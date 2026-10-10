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
| Merge-hardening production-tool suite |115 tests passed; zero failures/skips on Linux after portability/reference fixes |
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
checks (previous6 plus6 compatibility checks). Local Luau execution was unavailable. CI run37902783515 on the previous
merge-hardening head passed the original game validation and all12 targeted
progression checks; final verification must still use the current PR revision.

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

## Windows portability failure found and corrected

The first expanded matrix run37902783515 passed Ubuntu104 tests and the Windows
game checks, but the Windows Python job reported20 errors and1 failed assertion.
Most errors came from comparing a resolved long root to its Windows8.3 spelling
(`RUNNER~1`) with Path.relative_to. One fixture incorrectly emitted backslash paths
in a registry whose contract requires POSIX paths. The failure was not skipped.

Recorder, worker, preview generator and Blender audit APIs now normalize their
root before constructing child paths. Attempt records use portable POSIX paths.
The fixture emits the same canonical paths used by the real registry; malformed
backslash references now fail explicitly rather than disappear from the audit.
Four additional regressions exercise relative-root recording, worker checkpoints,
preview manifests and invalid source-reference rejection. All108 tests then passed
on Linux. The Windows rerun is a required current-head merge check, not assumed
passed by this authoring-time record.

## Legacy registry reference correction

CI run37903820449 passed all three jobs (Ubuntu/Windows production tools and
existing game regression plus12 progression checks). The exported source archive
was compared byte-for-byte with all23 local changed/new files: no mismatches.
Inspecting its full-checkout reconciliation then found153 false missing-file
references: each was a legacy semicolon-separated list treated as a single path.

The reconciler now splits that existing representation without rewriting the
registry. It hashes individual file references and records directories as
DIRECTORY_EXISTS_ONLY, not recursively validated art. Existing directories block
unapproved image regeneration. Seven additional tests cover lists, directories,
missing members, stale directories, traversal, deduplication and theme/trial
routing; the resulting local suite passed115 tests. The new revision still
requires fresh green CI; this historical run is not approval of later commits.
