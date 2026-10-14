# Guildborne integration candidate — 2026-10-14

Status: REVIEW CANDIDATE. This is an implementation of the first integration slice, not completion of phases A–E or game release acceptance.

## Implemented

- Consolidated the earlier asset, GUI and character research into `production/research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.json`: 94 unique options from 96 source routes. Runtime IDs, payload inspection and source rights remain separate fields; research does not authorize runtime intake.
- Added the eight requested motion repositories and named tool candidates to `production/research/TOOLS_FREE_2026-10-14.json` and its readable Markdown companion. No third-party skill pack or new MCP was installed.
- Added Forge-integrated learning: immutable evidence-linked lessons, local search, candidate skill patches, actual bounded evaluator subprocesses, independent named review, promotion journal and rollback/recovery. Release/accept records a learning handoff; it does not automatically promote a skill or invoke a model. One real regression lesson was recorded and retrieved; no skill was promoted.
- Bound native Borin presentation to the existing `smith_borin` NPC. Work, interaction and recovery share one pose owner; contact cues and cleanup preserve NPC IDs, root position, quest prompts and server rewards.
- Built a separate full-game Memory preview with the existing authored detailed Borin study packaged locally. The client overlay follows the authoritative NPC and native controller state. This is an EditableMesh preview with source provenance, not a production uploaded mesh/animation ID.
- Added an action timeline used by existing action poses, finite-time guards, and actor-owned audio cleanup with generation fencing. Added a forge cue contract. Audio bindings remain empty: no audible playback or mix acceptance is claimed.
- Delayed combat VFX now validate the captured action stamp/generation and caster life/ancestry. Repeated, stale, nonfinite and future stamps are rejected. Warrior release/contact markers use server action age in both detailed and compact rendering. This cancels future emissions; already-created effects retain bounded cleanup. Other class choreography still needs its own marker mapping.
- Added a guarded preview builder and sync operator. Only Studio Edit mode with PlaceId/GameId zero accepts sync; its Runtime must use Memory with an empty DataStore universe allowlist. Staging Runtime remains unchanged.

## Actual checks

- Fresh original `tools/validate.ps1`: 714 game tests plus Rojo build, Luau analysis/compilation and repository checks passed. A type-inference error in the first action timeline draft was corrected before the passing run.
- Local Studio network journey: 37 requests, real quest timers, 97.739 seconds; character, recruitment, party, three quests, loot/equip and Hall upgrade. Final Hall 2, gold 10, hero XP 90. Replays returned AlreadyCommitted without duplicated rewards; conflicting requests and incompatible equipment were rejected. This used `tests/studio_offline_journey_probe.luau`, not human UI input or persistent saves.
- Existing weapon grip fixture in Studio: 22 equipment cases, 170 welded parts, R6/R15 hand stand-ins, replacement and unequip cleanup passed. This does not certify animated grip/clothing fit on every live body preset.
- Native Borin fixture: three contact samples, maximum measured error 0.00000026656007889869218 studs, root preserved and pose restored. This is separate from detailed mesh contact accuracy.
- Detailed Borin arranged local lifecycle: Work → Interact → Recover → Work; tag removal cleaned up the mesh and adding the tag rebuilt it. Presentation attributes were arranged for this check; it was not a completed Borin quest.
- Client presentation probe: 225 finite pose samples, invalid time rejection and audio instance lifecycle passed. No audio listening or production asset ID acceptance.
- Final VFX fixture passed replacement, death, streamed removal, separate live-duplicate/stale checks, invalid timestamps and expired Warrior markers in High and Low quality. This checks cosmetic scheduling, not damage or physical-device performance.
- Full agentic Python discovery: 177 tests, 5 platform skips, successful. Studio role generation/verification: 98 generated files; Forge metadata: 36 tasks and 31 skills. The one real lesson was preserved when the stopped v4 ledger was migrated to the single active v5 ledger.
- Independent reviewers found and checked fixes for stale rollback lineage, reused holdout inputs, reviewer name normalization, generated chunk delimiters, sync preflight, setup cleanup, tag races and delayed cue replay.

## Remaining acceptance and implementation

