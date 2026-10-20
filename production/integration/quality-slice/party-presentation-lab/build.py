"""Copy the current quality project into a separate disposable party candidate.

Never invokes the ordinary preview builders or writes their outputs. All input
file identities are checked across the build; interrupted output is not accepted.
"""
from pathlib import Path
import argparse, hashlib, json, os, subprocess, xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def source_files(node):
    found = set()
    if isinstance(node, dict):
        if "$path" in node:
            p = Path(node["$path"])
            if not p.is_absolute():
                p = ROOT / p
            if not p.exists():
                raise ValueError(f"Missing input: {p}")
            found.update(x for x in p.rglob("*") if x.is_file()) if p.is_dir() else found.add(p)
        for value in node.values():
            found.update(source_files(value))
    return found

def prepare(source, start, three_road_walk=False):
    project = json.loads(source.read_text(encoding="utf-8-sig"))
    tree = project["tree"]
    server = tree["ServerScriptService"]["Server"]
    runtime = Path(server["Config"]["Runtime"]["$path"])
    text = runtime.read_text(encoding="utf-8-sig")
    if three_road_walk:
        template = (ROOT / "offline/ArchiveHeartRuntime.luau").read_text(encoding="utf-8-sig")
        assert template.count("return {") == 1
        expected = template.replace("return {", "return {\n    FullConnectedWorldCandidate=true,", 1)
        assert text == expected, "Three-road lab requires the exact reviewed full-connected runtime; regenerate the quality preview"
    assert 'StudioPersistence="Memory"' in text and 'AllowedDataStoreUniverses={}' in text
    assert tree["ReplicatedStorage"]["QualityPreviewAssets"]["$attributes"]["IsolatedMemory"] is True
    server["ServerBootstrap"].setdefault("$properties", {})["Disabled"] = True
    scripts = tree["StarterPlayer"]["StarterPlayerScripts"]
    # A directory $path plus an explicit same-name child produces TWO instances
    # in Rojo, not an override. Expand this one folder before setting Disabled.
    original_client = scripts["Client"]
    client_root = Path(original_client["$path"])
    assert client_root.resolve() == (ROOT / "src/client").resolve()
    client = {"$className": "Folder"}
    for path in sorted(client_root.iterdir()):
        if path.is_dir():
            client[path.name] = {"$path": str(path)}
        elif path.suffix == ".luau":
            name = path.stem.removesuffix(".client").removesuffix(".server")
            assert name not in client, f"Duplicate client source name: {name}"
            client[name] = {"$path": str(path)}
    assert not any(not k.startswith("$") for k in original_client), "Unexpected client overrides require review"
    for key in ("$attributes", "$properties"):
        if key in original_client:
            client[key] = original_client[key]
    scripts["Client"] = client
    client["ClientBootstrap"] = {
        "$path": str(ROOT / "src/client/ClientBootstrap.client.luau"),
        "$properties": {"Disabled": True},
    }
    tree["ServerScriptService"]["PartyPresentationLab"] = {
        "$path": str(HERE / "PartyPresentation.server.luau"), "$attributes": {"StartZone": start, "ThreeRoadWalk": three_road_walk}}
    scripts["PartyPresentationLab"] = {"$path": str(HERE / "PartyPresentation.client.luau")}
    project["name"] = "Guildborne_PartyPresentationLab"
    project.pop("servePlaceIds", None)
    project["serveAddress"] = "127.0.0.1"
    return project

def snapshot(project, source):
    # Re-enumerate every time, including new/removed children of source directories.
    # Client was expanded into explicit children: still monitor its original root
    # so a newly added top-level file invalidates the prepared project as well.
    client_files = {p for p in (ROOT / "src/client").rglob("*") if p.is_file()}
    return {str(p): sha(p) for p in sorted(source_files(project) | client_files | {source, Path(__file__).resolve(), ROOT / "offline/ArchiveHeartRuntime.luau"})}

def verify_bootstraps(target):
    expected = {
        ("ServerScriptService", "Server", "ServerBootstrap"): "Script",
        ("StarterPlayer", "StarterPlayerScripts", "Client", "ClientBootstrap"): "LocalScript",
    }
    found = []
    def walk(parent, ancestry):
        for item in parent.findall("Item"):
            props = item.find("Properties")
            values = {} if props is None else {p.attrib.get("name"): p.text for p in props}
            path = ancestry + (values.get("Name"),)
            if values.get("Name") in ("ServerBootstrap", "ClientBootstrap"):
                found.append((path, item.attrib.get("class"), values.get("Disabled")))
            walk(item, path)
    walk(ET.parse(target).getroot(), ())
    assert len(found) == 2, f"Exactly two bootstraps required, found: {found!r}"
    seen = set()
    for path, kind, disabled in found:
        assert path in expected and path not in seen and kind == expected[path] and disabled == "true", f"Unsafe bootstrap: {(path, kind, disabled)!r}"
        seen.add(path)
    assert seen == set(expected)
    return [{"path": list(path), "className": kind, "disabled": True} for path, kind, _ in found]

