#!/usr/bin/env python3
"""
HomeAssistant Health Exporter
Exports HA API connectivity metrics to Prometheus format.
"""

import http.client
import json
import time
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

HA_HOST = "localhost"
HA_PORT = 8123


class HAHealthExporterHandler(BaseHTTPRequestHandler):
    """HTTP handler for Prometheus metrics endpoint."""

    def do_GET(self):
        if self.path == "/metrics":
            self._serve_metrics()
        elif self.path == "/health":
            self._serve_health()
        else:
            self.send_response(404)
            self.end_headers()

    def _serve_metrics(self):
        """Query HA API and serve metrics in Prometheus format."""
        metrics = []

        # Get entity count
        entities_count = self._query_entities()
        metrics.append(f'ha_entities_count {{status="ok"}} {entities_count}')

        # Get version/response time
        response_time, version_status = self._query_version()
        metrics.append(f"ha_api_response_time_seconds {response_time:.3f}")
        metrics.append(f'ha_api_status {{status="{version_status}"}} 1')

        # Success indicator
        metrics.append("ha_exporter_up 1")

        content = "\n".join(metrics) + "\n"

        self.send_response(200)
        self.send_header("Content-Type", "text/plain; version=0.0.4")
        self.end_headers()
        self.wfile.write(content.encode())

    def _serve_health(self):
        """Health check endpoint."""
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok"}).encode())

    def _query_entities(self):
        """Query HA API for entity count."""
        try:
            conn = http.client.HTTPConnection(HA_HOST, HA_PORT, timeout=5)
            conn.request("GET", "/api/states")
            response = conn.getresponse()
            if response.status == 200:
                data = json.loads(response.read().decode())
                return len(data)
            else:
                return 0
        except Exception:
            return 0

    def _query_version(self):
        """Query HA API for version and response time."""
        start_time = time.time()
        try:
            conn = http.client.HTTPConnection(HA_HOST, HA_PORT, timeout=5)
            conn.request("GET", "/api/version")
            response = conn.getresponse()
            if response.status == 200:
                response_time = time.time() - start_time
                return response_time, "ok"
            else:
                return time.time() - start_time, "error"
        except Exception:
            return time.time() - start_time, "error"

    def log_message(self, format, *args):
        """Suppress default logging."""
        pass


def main():
    server = HTTPServer(("0.0.0.0", 9102), HAHealthExporterHandler)
    print("HA Health Exporter running on port 9102")
    server.serve_forever()


if __name__ == "__main__":
    main()
