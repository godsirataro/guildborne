# Synthetic five-hero party — native observation R1

2026-10-20. REVIEW ONLY. Strict isolated Memory presentation fixture: Warrior level10
with five real HeroService companions Knight/Warrior/Archer/Mage/Priest. Normal
bootstraps disabled; no loaded profile, earned recruitment, XP/currency/item grant,
production persistence or publication. This is not a full-game integration test.

The first builder attempt was refused after Rojo succeeded: duplicate ClientBootstrap
instances included an enabled script. It was never opened or played. The corrected
builder mounts explicit client children and verifies exact ancestry/class/uniqueness
and disabled state. Both raw stdout/stderr streams, including empty ones, survive.
Second candidate74aa33122ca68c65a2db9935e0bf32764e2c724576dcffa029daa64060ae2356
passed unchanged-input/build checks and native Edit guards before Play.
Studio ab3a8d65-356b-443e-bb73-879cba0fdfbf, owned process48576. Play now stopped.

## Capture and results
Run party-native-20261020-r1: server1792444858.300251..1792444888.313593,
client1792444858.387959..1792444888.399536, each requested30seconds.
Actual standard combat UI/input and speed1 navigation were used. Three manual
Ability1 inputs were rejected NoTarget: player4862.063439, player4874.129738,
Mage4882.479039 (timestamp prefixes179244 retained in raw report).
Do not mark manual Power Strike or manual Fireball passed.

Server observed owned Mage Fireball ActionAt1792444861.665813,
1792444873.764868 and1792444881.780827. These precede the rejected manual inputs;
normal companion AI was active. Mage final deltas:3 abilities,7 basics,200 damage.
Player health stayed57 with no action/ability/basic/damage counters in the trace.
No player PowerStrike success is present. rewardCallbacks44 in the final lab report
is a diagnostic count gathered while the lab kept running after capture; it grants
no rewards and must not be described as earned gold/XP.

Independent reviewer toolchain_audit validated19 server chunks/3624 contiguous rows
and26 client chunks/5158 contiguous rows, every compressed and raw hash/byte length.
Server contains1800 samples each for Mage and player; client1799 each.
Mage has6 Motor6Ds; player15 AnimationConstraints. Server Transform values are
constant, so server joint transforms alone do not establish cast animation.
Client PostSimulation samples near all three server-authorized AI Fireballs show
actual Part0-relative joint rotation as well as Transform motion: approximately
19 degrees RootJoint and12 degrees Neck in each initial0..0.2-second window, with
shoulder motion. Sampled actual-relative/Transform rotation disagreement is at most
0.052 degrees in those reviewed windows. These are movement observations, not
timing/contact quality, visual appeal or manually controlled skill acceptance.
The collector does not record C0/C1 and cannot prove their full composition equation.

## VFX limits
All512 tracked client VFX IDs have readiness and removal observations, with observed
lifetimes0.065262..0.750051 seconds. However discoveryOverflow=true and
captureIssues=[discovery_limit]; full VFX coverage is INCONCLUSIVE despite
collection.complete=true and no record-buffer overflow. VFX is globally UNASSIGNED.
Readiness includes381 untagged,82 Warrior.Basic Release,32 Warrior.Basic Contact,
9 Mage.Fireball Charge and8 Mage.Fireball Impact. No labeled Projectile or complete
same-cast lifecycle was established. Do not attribute Warrior.Basic to the player
or infer ownership from time alone. Removal means leaving Workspace, not necessarily
destruction. No audible audio, human art, device or full-party road claim is made.

## Source and transport
The source check was collected after capture, not a pre-Play complete source proof.
All443 project sources plus the installed observer match normalizedUTF8 length/
Adler32 checks.63 additional engine chat/player scripts are enumerated separately.
The observer installed from shell output had one extra normalized trailing newline;
installed-probe.luau preserves exact installed source. The initial comparison and
resolved comparison are both retained; no substantive source difference was hidden.
source-expected.json is the resolved expected list (observer length18567/Adler1851196738).
The initial comparison used length18566/Adler1762985272 from the repository file.
Pre-Play native guards did verify both sole normal bootstraps disabled, actual
Memory Runtime, empty allowed DataStore universes and PlaceId/GameId zero.

To avoid tool-response truncation, each consecutive200-record page was serialized
as JSON by HttpService, compressed losslessly through EncodingService Zstd and
transferred as40000-character base64 segments. .zst files preserve those compressed
bytes; matching .zst.json sidecars preserve offset/row count, raw/compressed lengths
and SHA256 for both compressed bytes and decoded UTF8. Every row sequence was
validated after decoding with local Node zlib.zstdDecompressSync. Python3.14's
standard compression.zstd also decodes these files. No samples were reduced or
replaced. Small raw MCP sample responses and terminal metadata are retained too.

Next: fresh synthetic run using actual per-companion Hold orders before combat,
then one accepted player PowerStrike and manual Mage Fireball with narrower complete
observation; separately test both roads with five companions. Earned progression,
ordinary quest/UI integration and final visual review remain separate requirements.
