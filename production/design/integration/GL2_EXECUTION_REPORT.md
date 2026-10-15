# GL-2.0 — execution batch 2026-10-15

**สถานะ: P0 เริ่มดำเนินการและยังเปิดอยู่; P1 แก้ follower recovery หนึ่งจุด; NOT PUBLIC READY.**

Public ครั้งแรกยังต้องครบ Lv100/Class3, Federation, สงคราม, ยึดพื้นที่ และตลาด Gold/วัสดุ รวมระบบอื่นตาม GL-2.0 ไม่มีการลดขอบเขตเป็น Lv35 หรือกำหนดวันเปิดจากการทดสอบรอบนี้

## สิ่งที่ทำในรอบนี้

- ใช้เอเจนต์จริงตรวจ inventory จากซอร์สและเส้นทางเมือง แบ่งงานแก้ HeroService และให้คนละเอเจนต์ตรวจกลับ ใช้ ledger เดียว `build/agentic/launch-v20-ledger.sqlite3`; coordinator ถือ `expansion-integration`, worker ถือ `shared-combat-coordinator` งานเดิมที่ยังไม่ commit ถูกเก็บไว้
- ปรับ `LATEST_GOALS.md`, `LAUNCH_PLAN.md`, `design/EXPANSION_PLAN.md`, `design/features.json`, `launch/backlog.json` และสัญญา Bond/Guild/LiveOps/web ให้ตรง GL-2.0 เก็บหลักฐาน/สถานะเดิม และย้าย phase เก่าไป `historicalPhase`/`historicalReleaseGate` เพื่อไม่เปลี่ยนผลทดสอบย้อนหลัง
- เพิ่ม [scope matrix](GL2_SCOPE_MATRIX.json):20 feature IDs เชื่อม17กลุ่มส่งมอบ พร้อมเจ้าของ แพ็กเกจ Forge พื้นฐานซอร์สและเกณฑ์รับงาน Federation/war/territory แยกชัดเจน งานภาพเริ่ม P1 และต้องครบ P8; เวลาที่เริ่มพัฒนาแยกจากเฟสตรวจรับ `foundationDependencies` เป็นพื้นฐานที่ต้องมีตอนเชื่อมระบบ ไม่ใช่การรอให้กลุ่มนั้นผ่าน final acceptance
- เพิ่ม [named source inventory](GL2_SOURCE_INVENTORY.md) จาก ID จริง รวม6arcs/36steps, Novice6, class paths, เมือง6แห่ง, body13, recipes/nodes/market allowlist ระบุ Hall18–20 ที่ยังไม่มี permit และเนื้อหาที่ต้องออกแบบต่อ จำนวน3combos/3stories/9research nodes/3events/3challenges/3territories ยังเป็นข้อเสนอ
- เพิ่ม `validate_gl2.py` และ regression16กรณี ป้องกัน Lv35 กลับเป็น Public, ระบบสำคัญถูกเลื่อนหลังเปิด, dependency/owner/path ผิด, งานภาพเริ่มช้า และการปิด P0 ทั้งที่ยังมีข้อค้าง ตัวตรวจนี้ไม่ใช่ release approver
- แก้ `HeroService.luau`: invalidation ของ generation เมื่อ recovery/respawn/parking/history reset/teleport/arrival/clear-line ทำให้ผล `ComputeAsync` เก่าไม่สามารถนำเส้นทางเดิมกลับมาใช้ Recovery หยุดคำสั่ง MoveTo เก่าด้วย ส่วน request ที่กำลังคำนวณยังถือ `computing` จนจบ เพื่อไม่เปิดหลาย request ซ้อนกัน

## ผลตรวจที่รันจริง

