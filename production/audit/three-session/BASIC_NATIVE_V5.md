# Warrior Basic native timing — v5
S15 9e708f3 independently reviewed/integrated as e077903. Controller reran six action-timeline groups and compiled source/probe. Actual preserved Studio62789207-389b-45dc-95a0-c5bffd63cd0b Client executed the committed basic_probe with an exact source-copy SkillEffects module under Client.Controllers; only the probe's factory require target was changed. Existing shared config/timeline/path dependencies were reused; the live game's cached SkillEffects was not replaced.

First attempt incorrectly placed the module directly under PlayerScripts; sibling PathSkillEffects resolution failed. Probe cleanup completed and actors/effects/module were0/absent. Corrected sibling placement succeeded. Do not call the failed attempt a game regression or omit it.

Actual native assertions passed for fresh/.15/.30 ages, duplicate calls, High/Low, pre-release/during-release/post-contact cancellations, replacement/clear/health death/removal, replacement playback, expiry and nonphysical geometry budgets. Console contains the exact PASS Basic native probe message. The probe uses fresh factories per case, so this does not establish aggregate five-actor budget behavior or physical touch/device performance. Humanoid.Died is handled in source but the death fixture sets CombatHealth; no distinct Humanoid.Died runtime assertion is claimed.

Worker budget:16desktop/12Low parts maximum plus optional trail/twoattachments, within existing shared48/30 detail limits. Probe counts match these conditional limits and rejects missed timing windows as INCONCLUSIVE. Server damage remains authoritative/immediate; cosmetic scheduling does not delay or reconfirm hit damage. PowerStrike/Fireball unchanged.

Independent post-run read confirmed0BasicTimingProbe actors,0Warrior.Basic effects, removed temporarymodule and unchanged earnedplayerposition(-4423.5527,2.9980,88.5282). Camera and quality restored by committedprobe on both paths. Current Chapter3 preserved. This is synthetic source-copy presentation evidence, not ordinary latest-build F attack/visualfeel or final art acceptance. Whole combined baseline awaits S13/S14 integration.

Raw tool results and console: basic-native-v5.json. No publishing, spending, production profiles or real combat commands used.
