"""MCMS real-time layer (Django Channels).

Streams domain events from mcms_core.event_log to authenticated clients over
WebSocket. Clients subscribe by sending {"action":"subscribe","kinds":[...]}.
The server pushes any new event_log row matching the requested kinds.

Pattern: event-stream-over-WS. The DB already emits events via triggers
(mcms_core.event_log); we poll for new seq values and forward them. This keeps
the realtime layer a thin projection of the event store (single source of truth).
"""
import json
import asyncio
from datetime import date, datetime, time
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.db import connection


def _json_default(obj):
    if isinstance(obj, (datetime, date, time)):
        return obj.isoformat()
    raise TypeError(str(type(obj)))


def _dumps(obj):
    return json.dumps(obj, default=_json_default)


@database_sync_to_async
def auth_user(scope_user):
    return bool(scope_user and getattr(scope_user, "is_authenticated", False))


@database_sync_to_async
def latest_seq():
    with connection.cursor() as cur:
        cur.execute("SELECT COALESCE(MAX(seq),0) FROM mcms_core.event_log")
        return cur.fetchone()[0]


@database_sync_to_async
def fetch_since(since, kinds):
    sql = """
        SELECT seq, occurred_at, kind, severity, source_schema, source_table, payload, channel
        FROM mcms_core.event_log
        WHERE seq > %s
    """
    params = [since]
    if kinds:
        sql += " AND kind = ANY(%s)"
        params.append(list(kinds))
    sql += " ORDER BY seq ASC"
    with connection.cursor() as cur:
        cur.execute(sql, params)
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row)) for row in cur.fetchall()]


class EventStreamConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        self.kinds = set()
        self.last_seq = await latest_seq()
        self.running = True
        self.poll_task = asyncio.create_task(self._poll())

    async def _poll(self):
        while self.running:
            try:
                rows = await fetch_since(self.last_seq, list(self.kinds))
                for r in rows:
                    self.last_seq = r["seq"]
                    payload = r.pop("payload")
                    try:
                        r["payload"] = json.loads(payload) if payload else {}
                    except (TypeError, json.JSONDecodeError):
                        r["payload"] = {}
                    await self.send(text_data=_dumps({"type": "event", "event": r}))
            except Exception as e:
                await self.send(text_data=json.dumps({"type": "error", "detail": str(e)}))
                await asyncio.sleep(2)
                continue
            await asyncio.sleep(1.5)

    async def receive(self, text_data=None, bytes_data=None):
        try:
            msg = json.loads(text_data or "{}")
        except json.JSONDecodeError:
            return
        action = msg.get("action")
        if action == "subscribe":
            self.kinds = set(msg.get("kinds") or [])
            await self.send(text_data=json.dumps(
                {"type": "subscribed", "kinds": sorted(self.kinds),
                 "last_seq": self.last_seq}))
        elif action == "ping":
            await self.send(text_data=json.dumps({"type": "pong"}))

    async def disconnect(self, code):
        self.running = False
