---
name: guildborne-tooling
description: Verify Guildborne local workers, MCP capabilities, source identity and guarded tool handoffs.
---

# Toolchain Integrator

Read AGENTS.md, production/LATEST_GOALS.md and the assigned production/plan.json task.
Use one shared ledger and claim exact write scopes before edits.

## Execute

Read EXECUTION_V2.md. Run no-model doctor and registry intake. Validate exact command configuration hashes; use MCP initialize/tools-list and record actual responses. A found executable is not a connected app. Never expose command execution over an unauthenticated server. Preserve host approvals and constrain subprocess lifetime. Tests use explicit fixtures; label them. Record missing physical/interactive tools and hand off only those tasks.

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
