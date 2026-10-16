# Gameplay UI review slice — 2026-10-17

Status: IMPLEMENTED_LOCAL_CHECKS; Studio, device and human visual acceptance remain pending.

This slice replaces the Journal presentation and adds native combat/tracker chrome. It does not implement all 73 screens or claim parity with the ten painted concepts. Existing server actions, progression, currency and save contracts remain authoritative.

## Integrated behavior

- Journal uses actual catalog order, quest projection, prerequisites, item stock and existing AcceptTask/ClaimTask/Track intents. Wide layouts show list and detail; narrow layouts switch list/detail with a back control. English and Thai labels use the existing translator.
- Combat HUD uses real player/hero names, up to five companions, existing portraits, replicated HP and cooldowns. Absent actors stay hidden. Large portrait cards are restricted to desktop space; compact bounds remain covered by layout contracts.
- Tracker shows actual projected progress and hides while a blocking menu owns focus. Missing/non-numeric progress has no fabricated fill.
- Quest navigation resolves the owner's replicated island, moved Hall, bridge, promenade, portal and campaign objective markers. Menu-only/unresolved island tasks keep their selection and expose unavailable directions instead of inventing a destination.

## Local art binding

See `ASSET_SELECTION.md` and `assets/production/ui-slice/manifest.json`. Four licensed original PNGs have source hashes and null runtime IDs. Keys are `panelBorder`, `parchment`, `questIcon`, `partyIcon`; `QualityAssetKey` is assigned before parenting. Native text, controls, fill and borders remain usable with no image binding. Coordinator's separate local EditableImage binder can supply pixels; this is not a Roblox upload/import.

## Preview

Run `python tools/build_gameplay_ui_review.py`, then open `build/gameplay-ui-review/GuildborneGameplayUIReview.rbxlx` in Studio and Play. The fixture uses real UI modules and static catalog with explicitly simulated state. Bottom controls switch language/view, advance simulated progress and reset. It has exactly one LocalScript and no server scripts or remotes. The HUD sample is illustrative fixture state, not an earned player party or live cooldown test.

## Evidence and remaining review

Raw local command outputs are under `checks/`. The full baseline runs game regression, Rojo build/sourcemap, Roblox definitions analysis, compilation, repository checks and whitespace validation. GUI simulation and numeric viewport bounds are separate checks; neither proves rendered pixels, touch input or physical performance. Existing Title test injected `Services` globals produce analyzer warnings; they are not runtime UI failures.

Final local results: 894 game regression cases passed; 12 existing plus 10 gameplay GUI simulation cases passed; 35 combat layout viewport cases passed. Full `tools/validate.ps1` exited successfully. Preview SHA256: `d15b127490a1ca854cc9e0333cec8a256a0def3c42d28635dace6b4eaae775bc`. Independent follow-up source review confirmed the island fix with no blocking findings in the scoped changes. This packet is REVIEW-only, not external acceptance.

## Original visual references for coordinator comparison

User-attached master document: `C:/Users/godsi/Downloads/Guildborne_Full_GUI_Master_Prompt_2026-10-16.md`. User-attached image paths below were supplied in the original session; temp-file availability must be checked before using them. All are under `C:/Users/godsi/AppData/Local/Temp/`:

| Reference | Filename |
|---|---|
| 1 Design system | codex-clipboard-b753a13a-4850-4496-8d7a-b8123fcda3d7.png |
| 2 Loading | codex-clipboard-a2f7703e-5b23-4a2f-9bf0-d6d718c6f2a1.png |
| 3 Main menu | codex-clipboard-b95b1783-5640-4c13-a15e-e77ba53ea7f9.png |
| 4 World map | codex-clipboard-bfadd763-ea91-4def-ac10-b8dcf4331236.png |
| 5 Character | codex-clipboard-0357402c-efa6-47f3-90a4-d49cdab5475d.png |
| 6 Skills | codex-clipboard-5a5b4c07-0974-47ed-b110-ad9f341a7d61.png |
| 7 Inventory | codex-clipboard-5a32a322-b288-49eb-a47a-4c384d53b4b9.png |
| 8 Journal | codex-clipboard-acd085b7-0985-4efb-acb9-674503838b6f.png |
| 9 Guild | codex-clipboard-6fbcaada-fe36-46e7-a31a-b00a4d361745.png |
| 10 Shop/craft | codex-clipboard-e69d9cd1-c530-4219-8699-625d325b9eba.png |

Compare Journal against reference 8 and the HUD component language against reference 1. The integrated game has no fixture HP/profile substitution: `PlayerCombatController` reads real actors and replicated attributes. Only `tests/gui/gameplay_gallery.client.luau` contains labeled fixture values (72/100 HP, 3.2s cooldown), and default.project.json does not include that fixture.

Independent code review found an island exit for menu-only quests; this was corrected and covered by regression. Native Thai wrapping, narrow long labels, portrait appearance, image slicing, controller focus and the live island journey still require coordinator-owned Studio review. No Studio/Blender session, publishing, paid upload or production save was used by this worker.
