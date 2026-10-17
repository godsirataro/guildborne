# Ordinary input: first novice chapter — 2026-10-17

Studio a6d25956-416f-4c3b-96bd-8a471f6f9819, isolated Memory optimized launch
preview with subsequently verified exact VFX/NPC module patches. Started fresh
Play. No profile, progression, reward or position mutation by test script.

Actual input route:

1. Clicked title Begin adventure, then Explore to close the management panel.
2. Walked W from (-4500,3,214) to approximately z150, then A toward courier
   (-4565,3,149). Pressed E in prompt range. UI checked Meet the courier and
   objective advanced to Follow the training path.
3. Walked D back to CourierPathMarker around (-4500,.12,153). Server-read
   world Objective advanced to dodge_warning; no server mutation used.
4. First dodge input did not complete the objective. Observed visible warning,
   moved A for .7s, then waited for validation. Server-read Objective advanced
   to help_courier; UI checked movement and warning objectives.
5. Walked A back to courier, closed menu and pressed E. Claim 100 XP changed
   from inactive to active after the real objective completion.
6. Clicked Claim 100 XP. UI advanced to Chapter 2 / 6, A Borrowed Weapon, with
   basic attack, area dodge and practice captive objectives.

PASS for this first ordinary-input chapter route and chapter transition only.
The button's reward label was observed; exact numeric profile XP was not read.
No class trial, Greenwood traversal, five-hero combat, full quest chain,
multiplayer, saved persistence or device acceptance follows from this result.
The earlier decorative/animation fixtures were not used to complete objectives.

## Chapter two continuation

In the same uninterrupted Play session, closed the Guild menu, walked to the
active Practice a basic attack prompt around (-4435,3,90), and pressed E.
Normal game flow entered the training arena. Pressed F once; actual trial HUD
reported Basic hits 1/1 and chapter objective advanced to Dodge the area attack.
Clicked Leave trial to return to the course. Moved clear of its visible warning;
the Rescue the practice captive prompt became enabled at (-4420,3,86).
Walked into range, pressed E, then reopened the Guild menu. Claim 100 XP was
active. Clicking it advanced the UI to Chapter 3 / 6, The Caravan's Debt.

PASS for ordinary-input chapter-two transition, including the real basic-attack
lesson. No combat hit, objective or progression was injected by the test. This
still does not certify every combat class, damage amount, rewards persistence,
later chapters or the complete Map + GUI + five-hero journey.

## Chapters three and four continuation

Walked to CaravanTracks, chose Rescue the travelers with E, then walked to the
remaining supplies prompt and completed its fallback action. Clicked the active
100 XP claim button; UI advanced to Chapter 4, The Crossroads Keeper.

Walked to the keeper prompt and entered its normal training encounter. First
attempt failed: PlayerHealth=0, EnemyHealth=16, TrialStatus=Failed and
TrialProblem=TrialDefeated; no victory objective granted. A second attempt's
lateral movement drifted outside basic-attack range and displayed Move closer
to your target; left that attempt. Third attempt used ordinary F at approximately
1.15-second intervals and Q every six intervals, without positional or combat
state mutation. Actual arena replicated PlayerHealth=21, EnemyHealth=0,
TrialStatus=Won, ReceiptDelivered=true and Defeat the opponent 1/1.

Clicked Leave trial, walked to Free the captive and Inspect the false guild
crest prompts, pressed E at each, then clicked the active 100 XP claim. UI
advanced to Chapter 5 / 6, Before the Oath, offering five class-training
objectives and a 50 XP claim. This confirms the observed fail/retry/win and
chapter advancement path. It does not certify moving-combat dodge proficiency,
all class trials, numeric saved XP, physical devices or multiplayer.

## Five class introductions

Continued by walking to Five Disciplines and entering each class introduction
using E, pressing Q, then Leave trial. Each actual arena returned Skills used
1/1, TrialStatus=Won and ReceiptDelivered=true:

