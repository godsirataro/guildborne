# Production execution v2

## What runs now

`forge.py` remains a no-model planner/ledger. `run_worker.py` is a separate,
explicitly opted-in subprocess adapter for installed Codex local-code tasks.
It sends prompts on stdin, records outputs, bounds retries/time, checks HEAD and
write scopes, keeps a lease, and checkpoints interruptions. An exit code0 only
creates `REVIEW_CANDIDATE_NOT_ACCEPTED`; it cannot grant UAT acceptance.

This is cooperative orchestration, not an authenticated reviewer service or a
filesystem/MCP security boundary. Configure the host sandbox and MCP approvals.
Never give an unattended worker publishing, cloud-write or purchase tools.
Local testing of the runner uses real subprocesses running fixture code, NOT a
paid Codex invocation or actual Studio session.

## Inspect without spending or contacting cloud services

```sh
python tools/agentic/forge.py doctor
python tools/agentic/forge.py validate
python tools/agentic/reconcile.py
python tools/agentic/character_contract.py
python tools/agentic/forge.py plan
python -m unittest discover -s tests/agentic -v
```

Read `build/agentic/reconciliation.json`. It maps each current asset/screen and
kit row to a candidate work package, hashes existing files including native
screen implementation candidates, reports missing references, and leaves all
original approval fields untouched. Routing is reviewable, not semantic proof.
Use the same shared ledger for every worker. A changed plan requires a new
ledger only AFTER old writers stop; never reset a live ledger to steal work.

## Run a local-code task with installed authenticated Codex

```sh
python tools/agentic/run_worker.py --task audit --ledger build/agentic/ledger-v2.sqlite3 --authorize-model-run --attempts 2 --timeout 900
```

The flag authorizes a quota-consuming model run on that workstation, not an
external purchase. No model name or API key is guessed. CI never invokes this
command. Non-local tasks deliberately refuse unattended execution in this
version; use their prompts in the verified interactive Studio/Blender/image
session. There is no secret full-game agent loop.

Outputs and a private cooperative lease checkpoint live under
`build/agentic/runs/<runId>/`. Do not upload this directory. To continue an
interrupted task, first confirm the prior worker/process group stopped, then:

```sh
python tools/agentic/run_worker.py --task audit --ledger build/agentic/ledger-v2.sqlite3 --authorize-model-run --resume-run ACTUAL_RUN_ID --confirm-worker-stopped
```

Resume requires the same task, plan, source HEAD and shared ledger. It preserves
prior logs and scoped edits. Changed HEAD/scope needs explicit reconciliation,
not an automatic reset. After reviewing changes, commit source, rerun checks,
and submit fresh evidence; use the local lease checkpoint for submission/release.

## Read-only MCP connection probe

Create a reviewed LOCAL JSON configuration with an argv array. Use Studio's
current quick-connect configuration, not an invented endpoint. Example Windows:

```json
{"command":["cmd.exe","/c","%LOCALAPPDATA%\\Roblox\\mcp.bat"]}
```

Compute its SHA256 with your trusted local hash tool, then:

```sh
python tools/agentic/mcp_probe.py --config LOCAL_CONFIG.json --approve-command-sha256 ACTUAL_HASH
```

The probe performs MCP initialize, paginated tools/list, and optional read-only
list_roblox_studios. It rejects server-initiated requests, oversized messages,
malformed JSON, protocol errors and mutating/generation tool calls. This can
prove an MCP process responded; it cannot prove a particular place is correct,
that art is generated, or that a game playtest passed. Review the real Studio ID
and schemas interactively before writes. No HTTP server or unauthenticated
remote command endpoint is started.

## Capture a real check, not a typed PASS

`record_check.py` accepts a reviewed local JSON with `argv` and
`timeoutSeconds`. The config SHA must be explicitly approved. It executes the
check with shell=false, records stdout/stderr, commit/tree and output hashes,
and rejects dirty or changed source. A command pass is not a task pass.

```sh
python tools/agentic/record_check.py --config LOCAL_CHECK.json --approve-command-sha256 ACTUAL_HASH
```

For ledger submission provide: taskId/environment, actual buildCommit and
sourceTree, current planSha256, exact checks, invocation tool/runId/exitCode/
buildCommit/log paths, and nonempty hashed artifacts. The Git object must exist
and be the checked-out HEAD. Submit and review on the same clean committed
checkout. Uncommitted evidence belongs in ignored build output to avoid a
self-referential commit. Empty stderr is a valid captured output but exclude it
from ledger artifact lists, which intentionally require nonempty evidence.

These checks prevent accidental stale/fabricated SHA acceptance; they do not
cryptographically prove a reviewer identity or prevent an authorized person
from fabricating a log. Independent inspection remains required.

## Image and 3D handoff

`asset_jobs.py --identity asset:ui.brand.wordmark` prepares a canonical job.
An existing source requires explicit --allow-rework and matching source hashes.
It does not call a provider. Selected candidates record actual origin/tool/rights;
PNG container/CRC inspection does not replace pixel decode or visual review.
Interactive screens cannot be baked into an image job. No uploaded ID is invented.

`character_contract.py` emits the complete normalized authoring contract and
89-row CSV without requiring the original ZIP. Aliases resolve earlier head-ID
examples. Fit-matrix entries remain untested, including Human Standard/Heavy.
The original17-file archive can still be imported byte-for-byte with the pinned
intake tool; normalized output is not claimed to be the original XLSX or meshes.

`blender_job.py --source REPO_PATH.blend --source-sha256 ACTUAL_HASH --collection BODY_COLLECTION --approve-local-blender`
invokes the checked-in read-only body audit with autoexec disabled. Confirm flags
using the installed Blender help. Source generation, clothing cages, deformation,
exports/imports and final fit still require the actual DCC/Studio workflow.

## Stop conditions

Nonzero or uncertain writes, invariant failure, missing ownership, unapproved
external action, conflicting checkout, unknown tool schema or stale references
stop the affected task. Keep unrelated safe tasks moving. No auto-merge, Roblox
publishing, device certification, cloud soak certification or popularity claims.
