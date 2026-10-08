from pathlib import Path
p=Path('docs/uat01/HANDOFF.md')
note='''## Camera readability and VFX lifetime checkpoint — 2026-10-02

CompanionOcclusion now fades only owned Following actors obstructing the local camera, restores prior LocalTransparencyModifier, handles late equipment/removal, and never changes server Transparency. Seven isolated cases passed; fresh bootstrap Play observed121 faded world parts and0 faded viewport parts. ActorPortrait/CompanyPreview clones explicitly reset local transparency. Evidence validation-companion-occlusion.json and companion-camera-fade.png. Controller integration is live; physical-device acceptance remains pending.

SkillEffects rejects detached actors, missing/expired boss warning stamps, and cancels warnings when actors leave Workspace even if still parented elsewhere. Archer/basic arcane delayed impacts now use caster-presence guards. Client fixture passed removal/cancel/expiry/impact cleanup with0 post-removal impact spawns; validation-vfx-lifecycle-runtime.json. Full src/tests strict analyze, compile, build and repository checks pass126runtime files; latest domain full suite remains320. All changed sources synced; owned Play stopped, fixtures removed. No persistent player changes or cloud publication. Latest quota78% used/22% remaining; continue toward15%.

'''
if not p.read_text(encoding='utf-8').startswith(note):
    p.write_text(note+p.read_text(encoding='utf-8'),encoding='utf-8')
