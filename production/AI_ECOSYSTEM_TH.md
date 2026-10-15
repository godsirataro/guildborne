# Guildborne AI Development Ecosystem

ปรับใช้จากเอกสาร NEONSHIFT ที่ผู้ใช้แนบ เมื่อ 2026-10-16 โดยต่อกับ Studio v3, Forge, Rojo และเกมที่มีอยู่ เป้าหมายคือให้ทีมเลือกทักษะและเครื่องมือถูกงาน ส่งต่องานตรวจสอบได้ และทำงานภาพขนานกับระบบตาม [GL-2.0](design/integration/FULL_GAME_GOLIVE_GL2_TH.md)

Public ครั้งแรกยังต้องมี Lv100, Class3, Federation, สงคราม, ยึดพื้นที่ และตลาด Gold/วัสดุของผู้เล่นครบ Lv35 เป็นการทดสอบภายใน งานภาพเริ่ม P1 และต้องครบ P8 การตรวจ ecosystem ผ่านไม่ได้ทำให้เกมผ่าน Go-live

## สิ่งที่นำมาใช้จริง

| แนวคิดจากเอกสาร | การใช้กับ Guildborne |
| --- | --- |
| ทีม AI แบ่งหน้าที่ | ใช้ 33 roles และ 10 workflows เดิมใน `studio/studio.json`; ตัว host เรียก subagent จริง จำนวนพร้อมกันขึ้นกับ host (รอบนี้รวม coordinator ได้ 4 ตัว) |
| ชุด Roblox skills | เชื่อม 31 project skills กับ supporting skills เฉพาะงาน สูงสุด 4 ตัวต่อ skill ผ่าน `studio/ecosystem.json` |
| Skill discovery | CLI `ecosystem.py route` แสดง primary skill, role, scopes และไฟล์ supporting skills พร้อม hash; ไม่อ่านแล้วเชื่อคำสั่งภายนอกโดยอัตโนมัติ |
| Toolchain ที่ทำซ้ำได้ | ใช้ checksum-pinned setup, Rojo/Luau/luau-lsp และ regression เดิม เพิ่ม manifest validation ใน CI ทั้ง Windows/Linux |
| Blender → Roblox | ใช้ workflow เดิม ตรวจ provenance, rig/mesh, import จริง และ Studio/device แยกขั้น; runtime ID ยังเป็น null จน import จริง |
| ตรวจรับโดยคนละผู้ทำ | ใช้ Forge ledger ร่วม, scopes และ independent review เดิม แยก local checks ออกจาก Studio/device/release acceptance |

แนวคิดรถแข่งแปลงเป็นงาน RPG ตามเนื้อหา: vehicle/tuning → hero locomotion, combat, class/skill/gear; garage → guild island/crafting; race → quests/bosses/Tower; traffic → friendly NPC routines; seasons → Federation/war/territory ห้ามย้ายสมมติฐานการขับรถหรือเศรษฐกิจของอีกเกมมาเป็นข้อกำหนดของเกมนี้

## วิธีเริ่มงาน

```powershell
python tools/agentic/ecosystem.py validate
python tools/agentic/ecosystem.py doctor
python tools/agentic/studio_mcp_preflight.py --strict
python tools/agentic/ecosystem.py route --task p1-city-services
python tools/agentic/ecosystem.py route --task shared-pve-reward-coordinator
python tools/agentic/ecosystem.py route --task market-integrity
```

เลือก skills root ได้ด้วย `--skills-root PATH`; ค่าเริ่มต้นคือ `CODEX_HOME/skills` หรือ `~/.codex/skills` ตาม host ใช้ `--root PATH` เมื่อรันจากภายนอก repository ทั้งสามคำสั่งอ่านอย่างเดียว ไม่ติดตั้ง ไม่รัน argv ใน manifest ไม่เรียกโมเดล ไม่ claim และไม่เปลี่ยนสถานะตรวจรับ

อ่าน `roblox-collaboration-mode` ก่อนเมื่อมี จากนั้นอ่าน project skill และเฉพาะ supporting skills ที่เกี่ยวข้อง หาก host ไม่มี skill ให้ทำงานด้วย project skill และเอกสารทางการต่อได้ การพบไฟล์หรือ hash ยืนยันได้เพียงไฟล์ในเครื่อง ไม่รับรองความถูกต้องหรือความทันสมัยของคำแนะนำในไฟล์

ก่อนแก้ไฟล์ยังต้องอ่าน source/รายงานล่าสุดตาม AGENTS, ตรวจ dependencies ด้วย Studio route, claim scope ผ่าน Forge โดยใช้ ledger เดียวของ coordinator และตรวจ lease ก่อนเขียน/รวมงาน ดู [ขั้นตอนทีม](STUDIO_V3.md) และ [execution](EXECUTION_V2.md) สำหรับ handoff และ reviewer

เครื่องมือจาก PR #2 รวมอยู่ใน workflow นี้แล้ว: `studio_mcp_preflight.py` ตรวจ registration ของ Codex แบบอ่านอย่างเดียว และ [Studio MCP / Multiplayer QA runbook](STUDIO_MCP_QA_RUNBOOK.md) ใช้กับ Memory preview ที่ตรวจ identity แล้ว Preflight ที่ผ่านยังไม่ใช่การเชื่อมต่อหรือผล playtest; registration ที่ปิดใช้งานต้องไม่ผ่าน `--strict`

## สองกระบวนการผลิต

**โค้ด:** ระบุ journey และ authoritative owner → อ่าน source จริง → claim → แก้พร้อม regression ที่มีความหมาย → ตรวจ Luau/build → สร้าง isolated preview → ทดสอบใน Studio → multiplayer/device/cross-server ตามงาน → independent review พร้อมหลักฐาน

