# Chapter 00 domain foundation — 2026-10-03

Six chapters now have a bounded, versioned server-domain state machine. This is not yet a playable world journey: main bootstrap still uses the legacy profile and does not register the Novice dependency.

## Implemented

- MAIN_00_01–05 teach courier interaction, movement/dodge, borrowed-weapon practice, caravan rescue/supplies choice, crossroads keeper and five class previews. Twenty objective IDs cover all six chapters. Story beats are ordered; the five class previews can be completed in any order.
- Candidate balance grants 100/100/100/100/50 XP across the first five chapters. Existing 50 XP per level gives level 10 at 450 XP. Both caravan choices require a follow-up and grant identical progression. These numerical rewards are implementation candidates, not final playtest balance.
- A server-only trial receipt for the chosen class is required before class selection. Selection grants/equips its starter weapon once.
- MAIN_00_06 requires class selection, abandoned-Hall clearance and registration, then grants Hall 1 and one freely chosen root-class hero at level 10/450 XP/rank F, with a starter weapon and party assignment. It charges no Gold or Robux.
- Chapter claims and guild founding are typed public intents. Objective and trial receipts are absent from the public protocol. Private receipt commands include their arguments in replay/conflict identity. All mutations use the existing candidate/commit/recovery path when the optional dependency is supplied.
- Opt-in schema 8 can require story validation. It rejects skipped, unknown, missing or cross-ruleset story state. Migrated legacy records retain no Novice story and receive no grants.

## Evidence

476 full domain tests pass, including seven new story tests. Coverage includes all 25 player/hero class pairs, both caravan branches, capacity failures, duplicate claims, rejected client receipts, lost-response recovery on every objective/chapter, request conflicts and close/rejoin preservation. The 5,000-order market simulation remains at zero invariant violations.

Roblox-native synthetic records passed 50 class/hero/branch paths and 1,450 JSON encode/decode round trips with no real profile writes. Strict analysis, compile, main/offline builds and 198 runtime file checks pass. Evidence: `validation-novice-story-domain.txt` and `validation-novice-story-native.json`.

## Required before enabling

Bind objective receipts to server-observed world interactions, ordered route checks, genuine dodge/attack outcomes, solo class trials and Hall combat. The Chapter 00 environment and bilingual UI prototypes, access gates and tutorial routing now exist; connect them to the genuine world/trial adapter. See NOVICE_JOURNEY_UI.md and NOVICE_TRIALS_AND_GATES.md. Complete actual-input progression, save/reconnect acceptance and balance testing. Current receipts are exercised by isolated fixtures, not by a player completing the story. No cloud game was published.
