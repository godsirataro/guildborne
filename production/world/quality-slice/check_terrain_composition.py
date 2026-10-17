"""Independent offline terrain support/clearance audit; writes terrain-clearance.json.

Uses git baseline 768ae4e, not author-provided baseline hashes. No Blender/Studio.
Horizontal triangles are clipped against exclusion rectangles, so triangles
crossing a road with all vertices outside it are still rejected. Vertical skins
are checked against native face planes and attachment gaps separately.
"""
from pathlib import Path
import hashlib
import json
import math
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASELINE = "768ae4e"
EPS = 0.00003
ROADS = {
    "center": [-12, 12, 1317, 1512], "landing": [-18, 18, 1496, 1530],
    "westLoop": [-72, -48, 1362, 1458], "eastLoop": [48, 72, 1362, 1458],
    "southCross": [-72, 72, 1438, 1462], "northCross": [-72, 72, 1363, 1387],
    "wood": [-41, -29, 1449, 1461], "herbs": [29, 41, 1449, 1461],
}
BOSS = [-48, 48, 1305, 1355]
RAMP = [-10, 10, 1355, 1380]


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def intersection_area(points, rect):
    """Sutherland-Hodgman clipping in XZ; boundary contact has zero area."""
    polygon = [(p[0], p[2]) for p in points]
    for axis, bound, sign in ((0, rect[0], 1), (0, rect[1], -1),
                              (1, rect[2], 1), (1, rect[3], -1)):
        if not polygon:
            return 0.0
        output = []
        previous = polygon[-1]
        was_inside = sign * (previous[axis] - bound) >= 0
        for current in polygon:
            inside = sign * (current[axis] - bound) >= 0
            if inside != was_inside:
                t = (bound - previous[axis]) / (current[axis] - previous[axis])
                output.append(tuple(previous[i] + t * (current[i]-previous[i]) for i in range(2)))
            if inside:
                output.append(current)
            previous, was_inside = current, inside
        polygon = output
    return abs(sum(a[0]*b[1]-b[0]*a[1] for a, b in zip(polygon, polygon[1:]+polygon[:1]))) / 2


def cross(a, b, c):
    u, v = [b[i]-a[i] for i in range(3)], [c[i]-a[i] for i in range(3)]
    return [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]


def self_test():
    # A triangle covers the rectangle even though none of its vertices is inside.
    assert abs(intersection_area([[-10, 0, -10], [10, 0, -10], [0, 0, 10]], [-1, 1, -1, 1])-4) < 1e-9
    assert intersection_area([[0, 0, 0], [1, 0, 0], [0, 0, 1]], [1, 2, 0, 1]) == 0
    assert abs(intersection_area([[0, 0, 0], [0, 0, 1], [1, 0, 0]], [-2, 2, -2, 2])-.5) < 1e-9


