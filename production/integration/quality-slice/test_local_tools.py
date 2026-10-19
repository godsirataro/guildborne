"""Deterministic safety fixtures; not Studio or physical-device acceptance."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import MagicMock, patch

spec = importlib.util.spec_from_file_location("local_tools", Path(__file__).with_name("local_tools.py"))
local_tools = importlib.util.module_from_spec(spec)
spec.loader.exec_module(local_tools)


class LocalToolsTests(unittest.TestCase):
    def test_messagepack_rojo_metadata(self):
        raw = b"\x83\xadserverVersion\xa57.7.0\xafprotocolVersion\x05\xb0expectedPlaceIds\xc0"
        self.assertEqual(local_tools.decode_rojo_msgpack(raw), {
            "serverVersion": "7.7.0", "protocolVersion": 5, "expectedPlaceIds": None})

    def test_reject_invalid_messagepack(self):
        for raw in (b"\x81\xa1a", b"\x80\x80", b"\x82\xa1a\x00\xa1a\x00",
                    b"\x81\xa1a\xc7", b"\x81\xa1a" + b"\x91" * 10 + b"\x00",
                    b"\xde\x00\x41", b"\x80" * (local_tools.MAX_RESPONSE + 1)):
            with self.subTest(raw=raw[:16]), self.assertRaises(ValueError):
                local_tools.decode_rojo_msgpack(raw)

    def test_reject_code_without_network(self):
        with patch.object(local_tools.socket, "create_connection") as connect:
            with self.assertRaises(ValueError):
                local_tools.blender_request("execute_code")
            connect.assert_not_called()

    def test_restrict_adapter_before_scene(self):
        with patch.object(local_tools, "blender_request", return_value={"restricted_read_only": False}) as request:
            with self.assertRaises(ValueError):
                local_tools.blender_status()
            request.assert_called_once_with("get_addon_info")

    def test_json_bound_and_shape(self):
        for raw in (b"[]", b" " * (local_tools.MAX_RESPONSE + 1)):
            with self.assertRaises(ValueError):
                local_tools.decode_response(raw)

    def test_build_requires_lease_without_process(self):
        with patch.object(local_tools.subprocess, "run") as run:
            with self.assertRaises(ValueError):
                local_tools.build_gui_review(None, None)
            run.assert_not_called()

    def test_invalid_lease_does_not_start_builder(self):
        with patch.object(local_tools.subprocess, "run") as run, patch.object(local_tools.subprocess, "Popen") as popen:
            run.return_value.returncode = 1
            with self.assertRaisesRegex(ValueError, "Lease verification failed"):
                local_tools.build_gui_review(__file__, "fixture-token")
            popen.assert_not_called()

    def timeout_fixture(self, tree_error, direct_cleanup_fails=False):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            (root / "tools").mkdir()
            (root / "tools/build_gui_review.py").write_text("# Fixture only\n", encoding="utf-8")
            process = MagicMock(pid=12345)
            process.wait.side_effect = [
                subprocess.TimeoutExpired("fixture-builder", 120),
                subprocess.TimeoutExpired("fixture-builder", 10) if direct_cleanup_fails else -9,
            ]
            if direct_cleanup_fails:
                process.kill.side_effect = OSError("fixture kill failed")

            def launch(*args, **kwargs):
                kwargs["stdout"].write(b"fixture stdout\x00\xff\n")
                return process

            with patch.object(local_tools, "ROOT", root), \
                    patch.object(local_tools, "os", SimpleNamespace(name="nt")), \
                    patch.object(local_tools.subprocess, "run", side_effect=[SimpleNamespace(returncode=0), tree_error]), \
                    patch.object(local_tools.subprocess, "Popen", side_effect=launch), \
                    patch("builtins.print"):
                self.assertEqual(local_tools.build_gui_review(__file__, "fixture-token"), 1)
            process.kill.assert_called_once_with()
            self.assertEqual(process.wait.call_count, 2)
            process.wait.assert_called_with(timeout=10)
            receipt_path, = (root / "build/gui-review").glob("*/receipt.json")
            receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
            self.assertEqual(receipt["status"], "BUILD_FAILED")
            self.assertTrue(receipt["timed_out"])
            self.assertEqual(receipt["cleanup"]["status"], "FAILED")
            self.assertTrue(receipt["cleanup"]["errors"])
            self.assertEqual(receipt["cleanup"]["direct_child_reaped"], not direct_cleanup_fails)
            self.assertEqual(Path(receipt["stdout"]).read_bytes(), b"fixture stdout\x00\xff\n")
            self.assertEqual(Path(receipt["stderr"]).read_bytes(), b"")

    def test_taskkill_timeout_retains_receipt_and_reaps_child(self):
        self.timeout_fixture(subprocess.TimeoutExpired("taskkill", 10))

    def test_all_cleanup_failures_still_retain_receipt(self):
        self.timeout_fixture(OSError("fixture taskkill unavailable"), direct_cleanup_fails=True)


if __name__ == "__main__":
    unittest.main()
