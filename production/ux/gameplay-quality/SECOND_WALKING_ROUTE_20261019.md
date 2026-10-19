# Second walking route UI and native picker correction

Base: 9ac4dbfefed015ebb61d540d85e0877fc82021b7. Bounded presentation change.

The reader independently validates CityGreenwoodCorridor / city_greenwood_west
and GreenwoodIronveilCorridor / greenwood_ironveil_south. Only the exact server
transit tuple selects the active route. Duplicate identities, malformed folders,
partial endpoint domains and streaming loss fail closed for the affected route.
Canonical metadata remains FloorCenter, width24, below4, above14.

Chapter02 Greenwood mine guidance now chooses the actual second entrance before
the old Central City fallback when valid metadata is present. Reverse guidance
uses the opposite endpoint. Missing geometry preserves portal fallback outside
transit; admitted transit loses its beacon rather than inventing geometry.
Elevated private mine floors cannot select the surface approach. Map title and
banner follow projected from/to zones, including direction changes without exit.
No geometry, server admission, quest progress, economy or rollout flags changed.
The second route remains dependent on separately reviewed server activation.

Inventory phone picker uses two noninteractive native Frame strokes instead of
font-dependent arrow glyphs. Full localized labels, 48px control and busy state
remain; selected category rotates the chevron through existing redraw behavior.

## Fresh local verification

- Walking runner: 58 PASS (reader14, walking quest9 and existing route/tracker cases).
- Inventory Pane: 24 PASS; yielded redraw/destruction: 2 PASS.
- Actual InventoryView mocked bindings: 12 PASS. Shared GUI: 60 PASS.
- Scoped Roblox LSP: four changed production modules clean; compile PASS.
- Rojo normal-game build and isolated Inventory review build PASS; diff check PASS.
- Independent read-only reviewer reran walking58 and Inventory24; no blockers.

These are local checks, not Studio/device/art acceptance. No Studio calls in this
wave. Native chevron rendering, second corridor traversal/streaming, physical
mobile input and human art approval remain pending. Full game baseline was not
rerun in this bounded wave.

## Preview

build/inventory-review/GuildborneInventoryReview.rbxlx
SHA256: 43b4014a222c6cb454bb8e05477b0d85941faf3b8813bbfcfa9a76aba794572a
One LocalScript, zero server Scripts/remotes. Synthetic actor fixtures0/1/6;
check EN/TH at320/796/1366 and collapsed/expanded phone picker. This fixture
covers Inventory only, not second-route traversal or the complete game redesign.
