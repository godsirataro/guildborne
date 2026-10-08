--!strict
local project=require("../src/shared/Data/QuestNpcState")
return function(test: any,eq: any)
	local catalog={JournalOrder={"a","b","c","d"},Journal={
		a={Count=2},b={Count=3,NPC="Mira",Item="herb"},c={Count=1,Requires="a"},d={Count=1,NPC="Mira",Requires="b"}}}
	local function data(): any return {settlement={journal={}},inventory={stacks={}}} end
	test("NPC quest suggestions respect location and prerequisite receipts",function()
		local d=data();eq(project(d,catalog,"Mira").id,"b");eq(project(d,catalog,"City Herald").id,"a")
		eq(project(d,catalog,"Unknown"),nil);d.settlement.journal.a={state="Claimed",progress=2}
		eq(project(d,catalog,"City Herald").id,"c")
	end)
	test("NPC marker prioritizes ready then available then active deterministically",function()
		local d=data();d.settlement.journal.a={state="Active",progress=0};eq(project(d,catalog,"City Herald").symbol,"...")
		d.settlement.journal.c={state="Active",progress=1};eq(project(d,catalog,"City Herald").id,"c");eq(project(d,catalog,"City Herald").symbol,"?")
		d.settlement.journal.a.state="Claimed";d.settlement.journal.c=nil;eq(project(d,catalog,"City Herald").symbol,"!")
	end)
	test("NPC turn-in availability follows current inventory and isolates players",function()
		local a,b=data(),data();a.settlement.journal.b={state="Active",progress=99};b.settlement.journal.b={state="Active",progress=99}
		a.inventory.stacks.herb=3;eq(project(a,catalog,"Mira").priority,3);eq(project(b,catalog,"Mira").priority,1)
		a.inventory.stacks.herb=2;eq(project(a,catalog,"Mira").priority,1);eq(a.settlement.journal.b.progress,99)
	end)
	test("NPC marker clears completed content and missing snapshots",function()
		local d=data();for _,id in ipairs(catalog.JournalOrder) do d.settlement.journal[id]={state="Claimed",progress=99} end
		eq(project(d,catalog,"Mira"),nil);eq(project(d,catalog,"City Herald"),nil);eq(project(nil,catalog,"Mira"),nil)
	end)
	test("NPC dialogue lists every usable quest in stable priority order",function()
		local d=data();local c={JournalOrder={"old","new","ready","active","locked"},Journal={
			old={NPC="Ghar",Count=1},new={NPC="Ghar",Count=1},ready={NPC="Ghar",Count=1},active={NPC="Ghar",Count=2},locked={NPC="Ghar",Count=1,Requires="old"}}}
		d.settlement.journal.ready={state="Active",progress=1};d.settlement.journal.active={state="Active",progress=0}
		local rows=project(d,c,"Ghar",true);eq(#rows,4)
		for index,id in ipairs({"ready","old","new","active"}) do eq(rows[index].id,id) end
		eq(project(d,c,"Ghar").id,rows[1].id);eq(project(nil,c,"Ghar",true),{})
	end)
end
