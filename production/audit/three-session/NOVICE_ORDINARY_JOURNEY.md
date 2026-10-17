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
