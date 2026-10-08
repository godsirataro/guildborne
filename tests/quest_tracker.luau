--!strict
local project=require("../src/shared/Data/QuestTracker")
return function(test: any,eq: any)
	local catalog={JournalOrder={"a","b","c"},Journal={
		a={Name="First",Description="Talk",Count=1,Category="Main"},
		b={Name="Gather",Description="Bring herbs",Count=3,Item="herb",Requires="a",NPC=true,Category="NPC"},
		c={Name="Battle",Description="Win",Count=2,Requires="b",Category="Side"}}}
	local function data(): any return {progression={tutorialStep="complete"},settlement={journal={}},inventory={stacks={}}} end
	test("earned Hall permit stays tracked after the final campaign and clears after upgrade",function()
		local c:any={Journal=catalog.Journal,JournalOrder=catalog.JournalOrder,CampaignChapter={Chapters={{HallPermit=2,Objectives={"first"}},{HallPermit=3,Objectives={"last"}}},ObjectiveLabels={first={"First","แรก"},last={"Last","สุดท้าย"}}}}
		local d=data();d.hallLevel=2;d.language="en";d.progression.campaign={claimed=2,hallPermit=3,objectives={}}
		local tracked=project(d,c,nil);eq(tracked.tab,"Guild");eq(tracked.focus,"UpgradeGuildHall");eq(tracked.name,"Return to guild island · Upgrade Hall 3");eq(tracked.ready,false)
		d.language="th";eq(project(d,c,nil).name,"กลับเกาะกิลด์ · อัปเกรดหอระดับ 3")
		d.hallLevel=3;eq(project(d,c,nil).id,"a");eq(d.progression.campaign.hallPermit,3)
		d.hallLevel=2;d.progression.campaign.claimed=1;eq(project(d,c,nil).focus,nil)
		d.progression.campaign.claimed=2;d.progression.campaign.hallPermit=2;eq(project(d,c,nil).id,"a")
	end)
	test("Novice tracker follows ordered lessons trial choice and founding before legacy tutorial",function()
		local c:any={Journal=catalog.Journal,JournalOrder=catalog.JournalOrder,NoviceChapter=require("../src/server/Config/NoviceChapter")}
		local d=data();d.character={};d.language="th";d.progression.tutorialStep="welcome";d.progression.novice={claimed=0,objectives={}}
		eq(project(d,c,nil).name,"พบคนส่งสาร");d.progression.novice.objectives.meet_courier=true;eq(project(d,c,nil).name,"เดินตามเส้นทางฝึก")
		d.progression.novice.claimed=5;d.progression.novice.objectives={};eq(project(d,c,nil).ready,false)
		d.progression.novice.trialClass="Mage";eq(project(d,c,nil).name,"Confirm first class")
		d.character.classId="Mage";eq(project(d,c,nil).name,"เคลียร์หอกิลด์ร้างด้วยตัวเอง")
		d.progression.novice.objectives={clear_abandoned_hall=true,register_guild=true};eq(project(d,c,nil).name,"Found my guild");eq(project(d,c,nil).ready,true)
	end)
	test("quest tracker respects prerequisite receipts before suggesting content",function()
		local d=data();eq(project(d,catalog,nil).id,"a")
		d.settlement.journal.a={state="Active",progress=1};eq(project(d,catalog,nil).kind,"Active")
		d.settlement.journal.a.state="Claimed";eq(project(d,catalog,nil).id,"b")
	end)
	test("quest tracker item progress follows current inventory, not stale event count",function()
		local d=data();d.settlement.journal.b={state="Active",progress=99};d.inventory.stacks.herb=1
		local r=project(d,catalog,"b");eq(r.progress,1);eq(r.ready,false);eq(r.npc,true)
		d.inventory.stacks.herb=20;r=project(d,catalog,"b");eq(r.progress,3);eq(r.ready,true)
		d.inventory.stacks.herb=nil;eq(project(d,catalog,"b").ready,false)
	end)
	test("quest tracker pin falls back after completion or an unknown selection",function()
		local d=data();d.settlement.journal.a={state="Active",progress=0};d.settlement.journal.b={state="Active",progress=0}
		eq(project(d,catalog,"b").id,"b");d.settlement.journal.b.state="Claimed"
		eq(project(d,catalog,"b").id,"a");eq(project(d,catalog,"foreign").id,"a")
	end)
	test("quest tracker guides existing onboarding but explicit active pin wins",function()
		local d=data();d.progression.tutorialStep="equip"
		eq(project(d,catalog,nil).kind,"Tutorial");eq(project(d,catalog,nil).tab,"Inventory")
		d.settlement.journal.a={state="Active",progress=0};eq(project(d,catalog,"a").kind,"Active")
	end)
	test("quest tracker empty or completed states do not invent rewards",function()
		eq(project(nil,catalog,nil),nil);local d=data()
		for _,id in ipairs(catalog.JournalOrder) do d.settlement.journal[id]={state="Claimed",progress=99} end
		eq(project(d,catalog,nil),nil);eq(d.settlement.journal.a.progress,99)
	end)
end
