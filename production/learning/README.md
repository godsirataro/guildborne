# Offline skill learning contract

`tools/agentic/learning.py` stores immutable JSON records in the **same Forge
SQLite coordinator ledger**, plus content-addressed candidates and captured local
test streams here. No background task, model invocation, installation or paid
service is included. Learning is a reviewed procedure improvement; it is not
model-weight training or game acceptance. Do not record secrets or user saves.

Forge `accept` and `release` atomically preserve a `learning-handoffs` event. Its
`NEEDS_EVIDENCE_BACKED_LESSON` status deliberately stays unproved until a scoped
worker records actual evidence. A release is not success. Handoffs do not run
evaluators or mutate skills. The current task's canonical skill stays unchanged.

## CLI

All learning commands require `--ledger`, `--task`, `--token` and optionally
`--root`. Use the shared ledger; do not create an independent database. The active
task needs `production/learning` write scope and, for proposals/promotions, the
exact target skill scope. Candidate skills must already exist in
`.agents/skills/<name>/SKILL.md`; generic file patches and installs are refused.

- `record --input <lesson.json>`: outcome `success`, `failure` or `interrupted`,
  nonempty `context`, `observation`, `correction`, `limit`, slug `tags`, and
  `evidence` refs `{path, sha256}`. Artifacts must exist and match. This verifies
  consistency, not that an operator's story is true.
- `search --query <words>`: ranked local lesson retrieval. Matching lessons with
  changed/missing evidence refuse retrieval instead of silently trusting them.
- `propose --input <proposal.json>`: `target`, `candidate` artifact ref, lesson
  IDs in `lessons`, scenario refs in `training`. Proposal captures HEAD, plan,
  AGENTS.md, exact skill bytes and candidate hashes without changing the skill.
- `evaluate --proposal <ID> --reviewer <different-name> --input <config.json>
  --approve-config-sha256 <reviewed-SHA>`: runs an explicitly reviewed Python
  evaluator synchronously, bounded to 30 seconds/case and120 seconds overall.
  Use fixture/temporary resources; this is **not an OS sandbox**. The code can
  access host resources, so its reviewed hash does not replace host approvals.
- `promote --proposal <ID> --evaluation <ID> --reviewer <same-reviewer>`:
  revalidates proof and source contracts, then atomically replaces one skill.
- `rollback --transaction <promotion-ID>`: restores exact bytes only if the
  current skill still equals that promotion and it is the latest successful
  mutation of that skill. Matching bytes alone cannot roll back an older branch.
  Later edits require reconciliation.
- `recover --transaction <PREPARED-ID>`: restores pre-transaction bytes if the
  target is either known before/after version. Confirm the old worker stopped.

## Forward-test interface

Scenarios are JSON `{id, input, expected}`. The reviewer config contains `runner`
artifact ref, `permissionsPreserved: true`, `reviewNotes`, `timeoutSeconds`, and
`cases: [{split: train|holdout|refusal, scenario: {path, sha256}}]`. Include every
proposal training case and at least one fresh holdout plus refusal. Distinct IDs
**and inputs** are required; a renamed training request is not a holdout. Refusal
must expect `REFUSED`. Keep holdout input independent of the proposed correction.
Structured inputs found in supporting lesson evidence are excluded too, even
when renamed or copied. The reviewer must also avoid reuse from narrative or
visual evidence; automatic extraction does not establish semantic novelty.

The reviewed runner receives `--candidate <path> --scenario <path>` and emits a
single JSON object to stdout:

```json
{"candidateSha256":"actual SHA", "scenarioSha256":"actual SHA", "observed":"observed result"}
```

Only exit0, matching input/candidate hashes and an actual observed result equal
to expected pass. Capture stderr separately; retain even empty raw streams. The
runner, candidate and scenario are copied to a per-case workspace and rehashed
after execution; the evaluator must not modify its inputs. Its cwd is that copy,
which reduces accidental project edits but does not restrict absolute host paths.
The
reviewer must ensure the runner actually exercises candidate behavior rather
than echoing expected results or searching for words. This cannot be established
by self-reported hashes alone, and named actors are not identity authentication.

## Crash and evidence boundaries

Each mutation first commits a PREPARED journal with original bytes, then uses a
same-directory temp file and `os.replace`. Observed failures restore the old
bytes where safe. A crash or expired lease can leave PREPARED; further mutation
refuses until explicit recovery. SQLite plus filesystem is not a distributed
transaction: recovery makes that gap explicit. Do not repair an unrelated edit.

Local test pass is separate from human art/feel/UAT, Studio import, physical
device and cross-server evidence. Keep runtime IDs and acceptance unchanged.
Code/software licenses do not grant rights over imported asset content.
