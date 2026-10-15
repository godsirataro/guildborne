# Main consolidation — 2026-10-16

The user explicitly authorized combining the local Guildborne work with PR #2,
committing it and pushing main. This authorization covers Git integration;
Roblox publishing, live commerce and game acceptance remain separate.

Sources combined without replacing history:

- Existing production branch through `a213f7d8f6a6d37b6d71cb1709f0a398e1e0da8c`.
- Working-tree ecosystem routing and central-city landscape, checkpoint `45aaa4c`.
- PR #2 through `420bd65b4717b27202ba1eec1d66584c4956b405`, merged in `0671611`.

Integration repairs:

- Disabled and malformed MCP `enabled` values now fail strict static preflight;
  enabled registrations still do not imply connection or playtest success.
- One linked ecosystem workflow includes the official preflight, Forge/Studio
  routing and QA runbook. Novice tests use the isolated Memory preview; persistent
  staging recovery tests remain separately scoped. Historical research is dated.
- Corrected branch-cylinder XYZ rotation; deterministic checks now verify all
  522 branch endpoints and exact generated Luau. Re-rendered both previews and
  Blender source, retaining prior raw logs as historical evidence.
- Git attributes preserve raw asset/evidence bytes. All 15 landscape manifest
  hashes matched the staged blobs, and ecosystem raw logs matched their staged
  bytes after renormalization. Source hashes explicitly use canonical LF text.

Local checks on the integrated working tree:

| Check | Result |
| --- | --- |
| Checksum-pinned tool setup | PASS; existing versions retained |
| Production Python suite | 208 tests: 202 passed, 6 Windows symlink privilege skips |
| Original Luau regression | 890 passed |
| Latest progression checks | 12 passed |
| Rojo build/sourcemap, type analysis, compilation, repository validation | PASS |
| Forge / Studio / ecosystem metadata and generated adapters | PASS; 60 tasks, 31 skills, 33 roles, 98 generated outputs |
| Landscape geometry | PASS; max endpoint error 0.00011757015139497185 studs; 1,141 route samples |
| Static preflight on this workstation | CONFIGURED_NOT_CONNECTED |
| Independent review | Preflight/runbook and landscape fixes reviewed by gl2_inventory; raw staging mismatch found and corrected |

`main-python.*.log` and `main-baseline.*.log` preserve raw local command output.
These are working-tree observations, not a formal clean-source Forge acceptance
packet. GitHub Actions must be read on the final integration commit; the earlier
PR #2 green checks alone do not cover this combined source. No new Studio,
physical-device, cross-server or human art/UAT acceptance is claimed.

The first integration CI run (`38803177076`) exposed source metadata generated
from Windows CRLF bytes in `production/plan.json` and `production/studio/studio.json`.
Git stores these two source files as LF, so a clean CI checkout correctly rejected
the manifest. Both local files were normalized to the committed LF representation
and the adapters/manifest regenerated; their source hashes were then checked
against staged Git blobs before a new CI run. No validator was bypassed and no
runtime logic changed in this repair.
