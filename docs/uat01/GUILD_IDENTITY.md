# Preset guild recognition art — 2026-10-04

`GuildIdentityWorld.luau` renders the Chapter01 recognition choices on the existing Hall banners. Sun, Oak and Compass are original native part symbols. Together, Courage and Discovery map to preset bilingual motto text. No custom user text, paid entitlement, collision or combat-stat changes are introduced.

The renderer applies after the Hall is built/moved/themed. It is idempotent for unchanged choices and language, restores the original emblem if recognition is absent, and follows the Hall pivot. The committed campaign state is the only runtime source of identity. A visual-only application of the actual revision69 Compass/Together choices was inspected on the existing Hall2; no profile write occurred.

Native matrix: 216 combinations (6 themes ×2 Hall models ×3 crests ×3 mottos ×2 languages), 3,168 crest part checks. Verified non-collision/query/touch, stable repeated sync, movement, unchanged collider counts and cleanup. This is native art acceptance, not physical-device/multiplayer or human approval. Cloud imports and standalone Blender crest exports are not provided by this module.

Remaining: final source sync/actual polished journey, close-range and mobile readability, optional crest display in guild directory and standalone export assets. The complete campaign card also displays the selected crest/motto in readable text and no longer recommends Hall2 after the upgrade is already complete.
