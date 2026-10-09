---
name: guildborne-ux-native
description: Design and implement Roblox-native menus, panels, commander HUD, skill trees and mobile EN/TH flows; not HTML gameplay UI.
---

# Guildborne Ux Native

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Audit current ScreenGui hierarchy, UI modules and docs/uat01/intake before redesign. Create journeys and state matrices for title, heroes, inventory, quest journal, class choice, status allocation, skill tree, recruitment, crafting, exchange, shop, guild, maps and settings. Reuse the current view-model architecture. Implement native Frame/TextLabel/ImageLabel controls, semantic tokens, 9-slice frames, safe insets, keyboard/touch/controller navigation and focus restoration. Universal styling is optional after capability verification, not a reason to rewrite every screen. A player's own class and five companions need distinct context. Learned/equipped/AI-enabled skills are separate states. Do not add fake mana, crit, ultimate or currency data. Every panel needs loading/empty/error/disabled/pending/success; market also needs stale quote, read-only and paused. Dynamic text stays localized, never baked into images. Preview and undo skill/status allocation before authoritative apply. Test narrow portrait, landscape, desktop, Thai text, virtual keyboard and reduced motion. Human touch remains a separate gate. Deliver component contracts, actual bindings and screenshot evidence.

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
