# Hero mentor increment — 2026-10-14

Source implemented and independently reviewed; local synthetic Studio world checks passed for the scoped cases below. PublicReady=false. No publication, live commerce or production data writes.

## Build and source checks

Built file `build/Guildborne_LaunchPreview.rbxlx`, SHA256 `41e341d43e58bbce62efcbe80652fab6650cbe04de899d2c73dbe307a295002c`; build receipt `build/launch-preview-build.json`, transfer manifest `build/launch-sync/sources.json`. Its360 script entries were synced into the already-open window titled `Guildborne_IntegrationPreview.rbxlx` (Place0/Game0, Memory). The window title is not the new artifact filename; older `build/integration-*` files and `build/Guildborne_IntegrationPreview.rbxlx` are historical artifacts and do not identify this candidate. All360 transferred script sources compared equal before Play. Source sync initially encountered disabled HTTP and then the Source property size limit on unchanged generated geometry; HTTP was temporarily enabled only for localhost transfer and restored, and a final full comparison verified every entry. Staging was not modified.

`build/hero-mentor-validation-final.log`:749 tests, Rojo build, Roblox analysis, compilation and repository checks passed. SHA256 `09dcc07f2ca3d94471fb5c50f839587f3d416b0a4d0cca79352e60ac29e26da2`. Independent reviewer policy_review separately ran749 tests and reviewed the final source. Studio adapters regenerated and verify passed98 files. This remains a dirty integrated workspace, not an immutable release revision.

## New behavior

Selected owned heroes can train for a matching Class2 path from Skills in the local launch candidate. Requirements retain Lv35, Hall4, Quarry Patrol, healthy active-party hero and no conflicting expedition/dispatch/tower. Temporary training uses the existing hero model and combat rules; damage, healing and guarded hits are server observations. Successful training records only a subject/path proof. Actual advancement still uses the existing command. Training another path before advancement replaces the unspent proof. Old earned classes remain readable.

Private receipt delivery uses PlayerDataService transaction/session/replay machinery; public protocol only accepts start/cancel. Cancel is refused while saving. The stored proof ID is omitted from client projection.

## Actual Studio observations and limits

Fresh normal boot:Lv1, no heroes, revision0. Foreign hero start returned NoviceJourneyRequired; direct HeroMentorProof returned InvalidRequest without a revision change.

Then a **separate synthetic world fixture** created three Lv35 heroes and a private fixture record. It used the real HeroService model creation/Begin/End, HeroMentorWorld, combat modules and receipt adapter. Its commit sink applied the pure proof operation to that fixture record; it did **not** exercise the live bootstrap Data session or a DataStore. Transaction uncertainty/rejoin evidence comes from automated PlayerDataService tests, not this Studio fixture. No grants or progress were added to the real fresh game profile.

- Initial fixture attempt lacked the bootstrap ability merge in MCP's separate require context and failed without proof. The fixture was corrected by merging Expansion.Abilities into its Combat config, as bootstrap normally does. The failure is retained in raw notice rows.
- Warrior/Berserker completed with its own `h:1` proof. Priest/Cleric restored the practice patient's HP20→100 and completed with `h:2` proof. Knight/Guardian observed a guarded hit, defeated the construct, and completed with `h:3` proof.
- During a deliberately retrying fixture delivery, Guardian status was Saving, enemyHP0, effect proven. Cancel returned SavePending and arena remained active. Resuming delivery recorded one matching proof and removed the arena.
- All three selected followers returned to the Heroes folder, unanchored, with original combat HP132/126/142. Arena was absent; owner returned to the fixture plot.
- An active Duelist trial cancelled without changing the fixture record; repeated cancel was harmless. Changing the fixture epoch ended another active trial and removed its arena.
- Injecting an acquisition error after real BeginMentor returned HeroMentorUnavailable, invoked restoration once and left all three followers unanchored with no arena.

Actual arena images were inspected through MCP in the conversation. Presentation is a simple prototype deck/construct/patient; this does not approve art, motion or audio. Raw observations: `hero-mentor-world-raw.json`, `hero-mentor-lifecycle-raw.json`, `hero-mentor-console-raw.json`. The console snapshot contained startup messages and the tool's camera reset notice, no game runtime error.

Fixture objects were removed; Play was restarted cleanly so temporary camera/UI changes and fixture callbacks are gone. `hero-mentor-clean-raw.json` confirms revision0, Lv1, no heroes, GUI enabled and fixture absent. The current Preview is a fresh Memory session. The previous normal Lv35/Borin journey remains evidence only for candidate55404c19, not this new build.

Learning record `lesson-e7bf7fe9df623d30f919d0ac024d4ceae37d85db2d809ddcb65d2104e8946117` captures the fixture dependency composition failure with raw evidence. This is a recorded lesson, not a promoted skill.

## Remaining gates

Normal hero recruitment→Lv35→trial→advance through UI on this build, the other seven paths in actual Studio, respawn/disconnect during a yielding save, exact client animation/audio quality, persistent staging/rejoin,2/4 clients, cross-server and physical devices remain pending. Earlier full player journey needs regression on the new build. Human UAT/release approval and other launch backlog remain open.

Independent evidence review by policy_review:PASS_SCOPED. Candidate hash, preserved build receipt,342 current source hashes,360 unique transfer paths,749-test log,98 adapters and all five listed artifact hashes checked. Fixture outcomes match raw records; contextual setup cause and images were not independently reproduced.
