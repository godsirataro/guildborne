# GUILDBORNE — FULL GUI PRODUCTION MASTER PROMPT

**For:** Codex CLI/desktop on the developer's local Windows workstation, connected GitHub, Roblox Studio MCP, Rojo, optional approved Blender MCP, and optional Figma/Canva design connectors.

**Intent:** Implement, integrate, test and prepare a reviewable Pull Request for a complete reusable native Roblox GUI system inspired by the **user-approved original Guildborne logo** and **10 attached GUI concept references**. This is a large *engineering task*, not merely a research report, a new image gallery or a fake UI demo. Continue existing Guildborne work; do not replace the game, reset progression or create a disconnected prototype.

**Local path assumption:** The pack lives at `design/guildborne-gui-production/` in the repository. If it is somewhere else, locate it and use actual paths. All examples are illustrative and must be validated against the checked-out repository.

**User direction (Thai):** ใช้โลโก้ที่ผู้ใช้ให้เป็นต้นฉบับ ทำ GUI ใหม่ทั้งเกมในสไตล์ Fantasy RPG ตามภาพอ้างอิงทั้ง 10 รูป มี CI Branding, Reusable Components, Background, Loading, Main Menu, HUD, Map, Status, Skill Tree, Inventory, Quest, Guild, Shop/Crafting และทุกหน้าอื่นในทะเบียน GUI จริง ต้องต่อเข้าระบบเดิม ใช้งานได้จริง รองรับ EN/TH, PC/Mobile/Gamepad, มีการทดสอบและหลักฐาน ห้ามสร้างภาพนิ่งแทน GUI ที่กดได้.

---

## 0. Absolute instructions: correct game, correct repo, correct authority

You are Guildborne **GUI Technical Director + Creative Director + Native Roblox UI Architect + Integration/QA Coordinator**. Delegate to the existing Guildborne Studio roles when the actual Codex host allows subagents, otherwise work in bounded sequential tasks. You must produce code and evidence, not just descriptions. Work incrementally and checkpoint progress; **do not claim the whole task is complete until every in-scope screen and quality gate has actual evidence**.

1. Open the actual repository (expected `C:\Work\MySelf\Guildborne`, `godsirataro/guildborne`). Run `git status`, `git branch --show-current`, `git rev-parse HEAD` and inspect current HEAD before editing. This prompt was prepared against public source observed 2026-10-16, not a locked implementation hash. Newer source overrides historical audit findings.
2. Read in this order: `AGENTS.md`, `README.md`, `production/LATEST_GOALS.md`, `production/QUALITY_GATES.md`, `production/STUDIO_V3.md`, `production/AI_ECOSYSTEM_TH.md` if present, `production/plan.json`, `docs/uat01/WORK_CHECKLIST.md`, `docs/uat01/intake/registry-reconciled.json`, `docs/uat01/UI_ART_GUIDE.md`, `docs/uat01/UX_FLOW.md`, `production/research/GUI_FREE_2026-10-13.md`, `docs/LAUNCH_GUILD_ISLANDS.md`, then current Luau/UI files and current status evidence. If a path has moved, find its replacement and document the mapping.
3. **Never** reset user progress, alter DataStore keys/schema, change game progression, class/status points, reward receipts, guild rights, market escrow, monetization, or world travel to match AI concept art. This is a PRESENTATION-focused initiative. Client sends intent; authoritative server validates.
4. **Never** auto-merge, publish any Roblox place, upload/replace Roblox assets, charge Robux/API/image-generation credits, activate disabled commerce/market, request credentials, change production data, or install unreviewed third-party code without separately scoped explicit owner approval. A feature that needs an unavailable backend must show a truthful unavailable state rather than inventing a working transaction.
5. Respect the shared **Forge ledger**, task dependencies, exclusive Studio/Blender write ownership, scoped branches, clean-source proof and independent review rules. `studio.py route` or an agent TOML alone does not start agents or grant acceptance. No parallel mutations to the same Studio state or shared source paths.
6. All images in this pack are **visual concepts**, not authoritative game screenshots or runtime UI assets. They may contain fictional names, made-up currencies, game classes, quests, statuses or numbers. Preserve the actual Guildborne source of truth over concept labels. **Do not upload a screenshot and call it implemented GUI.**
7. No externally sourced font files may be copied, committed or redistributed without separate license/engine review. Use Roblox-supported Font/FontFace fallbacks that render English and Thai correctly.
8. If a required live tool is absent, perform safe independent work, record `BLOCKED` on the affected integration gate, and tell the owner exactly how to unblock. Never fabricate tool output or a screenshot.

## 1. Definitive input & reference order

**Priority order when instructions conflict:** (1) AGENTS/repository security + owner permissions; (2) current game schemas, authoritative actions, and tests; (3) `src/shared/Config/Art.luau` + `docs/uat01/UI_ART_GUIDE.md`; (4) user-provided logo image; (5) 10 concept references for appearance; (6) third-party sample design systems. The concepts do **not** add game features.

