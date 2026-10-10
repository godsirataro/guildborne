# Guildborne Studio v3

Studio v3 adds a three-tier team around the existing Forge and Roblox/Luau game: 3 directors, 8 leads and 22 specialists. `studio/studio.json` is the single source for 33 roles, all 33 existing task routes, 10 workflows, 12 gates and 7 path rules. The 25 existing skills remain in use, with Studio, Adopt, Architecture, Sprint and Luau bringing the installed set to 30. It adds no gameplay, imported art or commerce processing.

The organization draws concepts from [Claude Code Game Studios v1.1.3](https://github.com/Donchitos/Claude-Code-Game-Studios/tree/v1.1.3), commit `be8993bbc5a1f016bc770b2846ce06272d284526` (MIT). This is concepts-only adaptation for Guildborne/Codex; no upstream source or skill pack is copied or installed. Tool integration uses existing Roblox Studio, Blender, Rojo and Luau workflows.

## Use the team

Start with `$guildborne-studio` for team routing or `$guildborne-director` for production. Read actual source and latest UAT as required by `AGENTS.md`, then run fresh baseline/reconciliation. Creative director owns direction, technical director owns integration boundaries, producer sequences work, and leads coordinate bounded specialist scopes.

```sh
python tools/agentic/forge.py doctor
python tools/agentic/forge.py validate
python tools/agentic/forge.py plan
python tools/agentic/reconcile.py
python tools/agentic/character_contract.py
python tools/agentic/studio.py validate
python tools/agentic/studio.py generate
python tools/agentic/studio.py verify
python tools/agentic/forge.py status --ledger C:/Work/MySelf/Guildborne/build/agentic/ledger.sqlite3
python tools/agentic/studio.py status --ledger C:/Work/MySelf/Guildborne/build/agentic/ledger.sqlite3
```

Use the coordinator's chosen shared ledger in every command; the path below is an example for the original production plan. Route reports readiness without claiming. Claim only when the task is ready, then replace `ACTUAL_OWNER` with that owner and `ACTUAL_RETURNED_TOKEN` with the token returned by Forge. Keep the token local.

```sh
python tools/agentic/studio.py route --task audit --ledger C:/Work/MySelf/Guildborne/build/agentic/ledger.sqlite3
python tools/agentic/forge.py claim --task audit --owner ACTUAL_OWNER --ledger C:/Work/MySelf/Guildborne/build/agentic/ledger.sqlite3
python tools/agentic/studio.py handoff --task audit --owner ACTUAL_OWNER --token ACTUAL_RETURNED_TOKEN --ledger C:/Work/MySelf/Guildborne/build/agentic/ledger.sqlite3
python tools/agentic/studio.py workflow --workflow character-golden-path
```

Studio commands emit reviewable assignments/dependencies; they do not launch models, claim tasks, mutate Studio/Blender or complete gates. Generated `.codex/agents/*.toml` definitions use `name`, `description` and `developer_instructions` with inherited host model/permissions, following [official Codex custom agents](https://learn.chatgpt.com/docs/agent-configuration/subagents). No hooks or arbitrary configuration overrides are installed. Verify generated files after canonical changes. [Claude's agent schema](https://code.claude.com/docs/en/sub-agents) is research context; its definitions are not Codex configuration.

With authorized real host subagents, coordinator delegates scoped ready work; otherwise execute roles sequentially. Generated files, a planned handoff and fixture subprocesses do not prove worker execution. `run_worker.py` remains the separately opted-in quota-consuming local-code adapter in `EXECUTION_V2.md`.

## Coordinate execution

`production/plan.json` remains canonical for package dependencies, checks, environments and scopes. Studio routes without rewriting it. Workflow steps describe integration order, not duplicate Forge jobs; they never bypass accepted Forge dependencies.

Use one shared absolute ledger across worktrees. Reconcile write paths with modules, claim before writing and check leases immediately before every write/integration. Studio/Blender mutation each requires exclusive ownership and explicit session handoff. Stop old workers before releasing stale leases. Ledger ownership is cooperative coordination, not a filesystem sandbox or authenticated identity.

Handoff task/role, source HEAD and source metadata hashes, reconciled scopes, dependencies, actual checks, evidence hashes/paths, incomplete gates and next owner. A planning handoff may describe uncommitted source; it does not certify a clean tested tree. Actual check receipts and record/compose evidence require a clean committed candidate, and a different reviewer validates source/evidence. Preserve raw receipts, including empty streams.

## Acceptance remains explicit

Local contracts, generated files, actual Blender/image/audio inspection, Roblox import, Studio playtest, real local multiplayer, physical devices, distinct live servers and human approval are separate observations. Gates describe evidence; the planner does not certify them. Human-release uses the local schema category only to report an external owner decision; a local command cannot pass it.

Keep current flags, legacy saves/progression/ancestry, server authority and market fencing/conservation. Guildborne is an original party RPG with native EN/TH UI and up to five heroes. Modular appearance stays cosmetic; Wizard is Human. Runtime asset IDs stay null until real import.

GitHub PR work is authorized; merge, Roblox publication (private/public), paid upload/generation, API/Robux spending, production DataStore changes and live commerce require separately scoped approval. New commerce processing remains deferred. Missing tools block only dependent work. See `MERGE_READINESS.md` for merge checks versus outstanding platform/game/human acceptance.
