# Guildborne NPC Living World Pack — วิธีใช้งานจริง

**ใช้กับโปรเจกต์ที่มีอยู่ ไม่สร้างเกมใหม่หรือรีเซ็ตงานสาม Session**

## เริ่มง่ายที่สุด

1. แตกไฟล์ ZIP ไปที่ `C:\Work\MySelf\Guildborne\design\Guildborne_Living_World_NPC_QuestReady_Pack_2026-10-17\` (หรือปรับตาม Root โปรเจกต์จริง)
2. เปิด Codex / Session **Master Controller** ใน Root `Guildborne` ที่เข้าถึง Git worktree, Forge ledger และ Roblox Studio ของเครื่องได้จริง
3. วางคำสั่งด้านล่าง โดยไม่ต้อง copy เนื้อหา Master Prompt ยาว ๆ เข้าห้องแชท

```text
Read completely:
design/Guildborne_Living_World_NPC_QuestReady_Pack_2026-10-17/01_FULL_MASTER_PRODUCTION_PROMPT.md

Read the 07_IMPLEMENTATION_CONTRACT.md and all data/research/reference files in this pack.
Act as Guildborne Executive World & NPC Systems Director with the EXISTING S13, S14, S15 workstreams.
Audit actual Git HEAD/branches, Forge ownership, current world/NPC/quest/appearance contracts and available Studio/Blender/Rojo tools.
Then implement W0 and the first dependency-ready W1 living city vertical slice; preserve all existing game and saved data.

Deliver NPC population and role design, stable quest-ready NPC identity, believable daily schedules, six-city multiculture, 4-race/13-body combinatorial appearances, proposed city/region secrets, and actual code/evidence for implemented increments.

Register safe tasks and route reviewed handoffs to the three workers only through available real tools; otherwise output copy/paste worker instructions.
Avoid conflicting shared writes, fake test passes, paid imports, release/publishing, persistent production writes and auto-merge.
Report a source-backed dashboard after every bounded wave.
```

4. เมื่อ Coordinator ตรวจสิทธิ์แก้ไฟล์ครบแล้ว ให้ส่ง Prompt S13/S14/S15 ที่แยกให้แต่ละ Session อย่างละไฟล์ (`02`, `03`, `04`) ผ่านช่องทางที่รองรับจริง หรือคัดลอกด้วยตัวเอง
5. เปิด `05` ให้ Content/Narrative Specialist และ `06` ให้ Character Art Specialist ผ่านงานที่ได้รับ Scope อย่างเป็นทางการ (ไม่เปิดหลาย Worker แก้ไฟล์เดียวกัน)
6. การพบ `Needs input` ให้ตอบเฉพาะคำถามที่รอจริง เช่น พล็อตราชวงศ์หรืออนุญาต Import, ไม่สมมติว่าอนุมัติค่าบริการ/อัปโหลดสาธารณะแล้ว

## สิ่งที่ ZIP มี

- `01` Master Prompt ครบกลยุทธ์และขั้นตอน W0-W5
- `02-04` Worker prompts สำหรับ Map / GUI / Animation, VFX, SFX
- `05-06` Specialists สำหรับ Narrative และ Modular Character
- `07` Implementation/Identity/Schedule/Quest/Save/QA contract
- `09` ทะเบียน NPC role/city/density/secret concepts และ QA matrix (ทั้งหมดเป็นข้อเสนอหรือ NOT_RUN)
- `10` แหล่งอ้างอิง Roblox/Source owner และบันทึกสิ่งที่ยังไม่ได้พิสูจน์
- `11` แบบส่งงาน/Checkpoint พร้อม evidence และ approval

## จุดย้ำสำคัญ

- `registered NPC` ไม่เท่ากับตัวที่แสดงพร้อมกัน; เป้าหมายต้นแบบ 80 Central + 55 x 6 cities = 410 **registrations** เป็นเพียงแผน
- ทุก NPC มี “โอกาสเป็น NPC เควสต์ได้ในอนาคต” ไม่เท่ากับต้องมีเควสต์สมบูรณ์ 410 ตัววันนี้
- 13 Body Presets เป็นฐานที่มีใน Catalog แต่ยังไม่ใช่ 13 Imported/Fit-tested Bodies ทั้งหมด
- เด็กและประชากรที่ไม่ต่อสู้ต้องมีพื้นที่/บทบาทปลอดภัย
- เสียง โมเดล โมชัน ปริศนาและเควสต์ใหม่ต้องผ่าน QA/สิทธิ์และ Server Authority ก่อนประกาศว่าทำเสร็จ
- ไม่มีการแก้ GitHub/Roblox จากการสร้าง ZIP ชุดนี้; Code Implementation เกิดเมื่อ Codex เจ้าของ Worktree เริ่มทำงานจริง
