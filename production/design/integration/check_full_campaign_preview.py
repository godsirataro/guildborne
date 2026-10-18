"""Verify a built full-campaign candidate; no Studio/gameplay acceptance."""
from pathlib import Path
import hashlib
import importlib.util
import itertools
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location("preview_builder", ROOT / "tools/build_integration_preview.py")
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
guarded = [ROOT / "src/server/Config/Runtime.luau", ROOT / "src/server/Config/ReleaseContent.luau", ROOT / "offline/ArchiveHeartRuntime.luau"]
before = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in guarded}
for flags in itertools.product((False, True), repeat=3):
    if not any(flags):
        continue
    try:
        builder.build(*flags, full_campaign=True)
    except ValueError:
        pass
    else:
        raise AssertionError(f"Accepted mixed candidate: {flags}")
assert before == {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in guarded}
packet = json.loads((ROOT / "build/full-campaign-sync/sources.json").read_text())
candidate = ROOT / "build/Guildborne_FullCampaignPreview.rbxlx"
assert hashlib.sha256(candidate.read_bytes()).hexdigest() == packet["candidateSha256"]
sources = {}
def visit(node, path=()):
    for item in node.findall("Item"):
        props = item.find("Properties")
        name = props.find("*[@name='Name']").text
        current = path + (name,)
        source = props.find("*[@name='Source']")
        if source is not None:
            assert current not in sources
            sources[current] = source.text or ""
        visit(item, current)
visit(ET.parse(candidate).getroot())
for entry in packet["entries"]:
    assert sources[tuple(entry["path"])] == entry["source"], entry["path"]
runtime = sources[("ServerScriptService", "Server", "Config", "Runtime")]
assert runtime == (ROOT / "offline/ArchiveHeartRuntime.luau").read_text()
assert 'StudioPersistence="Memory"' in runtime and 'AllowedDataStoreUniverses={}' in runtime
assert "LaunchCandidate" not in runtime
for flag in ("NoviceJourney", "IronveilJourney", "AshenJourney", "TowerJourney", "CrosshavenJourney", "ArchiveHeartJourney"):
    assert runtime.count(flag + "=true") == 1
release = sources[("ServerScriptService", "Server", "Config", "ReleaseContent")]
assert release == (ROOT / "src/server/Config/ReleaseContent.luau").read_text(encoding="utf-8-sig")
assert len(packet["entries"]) == len(sources)
print(json.dumps({"status": "PASS_BUILT_SOURCE_ONLY", "mixedModesRejected": 7, "exactSources": len(sources), "candidateSha256": packet["candidateSha256"], "studioTested": False}))
