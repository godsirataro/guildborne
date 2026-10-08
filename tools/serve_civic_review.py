"""Loopback-only, six-file bridge for an owned Studio art-review session."""
from pathlib import Path
from http.server import HTTPServer,BaseHTTPRequestHandler
import os
R=Path(__file__).resolve().parents[1];D=R/'build/civic-native-review'
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  name=self.path.removeprefix('/')
  if name not in {n+'.json'for n in ['borin','vaela','roka','elian','nyra','sela']}:self.send_error(404);return
  body=(D/name).read_bytes();self.send_response(200);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(body)));self.end_headers();self.wfile.write(body)
server=HTTPServer(('127.0.0.1',8769),Handler)
(R/'build/civic-review-server.pid').write_text(str(os.getpid()),encoding='ascii');server.serve_forever()