Read `02_SPECS/DESIGN_SYSTEM.md`, `02_SPECS/TOOL_ADOPTION_AND_SOURCES.md`, `02_SPECS/ASSET_PIPELINE.md`, `02_SPECS/SCREEN_COVERAGE.md`, `04_TRACKING/GUI_SCREEN_REGISTRY_73.csv`, `04_TRACKING/REFERENCE_MANIFEST.csv`, and `04_TRACKING/QUALITY_GATES.csv` in this pack. Hash the original logo and images; never silently substitute or re-generate the approved source logo.

Reference images in `03_REFERENCES/`:

- `00_OFFICIAL_GUILDBORNE_LOGO.png` — **logo authority**. Preserve proportions/lettering/crest, don't stretch or redraw in an inconsistent way.
- `01_BRAND_UI_KIT.png` — branding, palette, typography, reusable controls, panel backgrounds.
- `02_LOADING_SCREEN.png` — loading, real readiness/status, tips; **no fake 73% or loading numbers**.
- `03_MAIN_MENU.png` — title/continue/home navigation and news preview (unavailable features disabled).
- `04_WORLD_MAP.png` — conceptual travel atlas and regional selection, but **canonical place names only**.
- `05_CHARACTER_STATUS.png` — character and attribute layout; **game actually uses STR/DEX/INT/VIT/WIS**.
- `06_SKILL_TREE.png` — branch nodes/connectors/learned/available/locked states; actual trees and unlocks from source.
- `07_INVENTORY_EQUIPMENT.png` — loadout, grid, filters, compare, tooltip; actual catalog/slots/ownership.
- `08_QUEST_JOURNAL.png` — categories, objectives, server-reported progress, tracking; actual rewards.
- `09_GUILD_MANAGEMENT.png` — Guild Hall, party, player guild, policies/roster, but avoid speculative online features.
- `10_SHOP_CRAFTING.png` — shop/crafting layouts; real purchases only if explicitly implemented and enabled.

### Visual specification

Aim for **Guildborne Regal Adventure**: adventurous, welcoming, upscale fantasy with original crest, embossed antique-gold metal edges, deep navy leather/stone panels, restrained burgundy banners/actions, ivory live text, selective arcane cyan jewel light, warm parchment for reading-heavy quest lore. Use the same header/icon grammar across screens; avoid overwhelming every gameplay HUD with a giant opaque menu/logo. The concept art is richer than the present native game: achieve visual continuity without sacrificing legibility, loading speed or mobile performance.

Canonical colors from `src/shared/Config/Art.luau`:

- UI.Background `Color3.fromRGB(15,21,35)` `#0F1523`.
- UI.Card `Color3.fromRGB(26,34,49)` `#1A2231`.
- UI.Text `Color3.fromRGB(245,236,216)` `#F5ECD8`.
- UI.Muted `Color3.fromRGB(192,199,186)` `#C0C7BA`.
- UI.Accent `Color3.fromRGB(220,183,107)` `#DCB76B`.
- UI.Button `Color3.fromRGB(91,39,53)` `#5B2735`.
- UI.Border `Color3.fromRGB(104,96,74)` `#68604A`.
- Optional gem cyan may derive from `Art.Palette.Magic` `Color3.fromRGB(109,190,195)` `#6DBEC3`, after checking legibility and current game VFX conventions.

Don't silently override the existing class/VFX colors. Contrast/readability take precedence over photo-realistic filigree. Define tokens for spacing, border widths, radii, panel layers, focus, hover, pressed, disabled, selected, ready, error, success, rarity (only where catalog supports it), typography and motion. Ensure selected state isn't indicated by hue only.

## 2. Preflight: inspect the installed tools, don't hallucinate capabilities

### A. Local baseline

Run safe, read-only commands first:

```powershell
pwd
git status --short
git branch --show-current
git rev-parse HEAD
python --version
python tools/agentic/forge.py doctor
python tools/agentic/forge.py validate
python tools/agentic/studio.py validate
python tools/agentic/studio.py verify
python tools/agentic/reconcile.py
python tools/agentic/ecosystem.py validate
python tools/agentic/ecosystem.py doctor
python tools/agentic/studio_mcp_preflight.py
codex mcp list
```

Run only commands that actually exist at HEAD; if missing, record that. Read `--help` of any new command before invoking it. Do not re-run a broad generator against existing approved status fields. Reconcile current count of screens and source bindings; the historical pack matrix starts at 73 but must not overwrite current source statuses.

### B. Roblox Studio MCP (official)

