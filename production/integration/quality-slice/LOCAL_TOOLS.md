# Original local tool shortcuts

This small Python standard-library CLI wraps existing Guildborne workflows. It
contains no ForgeGUI implementation and calls no paid provider. Codex CLI model
usage still consumes the user's Codex allowance; local builds themselves do not
consume ForgeGUI credits. It is not a replacement image-generation model.

From this checkout:

```powershell
python production/integration/quality-slice/local_tools.py --status
python production/integration/quality-slice/local_tools.py --plan
```

Status reads only `127.0.0.1:34872/api/rojo` and the reviewed restricted Blender
bridge on `127.0.0.1:19877`. It cannot send Python code, choose arbitrary hosts,
follow HTTP redirects, use HTTP proxies, change a scene or launch an application.
Responses are limited to 256 KiB and network operations have a three-second
timeout; the Blender response also has an overall three-second deadline. A
connected Rojo server does not prove that the Studio plugin has accepted its
sync tree. Blender status verifies the adapter's read-only declaration before
requesting scene information; this is cooperative identification, not server
authentication. Exit code 1 identifies an unavailable or invalid connection.

The plan points to current native Roblox GUI and Blender scripts, without
running them. GUI content remains native Frame/TextLabel/ImageLabel components
with existing Luau state binding. Art generation, local build, Roblox import,
Studio testing, device testing and human acceptance are separate facts.

To rebuild the existing isolated GUI gallery, the controller must assign
`build/gui-review` output ownership and hold the current integration lease:

```powershell
python production/integration/quality-slice/local_tools.py --build-gui-review --ledger C:/Work/MySelf/Guildborne/build/agentic/four-session-v8.sqlite3 --lease-token ACTUAL_CURRENT_TOKEN
```

This command invokes only `tools/build_gui_review.py` via a fixed argv list with
`shell=False`. That existing builder emits a Rojo place with a single local
bootstrap and checks that server scripts and remotes are absent. The wrapper
checks the shared lease and bounds the build to 120 seconds. Generated files,
raw stdout/stderr (including empty stderr) and a per-run JSON receipt remain
under `build/gui-review`; source files are not modified. The receipt labels a
successful build `BUILT_NOT_STUDIO_TESTED`. Do not open/import/publish or run a
Blender authoring script automatically based on a build result. Interactive
application work requires its own verified session and exclusive ownership.

No external downloads, API keys, subscriptions, asset uploads or purchases are
required. Reuse existing approved art first; retain provider provenance and
review rights before reusing third-party images. Decorative raster art does not
replace readable runtime text, real item data or server-authoritative actions.
