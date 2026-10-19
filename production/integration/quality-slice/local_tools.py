"""Original local Guildborne tool shortcuts; no provider, upload or Studio writes."""
from __future__ import annotations

import argparse
import hashlib
import http.client
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time
import uuid

ROOT = Path(__file__).resolve().parents[3]
MAX_RESPONSE = 262144
TIMEOUT = 3.0
BLENDER_COMMANDS = frozenset({"get_addon_info", "get_scene_info"})


def decode_response(raw):
    if len(raw) > MAX_RESPONSE:
        raise ValueError("Response exceeded 256 KiB")
    value = json.loads(raw)
    if not isinstance(value, dict):
        raise ValueError("Expected a JSON object")
    return value


def decode_rojo_msgpack(raw):
    """Decode only bounded metadata primitives, never MessagePack extensions."""
    if len(raw) > MAX_RESPONSE:
        raise ValueError("Response exceeded 256 KiB")
    offset = 0

    def take(size):
        nonlocal offset
        if offset + size > len(raw):
            raise ValueError("Truncated MessagePack metadata")
        value = raw[offset:offset + size]
        offset += size
        return value

    def read(depth=0):
        if depth > 8:
            raise ValueError("MessagePack nesting limit")
        tag = take(1)[0]
        if tag <= 0x7F:
            return tag
        if tag >= 0xE0:
            return tag - 256
        if tag == 0xC0:
            return None
        if tag in (0xC2, 0xC3):
            return tag == 0xC3
        if 0xCC <= tag <= 0xCF:
            return int.from_bytes(take(2 ** (tag - 0xCC)), "big")
        if 0xD0 <= tag <= 0xD3:
            return int.from_bytes(take(2 ** (tag - 0xD0)), "big", signed=True)
        if 0xA0 <= tag <= 0xBF or tag in (0xD9, 0xDA, 0xDB):
            size = tag & 31 if tag <= 0xBF else int.from_bytes(take(2 ** (tag - 0xD9)), "big")
            return take(size).decode("utf-8")
        if 0x80 <= tag <= 0x9F or tag in (0xDC, 0xDD, 0xDE, 0xDF):
            is_map = 0x80 <= tag <= 0x8F or tag in (0xDE, 0xDF)
            size = tag & 15 if tag <= 0x9F else int.from_bytes(take(2 if tag in (0xDC, 0xDE) else 4), "big")
            if size > 64:
                raise ValueError("MessagePack collection limit")
            if not is_map:
                return [read(depth + 1) for _ in range(size)]
            result = {}
            for _ in range(size):
                key = read(depth + 1)
                if not isinstance(key, str) or key in result:
                    raise ValueError("MessagePack keys must be unique strings")
                result[key] = read(depth + 1)
            return result
        raise ValueError(f"Unsupported MessagePack metadata tag {tag:#x}")

    value = read()
    if offset != len(raw) or not isinstance(value, dict):
        raise ValueError("Expected exactly one MessagePack metadata object")
    return value


def rojo_status():
    # HTTPConnection does not use environment proxies or follow redirects.
    connection = http.client.HTTPConnection("127.0.0.1", 34872, timeout=TIMEOUT)
    try:
        connection.request("GET", "/api/rojo", headers={"Accept": "application/json"})
        response = connection.getresponse()
        if response.status != 200:
            raise ValueError(f"Rojo HTTP status {response.status}; redirects are refused")
        raw = response.read(MAX_RESPONSE + 1)
        media_type = response.getheader("Content-Type", "").split(";")[0].strip()
        result = decode_rojo_msgpack(raw) if media_type == "application/msgpack" else decode_response(raw)
        if not isinstance(result.get("serverVersion"), str):
            raise ValueError("Response did not identify a Rojo server version")
        return result
    finally:
        connection.close()


def blender_request(command):
    if command not in BLENDER_COMMANDS:
        raise ValueError("Only read-only Blender discovery commands are allowed")
    deadline = time.monotonic() + TIMEOUT
    with socket.create_connection(("127.0.0.1", 19877), timeout=TIMEOUT) as connection:
        connection.sendall(json.dumps({"type": command, "params": {}}).encode("utf-8"))
        raw = bytearray()
        while len(raw) <= MAX_RESPONSE:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise TimeoutError("Blender response deadline exceeded")
            connection.settimeout(remaining)
            chunk = connection.recv(min(16384, MAX_RESPONSE + 1 - len(raw)))
            if not chunk:
                raise ValueError("Blender closed before a complete JSON object")
            raw.extend(chunk)
            try:
                result = decode_response(raw)
            except (json.JSONDecodeError, UnicodeDecodeError):
                continue  # TCP packets may split either JSON or a UTF-8 character.
            if result.get("status") != "success":
                raise ValueError("Blender bridge returned an error")
            return result["result"]
        raise ValueError("Blender response exceeded 256 KiB")


def status():
    report = {"scope": "LOCAL_CONNECTION_ONLY_NOT_STUDIO_TESTED", "paid_calls": 0}
    for name, probe in (("rojo", rojo_status), ("blender", blender_status)):
        try:
            report[name] = {"connected": True, "response": probe()}
        except (OSError, ValueError, KeyError, TypeError, http.client.HTTPException) as error:
            report[name] = {"connected": False, "error": str(error)}
    print(json.dumps(report, indent=2, ensure_ascii=True))
    return 0 if all(report[name]["connected"] for name in ("rojo", "blender")) else 1


