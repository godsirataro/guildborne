"""Sample added-prop occlusion offline; no Studio or gameplay acceptance claim.

Run with Python + NumPy. Writes only ground-visibility.json beside this script.
Double-sided finite ray/triangle tests use a fixed review camera and five-stud
grids across conservative encounter envelopes. Baseline art and ground overlays
are deliberately excluded: this measures incremental occlusion by new props.
"""
from pathlib import Path
import hashlib
import json
import math
import sys
import numpy as np

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAMERA = [105.0, 94.0, 1545.0]
ANCHORS = {
    "Arrival": [0, 4, 1505], "Fallback": [0, 4, 1495],
    "ReturnGate": [0, 7, 1517], "Wood": [-35, 4, 1455],
    "Herbs": [35, 4, 1455], "Scout": [-60, 4, 1410],
    "Archer": [60, 4, 1410], "Boar": [0, 4, 1410],
    "Captain": [0, 8, 1330],
}
ENVELOPES = [("boar", 0, 1410, 53), ("captain", 0, 1330, 42),
             ("scout", -60, 1410, 32), ("archer", 60, 1410, 32)]


def ground_height(x, z):
    # AdventureMapKit Greenwood origin (0,0,1400): BossRise and RootAscent.
    if -48 <= x <= 48 and 1305 <= z <= 1355:
        return 6.0
    if -10 <= x <= 10 and 1355 < z < 1380:
        return 2.0 + (1380 - z) * .16
    return 2.0


def main():
    source = ROOT / "assets/production/world-slice/world-slice.mesh.json"
    raw = source.read_bytes()
    metadata_raw = (HERE / "ground-authoring.json").read_bytes()
    data, metadata = json.loads(raw), json.loads(metadata_raw)
    meshes = {m["id"]: m for m in data["meshes"]}
    props = [p for p in data["placements"]
             if p["name"] not in metadata["baselinePlacements"]
             and p["meshId"] not in metadata["originalMeshes"]]
    assert props, "No added props found; cannot silently pass an empty audit"
    triangles, names = [], []
    for placement in props:
        mesh = meshes[placement["meshId"]]
        frame = placement["cframe"]
        vertices = np.asarray(mesh["vertices"], dtype=float)
        vertices *= np.asarray(placement.get("scale", [1, 1, 1]))
        vertices = vertices @ np.asarray(frame[3:]).reshape(3, 3).T + frame[:3]
        triangles.extend(vertices[np.asarray(mesh["triangles"]) - 1])
        names.extend([placement["name"]] * len(mesh["triangles"]))
    triangles = np.asarray(triangles)
    a = triangles[:, 0]
    e1, e2 = triangles[:, 1] - a, triangles[:, 2] - a
    origin = np.asarray(CAMERA)
    s = origin - a
    q = np.cross(s, e1)

    def trace(target):
        direction = np.asarray(target) - origin
        h = np.cross(direction, e2)
        determinant = np.einsum("ij,ij->i", e1, h)
        valid = np.abs(determinant) > 1e-9
        inverse = np.zeros_like(determinant)
        inverse[valid] = 1 / determinant[valid]
        u = inverse * np.einsum("ij,ij->i", s, h)
        v = inverse * (q @ direction)
        distance = inverse * np.einsum("ij,ij->i", e2, q)
        hits = np.flatnonzero(valid & (u >= -1e-8) & (v >= -1e-8)
                             & (u + v <= 1 + 1e-8) & (distance > 1e-7)
                             & (distance < 1 - 1e-7))
        if not len(hits):
            return None
        nearest = hits[np.argmin(distance[hits])]
        return {"prop": names[nearest], "segmentFraction": float(distance[nearest])}

    anchors = [{"name": name, "target": target, "hit": trace(target)}
               for name, target in ANCHORS.items()]
    grids = []
    for name, cx, cz, radius in ENVELOPES:
        samples, blocked = 0, []
        for x in range(math.ceil(cx-radius), math.floor(cx+radius)+1, 5):
            for z in range(math.ceil(cz-radius), math.floor(cz+radius)+1, 5):
                if (x-cx)**2 + (z-cz)**2 > radius**2:
                    continue
                target = [x, ground_height(x, z) + .09, z]
                samples += 1
                hit = trace(target)
                if hit:
                    blocked.append({"target": target, **hit})
        grids.append({"name": name, "centerXZ": [cx, cz], "radius": radius,
                      "samples": samples, "occluded": len(blocked), "hits": blocked})
    failed = any(row["hit"] for row in anchors) or any(row["occluded"] for row in grids)
    assert source.read_bytes() == raw, "Mesh changed while visibility audit was running"
    report = {
        "status": "OFFLINE_SAMPLED_VISIBILITY_FAIL" if failed else "OFFLINE_SAMPLED_VISIBILITY_PASS",
        "sourceMeshSha256": hashlib.sha256(raw).hexdigest(),
        "authoringMetadataSha256": hashlib.sha256(metadata_raw).hexdigest(),
        "checkerSha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "camera": CAMERA, "gridSpacingStuds": 5, "telegraphSampleHeight": .09,
        "addedProps": len(props), "testedTriangles": len(triangles),
        "anchors": anchors, "grids": grids, "studioTested": False,
        "method": "Double-sided Moller-Trumbore finite segment intersection; nearest added-prop hit",
        "limits": ["One fixed camera; no other viewpoints or animated poses tested",
                   "Finite sampling cannot prove visibility between grid points",
                   "Excludes baseline geometry, overlays, shadows, transparency and UI",
                   "Sample heights approximate native Island/BossRise/RootAscent, not runtime raycasts",
                   "Envelope grids are conservative authoring samples, not executed attack footprints"],
        "sourceContracts": ["src/server/Services/AdventureMapKit.luau",
                            "src/server/Services/RegionalWorld.luau",
                            "src/shared/Config/City.luau", "src/shared/Data/Expansion.luau",
                            "src/server/Config/AdventureEnemyProfiles.luau",
                            "src/server/Systems/AdventurePatterns.luau",
                            "src/shared/Data/AdventureTelegraph.luau"],
    }
    (HERE / "ground-visibility.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "sourceMeshSha256": report["sourceMeshSha256"],
                      "addedProps": len(props), "anchorOcclusions": sum(bool(a["hit"]) for a in anchors),
                      "grids": [{k: g[k] for k in ("name", "samples", "occluded")} for g in grids]}, indent=2))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
