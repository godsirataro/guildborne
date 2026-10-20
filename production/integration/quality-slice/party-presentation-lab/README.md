# Disposable party presentation lab

This is a synthetic local-player Warrior level 10 plus five real HeroService
companions: a:Knight, a:Warrior, a:Archer, a:Mage, a:Priest. It does not load,
rewrite or save any player profile. Eligibility for the walking routes is
synthetic. It cannot prove earned progression or production release gates.

Build from the current quality preview project:

`python production/integration/quality-slice/party-presentation-lab/build.py`

Optional `--start-zone City` starts walking inspection in City; default Guild
allows ordinary walking into the existing island camp. Output defaults to
`build/party-presentation-lab/`; `--output-dir build/party-presentation-lab-r2`
selects a fresh child directory beneath repository `build/`. Previous attempts
are refused, not overwritten, including failed builds and their receipts.
The builder reuses existing art packaging and current source paths, disables both
normal bootstraps, records all input hashes and verifies the built script flags.
It does not run ordinary preview builders or overwrite their files.

Open only the resulting unsaved, standalone Memory place. Server guards require
Studio, PlaceId/GameId zero, Memory and empty allowed DataStore universes, one
player, disabled normal bootstraps, no existing world/remotes/art runtime or
earned character attributes. Never install it alongside an already running game.

The only combat remote accepts exactly `{action, actorId}` from the owner, with
an action/actor allowlist, live character fence and 8/sec token bucket (burst12).
It delegates to WorldService.PlayerAction, preserving server ownership, target,
line-of-sight, cooldown and damage logic. State only supplies display names and
language. No manual hit/ability stamping or forced cast is performed. Select
Player/Skill1 for PowerStrike and Mage/Skill1 for Fireball within ordinary camp
range. Actual return status and server attributes/HP remain the acceptance data.

Real HeroAnimator, EnemyAnimator, CombatController, PlayerCombatController and
FriendlyNpcAnimator start on the client, along with AudioController. Missing
audio bindings remain silent. The persistent banner identifies the fixture.
Normal SliceUI, quests, inventory, network/persistence and campaign controllers
are intentionally absent: this lab cannot establish their integration.

`workspace.PartyPresentationLab.Report` records at most256 combat commands and
100 walking notifications. Reward callbacks only increment a diagnostic counter;
no gold/XP/items are granted. Autonomous HeroService AI still runs normally and
may attack/cast. Observation must distinguish AI actions from recorded input.

Actual Humanoid.Died/replacement, another player joining or owner leaving latches
the lab closed until restart. Domain CombatHealth reaching zero is different:
the existing combat service rejects downed actors and owns their recovery; this
does not by itself terminate the lab. Client cleanup calls AudioController.Destroy
along with the five presentation controller handles.
Stop Play is mandatory teardown: WorldService/TravelService have no complete
world teardown API. The lab disconnects its remotes and removes its HeroService
owner/runtime when stopped, but does not claim hot-uninstall completeness.
No Studio acceptance, earned journey, physical device or human art approval is
established by build/compile checks. Controller owns all native execution.

Rojo execution is bounded to120seconds. Timeout/interruption triggers bounded
Windows process-tree termination and records its outcome. Every newly started
build attempt preserves raw streams and a failure receipt, including preflight,
source-enumeration and XML validation errors. Source sets are re-enumerated after
the build; added, removed or changed inputs prevent acceptance. Existing output
directories are refused intact. A failed cleanup is reported, never treated as a
successful build or permission to restart blindly.

Optional `--three-road-walk` includes Ironveil–Ashen in addition to the default
two roads. It requires the input runtime to explicitly enable
`FullConnectedWorldCandidate=true`; the server checks the loaded runtime again
before any fixture mutation, in addition to all existing isolation guards.
The project attribute, receipt and native report identify this mode. The fixture
remains synthetic level 10 eligibility, not earned Ashen progression. StartZone
still defaults to Guild (or explicit City); traversal after setup uses ordinary
walking inputs, with no forced test teleports.

Three-road mode accepts only the exact runtime emitted by the reviewed full-
connected preview generator; altered configuration must be regenerated/reviewed.
The loaded server runtime independently requires all six journey flags and
rejects launch, shared-combat or continuous-launch flags before mutations.
These extra exclusions apply only to the three-road opt-in.
