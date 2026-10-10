# Guildborne Agentic Production Forge

## Studio v3

[Studio v3](STUDIO_V3.md) extends this Forge with a three-tier team, canonical
role/workflow definitions, native Codex/Claude adapters and lease-checked handoffs.
Use `$guildborne-studio` for team routing and `$guildborne-adopt` for existing-source
intake. The existing production plan, task ownership and evidence rules remain
authoritative; native host tools perform actual subagent delegation.

```sh
python tools/agentic/studio.py validate
python tools/agentic/studio.py verify
python tools/agentic/studio.py status
python tools/agentic/studio_smoke.py
```

The smoke command exercises a disposable committed repository and local recorded
checks. It never calls a model or certifies Studio, device or human acceptance.

A repository-first production control plane for the existing game. **This PR adds skills, executable planning/ownership/evidence tools, original-kit intake and procedural asset generation. It does not declare all gameplay or art finished.** The planner does not call models. V2 adds separately opted-in Codex execution, MCP discovery and Blender audit adapters; no automatic publishing or purchases. See [current execution](EXECUTION_V2.md) and [latest goals](LATEST_GOALS.md).

See [merge readiness and outstanding game gates](MERGE_READINESS.md) before interpreting CI success.

## Quick start

From the repository root, Python 3.11+:

```sh
python tools/agentic/forge.py doctor
python tools/agentic/forge.py validate
python tools/agentic/forge.py plan
python tools/agentic/reconcile.py
python tools/agentic/character_contract.py
python -m unittest discover -s tests/agentic -p "test_*.py" -v
python tools/agentic/generate_primitives.py
```

In Codex, invoke `$guildborne-director`. It discovers the 30 canonical skills and follows 33 dependency-ordered work packages. Tasks cover source audit, research, modular bodies/clothes, UI/logo/icon production, player/companion combat, animation, VFX, maps/zones/building, monsters/bosses, quests/story/hero bonds, skills/stats/progression, inventory/crafting, markets, player guilds, existing shop presentation, audio, EN/TH, performance, UAT and ethical growth.

This is an **agent-directed pipeline**, not an unattended script that secretly starts paid models. The local agent uses its genuinely connected image/Studio/Blender/audio tools. The Python planner emits prompts and tracks work; it does not impersonate those tools.

## First integration target

Run current regression, then deliver Human Standard + Heavy + removable tunic/trousers/hair + five-hero commander HUD + one ability animation/VFX end-to-end. Expand only after fit, runtime, readability and cleanup pass. Reuse existing UAT models, generators and native modules instead of generating duplicate libraries.

## Production artifacts

- `plan.json`: desired work, dependencies, owner skill, environment, checks and write scopes. Suggested scopes are contracts to reconcile, not proof those modules already exist.
- `.agents/skills/guildborne-*/SKILL.md`: real repo-discoverable skill instructions.
- `character-kit-v1/catalog.json`: normalized original v1 data, 89 planned assets/13 body presets/20 palettes. Original IDs retained. No runtime asset IDs invented.
- `QUALITY_GATES.md`, `ART_BIBLE.md`, `PROGRESSION_CONTRACT.md`: integration contracts.
- `research/SOURCES.md`: primary-source research and adoption decisions.
- `build/agentic/`: generated inventory, prompts, SQLite ledger and previews. Treat as local ephemeral output, not source or UAT approval.

## Ownership protocol

```sh
python tools/agentic/forge.py status
python tools/agentic/forge.py claim --task audit --owner director-worker
python tools/agentic/forge.py heartbeat --task audit --token ACTUAL_RETURNED_TOKEN
python tools/agentic/forge.py submit --task audit --token ACTUAL_RETURNED_TOKEN --evidence build/agentic/evidence/audit.json
python tools/agentic/forge.py accept --task audit --owner independent-reviewer
```

`submit` checks task/environment, required PASS checks, real local Git commit/tree identity, clean source, plan fingerprint, recorded invocation and artifact hashes, then moves the task to REVIEW. A different reviewer must inspect truth and accept. Names in the ledger are **not authenticated identities**; this is cooperative coordination, not access control. File existence/hash is necessary but cannot prove a test was genuinely executed.

