# Guildborne Regal Adventure — foundation candidate

2026-10-16. Presentation-only first slice; owner visual review precedes broad migration.

## Authority and intake

Art.UI remains the color authority: Navy #0F1523, Card #1A2231, Ivory #F5ECD8,
Gold #DCB76B, Burgundy #5B2735, Muted #C0C7BA, Border #68604A.
Focus derives from Art.Palette.Magic. Existing class/VFX colors are unchanged.
The exact existing user-approved logo and ten attached references are retained under
`design/guildborne-gui-production/03_REFERENCES`; REFERENCE_MANIFEST.json records
SHA-256, dimensions and origins. No image was generated, cropped, uploaded or used
as an interactive screen. Missing ZIP/spec/QA files are not claimed as received.

## Current component contract

- Theme: immutable colors/fonts/spacing; native Gotham family, no redistributed fonts.
- GuildbornePanel.create(parent, options): Frame with static gradient, double border,
  restrained corner diamonds, Decoration and Content. Put layouts in Content.
  Optional valid image ID + actual SliceCenter uses native 9-slice; native border
  remains when imagery is absent. No runtime image IDs supplied by this slice.
- GuildborneButton.create(parent, options): button, setDisabled, setPending,
  setSelected, destroy. Activated callback is guarded when disabled/pending;
  focus, hover and pressed are static states. Selected underline supplements hue.
  Minimum default height 48; callers retain responsibility for meaningful state copy.
- HeaderBar.create: live wordmark fallback, optional approved logo with Fit,
  subtitle and existing native ornament. setSubtitle, setCompact, destroy.
- TabBar.create: horizontal scroll with 148x48 tabs; select, setDisabled, destroy.
  Invalid/disabled IDs do not change selection. Programmatic selection does not
  dispatch a game intent. No remote calls in components.

## First live integration

TitleView retains update(view), isOpen(), ProfileReady, pinned MenuRouter registration,
existing language callback, settings and recovery callback. Continue is gated by a
real Active profile; leave is idempotent while hidden and destroys CompanyPreview.
At content widths below 720 the controls precede the company summary; desktop uses
two columns. The full content scrolls vertically including expanded settings/credits.
Inherited ScreenGui uses CoreUISafeInsets. Text is live EN/TH, wrapping and auto-height.
No new ScreenGui controller, snapshot schema, progression, currency or backend.

## Visual comparison to refs 01–10

01 informs navy/gold layered frames, burgundy primary action, selected/focus states.
02 informs readiness/branding: indeterminate text only, no copied 73% or castle image.
03 informs title navigation hierarchy. Real Continue/Language/Settings/Credits remain;
fictional news, premium counters and PvP buttons are not added.
04–10 inform the next reviewed migration stages only. Their geography, six stats,
classes, prices and ranks are not game authority. Current stats remain
STR/DEX/INT/VIT/WIS. Audit maps them to canonical runtime screens.

This is deliberately native geometric fallback art, not final embossed filigree,
cinematic key art or the imported official crest. Visual/device approval is pending.

## Engine decisions and evidence boundary

Official references checked 2026-10-16:
- https://create.roblox.com/docs/ui/9-slice
- https://create.roblox.com/docs/reference/engine/enums/ScreenInsets
- https://create.roblox.com/docs/ui/styling

StyleSheet exists in official docs but compatibility with this connected Studio
was not verified (no open place). Theme constructors are the bounded fallback;
no stylesheet or third-party runtime library is silently installed. No animation
loops were added; reduced motion needs no separate effect suppression in these controls.
Roblox font fallback/Thai metrics, focus, clipping and real input still need Studio
and device verification; static analysis does not establish them.
