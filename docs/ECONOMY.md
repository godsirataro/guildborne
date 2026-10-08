# Game economy

> Launch scope decision — 2026-10-02: The user requires personal guild islands, portals in every launch city, public/friend visits, quest-gated Robux plot purchases with required material contributions, freely positioned buildings and purchasable permanent mixable building themes together in the FIRST public game release. See [authoritative scope and acceptance](LAUNCH_GUILD_ISLANDS.md). This supersedes older deferral of these specific systems, including theme monetization to Phase9; other release gates remain. Development resumed by the user on2026-10-03. Earlier15%quota pause is superseded; current evidence and remaining launch work are recorded in [the implementation checklist](uat01/WORK_CHECKLIST.md).

> Phase 4.5 update (2026-09-29): Phase 4.5 preserves Gold/item transfer and fee rules. Epoch closure refunds only remaining escrow; archival preserves cumulative burned fees and requires zero pending claims. No new faucet, price rule or real-money feature.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): Phase 4 now transfers Gold/items through durable escrow and burns a configurable 5% seller fee (cumulative ceiling per order). Trading uses market.goldIn/goldOut, separately from quest faucets and ordinary sinks. Only five allowlisted materials trade; no real-money or Robux conversion exists.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


> Current update — 2026-09-28: Current city economy: 20 earned Gold per candidate scout, ranked hire fee, Hall/Tavern/Quarters upgrades, bounded offline dispatch rewards, and 1,000 Gold revival Elixir. Optional 49 Robux fixed-item product is planned but unconfigured (ID 0). No Gold purchase is available. See [odds, costs and rules](CITY_GUILD_DISPATCH.md).

Status: Phase 0 economy direction retained. Phase 1 implements only quest Gold/items, recruitment and Hall sinks, XP and weapons. Actual rewards/costs are in [game design](GAME_DESIGN.md) and [Content.luau](../src/server/Config/Content.luau); later market/crafting numbers below remain proposals, not live prices or promises.

## Accounting units and boundaries

Phase 1.6 adds optional Knight and Mage recruits at 20 Gold each, with compatible starter weapons. The original three-class tutorial/Hall budget remains unchanged; recruiting both additional classes requires earned repeat-quest Gold. Recruitment remains deterministic, one per class. There are no paid packs, rarity odds, weekly resets or cash-out rates. See [the expansion](PHASE1_6_IMPLEMENTATION.md).

Gold is a nonnegative integer soft currency, earned through play and spent in the game. XP belongs to adventurers and cannot be traded. Items have stable definition IDs; stackable commodities use integer counts, and equipment uses unique instance IDs. No fractions, negative holdings, NaN, infinity, or implicit conversions are valid.

Set operational caps well below exact-integer arithmetic limits. Proposed limits: 1,000,000,000 Gold per personal wallet, 1,000,000 units per stack, 1,000,000 Gold unit price and 1,000 units per market order, with checked products/sums. These are application policy, not platform quotas. Validate intermediate fee multiplication and the maximum aggregate ledger value, too. Cap violations block the operation or retain rewards in a bounded pending claim; never clamp away player property.

Keep three domains separate: Game Economy (Gold/items/market), Platform Monetization (verified account entitlements), and Future Settlement Adapter (**DISABLED, NO IMPLEMENTATION**). The last is a documented boundary only: no module, endpoint, credential, feature-toggle activation path, exchange rate, or payout schema exists. Any future legally and platform-authorized integration requires a new architecture review. No Gold/Robux/THB/USD conversion is defined.

## Faucets, transfers, and sinks

| Asset | Faucets | Transfers, not creation/destruction | Sinks |
| --- | --- | --- | --- |
| Gold | Configured quest/boss rewards; capped event objectives | Market consideration, guild deposits, escrow movement | Recruitment, hall upgrades, crafting/service costs, market fees, later research/upkeep |
| Materials | Gathering, quests, bosses, events, recipe outputs | Trade, warehouse moves | Recipes, upgrades, construction, future repair |
| Equipment | Quests and crafting | Trade of eligible unequipped gear | Explicit salvage/upgrade consumption; optional future durability repair inputs |
| Consumables | Recipes and configured rewards | Trade | Use on an eligible server-authorized action |
| XP | Quest/encounter grants | None | Not a currency sink; thresholds consume progression accounting only if designed explicitly |

Gold creation and destruction must have named reasons. Escrow and bank movements are transfers. A market purchase creates no Gold. A seller fee destroys Gold; a fee returned to a guild treasury would be a transfer, so it must not be labeled a sink. Territory production bonuses create items only when a legitimate gathering/reward action commits; mere ownership is not an unlimited mint.

Avoid unlimited NPC buyback loops. Phase 1 has no NPC commodity exchange. Future vendors may offer bounded emergency supplies and limited buyback, with explicit budgets and cooldowns. Recipe graphs must be checked for cycles that create free inputs or profitable infinite NPC conversions.

## Prices have different meanings

| Field | Meaning | Authority |
| --- | --- | --- |
| BasePrice | Designer-authored benchmark for relative item utility | Versioned item catalog |
| NPCReferencePrice | Optional guide for NPC services, not a guaranteed tradable quote | Economy configuration |
| LastTradePrice | Price of the latest committed fill | Durable market ledger |
| MarketReferencePrice | Robust statistical estimate with freshness/confidence | Derived market data |