On the owner workstation: open the **correct isolated Guildborne Memory/offline test place**, enable `Assistant > Manage MCP Servers > Enable Studio as MCP server`, use official quick-connect to the Codex client where supported. Discover tools with the real MCP client, then confirm `list_roblox_studios`, selected Studio ID, place/universe, `get_studio_state`, allowed DataModel and exact schemas before ANY write. The official documentation describes tools such as `search_game_tree`, `inspect_instance`, `script_read`, `multi_edit`, `execute_luau`, `start_stop_play`, `screen_capture`, `get_console_output`, `user_keyboard_input`, `user_mouse_input`. **Only invoke those actually advertised for the connected session.** Keep Rojo filesystem as source of truth; avoid permanent Studio script edits outside tracked source. Do not target production Studio instances.

### C. Rojo

Existing repository pins **Rojo 7.7.0** in `rokit.toml` and checksum-pinned `tools/setup_tools.ps1`. Newer 7.7.1 exists, but DO NOT bump a pin in this task just to appear current. Validate sync/build/source maps with the currently pinned tools, using checked-in `default.project.json`. If user separately approves an upgrade, review release artifacts, update all pins and verified checksums, then verify Windows, CI, and compatibility.

### D. Blender + MCP (optional, restricted)

Use Blender primarily for **static ornamental source art** if truly needed: 3D crest mockups, golden frame relief, gems, shields, decorative corner pieces, material studies, and render passes on transparent backgrounds. Don't model native buttons/logic in Blender. Check installed Blender executable and version; prefer reproducible local Blender Python render scripts and editable `.blend` source. The community `ahujasid/mcp-for-blender` is NOT official Blender/Roblox software and can execute Python; use **only after** inspecting a pinned version/source, license, telemetry/privacy, imports, network behavior and approved local sandbox. It is not mandatory. If present, discover supported `get_scene_info`, `look`, `execute_blender_code` etc. before use; disable telemetry via reviewed opt-out when appropriate. Never run a network bootstrap installer silently or enable external paid 3D asset generation.

### E. Other connected design tools

If an actual **Figma** file/library is accessible, use it as an optional source for editable icons, reusable UI/component names, layout specs and export. If an actual **Canva** design exists, it may help with key art/banners, not replace interactive Roblox UI. Connected GitHub helps with PRs/evidence. Do not assert Figma/Canva projects exist or make any such connector a critical dependency. Optional image-generation tools can produce original nonfunctional ornaments/background art only if user-provided permissions, output license and cost policy allow it. Imported Kenney and Creator Store examples require per-asset review, even when Get Model has no displayed price. Treat scripts within downloaded templates as untrusted.

### F. Deployment boundaries

No blanket asset upload. Rendering a local PNG is not permission to import it to Roblox. `src/shared/Config/VisualAssets.luau` intentionally contains empty asset IDs; never replace them with guessed IDs. Audit actual rights, transparency and size; if a user explicitly approves the upload, use the current Roblox Studio or official Open Cloud asset flow, record real asset ID+permission+moderation state, and retain native fallback. Until then, implement in native Frames/ImageLabels/UIStroke/UIGradient/TextLabels and record import as PENDING.

## 3. Audit and coverage: ALL GUI, not only ten mockup screens

1. Parse the **current** `docs/uat01/intake/registry-reconciled.json` `screens` array; the inspected version contains **73 records (65 UAT01 + 8 FUTURE)**. Preserve every row/name/status; scan current `src/client/UI`, controllers, game schemas, `src/shared/Config/Localization.luau`, `VisualAssets.luau`, and user journey docs. Detect added GL2 screens not yet in registry. If registry and source disagree, record discrepancies explicitly rather than reset status to planned.
2. Produce `docs/gui/GUI_SOURCE_AUDIT.md` (or another bounded approved path): per screen, registry name/ID, status, runtime source, authoritative action, current bind/projection, visual reference, component dependencies, gating, test plan, device states. Link current file/line evidence and document other owner-scoped work packages that overlap.
3. Read `production/plan.json` and Forge scopes. Existing relevant tasks include `ux-system`, `brand-art`, `icon-art`, `localization`, `human-party-ui`, `p1-city-ui`; coordinate dependencies, existing 33 roles/10 workflows and up to 60 routes observed on 2026-10-16. **Do not create an independent second project plan or steal claimed scopes.** Reconcile and schedule via shared Forge ledger. If scopes clash, plan separate branches/handoffs and integrate serially.
4. Build a live screen-coverage matrix with classifications:
   - `BOUND_READY_FOR_RESKIN`: actual runtime and safe actions exist; style and test them.
   - `PARTIAL_REQUIRES_UI_INTEGRATION`: existing game logic exists but view or states are incomplete; implement the missing presentation/binding only.
   - `DESIGN_ONLY_BACKEND_PENDING`: make a review fixture or disabled honest preview, not an enabled production command.
   - `RESTRICTED`: paid purchase, public market, production war, external guild federation etc. only show current authorized read-only/disabled state.
   - `ACCEPTED`: only if a current real test and human sign-off meet the applicable evidence gate.