| Class | Ability | Target health after accepted action |
| --- | --- | --- |
| Priest | Heal | 700/700 |
| Mage | Fireball | 654/700 |
| Archer | Piercing Shot | 668/700 |
| Knight | Taunt | 700/700 |
| Warrior | Power Strike | 668/700 |

These were ordinary-input introductions; non-damage actions correctly did not
reduce dummy health. Clicked active Claim 50 XP; UI advanced to Chapter 6 / 6,
The Right to Found a Guild. Entered the Warrior solo trial to inspect its actual
goals: three basic hits, defeat a 700-health Sentinel and dodge one warning.
Left that trial without claiming completion. Class selection and chapter six
remain pending. Introduction completion is not full solo-trial acceptance or
five-class visual-quality acceptance.

## Mage solo trial and first-class confirmation

Selected Mage through its existing course prompt and entered the full solo
trial. Early attempts failed or were left; one recorded failure had enemy HP76
and player HP0 despite meeting skill/dodge counters. A later attempt used only
ordinary Q/F presses and lateral A/D movement triggered by the visible committed
warning. Faster observation/input cadence reduced missed warning windows.
No health, enemy position, damage, cooldown, objective or receipt was injected.

Actual successful arena attributes: Mage, TrialStatus=Won, ReceiptDelivered=true,
EnemyHealth=0/700, PlayerHealth=36/47; Sentinel defeated1/1, Skill hits3/3,
Warnings dodged1/1. Left trial and opened Guild menu, which showed Trial passed:
Mage. Clicked Choose this class, then the explicit Confirm first class button.
This is isolated Memory first-class selection, not a production save change.

## Chapter six completed: guild and first companion

Walked to Clear the abandoned Hall alone and entered its normal Mage encounter.
Used Q/F and reactive A/D warning movement. Actual result: Hall Sentinel health
0/360, player HP47/47, TrialStatus=Won and ReceiptDelivered=true. Left trial,
walked to Register your personal guild and pressed E. Guild UI offered the
free level-10 companion choice. Kept Warrior, clicked Found guild with Warrior,
then Confirm free guild founding.

Actual post-confirmation state: CurrentZone=Guild, character position near
(0,4,23), UI 0 Gold / Hall Lv1 and Personal Guild / Hall Lv1. Replicated actual
player model: ClassId=Mage, Level10, XP450, WeaponId=mage_staff. Owned Warrior:
Level10, WeaponId=training_sword, PartySlot1, HeroState=Following. Other owned
class models were Available at level1; these are not claimed as an active
five-hero party. No production persistence or currency writes were performed.

This completes the observed six-chapter ordinary-input onboarding route in this
single unsaved Memory session. It does not certify rejoin/save persistence,
mobile inputs, multiplayer, every class's full solo trial, or the later
quest-to-Greenwood-and-five-hero combat journey. Roof-corrected source and 14px
tracker commits were integrated on disk during this run but are not the place
version used for this onboarding evidence.

## Post-novice campaign: first companion and city supply delivery

Continued the same isolated Memory Play session through ordinary mouse/keyboard
inputs, with read-only attribute observations. At FounderTable near (-23,2,-12),
R completed meet_founder (E instead opened nearby hero inspection). Saved the
existing equipped Warrior party, selected the companion with T and issued G
Regroup. Guild CampaignJourney showed all three chapter-one objectives checked.
Clicked CampaignClaim: player Mage XP550/Level12 and Warrior Level12; UI advanced
to The Empty Table, guild chapter 2/12, and 15 Gold was visible.

Visited Tavern, Hall and Workshop gold markers with R. Enabled objective then
became SupplyPickup in City. Initial direct west/north navigation encountered the
Hall wall and left the island edge; recovery returned the player to the guild.
This is not evidence of a seamless or well-signposted path. The actual successful
walk used the south Hall exit near (0,4,23), east to x62, north across the bridge
at x64 to z-65, then west along IslandPromenade to the Central City portal.
Pressed E: CurrentZone became City, player (0,3.698,-720), Warrior approximately
(0.117,3.699,-716). Companion travel succeeded without teleport/profile injection.

