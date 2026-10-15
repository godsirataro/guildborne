# Human Party lifecycle increment — 2026-10-14

Status: scoped local implementation and synthetic Studio checks independently reviewed and passed. **Public ready: false.**

Candidate SHA256: `39dfc9420fb57af517370c842c0e09bfd000560539aa0df4dd6db6eea9f803dc`. Local Place/Game 0; Memory. All 363 script sources compared, eight changed/new. Staging/public flags and production profiles were not changed. The Studio window retains its older IntegrationPreview title; actual built artifact is Guildborne_LaunchPreview.rbxlx.

## Implemented

- Temporary human Party of at most six including leader; distinct from saved five-NPC companion selection and personal Guild ownership. No human-member Guild or Federation activation.
- Invites expire after60 seconds; bounded incoming/outgoing invitations; server checks recipient, leader, revision and final capacity. Replay cache bounded64 with stale revision fencing. Decline/leave/kick/disband/leader transfer/ready supported.
- Same-server disconnect grace30 seconds; deterministic leader transfer; session-generation checks prevent old callbacks changing a replacement session. Ready resets on membership/leadership changes and is not travel consent.
- Saving/Degraded retains membership and leadership. Recovery actions are available through native paused-state UI; pending client requests still disable mutations. Separate profile eligibility prevents joining new parties while saving.
- Native EN/TH panel with distinct NPC heroes tab, plain player names, destructive-action confirmation, and independent transient revision. Unsolicited Party state changes do not require or increment a profile revision.
- Explicit Network route after protocol/rate validation and before individual novice/mentor spatial gates. Social actions do not reach Data.Execute, World.IntentCommitted or economic audit flushing. Runtime enabled only by existing local launch resolver.

## Evidence

- Full automated check log: **764 tests**, build, Roblox-aware analysis, compile and repository checks passed. The final UI recovery refinement followed this run; final affected UI files were separately analyzed/compiled and the updated UI stub fixture passed. No claim that the full suite ran again after that UI-only refinement.
- Core reviewer independently ran nine focused synthetic checks and reviewed session/ownership/replay handling. Three additional protocol regression checks are included in the main suite.
- Studio Network fixture used the actual Network module with fake dependencies and one actual local Player transport target. All eight social routes plus injected handler failure and malformed request were checked: zero profile Execute, zero economic committed callbacks, zero audit flushes. Normal TravelZone still hit its progression gate. This is not a two-player network session.
- Actual SliceUI fixture with synthetic Party data: EN/TH at360/640px; sixteen buttons checked per case, no detected button text clipping. Party invitation appeared on unchanged persistent revision without message/navigation. Full roster had six owners with five displayed NPCs each; full-party invite disabled and grace-member kick enabled. Zero mutation callback calls. This is widget/layout evidence, not six-client capacity or physical touch acceptance.
- After fixture cleanup and Play restart, ordinary clicks opened Begin your adventure and Human Party on the actual solo UI. Root captured the visible screen in chat. Console snapshot contains normal boot only; fixture widgets were removed. No saved screenshot file is claimed.

Preserved files: `build-receipt.json`, `validation.log`, `core-tests.log`, `studio-raw.json`, `network-fixture.luau`, `native-ui-fixture.luau`, `ui-stub-fixture.luau`, and `final-ui-analysis.log` / `final-ui-compile.log` / `final-ui-stub.log`. Independent reviewer verified candidate/hash identity, all345 current source hashes, raw output,764 test rows and final UI recovery behavior; reran nine core checks and the UI stub.

## Remaining first-Public requirements

Two/four/six real clients and mixed outsiders, shared travel/slot reservation, shared enemy targeting/identity, support participation, conserved EXP/loot allocation and durable multi-owner settlement are **not implemented or accepted by this increment**. Core lifecycle state is ephemeral and does not survive server shutdown or cross-server transfer. Platform blocking/preference integration, invite spam tuning, cloud/device tests and human UAT remain pending. Source-only or synthetic results cannot close these gates.

Reviewed lessons: profile persistence state is not player connection state; test slow saves longer than disconnect grace. Transient social state needs its own UI revision. Individual-trial restrictions must not trap users in social membership. Learning does not grant publishing or reward authority.