```powershell
python -m unittest discover -s tests/agentic -v
python tools/agentic/studio.py validate
python tools/agentic/studio.py verify
pwsh -File tools/validate.ps1
python tools/build_integration_preview.py --launch
```

คำสั่ง preview สร้างไฟล์ทดสอบภายใน ไม่ใช่เปิดตัวเกม ค่าเกมปกติใช้ staging DataStore; ให้ใช้ isolated Memory preview ตาม workflow ทดสอบ ห้ามสรุปว่าเกมทุก build ใช้ Memory หรือให้ local test แตะ production data

**ภาพและเสียง:** กำหนดสัดส่วน/สไตล์/งบเครื่อง → ตรวจที่มาและสิทธิ์ → สร้าง source → ตรวจ geometry/rig/animation ใน Blender → export → import จริงและบันทึก runtime ID → ตรวจใน Studio → เครื่องจริงและ human art approval

```powershell
python tools/agentic/reconcile.py
python tools/agentic/character_contract.py
python tools/agentic/blender_job.py --help
```

P1 ใช้หนึ่งย่านเมืองเป็นมาตรฐาน: สัดส่วนอาคาร/ภายใน, ทาง NPC, จับเครื่องมือ, hero locomotion, combat, แสงและเสียง งานเมืองอื่นและตัวละครทำขนานกับระบบได้เมื่อ scopes ไม่ชนกัน P8 เป็นจุดที่งานภาพต้องครบ ไม่ใช่จุดเริ่มผลิต สถานะ generated, Blender-validated, imported, Studio-tested, device-tested และ human-approved ต้องบันทึกแยกกัน

## เครื่องมือและการติดตั้ง

| รายการ | การตัดสินใจรอบนี้ |
| --- | --- |
| Rojo, Luau, luau-lsp | ใช้ของเดิมผ่าน `tools/setup_tools.ps1` และ `tools/validate.ps1` คง Rojo 7.7.0 ที่ pin ไว้ |
| Studio MCP | ใช้ connector ที่มีอยู่ ตรวจ target identity ก่อนอ่าน/แก้เกมจริง |
| Blender | พบ binary 5.2 ที่เครื่องนี้; MCP handshake ยังล้มเหลว จึงยังไม่ยืนยัน live scene; งาน offline ใช้ Blender job/audit เดิมได้ |
| Roblox skills | พบ 29 host skills แล้ว ไม่ติดตั้งซ้ำ; project skills เป็นกติกาเฉพาะเกม |
| Wally/Pesde, Selene/StyLua/Lune | ยังไม่เพิ่ม ต้องมีปัญหาที่เครื่องมือช่วยแก้และทดลองแบบจำกัดก่อนเปลี่ยน baseline |
| Fusion/React | คง native UI และ `src/client/UI/SliceUI.luau` ไม่มีการย้าย UI framework |
| ProfileStore | คง `PlayerDataService` และ persistence adapters เดิม ไม่เปลี่ยน profile key, save schema หรือ migration จากตัวอย่างใน generic skills |
| Matter/ECS | ยังไม่เพิ่ม ไม่มีเหตุผลจาก profiling สำหรับการย้าย architecture รอบนี้ |
| Generators/Open Cloud ที่มีค่าใช้จ่าย | ยังไม่ใช้ การอนุญาตติดตั้งเครื่องมือไม่ใช่การอนุญาตค่าใช้จ่ายหรือเผยแพร่เกม |

Server ยังเป็นเจ้าของ currency/inventory/combat/rewards และตลาดยังรักษา fencing, receipts, session ownership, idempotency และ conservation ไม่ติดตั้งแพ็กเกจอื่นเพื่อแทนกลไกเหล่านี้โดยอัตโนมัติ

## ผลตรวจและแหล่งอ้างอิง

ผลสังเกตเครื่องและ MCP ณ 2026-10-16 อยู่ใน [research snapshot](research/ecosystem-2026-10-16/README.md) คำสั่ง doctor ตรวจเพียง filesystem; version ที่ยืนยันด้วย executable และผล live probe ต้องมีหลักฐานแยก

- [Roblox Studio MCP](https://create.roblox.com/docs/studio/mcp) อธิบาย MCP และการระบุ Studio instance; API ที่มีในเอกสารไม่เท่ากับเครื่องนี้เรียกได้ครบ
- [Roblox agent plugin](https://github.com/Roblox/roblox-studio-agent-plugin) เป็นแหล่งทางการสำหรับ configuration/skills ไม่จำเป็นต้องติดตั้งซ้อนเมื่อ connector เดิมทำ discovery ได้แล้ว
- [roblox-brain](https://github.com/TabooHarmony/roblox-brain) ระบุ 29 skills ขณะตรวจ ต่างจากจำนวน 28 ในเอกสารแนบ; รอบนี้ไม่ได้คัดลอกชุดภายนอกเข้า repository
- [Rojo 7.7.1](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1) มีรุ่นใหม่กว่า pin เดิม การมีรุ่นใหม่ไม่ใช่เหตุให้เปลี่ยน toolchain ระหว่างงานนี้
- [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService) อธิบาย multiplayer testing; ต้องพิสูจน์กับ host จริง และหลาย client ใน server เดียวไม่ใช่หลักฐาน cross-server

CI ตรวจโค้ดและสัญญาข้อมูลเท่านั้น การนำไปใช้รอบนี้ไม่เปลี่ยนวันเปิด ไม่เปิด commerce และไม่รับรองว่าผ่าน GL2 ภาพ, device, cross-server หรือ human release gates
