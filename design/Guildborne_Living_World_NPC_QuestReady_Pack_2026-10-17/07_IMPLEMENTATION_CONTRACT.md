# Guildborne Living World — Proposed Technical Contracts (not runtime source)

**Status: DESIGN CONTRACT — not an implemented feature.** Adapt to the existing Guildborne `FriendlyNpcs`, City and Quest/Journal, Appearance and Profile services. Do not create duplicate persistence/quest systems. The Master Controller must reconcile owner and Forge write scope before new runtime modules.

## A. Stable IDs / three layers

1. **NPC Content identity**: stable named `npcId` (e.g. `marshal_elian`) for an authored person, or namespaced `proposed.city.crownford.clockmaker_01` for a nonapproved fictional concept. NPC identity must never be derived solely from display name, race, mesh, spawn part path, or random generation index.
2. **Physical world instance**: ephemeral clone/visual with `instanceGeneration` and `zoneId`; multiple players may see different LOD renderings, but their actual quest receiver is always the same verified server-owned canonical NPC identity. World/civic Chapter5 identity duplication is a separate migration; do not fake it.
3. **Appearance selection**: canonical `CHR_BDY_*`, `ACC_*`, `CLO_*` or data-backed appearance IDs and a deterministic stable seed, independent from gameplay ancestry/stats and separately tested for imported rights/fit. A new NPC outfit is not granted to player inventory.

### Proposed NPC definition shape

```lua
-- SCHEMA ILLUSTRATION ONLY: not an actual current table from GitHub.
return {
    npcId = "marshal_elian",                -- reuse actual canonical identity
    zoneId = "City",                      -- resolve against actual WorldGraph
    homeAnchorId = "EXISTING_APPROVED_ANCHOR",
    roleId = "civic_marshal",
    appearance = {
        raceCosmeticId = "HUMAN",
        bodyPresetId = "CHR_BDY_HUMAN_STANDARD_V01",
        visualStatus = "REQUIRES_APPROVED_IMPORT_OR_NATIVE_FALLBACK",
    },
    scheduleId = "city_marshal_day_v1",
    interaction = {
        dialogueId = "existing_localized_entry",
        serviceIds = {},                   -- verified existing services only
        questHookIds = {"elian_charter"}, -- existing ID, verify exact binding
        secretHookIds = {},               -- empty until designed and approved
    },
    contentRevision = 1,
    permanentMemory = false,              -- do not persist daily action positions
}
```

**Validation rules:** stable `npcId` unique among named actors; `zoneId` in real config; `anchorId` in authorized map roster, schedule states bounded; no arbitrary `Instance`, URL, command, uploaded model ID or client-supplied Quest/Reward fields; asset refs catalog-approved; templates keyed/versioned; race cosmetic cannot override authoritative class/ancestry.

## B. Shared world clock / deterministic schedule

- Server-owned world time or reviewed existing environment time, never client clock authority for rewards.
- Relevance-driven updates in batched bounded cadence; an offline NPC's next plausible station derived from time and finite schedule data, **not** simulated every step while unseen.
- Schedule transitions: `HOME -> COMMUTE -> WORK -> LUNCH -> WORK -> SOCIAL -> REST`; specialized residents may have `PATROL`, `TEACH`, `ATTEND_EVENT`, `TRAVEL`, `DIALOGUE_INTERRUPT`, `FLEE_SAFE` where permitted. Child NPCs use safe play/learning/family return only.
- Persistent important NPC identity and quest relevance survive visual culling; current interactions resolve their verified, current physical reachable station and fallback, not historical stale coordinates.
- FSM event priority: active server-verified quest/civic service > required dialogue > safe interruption > casual schedule > ornamental idle; all terminal transitions cancel prior work/movement/audio safely.
- No separate per-NPC server script or per-NPC unbounded pathfinds; use a fixed shared path scheduling queue, path caching/recomputation thresholds and distance/complexity budgets proven by test.

## C. Resident generation and anti-clone

