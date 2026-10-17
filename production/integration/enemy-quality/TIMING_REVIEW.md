# Launch skill marker timing repair

Scope: SkillEffects, shared ActionTimeline and its existing test file. No server
combat, CombatController, HeroAnimator, NPC, audio ID or asset changes.

Before this repair, Mage/Archer/Knight/Priest delayed VFX began counting from
client observation, so network delay shifted the whole visual sequence. They now
schedule against the accepted server ActionAt. Passed markers and introductions
are skipped; upcoming markers keep their intended absolute time. Markers remain
cosmetic and do not delay, authorize or prove server damage/healing.

| Class | Release / target stage | Later target stage |
|---|---:|---:|
| Warrior (existing timing) | .10 | .24 |
| Mage | .12 | .30 |
| Archer | .12 | .26 |
| Knight | .12 | .24 taunt cue |
| Priest | .12 | .32 recovery ring |

Archer Area secondary arrows retain .26 + n*.035 releases and .42 + n*.035
impacts, n=0..4 (reduced detail uses fewer arrows). These are admitted independently,
so missing the first impact does not discard upcoming arrows. Already-passed arrows
are never replayed. Existing expansion PathSkillEffects scheduling is unchanged.

The compact launch-class fallback now shares its class markers: Mage/Archer
projectile then impact, Knight shield then target cue, Priest beam then final
target cue. The existing path-identity compact branch keeps its previous behavior.
Counts/caps and .75-second detailed-effect admission remain unchanged. This is not
proof that all five actors can display detailed effects simultaneously.

## Local validation and limits

`tests/action_timeline.luau` exercises the actual injected scheduler with fake
clock/queue: latency, passed markers, exact boundary, invalid clocks, cancellation,
duplicate callback, delayed callback deadline and five independent actor guards.
It retains the existing Power Strike accepted/rejected server-ability tests.
`timing-targeted.log` is the actual output. Independent source review found no
concrete timing/cancellation/budget regression and separately ran the tests.

`timing-baseline.log` records the full repository validation run. Local tests do
not prove Roblox allocation, five-hero readability, sound synchronization, physical
mobile performance or end-to-end skill VFX wiring. No Studio calls were made here.

## Controller acceptance — pending

Run the existing `tests/studio_action_cancellation.luau` in the isolated client.
Then inspect all five class branches in High and Low at ActionAt ages 0, .05, .20
and .50. For base classes, .50 should create no expired launch effect; at .20 only
upcoming target/recovery cues should appear. Test Archer Area separately because
its final .525/.56 impacts remain upcoming at age .50. Use valid per-class
ActionEffect/ActionAbilityId and target metadata. Allow the detailed admission
window to reset between isolated samples, then test five simultaneous actors with
one shared factory to exercise compact fallback and real shared object caps.

During pending stages, replace ActionAt, clear it, remove the model, kill the
Humanoid or set health to zero; check no later cues appear after cancellation is
observed. Count Primary/Detail buckets and cleanup. Record actual output and visual
evidence separately; the deterministic scheduler test cannot certify this matrix.
