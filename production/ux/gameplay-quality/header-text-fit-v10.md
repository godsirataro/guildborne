# Native text-fit correction — 2026-10-20

Base `1483e54`; task `gameplay-ui-quality`; owner `s14-header-text-fit-v10`;
shared v10 ledger. This corrects the resource header's text initialization only.

## Cause and bounded fix

Controller reported an isolated native probe confirming that setting TextScaled
true and then TextWrapped false leaves scaling disabled. GoldValue retained the
default TextSize8: zero measured 7×12 in a 212×24 label despite its 12–22
UITextSizeConstraint. This was not an identified external style normalizer.

The helper now sets TextSize to its supplied maximum, TextWrapped true, then
TextScaled true. Gold/caption/loading retain maxima 22/13/16 and existing
constraints. Caption height remains 16; all other label rectangles, shared HUD
layout, snapshots, localization, input handlers, menu/focus identity and all
30 item definitions remain unchanged.

Controller's isolated proposed-order probe reported scaling true, zero 13×22,
16-digit value 192×22 and Thai text 138×22 fitting its tested label. These are
controller observations, not a new worker Studio session. Full integrated
native retake and phone glyph fit remain controller acceptance work.

## Regression and review

The GUI mock now implements the observed coupled properties for native text
objects, storing them outside raw table fields so repeated assignments cannot
bypass the setters. It does not simulate glyph bounds or TextFits. A repeated
property-transition case checks both orderings. A real-header case checks
GoldValue, ResourceCaption and ResourceLoading across loading/zero/long Thai
updates, including their distinct explicit fallback sizes.

The pre-fix component fails with `GoldValue lost native scaling` using this
mock (`build/header-fit-before.log`). The fixed suite passes 69 GUI cases
(`build/header-fit-after.log`), including existing 80 viewport combinations.
The Title test previously asserted an impossible combination of scaled=true
and wrapped=false; its assertion now follows native coupling without changing
Title source. Independent reviewer `material_review_v9` reran 69 cases and
reviewed the mock, red/green evidence and scoped diff: no actionable findings.

`tools/validate.ps1` also passed: 970 domain tests, Rojo build/sourcemap,
strict analysis, compilation and repository checks. Raw output remains in
`build/header-fit-baseline.log`. No native acceptance is inferred from this run.

Earlier local PNG approximations did not model this engine coupling and must
not be used as proof that the old candidate's native font fit passed. They are
preserved as historical source approximations, not regenerated acceptance.

No worker Studio/Blender calls, Forge generation, uploads, publishing, push,
merge or production writes. Native/input/device/human acceptance stays separate.