def main():
    self_test()
    source = ROOT / "assets/production/world-slice/world-slice.mesh.json"
    collision_path = source.with_name("collision.json")
    raw, collision_raw = source.read_bytes(), collision_path.read_bytes()
    data, collision = json.loads(raw), json.loads(collision_raw)
    baseline_sha = subprocess.check_output(["git", "rev-parse", BASELINE], cwd=ROOT, text=True).strip()
    def baseline_file(path):
        return json.loads(subprocess.check_output(["git", "show", baseline_sha+":"+path], cwd=ROOT))
    old = baseline_file("assets/production/world-slice/world-slice.mesh.json")
    old_collision = baseline_file("assets/production/world-slice/collision.json")
    errors = []
    def check(condition, message):
        if not condition:
            errors.append(message)
        return condition
    meshes = {m["id"]: m for m in data["meshes"]}
    placements = {p["name"]: p for p in data["placements"]}
    check(len(meshes)==len(data["meshes"]), "Duplicate mesh IDs")
    check(len(placements)==len(data["placements"]), "Duplicate placement names")
    removed_ids = {m["id"] for m in old["meshes"] if m["id"].startswith(("ground_court__", "ground_leaf__"))}
    removed_names = {p["name"] for p in old["placements"] if p["meshId"] in removed_ids}
    check(len(removed_ids)==2 and len(removed_names)==10, "Unexpected baseline replacement set")
    for m in old["meshes"]:
        if m["id"] in removed_ids:
            check(m["id"] not in meshes, "Old patch mesh retained: "+m["id"])
        elif m["id"] not in {"arch__000","arch__001"}:
            check(meshes.get(m["id"])==m, "Baseline mesh changed: "+m["id"])
    for p in old["placements"]:
        if p["name"] in removed_names:
            check(p["name"] not in placements, "Old patch placement retained: "+p["name"])
        else:
            check(placements.get(p["name"])==p, "Baseline placement changed: "+p["name"])
    check(len(collision["colliders"])==413 and collision["colliders"]==old_collision["colliders"], "Baseline 413 colliders changed")
    check(collision["sourceMeshSha256"]==hashlib.sha256(raw).hexdigest(), "Collision source hash stale")
    old_ids = {m["id"] for m in old["meshes"]}
    old_names = {p["name"] for p in old["placements"]}
    # Silhouette additions are audited by check_silhouette.py; revised arrival
    # surfaces and the sign by check_arrival.py, with apron/landing support.
    new_meshes = [m for m in data["meshes"] if m["id"] not in old_ids and not m["id"].startswith(("silhouette_", "arrival_", "terrain_arrival_", "terrain_forest_"))]
    new_placements = [p for p in data["placements"] if p["name"] not in old_names and not p["meshId"].startswith(("silhouette_", "arrival_", "terrain_arrival_", "terrain_forest_"))]
    check(1<=len(new_meshes)<=6, "New terrain mesh count outside 1..6")
    check(1<=len(new_placements)<=12, "New placement count outside 1..12")
    check(all(m["id"].startswith("terrain_") for m in new_meshes), "Non-terrain mesh added")
    new_ids = {m["id"] for m in new_meshes}
    check(all(p["meshId"] in new_ids for p in new_placements), "Added placement references non-terrain mesh")
    stats = {"islandSurfaceTriangles": 0, "bossSurfaceTriangles": 0,
             "bossWallTriangles": 0, "islandSkirtTriangles": 0}
    rows, total = [], 0
    def within(tri, rect):
        return all(rect[0]-EPS<=v[0]<=rect[1]+EPS and rect[2]-EPS<=v[2]<=rect[3]+EPS for v in tri)
    for p in new_placements:
        if p["meshId"] not in meshes:
            check(False, "Missing terrain mesh: "+p["name"])
            continue
        m = meshes[p["meshId"]]
        f, scale = p["cframe"], p.get("scale", [1, 1, 1])
        if not check(len(f)==12 and all(math.isfinite(x) for x in f) and scale==[1, 1, 1], "Invalid terrain transform: "+p["name"]):
            continue
        vs = [[f[i]+sum(f[3+i*3+j]*v[j] for j in range(3)) for i in range(3)] for v in m["vertices"]]
        check(all(math.isfinite(x) for v in vs for x in v), "Nonfinite terrain vertex")
        before = len(errors)
        for index, face in enumerate(m["triangles"]):
            total += 1
            label = p["name"]+":"+str(index+1)
            if not check(len(face)==3 and len(set(face))==3 and all(type(i)==int and 1<=i<=len(vs) for i in face), "Invalid triangle "+label):
                continue
            tri = [vs[i-1] for i in face]
            n = cross(*tri)
            if not check(sum(x*x for x in n)>1e-14, "Degenerate triangle "+label):
                continue
            flat_low = all(abs(v[1]-2.02)<=EPS for v in tri)
            flat_high = all(abs(v[1]-6.02)<=EPS for v in tri)
            if flat_low or flat_high:
                check(n[1]>0, "Surface winding downward "+label)
                check(within(tri, BOSS if flat_high else [-110, 110, 1300, 1500]), "Surface lacks native support "+label)
                if flat_low:
                    check(intersection_area(tri, BOSS)<1e-7 and intersection_area(tri, RAMP)<1e-7, "Island surface under rise/ramp "+label)
                for name, rect in ROADS.items():
                    check(intersection_area(tri, rect)<1e-7, "Surface intersects "+name+" "+label)
                stats["bossSurfaceTriangles" if flat_high else "islandSurfaceTriangles"] += 1
                continue
            # Each entry: constant axis, plane, transverse limits, Y limits, outward sign, kind.
            planes = [(0,-48.02,1305,1355,2.02,5.98,-1,"boss"),
                      (0,48.02,1305,1355,2.02,5.98,1,"boss"),
                      (2,1304.98,-48,48,2.02,5.98,-1,"boss"),
                      (2,1355.02,-48,48,2.02,5.98,1,"boss"),
                      (0,-110.02,1300,1500,-1.98,1.98,-1,"island"),
                      (0,110.02,1300,1500,-1.98,1.98,1,"island"),
                      (2,1299.98,-110,110,-1.98,1.98,-1,"island"),
                      (2,1500.02,-110,110,-1.98,1.98,1,"island")]
            matched = False
            for axis, plane, low, high, ymin, ymax, sign, kind in planes:
                other = 2 if axis==0 else 0
                if not all(abs(v[axis]-plane)<=EPS for v in tri):
                    continue
                matched = True
                check(all(low-EPS<=v[other]<=high+EPS and ymin-EPS<=v[1]<=ymax+EPS for v in tri), "Vertical skin outside native face "+label)
                check(n[axis]*sign>0, "Vertical skin inward winding "+label)
                if axis==2:
                    xmin, xmax = min(v[0] for v in tri), max(v[0] for v in tri)
                    gaps = [(-12,12)] if kind=="boss" and plane>1355 else [(-62,-18),(-14,14)] if kind=="island" and plane>1500 else []
                    for left,right in gaps:
                        check(min(xmax,right)-max(xmin,left)<=EPS, "Skin crosses attachment/ramp gap "+label)
                stats["bossWallTriangles" if kind=="boss" else "islandSkirtTriangles"] += 1
                break
            check(matched, "Unsupported height/plane "+label)
        rows.append({"name": p["name"], "meshId": p["meshId"], "triangles": len(m["triangles"]),
                     "worldMin": [min(v[i] for v in vs) for i in range(3)],
                     "worldMax": [max(v[i] for v in vs) for i in range(3)], "errors": len(errors)-before})
    check(total<=12000, "Instantiated terrain triangle budget exceeded")
    check(source.read_bytes()==raw and collision_path.read_bytes()==collision_raw, "Artifacts changed during audit")
    report = {"status": "OFFLINE_TERRAIN_CLEARANCE_FAIL" if errors else "OFFLINE_TERRAIN_CLEARANCE_PASS",
              "sourceMeshSha256": hashlib.sha256(raw).hexdigest(), "baselineCommit": baseline_sha,
              "checkerSha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              "baselineMeshesPreserved": len(old["meshes"])-len(removed_ids)-2,
              "baselinePlacementsPreserved": len(old["placements"])-len(removed_names),
              "removedPatchMeshes": sorted(removed_ids), "removedPatchPlacements": sorted(removed_names),
              "baselineCollidersSha256": digest(old_collision["colliders"]),
              "newMeshes": len(new_meshes), "newPlacements": len(new_placements),
              "instantiatedTerrainTriangles": total, "triangleClasses": stats,
              "surfaceExclusions": ROADS, "placements": rows, "errorCount": len(errors), "errors": errors[:100],
              "limits": ["Offline triangle geometry only; no Studio physics, rendering or human art acceptance",
                         "Road exclusions apply to horizontal surfaces; vertical skins lie below native walking surfaces",
                         "No camera visibility, color contrast or dynamic telegraph rasterization proof",
                         "Support follows static AdventureMapKit native planes; runtime terrain mutations are not tested"],
              "studioTested": False}
    (HERE/"terrain-clearance.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({k: report[k] for k in ("status","sourceMeshSha256","newMeshes","newPlacements","instantiatedTerrainTriangles","triangleClasses","errorCount","errors")}, indent=2))
    return 1 if errors else 0


if __name__=="__main__":
    if "--self-test" in sys.argv:
        self_test()
        print("Triangle clipping self-tests passed; no report written")
    else:
        sys.exit(main())