def blender_status():
    info = blender_request("get_addon_info")
    if not isinstance(info, dict) or info.get("restricted_read_only") is not True:
        raise ValueError("Expected the reviewed restricted read-only Blender bridge")
    return {"adapter": info, "scene": blender_request("get_scene_info")}


def command_plan():
    return {
        "scope": "PLAN_ONLY_NOT_EXECUTED",
        "native_gui": {"build": "python tools/build_gui_review.py",
                       "source": ["src/client/UI", "tests/gui/gallery.client.luau"],
                       "output": "build/gui-review/GuildborneGUIReview.rbxlx"},
        "blender": {"audit_help": "python tools/agentic/blender_job.py --help",
                    "authoring": ["tools/blender_world_slice.py", "tools/blender_enemy_slice.py",
                                  "tools/blender_vfx_flipbook.py"],
                    "requirement": "Review scripts, exact inputs and exclusive DCC ownership before execution"},
        "quality_preview": {"script": "tools/build_quality_preview.py",
                            "requirement": "Controller owns build and separate Studio import/playtest"},
        "provider": "No ForgeGUI calls; existing owned art may be reused after rights and native UI review",
        "limits": "No cloud publishing, downloads, API spending, automatic imports or acceptance promotion",
    }


def build_gui_review(ledger, token):
    if not ledger or not token:
        raise ValueError("Build requires --ledger and --lease-token for quality-slice-integration")
    # Reuse the project's existing cooperative lease check; never create a ledger.
    ledger = Path(ledger).resolve(strict=True)
    try:
        lease = subprocess.run([sys.executable, str(ROOT / "tools/agentic/forge.py"), "check-lease",
                                "--ledger", str(ledger), "--task", "quality-slice-integration",
                                "--token", token], cwd=ROOT, check=False, timeout=15,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.TimeoutExpired:
        raise ValueError("Lease verification timed out; no build started") from None
    if lease.returncode != 0:
        raise ValueError("Lease verification failed; no build started")
    output = ROOT / "build/gui-review"
    if output.resolve() != output or any(p.resolve() != p for p in output.rglob("*")):
        raise ValueError("Review output must not redirect through symlinks or junctions")
    script = ROOT / "tools/build_gui_review.py"
    source_hash = hashlib.sha256(script.read_bytes()).hexdigest()
    output.mkdir(parents=True, exist_ok=True)
    receipt_dir = output / ("local-tools-" + uuid.uuid4().hex)
    receipt_dir.mkdir()
    argv = [sys.executable, str(script)]
    started = time.time()
    timed_out = False
    cleanup = {"status": "NOT_NEEDED", "errors": [], "direct_child_reaped": False}
    with (receipt_dir / "stdout.txt").open("wb") as stdout, (receipt_dir / "stderr.txt").open("wb") as stderr:
        process = subprocess.Popen(argv, cwd=ROOT, stdout=stdout, stderr=stderr, shell=False)
        try:
            exit_code = process.wait(timeout=120)
        except subprocess.TimeoutExpired:
            timed_out = True
            exit_code = None
            if os.name == "nt":
                try:
                    killed = subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"],
                                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                            timeout=10, check=False)
                    if killed.returncode != 0:
                        cleanup["errors"].append(f"Tree cleanup exited {killed.returncode}")
                except (OSError, subprocess.SubprocessError) as error:
                    cleanup["errors"].append(f"Tree cleanup: {error}")
            # A failed tree-cleanup utility must not skip direct-child cleanup or
            # erase the original build's raw streams and failure receipt.
            try:
                process.kill()
            except OSError as error:
                cleanup["errors"].append(f"Direct child kill: {error}")
            try:
                exit_code = process.wait(timeout=10)
                cleanup["direct_child_reaped"] = True
            except (OSError, subprocess.SubprocessError) as error:
                cleanup["errors"].append(f"Direct child wait: {error}")
            cleanup["status"] = "FAILED" if cleanup["errors"] else "COMPLETED"
    receipt = {"argv": argv, "cwd": str(ROOT), "exit_code": exit_code,
               "timed_out": timed_out, "elapsed_seconds": round(time.time() - started, 3),
               "cleanup": cleanup,
               "builder_sha256": source_hash,
               "status": "BUILT_NOT_STUDIO_TESTED" if exit_code == 0 and not timed_out else "BUILD_FAILED",
               "stdout": str(receipt_dir / "stdout.txt"), "stderr": str(receipt_dir / "stderr.txt"),
               "paid_calls": 0}
    (receipt_dir / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(receipt, indent=2))
    return 0 if receipt["status"] == "BUILT_NOT_STUDIO_TESTED" else 1


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--status", action="store_true", help="Read fixed loopback Rojo and restricted Blender endpoints (default)")
    mode.add_argument("--plan", action="store_true", help="Print existing local pipelines without executing them")
    mode.add_argument("--build-gui-review", action="store_true", help="Explicitly build only the existing native GUI review fixture")
    parser.add_argument("--ledger", help="Existing shared coordinator SQLite ledger (build only)")
    parser.add_argument("--lease-token", help="Current controller quality-slice-integration lease token (build only)")
    args = parser.parse_args(argv)
    try:
        if args.build_gui_review:
            return build_gui_review(args.ledger, args.lease_token)
        if args.ledger or args.lease_token:
            parser.error("Lease arguments are only accepted with --build-gui-review")
        if args.plan:
            print(json.dumps(command_plan(), indent=2))
            return 0
        return status()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"Local tool action failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
