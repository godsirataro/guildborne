# Chapter 00 playable course — 2026-10-04

The optional memory-only Novice build now connects all six chapters to actual world interactions, measured combat lessons, the five solo class trials and free guild founding. Default staging and offline projects retain legacy onboarding. Open `build/Guildborne_NoviceCoursePreview.rbxlx` for this separate preview; stopping Studio discards its profile.

## Actual complete journey

One fresh schema-8 profile completed the rescue branch through normal movement, E interactions, F/Q combat and actual GUI clicks. No tool granted XP, Gold, inventory, health, class, objectives or victories. Read-only snapshots captured the committed server revisions.

| Milestone | Revision | XP / level | Result |
| --- | --- | --- | --- |
| Courier, path, warning dodge, help | 5 | 100 / 3 | Chapter 1 claimed |
| Basic attack, warning dodge, rescue drill | 9 | 200 / 5 | Chapter 2 claimed |
| Tracks, rescue choice, supply fallback | 13 | 300 / 7 | Chapter 3 claimed |
| Keeper victory, captive, false crest | 17 | 400 / 9 | Chapter 4 claimed; battle 21/48 HP |
| Five actual class skills, including heal | 23 | 450 / 10 | Chapter 5 claimed |
| Mage solo trial | 24 | 450 / 10 | Three skill hits, dodge, victory; 25/47 HP |
| Confirm Mage | 25 | 450 / 10 | Starter staff equipped |
| Hall victory and registration | 27 | 450 / 10 | Battle 47/47 HP |
| Confirm free Knight companion | 28 | 450 / 10 | Hall 1, cap 20, Bram level 10 and sword |

Gold remained 0 throughout. Course/trial models were removed and the player returned to Guild at approximately (0,4,23). Evidence: `validation-novice-course-journey-live.json`. Actual runtime console recorded each revision once with no script errors. The complete journey used one class/founding choice; other combinations have domain coverage, not equivalent full native journey evidence.

## Implementation and validation

`NoviceCourseWorld` owns one bounded course per player (maximum eight), checks server distance and expected objective, and submits private receipts through the existing transaction service. Class trials use the bounded arena manager. Borrowed lessons use level-appropriate shared damage/targeting/abilities; the teaching warning on the road does not cause damage. Result retries retain stable identity. A scoped owner/rate-validated combat remote accepts only attack/return intent.

498 domain tests pass, including eight lesson definitions, all five Hall combat configurations, invalid stage/class/party cases, quest tracking and existing save recovery tests. Strict analysis, whole-source compilation, repository boundaries and three builds pass at 214 runtime scripts. This is local technical evidence, not release approval.

## Remaining

A second actual fresh journey now completed the supplies branch with reverse-order class lessons, Archer selection and free Priest founding at revision 28. Keeper finished 48/48 HP; Archer trial and Hall each finished 49/49 HP. The newer four-character presentation was active. Evidence: `validation-novice-supplies-archer-live.json`. Separate temporary-eligibility failure testing took real warning damage to 0, awarded nothing, exited and restarted at full borrowed HP with the real profile unchanged at revision 0. This does not establish persistent reconnection behavior.

- Persistent reconnection, death/retry and real simultaneous-client course isolation acceptance.
- Full native journeys for other class/branch/founder combinations; physical mobile/controller and human UAT.
- Courier/captive/keeper character art, borrowed weapon appearance, dialogue, motion/audio polish and imported assets.
- Chapters 01–02 and the broader launch backlog; this course does not make six complete cities or the entire release complete.
- Cloud publishing, commerce IDs and public market activation remain disabled/pending.
