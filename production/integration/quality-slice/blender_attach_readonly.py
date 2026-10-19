"""Attach reviewed read-only discovery to the open Blender; never open/save a scene.

Run inside the explicitly handed-off Blender Python Console. This transient
adapter does not register the addon, preferences, updater, external providers or
arbitrary code execution. Stop with the saved server object's stop() method.
"""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import bpy

SOURCE = Path('C:/Work/MySelf/NEONSHIFT/.tools/blender-mcp/addon.py')
SOURCE_SHA = 'eb0facf69781a30e69792532087d8d41c6a14fcd323353250abe7988ee297fa5'
KEY = 'guildborne_readonly_bridge'
assert not bpy.app.background, 'Use the handed-off interactive Blender'
assert KEY not in bpy.app.driver_namespace, 'Existing bridge must be reviewed and stopped explicitly'
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == SOURCE_SHA, 'Reviewed source changed'

def snapshot():
    return (bpy.data.filepath, bpy.context.scene.as_pointer(),
            tuple((o.as_pointer(), o.name, tuple(o.location), tuple(o.rotation_euler), tuple(o.scale))
                  for o in bpy.context.scene.objects))

before = snapshot()
spec = importlib.util.spec_from_file_location('guildborne_readonly_addon', SOURCE)
addon = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = addon
spec.loader.exec_module(addon)

class ReadOnlyBridge(addon.BlenderMCPServer):
    def execute_command(self, command):
        if not isinstance(command, dict) or set(command) - {'type', 'params'}:
            return {'status': 'error', 'message': 'Bounded command object required'}
        kind = command.get('type')
        params = command.get('params', {})
        if not isinstance(params, dict):
            return {'status': 'error', 'message': 'Object params required'}
        if kind == 'get_object_info':
            if set(params) != {'name'} or not isinstance(params['name'], str) or not 1 <= len(params['name']) <= 256:
                return {'status': 'error', 'message': 'Bounded object name required'}
        elif params:
            return {'status': 'error', 'message': 'Unexpected parameters'}
        try:
            if kind == 'ping':
                result = {'pong': True, 'mode': 'guildborne-read-only'}
            elif kind == 'get_addon_info':
                result = {'name': 'Guildborne read-only discovery adapter',
                          'addon_version': list(addon.bl_info['version']),
                          'protocol_version': addon.ADDON_PROTOCOL_VERSION,
                          'capabilities': ['ping', 'get_addon_info', 'get_scene_info',
                                           'get_object_info', 'get_telemetry_consent'],
                          'blender_version': bpy.app.version_string, 'premium_generators': [],
                          'restricted_read_only': True}
            elif kind == 'get_scene_info':
                result = self.get_scene_info()
            elif kind == 'get_object_info' and isinstance(params.get('name'), str):
                result = self.get_object_info(params['name'])
            elif kind == 'get_telemetry_consent':
                result = {'consent': False}
            else:
                return {'status': 'error', 'message': 'Command denied by read-only Guildborne adapter'}
            return {'status': 'success', 'result': result}
        except Exception as error:
            return {'status': 'error', 'message': str(error)}

server = ReadOnlyBridge(host='127.0.0.1', port=19877)
server.start()
try:
    assert server.running, 'Local listener failed'
    assert snapshot() == before, 'Unexpected scene identity or transform change'
except Exception:
    server.stop()
    raise
bpy.app.driver_namespace[KEY] = server
print('GUILDBORNE_READONLY_BRIDGE_READY', json.dumps({
    'pid': os.getpid(), 'port': 19877, 'host': '127.0.0.1',
    'scene': bpy.context.scene.name, 'source_sha256': SOURCE_SHA,
    'scene_unchanged': True, 'addon_registered': False, 'write_commands': False,
    'upstream_commit': '7a0373ec9199183cb460068c4f96aed9c579fb4f',
}))
