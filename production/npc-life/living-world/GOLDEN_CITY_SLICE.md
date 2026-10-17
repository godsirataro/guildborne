# W1: Smith Borin / Work That Lasts

Status: scoped contract implementation first; visible world integration and acceptance remain pending.

Use canonical NPC `smith_borin`, FriendlyNpcs X=370/Z=-958. Y/root orientation must come from the existing spawned model/ground logic, not a fabricated coordinate. Keep existing model, prompt, `NpcId`, `QuestNPC="Smith Borin"` and station reference. Do not relocate the actor when a schedule phase changes.

Existing quest: `borin_castings`, prerequisite `first_ingot`. Player accepts and crafts two iron ingots afterward in their own guild forge; use existing acceptance/progress/claim and retain all authoritative reward values. Actual operations route through SettlementService and current profile commit/receipt mechanism. Never grant materials or Gold just to make a journey appear complete.

## Controller integration contract

1. Consume S17 pure definitions as metadata. Resolve legacy Journal aliases through exact FriendlyNpcs entries and actual server catalog; unknown hooks remain unavailable. No new secret actions.
2. At spawn bind the actual root to its canonical identity. Keep the existing anchor reachable even at night/far relevance. Schedule activities at that anchor until S13 approves paths and fallbacks.
3. Sample schedules in one bounded server coordinator with a reviewed clock. Do not make per-NPC scripts, timers, path loops or persistent position records. No client schedule value authorizes rewards.
4. S15 integrates schedule work/rest and interaction/recovery into the single existing animator. BorinWorkMotion continues owning Borin's motors/contact cues. Never layer another motor writer over it. Distance relevance changes visual effort only.
5. Existing server prompt/distance/session checks authorize conversation intents. UI renders committed Journal state in TH/EN. Talk interruptions cannot change quest eligibility or rewards.
6. Keep new metadata out of saved profiles. Runtime wiring, actual cadence and performance budgets require measured integration tests.

## Actual gameplay checklist — all NOT_RUN for this candidate

- Identify exact reviewed build, Studio instance, PlaceId=0/GameId=0, Memory persistence and empty cloud allowlist; Controller alone owns Studio.
- Observe Borin work, approach normally, open TH/EN dialogue, confirm work fades while speaking and safely resumes afterward.
- Meet `first_ingot` legitimately; accept `borin_castings`, pin it, traverse city-to-owned-island, craft twice, return and claim once. Capture authoritative before/after Journal/inventory/Gold/XP, not UI-only text.
- Reject distant/foreign/duplicate/stale/invalid interaction and claim. Test uncertain commit/rejoin using the established isolated persistence fixtures; Memory restart is not durable reconnect proof.
- Test two players speaking, one leaving, actor removal/re-addition, far/near transitions, reduced motion and interrupted work. No duplicated effects or listeners.
- Traverse the route with five genuinely owned companions; label any seeded roster fixture. Verify doors, root height, collision and map routing.
- Profile actual rig/path/instance/memory counts and frame times under representative load; no FPS claim from proposed population budgets.

Studio, multiplayer, physical Android/iOS, real imported appearance fit, and human art/feel approval remain distinct pending evidence. W2–W5 retain the full user scope but cannot be promoted from this contract slice.