Phase A source/research reconciliation and the first source integration are implemented. The open Staging place was stale relative to this workspace and used DataStore persistence, so it was not synced or played. The separate Memory candidate exercises the current workspace including pre-existing uncommitted character work.

Phase B still needs the ordinary Borin quest journey from its real prerequisites, actual detailed-model contact/foot/hand review, licensed experience-accessible audio binding and listening. The native contact fixture is not a substitute for these.

Phase C still needs detailed Watchblade/bow study integration into actual R15 and companion actors, all action/cancel states, marker-driven VFX/audio across classes and late-network checks. Current pose/grip checks are narrower evidence.

Phase D still needs the full intended novice/progression route through UI, boss combat, crafting, travel and persistent rejoin; Thai/English layout and two/four-client checks; actual mobile performance and human art/feel review. The legacy Memory smoke journey does not certify these newer gates.

Phase E stays gated on the first polished playable route. The tools below are adoption decisions, not invented installed capabilities. No publishing, asset upload, paid inference, production saves, commerce or cross-server acceptance occurred.

## Approved tool additions and practical routing

| Candidate | Decision for Guildborne |
|---|---|
| HyperFrames | First local video-render experiment after authentic gameplay footage is ready; titles/captions/trailer overlays. Pin dependencies and test offline before adoption. |
| Remotion / Claude Remotion Skill | Alternative only when its free eligibility applies; no parallel renderer stack by default. |
| GSAP Skills | Study easing/timing/cleanup; implement original native TweenService behavior. Web animation is not a Roblox animation asset. |
| Animate / Claude Motion / Product Launch Motion / Motion Graphics Skills | Read storyboard, contact-sheet, cue-sheet and procedural sound approaches; select one renderer rather than install all four workflows. |
| OpenDesign | Name resolves to multiple unrelated projects. Keep identities explicit in research; use design intake/context concepts, do not guess a credential-importing application. |
| Graft / Trail-Code; Codebase Memory MCP | Benchmark a pinned local Luau index against rg and existing source maps before adding a persistent graph. Measure parse correctness, update freshness and query time; no paid summaries. |
| OpenMontage | Later local footage trim/mix/subtitle workflow. Provider generation and hosted APIs excluded. |
| Agency Agents | Compare selected role/checklist ideas with canonical Studio v3 roles. No bulk role replacement or claims that prompt files launch agents. |
| Diagram Design | Architecture, quest and state diagrams as review artifacts; native game UI remains separate. |
| Scientific Agent Skills | Selected experiment design/statistics for measured playtests; no general scientific bundle. |
| Agent Reach | Public documentation/GitHub/RSS research experiment only; audit each backend before enabling. |
| grill-me / grill-with-docs | Focused unresolved design review and decision records; do not repeat already approved questions. Exact “grill doc” alias remains unverified. |

Terminal/background CLI work uses bounded local processes with an owned session ID, captured stdout/stderr, timeout and explicit stop/cleanup. It does not create recurring automation or background model calls. Studio and Blender retain exclusive ownership.

Subagents use the host's real collaboration tool, canonical Studio roles, one shared Forge ledger and disjoint write scopes. Model settings inherit the host; no external model router, provider credentials or paid fallback is introduced. A future routing benchmark must compare actual measured task quality, time and cost before changing that default.

The learning loop is task-triggered: work → observed check → immutable lesson → candidate → fresh holdout/refusal tests → independent review → promotion or rollback. User feedback remains identified as user feedback, separate from agent conclusions. Learning cannot grant publishing, spending or server-authority permissions.

## Reproduce the local candidate

Run `python tools/build_integration_preview.py`; open `build/Guildborne_IntegrationPreview.rbxlx` as a separate Studio file. Verify PlaceId/GameId zero and Memory Runtime before Play. To refresh an already-open preview, serve only `build/integration-sync` on localhost port 8774, run the reviewed `production/integration/sync_preview.luau` in Edit, then stop the file server after testing. Do not run this against Staging.

Build receipts and probe outputs are under `build/integration-*`. Generated files, local tests, Studio probes, physical-device tests and human approval remain separate evidence levels.
