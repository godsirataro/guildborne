# Full campaign qualification candidate

2026-10-18. The full goal includes Lv100, all cities, tower and player plus five
heroes. The current launch selection caps Lv35/Hall4, excludes Ashen and Tower,
and cannot prove that full progression. Existing Chapter00–06 content must be
qualified rather than replaced with duplicate stories.

Use `python tools/build_integration_preview.py --full-campaign` for the existing
offline/ArchiveHeartRuntime.luau through the current dynamic source mapping.
All six journey flags are already enabled in that reviewed offline runtime.
No LaunchCandidate means the Lv35 candidate selection is absent; normal earned
quest/class/Hall requirements still apply. No XP, profile, receipt or entitlement
is injected. Production Runtime and ReleaseContent are unchanged. No publishing
or DataStore access is enabled. This mode is mutually exclusive with launch,
shared-combat and continuous-world fixture options; it does not claim new walking
geometry or activate the continuous-world candidate.

Built full candidate SHA256:
011f4a557526175559e3ece8305da8bc2f1b9fd9ef86a2fd296b65f5831afbd9.
`check_full_campaign_preview.py` passed seven rejected mixed-mode combinations,
exact XML/transfer equality for 385 source entries, actual Memory runtime and
six journey flags, no launch marker, and unchanged release-config source.
The existing launch/continuous build retains exactly its prior candidate hash:
bdcc13bd797335df550a182c9904763144426302324bb9c062ab7dfea2688de9.
These are built-source checks, not native progression, combat or UAT acceptance.

Read-only S17 audit identifies the current source spine in NoviceChapter,
ChapterOne..Six, CampaignSequence, CampaignService and PersonalGuildService.
Existing milestones include Lv35/Hall4 Ashen entry, Lv50/Hall7 tower-checkpoint
requirements, Lv65/Hall10 permit11, Lv70/Hall11 Crosshaven, and Lv100/Hall17 finale.
The repeatable ten-floor tower and Chapter04 private story tower are separate.
Regional monster lists alone do not describe later story encounter coverage.

Remaining qualification: map actual quests/encounters/prerequisites and receipts
to earned runs; test repeatable Tower floors1/2/5/6/10 and later chapters on current
source. Resolve per-actor Class3 quest proof: existing actor mentor proof is Tier2,
and a player temporary Crosshaven trial cannot be assumed to prove hero Class3.
Hall18–20 permit/utility content is separate from Lv100, which Hall17 already
supports. Preserve legacy earned classes/progression and do not add guessed
quests or permit grants to make a test pass.

S15 combat harness0309b9d integrated as45cf0c6 after controller review. It must
run once in a fresh separate unsaved Memory session, with normal bootstraps
disabled and actual server hit/evade/cancel/RootBurst observations. No native
execution is claimed; current Studio ownership remains with S14's ux-system.
