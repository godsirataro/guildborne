# W3 Title — respond to actual W2 visual rejection

Controller reported actual W2 Studio output at 796x675: dark crude citadel,
lifeless empty roster composition, 190px header wasting vertical space, cropped
Credits, overflowing language label and two-line Continue. W2 visual acceptance
was NOT passed. This report does not relabel W2 as accepted.

## Changes for native review

- Header now 112px on short/narrow content areas, 124px otherwise. Crest remains
  above a 32/44/52px serif wordmark with gold rules; subtitle is shorter.
- Entry rail minimum content shrinks to 304px plus 36px padding. Continue is 56px;
  secondary actions stay 48px. Labels are Begin adventure / Continue / Language: EN,
  or localized Thai. Existing language callback is unchanged. Four action labels
  use one line with native TextScaled and a 14–17px constraint.
- Header 112 + list gap 12 + rail 340 = 464px, within a 494px content viewport in
  the synthetic short-layout check. Credits is part of this rail, not below it.
  Expanded Settings/Credits and the mobile scenic section intentionally scroll.
- Scene height 220px for short content, 240px for narrow tall content, 280px desktop.
  Scenic fallback now contains a dusk sky gradient, sun/clouds, two mountain
  depths, lake, terraced cliffs, waterfalls, foreground terrain and bridge.
  Ivory stone, warm windows, blue paired roofs, cornices and burgundy banners
  replace the near-black isolated block castle.
- Diorama has 118 static anchored nonphysical BaseParts. No uploads, assets,
  render loop, dynamic lights, gameplay systems, NPCs or fabricated heroes.
  Actual CompanyPreview stays in the foreground. Camera adapts to aspect ratio;
  resize connection disconnects when its viewport is destroyed.

## Evidence and remaining visual gaps

Current review artifact: build/gui-review/GuildborneGUIReview.rbxlx. Controller
continues to own Studio. No Studio calls, publishing or after screenshots produced
by this worker. Old screenshots remain historical and unchanged. Fresh native
screenshots are required at 796x675, a 600px-high window and 320px portrait, EN/TH,
including expanded settings and both empty/actual-owned-hero states.

Candidate SHA256: `089272c9c708ff8e81c4d9b26d5628f474862028cd1fd7957dfbdd906e0284af`.
BUILT_NOT_STUDIO_TESTED. Local tools/validate.ps1 passed: 890 game regressions,
Rojo build/sourcemap, strict analysis/compilation and repository checks. All 12
simulated GUI cases passed. Raw logs are in evidence/w3. Independent read-only
review found no blocking source issue; actual glyph bounds and Credits visibility
remain native review items.

The synthetic GUI checks exercise all four short labels, short-height responsive
branches, a bounded geometry count and viewport cleanup. They do not measure
Roblox glyph bounds or prove that Credits is on-screen in the engine. Actual
text fit, silhouette, camera framing, hero contrast and beauty remain pending.

Even with scenery and depth, native block/wedge geometry is not the supplied
painted illustration: fine architectural curves, fabric texture, atmospheric
painting and the original raster logo still lack approved runtime bindings.
No invented ID or reference screenshot overlay fills that gap. Device performance
for the 118-part viewport is also unmeasured; a bounded count is not a performance
acceptance result.

No changes to server authority, profile readiness, MenuRouter, shared HUD,
production plan or Studio spec. Same GUI task/PR and controller handoff apply.
