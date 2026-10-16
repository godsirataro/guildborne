# World connectivity evidence

This is an incomplete two-round program checkpoint, not all-world acceptance.

## Studio follow-up after explicit target confirmation

The Central reference loop now has bounded real Studio physics evidence:
20 five-hero segments, 1,277 samples, all three service buildings entered/exited,
no additional recovery, and 29 service assertions passed. Actual-player automated
navigation and Tavern/Crafting prompt activation also ran. See the
[Studio report and raw evidence](../../design/integration/p1-city/world-connectivity/studio/REPORT.md).
The initial legacy offline build failed on missing ReleaseContent; the existing
dynamic Memory builder produced the successful candidate. Earlier pending/no-open-
place statements below describe initial preflight only. Neither whole-world
completion nor device/human acceptance follows from this result.

## Recorded candidate

Code/test candidate: `e842d009385158f3b48e4d02af0fc0d961735cbf`.
Both immutable local-command receipts verified against clean unchanged source:

| Command | Result | Preserved receipt |
|---|---|---|
| `pwsh -NoProfile -File tools/validate.ps1` | PASS: 890 tests; analysis, compile, build, repository checks | [baseline result](../../design/integration/p1-city/world-connectivity/baseline/result.json) |
| `python tools/verify_city_landscape.py` | PASS: projected geometry only | [geometry result](../../design/integration/p1-city/world-connectivity/geometry/result.json) |

Receipt folders preserve result, invocation and raw stdout/stderr bytes, including
empty streams. Their original `build/agentic/checks` paths remain recorded in the
JSON; copies are archival, not rewritten Forge submissions. Later commits only
clarify documentation/status vocabulary and preserve these records, not change
the tested runtime/test/verifier code.

Independent reviewer `/root/independent_review` inspected actual CityKit doorway
transforms, furnishings and probe semantics: no source runtime blockers found.
The reviewer found stale historical hash references; the landscape report now
explicitly labels the old manifest historical and points here. This was source
review, not an independent Studio replay or formal Forge task acceptance.

## Changed behavior

Four cobblestone segments connect the market avenue to the east-facing forge
door and the market courtyard to the Exchange door. Existing buildings, markers,
landscape recipe, service authority, runtime flags and destinations are preserved.
The Studio probe now includes Exchange entry/exit and return to Plaza, retaining
five companions, no recovery, no death/fall, separation and zero-reward assertions.

## Verification layers

- Initial `tools/setup_tools.ps1` and `tools/validate.ps1`: PASS; 890 tests,
  Roblox-aware analysis, compilation, Rojo build/sourcemap and repository checks.
  This exploratory run overlapped source work; the final committed check receipt
  is the authoritative candidate result.
- `python tools/verify_city_landscape.py`: PASS; 1,172 landscape route samples,
  109 paved approach samples, 522 branch endpoints. Only projected geometry is
  tested; this does not certify shell/foundation collision or pathfinding.
- Studio probe: source compiled; execution pending. Initial MCP state returned
  `Place is not open`. A separate Memory build is ready at
  `build/Guildborne_WorldConnectivity.rbxlx`; target confirmation is pending.
- Physical device, normal player input, earned service transactions, multiplayer
  and human art acceptance: not executed in this run.

Historical `assets/uat01/city-landscape/evidence-hashes.json` and old raw logs
remain unchanged. Their source/validation hashes describe their earlier commit,
not this revision. Fresh receipts must not be used to retroactively certify old
Blender images or an unexecuted Studio test.

Audit files map all 19 requested rows. WORLD_GRAPH and ANCHOR_BINDINGS are a
source-derived review inventory, explicitly partial for dynamic/private actors;
they do not introduce a second gameplay registry. See ROUND1_REPORT and
ROUND2_REPORT for remaining work and OWNER_REVIEW for outstanding decisions.
