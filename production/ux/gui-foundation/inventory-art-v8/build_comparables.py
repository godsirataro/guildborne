"""Build isolated before/after Inventory places with identical fixture inputs.

Uses only local Git objects and existing Rojo. Does not open Studio or publish.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[4]
BASE = "3b62d2fddb9eb74d8101049356e089152021e3c1"
MODULES = ("InventoryActorPreview", "EquipmentSlot", "InventoryPane")
OUT = ROOT / "build/inventory-art-v8"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect(path):
    items = ET.parse(path).getroot().findall(".//Item")
    assert sum(item.get("class") == "LocalScript" for item in items) == 1
    assert not any(item.get("class") in {"Script", "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent"} for item in items)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    subprocess.run([sys.executable, "tests/gui/build_inventory_review.py"], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    review = ROOT / "build/inventory-review"
    project = json.loads((review / "review.project.json").read_text(encoding="utf-8"))
    receipt = json.loads((review / "build_receipt.json").read_text(encoding="utf-8"))
    after = OUT / "GuildborneInventoryArtAfter.rbxlx"
    after.write_bytes((review / "GuildborneInventoryReview.rbxlx").read_bytes())
    components = project["tree"]["StarterPlayer"]["StarterPlayerScripts"]["Client"]["UI"]["Components"]
    changes = {}
    for name in MODULES:
        source = "src/client/UI/Components/" + name + ".luau"
        before = OUT / ("before_" + name + ".luau")
        before.write_bytes(subprocess.check_output(["git", "show", BASE + ":" + source], cwd=ROOT))
        components[name] = {"$path": str(before)}
        changes[source] = {"before": sha(before), "after": sha(ROOT / source)}
    project_path = OUT / "before.project.json"
    project_path.write_text(json.dumps(project, indent=2), encoding="utf-8")
    before_place = OUT / "GuildborneInventoryArtBefore.rbxlx"
    subprocess.run([str(ROOT / ".tools/rojo/rojo.exe"), "build", str(project_path), "--output", str(before_place)], cwd=ROOT, check=True)
    inspect(before_place)
    inspect(after)
    result = {"status": "BUILT_NATIVE_NOT_RUN", "before_components_commit": BASE,
              "after_commit": receipt["source_commit"], "changed_components": changes,
              "fixture_source_hashes": receipt["source_files"],
              "before": {"path": str(before_place), "sha256": sha(before_place)},
              "after": {"path": str(after), "sha256": sha(after)},
              "comparison": "Identical current fixture and dependencies; only three named components differ."}
    (OUT / "comparison_receipt.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps({key: result[key] for key in ("status", "before", "after")}))


if __name__ == "__main__":
    main()
