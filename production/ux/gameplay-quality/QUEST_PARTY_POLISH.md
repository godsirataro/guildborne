# Quest and party presentation wave

Reference inspected locally: design/guildborne-gui-production/03_REFERENCES/01_BRAND_UI_KIT.png (SHA256 94026d40fdea2713c4c918e80a5cd35cba4d18bbf2f30702649f9e4c8d687590). Selected language: engraved navy surfaces, restrained gold relief, burgundy heading/selection bands, ivory identity text, and azure state accents. This is native component work in the actual game modules, not a painted screenshot overlay or a new preview artifact.

## Visible changes

- QuestTrackerView: native engraved highlight/shadow, wide burgundy heading ribbon, gold diamond seal and exclamation fallback. A true ready state replaces the exclamation with a native check silhouette. Optional existing questIcon pixels can load without hiding the fallback prematurely. Keyboard focus and hover now have an explicit rim state; disabled controls do not highlight as interactive. Nonfinite progress hides the progress fill.
- Compact tracker retains its exact outer bounds, two-line text rectangle and existing 12/14px font selection. Large seal/ribbon/corner ornaments are hidden in compact mode. This protects established top-bar clearances; the compact visual change is restrained engraved edging, not a new expanded card.
- CombatChrome and PlayerCombatController: native navy portrait mount/gold rim; selected actor gets a burgundy top ribbon, gold rail and azure diamond. Name and HP occupy separate lanes: name13px (12px in narrow cards), muted HP10px. Portrait and card sizes, actor selection actions, real replicated health, and up to five companion semantics remain unchanged. Long names explicitly truncate; no claim that all names TextFit.

No new images, image edits, runtime IDs, uploads, services, title changes or economy changes. Existing optional local image bindings remain intact. Original1254px art export limitations are unchanged.

## Controller-reported gameplay findings addressed

- protect_companion and defeat_forest_guardian resolve matching living owned encounter identities and their canonical streamed markers. Direction-only hints have no world-beacon anchor. Missing/dead/foreign/mismatched encounters remain unavailable.
- return_forest_evidence retains the Greenwood-to-city-to-public-guild-portal route while the island Registrar is unstreamed. The final island destination still requires its real marker.
- The visible ManagementPanel and existing GuildborneMenuOpen state supplement MenuRouter blocking, hiding route card/banner/compass without clearing the selected quest. This also tolerates independently loaded navigation modules during controller review.

## Validation and inspection handoff

Independent source reviews cover UI and routing separately. Local GUI harness:41 cases (12 foundation,13 gameplay,12 waypoint,4 tracker polish). Full baseline passes899 regression cases plus Rojo build/sourcemap, Roblox analysis, compilation and repository checks; route suite includes14 scoped cases. Raw complete baseline and GUI outputs are checks/quest-party-baseline.log and checks/quest-party-gui.log. No screenshot or render was produced by this worker; simulations do not measure native glyph fit, real touch input, streamed geometry or rendered layering. Prior controller observations do not accept this candidate automatically.

Controller Studio inspection: at796x674 compare party name/HP hierarchy and selected portrait frame, and verify compact tracker clears gold/menu. At desktop1024x768 inspect wide seal/ribbon in active, ready, unavailable and loading states, with local images absent then bound. Check EN/TH, long names, keyboard focus, all five heroes, compact portrait/landscape and unchanged combat-pad/nav interactions. Open/close Management while a quest is pinned; repeat forest combat targets and city return portal retargeting. 320x280 remains unsupported for the navigation card as documented in COMPASS_CARD_FIX.md.

Coordination uses gameplay-ui-quality on four-session-v4.sqlite3 only. Controller owns Studio; this worker did not touch Studio or Blender. Deliver one local commit, no push/PR/merge, then release lease.

Next gap, deliberately outside this bounded wave: controller reached earned chapter7 UnequalWeight/Hall2 and reported island-to-Ironveil scales guidance unavailable (controller evidence a926370). This candidate does not claim to fix or accept that route.