Missing information is `nil`/unavailable, never zero. Do not substitute a last trade for a reference silently. The [market algorithm](MARKETPLACE.md) uses independent participation thresholds, filtered samples, and capped weights. It cannot eliminate collusion; its output is informational, never collateral for borrowing or an automatic minting input.

## Crafting and item utility

Introduce crafting in Phase 2. Example recipe chain:

| Recipe ID | Inputs | Gold sink | Output | Requirement |
| --- | --- | --- | --- | --- |
| smelt_iron | 3 Iron Ore | 2 | 1 Iron Ingot | Basic Blacksmith |
| forge_iron_sword | 2 Iron Ingot + 2 Timber | 10 | 1 Iron Sword instance | Basic Blacksmith |
| reinforce_iron_sword | 1 owned Iron Sword + 1 Iron Ingot | 15 | Same instance, upgrade level +1 | Upgrade cap and valid ownership |

Recipe records include revision, input/output IDs, quantities, fee, building prerequisites, duration, level bounds, binding policy, and enabled state. Snapshot the recipe revision at start. Debit inputs and reserve output capacity together. Phase 2 initially uses instantaneous crafting to keep the transaction in one player record; timed jobs require a separately tested persistent job contract.

Common materials retain utility in repair, maintenance, research, and construction as later features arrive. Prefer multiple competing uses over requiring enormous quantities for their own sake. Equipment progression combines role-specific stats and tradeoffs rather than an endless rarity multiplier. Binding prevents monetized or tutorial-only entitlements from becoming a tradable Gold source.

## Fees and rounding

Store fees in basis points (`sellerFeeBps = 500` is the initial 5% proposal), versioned and snapped when the sell order is accepted. Gold prices and quantities are integers. For an order with cumulative executed gross `G`, total fee due is `ceil(G * feeBps / 10000)`; the next fill charges the increase since the previous fill. This prevents splitting a single order into tiny fills to avoid fees, while splitting into many orders cannot reduce the total ceil-rounded fee. Disclose the small-order rounding effect before confirmation.

Example: 10,000 Gold gross, 500 bps → 500 Gold destroyed and 9,500 credited to the seller. A 0 bps configuration produces zero fee. Verify the fee never exceeds proceeds and no canceled, unfilled quantity incurs an execution fee. There is no listing fee initially. Later fee discounts must preserve a floor and must not be purchased with Robux.

## Balancing and rollout

All reward amounts, XP curves, recruitment costs, building costs, recipe quantities, service costs, drop weights, stack caps, event/territory modifiers, fees, and market eligibility belong to versioned server configuration. Public display projections may be replicated; private controls and authoritative reward definitions remain server-side. No economic amount belongs in a UI callback.

Start with the feasible onboarding budget in [game design](GAME_DESIGN.md). Measure median and lower-quartile time to the first equipment improvement and hall upgrade. Examine outcomes by new/returning player, progression band, region, and paying/nonpaying cohorts. Do not rebalance only around the richest players.

Use a fixed basket price index and supply reconciliation from [economy health](ECONOMY_HEALTH.md). Adjust one major parameter family at a time with a recorded hypothesis, config revision, expected result, and review date. Prefer a staged release and rollback path; retain the reward/cost revision on active jobs and open orders so a deployment does not change already accepted terms.

Provisional economic goals: essential progression remains possible without trading; market participation reduces specialization friction; sinks grow with optional advancement rather than taxing basic survival; no paid benefit dictates victory. A short-term shortage may be useful specialization, not an automatic reason to spawn free stock. Investigate telemetry completeness and exploit risk before tuning supply.

World events modify bounded resource/encounter parameters, never executed prices. Territory bonuses have caps, alternate sources, and upkeep to reduce runaway wealth concentration. Seasonal rankings and territories can reset, but normal Gold/items/progression do not reset by default.

## Acceptance invariants

- Every committed Gold delta reconciles to a named faucet, sink, or equal transfer counterpart.
- Owned + reserved + pending assets cannot be spent twice; reservations do not increase total supply.
- Recipe outputs and all consumed inputs commit together or remain unchanged.
- Full storage never silently destroys a purchased or earned asset.
- Quest replay, duplicate network delivery, and receipt redelivery cannot create additional value.
- Configuration changes leave a reproducible explanation for every previously accepted transaction.

These invariants enter tests in the phase that adds the relevant feature. Analytics is not the accounting authority.

## Phase 2.3 equipment shop

Server-priced account-bound equipment uses Gold, with capacity 50 including assigned instances. Purchase sinks Gold; sale destroys an unassigned item and credits floor(price/2), with existing audit events and idempotent receipts. Materials and class fallback kits cannot be sold. No crafting, trading or paid currency was added. [Current prices and rules](INVENTORY.md) supersede weapon-only slice restrictions; historical quest/recruit rewards are unchanged.

## Phase 2.4–2.7 resource and tower slice

Gathering grants two resources per accepted nearby interaction, with persistent node cooldowns and a 100-stock ceiling (200 with Warehouse). Existing quest stock is preserved. Buildings and crafting debit inputs atomically; dismantling refunds half original materials, rounded down. Skill reset costs 10 Gold. Tower first-clear and repeat rewards differ and use durable receipts; individual tower enemies grant no camp rewards. Full prices and caps are in [base rules](BASE_BUILDING.md) and [tower rules](TOWER.md).
