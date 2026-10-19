# Synthetic party manual inputs — R2 failure and R3 success

Both runs use isolated Memory candidate d51362276b9b6bfb99abde6574175ee217c4f24984e9a4c315b28a8736e52b92
built in party-presentation-lab-r3 from the corrected HUD source. Normal bootstraps
are disabled. Level10 Warrior and five HeroService companions are fixture data,
not earned progress. No profile loads/writes, currency/XP/item grants or publication.
Studio ea5c5563-9675-40a1-a15b-5aae5d7272a7, owned PID34396, is now Edit.

## R2 failed manual attempt
All five keyboard Hold orders were accepted; initial attempts to click the clipped
Hold button instead sent Basic and were rejected EnterCamp. Mage Regroup accepted.
Controller waited too long in enemy range before capturing. Player health is zero
throughout480 server samples; Mage falls47 to0, with no successful cast tuples.
Only recorded manual Ability1 was Mage NotReady. Missing player command is not a
server acceptance. The8second trace has984 server and984 client rows, no observer
overflow. Keep this failed trial, not a substitute successful take.

An attempted200-row then50-row inline base64 export exceeded tool output limits.
The50-row truncated raw result is retained as failed transport, not parsed evidence.
Ten complete lossless Zstd pages recover all1968 contiguous observations.
Stop/restart between R2/R3 is controller-attested; its action receipts were not saved.

## R3 accepted inputs and presentation
At a safe approach, five Hold orders succeeded, followed by Mage Regroup to suppress
automatic attacks. The selected player walked at speed1 toward(-12,4,76); ordinary
Q, Mage selection and Q produced:
- player Ability1 OK1792447994.592765, ActionAt1792447994.592724 power_strike,
  AbilityCount+1 and DamageDealt+27.
- Mage Ability1 OK1792447995.326639, ActionAt1792447995.326595 fireball,
  AbilityCount+1 and DamageDealt+35.

Server capture1792447992.528877..1792448000.54232 and client
1792447992.598251..1792448000.613777 each request8seconds, with984/1236 rows and
480 samples per actor per side. No record loss, capture gap or discovery overflow.
First matching client tuples arrive35.229ms /17.652ms after the respective server
ActionAt. These are observations in this Studio run, not network latency guarantees.

Independent reviewer toolchain_audit verified actual Part0-relative joint motion
against the last pre-cast sample in the first0.35seconds. Player left/right shoulder
maxima67.625/122.172degrees, Waist52.416,Root9.536; Mage shoulders104.140/103.032,
RootJoint24.069,Neck12.390. Transform deltas track these observations.
No C0/C1 composition, timing/contact quality or human art acceptance is established.
derived-facts separates first and last observations: Mage health47 at first cast
observation and25 at the last; the latter is not cast-time health.

VFX:85 additions/readiness,82 removals. Three late untagged objects at
1792448000.48055..8000.480871 are right-censored by the capture deadline.
19 Mage.Fireball-tagged objects:Charge9,Travel2,Impact8; all have removal observations.
Observed completed lifetimes0.0652518..0.665056seconds. Global attribution remains
UNASSIGNED; timing/family alone does not prove per-actor or same-cast ownership,
and leaving Workspace is not proof of destruction. No full audio acceptance.
The actual screenshot shows an overbright blocky effect and overlapping labels;
successful mechanics do not imply satisfactory VFX/UI/art.

## Source and transfer integrity
After Stop Play, all443 candidate sources plus the exact installed observer match
444 Edit sources by normalizedUTF8 length/Adler32 and classes; PlaceId/GameId zero,
HttpEnabled false. This is post-capture identity, not a pre-Play full-source check.
The initial XML parser looked only for ProtectedString, missing443 string-tagged
sources. Its failed comparison is retained; the corrected parser covers both tags.

Twelve R3 pages are losslessly compressed by native EncodingService and delivered
to a bounded127.0.0.1 HTTP receiver. It validates contiguous sequences, refuses
existing files and stores compressed/raw SHA256 and byte lengths. A temporary
RemoteFunction returns only bounded existing client observer chunks to the server.
HttpEnabled was temporarily true only for export and restored false; bridge was
destroyed; receiver closed after12 successful writes with zero failures.
Raw r3TransferReceipt records bridge removal and HttpEnabled restoration.
No gameplay state was modified by this evidence transfer. Stop Play discards
the disposable session. Original user's Studio remains untouched.

Independent review verified all22 R2/R3 compressed pages, hashes, lengths, sequences,
manual server outcomes, joint observations and source identities. Full party road
travel, earned journey, physical devices, performance and final art remain open.