5. Do not use made-up names from the image references (`Aurenvale`, `Valorfall`, fictional item prices/reward values, fake mana/currency/stat examples) as canonical world facts. Guildborne cities are **Crownford, Sylvaris, Deepforge, Astralis, Crosshaven, Ironroot**, plus Central City, Greenwood, Ironveil, Ashen, Tower, Archive Heart, and actual Guild Islands. Use actual content IDs and service flags.

## 4. Architecture: native reusable Roblox GUI design system

Use **Native Luau** as the default. Reuse `src/client/UI/SliceUI.luau`, `MenuRouter.luau`, `TitleView.luau`, `StatusPointView.luau`, `SkillTreeView.luau`, `InventoryView.luau`, `CivicMapView.luau`, `GuildLandView.luau`, `MarketView.luau`, `SettingsControls.luau`, `ActorPortrait.luau`, `AssetImage.luau`, `ItemViewport.luau`, `SymbolIcon.luau`, and `src/shared/Config/Art.luau`. Search for new files at current HEAD. Keep the current `SliceController`, `AudioController`, `Localization.translate`, snapshot/selectors, network protocols and `MenuRouter` focus ownership. **Refactor/adapt; do not replace the game with a second ScreenGui controller or duplicate backend.**

Recommended modular structure (adapt names to existing files and Rojo mapping; not an instruction to overwrite):

```text
src/client/UI/
  DesignSystem/
    Theme.luau                  # derived from Shared.Config.Art.UI
    Typography.luau             # legal Roblox fonts, Thai fallback
    Spacing.luau                # density, responsive scales
    Assets.luau                 # approved runtime IDs + native fallback
    Motion.luau                 # reduced-motion-aware transitions
    Accessibility.luau          # focus, contrast, controller/touch
    UIComponents.luau           # facade (if appropriate)
  Components/
    GuildbornePanel.luau
    GuildborneButton.luau
    TabBar.luau
    HeaderBar.luau
    ProgressBar.luau
    StatRow.luau
    SkillNode.luau
    ItemTile.luau
    ItemTooltip.luau
    QuestCard.luau
    HeroPortrait.luau
    DialogueBox.luau
    NotificationToast.luau
    ModalDialog.luau
    CurrencyCounter.luau
    WorldMapMarker.luau
    LoadingState.luau
    ScrollableContent.luau
  [EXISTING VIEWS REMAIN, MIGRATED IN INCREMENTS]
```

Important: this tree is a **candidate implementation shape**, NOT proof the files exist or the Forge scope permits them. Claim/coordinate before writes, inspect `default.project.json` mappings, preserve module exports used by existing callers and add adapters instead of invasive rewrites.

### Component contracts

Every reusable component should expose clean data-in/config-out APIs, not call server remotes directly. State it needs includes id, label, icon/asset fallback, enabled/disabled, selected, pending/blocked, tooltip, localization key, input modality, callback, accessibility label, layout density, and optional size. Provide destroy/unmount/connection cleanup. Prefer simple explicit Luau constructors over adding Fusion, React Luau, Vide or Wally without measured justification and owner approval.

Required component families:

- Shell: top/side navigation, scalable content region, background/scrim, scene illustration layer, dismiss/close/back, focus shield.
- Frames: `Panel`, `Card`, `SectionHeader`, `Tooltip`, `Modal`, `Dialogue`, `QuestParchment`, `NoticeBoard`, `HeroFrame`, `ItemSlot`, `NineSliceBorder` and `Banner`.
- Controls: `PrimaryButton`, `SecondaryButton`, `DangerButton`, `IconButton`, `TabBar`, `SegmentControl`, `Toggle`, `Checkbox`, `Dropdown`, `TextInput`, `SearchBar`, `Stepper`, `Slider`, `Confirmation`.
- Display: `Gold/ResourceCounter` only for real currencies, HP/MP/XP bars only where actual data exists, player+five hero party cards, cooldown indicators, rarity chips only if catalog-defined, skill graph nodes/connectors, progress meters, error badges, input glyphs, toast queue, safe MapMarker, NPC speech card.
- Screen state: `Loading`, `Empty`, `Unavailable`, `NoConnection`, `ProfileNotReady`, `SavePending`, `RetryableError`, `ConfirmationPending`, `RestrictedByPolicy`, `DisabledFeature`, `Success`, `Locked`, `Busy`, `ReducedMotion`.

### Roblox-specific implementation choices

