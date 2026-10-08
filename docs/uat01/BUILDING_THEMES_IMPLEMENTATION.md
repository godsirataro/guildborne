# Building themes — local prototype implementation, 2026-10-03

Six original art directions now have native three-dimensional previews and Blender source/export assets: Human Hearth, Elven Canopy, Dwarven Forge, Orc Welcome, Mage Observatory and Crosshaven Commons. The concept board is a visual target; current native models are simple open utility-building prototypes, not finished equivalents of the illustrated buildings.

Human is free. Orc is a proposed quest-earned theme, unlocked after claiming Borga's A Hearth for Everyone quest. The other four are reserved paid-theme candidates with product IDs0; purchasing is disabled. These unlock assignments are implementation candidates, not finalized launch pricing or balance.

Themes are applied per owned Warehouse, Hero Quarters or Blacksmith, including stored buildings. Applying a theme preserves building identity, coordinates, orientation, upgrades, inventory and all functional benefits. Storage, restoration and layout switching retain each building's selected theme. Layout slots currently capture geometry only; they do not override theme choices.

Optional expansion.themeRights stores permanent quest or trusted purchase records. The public view projects only boolean ownership, never purchase references. Normal commands may unlock a completed quest theme or apply an owned theme; no client grant/payment-proof command exists. The internal verified-entitlement function is a candidate-state helper, not payment verification, and all configured paid IDs currently reject grants. A real Marketplace verifier and fulfillment/recovery acceptance remain required before commerce.

## Evidence

- 391 domain tests passed. Theme tests cover claimed-quest gating, client-grant rejection, ownership/upgrade preservation through storage and rejoin, uncertain commits, receipt-reference conflicts and projection redaction. The5,000-order soak had zero invariant violations.
- Disposable Studio geometry fixture passed106 checks: six themes119parts, unchanged seven colliding base parts per preview, decorative collision/query/touch disabled, idempotent theme refresh and unchanged world position/orientation. No profile writes.
- One Blender source gallery, six FBX, six GLB and six icon renders were produced from the native geometry. All12exports passed round-trip triangle count, dimensions and origin checks; total1,428triangles. Roblox mesh uploads/import permission review remain pending.
- Actual offline UI: accepted Borga quest, gathered12Timber/4Stone, claimed quest for4Timber and8Gold at revision10, constructed warehouse b:1 at revision11, unlocked Orc at revision12, applied Orc at revision13. World model still occupied(56,1.5,-24), warehouse capacity remained200, and theme unlock/application generated no material or currency events. Server debug positioning and scroll positioning were used; this is not walking or human acceptance.
- All six compact UI previews are present at80px height, with Human preview visually confirmed. Other visual states and physical devices still need acceptance.

## Files and limits

Concept and exact built-in image_gen prompt: [concept](../../assets/uat01/building-themes/concept.png), [prompt](../../assets/uat01/building-themes/concept-prompt.txt). Native geometry source export: [kit](../../assets/uat01/building-themes/kit.json). Blender gallery: [source](../../assets/uat01/building-themes/Guildborne_Building_Themes.blend), [render](../../assets/uat01/building-themes/preview.png), [exports](../../assets/uat01/building-themes/export-report.json), [round-trip report](../../assets/uat01/building-themes/roundtrip-report.json).

Hall/furniture/road/garden/wall themes, final mesh detail, textures, import permissions, actual purchase verification, real multiplayer/mobile/controller acceptance and human UAT remain outstanding. No cloud asset upload, real purchase or public publication occurred.

## Hall extension — 2026-10-03

Guild Hall is now selectable in Building themes, using the same free/quest/paid ownership gates. Optional expansion.hallTheme is validated and preserved through movement, upgrades, layouts and rejoin. Theme changes do not change Hall collision or level. Native previews clone the actual owned Hall model and strip signs/prompts.

411domain tests include Hall theme ownership, uncertainty, layout preservation, rejoin and malformed selection.5,287native checks cover six themes/two levels/four rotations,48no-jump doorway routes and upgraded Hall synchronization. Actual offline UI: Borga quest claim revision4, Orc unlock5, Hall application6; position(0,1,-24) and HallLv1 preserved. Only the quest consumed4Timber and granted8Gold; theme unlock/application had no item/currency events. Debug travel and scrolling were used. Paid themes remain ProductId0 and unavailable.

[Hall art and exports](../../assets/uat01/hall-themes/README.md):12models/634visible parts/7512triangles,12FBX+12GLB verified,12icons and editable Blender. Final art/import/device acceptance and furniture themes remain pending.
