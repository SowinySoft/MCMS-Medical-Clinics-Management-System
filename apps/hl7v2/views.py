"""Phase 7 - HL7 v2 ingestion API.

  POST /api/hl7v2/ingest/      -> ingest one raw HL7 v2 message (text or JSON)
  GET  /api/hl7v2/messages/    -> recent ingested messages (audit log)

Accepts the raw pipe-delimited message either as text/plain body or as
{"message": "MSH|..."} JSON. Routes ADT / SIU / ORU to the parser, stamps
created rows with the caller's facility (Phase 6), and returns an HL7-style
ACK code (AA/AE/AR). Idempotent on MSH-10.
"""

from django.db import connection
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet

from apps.core.permissions import HasRolePermission
from apps.hl7v2 import parser


class HL7V2ViewSet(ViewSet):
    permission_classes = [HasRolePermission]
    required_perms = {"ingest": "admin.all", "messages": "admin.all"}

    def _caller(self):
        from apps.core.models import AppUser
        au = AppUser.objects.filter(username=self.request.user.get_username()).first()
        if au is None:
            return None, None
        return au.user_id, au.facility_id

    @action(detail=False, methods=["post"], url_path=r"ingest")
    def ingest(self, request):
        raw = request.data.get("message") if isinstance(request.data, dict) else None
        if raw is None:
            body = request.body.decode("utf-8", "replace") if request.body else ""
            raw = body
        if not raw or "MSH" not in raw:
            return Response(
                {"detail": "supply a raw HL7 v2 message (text body or {'message': '...'})"},
                status=status.HTTP_400_BAD_REQUEST)
        user_id, facility_id = self._caller()
        try:
            result = parser.ingest(raw, facility_id=facility_id or 1, received_by=user_id)
        except parser.HL7Error as e:
            return Response({"ack": "AR", "detail": str(e)},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        http = status.HTTP_200_OK if result["ack"] == "AA" else status.HTTP_422_UNPROCESSABLE_ENTITY
        if result.get("duplicate"):
            http = status.HTTP_200_OK
        return Response(result, status=http)

    @action(detail=False, methods=["get"], url_path=r"messages")
    def messages(self, request):
        _, facility_id = self._caller()
        where, params = "", []
        if facility_id is not None:
            where = "WHERE facility_id = %s"
            params = [facility_id]
        with connection.cursor() as cur:
            cur.execute(
                "SELECT hl7_message_id, message_control_id, message_type, sending_app, "
                "       ack_code, error_detail, actions, received_at "
                f"FROM mcms_core.hl7_message {where} "
                "ORDER BY received_at DESC LIMIT 100", params)
            cols = [c[0] for c in cur.description]
            rows = [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]
        return Response({"count": len(rows), "results": rows})
