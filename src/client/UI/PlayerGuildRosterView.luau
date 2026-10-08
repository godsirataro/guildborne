--!strict
-- Staged view; not registered in the live navigator or network protocol yet.
return function(ui:any)
	local confirmation:string?=nil
	local copy={
		en={title="Player Guild",members="Members",leader="Guild Master",Master="Master",Officer="Officer",Commander="Commander",Member="Member",you="You",leave="Leave guild",leaveConfirm="Confirm leaving this guild",cancel="Cancel",transfer="Leadership invitation",transferHelp="The current leader has invited you to become Guild Master.",accept="Review leadership transfer",acceptConfirm="Accept responsibility as Guild Master",leaveHelp="You must transfer leadership before leaving.",unavailable="Guild membership is unavailable. Try again shortly.",refresh="Refresh roster"},
		th={title="กิลด์ผู้เล่น",members="สมาชิก",leader="หัวหน้ากิลด์",Master="หัวหน้ากิลด์",Officer="เจ้าหน้าที่",Commander="ผู้บัญชาการ",Member="สมาชิก",you="คุณ",leave="ออกจากกิลด์",leaveConfirm="ยืนยันออกจากกิลด์นี้",cancel="ยกเลิก",transfer="คำเชิญรับตำแหน่งหัวหน้า",transferHelp="หัวหน้าคนปัจจุบันเชิญคุณรับตำแหน่งหัวหน้ากิลด์",accept="ตรวจสอบการโอนหัวหน้า",acceptConfirm="ยืนยันรับหน้าที่หัวหน้ากิลด์",leaveHelp="ต้องโอนตำแหน่งหัวหน้าก่อนออกจากกิลด์",unavailable="ยังอ่านข้อมูลสมาชิกไม่ได้ โปรดลองอีกครั้ง",refresh="โหลดรายชื่อใหม่"},
	}
	return function(snapshot:any,busy:boolean,language:string)
		local t=copy[language]or copy.en
		local messages=if language=="th"then {
			Creating="กำลังสร้างกิลด์",Joining="กำลังเข้าร่วมกิลด์",Cancelling="กำลังยกเลิกการเข้าร่วม",Removing="กำลังอัปเดตสมาชิก",
			pending="ยังยืนยันการบันทึกไม่ครบ โปรดโหลดสถานะใหม่ในอีกสักครู่",
			recovery="กำลังตรวจสอบข้อมูลสมาชิกที่ค้างอยู่ โปรดโหลดสถานะใหม่ก่อนทำรายการต่อ",
			empty="คุณยังไม่ได้เข้าร่วมกิลด์ผู้เล่น เกาะกิลด์ส่วนตัวและความคืบหน้าเดิมยังอยู่",
		}else {
			Creating="Creating your guild",Joining="Joining the guild",Cancelling="Cancelling the join",Removing="Updating membership",
			pending="Your membership update is not fully confirmed yet. Refresh shortly to check its status.",
			recovery="Your unfinished membership update needs recovery. Refresh its status before making another change.",
			empty="You have not joined a Player Guild. Your Personal Guild island and progress are still yours.",
		}
		local head=ui.card(ui.scroll,t.title)
		local function button(parent:Instance,label:string,name:string,callback:any)
			local b=ui.button(parent,label,not busy,function()if not busy then callback()end end);b.Name=name
		end
		button(head,t.refresh,"GuildRosterRefresh",function()ui.act("RefreshPlayerGuild")end)
		if not snapshot then confirmation=nil;ui.text(head,t.unavailable,16);return end
		if snapshot.state=="Pending"then
			confirmation=nil;ui.text(head,messages[snapshot.phase]or t.title,18)
			ui.text(head,if snapshot.needsRecovery then messages.recovery else messages.pending,16);return
		elseif snapshot.state=="Empty"then confirmation=nil;ui.text(head,messages.empty,16);return end
		local selfMember:any=nil
		ui.text(head,t.members..": "..#snapshot.members.." / "..snapshot.capacity,16)
		for _,member in ipairs(snapshot.members)do
			local title=(member.displayName or ("#"..member.userId))..(if member.isSelf then " · "..t.you else "")
			local row=ui.card(ui.scroll,title);row.Name="GuildMember_"..member.userId
			ui.text(row,t[member.role]or member.role,16)
			if member.isSelf then selfMember=member end
		end
		if not selfMember then confirmation=nil;return end
		local leaveKey="leave:"..snapshot.guildId..":"..selfMember.generation
		local offer=snapshot.transferOffer
		if offer then
			local panel=ui.card(ui.scroll,t.transfer);panel.Name="GuildTransferOffer";ui.text(panel,t.transferHelp,16)
			local key="transfer:"..offer.token
			if confirmation==key then
				button(panel,t.acceptConfirm,"GuildTransferConfirm",function()confirmation=nil;ui.act("AcceptGuildLeadership",{guildId=snapshot.guildId,token=offer.token,expectedGeneration=selfMember.generation})end)
				button(panel,t.cancel,"GuildTransferCancel",function()confirmation=nil;ui.render()end)
			else button(panel,t.accept,"GuildTransferReview",function()confirmation=key;ui.render()end)end
		end
		local footer=ui.card(ui.scroll,t.title)
		if selfMember.role=="Master"then ui.text(footer,t.leaveHelp,16)
		elseif confirmation==leaveKey then
			button(footer,t.leaveConfirm,"GuildLeaveConfirm",function()confirmation=nil;ui.act("LeavePlayerGuild",{guildId=snapshot.guildId,expectedGeneration=selfMember.generation})end)
			button(footer,t.cancel,"GuildLeaveCancel",function()confirmation=nil;ui.render()end)
		else button(footer,t.leave,"GuildLeaveReview",function()confirmation=leaveKey;ui.render()end)end
	end
end
