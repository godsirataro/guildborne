# Local toolchain connection checkpoint — 2026-10-20

Controller verified the tools again after the workstation restart. This is connection and local tooling evidence, not game/UAT acceptance.

- ForgeMCP is now available directly in the controller chat. Actual `asset_capabilities`, `generation_list` and `publication_connections_list` calls succeeded. Account has an active eligible API-key publication connection; no credentials were read. No generation or publishing call was made. MCP history returned no jobs; that endpoint excludes website generations, including the existing Inventory concept.
- Roblox Studio initially reported `Place is not open`. Controller opened the saved local `TwoRoute_Studio_Checkpoint.rbxl`, confirmed Edit mode and PlaceId 0, and connected the installed Rojo 7.7.0 plugin to `Guildborne_QualityPreview` at loopback port 34872.
- Rojo serves `build/quality-preview.project.json` from this controller checkout. Plugin displayed the connected project and Disconnect button. Readback of Dataset3/Chunk1, Runtime and InventoryPane matched local normalized source lengths and Adler32 checksums (120016/2337963042, 696/2800152602, 21255/3179999910). This is sampled sync evidence, not a full source or gameplay test.
- The preview Runtime specifies Memory persistence, empty allowed DataStore universes, and disabled analytics/permanent passes. No Play, publishing or production DataStore write was performed during this connection task.
- Studio saved a separate local copy at `build/toolchain-20261020/Guildborne_Connected.rbxl` (1,363,045 bytes at save). Rojo connection screenshot: `build/toolchain-20261020/rojo-connected.png`.
- Blender 5.2.1 LTS interactive scene was the unsaved default Cube/Light/Camera scene. The existing reviewed `blender_attach_readonly.py` was attached on 127.0.0.1:19877, preserving scene objects/transforms. Actual ping, addon-info and scene-info calls succeeded; addon1.8/protocol13. It intentionally denies arbitrary execution and writes. Background Blender CLI recipes are the authoring path; this discovery bridge is not a writable Blender MCP.
- Studio reported an existing asset-type mismatch for `rbxassetid://203785492` on load. This was not repaired or treated as a failed connection.

## Original local workflow, not a ForgeGUI clone

Use `local_tools.py` and `LOCAL_TOOLS.md` in this directory for bounded local status checks and the existing native GUI review builder. Reuse actual Luau components and Blender recipes for layouts, native text, icons, item meshes and VFX. Reserve Forge credits for selected original concepts/illustrations after checking existing assets.

These local commands do not call ForgeGUI generation APIs. Codex reasoning still uses the account's Codex allowance, and local rendering consumes machine time. They do not reproduce ForgeGUI's hosted generative models or bypass its credit system. No missing skill justified another install in this task.

Actual local GUI review build completed with exit0. Raw receipt and unchanged
stdout/stderr are in `build/gui-review/local-tools-85e5f0da3c2241d5b5d44b1480f7267b/`.
Output `build/gui-review/GuildborneGUIReview.rbxlx` SHA256:
`61239fb3b478cc63826448f4f4d2e30d62062d3df63a95bae796e9859331df4a`.
The builder checked exactly one LocalScript and no server scripts/remotes.
This newly built fixture was not opened or playtested in Studio in this task.
Live CLI connection report is saved in `build/toolchain-20261020/local-status.json`;
sampled local-versus-Studio comparisons are in `sync-readback.json` beside it.
Nine deterministic wrapper fixtures passed, including failed lease and timeout
cleanup paths. A separate reviewer reran all nine and cleared the cleanup issue.
These fixtures are not Studio tests. A separate installed Blender CLI process
also completed a `--background --disable-autoexec` Python inspection with exit0,
reporting Blender 5.2.1 LTS; no interactive scene was opened or saved by that probe.

Official references checked on 2026-10-20:

- https://rojo.space/docs/v7/getting-started/new-game/ — server and Studio plugin connection workflow.
- https://rojo.space/docs/v7/sync-details/ — live-sync capabilities and limitations.
- https://www.blender.org/about/license/ — Blender license and original artwork distinction; review individual dependencies before distribution.

Human visual acceptance, Studio gameplay regression, device testing, and release authorization remain separate.
