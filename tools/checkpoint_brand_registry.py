from pathlib import Path
root=Path(__file__).resolve().parents[1]
docs=root/'docs/uat01'
note='''## Latest brand and registry checkpoint — 2026-10-02

Title has three native brand symbols and Continue above the preview so it is visible at 260/640 x 340 in EN/TH. Loading stays disabled; ready and recovery routes passed synthetic checks. 53 symbols passed 1,323 primitive bounds checks at 18/24/48px. See validation-title-brand-runtime.json, validation-ui-symbols-runtime.json and title-continue-visible.png. Two original obsidian/parchment textures bring generated PNG sources to19; seam/import review remains pending. Actual central-city and personal-guild overview captures are saved in assets/uat01/world-captures; temporary camera scripts and UI overrides were removed, owned Play stopped. No profile writes.

All239 asset design rows now have a source or explicit reuse/unbound status; this does not mean239 production-ready assets. Registry retains65 screens (57alpha/8future),0human UAT approvals and no uploaded IDs. Updated Excel output: outputs/01a0f39c-43bd-7a81-917f-8a8cd02c0ddf/Guildborne_Production_Registry.xlsx, with four sheets, live count formulas and28 work areas. Original supplied workbook preserved. Domain baseline330PASS; main136runtimefiles. Last quota81%used/19%remaining. Continue to15%; release gates remain unchanged.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s if not s.startswith(note.splitlines()[0]) else s,encoding='utf-8')
for file in [docs/'STATUS.md',docs/'WORK_CHECKLIST.md',docs/'ASSET_MANIFEST.md',root/'assets/uat01/GALLERY.md',root/'assets/uat01/ui-symbols/README.md']:
 s=file.read_text(encoding='utf-8').replace('Seventeen','Nineteen').replace('17local generated','19local generated').replace('15 local PNG','19 local PNG').replace('50SVG/native','53SVG/native').replace('50 original','53 original').replace('50 symbols','53 symbols').replace('1,209','1,323')
 if file.name=='WORK_CHECKLIST.md':
  s=s.replace('Loading/Continue, language, credits, owned company preview','Loading/Continue above fold,3native brand symbols,EN/TH,credits,owned company preview;4compact state cases passed').replace('Native R6/R15 poses;','Live camp/Tower6joint animation with windup/culling/lifecycle checks; native R6/R15 poses;').replace('239 design slots are not239 finished images; source bindings and acceptance','239 source/reuse/unbound records reconciled; import, gameplay bindings and acceptance remain')
 if file.parent.name=='ui-symbols':
  s=s.replace('and eight empty states.','and eight empty states, plus three brand symbols.').replace('Five empty-state variants also appear','Three brand symbols are bound to TitleView. Five empty-state variants also appear')
 file.write_text(s,encoding='utf-8')