def bounded_build(command, out, receipt):
    process = None
    with (out / "build.stdout.txt").open("wb") as stdout, (out / "build.stderr.txt").open("wb") as stderr:
        try:
            process = subprocess.Popen(command, cwd=ROOT, stdout=stdout, stderr=stderr)
            receipt["pid"] = process.pid
            receipt["exitCode"] = process.wait(timeout=120)
        finally:
            if process is not None and process.poll() is None:
                cleanup = dict(treeTerminationAttempted=False, confirmedExited=False)
                receipt["cleanup"] = cleanup
                try:
                    if os.name == "nt":
                        cleanup["treeTerminationAttempted"] = True
                        with (out / "cleanup.stdout.txt").open("wb") as co, (out / "cleanup.stderr.txt").open("wb") as ce:
                            killed = subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"],
                                                    stdout=co, stderr=ce, timeout=10)
                        cleanup["taskkillExitCode"] = killed.returncode
                    else:
                        process.kill()
                    process.wait(timeout=5)
                    cleanup["confirmedExited"] = True
                except Exception as error:
                    cleanup["error"] = repr(error)
                    # Never wait indefinitely, nor claim child-tree cleanup from
                    # killing only the parent. Retain the unresolved tree result.
                    try:
                        process.kill()
                        process.wait(timeout=5)
                        cleanup["parentExited"] = True
                    except Exception as fallback:
                        cleanup["fallbackError"] = repr(fallback)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--start-zone", choices=["Guild", "City"], default="Guild")
    parser.add_argument("--three-road-walk", action="store_true", help="Synthetic third route; requires full-connected isolated runtime")
    parser.add_argument("--output-dir", help="New directory beneath repository build/; existing attempts are refused")
    args = parser.parse_args()
    source = ROOT / "build/quality-preview.project.json"
    out = Path(args.output_dir) if args.output_dir else ROOT / "build/party-presentation-lab"
    if not out.is_absolute():
        out = ROOT / out
    out = out.resolve()
    build_root = (ROOT / "build").resolve()
    assert out != build_root and out.is_relative_to(build_root), "Output must be a new child directory within build/"
    out.mkdir(parents=True, exist_ok=False)  # preserve ALL prior attempt evidence
    target = out / "Guildborne_PartyPresentationLab.rbxlx"
    receipt_path = out / "receipt.json"
    project_path = out / "review.project.json"
    command = [str(ROOT / ".tools/rojo/rojo.exe"), "build", str(project_path), "--output", str(target)]
    receipt = dict(status="FAILED", command=command, exitCode=None, timeoutSeconds=120,
                   inputHashes={}, inputsUnchanged=False, synthetic=True,
                   startZone=args.start_zone, threeRoadWalk=args.three_road_walk, walkingRouteCount=3 if args.three_road_walk else 2, studioTested=False, profileWrites=0)
    project = None
    failure = None
    try:
        original = source.read_bytes()
        project = prepare(source, args.start_zone, args.three_road_walk)
        receipt["inputHashes"] = snapshot(project, source)
        project_path.write_text(json.dumps(project, indent=2) + "\n", encoding="utf-8")
        bounded_build(command, out, receipt)
        after = snapshot(project, source)
        receipt["afterInputHashes"] = after
        before = receipt["inputHashes"]
        receipt["addedInputs"] = sorted(set(after) - set(before))
        receipt["removedInputs"] = sorted(set(before) - set(after))
        receipt["inputsUnchanged"] = before == after and source.read_bytes() == original
        assert receipt["exitCode"] == 0 and receipt["inputsUnchanged"], "Build failed or input set/content changed"
        bootstraps = verify_bootstraps(target)
        receipt.update(status="BUILT_NOT_STUDIO_TESTED", candidate=str(target),
                       candidateSha256=sha(target), disabledBootstraps=bootstraps,
                       projectSha256=sha(project_path))
    except BaseException as error:
        failure = error
        receipt["status"] = "FAILED"
        receipt["error"] = repr(error)
        # Capture changed file sets even after timeout/build failure where possible.
        if project is not None:
            try:
                after = snapshot(project, source)
                receipt["afterInputHashes"] = after
                receipt["addedInputs"] = sorted(set(after) - set(receipt["inputHashes"]))
                receipt["removedInputs"] = sorted(set(receipt["inputHashes"]) - set(after))
                receipt["inputsUnchanged"] = bool(receipt["inputHashes"]) and receipt["inputHashes"] == after
            except Exception as inventory_error:
                receipt["inputInventoryError"] = repr(inventory_error)
                receipt["inputsUnchanged"] = False
    finally:
        receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: receipt.get(k) for k in ("status", "exitCode", "inputsUnchanged", "candidate", "candidateSha256", "error", "cleanup")}, indent=2))
    if failure is not None:
        raise failure

if __name__ == "__main__":
    main()
