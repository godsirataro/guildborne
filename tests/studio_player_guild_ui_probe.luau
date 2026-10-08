--!strict
-- Synthetic roster and captured callbacks. Never sends network commands.
return function(draw:any):any
	local gui=Instance.new("ScreenGui");gui.Name="GuildRosterUIProbe";gui.Parent=game.Players.LocalPlayer.PlayerGui
	local host=Instance.new("ScrollingFrame");host.Size=UDim2.fromOffset(240,300);host.Parent=gui
	local views,bounds,actions=0,0,0
	local ok,result=pcall(function():any
		for _,width in ipairs({240,640,704})do for _,language in ipairs({"en","th"})do
			host.Size=UDim2.fromOffset(width,300)
			local callbacks:{[Instance]:any}={};local commands:{any}={};local render:any=nil
			local function text(parent:Instance,value:string,size:number?):TextLabel
				local v=Instance.new("TextLabel");v.Text=value;v.TextSize=size or 16;v.Font=Enum.Font.Gotham;v.TextWrapped=true;v.Size=UDim2.new(1,0,0,0);v.AutomaticSize=Enum.AutomaticSize.Y;v.Parent=parent;return v
			end
			local function card(parent:Instance,title:string):Frame
				local f=Instance.new("Frame");f.Size=UDim2.new(1,-24,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
				local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.Parent=f;text(f,title,20);return f
			end
			local function button(parent:Instance,value:string,enabled:boolean,callback:any):TextButton
				local b=Instance.new("TextButton");b.Text=value;b.Font=Enum.Font.Gotham;b.TextSize=16;b.TextWrapped=true;b.Size=UDim2.new(1,0,0,72);b.Active=enabled;b.Parent=parent;callbacks[b]=callback;return b
			end
			local function activate(name:string)local b=host:FindFirstChild(name,true);assert(b and callbacks[b],name);callbacks[b]()end
			local mine={userId="2",role="Member",isSelf=true,generation=1,displayName="นักผจญภัยแห่งกิลด์"}
			local snapshot:any={guildId="g",capacity=50,members={{userId="1",role="Master",generation=1,displayName="Guild Founder"},mine},transferOffer={token="g:transfer:1",fromUserId="1",expiresAt=100}}
			local busy=false
			local view=draw({scroll=host,card=card,text=text,button=button,act=function(action,payload)table.insert(commands,{action=action,payload=payload})end,render=function()render()end})
			render=function()host:ClearAllChildren();table.clear(callbacks);view(snapshot,busy,language)end
			local function inspect()
				task.wait(.1)
				for _,v in host:GetDescendants()do if v:IsA("TextLabel")or v:IsA("TextButton")then assert(v.TextBounds.X<=v.AbsoluteSize.X+1 and v.TextBounds.Y<=v.AbsoluteSize.Y+1,"Clipped "..language.." "..v.Text);bounds+=1 end end
				views+=1
			end
			render();inspect();activate("GuildTransferReview");inspect();assert(#commands==0)
			activate("GuildTransferCancel");inspect();assert(#commands==0)
			activate("GuildTransferReview");activate("GuildTransferConfirm");assert(#commands==1 and commands[1].payload.token=="g:transfer:1")
			render();activate("GuildLeaveReview");inspect();mine.generation=2;render();inspect();assert(not host:FindFirstChild("GuildLeaveConfirm",true),"Stale leave confirmation")
			activate("GuildLeaveReview");activate("GuildLeaveConfirm");assert(#commands==2 and commands[2].payload.expectedGeneration==2)
			busy=true;render();inspect();activate("GuildRosterRefresh");assert(#commands==2,"Busy action escaped")
			busy=false;mine.role="Master";snapshot.transferOffer=nil;render();inspect();assert(not host:FindFirstChild("GuildLeaveReview",true))
			snapshot=nil;render();inspect();assert(not host:FindFirstChild("GuildTransferReview",true))
			for _,phase in ipairs({"Creating","Joining","Cancelling","Removing"})do
				snapshot={state="Pending",phase=phase};render();inspect()
				assert(not host:FindFirstChild("GuildLeaveReview",true)and not host:FindFirstChild("GuildTransferReview",true))
			end
			snapshot={state="Pending",phase="Joining",needsRecovery=true};render();inspect()
			activate("GuildRosterRefresh");assert(#commands==3 and commands[3].action=="RefreshPlayerGuild")
			snapshot={state="Empty"};render();inspect();assert(not host:FindFirstChild("GuildLeaveReview",true))
			actions+=#commands
		end end
		return {views=views,textBounds=bounds,capturedActions=actions,scope="Synthetic roster EN/TH; no network or profile writes"}
	end)
	gui:Destroy();assert(ok,result);return result
end
