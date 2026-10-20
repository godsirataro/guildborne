# Native ForgeGUI-inspired inventory refinement

Original source integrations: 395d0a4 (064d194), d5e9379 (04083c1),
c2b385a (aafbdad). The ForgeGUI image is concept guidance only; the UI uses
existing native components and original ItemVisuals. No additional paid
generation, raster import, asset upload, publication or production save occurred.

## Observed result

The full connected Memory preview was built with Rojo and opened in owned Studio
ebbf8965-95d7-4272-bedd-56f94f7a8dee, process40568. PlaceId/GameId0, Memory and
empty DataStore universes were read before Play. Normal bootstraps were enabled.
All447 script paths/classes/normalized UTF-8 lengths/Adler32 values matched the
built XML before each tested source revision, with no extra sources.

The integrated English inventory shows a249px selected-item model with80px grid
models, teal selection and genuine zero material quantities. Clicking the real
Shop control exposed a pre-existing Hall0 placeholder defect. The actual catalog
omits HallLevel on several starter items; the gate already uses1 but its label
did not. d5e9379 repairs only that display parameter. Native mouse selection and
fresh EN/TH sessions show `Requires Hall Lv1` / `ต้องมีหอกิลด์ระดับ 1`,
with the purchase button still inactive and unselectable. No purchase occurred.
Thai was selected through the title's real language control.

After integrated inspection, the existing tests/gui/inventory_review.client.luau
was executed as a separately labelled native component fixture, DisplayOrder100.
Its two control rows were named for unambiguous test clicks. It uses actual
InventoryView/InventoryPane/ItemViewport/Localization but synthetic inventory and
records intents only. Its320x568 container is NOT a device or engine viewport.
Actual clicks select the sword and scroll394px to its action/metadata. Busy
controls are inactive/unselectable; Empty has no inspection bay and displays its
empty message. Recorded intent count remains0 in these observations.

That fixture exposed raw `AlreadyEquipped`. c2b385a adds only its English/Thai
translation. After rebuilding and matching all447 sources, actual fixture
selection shows `Already equipped` and `สวมใส่อยู่แล้ว`, still disabled, with0
recorded intents. Native screenshots/readbacks are under native/post-localization.
The two revised modules were copied into the owned Edit candidate from exact local
source, then compared against newly built XML; this is not a claim of live Rojo sync.
Play was stopped and Studio confirmed Edit after the final run.

## Evidence and independent review

manifest.json hashes50 copied native/check artifacts,1,990,540bytes, including
empty raw streams. `.gitattributes` preserves their bytes in Git. README and the
manifest are not included in that manifest's entries.

- cf3a7e576d9541359218b0b4fe98f493: immutable395d0a4,973 tests plus full baseline.
- 236b981dc0984f7d94aca9728411858a: immutabled5e9379,973 tests plus full baseline.
- 16b55aedb3d74825af21250f23ab33d1: immutable52e7505 (runtimec2b385a),
  unchanged source,973 tests, build/sourcemap/analysis/compile/repository checks.
- Worker checks:27 existing pane cases,19 inspection cases,7 camera-arithmetic
  cases; Hall-label actual projection regression10PASS/2FAIL before and12PASS
  after; AlreadyEquipped real Localization5 checks. These are local tests, not
  native input or server transactions.
- Independent r6_preflight verified the first candidate's447 identities,
  ordinary-source mapping, baseline hashes and EN screenshots; no additional
  blocking desktop layout defect beyond the discovered label. Worker independent
  reviewers checked each source repair. Final independent r6_preflight review
  verified all50 manifest entries/1,990,540bytes and all49 copied artifacts against
  their originals, reproduced all three447-source comparisons, and checked the
  final XML SHA e2c58cf56c9d283682629b6dbef4bba047a93ff0b78ae22903995db087ceae97.
  Final baseline commit/tree/stream hashes and actual screenshots/readbacks agree
  with the limited claims above. Final StopPlay and fresh Edit confirmation are
  preserved separately in [cleanup receipt](../gui-final-stop-20261021.json).

Initial native/expected-sources.json and native/identity.json record0 sources:
the first offline parser searched ProtectedString while Rojo emits string Source
properties. The corrected roster and native readback contain447 exact matches.
The failed parser artifacts remain unchanged. A later UTF-8 shell-output read
failed before any Studio mutation; source was read through the Unicode-safe
Node bridge. Neither failure is represented as a passing native test.

## Remaining acceptance

The larger portrait is an improvement in readability, not full custom-art
acceptance. Models remain angular; repeated ornate frames need further art
review. Broader Thai copy, long-text/action reachability, real phone/gamepad
input, owned-equipment server transactions and human art/UAT remain open.
No complete Bond, Echo, Secret Class discovery, all-game or release acceptance
is claimed. R6 walking/junction/Hold/visible-order and active NPC tests remain
separate next gates.
