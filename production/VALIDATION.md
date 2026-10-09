# Production v2 merge-hardening validation — 2026-10-09

## Reviewed source

Continues PR #1 at head `0a3f542ebf78e92ded44701b9b1e4f1493c08c42`.
Source was obtained through GitHub Actions artifact11596576874 from run37886661990.
Its code/docs archive identifies tested merge commit
`8d8c3abb7be6aa2cff4a0b0f5745021555c23f23` and has SHA256
`169a081159be6fb6aec6206c8907f4e30116f1bfb6ec8588efc141001154d0b5`.

The offline review snapshot intentionally omits heavy assets/review directories.
A local Git fixture was created for diff inspection; it is NOT the remote commit.
Missing binary references in this snapshot must not be called missing GitHub files.
CI reconciliation uses the complete repository checkout.

## Locally executed

| Check | Actual result |
| --- | --- |
| Baseline production-tool suite at reviewed source |66 tests passed |
| Merge-hardening production-tool suite |104 tests passed; zero failures/skips on Linux |
| Plan and skills |33 tasks /25 skills, valid metadata/dependencies |
| Python source compilation |Passed for tools/agentic and tests/agentic |
| Character contract |15 names /13 presets /20 palettes; aliases and untested fit matrix generated |
| Registry reconciliation |Preserves all current registry rows; warnings remain explicit; no registry mutation |
| Procedural outputs |Existing panel +5 flipbooks generated; normalized pixel/alpha decoder exercised |
| Source whitespace check |Passed |

New regressions include canonical Windows/POSIX paths and symlink parents;
directional scope containment; plan mutation and interruption checkpoints;
quiet/failed command receipts; record -> compose -> submit -> independent review;
late log/receipt tampering; protocol2025-11-25, malformed discovery and cleanup;
PNG pixels/filters/bounded decompression/alpha; duplicate reward keys and routing.

All worker/MCP subprocesses in these tests are explicitly labeled fixtures. No
actual Codex quota, image provider, Studio session or Blender was invoked here.
The image decoder proves normalized pixels and alpha, not final visual quality.

## CI-required validation

CI now runs the production-tool suite on Ubuntu AND Windows. The original pinned
Windows game validation remains unchanged, supplemented by12 latest-progression
checks (previous6 plus6 compatibility checks). Local Luau execution was unavailable;
consult the current PR CI run for the executed Luau/type/build result and actual
count rather than promoting this pending authoring-time statement to PASS.

Additional progression checks cover already-earned Class2 at30 remaining valid;
new heroes starting at10 independent of Hall/leader; hero-only respec isolation;
wrong-class/parent/tier rejection; Tower5/quarters prerequisites; and unchanged
legacy allocation behavior. No new runtime changes beyond the previous scoped
v2 readiness/refund/display delta were needed in this hardening pass.

## Preserved boundaries

No rollout of new default campaign flags or PlayerData schema; no removal of old
ancestry bonuses, saved paths, items or levels; no market ledger changes, cloud
writes, paid model calls, live commerce, Roblox publication or automatic merge.
All original game regression tests remain enabled.

See MERGE_READINESS.md for the implemented merge scope and the distinct pending
provider/Studio/Blender/hardware/cross-server/human game-acceptance gates. The
normalized Character Kit contract is self-contained; the exact original ZIP/XLSX
intake still requires the supplied archive. Final models/art are not in this PR.
