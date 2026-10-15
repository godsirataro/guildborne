# Actual two-client shared reward observation — local e804

Scoped independent evidence review: PASS by policy_review. Candidate SHA256 `e804fcda68202968fce5af6123d1c209c8e86f54c0f2f53bc4e36f141fe242c6`; 377 sources matched in both local Edit and dedicated server. Full baseline:871 tests and all automated checks. Local Place0/Game0, Memory, analytics disabled; Staging unchanged.

Two real Studio clients (-1/-2) earned all six Novice steps, Warrior class trials and free Hall founding. Native prompts/claims/confirmation UI were used with Humanoid MoveTo and ordinary client TrialInput Basic/Ability/Return requests for combat. No profile, HP, objective, cooldown or clock edits. Both began the shared test at revision28, characterLv10/450XP, Hall1 and one earned Lv10/450XP hero: Priest for Player1, Warrior for Player2. This replay is automation-assisted gameplay, not human UAT or a fully native-input acceptance run.

The operator explicitly placed both owners into the isolated candidate lab and saved their original pivots. This is not natural shared travel. HumanParty members were empty: two independent owners shared the same135HP scout. The following Priest and Warrior had observed damage totals36 and99. These counters and current hero status are supporting observations; lifetime healing totals are not fresh encounter-only contribution evidence.

The scene reached Completed and RewardStatus Delivered. The actual Bootstrap PlayerDataService emitted two CommitSharedPvE saves at revision29. Each hero changed450→451XP; both characters stayed450XP. Gold changed0→1 and0→2. The configured one-enemy pool was exactly2XP/3Gold; no reward multiplication occurred.

After restoring original pivots, entering the completed scene again and sending three ordinary Basic intents per player, fresh views remained revision29, heroXP451 and Gold1/2. Both players had HP57/WalkSpeed17/JumpPower50. This is bounded no-second-payout evidence for one completed scene, not a direct receipt replay, logout/rejoin or process-crash test. Private receipt internals were not exposed; separate synthetic real-PDS fixtures cover those local receipt/reconstruction paths.

Original pivots were restored again, fixture globals and client drivers cleared, and the owned server/two clients ended. MCP inventory then showed only local Edit preview and untouched Staging. Memory data ends with the session.

Raw evidence (unchanged):
- `shared-e804-earned-before.json`
- `shared-e804-earned-after.json`
- `shared-e804-reentry.json`
- `shared-e804-console.json`

Remaining: native shared entry/return, mixed Party/Solo populations, four/six-owner companion load, repeated encounters, actual offline contributors/uncertain delivery, cloud/process durability, physical devices and human acceptance. No Public-ready claim.
