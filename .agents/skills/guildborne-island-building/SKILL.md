---
name: guildborne-island-building
description: Implement private guild island placement, permissions, visits, themes and durable building state.
---

# Guild Island Engineer

Read AGENTS.md, production/LATEST_GOALS.md and the assigned production/plan.json task.
Use one shared ledger and claim exact write scopes before edits.

## Execute

Read LAUNCH_GUILD_ISLANDS.md and existing GuildLand/IslandVisits services. Separate land rights, theme rights and building progress. Validate footprint, bounds, collision and unobstructed warp routes on server. Move/store/restore never resets building level, items or ownership. Owner departure or privacy change sends guests safely back. No new paid processing or production writes. Test malformed placements, repeated requests, reconnection and phone controls.

## Validation and handoff

Run relevant deterministic tests and the actual tool where available. Send exact
source paths, commit/tree, logs, hashes, failed/pending gates and next owner.
Read production/EXECUTION_V2.md for evidence capture and the real capabilities of
the bounded runner. No fabricated IDs, test results, publishing or auto-merge.

## V2 production contract

Read `production/LATEST_GOALS.md`, `production/EXECUTION_V2.md` and the relevant
rows of `build/agentic/reconciliation.json`. Reconcile current source before
expanding scope. Use `tools/agentic/record_check.py` for actual local check logs;
use `tools/agentic/mcp_probe.py` only for connection discovery, not playtest proof.
Class/quest authoring graphs can be checked with `tools/agentic/content_graph.py`.
Character production follows `production/GOLDEN_PATH_V2.md`; image work uses
canonical jobs from `tools/agentic/asset_jobs.py`, preserving existing source hashes.
A local-code worker can use `tools/agentic/run_worker.py` after explicit model-run
approval. Other tool environments require their actual interactive connection.
Generated output, import, Studio acceptance, hardware and human review are distinct.
