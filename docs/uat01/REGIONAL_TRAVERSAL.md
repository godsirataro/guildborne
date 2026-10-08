# Regional traversal checkpoint — 2026-10-03

Greenwood, Ironveil and Ashen are connected to city portals in the owned offline build. Each has a separate arrival, fallback landing, disabled checkpoint spawn, return portal and two gathering nodes. Gathering uses the existing authoritative inventory, cooldown and quest transaction path. Regional encounters remain disabled; the encounter/reward catalogs are not evidence of live combat.

The full domain suite passed 425 tests (including 5,000 market orders with zero invariant violations). A fresh Studio play session passed `studio_regions_travel_probe.luau`: 675 checks, 18 no-jump paths across all three regions, six gathering nodes, no profile writes. This checks native pathfinding connectivity, landing support and clearance; it is not multiplayer or device acceptance.

Subsequent checkpoint: a standard R15 physically walked all9authored routes over approximately1,402studs on the updated142part maps. The probe's progress marker was moved from its optional Script context to its own fixture so it also runs directly through MCP. All fixtures were removed. Later offline-only player combat integration is tracked separately in [regional combat](REGIONAL_COMBAT_OFFLINE.md); the traversal-only results above predate that activation.

The probe discovered a disconnected navigation mesh on Ashen's elevated Warden ramp. A solid foundation fills its three-stud underside void. The source generator and native map now contain 142 parts. Regenerated Blender exports must remain paired with this geometry. Existing nine physical R15 route-walk results predate this foundation and are historical evidence.

Strict analysis, compilation, repository checks and the memory-only offline build passed with 174 runtime Luau files. Greenwood's earlier real UI portal/gather/Mogra-quest evidence is recorded in `GREENWOOD_TRAVERSAL.md`.

Real UI follow-up passed in the owned memory-only Studio session: E entered Ironveil; hold-E collected two stone and two iron ore (revision 3); E returned to City and then entered Ashen; hold-E collected two stone and two herbs; E returned to City (revision 8, final stacks stone=4, iron_ore=2, herb=2). The first rapid Ashen entry was too early for travel cooldown, so the test retried the ordinary E prompt. One diagnostic assertion occurred before that retry; no gameplay script exception was involved. Server character repositioning shortened walking between prompts, while every travel and inventory transaction used the actual client interaction. No direct inventory grants or cloud writes occurred.

All six regenerated FBX/GLB map exports passed round-trip part, triangle and bounds checks. The three editable Blender scenes and previews match the updated source geometry.
