# Native coast regression and inventory findings

2026-10-19. Controller a763e92; original quality candidate
103f38e3106595e8c3e5bbc19ff22f7211633a58ab723ecf0a4aed1c839b5679.
Disposable Studio 1ec0bd16-505e-4eee-815a-2c8cfbb63547, PlaceId/GameId0.
Disabled previous combat fixtures and normal bootstraps in Edit. Installed 26
quality sources plus ContinuousPartyFixture and three attribute groups. Read
back 385 game sources plus 27 fixture/art sources with CRLF-to-LF normalization,
all equal to local packets before Play. Memory and empty allowed-store guards
passed. This is a modified disposable place, not whole-place hash equality.

Dataset2 coast source79e3c3ea39f702ee77d6765ea41d0dffbdbc9cd4a1c674faa1a01832e82f807f
loaded READY_LOCAL_ONLY:67 placements,5676 unique triangles,.7924504 seconds.
All67 native parts anchored/noncolliding/nonqueryable/nontouching. Dataset1
reports116 placements45267 triangles14.7547229seconds; its world binding means
no top-level QualityArt_Dataset1 folder, not a failed import. CollisionReady=true.
Raw tool response: COAST_NATIVE_RAW.json.

Actual synthetic five-companion round trip: PASS_NATIVE_FIXTURE,1496 samples,
79 segments, max separation24.3721504, max sampled displacement4.53515625.
All five alive, recovery counters unchanged at1, final zone and respawn City,
no active walking context, rewardCalls0. Raw report: COAST_PARTY_RAW.json.
This covers current multi-route-ready source on the active City-Greenwood edge,
not a new active edge, earned eligibility, rewards or full campaign acceptance.
Stopped Play after recording terminal evidence.

MCP capture coast_native_oct19_road reviewed at(-320,11,-250) toward
(-323.33,8,-178.33). Road readable; bare roadside slopes and plain old watchspire
remain visually inadequate. Tool image exists in conversation, no PNG archive
claimed. S13 continues bespoke watchspire work; human art/device gates pending.

## Inventory candidate fails native acceptance

Worker41be870+9f910f4 independent source review found no initial source blockers.
Controller reran12 actual InventoryView behavior cases and5 pane simulations,
all passed. Their mocks did not expose the following native engine behavior.
Opened exact fixture SHA5cbed1669c28fc51d4694f944c86d7bf12278f5e03b1182808f70628198a7a86
in disposable803f427b-0082-4f62-8e09-4ddb616aa01b. Edit guard: Place/Game0,
one LocalScript, zero server Scripts/remotes. Actual fresh Play at796x675 EN
showed one InventoryPane with two copies of each of seven direct components,
52 text objects, and no player portrait despite actual Character23 children.
All visual direct children Archivable=true; only nine Sounds and Status were
non-archivable descendants. Root Archivable=false; both actor WorldModels empty.
INVENTORY_NATIVE_BLOCKERS_RAW.json preserves duplication/non-archivable readback.
Capture inventory_native_796_en_initial exists in tool history only. TextFits0
failures did not establish correct layout. Worker identified missing draw
reentrancy guard; portrait cause remains under diagnosis. No integration/native
PASS claimed. Stopped preview Play before handing exclusive Studio ownership back.

Rojo7.7.0 server started against Guildborne-inventory/build/inventory-review/
review.project.json at127.0.0.1:34872, session76777. API identifies project
GuildborneInventoryReview. Listening server is verified; Studio plugin connection
and sync are NOT verified. No unrelated Studio scene was synchronized.
User-opened Blender process53340 observed; no Blender MCP tool exposed here.
S13 owns Blender inspection/authoring. Codex usage41% used59% remaining.
