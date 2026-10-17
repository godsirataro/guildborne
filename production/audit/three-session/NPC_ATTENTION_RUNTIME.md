# NPC attention runtime — 2026-10-17

S17 e3479f3 independently reviewed without source blocker, worker released borin-integration (ledger PLANNED/owner null), integrated as6504c8b. Head-only easing retains existing single animator owner, tool arms, feet and root. Latest accepted interactor identity, distance, missing root, expiry and reduced-motion behavior were reviewed.

Actual Client in isolated Studio4c0f401f-f705-46a0-8baa-6d5decad4352 executed committed tests/studio_borin_integration.luau with exact source-copy FriendlyNpcAnimator and BorinWorkMotion modules. Only animator's motion require redirected to the copied module; probe passed its collection provider to isolate a disposable original native kit. It did not replace the gameplay NPC animator or change the earned server.

Result:
```json
{"activeRestorePreconditions":3,"attentionHintFixture":true,"dialogueFixture":true,"restored":true,"questJourneyTested":false,"status":"PASS_CLIENT_FIXTURE_ONLY","npcId":"cartographer_nyra","rootPreserved":true,"multiplayerTested":false}
```
Independent cleanup check actorRemoved/guiRemoved/animatorRemoved/motionRemoved all true. Probe module also destroyed by wrapper. Fixture restored camera, clock and reduced-motion attribute.

Synthetic local hints establish presentation behavior only. Real modular-kit naturalness, accepted real speaker replacement, two-client behavior, tool/foot motion and whole-build acceptance remain unverified. No server acceptance, multiplayer or physical-device claim.
