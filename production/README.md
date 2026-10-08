# Guildborne Agentic Production Forge

A repository-first production control plane for the existing game. **This PR adds skills, executable planning/ownership/evidence tools, original-kit intake and procedural asset generation. It does not declare all gameplay or art finished.** It does not call a model, launch Studio/Blender, publish, or purchase anything by itself.

## Quick start

From the repository root, Python 3.11+:

```sh
python tools/agentic/forge.py doctor
python tools/agentic/forge.py validate
python tools/agentic/forge.py plan
python -m unittest discover -s tests/agentic -p "test_*.py" -v
python tools/agentic/generate_primitives.py
```

In Codex, invoke `$guildborne-director`. It discovers the 21 specialist skills and follows 28 dependency-ordered work packages. Tasks cover source audit, research, modular bodies/clothes, UI/logo/icon production, player/companion combat, animation, VFX, maps/zones/building, monsters/bosses, quests/story/hero bonds, skills/stats/progression, inventory/crafting, markets, player guilds, existing shop presentation, audio, EN/TH, performance, UAT and ethical growth.

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
python tools/agentic/forge.py submit --task audit --token ACTUAL_RETURNED_TOKEN --evidence production/audit/evidence.json
python tools/agentic/forge.py accept --task audit --owner independent-reviewer
```

`submit` checks task/environment, required PASS checks, build-commit format and real artifact hashes, then moves the task to REVIEW. A different reviewer must inspect truth and accept. Names in the ledger are **not authenticated identities**; this is cooperative coordination, not access control. File existence/hash is necessary but cannot prove a test was genuinely executed.

Dependencies advance only after ACCEPTED. Active and REVIEW write scopes block overlapping writers. Expired leases are not automatically stolen because an old Studio worker may still be running. Confirm the old process/session stopped, then use `release` with its token. For worktrees always supply one shared absolute `--ledger` path controlled by the integrator.

Evidence JSON shape (replace values with observed data; this example is not evidence):

```json
{
  "taskId": "audit",
  "environment": "local",
  "buildCommit": "0000000000000000000000000000000000000000",
  "checks": {"inventory":"PASS", "baseline":"PASS", "conflicts":"PASS"},
  "artifacts": [{"path":"production/audit/actual-log.txt", "sha256":"REPLACE_WITH_ACTUAL_FILE_SHA256"}]
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
