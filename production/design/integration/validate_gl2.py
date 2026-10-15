"""Read-only GL-2.0 delivery checks. PASS is metadata consistency, never release approval."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REQUIRED_GROUPS = {
    "progression", "campaign", "classes", "heroes", "personal-guild", "islands",
    "shared-multiplayer", "federation", "war", "territory", "economy-market",
    "endgame", "appearance", "cities-world", "ux-accessibility", "rewards-commerce", "operations-web",
}
CRITICAL_BACKLOG = {
    "chapters70-100": "P4", "federation": "P6", "guild-war": "P6",
    "territory": "P7", "player-market": "P7",
}


def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def validate(matrix, features, backlog, plan, studio, root=ROOT):
    errors = []

    def require(condition, message):
        if not condition:
            errors.append(message)

    def index(rows, label):
        result = {}
        for row in rows:
            key = row.get("id")
            require(isinstance(key, str) and bool(key), f"{label}: missing ID")
            require(key not in result, f"{label}: duplicate ID {key}")
            result[key] = row
        return result

    def graph(rows, label, dependency_field="dependsOn"):
        visiting, visited = set(), set()

        def visit(key):
            if key in visiting:
                errors.append(f"{label}: cycle at {key}")
                return
            if key in visited:
                return
            visiting.add(key)
            for dependency in rows[key].get(dependency_field, []):
                if dependency not in rows:
                    errors.append(f"{label}: {key} has unknown dependency {dependency}")
                else:
                    visit(dependency)
            visiting.remove(key)
            visited.add(key)

        for key in rows:
            visit(key)

    for name, document in (("matrix", matrix), ("features", features), ("backlog", backlog)):
        require(document.get("deliveryPlan") == "GL-2.0", f"{name}: wrong delivery plan")
        require(document.get("publicReady") is False, f"{name}: this P0 packet cannot approve Public")
    require(matrix.get("publicMaxLevel") == backlog.get("publicMaxLevel") == 100, "Public must require Lv100")
    require(matrix.get("internalAlphaMaxLevel") == backlog.get("internalAlphaMaxLevel") == 35, "Lv35 must remain internal Alpha")
    require(set(matrix.get("requiredPublicSystems", [])) == {"Class3", "Federation", "war", "territory", "player-market"}, "Missing full-game Public systems")
    require(matrix.get("releaseAuthorization") == "PENDING_SCOPED_OWNER_DECISION", "Metadata cannot authorize release")
    phases = index(matrix.get("phases", []), "phases")
    require(set(phases) == {f"P{i}" for i in range(14)}, "Phase inventory must be P0–P13")
    graph(phases, "phases")
    for phase, dependencies in {
        "P1": {"P0"}, "P2": {"P0"}, "P3": {"P0"}, "P4": {"P2"},
        "P5": {"P2", "P3", "P4"}, "P6": {"P3"}, "P7": {"P6"}, "P8": {"P1"},
        "P9": {f"P{i}" for i in range(2, 9)}, "P10": {"P9"}, "P11": {"P10"}, "P12": {"P11"}, "P13": {"P12"},
    }.items():
        require(dependencies <= set(phases.get(phase, {}).get("dependsOn", [])), f"{phase}: missing required integration predecessor")
    groups = index(matrix.get("groups", []), "groups")
    require(set(groups) == REQUIRED_GROUPS, "Full-game group inventory incomplete or changed without validator review")
    graph(groups, "groups", "foundationDependencies")
    require(bool(matrix.get("dependencyMeaning")), "Source foundations must be distinguished from phase acceptance dependencies")
    feature_rows = index(features.get("features", []), "features")
    require(set(feature_rows) == {f"{i:02}" for i in range(1, 21)}, "Expected all20 canonical feature IDs")
    graph(feature_rows, "features")
    tasks = {row["id"] for row in plan["tasks"]}
    roles = {row["id"] for row in studio["roles"]}
    covered = set()
    for key, group in groups.items():
        require(group.get("requiredBeforePublic") is True, f"{key}: required group deferred")
        require(group.get("phase") in {f"P{i}" for i in range(1, 12)}, f"{key}: delivery must precede Public")
        require(group.get("startsAt") in phases, f"{key}: invalid start phase")
        require("dependsOn" not in group, f"{key}: use foundationDependencies, not ambiguous scheduling edges")
        start, finish = group.get("startsAt"), group.get("phase")
        if start in phases and finish in phases:
            require(int(start[1:]) <= int(finish[1:]), f"{key}: starts after its completion phase")
        require(group.get("ownerRole") in roles, f"{key}: unknown owner")
        require(bool(group.get("forgeTasks")) and set(group.get("forgeTasks", [])) <= tasks, f"{key}: unknown/missing Forge task")
        require(bool(group.get("acceptance")), f"{key}: missing acceptance")
        require(bool(group.get("featureIds")) and set(group.get("featureIds", [])) <= set(feature_rows), f"{key}: unknown feature")
        covered.update(group.get("featureIds", []))
        for path in group.get("sourcePaths", []):
            resolved = (root / path).resolve()
            require(resolved.is_relative_to(root.resolve()) and resolved.is_file(), f"{key}: missing/outside source {path}")
    require(covered == set(feature_rows), "Not every feature is mapped to a delivery group")
    for key in ("appearance", "cities-world"):
        require(groups.get(key, {}).get("startsAt") == "P1" and groups.get(key, {}).get("phase") == "P8", f"{key}: art must start atP1 and complete byP8")
    for key, latest_start in {"heroes": 1, "ux-accessibility": 1, "progression": 2, "campaign": 2, "classes": 2, "personal-guild": 2, "islands": 2}.items():
        start = groups.get(key, {}).get("startsAt")
        if start in phases:
            require(int(start[1:]) <= latest_start, f"{key}: foundations start too late for early playable route")
    for key, feature in feature_rows.items():
        require(feature.get("releaseGate") == "full-game-required" and feature.get("requiredBeforePublic") is True, f"feature{key}: not required before Public")
        require(feature.get("phase") in {f"P{i}" for i in range(12)}, f"feature{key}: invalid pre-Public phase")
        require(feature.get("ownerRole") in roles, f"feature{key}: unknown owner")
    items = index(backlog.get("items", []), "backlog")
    for key, item in items.items():
        require(item.get("phase") in phases, f"backlog {key}: retired/unknown phase")
        require(item.get("ownerRole") in roles, f"backlog {key}: unknown owner")
        if item.get("requiredBeforePublic"):
            require(item.get("phase") not in {"P12", "P13"} and item.get("status") != "DEFERRED", f"backlog {key}: required work deferred")
    for key, phase in CRITICAL_BACKLOG.items():
        item = items.get(key, {})
        require(item.get("phase") == phase and item.get("requiredBeforePublic") is True, f"backlog {key}: missing required full-game delivery")
    open_decisions = [row for row in matrix.get("unresolvedDecisions", []) if row.get("status") == "OPEN_P0_BLOCKER"]
    if open_decisions:
        require(matrix.get("p0Complete") is False, "P0 cannot close with unresolved content/capacity decisions")
    for row in open_decisions:
        require(row.get("ownerRole") in roles, f"decision {row.get('id')}: unknown owner")
        require(row.get("canonicalIds") is None and row.get("countApproved") is False, f"decision {row.get('id')}: proposal falsely approved")
    return errors


def documents():
    return [read(path) for path in (
        "production/design/integration/GL2_SCOPE_MATRIX.json", "production/design/features.json",
        "production/launch/backlog.json", "production/plan.json", "production/studio/studio.json",
    )]


if __name__ == "__main__":
    documents_ = documents()
    errors = validate(*documents_)
    print(json.dumps({"status": "FAIL" if errors else "PASS", "scope": "delivery-metadata-only",
                      "p0Complete": documents_[0]["p0Complete"], "publicReady": False,
                      "openP0Decisions": len(documents_[0]["unresolvedDecisions"]), "errors": errors}, indent=2))
    raise SystemExit(bool(errors))
