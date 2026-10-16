# GUI production checkpoint

This branch implements the reusable foundation and first Title/Loading screen for
owner review, then continues the supplied full-game GUI initiative. It does not
claim all 87 audited surfaces are reskinned or accepted.

- GUI_SOURCE_AUDIT.md: actual source, bindings and registry discrepancies.
- GUI_SCREEN_COVERAGE.csv: 73 preserved registry rows plus 14 additional surfaces.
- GUI_DESIGN_SYSTEM.md: component contracts, visual references and engine choices.
- GUI_ACCEPTANCE.md: fresh checks and actual evidence levels.
- GUI_REMAINING_GAPS.md: subsequent screen migration and external gates.

Original prompt and references: design/guildborne-gui-production.
One shared coordinator ledger: build/agentic/gui-v27-ledger.sqlite3.
Task gui-foundation, owner gui-coordinator; workers have disjoint subscopes.
The previous default ledger had a mismatched plan fingerprint; all inspected
historical ledgers had no ACTIVE or REVIEW jobs before the new current-plan ledger
was created. No old task was accepted, reset or released to bypass dependencies.
A bounded continuation task was added to the canonical plan; ux-system remains
unaccepted. Generated Studio role adapters were refreshed from that plan.

Baseline 42cb34b: recorded check 229ed8c563764de697e5c894f55ec561,
890 game tests, strict analysis, compile, Rojo build and repository checks passed.
No backend/runtime flags changed. All physical-device/human/release gates remain external.
