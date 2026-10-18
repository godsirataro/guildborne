# Native novice chapter presentation

Worktree `C:/Work/MySelf/Guildborne-novice-ui`, branch `codex/novice-quest-ui`, base `9ae9662`. Shared v5 ledger only. Studio remained controller-owned; no scene/profile/server mutation, network installation, spending, push, PR, merge or publishing.

## Visible change

The Guild novice card now presents a navy chronicle header, actual localized chapter title, brief EN/TH narrative based on existing objectives, a six-chapter claimed/current/upcoming trail, and an ivory objective body. Completed objectives keep their checkmark and muted text; current progress uses the actual receipt count. One thin outer rim and the existing primary-action treatment provide emphasis, without framing every objective.

Objectives precede the reward/action. Incomplete chapters show the real reward as **On completion** and a smaller disabled **Complete the objectives first** control. Ready chapters keep the actual Claim XP action. Ready-but-underlevel shows the required level; busy/pending displays waiting and blocks duplicate activation. Claimed trail state changes only from the server snapshot. XP remains 100 for chapters 1–4, 50 for chapter 5; chapter 6 retains class trial, class selection and guild founding instead of an invented XP claim.

Explore closes the existing management panel through the same visibility flow used elsewhere. Its context text tells players to reopen Guild menu to return. Existing post-chapter-six Guild routing is unchanged: the complete-card fixture does not imply a new live completion screen.

Visual reference inspected locally: `design/guildborne-gui-production/03_REFERENCES/08_QUEST_JOURNAL.png`, alongside `docs/uat01/UI_ART_GUIDE.md` and the art bible. Native palette/fonts remain existing Theme tokens. No images/fonts/asset IDs were added or fabricated. This is authored native layout, not a pasted reference screenshot.

## Source ownership

- `src/client/UI/Components/NoviceChapterCard.luau`: presentation adapter around existing NoviceJourneyView and NoviceJourneyViewState. Original class/founding confirmation closures and canonical action payloads remain the only action owners.
- `src/client/UI/SliceUI.luau`: replace only novice factory binding and pass the existing panel-hide Explore callback.
- `tests/gui/novice_chapter.luau`, `tests/gui/run.py`: focused behavior coverage and optional `--suite novice`.
- `tests/gui/novice_chapter_review.client.luau`, `tests/gui/build_novice_chapter_review.py`: disposable native preview.

NoviceJourneyView, server/config, trial controller, quest rules, IDs and reward data were read but not modified. New story captions are presentation copy based on the existing objectives, not additional quests or mechanics.

## Verification performed

- `python tests/gui/run.py`: **57 cases passed**, comprising previous 47 and 10 novice cases. They cover objective-before-action hierarchy, actual rewards/partial progress, ready versus eligible, busy and duplicate guards, server-confirmed advancement, original two-click class/founding confirmation, companion-change reset, class and founding inventory-full gates, trial-class change reset, responsive text properties, destruction cleanup and unavailable data. This simulation does not render fonts or AutoSize.
- Scoped luau-lsp passed for NoviceChapterCard and SliceUI using the default-project sourcemap, and the native fixture using its isolated sourcemap. Initial sourcemap generation needed creation of the fresh worktree's build directory; the successful rerun is the reported check.
- Rojo preview build passed. XML assertions confirmed one LocalScript and no server Script or RemoteEvent/RemoteFunction/UnreliableRemoteEvent.
- `git diff --check` passed. No full game baseline was repeated.
- Independent source review found no production blocker. Its fixture observation-generation correction was applied: stale delayed callbacks cannot label newer rendered contents with an earlier size/state. Reviewer-requested foundation capacity and class-change regressions were added and passed.

## Preview and controller acceptance

Output: `C:/Work/MySelf/Guildborne-novice-ui/build/novice-chapter-review/GuildborneNoviceChapterReview.rbxlx`

SHA256: `c83a8c701e46034d0268a64d2ec288d601bddf7f4ee62fe7cbfb4420aba596af`.

Rebuild with `python tests/gui/build_novice_chapter_review.py`. Open locally and Play. Toolbar provides EN/TH, ten state presets, chapters 1–5 (chapter 6 through Trial/Class/Foundation presets), widths 728/390/240, synthetic long-copy toggle and 1:1/Fit. The canvas uses explicit scaling; it is not physical-device proof. Scroll the native content to actions. Explore offers a local Guild menu return control.

The fixture uses the actual adapter, original view/state and a cloned catalog. Long copy is clearly synthetic; all intents are captured as attributes/logs without remotes or profile writes. Claim intentionally remains pending until changing a fixture state, since no server exists to respond. `NOVICE_NATIVE_OBSERVATION` / `NOVICE_TEXT_NOT_FIT` logs are emitted only when the controller actually runs it; no observations are claimed in this packet.

Required native checks: actual ordinary chapter 3 before/after; EN/TH incomplete/ready/underlevel/busy; confirm objective ordering and honest reward text; long title/objective wrapping and scrolling at all three widths; class and founding two-click flow; all five hero choices on the narrow grid; Explore/return; repeated rerender/destroy without duplicated input. Foundation labels have 52px buttons with existing internal padding, so minimum-width TextBounds require particular attention.

Status: **local implementation / file generated / local checks passed / independently source-reviewed**. **Studio rendering, native input, screenshots, device performance and human art acceptance remain NOT_RUN by this worker**. The rbxlx is the visual review artifact; no screenshot evidence is fabricated.
