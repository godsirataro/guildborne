# Studio v3 acceptance boundaries

Studio v3 extends the existing Forge on PR #1. It provides 33 roles, 30 canonical skills, 10 workflows, 12 evidence gates, 7 path rules and mappings for all 33 current production tasks. Generated artifacts are 33 Codex role definitions, 33 Claude role definitions, 30 Claude skill wrappers and one catalog; the separate manifest records their hashes and canonical source hashes. No gameplay or production-plan migration is included.

## Observed local capabilities (2026-10-10)

| Observation | Evidence and limit |
| --- | --- |
| Native Codex skills | Codex 0.162.0-alpha.17.2 app-server `skills/list` with a fresh scan discovered all 30 Guildborne skills, including the five new skills, without reported Guildborne load errors. No model turn was invoked. Local report: `build/agentic/studio-native-discovery.json`. |
| Role adapters | Deterministic generation, TOML parsing, supported native keys, source/output hash verification and scoped role instructions are tested. Standalone custom-agent runtime selection and Claude client loading are not certified by file generation or skills discovery. |
| Coordinator handoff | `studio_smoke.py` executed a disposable committed repository: route, claim, scoped handoff, three recorded checks, REVIEW, rejection of self-review, distinct reviewer acceptance and dependency unlock. This is fixture evidence; it does not accept the real production audit task. |
| Real host workers | Actual Codex host subagents built the canonical specification, router and independent behavioral tests using one development coordinator ledger and disjoint claims. Generated definitions do not launch workers automatically. |
| Generated-role behavior | A real host QA subagent parsed the generated `qa-engineer` instructions and independently rejected a proposed promotion of local smoke and same-server multiplayer into device/cross-server/human acceptance. It queried the actual Studio inventory and made no writes. This tests supplied instructions, not automatic custom-agent registration. |
| Blender executable | Blender 5.2.1 LTS opened the existing Sentinel source with auto-execution disabled: 24 objects, 11 meshes, 1 armature and 9 actions. This read-only tool smoke does not validate new Human bodies, clothing fit, exports or Roblox import. The executable is outside PATH; a PATH-only doctor may report it unavailable. |
| Roblox Studio | `list_roblox_studios` returned an empty studio list. Studio integration and playtest evidence cannot be produced in this session. Rojo builds remain local-file evidence. |

Local capability reports are ignored working artifacts, not authenticated platform attestations. No global client configuration, publishing, uploads, paid model subprocesses, commerce activation or production DataStore writes are performed by the new Studio commands.

## Candidate checks

Run these on the clean committed candidate; retain receipts and raw streams with `record_check.py`. GitHub CI runs the production tools on Windows and Ubuntu and the existing game regression on Windows. CI artifacts identify their source commit and package the tracked native adapters with the source.

```sh
python -m unittest discover -s tests/agentic -v
python -m compileall -q tools/agentic tests/agentic
python tools/agentic/forge.py validate
python tools/agentic/studio.py validate
python tools/agentic/studio.py verify
python tools/agentic/studio_smoke.py
python tools/agentic/reconcile.py
python tools/agentic/character_contract.py
```

Run `tools/setup_tools.ps1` when pinned baseline tools are missing, then `tools/validate.ps1` and `.tools/luau/luau.exe tests/run_latest_progression.luau`. Pipeline tests do not replace the game baseline. Windows hosts without symbolic-link creation privileges skip the two new link tests; Ubuntu CI exercises those boundaries.

Behavioral coverage checks exact task/skill ownership, hierarchy and workflow order, dependency/review transitions, lease expiry, explicit owners, directional write scopes, shared-ledger identity, token redaction, no overwrite of edited output, stale adapters, hash drift, unsafe paths and valid native TOML. Missing PyYAML prevented the optional skill-creator `quick_validate.py` run; canonical frontmatter/reference checks and actual Codex skill discovery cover the delivered skills without installing packages.

## Still external to merge checks

Roblox imports and real runtime IDs, Studio playtests, four actual multiplayer clients, physical devices, distinct live servers, new asset fit/art/audio review and human acceptance remain separate game-production gates. Four clients on one server do not demonstrate cross-server behavior. Existing game tasks and evidence are preserved; no gate becomes ACCEPTED merely because Studio v3 passes its local tests.

Continue through the ready Forge tasks and the appropriate workflow in [STUDIO_V3.md](STUDIO_V3.md). A coordinator must choose actual connected sessions, obtain the exact task claim, delegate through available host capabilities, validate fresh receipts and assign a different reviewer. Merge and release remain external decisions.
