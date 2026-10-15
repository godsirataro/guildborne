# Novice local Studio identity compatibility

Actual two-client Studio observation: both negative-ID Players completed chapter one through normal objectives/claim (revision5, Lv3). Practice prompt triggered but the lesson did not open. Source identified positive-only owner validation in both lesson and first-class trial constructors. This is a compatibility failure, not evidence of a successful chapter-two trial.

## Change

Pure `StudioTrialIdentity(context, ownerId, isCurrentOriginalPlayer)` produces an exact-owner predicate. Negative finite nonzero integer IDs require every explicit fence: `IsStudio==true`, `PlaceId==0`, `GameId==0`, `PersistenceMode=="Memory"`. The current-original-Player callback must return true without errors or yielding. Zero, fractional, nonfinite, malformed and different-owner IDs fail. Positive defaults in Trial/Lesson constructors remain unchanged when no policy is injected.

Root Bootstrap supplies `TrialIdentityContext` to Course from actual trusted server environment. Course binds each predicate to the actual Player object using Players:GetPlayerByUserId and Parent identity. No client flag or public action changes. Borrowed LessonFactory receives the predicate; manager obtains per-player TrialsFor, and the arena receives the predicate as optional ninth argument for its default first-class simulator. Existing option-based later-game arenas retain their own factories.

Audit: TrialInput already validates exact sender, bounded action shape and rate, without positive-only ID validation. NoviceReceiptAdapter and PDS.CommitNovice use the exact owner/session key and immutable receipt transaction; no additional positive-ID restriction found. Their code is unchanged. Solo distance, server-observed movement, cooldowns, eligibility, objective order and receipt gates remain active. No profile, XP, HP, timer or proof was edited to advance the route.

## Evidence and pending acceptance

Four focused pure tests cover default compatibility, every environment fence/current-object callback failure, real negative-ID practice combat and exact receipt owner, plus first-class trial evidence/solo gates. Logs: `build/novice-identity-tests.log`, `build/novice-identity-analysis.log`, `build/novice-identity-compile.log`.

Actual restarted two-client earned journey is pending root Studio validation; source tests do not establish that acceptance. No publishing, cloud writes or runtime flag mutation in this scoped task.

Independent policy review reran all four focused tests and found no source blocker. Scoped Luau LSP and compile passed; actual Studio journey remains pending.
