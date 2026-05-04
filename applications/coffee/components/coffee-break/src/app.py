#!/usr/bin/env python3
"""Minimal HTTP app for Konflux: build → test → release → deploy."""

from http.server import BaseHTTPRequestHandler, HTTPServer


class _Handler(BaseHTTPRequestHandler):
    def log_message(self, format: str, *args) -> None:  # noqa: A003
        return  # quiet default access logs

    def do_GET(self) -> None:
        if self.path == "/" or self.path.startswith("/?"):
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"OK")
        else:
            self.send_error(404)


def main() -> None:
    print("Hello from Konflux")
    server = HTTPServer(("0.0.0.0", 8080), _Handler)
    server.serve_forever()


if __name__ == "__main__":
    main()
