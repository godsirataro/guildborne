# Asset manifest and integration

2026-10-02. See [gallery](../../assets/uat01/GALLERY.md), [machine-readable manifest](../../assets/uat01/manifest.json) and [exact prompts](../../assets/uat01/PROMPTS.md). Nineteen PNGs were generated with the built-in image_gen tool and copied into assets/uat01/generated, including superseded variants. Sprite prompts are in [VFX prompts](../../assets/uat01/VFX_TEXTURE_PROMPTS.md); crest prompts are in [crest prompts](../../assets/uat01/CREST_PROMPTS.md). No reference image was imported from Blox Fruits or any third-party game. No Roblox upload, asset permission change or purchase occurred. Generated output is not asserted to be public domain; creator-account permissions must be verified at import.

Additional delivery: [53 original SVG/native UI symbols](../../assets/uat01/ui-symbols/README.md), with three command icons integrated; [nine script-free Roblox prefab packs](../../assets/uat01/roblox-prefabs/README.md). Source-ready art and native models do not certify gameplay integration or UAT acceptance.

Additional original local sources: [ten Blender props](../../assets/uat01/adventure-kit/README.md), with editable .blend, ten FBX, ten GLB, native equivalents and a20-file round-trip report; [ten synthesized UI audio cues](../../assets/uat01/audio/README.md),48kHz16-bit mono WAV. Mesh import and listening/UI audio integration remain pending. New VFX slash/smoke sprites have actual alpha but faint pixels touch the edge; review status remains explicit in manifest.json.

| File stem | Deliverable | Runtime state |
|---|---|---|
| guildborne-logo-v1 | Transparent wordmark | Optional TitleView consumer prepared; ID empty |
| guildborne-keyart-v1 | Title background | Optional TitleView backdrop prepared; ID empty |
| guildborne-worldmap-v1 | City + three islands illustration | Concept; not a live navigation map |
| guildborne-skill-icons-v1 | 5 × 4 static skill symbols | Crop review; no uploaded ID or skill HUD integration |
| guildborne-equipment-icons-v1 | 4 × 4 grid, 14 new item symbols | Optional InventoryView second-atlas consumer; ID empty |
| guildborne-item-icons-v1 | 4 × 4 existing item symbols | Optional InventoryView consumer prepared; ID empty |
| guildborne-hero-templates-v1 |15hero visual proposals |15models/rigs/60clips created; recruitment binding pending |
| guildborne-npc-concepts-v1 | 8 service NPC proposals | Model/rig production pending |
| guildborne-bestiary-concepts-v1 |9enemies+3bosses |12rigs/48clips created; isolated AI prototype tested; live encounter integration pending |
| guildborne-vfx-storyboard-v1 | 5 classes × 4 visual stages | Choreography reference; not a flipbook |
| guildborne-ui-concepts-v1 | 6 screen concepts | Layout reference; pictured values not catalog data |
| guildborne-cosmetic-concepts-v1 |8cosmetic proposals |8art models/icons and greeting clip created; entitlements/shop/dynamic VFX pending |

Actual dimensions differ from requested dimensions; manifest.json records the measured PNG sizes and SHA-256 hashes. Logo, both item atlases and skill icons have alpha channels; other sheets have opaque backgrounds. The item atlas is 1254 × 1254 and skill atlas 1402 × 1122, so cells have rounded, variable pixel widths. Never assume 512px cells. The skill sheet has tight effects at some boundaries and needs gutter/crop review. These are static atlases, not ParticleEmitter flipbooks.

VisualAssets.luau is the only runtime ID registration point for the prepared consumers. Empty strings create no ImageLabel or failed network request; existing text/native UI stays usable. Once upload is separately approved, upload through the owning experience's account, record the real ID and served dimensions, check every crop at 48/80px, then populate Logo/KeyArt/ItemAtlas. AssetImage reveals only loaded images. Re-test denied/unavailable IDs, EN/TH and mobile before accepting. Do not place local filesystem paths into ImageLabel.Image.

Native additions: CompanyPreview clones at most five of the local player's replicated heroes, strips scripts/prompts/Humanoids, anchors visual copies, and disconnects drag handlers when destroyed. SkillTreeView renders existing learned/locked states and routes learning through the existing server command. IslandScenery deterministically builds noninteractive background geometry and uses no external asset IDs.

Re-run `python tools/audit_uat_assets.py` to inspect source images and regenerate metadata. It does not edit or crop image pixels.

API reference checked: [Roblox ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel). Adventure reference supplied by user: [Blox Fruits](https://www.roblox.com/games/2753915549/Blox-Fruits); Guildborne keeps its own characters, geography and commander identity.

Current portable/native library evidence: [production ledger](PRODUCTION_LIBRARIES.md).
