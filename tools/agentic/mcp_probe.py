"""Bounded MCP stdio discovery; only read-only Studio discovery tools are callable."""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import queue
import math
import signal
import subprocess
import sys
import threading
import time
from forge import ROOT, read_json, save_json, reject_constant, unique_pairs

MAX_LINE = 2 * 1024 * 1024
READ_TOOLS = {'list_roblox_studios', 'get_studio_state'}
SUPPORTED_PROTOCOLS = ('2024-11-05', '2025-03-26', '2025-06-18', '2025-11-25')


class StdioClient:
    def __init__(self, argv: list[str], timeout: float = 15):
        if not argv or not all(isinstance(s, str) and s and '\0' not in s for s in argv):
            raise ValueError('Explicit MCP executable and argument list required')
        if type(timeout) not in (int, float) or not math.isfinite(timeout) or not 1 <= timeout <= 120:
            raise ValueError('Timeout must be 1..120 seconds')
        self.timeout, self.serial = timeout, 0
        self.discovered_names = set()
        self.failure = None
        self.messages = queue.Queue(maxsize=128)
        creation = {'creationflags': subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == 'nt' else {'start_new_session': True}
        self.process = subprocess.Popen(argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, shell=False, bufsize=0, **creation)
        self.reader = threading.Thread(target=self._read, daemon=True)
        self.reader.start()

    def _read(self):
        try:
            while True:
                raw = self.process.stdout.readline(MAX_LINE + 1)
                if not raw:
                    self.messages.put_nowait(ValueError('MCP process closed stdout')); return
                if len(raw) > MAX_LINE:
                    raise ValueError('MCP response exceeded size budget')
                self.messages.put_nowait(json.loads(raw, parse_constant=reject_constant, object_pairs_hook=unique_pairs))
        except Exception as exc:
            self.failure = ValueError(str(exc))
            try: self.messages.put_nowait(ValueError(str(exc)))
            except queue.Full: pass

    def send(self, message):
        data = json.dumps(message, allow_nan=False).encode() + b'\n'
        if len(data) > MAX_LINE:
            raise ValueError('MCP request too large')
        self.process.stdin.write(data); self.process.stdin.flush()

    def request(self, method, params=None):
        self.serial += 1
        request_id = self.serial
        self.send({'jsonrpc': '2.0', 'id': request_id, 'method': method, 'params': params or {}})
        deadline = time.monotonic() + self.timeout
        while time.monotonic() < deadline:
            if self.failure:
                raise self.failure
            try: value = self.messages.get(timeout=max(.001, deadline - time.monotonic()))
            except queue.Empty: raise ValueError('MCP request timed out') from None
            if isinstance(value, Exception): raise value
            if not isinstance(value, dict) or value.get('jsonrpc') != '2.0': raise ValueError('Invalid MCP response')
            if 'method' in value:
                # Never execute server-initiated sampling/elicitation or commands.
                if 'id' in value:
                    self.send({'jsonrpc': '2.0', 'id': value['id'],
                               'error': {'code': -32601, 'message': 'Client capability not available'}})
                continue
            if type(value.get('id')) is not int or value['id'] != request_id:
                continue
            if ('result' in value) == ('error' in value):
                raise ValueError('MCP response must contain result or error, not both/neither')
            if 'error' in value:
                raise ValueError(f'MCP {method} returned an error')
            if not isinstance(value.get('result'), dict):
                raise ValueError('Expected an MCP result object')
            return value['result']
        raise ValueError('MCP deadline exceeded')

    def discover(self):
        hello = self.request('initialize', {'protocolVersion': '2025-11-25', 'capabilities': {},
            'clientInfo': {'name': 'guildborne-readonly-probe', 'version': '2.1'}})
        if hello.get('protocolVersion') not in SUPPORTED_PROTOCOLS:
            raise ValueError('Unsupported negotiated MCP version; update the reviewed adapter')
        self.send({'jsonrpc': '2.0', 'method': 'notifications/initialized'})
        tools, cursor, seen, cursors = [], None, set(), set()
        for _ in range(20):
            result = self.request('tools/list', {'cursor': cursor} if cursor else {})
            chunk = result.get('tools')
            if not isinstance(chunk, list): raise ValueError('Invalid tools/list')
            for tool in chunk:
                if not isinstance(tool, dict):
                    raise ValueError('MCP tool definition must be an object')
                name = tool.get('name')
                if not isinstance(name, str) or not name.strip() or len(name) > 256 or name in seen:
                    raise ValueError('Missing/duplicate MCP tool name')
                if not isinstance(tool.get('inputSchema'), dict):
                    raise ValueError('MCP tool inputSchema required')
                seen.add(name); tools.append(tool)
                if len(tools) > 2000:
                    raise ValueError('MCP tool count exceeds probe budget')
            cursor = result.get('nextCursor')
            if cursor is None:
                self.discovered_names = seen
                return {'protocolVersion': hello['protocolVersion'], 'serverInfo': hello.get('serverInfo'), 'tools': tools}
            if not isinstance(cursor, str) or not cursor or cursor in cursors:
                raise ValueError('Invalid or repeated MCP pagination cursor')
            cursors.add(cursor)
        raise ValueError('MCP tool pagination exceeded limit')

    def call_read(self, name, arguments=None):
        if name not in READ_TOOLS:
            raise ValueError('Probe adapter forbids mutating/generation tools')
        if name not in self.discovered_names:
            raise ValueError('Read-only tool was not advertised by this MCP connection')
        result = self.request('tools/call', {'name': name, 'arguments': arguments or {}})
        if result.get('isError'): raise ValueError('MCP discovery tool failed')
        return result

    def close(self):
        if self.process.stdin and not self.process.stdin.closed:
            try:
                self.process.stdin.close()
            except BrokenPipeError:
                pass
        try:
            self.process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            # This process was created in its own group above. Never kill by
            # executable name: only the bridge tree owned by this probe.
            if os.name == 'nt':
                subprocess.run(['taskkill', '/PID', str(self.process.pid), '/T', '/F'],
                               capture_output=True, timeout=15, check=False)
            else:
                try:
                    os.killpg(self.process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            if self.process.poll() is None:
                self.process.kill()
            self.process.wait(timeout=5)
        if self.process.stdout and not self.process.stdout.closed:
            self.process.stdout.close()
        self.reader.join(timeout=1)


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config', type=Path, required=True, help='Reviewed local JSON: command array')
    p.add_argument('--approve-command-sha256', required=True)
    args = p.parse_args(argv)
    from forge import digest
    if digest(args.config) != args.approve_command_sha256:
        raise ValueError('Review the exact local MCP command configuration before execution')
    config = read_json(args.config)
    client = StdioClient(config['command'])
    try:
        report = client.discover()
        names = {t['name'] for t in report['tools']}
        report['connectedAt'] = time.time()
        report['status'] = 'MCP_CONNECTED_NOT_STUDIO_ACCEPTED'
        report['studios'] = client.call_read('list_roblox_studios') if 'list_roblox_studios' in names else None
        report['warning'] = 'Verify the exact Studio ID/place in the agent session before ANY write. Discovery alone grants no production permission.'
        save_json(ROOT/'build/agentic/mcp-discovery.json', report)
        print(json.dumps({'status': report['status'], 'tools': sorted(names)}))
    finally: client.close()


if __name__ == '__main__':
    try: main()
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as exc:
        print(f'MCP probe blocked: {exc}', file=sys.stderr); sys.exit(1)