- `PopulationPlan[zoneId] = {registeredTarget, activeBudgetProposal, roleWeight, districtNodes, seedSalt, minimumCritical}` with initial targets a **design hypothesis**, configurable and backed by actual frame/memory results before shipping.
- Unique heroes/story actors/quest hosts are **critical** and never dropped by generic density culling. Ambient civilians may be virtual and can be instantiated near a player with no persistent stores.
- Weighted selection must be reproducible per `npcId`/zone/campaign day; avoid same exact outfit/head/hair near each other using deterministic local visual-group selection.
- An ambient NPC promoted to a future quest actor gets an explicit, versioned stable identity and appearance mapping, never reuses the name/ID of existing Rowan, Elian, Nyra etc.
- Per-zone distribution respects actual shops/lanes/buildings; no spawning children near combat boss patterns, players' private plots or locked rooms; no npc footprint blocks 5-hero routes. Use safe collision and fall recovery.

## D. Quest-ready hook contract

- `questHooks` are **references**, not executable rewards. Each unbound hook must resolve `NOT_AVAILABLE` and stay absent from UI actions; never become accepted by default.
- All interactions use server-authoritative `PlayerDataService`/`Commands` + existing quest/catalog/receipt validation. Validate `owner`, `actor`, `npcId`, `zone/anchor`, actual distance, prerequisites, quest revision/state, active session/epoch and rate limits. Do not use only ProximityPrompt enabled/MaxActivationDistance as authorization.
- The dialogue UI requests an intent only and observes **committed** rewards; interrupted or uncertain commits remain in SavePending/recovery; no duplicate Gold/XP or hero reward even when clients spam.
- Secret lifecycle can include `HIDDEN`, `RUMORED`, `DISCOVERED`, `ACTIVE`, `READY`, `CLAIM_PENDING`, `CLAIMED`, `BLOCKED`, `RETRYABLE`; discovery is gated by server evidence and requires versioned, bounded per-player state only when actually implemented.
- Preserve existing main quest `MAIN_00_01...` and six chapter catalogs, including story hidden routes; separate design-only proposals from canonical shipped IDs.

### Sample unapproved secret *specification* record

```json
{
  "secretConceptId": "proposal.crownford.lost_seal",
  "status": "DESIGN_ONLY",
  "npcIdCandidate": "proposal.crownford.clockmaker_01",
  "zoneId": "Crownford",
  "clueAnchors": ["REQUIRES_S13_VERIFICATION", "REQUIRES_S13_VERIFICATION"],
  "clueTexts": {"th": "ฉบับรออนุมัติ", "en": "DRAFT: review required"},
  "actualQuestId": null,
  "rewardAuthority": "UNDEFINED_NOT_ENABLED",
  "noMandatoryProgressionGate": true
}
```

## E. Visual & rigging integration

Existing baseline: 13 body IDs / 4 races, original appearance registry planned, Human Standard/Heavy source-derived experiments, R6 hero/gameplay proxy and 16-bone civic cast. A flexible garment must have a genuine imported mesh with valid cage pair and explicit per-preset fit; rigid attachments may be used appropriately but never mislabeled layered garment proof. Body root/collider and combat ranges remain unchanged by cosmetic appearance. Children require separate safe age/stature authoring/physics assessment if small rigs are added.

Artifact status ladder: `PLANNED -> SOURCE_CREATED -> DCC_VALIDATED -> IMPORTED_WITH_PERMISSION -> STUDIO_FIT_PASSED -> GAME_INTEGRATED -> DEVICE_PASSED -> HUMAN_APPROVED`. These are **separate evidence events**. An existing fallback should remain available whenever an optional visual asset cannot load; NPC quest reachability must not depend on the mesh.

## F. Acceptance and profiling

Instrumentation should record real (not fabricated): `registered`, `logical`, `physical`, `interactive`, `humanoid`, `animated`, `pathRequestsPerSecond`, `visibleInCamera`, `instancesByZone`, `memoryBefore/After`, median and 95th percentile frame time, network send budget, cleanup count, actual test scene/device and source SHA. Budget numbers are selected **after** profiling device/party; proposed resident targets do not imply memory or hardware FPS commitments.

QA must distinguish:
`SOURCE_AUDITED`, `LOCAL_TESTED`, `STUDIO_SOLO_TESTED`, `STUDIO_SIMULATED_MULTI_CLIENT_TESTED`, `DISTINCT_SERVER_TESTED`, `PHYSICAL_ANDROID_TESTED`, `PHYSICAL_IOS_TESTED`, `HUMAN_ART_APPROVED`, with actual evidence for each. A StudioTestService simulated multiplayer server is NOT cross-server proof; emulator is NOT physical device.
