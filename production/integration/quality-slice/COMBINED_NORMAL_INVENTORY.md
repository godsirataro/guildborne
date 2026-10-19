# Combined candidate normal-game Inventory check

2026-10-19. Opened actual built Guildborne_QualityPreview.rbxlx SHA256
c7527e912c6093be3483709d168d34414916cdf49c400498f0f8fbf4aed7cc2f
in disposable Studio b8caf94f-9ab1-4969-80d4-9b53a54cc24b. Before Play:
PlaceId/GameId zero, Memory persistence, empty allowed DataStore universes,
normal server/client bootstraps enabled. InventoryPane and InventoryActorPreview
full Source readback equals current controller source after CRLF normalization.

Normal bootstrap loaded revision0 fresh Memory profile; no injected profile,
reward or progression. Real mouse input changed title language to Thai, then
Begin adventure and Inventory. Native screen capture combined_inventory_th
shows actual player portrait and empty equipment/material inventory. Client
inspection at796x674 found one InventoryPane, one233x120 ActorViewport and
five80x80 material previews, no visible TextFits failures. This checks current
normal-game rendering only; it does not prove equipment transactions, all states,
all screen sizes, physical devices, earned progression or final artwork.

Native art Dataset1 READY_LOCAL_ONLY:116 placements,45267 triangles,6.677seconds.
Dataset2 READY_LOCAL_ONLY:72 placements,11330 triangles,1.199seconds.
WorldCollisionReady true. These import timings are one run, not performance gates.
Raw responses and unchanged console output: COMBINED_NORMAL_INVENTORY_RAW.json.
Console contains Roblox CorePackages FoundationProvider warnings and asset type
mismatch for203785492; no claim of a clean console. Investigate that asset before
promoting visual acceptance. Actual screenshots inspected through MCP; no local
PNG archive or human approval is claimed.

Visible art issues sent to S14: excessive blank header-to-columns space,
small actor visual weight and crowded small filter labels at medium viewport.
No visible TextFits failure does not establish clipping or composition correctness.

Restarted bundled Rojo7.7.0 for this exact quality-preview.project.json on34872,
exec session14305. The PATH shim failed first (missing path); bundled executable
started successfully. Studio Rojo plugin connection remains UNVERIFIED; source
comparison above concerns the loaded rbxlx, not a proven live Rojo sync.