Dependencies advance only after ACCEPTED. Active and REVIEW write scopes block overlapping writers. Expired leases are not automatically stolen because an old Studio worker may still be running. Confirm the old process/session stopped, then use `release` with its token. For worktrees always supply one shared absolute `--ledger` path controlled by the integrator.

Evidence JSON shape (replace values with observed data; this example is not evidence):

```json
{
  "taskId": "audit",
  "environment": "local",
  "buildCommit": "0000000000000000000000000000000000000000",
  "sourceTree": "REPLACE_WITH_ACTUAL_TREE_SHA",
  "planSha256": "REPLACE_WITH_CURRENT_PLAN_HASH",
  "invocation": {"tool":"ACTUAL_TOOL", "runId":"ACTUAL_RUN_ID", "exitCode":0, "buildCommit":"REPLACE_WITH_SAME_BUILD", "logs":["build/agentic/evidence/actual-log.txt"]},
  "checks": {"inventory":"PASS", "baseline":"PASS", "conflicts":"PASS"},
  "artifacts": [{"path":"build/agentic/evidence/actual-log.txt", "sha256":"REPLACE_WITH_ACTUAL_FILE_SHA256"}]
}
```

Never submit the example. Reviewer verifies the build matches the tested checkout. For cross-server tasks require distinct nonempty live JobIds; device tasks require actual device identity. These structural fields are not a replacement for platform/hardware proof.

## Character Kit v1

The normalized catalog and shared contract are included. To ingest **all original files byte-for-byte**, including original prompts, CSVs, XLSX and source generator, use the original attached archive:

```sh
python tools/agentic/import_character_kit.py PATH_TO/Guildborne_Modular_Character_Kit_v1.zip
```

Importer verifies the pinned SHA256, rejects traversal/symlinks/oversized or changed archives, never executes bundled scripts and refuses overwriting an existing intake. Full original archive is not reconstructed from this normalized catalog. Keep vendor intake read-only; do not rerun the original registry generator over production status changes.

## Local tool requirements

Git/Python/Rojo/Luau follow existing `tools/setup_tools.ps1`. Roblox Studio and Blender run on the user's workstation, not GitHub-hosted CI. Verify Studio MCP tool discovery/session identity before edits. Image/audio providers are optional and capability/budget gated. No provider key is required by this package; do not commit keys. Community Blender MCP is optional after source/telemetry/security review; offline `blender --background --disable-autoexec` scripts are the reproducible fallback.

## Deferred commerce work

The dedicated commerce-processing specialist is not included: its GitHub write returned an indeterminate tool safety-status block. New receipt-processing implementation and live commerce are therefore outside this package. The native UX task can review and style the existing shop using existing bindings only. No tests or tool permissions were disabled to bypass the block.

## CI and release

CI validates this package separately from the game's existing Windows Luau/build checks; it has no publish stage and no write permission. Physical Android/iOS, true independent live servers, sustained cloud soak, final artistic review and human UAT remain gates. No claim that the package guarantees popularity or production readiness.

## Merge-hardening follow-up

The tools now reject Windows path aliases and symlink parents, record quiet/failed
checks without losing their execution receipts, compose per-check evidence, validate
PNG pixels/filters/alpha (not only chunk CRC), and negotiate the stable MCP
2025-11-25 protocol as well as earlier supported revisions. CI exercises production
tooling on both Ubuntu and Windows; the existing Luau/build job remains separate.

For a local task, record each approved check on committed clean source, then:

```sh
python tools/agentic/compose_evidence.py --task audit --check inventory=build/agentic/checks/ACTUAL_RUN_1/result.json --check baseline=build/agentic/checks/ACTUAL_RUN_2/result.json --check conflicts=build/agentic/checks/ACTUAL_RUN_3/result.json --output build/agentic/evidence/audit.json
```

Replace ACTUAL_RUN paths with real recorder outputs. Check assignments explicitly
state which command checks which requirement; an independent reviewer must verify
that semantic match. The composer does not run an agent or accept the task.
