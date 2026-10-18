"""Build the current game as a separate Memory-only Studio candidate.

Does not connect/sync Studio, modify the staging Runtime, or publish anything.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import argparse

ROOT = Path(__file__).resolve().parents[1]


def build(launch=False, shared_combat=False, continuous_world=False, full_campaign=False):
    if full_campaign and (launch or shared_combat or continuous_world):
        raise ValueError("Full campaign is a separate Memory candidate; do not combine with launch fixtures")
    if shared_combat and not launch:
        raise ValueError("Shared combat fixture requires --launch")
    if continuous_world and not launch:
        raise ValueError("Continuous world fixture requires --launch")
    runtime = ROOT / "src/server/Config/Runtime.luau"
    before = hashlib.sha256(runtime.read_bytes()).hexdigest()
    project = json.loads((ROOT / "default.project.json").read_text())
    variant = "full-campaign" if full_campaign else "launch" if launch else "integration"
    project["name"] = "Guildborne_LaunchPreview" if launch else "Guildborne_IntegrationPreview"
    if continuous_world:
        project["name"] = "Guildborne_ContinuousWorldPreview"
    out = ROOT / "build"
    out.mkdir(exist_ok=True)
    runtime_path = ROOT / "offline/Runtime.luau"
    if full_campaign:
        project["name"] = "Guildborne_FullCampaignPreview"
        runtime_path = ROOT / "offline/ArchiveHeartRuntime.luau"
        full_runtime = runtime_path.read_text(encoding="utf-8")
        for flag in ("NoviceJourney", "IronveilJourney", "AshenJourney", "TowerJourney", "CrosshavenJourney", "ArchiveHeartJourney"):
            assert full_runtime.count(flag + "=true") == 1, f"Full campaign runtime missing {flag}"
        assert "LaunchCandidate" not in full_runtime, "Full campaign must not enable the Lv35 release selection"
    if launch:
        base_runtime = runtime_path.read_text()
        for flag in ("NoviceJourney=false", "IronveilJourney=false"):
            assert base_runtime.count(flag) == 1, f"Unexpected offline runtime: {flag}"
        assert "LaunchCandidate" not in base_runtime
        candidate_runtime = base_runtime.replace('NoviceJourney=false', 'LaunchCandidate=true,\n    NoviceJourney=true').replace('IronveilJourney=false','IronveilJourney=true')
        if shared_combat:
            candidate_runtime = candidate_runtime.replace('LaunchCandidate=true,', 'LaunchCandidate=true,\n    SharedCombatCandidate=true,')
        if continuous_world:
            candidate_runtime = candidate_runtime.replace('LaunchCandidate=true,', 'LaunchCandidate=true,\n    ContinuousWorldCandidate=true,')
        runtime_path = out / "LaunchRuntime.luau"
        runtime_path.write_text(candidate_runtime, encoding="utf-8")
    project.pop("servePlaceIds", None)
    server = {"$className": "Folder"}
    for entry in sorted((ROOT / "src/server").iterdir()):
        if entry.name == "Config":
            server["Config"] = {"$className": "Folder", **{
                p.stem: {"$path": str(p)} for p in entry.glob("*.luau")}}
            server["Config"]["Runtime"] = {"$path": str(runtime_path)}
        elif entry.is_dir():
            server[entry.name] = {"$path": str(entry)}
        elif entry.suffix == ".luau":
            server[entry.stem.removesuffix(".server").removesuffix(".client")] = {"$path": str(entry)}
    project["tree"]["ServerScriptService"]["Server"] = server

    def absolute(node):
        if isinstance(node, dict):
            if "$path" in node and not Path(node["$path"]).is_absolute():
                node["$path"] = str(ROOT / node["$path"])
            for value in node.values():
                absolute(value)
    absolute(project)
    offline = runtime_path.read_text()
    assert 'StudioPersistence="Memory"' in offline and 'AllowedDataStoreUniverses={}' in offline
    out = ROOT / "build"
    out.mkdir(exist_ok=True)
    # Package an already-authored local study beside the full game. This is a
    # preview-only client mesh, never a production imported asset declaration.
    data = ROOT / "build/civic-native-review/borin.json"
    if data.is_file():
        source = data.read_text(encoding="utf-8")
        parsed = json.loads(source)
        assert parsed["id"] == "borin" and len(parsed["bones"]) == 16 and len(parsed["frames"]) == 181
        art = out / "integration-art"
        art.mkdir(exist_ok=True)
        chunks = [source[i:i + 140000] for i in range(0, len(source), 140000)]
        for i, chunk in enumerate(chunks, 1):
            delimiter = "=="
            while "]" + delimiter + "]" in chunk:
                delimiter += "="
            (art / f"Chunk{i}.luau").write_text('return [' + delimiter + '[' + chunk + ']' + delimiter + ']\n', encoding="utf-8")
        (art / "Data.luau").write_text('local pieces={}\nfor i=1,' + str(len(chunks)) + ' do pieces[i]=require(script.Parent["Chunk"..i]) end\nreturn game:GetService("HttpService"):JSONDecode(table.concat(pieces))\n', encoding="utf-8")
        native = (ROOT / "tools/native_civic_contact_review.luau").read_text(encoding="utf-8")
        native = native.replace('local d=data or Http:JSONDecode(Http:GetAsync("http://127.0.0.1:8769/"..id..".json"))', 'local d=assert(data,"Packaged art required")')
        assert "GetAsync" not in native
        (art / "NativeReview.luau").write_text("return function()\n" + native + "\nend\n", encoding="utf-8")
        project["tree"]["ReplicatedStorage"]["IntegrationArt"] = {
            "$className": "Folder", "$attributes": {"SourceSha256": hashlib.sha256(data.read_bytes()).hexdigest()},
            "Data": {"$path": str(art / "Data.luau")}, "NativeReview": {"$path": str(art / "NativeReview.luau")},
            "Effects": {"$path": str(ROOT / "tools/native_civic_effect_review.luau")}}
        for i in range(1, len(chunks) + 1):
            project["tree"]["ReplicatedStorage"]["IntegrationArt"][f"Chunk{i}"] = {"$path": str(art / f"Chunk{i}.luau")}
        project["tree"]["StarterPlayer"]["StarterPlayerScripts"]["DetailedBorinPreview"] = {
            "$path": str(ROOT / "production/integration/DetailedBorinPreview.client.luau")}
    manifest = out / f"{variant}-preview.project.json"
    manifest.write_text(json.dumps(project, indent=2) + "\n")
    candidate = out / (project["name"] + ".rbxlx")
    subprocess.run([str(ROOT / ".tools/rojo/rojo.exe"), "build", str(manifest), "--output", str(candidate)], check=True, cwd=ROOT)
    assert before == hashlib.sha256(runtime.read_bytes()).hexdigest()
    receipt = {"status": "BUILT_NOT_STUDIO_TESTED", "persistence": "Memory", "stagingRuntimeUnchanged": True,
               "candidate": str(candidate), "sha256": hashlib.sha256(candidate.read_bytes()).hexdigest(),
               "sources": {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in sorted((ROOT / "src").rglob("*.luau"))}}
    receipt["variant"] = variant
    receipt["sharedCombatCandidate"] = shared_combat
    receipt["continuousWorldCandidate"] = continuous_world
    receipt["fullCampaignCandidate"] = full_campaign
    receipt["runtimeSha256"] = hashlib.sha256(runtime_path.read_bytes()).hexdigest()
    (out / f"{variant}-preview-build.json").write_text(json.dumps(receipt, indent=2) + "\n")
    # Read-only localhost transfer data for the already-open local preview. The
    # Studio operator must verify PlaceId/GameId zero before applying this data.
    entries = []
    for area, prefix in [("client", ["StarterPlayer", "StarterPlayerScripts", "Client"]),
                         ("server", ["ServerScriptService", "Server"]),
                         ("shared", ["ReplicatedStorage", "Shared"])]:
        for path in sorted((ROOT / "src" / area).rglob("*.luau")):
            rel = path.relative_to(ROOT / "src" / area)
            kind = "Script" if path.stem.endswith(".server") else "LocalScript" if path.stem.endswith(".client") else "ModuleScript"
            name = path.stem.removesuffix(".server").removesuffix(".client")
            content = offline if area == "server" and rel.as_posix() == "Config/Runtime.luau" else path.read_text(encoding="utf-8-sig")
            entries.append({"path": prefix + list(rel.parts[:-1]) + [name], "className": kind, "source": content})
    if data.is_file():
        for i in range(1, len(chunks) + 1):
            entries.append({"path": ["ReplicatedStorage", "IntegrationArt", f"Chunk{i}"], "className": "ModuleScript",
                            "source": (art / f"Chunk{i}.luau").read_text(encoding="utf-8")})
        for name, path in [("Data", art / "Data.luau"), ("NativeReview", art / "NativeReview.luau"),
                           ("Effects", ROOT / "tools/native_civic_effect_review.luau")]:
            entries.append({"path": ["ReplicatedStorage", "IntegrationArt", name], "className": "ModuleScript", "source": path.read_text(encoding="utf-8")})
        entries.append({"path": ["StarterPlayer", "StarterPlayerScripts", "DetailedBorinPreview"], "className": "LocalScript",
                        "source": (ROOT / "production/integration/DetailedBorinPreview.client.luau").read_text(encoding="utf-8")})
    sync = out / f"{variant}-sync"
    sync.mkdir(exist_ok=True)
    (sync / "sources.json").write_text(json.dumps({"candidateSha256": receipt["sha256"],
                                                  "artSourceSha256": hashlib.sha256(data.read_bytes()).hexdigest() if data.is_file() else None,
                                                  "entries": entries}), encoding="utf-8")
    print(json.dumps({k: v for k, v in receipt.items() if k != "sources"}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--launch", action="store_true")
    parser.add_argument("--shared-combat", action="store_true", help="Opt-in local Memory combat/reward lab; no public route or cloud persistence")
    parser.add_argument("--continuous-world", action="store_true", help="Opt-in local Memory City-Greenwood walking candidate")
    parser.add_argument("--full-campaign", action="store_true", help="Separate existing Chapter00-06 Memory runtime; incompatible with launch fixtures")
    args = parser.parse_args()
    build(args.launch, args.shared_combat, args.continuous_world, args.full_campaign)
