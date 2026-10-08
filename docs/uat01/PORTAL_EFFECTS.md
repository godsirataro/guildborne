# Travel portal ambient effects — 2026-10-03

Eight existing gameplay travel gates now carry the GuildborneTravelPortal tag. PortalEffects creates local elliptical arcs and two floating rune blocks, with palettes for Guild, City, Greenwood, Ironveil and Ashen. The original gate surfaces are more transparent so the marks remain legible. The effects face the camera side of the gate and do not obstruct either direction.

At most three nearby gates animate on desktop High/Auto (12parts each,36total). Low uses two gates with8parts each (16total). Touch Auto selects Low; an explicit High override still caps touch at two gates (24parts). Gates beyond100studs have no effect geometry. Decorative parts are anchored, have no shadows, collision, touch or query, and send no network requests. Rendering updates at most30times/second. These budgets are ambient geometry limits, not measured device frame-rate guarantees.

Reduced idle motion removes both rotation and alpha pulsing. Streaming/tag removal, quality changes, destination changes and controller destruction clean up their geometry. The anchor surface, travel prompt and server transaction remain separate from the effect; there are no asset uploads, particles or purchased cosmetic entitlements involved.

Validation:13native stages,400geometry checks, fixed reduced-motion poses/alpha, front/back visibility, distance and saturation budgets, tag/stream cleanup, destination replacement and idempotent destruction passed. Live owned memory-only Studio had8tagged gates, an8part Guild effect in touch emulation and actual keyboard E travel from the city portal to(0,4,23). The character was moved near the gate only to shorten walking. Source-matching gate opacity was visually reviewed in portal-effects.png. See validation-portal-effects-native.json.

Strict analysis, compilation, main/offline builds and repository checks cover196runtime files. Latest unchanged domain baseline is464tests. Physical mobile/gamepad, simultaneous players, final art approval and imported assets remain pending.
