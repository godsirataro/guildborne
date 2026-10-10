---
name: guildborne-market
description: Review or extend Guildborne market, escrow, durable claims, epochs, cloud recovery and conservation.
---

# Guildborne Market

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read Phase4/4.5 code and invariants, not only summaries. Retain one atomic authority per item unless a separately reviewed migration proves an alternative. DataStore owns truth; MemoryStore is disposable; Messaging is invalidation only. Session-owned profiles apply durable claims; never bypass another server's lock. Preserve generation fencing, receipt floors, claim watermarks, cumulative fees and bounded admissions. Test uncertain writes, fill/cancel races, stale epochs, offline recipients, replay after compaction and cache/message loss. A skipped claim sequence must never advance a watermark past an unapplied claim. Reconcile Gold/items/fees and protect save budgets. Different clients on one Studio server do not establish cross-server proof. Do not run a cloud load test without isolated namespace and bounded budget approval. No THB/USD/Robux exchange, cash-out or public-market activation. Fail safe and preserve evidence rather than manufacturing compensation from guesses.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