- First use `UIListLayout`, `UIGridLayout`, `UIPadding`, `UISizeConstraint`, `UIAspectRatioConstraint`, `AutomaticSize`, `TextWrapped`, sensible scaling, `UIStroke` and `UIGradient`. Support `ScreenGui.ScreenInsets` / core safe area, avoid cutouts and system controls. Respect preferred text-size settings and input focus.
- Review Style Editor/StyleSheet/StyleLink in currently connected Studio. If compatible with Rojo+current UI and doesn't conflict with current code-set properties, implement token/styling adoption incrementally; otherwise keep a tested Theme module and native style constructors. Do not assume there is a CSS renderer or that multiple StyleSheets can be linked to one UI tree.
- For ornate resizable borders, make **separate decorative transparent 9-slice images** where approved, configure `ImageLabel/ImageButton.ScaleType = Enum.ScaleType.Slice`, `SliceCenter` from actual image corners and scale. Text, icons, focus/hover and values remain live GuiObjects. Keep a native `UIStroke`/`UICorner` fallback if assets are unavailable.
- Use `ViewportFrame` for actually owned gear/hero preview; reuse `ItemViewport` and existing preview controls. No unbounded animation loops or offscreen expensive viewports; provide static fallback on low-power/mobile.
- No repeated client listeners/connections after `ui.render()`/reopen. No memory leaks, duplicate UI ownership or stale focus. Preserve gamepad back navigation and keyboard/touch support.
- Decorative `ImageLabel`s must have `Active=false`/sane ZIndex and never absorb touches. Buttons should use `Activated`, actual `Active`/`Selectable`, and preserve event source/protocol. Guard double clicks in UI **and** server transactional logic.

## 5. End-to-end visual production: follow the image reference while preserving live behavior

Split artwork into three layers:

**Layer A — brand source:** exact provided official transparent Guildborne logo, original crest/gold/red style, safe padding and aspect ratio. Create 1:1 source registry; make smaller logo placements by scaling same source only, not a new logo interpretation. Add alt/fallback `GUILDBORNE` text when runtime upload unavailable.

**Layer B — editable decorative primitives:** separately render/draw ornamental gold corners, shield/gem, medieval buttons (empty), tab border, dark panel textures, parchment center, header bar, ribbon banners, dividers, minimap border and optional card highlights. Source may be `.blend`, `.svg`/editable design file or native Luau builders. Produce PNG/RGBA UI art with alpha and documented dimensions. DO NOT crop a whole concept screenshot into a fake interactive screen. If deriving crops, only for nonfunctional background decoration after rights/visual QA and ensure no embedded labels or false numbers.

**Layer C — native interaction:** use actual TextLabels, TextButtons, frames, ScrollingFrames, progress indicators and event wiring. Resource numbers, skills, unlock requirements, language, class, equipment, quests, sale order details and state never come from reference PNG pixels.

For each final asset, record: source image, source path, editable file, asset ID (or empty until real approved import), SHA-256, license/origin, intended screen, UI element, transparency/edge test, 9-slice bounds if applicable, resize test, EN/TH text overlay, device test, owner approval and rollback/fallback path. Limit texture atlases and unnecessary full-screen image layers; avoid text embedded into textured artwork.

### Blender job restrictions

Blender may make convincing embossed metal **decorations**, not application behavior. Produce rendered alpha passes with transparent background, exact sprite bounding box, multiple sizes/densities, bevel/light material consistency. Keep editable sources and deterministic export scripts. Use `get_scene_info`, `look` and approved `execute_blender_code` only if actually connected; restrict code to project assets and maintain export proof. If Blender MCP is absent, proceed using native Roblox decoration or local Python/Blender only. Never generate paid 3D assets or pull unreviewed third-party mesh scripts by default.

## 6. Required screen families & acceptance

**Execute across the entire live registry, not just these top-ten concept classes.** Produce a functional first-party reference of each representative layout, then migrate every applicable screen in stable phases, with a visual and interaction audit of all 73 known records and new records discovered. No claim of 73 'completed' solely because a CSV lists them.

### 6.1 Loading / Title / Reconnect

