# Chapter 02 / Ironveil implementation contract — 2026-10-04

Source: `intake/QUEST_CATALOG_DRAFT.json`, MAIN_02_01–06. These are design proposals, not executable instructions. This contract continues the authorized first-release scope; no cloud release or paid dependency is introduced.

Chapter01 now has an actual fresh run through Hall2. Chapter02 must preserve its completed state, founder/recruit identities and all earned XP. A new local profile begins the arc only after claiming recognition and actually paying the Hall2 upgrade. Existing expedition/market IDs remain intact.

| Quest | Server evidence to implement | Local reward candidate / gate |
| --- | --- | --- |
| MAIN_02_01 / Unequal Weight | Inspect three scales, interview the carrier, enter Ironveil | Lv20/Hall2;100XP,60Gold; no actual market trade |
| MAIN_02_02 / Knocks Below | Read a visual signal, choose a safe shaft, rescue a trapped miner | Lv22/Hall2;150XP,60Gold; audio never required |
| MAIN_02_03 / The Last Support | Inspect cracks, protect the engineer, complete a selected safe repair sequence | Lv25/Hall2;150XP,60Gold; Hall3 permit;12timber/16stone/8iron_ore |
| MAIN_02_04 / Two Inks | Obtain revealing reagent, compare seals, choose workers/council joint review | Lv28/Hall3;100XP,120Gold; equal mechanical rewards |
| MAIN_02_05 / Keeper of the Mine Key | Operate the mechanism, defend the NPC, defeat the guardian and return its key | Lv30/Hall3;250XP,120Gold; Hall4 permit;18timber/24stone/12iron_ore |
| MAIN_02_06 / A New Crest in Familiar Hands | Meet the Class2 mentor, submit evidence, try an eligible borrowed path without forced commitment | Lv35/Hall4; no duplicate stat/skill points; Ashen story access intent |

At the existing50XP/level curve, the minimum character XP goes950→1050→1200→1350→1450→1700. At Hall2 the third reward banks XP while level remains25; buying Hall3 releases level28. At Hall3 the fifth reward banks XP while level remains30; buying Hall4 releases level35. Do not discard banked XP or require a level beyond the current Hall cap before granting its permit.

Baseline Gold after Chapter01/Hall2 is20 without extra fights. First three rewards add180; Hall3 costs160, leaving40. Next two add240; Hall4 costs240, leaving40. Materials above match the existing Hall upgrade tables. These are explicit balance candidates, not final economy tuning. Other earned loot/XP remains valid and unmodified.

Implementation must support additive campaign continuation without invalidating the prior version1 six-quest checkpoint. Recognition art remains available after later quests. Hall eligibility uses earned permits for this optional Novice arc; legacy profiles retain their established quest gates. Class2 tests need the existing real path/ability catalog reconciled before any trial is accepted. A generic interaction marker alone cannot stand in for an NPC rescue, repair puzzle or class trial.

World/art work: readable scale yard, shaft entry, shoring gallery, document desk, guardian mechanism and training camp; miner/engineer/carrier NPC roles, visual signal sequence, cargo/key props and fail/retry feedback. The existing Ironveil surface map and combat can be reused where their geometry and encounter rules fit. Underground additions and actual moving-NPC protection remain to be implemented.

Current status: six quests bound in an explicit memory-only Ironveil preview and completed from a fresh profile through revision108/Hall4/level35. Main runtime stays disabled. Ordered private receipts, moving rescue, visual puzzles, safety shutters, party guardian and borrowed Elementalist trial have actual desktop evidence. All ten borrowed paths separately pass shared real-ability simulations. See IRONVEIL_ACCEPTANCE.md for evidence and remaining acceptance limits.
