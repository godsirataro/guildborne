# Guildborne — original art pack v1

Generated 2026-10-01 through2026-10-03 with built-in image_gen. Twenty-two local generated PNG sources, including superseded variants. These are artwork and visual references; they do not certify implemented gameplay or popularity. Native implementation evidence is in [validation](../../docs/uat01/VALIDATION_ART_UI.md).

## Additional production sources

58 original SVG/native UI symbols: [gallery](ui-symbols/gallery.html). Script-free Roblox model libraries: [prefab packs](roblox-prefabs/README.md).

## Brand and title art

Standalone transparent crest v2; faint-alpha padding still needs import review.

![Guildborne crest](generated/guildborne-crest-v2.png)

Transparent logo source. Roblox upload pending.

![Guildborne logo](generated/guildborne-logo-v1.png)

Title background / key art. Concept characters and city detail are more elaborate than current native models.

![Guildborne key art](generated/guildborne-keyart-v1.png)

## World map

City + Greenwood + Ironveil + Ashen visual proposal. Three compact native adventure blockouts now support offline travel, gathering and personal-party combat; they are simpler than this illustration.

![World-map concept](generated/guildborne-worldmap-v1.png)

Six planned city identities: human Crownford, elven Sylvaris, dwarven Deepforge, mage Astralis, shared capital Crosshaven and friendly-Orc Ironroot. The board is an architectural target, not six completed playable cities. [Exact prompt](CITY_IDENTITY_PROMPTS.md).

![Six-city identity board](generated/guildborne-city-identities-v1.png)

Six simpler native/Blender landmark prototypes,192parts/2304triangles,12verified FBX/GLB exports and6native navigation routes. These are reusable building assets, not completed city maps. [Sources and limits](city-landmarks/README.md).

![City landmark prototypes](city-landmarks/preview.png)

## Heroes and NPCs

Fifteen costume/template concepts across five classes. Fifteen named templates now bind to simpler native appearances in offline Tavern recruitment; production mesh imports, rotation/tickets and release acceptance remain pending. See [named recruits](../../docs/uat01/NAMED_RECRUITS.md).

![Hero template concepts](generated/guildborne-hero-templates-v1.png)

Eight service character concepts. NPC art names/roles are proposals where no runtime counterpart exists.

![NPC concepts](generated/guildborne-npc-concepts-v1.png)

## Combat, skills and effects

Twenty static skill symbols. Candidate crops are in manifest.json. No flipbook animation is implied.

![Skill icon atlas](generated/guildborne-skill-icons-v1.png)

Nine enemy archetypes plus three boss concepts; AI and encounters still require implementation.

![Bestiary concepts](generated/guildborne-bestiary-concepts-v1.png)

Five four-stage spell storyboards. These have a background and are not runtime particle textures.

![VFX choreography concepts](generated/guildborne-vfx-storyboard-v1.png)

## Inventory and shop

Sixteen icons match existing item definition IDs. Inspect crop bounds/gutters before enabling the uploaded atlas.

![Item icon atlas](generated/guildborne-item-icons-v1.png)

Eight guaranteed cosmetic concepts; no configured products or purchasable entitlements.

![Cosmetic concepts](generated/guildborne-cosmetic-concepts-v1.png)

## UX/UI direction

Six screen concepts. All names, quantities, prices and statistics pictured are illustrative. Production UI must use authoritative catalog/profile state. The pictured leather market row is not on the actual five-material allowlist. Actual skills are boolean learned nodes, not the rank counters drawn in this concept.

![UI concepts](generated/guildborne-ui-concepts-v1.png)

[Exact generation prompts](PROMPTS.md) · [Measured file metadata and proposed crops](manifest.json) · [UX flow](../../docs/uat01/UX_FLOW.md) · [Asset integration](../../docs/uat01/ASSET_MANIFEST.md)

## Equipment expansion atlas

![Fourteen new equipment icons](generated/guildborne-equipment-icons-v1.png)

Fourteen icons match the new live catalog IDs; two cells are intentionally empty. Native game models use existing original weapon families and tint variations, not the full detail in this raster art. Candidate atlas requires crop/gutter and import-resolution review before upload.

## Editable 3D adventure props

![Original Blender prop kit](adventure-kit/preview.png)

[Editable Blender, FBX and GLB library](adventure-kit/README.md): ten props,1,044 triangles. All20 exports round-tripped into Blender successfully. Native Roblox counterparts verified in Staging; mesh import pending.

## New VFX sprite candidates and audio

[Slash sprite](generated/guildborne-vfx-slash-v1.png) and [smoke sprite](generated/guildborne-vfx-smoke-v1.png) were generated with built-in image_gen. Both retain real alpha. Very faint edge pixels require review before production use. [Exact prompts](VFX_TEXTURE_PROMPTS.md).

[Ten original UI audio masters](audio/README.md) are local48kHz mono WAVs. Numerical checks passed; listening review and runtime integration remain pending.

## Sentinel custom rig and animation candidates

[Editable kit and validation](character-kit/README.md) —16 bones,288triangles,9individual FBX clips and rest FBX/GLB. Studio import and runtime IDs pending.

![Motion contact sheet](character-kit/preview.png)

## Combat impact and sound candidates

[Impact sprite prompt](IMPACT_PROMPT.md), [12 combat sound candidates](audio/combat/README.md), and [normalized motion preview](character-kit/motion-preview.gif). Sprite alpha-margin review, sound listening and Studio imports remain pending.

## Original weapons and shockwave animation

[Five weapon models and native runtime integration](weapon-kit/README.md), [16-frame transparent shockwave atlas](vfx-native/README.md). Exports verified locally; Roblox mesh/texture imports remain pending.

![Weapon silhouettes](weapon-kit/preview.png)

## Complete inventory display library

[All30 item meshes, transparent icons and native previews](item-kit/README.md). Sixty portable mesh exports round-trip verified;30RGBA icons have at least51px transparent padding. Native previews integrated into Inventory, with cloud import still pending.

![All30 item models](item-kit/preview.png)

## Regional enemy rigs

[Twelve models and48custom animation clips](enemy-kit/README.md), with72portable exports round-trip verified. Local static Studio templates are available; live encounters and animation import remain pending.

![Three-region enemy art](enemy-kit/preview.png)

Three original traversable blockouts: [region kit](region-kit/README.md), with9review routes and15encounter markers. Regional gameplay integration remains pending.

[15hero visual templates and60clips](hero-kit/README.md) · [8cosmetic art prototypes and greeting animation](cosmetic-kit/README.md). No recruitment or shop entitlement is implied.

Standalone local Studio review: [instructions](../../review/README.md). Includes all native display libraries, region routes and synthetic boss demos.

## Craftable guild furniture

![Furniture kit](furniture-kit/preview.png)

[Ten original native/Blender models and runtime status](furniture-kit/README.md): crafting, outdoor placement, storage, recycling and layout capture are implemented locally. Indoor placement and physical-device acceptance remain pending.

## Hall themes

![Hall theme library](hall-themes/preview.png)

[Six themes across two Hall levels](hall-themes/README.md), with native runtime selection and24verified local exports. Paid ownership fulfillment and final art/device acceptance remain pending.
