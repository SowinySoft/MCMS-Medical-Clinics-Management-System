"""ASGI config for MCMS.

Routes HTTP to Django (DRF/Swagger) and WebSocket (/ws/events/) to Channels.
Served by Daphne in dev/prod:  daphne config.asgi:application
"""
import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

# HTTP application must be created before importing models that rely on apps
http_app = get_asgi_application()

from apps.core.consumers import EventStreamConsumer  # noqa: E402

websocket_urlpatterns = [
    path("ws/events/", EventStreamConsumer.as_asgi()),
]

application = ProtocolTypeRouter({
    "http": http_app,
    "websocket": URLRouter(websocket_urlpatterns),
})
