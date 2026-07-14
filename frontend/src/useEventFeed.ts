// Live event feed over WebSocket. Subscribes to the backend event stream and
// exposes an accumulating list of domain events. Mirrors mcms_core.event_log.
import { useEffect, useRef, useState } from "react";
import cfg from "./config.json";

// Vite env override (docker/nginx) with config.json fallback.
const wsBase =
  (import.meta.env.VITE_WS_BASE as string | undefined) || cfg.wsBase;

export interface FeedEvent {
  seq: number;
  occurred_at: string;
  kind: string;
  severity: string;
  source_schema: string;
  source_table: string;
  payload: any;
}

export function useEventFeed(kinds: string[] = []) {
  const [events, setEvents] = useState<FeedEvent[]>([]);
  const [connected, setConnected] = useState(false);
  const ws = useRef<WebSocket | null>(null);

  useEffect(() => {
    if (!localStorage.getItem("access")) return;
    const url = wsBase;
    const socket = new WebSocket(url);
    ws.current = socket;

    socket.onopen = () => {
      setConnected(true);
      socket.send(JSON.stringify({ action: "subscribe", kinds }));
    };
    socket.onmessage = (e) => {
      const msg = JSON.parse(e.data);
      if (msg.type === "event") {
        setEvents((prev) => [msg.event, ...prev].slice(0, 100));
      }
    };
    socket.onclose = () => setConnected(false);

    return () => socket.close();
  }, []); // eslint-disable-line

  return { events, connected };
}
