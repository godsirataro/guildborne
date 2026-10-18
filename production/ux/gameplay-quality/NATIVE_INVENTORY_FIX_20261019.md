# Inventory native blocker corrections

2026-10-19. Follows 41be870 and 9f910f4. Original controller failure is retained
unchanged in INVENTORY_NATIVE_BLOCKERS_RAW.json; corrected raw tool responses
are in INVENTORY_NATIVE_FIX_RAW.json. This is bounded native correctness evidence,
not final reference-art, physical-device, full-game or human acceptance.

## Causes and changes

- A cold asset constructor can yield while AbsoluteSize changes. Previously a
  second draw entered the same pane and duplicated seven direct components.
  Serialize draw passes, coalesce resize requests, and dispose late previews if
  the pane is destroyed during a yield. Flush final automatic layout sizing.
- Actual Humanoid.Status reports IsA('Model') true and Archivable false. It is
  engine state, not artwork. Exact Model class filtering excludes it while
  retaining explicit Accessory and other visual types; live flags are unchanged.
- Native 320 English matrix exposed Shared inventory heading overflow. Use 18px
  phone heading; final matrix has no TextFits failures for the tested Owned view.

## Verification

- inventory_reentrant_probe.py: existing five pane simulations plus two new
  coroutine suspension cases pass. Three resizes coalesce to one follow-up and
  seven unique components; destruction during suspension cleans the late preview.
  Negative control with original HEAD source passes old five but fails the new
  reentrant case, confirming the new test detects the original fault.
- Actual InventoryView harness: 12 PASS. Scoped Roblox-aware LSP PASS for both
  changed production modules. Independent read-only reviewer found no remaining
  source blocker. This review is separate from engine evidence.
- Disposable Studio 803f427b-0082-4f62-8e09-4ddb616aa01b began as controller's
  exact original 5cbed166 fixture. Replaced only InventoryPane and
  InventoryActorPreview in Edit, then read back exact source equality before
  each Play. Final byte counts: Pane14866, Preview10053 (trimmed final newline).
  No whole-place hash equality claimed for the in-memory modified place.
- Cold Play: one copy of each of seven sections, actual player portrait17 parts,
  one model, fallback false, zero cloned scripts. Source root remains
  non-archivable. Screens inventory_fixed_796_en and inventory_fixed_320_th were
  inspected in MCP tool history; no local PNG archive is claimed.
- Real mouse input: select spareSword, scroll the outer fixture viewport to
  reveal Sell, first Sell -> Confirm sale with0 intents, second -> one
  SellEquipment {instanceId=spareSword}. Earlier clicks while clipped did not
  activate it. This was before the phone-only heading adjustment; no economy
  operation occurred because the fixture only records intents.
- Final source: mouse-clicked all six Owned combinations320/796/1366 × EN/TH.
  Actual pane widths280/756/976; exactly one section per name, no TextFits
  failures. This does not establish all text visibility or physical device fit.
- inventory_native_regression.luau ran against actual modules in final Client:
  actual-player17parts; owned synthetic hero; incomplete visual fallback;
  foreign-owner fallback; missing hero fallback; six resize transitions and
  cleanup. All six passed. Copies anchored/noncolliding/nonqueryable/nontouching,
  no copied scripts; temporary test GUI and hero destroyed.
- Play stopped and Edit confirmed before ownership handoff. Other Studio places
  and controller's Rojo server were untouched. No publishing/upload/spending.

## Artifact and remaining acceptance

Rebuilt preview: build/inventory-review/GuildborneInventoryReview.rbxlx
SHA256:a22b4a04e076b29ccce13776e89cfba04e02216e846c107395cf3e0b86e702b9
The rebuild has the corrected sources; native tests used the two-source patched
original disposable place, not a fresh opening of this rebuilt file.

Open preview and Play; choose Size796/1366/320 and LanguageEN/TH. Keep1:1 for
nominal-size checks, scroll OUTER viewer as required. Fit is not device evidence.
Full integrated equipment results, every busy/empty/capacity/Hall state in native,
real hero streaming, sustained performance, keyboard/gamepad/touch and art signoff
remain controller acceptance work. Earlier interrupted full baseline remains
incomplete; this correction does not promote it to PASS.
