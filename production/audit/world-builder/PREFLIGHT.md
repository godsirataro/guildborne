# World builder preflight — 2026-10-16 (Asia/Bangkok)

Base: `bf948c636aa47e1d1b92a617895d324fcfaf42e9`; branch `codex/world-connectivity`.
Initial working tree was clean. Attached prompt documents were read as task material;
their historical test counts and capability statements are not fresh evidence.
The ZIP was inventoried without executing or installing its contents.

## Ownership and scope

The default `build/agentic/ledger.sqlite3` rejects the current plan fingerprint.
The existing coordinator ledger `C:/Work/MySelf/Guildborne/build/agentic/launch-v26-ledger.sqlite3`
matches all 60 tasks and had no active owners at inspection. It is shared by this
run; no ledger was reset or replaced. Claims: `audit` (world-director),
`p1-city-services` (world-builder), `p1-city-verification` (world-qa).

The original `city-zones` task is not ready: audit and registry reconciliation
require accepted evidence first. Its scope also excludes most requested world
modules. Therefore the complete inventory is an audit under `production/audit`,
not a new authoritative runtime registry. A bounded Central City implementation
uses the already-ready P1 scopes. Broader region/chapter integration needs a
reconciled owner assignment and dependencies; no synthetic acceptance was used
to unlock it. Crosshaven continuity in particular must preserve private chapter
actors and saved objective identities, not merely move geometry.

## Exercised capabilities

| Capability | Observation | Limit |
|---|---|---|
| Forge / Studio routing | validate: 60 tasks, 31 skills; Studio: 33 roles, 10 workflows, 98 generated files verified | Metadata, not game acceptance |
| Reconciliation | 502 assets, 73 screens, 89 kit assets, 402 hashes, no missing references | Source bindings still require semantic review |
| Character contract | 89 planned assets, 15 required body parts PASS | No mesh/fit approval |
| Rojo | Offline Memory project built locally | No import/playtest implied |
| Studio MCP | One instance listed; get_studio_state returned `Place is not open` | Initial connection discovery only |
| Blender | Installed executable reports Blender 5.2.1 LTS | Forge doctor searches PATH and incorrectly suggests no binary; no Blender MCP tools exposed |
| GitHub | Existing origin and authenticated CLI available | PR only; no merge/release |
| Physical devices | None exercised | Device acceptance pending |

Pinned tools were prepared with the reviewed `tools/setup_tools.ps1`. Original
game validation is run separately from Python/tool metadata checks. See
EVIDENCE_INDEX.md for actual outcomes and candidate identity.

## Protected boundaries

Default Runtime remains DataStore staging with journey previews disabled. Test
artifact uses `offline/Runtime.luau`: Memory, empty allowed-universe map, analytics
and purchases disabled. Streaming migration is outside this slice. No public or
private publishing, asset upload, paid generation, production-store write or
commerce activation is authorized or performed by this run.

Normal player input, earned recruitment/crafting, all-zone hero traversal,
physical mobile performance and human environmental-art review remain distinct
from a synthetic HeroService walk and offline geometric checks.
