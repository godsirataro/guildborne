# World connectivity evidence

This is an incomplete two-round program checkpoint, not all-world acceptance.

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
