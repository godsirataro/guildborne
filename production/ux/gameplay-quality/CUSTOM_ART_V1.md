# Original Guildborne gold frame candidate

Built-in image_gen produced an original transparent frame from the supplied brand-kit reference. Source is copied byte-for-byte into assets/production/ui-slice/guildborne-gold-frame-v1-source.png; ART_CANDIDATES.json records provenance, dimensions, reference hash and original output path. The source and existing official logo/textures remain unchanged.

Art brief: one square 512x512 transparent 9-slice panel frame, no labels/logo/icons/fill; bevelled bright gold outer edges and dark brass recesses; sculpted corner filigree; uniform straight double rails between corners; transparent central area; navy/burgundy reflections matching reference 1. Requested 8px outer margin, corner ornaments within64px and metal confined to56px edge band. No full-screen screenshot substitution or baked game data.

Actual output is 1254x1254, not the requested512x512. It has substantially richer painted metal, corner forms and cloth-colored recesses than the existing white CC0 mask, but is not yet a runtime-ready export. Center alpha is0..1 rather than exactly0; visible alpha>16 bounds have at least14px outer padding. Proposed source slice center320,320,934,934 preserves corner ornaments, subject to real native slicing review.

The local binder permits at most1024 per dimension and one million total pixels. This source alone uses1,572,516 pixels; registering it in manifest.images would break that contract. It is deliberately recorded separately as a candidate, not falsely marked bound/imported. A source-preserving technical export needs the explicit image-method choice already requested, or a suitable image-tool output within the budget. No silent Pillow resize, crop, or alpha modification was performed. A512x512 derivative plus the four current images would use301,360 pixels.

Separately, coordinator's Studio observation found12px compact tracker text small at796x617 despite successful rendering. Tracker now uses14px when its compact button width is at least200px, retains12px for narrow phone slots, and keeps desktop15px. This leaves geometry and44px hit target unchanged. The24-case GUI simulation and targeted Roblox analysis pass; glyph fit at14px still requires native EN/TH verification.

Coordinator reported actual tracker fixture rendering after prior layer fix, not a full quest journey. This worker has made no Studio claims or mutations. Existing game data and actions remain native and authoritative.
