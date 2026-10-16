# GUI foundation acceptance ledger

Date: 2026-10-16. Candidate implementation, not all-game or human acceptance.

## Baseline

Source 42cb34bcb4ee6f1c30a5805ae92c1c20ca3db323.
Recorded clean-source invocation 229ed8c563764de697e5c894f55ec561:
`powershell -NoProfile -File tools/validate.ps1` passed 890 game tests,
strict Roblox analysis, compilation, Rojo build/sourcemap and repository boundaries.
Raw logs remain unchanged in build/agentic/checks; final evidence is recorded separately.

## Candidate checks

- `python tests/gui/run.py`: 9 simulated behavior cases PASS at the pre-commit working tree.
  Real module source, narrow engine simulation; no native input/layout proof.
- Targeted strict analysis and compile of new UI and test Luau: PASS at working tree.
- `studio.py validate`, `studio.py verify`, `ecosystem.py validate`: PASS, 61 routed tasks.
- `tools/build_gui_review.py`: isolated Rojo build, zero server scripts/remotes,
  exactly one LocalScript. This is a fixture, not a persisted player game.
- Full candidate regression and immutable receipts: pending final recording.

## Independent source review

A different agent reviewed component/Title source and test boundaries. Found Settings
selection lag and a vacuous nested slice test; both corrected. Added positive and
negative slice cases. No P1/P2 findings reported in this bounded source review.
Reviewer did not certify art, layout, Studio, hardware or release.

## Native and external gates

Studio discovery initially returned session 1e078f2a-71bd-4c20-bc35-7a41b7bbb4d4,
then `Place is not open`. User agreed to open the separate review file.
Until actual native evidence is appended, all native checks below are NOT_RUN:

- Desktop 1920x1080 /1366x768 /1280x720 /1024x768.
- Portrait 390x844 /360x800 /320x568, landscape phone and safe areas.
- EN/TH clipping, settings expansion, scrolling and focus visibility.
- Mouse, keyboard, gamepad, touch and virtual keyboard.
- Actual five-model preview, full game state/recovery and multiplayer.

No physical Android/iOS, cross-server, performance, human art/UAT or release
acceptance. No asset IDs imported. Exact official logo is archived; runtime uses
native text/symbol fallback. Pending owner first-screen review before broad reskin.
