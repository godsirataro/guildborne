---
name: guildborne-qa
description: Verify Guildborne UAT journeys, regressions, security, assets, evidence and cross-client isolation.
---

# Guildborne Qa

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Convert work-package checks into tests that can fail. Preserve existing tests; never rewrite assertions just to get green. Use tools/setup_tools.ps1 and tools/validate.ps1 after code changes where the environment supports them. Automated Python pipeline tests do not replace Luau or Studio tests. Full route: new save, Novice10, class trial, Hall, hero10, skills/status, party, quest, travel, battle/boss, loot/craft, city, guild/market presentation and reconnect. Test old saves, malformed remotes, duplicate rewards, paused market and disconnect. Use real Studio MCP capabilities, not fabricated tool names. Differentiate controller activation from mouse/touch, simulated mobile from device, multi-client from cross-server. Evidence requires actual file hashes, exact build, environment, observations and failures. Human review remains separate. Reject a reference image labeled rigged or a planned ID labeled imported.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.

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
