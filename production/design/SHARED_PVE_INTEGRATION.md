# Shared PvE integration
Status: REQUIRED FIRST PUBLIC / IMPLEMENTATION INCOMPLETE.

PARTY6_PLAN.md remains the detailed contract. Current human membership is a local scoped slice (see party-integration/REPORT.md), not shared combat. Next sequence: consented shared travel/slot reservation → composite owner+actor identity → shared enemy authority and threat/support → eligibility → durable settlement and per-recipient claims → 2/4/6-client mixed-population tests.

Solo owners and Party owners can fight the same supported enemy population. Six is human Party capacity, not guaranteed server capacity. Preserve up to five heroes per owner;6+30 allies before enemies is a required stress scenario, not a measured supported load.

Fixed encounter reward pool divides across eligible participating owners; NPC work credits the owner. Define internal hero XP separately because today's per-actor grant cannot be reused as a conserved pooled grant. Effective heal/protection/tanking count; proximity, last hit and Party membership alone do not. Unique items allocate once; personal quest keys and earned class prerequisites remain individual.

Commit immutable settlement before recipient delivery, retain pending claims across failure, and never claim multi-profile atomicity. Test disconnected contributors, kick-before-kill, full inventory, caps, mixed outsiders, late joining, replay and restart. Preserve local ownership fences outside explicitly shared encounter mode. No publication or cloud persistence enablement follows from this plan.

## Current implementation boundary

Opaque membership, composite actor keys, effect-time membership checks, once-per-tick scheduler, contribution ledger and immutable owner allocation repository pass scoped independent source reviews. A seven-owner synthetic fixture passed in Local Studio without profile writes; this does not enable shared zones or prove seven human clients. See integration/SHARED_PVE_CHECKPOINT.md.

The next private contract freezes each eligible owner's player and hero IDs into a version2 settlement. Experimental equal-actors-v1 divides that owner's XP pool across those frozen IDs; it never duplicates the pool for every hero. Version1 remains owner-only preparation and cannot authorize this payout. Actual roster ownership must be checked by the trusted encounter adapter. Missing actors, XP/inventory/wallet limits or receipt capacity keep the entire recipient allocation pending; no redistribution or guessed repair.

Durable profile receipts must outlive the recent-command window and session epoch. Candidate grants, canonical allocation receipt and audit events must commit through the existing fenced profile transaction. No public remote action accepts an allocation. Versioned settlement and profile receipts are separate records, so recipients can finish independently and retry safely; no multi-profile atomicity is promised.
