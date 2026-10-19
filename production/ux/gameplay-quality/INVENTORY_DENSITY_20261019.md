# Inventory medium composition follow-up

Base624ddc3; branch codex/inventory-medium-polish. Addresses controller's actual
normal-game c7527e Inventory capture at796x674 (see integration/quality-slice/
COMBINED_NORMAL_INVENTORY.md): unused actor-selector band on a fresh profile,
small120px player portrait, and crowded/cropped category strip.

## Changes

- Zero or one selectable actor: omit redundant selector and start columns38px
  below the heading instead of94px. Two or more retain the actual selector,
  including all six actors. No actor identity/progression rules changed.
- Medium portrait stage180px (previous120); desktop200 and phone160 retained.
  Existing viewport now has a native Surface-to-Background gradient. Camera,
  snapshot sanitization, owner checks, polling and fallback are unchanged.
- Categories use48px native targets and16px text with8px inset. Medium uses
  three columns/two rows; wide area may use one row only with conservative
  full-label allowance. The capped desktop center also uses two rows.
- Phone: full-width selected-category button opens full-width choices, pushing
  content down rather than covering it; selection collapses and invokes the
  existing filter callback. No new locale key, texture or runtime ID.
- Opt-in quiet GuildborneButton hides inner bevel and reduces padding only for
  categories. Default button behavior/styling unchanged. Arrow glyphs use Luau
  Unicode escapes; tests catch the Windows encoding corruption found in review.

Medium0/1 actors: category origin38, grid204 (old208), portrait stage180.
Medium6 actors: category origin94, grid260; readable second category row costs
52px, independently of portrait height. Phone6 actors/collapsed picker: first
item row ends380px within the simulated management content height. Expanded
picker deliberately requires scrolling; no physical-device fit claim.

## Fresh validation and limits

- 24 actual Pane/Slot/Button source simulations: previous cases plus18 combinations
  EN/TH x0/1/6 actors x280/744/968 content widths, and busy picker/category checks.
  Validate non-overlapping category bounds, full translated labels,48px targets,
  last hero reachability, collapsed first phone row, loadout availability and
  canonical callback forwarding. Mock geometry cannot prove rendered TextFits.
- Two coroutine-yield regressions: resize coalescing and destruction during
  construction still pass. The runner includes the24 tests above, not26 extra.
- 12 actual InventoryView projection/action cases PASS (sale confirmation and
  authoritative payloads preserved). Existing60 GUI simulations PASS, including
  shared button disabled/pending/destruction and other screen behavior.
- Scoped Roblox-aware LSP PASS for three production modules and review fixture;
  changed Luau compile and git diff check PASS. Reconciliation502assets/73screens,
  no missing references; character contract PASS. These are local checks only.
- Independent read-only reviewer found no remaining source blockers and reran
  all24 Pane simulations plus2 yield regressions after the glyph correction.
- No Studio calls or mutations this wave. Earlier isolated native and normal-game
  receipts remain historical evidence. Full baseline944 was controller's prior
  run, not rerun or promoted as this wave's native/device/art acceptance.

## Controller handoff

Built: build/inventory-review/GuildborneInventoryReview.rbxlx
SHA256:fffc4e9644f82690e2e2a25975fcd1dc8e424ebf1a461f2ea63de09cf02382d1
Builder verifies one LocalScript, zero server Scripts/remotes; build_receipt.json
contains exact source hashes. This is a synthetic read-only-intent fixture.

New controls ModeActors0, ModeActors1, ModeActors6 are in the horizontally
scrolling mode bar. Test all three at Size320/796/1366 and LanguageEN/TH with1:1.
Actor0 removes class/roster, Actor1 retains player only, Actor6 has player+five
synthetic hero records (no live hero models fabricated). These count fixtures
retain synthetic inventory and are not fresh earned profiles.

Capture first viewport, phone expanded/collapsed picker, last hero selection,
medium180px silhouette, long Thai labels, busy/empty and selected-item Back.
Confirm no cropped labels, duplicated sections, loss of actual avatar/fallback,
or changes to sale/equip intents. Also recheck normal-game fresh-profile Inventory
against the prior capture. Gamepad focus restoration, actual touch, sustained
viewport cost and human reference-art approval remain pending.
