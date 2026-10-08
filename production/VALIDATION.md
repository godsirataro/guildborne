# Production-tool validation — 2026-10-09

## Executed in this change

Environment: isolated Linux authoring container, Python 3.13.5. This is a local copy of the added production files, not a full Roblox checkout. GitHub source was separately inspected at base commit `efd853d18578f7225e90c2d9f52f9e9ed755bc7e`.

| Check | Actual result |
|---|---|
| `python -m unittest discover -s tests/agentic -v` | **29 passed**, 0 failures, 0 skips; final run 0.090 seconds |
| `forge.py validate` | **28 tasks / 21 skills PASS**; dependency graph and skill contracts |
| `forge.py plan` | 28 work-package prompts generated; no model/API/Studio execution |
| `generate_primitives.py` | Six RGBA PNG procedural previews plus a manifest generated |
| Python compilation | New tools and tests compiled successfully |
| Original Character Kit intake | Reviewed SHA256 accepted; all 17 original files extracted into a temporary isolated directory; bundled scripts not executed |
| Original-to-normalized comparison | All 89 compact asset rows, 13 presets, 20 palettes and original Shared Contract matched source |
| New text whitespace | No trailing-whitespace failures |

The unit tests cover strict JSON, unsafe paths, overlap detection, task dependencies, local cooperative locking, expired/stale leases, separate review, evidence-file hashes, evidence type, distinct cross-server identifiers, device metadata, PNG CRC/alpha/sequence/determinism and original catalog integrity. These tests intentionally use synthetic fixtures; a synthetic `PASS` packet is never represented as real game evidence.

## Scope adjustment

The dedicated commerce-processing specialist could not be uploaded because the connector repeatedly returned an indeterminate tool safety-status block. It is **not included**. The plan was explicitly reduced from29 to28 tasks and from22 to21 skills, removing that work package and updating dependencies. All29 behavioral tests remain enabled. Existing shop presentation can use existing bindings; new receipt-processing implementation and live commerce are deferred. No tool permission or safety check was disabled.

## Not executed or not certified here

- Roblox Studio, Roblox Studio MCP and Blender were not connected to this authoring container. No new runtime import, deformation, animation, clothing fit, gameplay playtest or screenshot is claimed.
- No image/audio model provider was invoked. The generated primitives are simple procedural fallback/test textures, not finished hand-directed game artwork.
- The game's existing Luau/Roblox-aware suite, Rojo build and Windows tools were not run in this container. The PR includes a separate Windows CI job using the existing checksum-pinned setup and validation scripts; inspect that job's actual result before merging.
- No true live cross-server, physical Android/iOS, sustained cloud soak or human UAT is certified.
- No complete-game implementation, popularity, revenue or production-capacity claim is made.

## Runtime preservation

The change adds an agent production layer only. No `src/` code, existing game tests, Rojo mappings, player save schemas or market runtime settings were edited. No Roblox publication, paid upload, Robux/API spend, production DataStore operation or merge occurred.

## Remaining integration notes

The kit's original sample `headPresetId` is `HEAD_HUMAN_01`, while the catalog's actual asset row is `CHR_HEAD_HUMAN_01`. Preserve the original source and reconcile through an explicit ID mapping; do not treat the sample as a verified runtime ID. Original ZIP/XLSX bytes are available via the checksum-verified intake command, not embedded in the PR. Skills express task instructions; they do not supply unavailable external tools, authenticate reviewers, enforce an OS sandbox or automatically complete the game.
