# Website handoff snapshot — 2026-10-14

Scope: inventory the existing Guildborne game for ChatGPT Web and checkpoint the user's latest local code, assets, reports and tools on the existing branch. No runtime behavior was edited by this documentation task. Pre-existing implementation is included as a candidate snapshot, not declared independently release-approved.

Fresh local checks:

- `tools/setup_tools.ps1`: pinned tools prepared successfully.
- `tools/validate.ps1`: PASS, 752 Luau tests; Rojo build/sourcemap, Roblox-aware analysis, compilation, repository/built-place boundaries and whitespace checks passed.
- `python -m unittest discover -s tests/agentic -p "test_*.py"`: 177 tests run, OK with 5 skipped (172 not skipped).
- Forge doctor: Git/Python/Codex available; Blender binary not found by doctor; Studio/image capabilities were not exercised here.
- Forge validate/plan: PASS, 39 tasks and 31 skills; planning does not execute game/tool acceptance.
- Reconciliation: 502 asset entries, 73 screens, 89 kit entries, 402 hashed files, zero missing references; sourceApproved remains0. Counts do not establish final assets.
- Character contract: PASS, 89 planned entries and 15 required core parts; not fit/import acceptance.
- Studio metadata validate/verify: PASS, 33 roles, 39 tasks, 10 workflows, 98 generated files. This is agent metadata validation, not a Roblox Studio playtest.
- Changed/untracked-file credential-pattern scan: 257 files, no matched private-key/OpenAI/GitHub/AWS credential patterns. This bounded scan is not a complete security audit.
- Independent read-only feature-source review identified one wording correction: hero identity exists, but bond/personal stories remain planned. Corrected in the brief.

Raw local command logs are copied byte-for-byte beside this report. They were run against the dirty source candidate before the snapshot commit; they are not clean-commit Forge receipts or a submitted/accepted evidence packet. Subsequent task edits are handoff documentation, copied logs and whitespace-only normalization of six research Markdown/JSON reports newly added to Git. JSON values were verified unchanged. Original kit intake and raw evidence streams were not normalized. The first normalization attempt failed on local text encoding before edits; the UTF-8 retry succeeded. Final staged whitespace validation passed.

Coordination: the default ledger rejected the changed plan. The existing matching shared `build/agentic/launch-v11-ledger.sqlite3` was inspected and the `audit` task claimed for `production/audit`; no old ledger was reset or active session stolen. Read-only source review used one subagent. No Studio/Blender mutation occurred.

Remaining acceptance: normal all-class/hero Lv35 journeys, Party6/shared PvE implementation, real imports/clothing fit/audio, cloud/save/rejoin, 2/4/6 clients and mixed encounters, physical Android/iOS, human art/UAT and scoped release decisions. No merge, Roblox publish or live commerce activation occurred.
