--!strict
-- Read-only recollections from saved choices. Never changes rewards, gates or routes.
local records={
 caravan={
  rescue={"Sela: You pulled our people from the wreck. Today we bring supplies for everyone.","เซลา: เจ้าเคยช่วยคนของเราจากซากรถ วันนี้เรานำเสบียงมาช่วยทุกคน"},
  supplies={"Sela: You saved the caravan's food. We remember that care as we supply the alliance.","เซลา: เจ้าเคยกู้เสบียงของขบวน เราจำความใส่ใจนั้นได้และมาช่วยส่งของให้พันธมิตร"},
 },
 timber={
  workers={"The workers you supported have joined the relief crew.","คนงานที่เจ้าเคยช่วยมาร่วมทีมบรรเทาทุกข์แล้ว"},
  town={"The town you supplied has sent a relief crew.","เมืองที่เจ้าเคยส่งไม้ให้ได้ส่งทีมบรรเทาทุกข์มาแล้ว"},
 },
 reconciliation={
  shared_table={"Roka: We learned to listen at one table. Human and Orc voices stand together here.","โรกา: เราเรียนรู้ที่จะฟังกันที่โต๊ะเดียว เสียงมนุษย์กับออร์คยืนเคียงกันที่นี่"},
  joint_work={"Roka: Working side by side rebuilt our trust. Humans and Orcs will keep these names safe together.","โรกา: การทำงานเคียงกันฟื้นความไว้ใจ มนุษย์กับออร์คจะช่วยกันรักษารายชื่อเหล่านี้"},
 },
 warden={
  release={"The warden is free of the old oath. The alliance now carries this duty together.","ผู้เฝ้าพ้นคำสาบานเก่าแล้ว พันธมิตรรับหน้าที่นี้ร่วมกัน"},
  renew={"The warden accepted a new duty by choice. No oath binds an unwilling keeper.","ผู้เฝ้ายอมรับหน้าที่ใหม่ด้วยใจตนเอง ไม่มีคำสาบานผูกผู้ที่ไม่สมัครใจ"},
 },
}
local fallback={
 caravan={"Sela: The caravan is here. Let us bring these supplies safely to the alliance.","เซลา: ขบวนมาถึงแล้ว มาช่วยกันส่งเสบียงให้พันธมิตรอย่างปลอดภัยเถอะ"},
 timber={"Relief crews have gathered to help the alliance.","ทีมบรรเทาทุกข์มารวมตัวเพื่อช่วยพันธมิตร"},
 reconciliation={"Roka: Every neighbor deserves to be heard. Let us protect these names together.","โรกา: เพื่อนบ้านทุกคนควรได้รับการรับฟัง มาช่วยกันรักษารายชื่อเหล่านี้เถอะ"},
 warden={"The alliance will share the work of protecting the archive.","พันธมิตรจะแบ่งหน้าที่ดูแลหอจดหมายเหตุร่วมกัน"},
}
return function(data:any,kind:string):{string}?
 local progression=data and data.progression or {}
 local choices=progression.campaign and progression.campaign.choices or {}
 local selected=if kind=="caravan"then progression.novice and progression.novice.branch elseif kind=="timber"then choices.allocate_timber elseif kind=="reconciliation"then choices.choose_reconciliation elseif kind=="warden"then choices.choose_warden_release else nil
 local variants=records[kind];if not variants then return nil end
 local text=variants[selected]or fallback[kind]
 return {text[1],text[2]}
end
