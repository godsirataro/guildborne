---
name: guildborne-studio
description: Coordinate Guildborne Studio v3 role routing, workflows and handoffs for multi-system game production.
---

# Guildborne Studio v3

Read `AGENTS.md`, `production/STUDIO_V3.md`, `production/LATEST_GOALS.md` and the relevant playbook section. `production/studio/studio.json` is canonical for roles, workflows, routing and path instructions; `production/plan.json` remains canonical for Forge tasks, dependencies and scopes.

Use `python tools/agentic/studio.py validate`, `generate` and `verify` to inspect/regenerate Codex agents. Use `status`, `route`, `handoff` and `workflow` for reviewable plans; inspect each subcommand's `--help` for arguments. These commands do not invoke models, claim work, mutate Studio or grant acceptance.

For optional platform guidance, run `python tools/agentic/ecosystem.py route --task TASK_ID`; it resolves the primary repository skill plus a bounded set of installed host Roblox skills. Read the bootstrap skill first when available, then the project skill and only relevant supporting guidance. Missing host skills do not block the project workflow. The route is advisory: it cannot claim work, dispatch agents or validate platform advice. Preserve current profile keys/migrations, native UI, server authority and market fencing; generic library examples do not authorize replacements. See `production/AI_ECOSYSTEM_TH.md` for code/asset workflows and `ecosystem.py doctor` for filesystem inventory (not a live MCP probe).

Directors reconcile boundaries and intent, producer sequences work, and leads coordinate specialists. Delegate through real host subagent capabilities when available and authorized; otherwise execute bounded roles sequentially. Generated `.codex/agents/*.toml` files support host discovery, but file existence is not a launched worker. Inherit host model and permissions.

Claim through Forge in one shared ledger before writes. Reconcile suggested scopes with actual modules, check the lease immediately before writes/integration and serialize Studio/Blender mutation. Handoff source identity, paths, actual checks/evidence, remaining gates and next owner. Different reviewer inspects evidence; no implied quota run, merge, publication or commerce.