A west-first city approach hit a building at z-730. Returned to central x0,
walked north to z-789, then west to x-98. Waited for Warrior to follow into range,
pressed R at SupplyPickup (-100,1.2,-790): enabled prompt changed to
SupplyDelivery (-100,1.2,-835). Walked north to (-97.901,3.698,-833.807), waited
for the companion, pressed R: enabled prompt changed to Guild TeamTable
(-23,2,-12). This verifies actual city supply collection/delivery and companion
proximity gating. Chapter-two recruitment/reward and Greenwood combat are still
pending. Active Memory session is preserved at the delivery location.

## Chapter two claimed; two companions reached Greenwood

Returned through City's Guild portal with ordinary movement/E. Used R at the
TeamTable. All chapter-two objectives checked; chose Priest and confirmed the
free recruitment through two CampaignClaim clicks. Player Mage and founder
Warrior became Level14, player XP650. New Priest h:1 is Level10 with
apprentice_staff. Initial Add-to-party click targeted a button below the viewport
(y1079) and did not select it. Scrolled the actual UI down eight wheel steps,
clicked Add to party at visible y341, scrolled back, observed Selected:2/5, and
saved. Server now has Priest h:1, PartySlot2, Following, CombatHealth51. This was
an input/scroll issue, not established hero-spawn failure.

Walked the east bridge route again, E traveled City, then walked the central
street from z-720 to Greenwood portal near z-1450. E set CurrentZone=Greenwood
and player root (0,5.078,1505). Both Warrior and Priest followed. Walked to first
tracks near (0,5.078,1480.739), pressed R; second tracks near
(-28.767,5.058,1451.882), pressed R. Actual campaign advanced to focus_escort.

Focus acceptance remains unresolved. Selected Warrior through Actor2 and sent
Focus/Regroup through actual HUD buttons/keys near ScoutCamp; model order attrs
change and InCombat=true, enemies take damage and respawn, but campaign stays
focus_escort (DeliveryProblem=OK). One exact server read-only LOS ray from
Warrior root+1 (-59.148,6.05,1422.879) to living scout root+1
(-49.012,6,1436.311) returned no collision using production ray parameters.
Other attempts occurred while scout was dead and cannot prove a failure.
Target.active/hostile-space/runtime focus evidence still needs diagnosis; no
server combat gate was weakened, no quest progress injected. Actor.focus is a
valid projection of focusTarget in HeroService.CompanionEvidence; a field rename
is not justified. Preserve live Memory session near (-53.11,5.048,1422.901).

## Greenwood escort completed and chapter-three reward claimed

Continued real HUD Focus inputs while observing the server objective. A Focus
input against a live target advanced focus_escort to regroup_escort. Regroup
inputs during the next active fight advanced to finish_escort. Earlier accepted
orders were insufficient evidence of a selected live target or active fight;
no source bug was established and no combat/campaign gates were changed.

Issued ordinary player/Warrior Q/F actions and kept both companions nearby.
Observed actual Warrior DamageDealt663 and Priest DamageDealt759 cumulatively
across the repeated fights (not a single-kill damage claim). Scout health reached
zero. R from the earlier position did not finish; moved south approximately
7 studs to the actual EscortFinish marker and pressed R. Server campaign
Objective became nil with text Claim chapter rewards in the Guild menu.
Clicked native CampaignClaim: UI advanced to Woodland Debt, chapter4/12 Lv16.
Actual player Level16 XP753, MaxHealth65, DamageDealt63 and AbilityCount1.

This verifies the real same-session guild UI/party -> travel/map -> two-companion
regional fight/orders -> objective submission -> server reward -> GUI update
journey. Repeated scout kills were involved; this is not a clean first-attempt
UX acceptance, multiplayer/save/mobile acceptance, or latest-art acceptance.
Current Play still uses the earlier optimized roof mesh and 12px tracker.
Navigation review found direct destination arrows can suggest wall/void paths;
S14 has been assigned native next-waypoint guidance within its existing exclusive
scope, with real Hall/bridge/road anchors and subsequent controller walk testing.