| ตรวจ | ผลและขอบเขต |
|---|---|
| `tools/setup_tools.ps1` | PASS; pinned development tools พร้อม |
| `tools/validate.ps1` ก่อนและหลังแก้ HeroService | PASS;885 Luau tests พร้อม build/sourcemap, Roblox analysis, compile, repository/boundary และ whitespace checks |
| `validate_gl2.py` | PASS เฉพาะ delivery metadata; `p0Complete=false`, `publicReady=false`,10 open decisions |
| `test_gl2_scope.py` |16 tests PASS; รวม regression ที่เพิ่มจาก reviewer เรื่องลำดับเริ่มงาน/สงคราม และ P5 ต้องผ่าน campaign/shared rewards |
| `check_hero_paths.py` |8 coordinator checks และ10 source-closure tests PASS; ใช้ scheduler/physics mocks ไม่ใช่ Studio |
| Recovery negative control | worker เอา recovery invalidation ออกจาก generated harness แล้วกรณีทดสอบล้มเหลวตามคาด; log เก็บแยก ไม่มีการเปลี่ยน production source เพื่อทำ negative control |
| Forge doctor/validate/plan | ตรวจจริง;55 task definitions/31 skill definitions ไม่ใช่55งานเสร็จ |
| Studio v3 validate/verify | PASS;33roles/10workflows และ98 generated files เป็น metadata เท่านั้น |
| Reconciliation / character contract |502assets/73screens/89kit assets,402 hashes,0missing references;15required body parts ไม่มีการสร้าง/อนุมัติ mesh |
| Studio MCP discovery | คืน `studios: []`; ไม่มี Studio playtest หรือ screenshot รอบนี้ |
| Independent review | Follower fix และ persisted checker ไม่มี blocking finding; แก้ข้อทักท้วง metadata เรื่องลำดับเริ่มงาน ข้อความ historical และการรับ P5 หลัง P3/P4 พร้อม regression |

Raw local logs อยู่ `build/agentic/gl2-setup.log`, `gl2-baseline.log`, `gl2-final-baseline.log`, `gl2_hero_path.stdout.log`, `gl2_hero_path.stderr.log` และ worker `gl2_hero_path_mutant.*.log` เก็บ empty streams ตามจริง ไม่แต่ง output

คำสั่งรันซ้ำจาก repository root:

```powershell
python production/design/integration/validate_gl2.py
python production/design/integration/test_gl2_scope.py
python production/design/integration/check_hero_paths.py
& ./tools/validate.ps1
```

## Source identity และข้อจำกัด

Base HEAD `c144c69bfbfab471f033b8ecbdd7c847014e124f` มีงานแก้ค้างจากก่อนเริ่มรอบนี้ ผลตรวจใช้ working tree ไม่ใช่ HEAD ที่สะอาด จึงไม่ submit เป็น clean-commit evidence และไม่ mark Forge accepted ไม่ commit รวมงานเดิมโดยไม่แยกตรวจ

HeroService SHA256: `9524acc7dea1ceabd87911ad1742f169e0162ccf93a37a454d6c5ec27e72aae6`.

Scope matrix SHA256: `5f1b83a6ac64b63727d353e8dbf62e3240e079501587bb68bc8eccbac878fbc8`.

Full baseline885 รวม coordinator tests เดิม แต่ไม่รวม10 source-harness tests หรือ16 Python metadata tests อย่ารวมตัวเลขเป็นจำนวน gameplay acceptance ใหม่

Follower test ดึง closure ปัจจุบันจากซอร์สด้วยขอบเขตที่ตรวจ uniqueness/order แล้วทดสอบ async ที่ควบคุมได้ ยังไม่พิสูจน์ Roblox pathfinding/physics/full heartbeat หรือการเดินห้าฮีโร่ผ่านประตู/บันได Character/parking/history reset ตัดผลเส้นทางเก่า แต่ไม่ได้เพิ่ม MoveTo cancellation ให้ทุก transition; พฤติกรรมเดิมส่วนนั้นต้องตรวจใน Studio

## งานถัดไปและเงื่อนไขที่ยังไม่ผ่าน

1. Gameplay/narrative/asset owners ปิด10รายการใน P0: named content, Hall18–20, proposed counts, war population/device budgets และ commerce contract แล้วแตก Forge scopes ให้ลงมือได้โดยไม่ชนกัน
2. World/art ใช้ P1 square→tavern→forge เป็นเส้นทางตรวจจริง บริการ `CityFuture` ที่ยังค้างต้องเชื่อมกับระบบที่มีอยู่ พร้อม NPC/tool contact, interiors, แสง/เสียง และ five-hero traversal
3. Technical/QA ต่อ P3 durable provider/travel/recovery และ P4 normal-input routes ทั้งทุก branch; เก็บ Studio, distinct-live-server, physical-device และ human evidence แยกกัน
4. หลังรวม source ที่ review แล้วจึงสร้าง clean candidate/recorded evidence ไม่มีการ publish, เปิดตลาด/commerce, paid upload หรือ production DataStore writes ในรอบนี้

วันเปิดยังไม่ล็อก; P0–P13 และการอนุมัติ release จริงยังไม่ถือว่าเสร็จ
