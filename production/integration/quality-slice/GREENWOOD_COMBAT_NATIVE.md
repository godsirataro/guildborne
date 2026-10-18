# Actual server combat and client observation

2026-10-19, fresh unsaved Studio 1ec0bd16-505e-4eee-815a-2c8cfbb63547,
PID38036, Guildborne_GreenwoodCombatReview.rbxlx. All earlier Studio processes
were absent and MCP inventory empty before opening; old earned Memory sessions
are no longer live. Their retained reports remain historical, not restored saves.

Harness0309b9d integrated as45cf0c6; current game source uses ffd2760 multi-route
readiness. Base candidate bdcc13bd797335df550a182c9904763144426302324bb9c062ab7dfea2688de9;
combat candidate0389f2ae9d854f9ec0acec1df6a5ca04031b497f9e15808b043c711af8f38a76.
Before Play: PlaceId/GameId0, Memory, empty allowed DataStore universes, both
normal bootstraps disabled, paired fixtures enabled, no world or art template.
385 game sources plus two fixture sources compared equal with CRLF-to-LF only.
Initial strict byte comparison failed on Studio's CRLF loading; Play was started
despite that failed check, immediately stopped and excluded from acceptance.
Then all normalized source comparisons passed before the accepted fresh Play.
HTTP enable state was restored after readback; no source patch was used to pass.

Server terminal PASS_SERVER_FIXTURE:
- Cleave actual hit:15 HP damage.
- Cleave evade: real release, no victim HP/cue change.
- No-target cancel: warning cleared, no impact or damage.
- Phase-two Root Burst: reached with31 actual Basic calls (7 accepted,24 cooldown
  rejections); actual hit15 HP damage.
Warnings were1.1s and1.5s respectively; last release lateness0.183985s is retained,
not claimed to be an exact wall-clock deadline. Reward calls were empty.

Client OBSERVED_NATIVE_CLIENT:128 samples, zero dropped, eight observed warnings,
seven impact stamps, actual Cone26-edge and Circle32-edge warning geometry.
Samples retain twelve joint Euler components and replicated health/cues. Cleave
evade release retained victimHP202 and priorcue; RootBurst finalvictimHP127,
bossHP286. Client reports remain cosmetic observations, not combat authority.
Server and workspace clocks are separate. Raw MCP responses are adjacent.

Native capture greenwood_combat_actual_phase displayed actual captain, player and
cone warning. No local PNG archive or final art approval claimed. Scene uses
baseline regional scenery, not the new coastline/art packet. Player is anchored
and deliberately placed; profile is synthetic Knight60/Hall9 with zero companions.
No earned progression, walking, five-hero combat, rewards, ordinary input, HUD,
audio/skill VFX, device performance or full-game acceptance is established.

Cleanup reported ok with required residual teardown. Controller stopped Play
after collecting both terminal reports. TravelService connections/collision groups
and cosmetic changes require that Stop; the fixture is not reusable in one Play.
Console also reported Roblox CorePackages FoundationProvider warnings and asset
203785492 type mismatch; these are unresolved, not hidden by the server PASS.