- Authentic logo, cinematic background, live readiness indicator (if progress can't be measured, show indeterminate spinner/status, **not fake percentages**), locale toggle, safe Continue, retry/reconnect/error, save pending, legal credits.
- Actual `TitleView` readiness, `SetLanguage`, profile state and `MenuRouter`; do not bypass `ProfileReady`, save failures or startup controls. Lightweight loading at low bandwidth; no UI blocking through false transitions.

### 6.2 Main Home / Exploration HUD / Player + five heroes

- Hero portrait, name/class/HP/optional mana from real projection, buffs, Gold, up to five companion slots with correct health/away/downed states; compact quest tracker; context prompts; actual skill cooldowns/input glyphs; normal/hide HUD modes.
- Gameplay scene remains visible. The concept's huge GUILDBORNE logo is for title/full menus, not opaque 40%-height during combat. Support touchscreen, gamepad and keyboard layout; do not displace Roblox core UI.
- Must test player+five follower party with actual input, no HUD overlap with device safe areas and no fake ready/cooldown indicator.

### 6.3 World/City/Regional maps

- Concept atlas may be a **stylized informational illustration**. Real selectable destinations are only the canonical Guildborne cities/regions and currently server-authorized travel. `CivicMapView`, `CityWaypoint`, `QuestRoute`, existing position/waypoint and `TravelZone`/TravelService remain authoritative. Locked/undiscovered regions show requirements and disabled Travel; no client coordinate teleport.
- Use real quest marker and minimap data, map zoom/pan, map legend, waypoints, selected destination card, return/back, city/guild portal states, mobile drag/scroll guard. Fantasy map geography should not lie about actual zone connectivity.

### 6.4 Status / Character / Appearance

- Actual status allocation keys are **STR, DEX, INT, VIT, WIS** from `StatusPoints.luau`. The six mockup attributes (incl. Spirit/Luck) are decorative and must **not** become game stats. Respect real AP budget, soft caps, allocation step, blocked state, Hall/combat/expedition restrictions and `AllocateStatus` / `ResetBuildPoints` server intents. Display actual derived changes and confirmation. Respec must not duplicate AP/SP.
- Owned character model via `ViewportFrame` only with actual rig/fit permission; original equipment/comparison bindings. Character, hero and legacy save behavior must remain intact.

### 6.5 Skill Tree / Class

- Render actual `Rules.SkillOrder`, node requirements/paths, learned/available/locked states, trait exclusivity, actual unlock rules and `LearnSkill` action. Use node icons, connections, tooltip, focus paths, pan/zoom only as needed, list equivalent for touch/accessibility. Do not invent Cleave/Valiant Charge or free skill rank distribution from illustrations; no client-authoritative points.
- Visually test empty/new player, early class, blocked tier, unlock success, insufficient points, respec, and old persisted profiles.

### 6.6 Inventory / Equipment / Item Detail / Comparison

- True shared inventory, actors, existing slots, equipment ownership and stat calculations, item icon fallback, filters/sort/selection/search where data supports it, item details, comparing before equip, explicit sale confirmation. Preserve existing `EquipEquipment`, `UnequipEquipment`, valid actors and guarded save/transaction semantics.
- Do not invent Bag Capacity/rarity/legendary items from mockups if not in actual catalog. `ItemViewport` and native text fallback always work without uploaded asset IDs.

### 6.7 Quest Journal / Codex / NPC Dialogue

- Active Journal, main/side/class/guild quest types only where actual data supports them; tracked quest, location hint, objectives, claim-once rewards, EN/TH names, blocked/ready/completed. Source of descriptions/actual reward from server/catalog; decorative parchment section is reusable.
- Codex tabs for content that truly exists; disabled/empty states for future factions/bestiary. Dialogue must retain exact NPC/quest callbacks, not re-author gameplay story.

### 6.8 Guild / Party / Hall / Island / Building

- Distinguish **Personal Guild Hall** from **Player Guild** and any future Federation. Preserve guild membership, permissions, room/land placement, island directory, visitors, building rotation, materials and locked/purchase states. User interface cannot grant land/roles or create fictional shared treasury.
- Acknowledge paid land/theme offers can exist as policy/design but remain disabled until authorized. Show quest prerequisites, material delivery and permanent entitlement truthfully; don't create purchase success animation from a button click alone.

### 6.9 Shop / Forge / Crafting / Market

- Reusable design for shop cards and recipe detail, but actual displayed Gold, prices, recipes, source/sinks, inventory and confirmation are from the server-authoritative current catalog. Market must retain read-only/paused/claim states, order confirmations, rejection and receipt states. Do not enable public marketplace, unimplemented trading or direct Robux purchases.
- If commerce API has a blocked/indeterminate state in current source, keep the affected UI disabled; no bypass through a second route.

### 6.10 Tower / Boss / Event / Guild War / Future content

- Style all screens present in registry including class trials, ten-floor tower, bestiary, boss encounters, territory/war screens and future/federation/season design scopes. Make useful preview fixtures for unsupported screens, but do not claim fully integrated gameplay when the backend isn't implemented. Respect build flags and platform policies. Character progression/campaign level gates remain as committed in the live project; do not hardcode old 30/70 from historical reports when current rules differ.

## 7. Execution strategy: reference slice first, then complete all GUI

Work in small reviewable increments without indefinitely asking permission for ordinary local code/refactor work:

**Phase 0 — Proof of baseline and design intake.** Inventory current screens and states, match 10 refs to runtime surfaces, audit brand source logo, record free asset license and tool capabilities, agree active scope, inspect current Forge claims. Produce current matrix and source-to-component plan. This phase MUST include commands and source findings, not 30 pages of generic planning.

**Phase 1 — Reusable design system and internal native UI gallery.** Build an isolated offline/style-gallery place and component fixtures: buttons × all states, panels, menu shell, 9-slice fallback, inputs/tabs, toasts, loading indicator, skill node, item tile, hero portrait, quest card, map marker. Add EN/TH text and 360px viewport coverage. Use real Lua modules in Rojo. Must demo with actual Studio input if connected, otherwise record local-only checks and BLOCKED Studio gate.

**Phase 2 — Golden Vertical Slice**: FULL Title → Loading → Main Navigation → Exploration HUD (player+5 hero slots) → Status → Skill Tree → Inventory → Quest Journal → Back → persistent/blocked states. Do not change core gameplay logic. Make 10 reference-inspired images into coherent native layout on game state; verify actual click/gamepad/touch where available. Use screenshots of real Studio and compare qualitatively to reference; write differences.

**Phase 3 — World & Guild**: real world map/quest guidance, six city service UIs, travel constraints, Party/Hall/Guild Land, building and visitor states, shop/crafting with actual server data. Reconcile no invented currency, names or backend actions.

**Phase 4 — Entire Registry Completion**: process ALL current registry screens including 8 FUTURE designs (at least honest disabled mock/preview states), future launch/GL2 screens and actual new paths discovered. Update matrix after each screen; preserve current feature flags. No red flags disguised as a pretty interface.

**Phase 5 — QA/Performance/Release Candidate**: run original Luau tests, strict analyzer, project build, Python production checks, UI component/layout tests and real Studio playtests, 2/4 client QA where relevant, then Android/iOS physical input/performance separately. Independent reviewer checks brand correctness and real integration. Create PR with screenshots/coverage/testing gaps. Human art approval, live publishing and monetization remain separate explicit decisions.

Do not spend the entire run creating only documentation; build one real testable component or golden slice as soon as Forge dependencies and source audits permit it. For each phase, produce concrete source changes, tests, screenshot/evidence if possible and a safe resumable checkpoint.

## 8. Component behaviors, localization and input rules

- Languages: English **and Thai**; keep dynamic text outside textures. Use existing `Localization.translate`, don't replace translations with auto-translated English labels. Handle long Thai strings, no whitespace word boundaries, and dynamic amounts/numbers. Verify text wraps without clipping.
- Accessibility: text-size preferences, keyboard/gamepad focus, color+icon+label states, touch targets with usable minimum dimensions, scroll/slider alternatives, reduced-motion, visual contrast and failure messages.
- Screen classes to inspect/test: desktop 1920×1080, 1366×768, 1280×720, 1024×768, 390×844, 360×800, 320×568, plus Studio Device Emulator modes actually available. Derive thresholds from measurements, do not fake a device run.
- Do not force all menu tabs horizontally visible on tiny phones; use collapsed navigation, scrollable tabs or hierarchical menus. Icon-only controls need labels/accessible tooltips. `ScreenGui.ScreenInsets` and Core GUI must be respected. Landscape/mobile/portrait breakpoints must use actual Roblox safe areas.
- `GuiService.SelectedObject` focus must return to original control after modal closes. No duplicate `MenuRouter` registrations on every re-render. Popups block actions beneath but do not trap focus after dismissal.
- Avoid excessive `RunService.RenderStepped` loops or hidden viewport models. Capture measured instance count, UI draw cost, overdraw and memory on real target hardware; create budgets after the baseline. No frame-per-second performance claim without hardware evidence.
- Snapshot corruption, `Loading`, `Failed`, `Degraded`, `LeaseLost`, offline, missing icon/image, unavailable locale key, no items/no quests, sold-out shop, market PAUSED and double-submit are first-class visual states.

## 9. Required test & evidence ladder

Never equate these levels:

1. **SOURCE_AUDITED**: existing view/protocol/schema traced; no tests implied.
2. **DESIGN_SPECIFIED**: mockup and tokens reviewed; not built.
3. **ASSET_GENERATED**: local PNG/.blend/SVG exists and its SHA is recorded; no Roblox import or rights claim implied.
4. **NATIVE_COMPONENT_BUILT**: code + deterministic unit tests with actual observed results.
5. **ROJO_BUILT**: actual pinned Rojo build and sourcemap/strict Luau checks pass.
6. **STUDIO_PLAYTESTED**: actual connected approved Studio session; real visible UI screens, normal user inputs and console output captured.
7. **MULTIPLAYER_TESTED**: actual two/four-client same-server proof; no false cross-server certification.
8. **PHYSICAL_DEVICE_TESTED**: actual Android/iOS hardware evidence, touch and performance recorded.
9. **HUMAN_ART_UAT_ACCEPTED**: owner visual/UX approval specific to screens/assets.
10. **RELEASE_APPROVED**: separate explicit authorization to publish; cannot be auto-granted.

Validate with current approved commands (inspect path/flags first):

```powershell
python -m unittest discover -s tests/agentic -v
python tools/agentic/studio.py validate
python tools/agentic/studio.py verify
python tools/agentic/reconcile.py
pwsh -File tools/validate.ps1
# Existing repo's isolated preview build and relevant targeted UI tests: inspect --help and docs first.
```

Collect real screenshots with `screen_capture` **only when Studio MCP advertises it**. A generated concept image is not a Studio screenshot. Test representative fixture interactions before overwriting main visuals. Use a current owner-approved isolated Memory preview and no production namespace. Test visual quality at multiple viewport sizes, keyboard, gamepad, touch, EN/TH, no-data, duplicate-submit, stale state, and no asset permissions. For asset imports, record real IDs/permission/review. For every screen keep screenshot/evidence paths, exact commit/tree, source, test result and open problems in `docs/gui/GUI_ACCEPTANCE.md` and machine-readable coverage.

### Hard stop conditions

Stop dependent task and report if: wrong Studio place, conflicting Forge ownership, unknown UI protocol, baseline regression, uploaded image permissions absent, purchase/payment path would be activated, untrusted model/asset script, cross-server evidence falsely inferred, expected action cannot be observed, unsafely mutated DataStore, loss of session, or status no longer matches revision. Keep unrelated safe work moving.

## 10. Deliverables, reporting and next actions

Create/maintain these artifacts **inside Guildborne repo with scope coordination**:

1. `docs/gui/GUI_SOURCE_AUDIT.md` — screen-by-screen source/protocol/flags/owner map and historical discrepancies.
2. `docs/gui/GUI_DESIGN_SYSTEM.md` — brand tokens, typography, component API, states, reference mapping, runtime/fallback asset manifest.
3. `docs/gui/GUI_SCREEN_COVERAGE.csv` — every current registry screen and new screens; status from actual evidence, not wishful labels.
4. Native reused `src/client/UI/...` modules plus relevant tests and actual representative screen integration.
5. Editable local design assets (approved source) with hashes; do not claim concept screenshots are runtime images.
6. Isolated component gallery/staging preview and actual evidence captured when tool exists.
7. `docs/gui/GUI_ACCEPTANCE.md` — results by surface, viewport, language, input/device and evidence level.
8. `docs/gui/GUI_REMAINING_GAPS.md` — missing backend vs cosmetic vs device vs publication gates, owner and next step.
9. A reviewable GitHub PR with exact diff, build/test commands/results, screenshots and PENDING gates. **Do not auto-merge or publish.**

At the end of EACH session output:

```text
GUILDBORNE GUI PRODUCTION CHECKPOINT
- Repo / branch / HEAD:
- Current task / claimed Forge owner / shared ledger:
- Connected tools actually discovered:
- New/modified files:
- Screens covered vs total registry and additional GL2 scope:
- Screens with native UI + action integration:
- Tests EXECUTED and actual results:
- Visual comparisons against images 01–10:
- Asset IDs actually imported / pending:
- Studio, gamepad, mobile, multiplayer evidence separately:
- Blockers and safe fallbacks:
- Next bounded task + specific owner:
- PR URL or reason not ready:
```

## 11. First executable instruction — START NOW

**Do this next rather than writing a theoretical plan:**

1. Verify repository, branch, files, official logo + 10 image SHA, Forge ownership and available MCP capabilities.
2. Extract **all current screens** and source-to-screen mappings; write a concise current audit with concrete file links.
3. Identify a safe claimed UI scope (prefer `ux-system`) and build a native **GuildborneButton + GuildbornePanel + TabBar + Header** design-system slice that uses live `Art.UI` colors and image-safe fallbacks. Use visual reference `01_BRAND_UI_KIT.png`.
4. Integrate the reusable slice into one **actual existing screen** (prefer Title/Continue or an isolated review GUI if current ownership prevents editing Title); **do not** break `TitleView`, `MenuRouter`, runtime state or `SetLanguage`.
5. Run actual targeted tests and Rojo build, then connected Studio visual/interaction tests if available. If Studio is not connected, report that gate BLOCKED and show local evidence only.
6. Checkpoint source and proceed to Loading/Main Menu/HUD/Status/Skill/Inventory/Quest and then all other screens using the sequence above. Work continues until quality gates or owner permissions require a stop; never declare completion from a picture gallery or generated docs.

**Priority for design review:** The owner should approve the reusable foundation and first integrated screen (desktop and mobile) before you apply it across all 73+ screens. Continue audit/test work in parallel only where scopes and mutable tools do not overlap.

### End-state definition

The project is genuinely UI-complete only when every required current screen has consistent Guildborne branding, truthful enabled/disabled state, real action bindings, EN/TH readability, verified navigation and recovery, gamepad/touch usability, no authoritative game regressions, performance evidence and explicit human visual acceptance. A generated screenshot, completed Markdown file, green CI badge or successful tool connection alone is **not** completion.
