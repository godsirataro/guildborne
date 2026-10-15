# Expansion implementation increment — 2026-10-14

The twenty-theme attachment is archived in ../source-proposal.txt and reconciled in ../EXPANSION_PLAN.md. Ten design contracts and ../features.json retain ownership, release classification, dependencies and truthful public-copy status. Three scoped jobs bring Forge to 45 definitions; Studio validates 33 roles, 31 skills, 10 workflows and 98 generated adapters. Job definitions are not completion counts.

Implemented source: bounded Balanced/Defensive tactics, server-position Hold, role-based Regroup, native English/Thai command feedback; sanitized eight-milestone per-session analytics through the existing adapter and committed-event hooks. No persistent schema change, external analytics enablement, shared reward redesign or new damage authority. Worker evidence: ../evidence/tactics.md and ../evidence/analytics.md.

Fresh tools/validate.ps1: **775 tests passed**, Rojo build/sourcemap, Luau analysis/compile, repository validation and diff checks passed. Raw output: validation.log. Focused checks are included in that count, not additional tests. Reconciliation found zero missing references; character contract passed planned definitions only.

Local Memory candidate built: build/Guildborne_LaunchPreview.rbxlx SHA256 e396c1b6eac4da04b284332a22333ae4f03b4059031394d2ce5dc3549a2d781e. Raw build output: build.log. This candidate is **BUILT_NOT_STUDIO_TESTED**. Current MCP discovery returned only Guildborne - Staging, Place86788611613035; the previous local preview instance was absent. No staging mutation or publishing was performed.

Pending runtime checks: Hold→telegraph evasion→return, role formation around obstacles, death/travel/mentor cleanup, real native command strip at mobile widths, normal-session milestone hooks. Pure tests do not pass these. Real 2/4/6 clients, shared travel/encounters/conserved settlement, cloud saves, physical devices, imported assets/audio, commerce and human UAT remain launch gates.

Next dependency-ready increment: runtime acceptance of these commands and FTUE clarity, then first three-role combo prototype; mandatory shared PvE authority/settlement proceeds without waiting for optional Bond/Research/website. See design contracts for exclusions and acceptance. No completion percentage or Public-ready claim is made.

Independent plan reconciliation was returned by policy_review. Final source review of tactical/analytics integration was requested but has not returned a verdict at this checkpoint. Therefore this increment remains REVIEW, not accepted or release-ready. No skill promotion was attempted; lease release is coordination cleanup, not acceptance.

## Follow-up: session lifecycle fixes

The prior review checkpoint above is historical. Independent review found and this increment fixed three issues: load completion after disconnect could create an orphan funnel; queued combat observations could be attributed to a replacement Player; synchronous Product callbacks could yield the gameplay caller. Bootstrap now verifies live identity after Load, combat captures its original Player before deferring, and Product snapshots sanitized fields into a protected queue capped at32. Existing business Emit behavior is unchanged.

policy_review returned scoped source PASS for all three fixes, independently reran seven analytics tests and the extracted actual-source Bootstrap fixture. The fixture checks disconnected/replacement load, null/stale/current observation, deferred combat rejoin rejection, absent Player and queue capacity. This is local simulated dependency evidence, not Studio acceptance. Raw: bootstrap-lifecycle.log; reproducible extractor: check_bootstrap_lifecycle.py.

Reviewed hashes: Bootstrap 4029db8f6a1f5474ca1a0ecbd9f6506ec1d8fac81952937f1f728bba4bb632e9; Adapter 3c318e9aeea02d9433de508dbe98080fb4c744151b2508e91da575b5772e1c42; CombatService 4c473e123b46c57f13fdfb91e81c55bfda10445cdc77d13cf092daf0a41862fe. Tactical scoped review also passed; actual movement/UI remains pending.

Lesson: pcall catches errors but does not prevent yielding. Capture original session identity before asynchronous dispatch; checking only the current userId mapping at delivery cannot reject an old-session event. Keep outstanding analytics work bounded and test disconnects during yielding Load. This lesson is evidence-backed locally, not an automatically promoted skill.

New local Memory candidate SHA256 258a4d32fc6cbd4b72373738b51345a9830246d4e12e8063de3720edf7365858; build-session-fix.log records generation. Previous candidate evidence is not transferred to it.

Full post-session-fix validation passed **777 tests**, build, analysis, compilation and repository checks (validation-session-fix.log). Opened that local candidate through the registered file association; Studio confirmed Place0/Game0, Memory and analytics=false. Play boot emitted one session_ready milestone, client ready, and normal Begin button opened the game UI. Console captured in studio-session-fix-console.json. This is boot/UI evidence only, not the full quest route.

Actual UI inspection exposed Hold[J] colliding with the existing quest tracker[J]. Changed Hold to K and retained gamepad DPadRight. Six tactical checks (including J absent/K Hold/hint K) and scoped analysis passed after this small delta; full777 suite predates only that binding/test/docs delta. Rebuilt candidate90a6ef83c84e95ed03063a27bf18ebfae9066eb96a5629b923f6af809d96f060 (build-final.log). Updated only CombatBindings in the already-open local candidate, restarted Play and verified native text Hold[K] alongside quest[J], plus normal boot again. This was a targeted source sync, not a fresh all-script byte comparison. Raw key result: studio-key-fix.json. The local window is left in Play for inspection; Staging was untouched.
