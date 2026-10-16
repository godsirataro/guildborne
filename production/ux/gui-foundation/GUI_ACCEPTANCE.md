# GUI foundation acceptance ledger

2026-10-16. Native foundation/Title review candidate, not whole-game GUI acceptance.
Implementation commit:6742d85. No runtime change after the tests recorded below.

## Fresh local checks

| Check | Observed result | Immutable run |
|---|---|---|
| Pre-change game baseline at42cb34b |890 tests, analysis/compile/Rojo/repository PASS |229ed8c563764de697e5c894f55ec561 |
| Candidate tools/validate.ps1 at6742d85 |890 tests, analysis/compile/Rojo/repository PASS |c32556c0873d4da0999f56e5a93fdb82 |
| tests/gui/run.py at6742d85 |9 simulated GUI behavior cases PASS |b88ffe2d323e42088dfc9493993df173 |
| tools/build_gui_review.py at6742d85 |Rojo build PASS, zero Script/remotes, one LocalScript |833fbfba163a4a9284c092784ac1c516 |
| Python production tests |208 tests OK,6 skipped; working-tree run |production-tests-working-tree.txt |
| Studio/Forge/ecosystem metadata |61 tasks,33 roles; validate/verify PASS |Tool results, not game acceptance |

Raw receipt/log copies are under evidence/checks/<run>. Original paths inside receipts
remain unchanged and refer to build/agentic/checks on the execution machine.
No receipt was rewritten to imply a newer commit. Evidence manifest hashes copies.
The Python working-tree test log is not an immutable recorded-check packet.

## Native Studio fixture

Selected Studio:e50c5386-8bf0-4f6b-8587-261cabeb0a4f,
GuildborneGUIReview.rbxlx, PlaceId0/GameId0; no server scripts/remotes.
Built place SHA256:f79076a72d03f7daeb5d28652eac85865137a207bd5cdf23d833b36df771e767.
Play session used actual Title/components/MenuRouter/SettingsControls/CompanyPreview
with a clearly labelled simulated profile and empty roster; no persistence or rewards.
Stopped Play after tests. No Studio source edits were saved.

Observed results:
- Mouse Language changed actual EN to TH labels (state readback and screenshots).
- Mouse Settings expanded and immediately set Selected=true; canvas grew to994px.
- Mouse Continue hid Title, destroyed preview, cleared menu-blocking and restored touch controls.
- Disabled tab and disabled/pending buttons did not change gallery status; primary activation counted1.
- Recreated loading Title refused mouse Continue/Language (both counters0, controls inactive).
- Existing MenuRouter.focusCurrent selected Continue; injected Return activated once.
- Separate visible Title handed off Degraded/LeaseLost once and destroyed preview.
- Actual engine layout boxes320x568,360x800,390x844,1024x768,1280x720,
  1366x768,1920x1080 reported TextFits=true for Thai Continue/Language/company text.
  These are constrained native Frames, NOT device-emulator or physical-device tests.

Screenshots are actual796x675 Studio viewport captures: title-desktop-en.png,
title-desktop-th.png, title-layout-360-th.png, component-gallery.png. The narrow
capture shows a constrained360x568 Title above the gallery; it is not a phone photo.

Caveats: an initial Tab injection did not establish SelectedObject. Explicit focus
plus Return worked, but automatic keyboard/gamepad navigation remains unresolved.
Output also contains Roblox Core UIBlox FoundationProvider warnings and existing
asset203785492 type-mismatch messages. No new GUI script exception observed.
Exact official logo has not been uploaded; screenshots show native wordmark fallback,
not final crest/illustrated background parity with the reference images.

## Independent review and remaining gates

Separate agents reviewed source. Fixed Settings selection lag and a vacuous nested
slice test, adding positive/negative slice cases. No P1/P2 source findings reported.
Review of evidence hashes is distinct from human art acceptance.

Only Title and the isolated component gallery have new native fixture observations.
73 original screens plus14 extra surfaces are audited, not broadly reskinned.
Actual five-hero models, full-game integration, all other screens/states, gamepad,
physical touch/virtual keyboard, device performance, multiplayer, cross-server,
human art/UAT and release remain pending. Asset IDs imported:none.
Owner review of the reusable foundation/first screen precedes broad migration as
specified in the supplied master prompt. No merge, publish or commerce activation.
