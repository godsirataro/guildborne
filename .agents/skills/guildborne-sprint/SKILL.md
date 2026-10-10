---
name: guildborne-sprint
description: Sequence dependency-ready Guildborne work and coordinate shared leases, checkpoints and independent review for a scoped production sprint.
---

# Guildborne sprint coordination

Read `production/plan.json`, `LATEST_GOALS.md`, `MERGE_READINESS.md` and `EXECUTION_V2.md`. Use Forge `plan`/`status` and Studio `status`/`workflow` to identify ready packages, gates and owners. Workflow ordering does not bypass Forge dependency acceptance.

Use one shared absolute ledger across workers/worktrees. Reconcile scopes with real modules, claim before writing and check leases immediately before writes/integration. Parallelize independent scopes through actual authorized host delegation; otherwise work sequentially. Studio/Blender each have exclusive ownership. Confirm stale workers stopped before explicit release; never steal expired interactive leases.

Choose a complete player route or bounded integration target with artifacts and measurable checks. Preserve failure logs and checkpoint identity without erasing unfinished goals. `run_worker.py` remains a separately approved quota-consuming local-code adapter, not a Studio planning side effect.

Handoff reviewable changes, observed checks, evidence references, blockers and next owner. Record checks on clean committed source and compose REVIEW evidence; a different reviewer validates it. Distinguish generation, Blender, import, Studio, devices/live servers and external human approval. End at a private candidate; no automatic merge/release.
