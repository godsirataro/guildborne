# Novice chapter card — initial native review

S14 bde2f31 and 0b5e481 independently source-reviewed, integrated as 941f1e4
and 3ab6609. Controller reran all 57 GUI simulation cases successfully and built
the isolated preview, SHA256 146d17aa0c3e322153152d304adffe41de628bddaa6e72de7b0ae9f5677c6dc4.
Full combined baseline awaits the delivered Map integration.

Studio f1affd20-99ba-48a9-9573-e60f50ddeab7 opened that preview. Edit inspection
found one LocalScript, nine modules, zero server Scripts/remotes, PlaceId/GameId0.
Actual Play captures inspected: novice_chapter_initial_v5,
novice_chapter_thai240_long_v5, novice_foundation_thai240_scrolled_v5.
These are tool-visible captures, not archived PNGs.

Native EN initial chapter3 and TH synthetic long-copy at logical240x500 scale1
rendered with no TextFits failures. The long-copy canvas reached689px. TH
Foundation at that size had861px canvas and all five companion labels fitted.
Mouse-wheel scrolling reached361px, exposing the choices and confirmation.
Actual clicks selected Knight, Mage, Warrior, Archer and Priest. First founding
click showed confirmation without dispatch; second captured FoundNoviceGuild /
Priest. This was a synthetic fixture intent, not an awarded companion or guild.

Initial harness limitation (corrected below): redraw cleared contents and reset scroll to0 after
selection/first confirmation. Early batched clicks therefore missed offscreen
controls; later runs scrolled again and waited for layout before clicking. Failed
attempt observations remain in novice-card-native-v5.json. Production SliceUI
uses ScrollRetention before clearing; this fixture does not, so its scroll reset
does not by itself establish a production defect. Bring the harness in line with
that production behavior before broader native acceptance. Do not count the
first failed multi-click batch as five successful selections.

Current fixture remains running for continued checks. Preserved earned Studio
62789207-389b-45dc-95a0-c5bffd63cd0b independently still reports Chapter3 and
position(-4423.552734375,2.9980251789093018,88.52818298339844).
No earned progression or actor position was changed.

Follow-up: fixture now uses the existing production ScrollRetention module.
Rebuilt/compiled successfully (f4975a42…17beb2); then copied the exact two changed
sources into the isolated stopped Edit fixture and verified both Source strings
equal before starting fresh Play. Actual TH240 long Foundation scroll361 remained
361 after selecting Knight. Raw novice-card-scroll-parity-v5.json records this.
The rebuilt file itself was not reopened; this is exact-source fixture evidence.

Pending: other sizes/EN long copy, ready/busy/underlevel native controls, actual
combined-game claim and Explore behavior, native class confirmation, fixture
broader scroll-retention coverage, physical devices and human art acceptance. Console keeps
CorePackages warnings and preexisting203785492 asset-type messages; not presented
as a clean whole-game log. Goal ACTIVE.
