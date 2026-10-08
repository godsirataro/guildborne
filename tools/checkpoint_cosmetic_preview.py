from pathlib import Path
import base64
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
for name in ('cosmetic-settings','cosmetic-controls'):
    (docs/(name+'.png')).write_bytes(base64.b64decode((root/'build'/(name+'.base64')).read_text()))
note='''## Latest preview and city traversal checkpoint — 2026-10-02

Settings now contains a bounded one-model CosmeticPreview for all8concepts, Previous/Next/45degree rotation, localized TH/EN names and explicit preview-only/static-emote notice. Shared CosmeticVisuals factory accepts optional ID; server CosmeticVisualKit is a compatibility wrapper. No ownership/equip/purchase commands. Sixteen framing cases (240/640width,8models) passed212part checks1696corners, cycling/cleanup/Thai strings; pointer Next passed in isolated UI and rotation passed in actual Settings. Short viewport scrolls through preview and controls. Screenshots cosmetic-settings.png and cosmetic-controls.png. Added stable card names after detecting ambiguous duplicate Frame paths in inspection. Registry8statuses now COSMETIC_PREVIEW_INTEGRATED_ENTITLEMENT_UNBOUND. Sources synced; Studio Edit, all owned Play stopped/fixtures cleared.

Physical city walk caught a pre-existing decorative CityHouse overlapping Alchemy Shop. CentralCityWorld now reserves main-building footprints with8stud margin before adding generic frontage. The entrance probe now includes the whole city, not only each building.155corridor samples/5buildings and837road samples/12roads pass. Neutral standard R15 at speed16/no auto-jump entered and exited all5actual buildings; validation-city-interior-walk.json. No player/profile mutation. Isolated cutaway gallery removed, camera restored.

Standalone ArtReview includes5furnished rooms and return pads:1544parts/19prompts/16travel destinations with floors. Three synthetic demos produced92damage events, cleaned up/restarted/double-destroyed safely. Current build includes14allowlisted dependency modules+ReviewWorld+Bootstrap,306KB; dependency boundary verifier passed. Fresh standalone-file complete join/travel still pending. Last full domain suite323; latest build/strict/compile/repo129runtimefiles passed before stable-card-name refinement (rebuild after that refinement as needed). Quota79% used/21% remaining; continue until15%.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8')
if not s.startswith(note):p.write_text(note+s,encoding='utf-8')
p=docs/'STATUS.md';s=p.read_text(encoding='utf-8').replace('last observed22% remaining','last observed21% remaining');p.write_text(s,encoding='utf-8')
p=docs/'WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('Guaranteed UAT simulation, preview/ownership/delivery; live commerce remains disabled','Settings model preview integrated; ownership/equip/delivery and guaranteed UAT simulation remain; live commerce disabled');p.write_text(s,encoding='utf-8')
p=root/'assets/uat01/cosmetic-kit/README.md';s=p.read_text(encoding='utf-8');s+='\nSettings integrates a local rotating preview via Shared.Data.CosmeticVisuals and client.UI.CosmeticPreview. Eight models passed framing at240/640px widths, localization, cycling and cleanup. This is a model preview, not a worn avatar try-on or entitlement implementation.\n';p.write_text(s,encoding='utf-8')
p=root/'assets/uat01/city-interior-kit/README.md';s=p.read_text(encoding='utf-8').replace('Physical walking, arbitrary avatar collision and final device performance acceptance remain pending.','Neutral standard R15 walked into and out of all five live buildings at speed16 without auto-jump. This caught and fixed overlapping decorative street frontage. Arbitrary avatar collision and final device performance acceptance remain pending.');p.write_text(s,encoding='utf-8')
