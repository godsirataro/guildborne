---
name: guildborne-localization
description: Maintain Thai/English UI, quest dialogue, terminology, layout expansion and accessibility.
---

# Guildborne Localization

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Extract current localization keys and glossary. Preserve source context, speaker, placeholders and grammatical meaning. Thai/English need actual layout inspection: wrapping, Thai mark clipping, line spacing, narrow menus and quantity input. Do not bake dynamic copy into art, concatenate grammar-fragile strings or change IDs during translation. All critical states communicate with shape/text as well as color. Add reduced motion, readable contrast and non-audio alternatives for clues/telegraphs. Verify font support using the runtime fonts available; never redistribute font files. Review class tier versus rarity rank versus guild level terminology. Mark native-language/human review separately from automated key coverage. Deliver validated tables, missing-key report and screenshots of longest strings.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
