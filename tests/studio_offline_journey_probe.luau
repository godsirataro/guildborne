--!strict
-- Public-network smoke journey for the separate offline place ONLY.
-- Real timers and normal receipts; no direct data edits, grants or clock skips.
return function(report: any?): any
    assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0,"Offline local file required")
    local remotes=game.ReplicatedStorage:WaitForChild("GuildborneRemotes")
    local command=remotes:WaitForChild("Command") :: RemoteEvent;local state=remotes:WaitForChild("State") :: RemoteEvent
    local latest: any=nil;local response: any=nil;local waiting: string?=nil;local log={}
    local connection=state.OnClientEvent:Connect(function(view)
        latest=view;if waiting and (view.requestId==waiting or (view.code=="InvalidRequest" and not view.requestId)) then response=view end
    end)
    local function progress(value: string) if report then report(value) end end
    local function transmit(packet: any,expected: string?): any
        task.wait(.65);waiting=packet.requestId;response=nil;command:FireServer(packet)
        local deadline=os.clock()+12;while not response and os.clock()<deadline do task.wait(.04) end
        waiting=nil;assert(response,"No response: "..packet.action)
        assert(response.code==expected,packet.action..": expected "..tostring(expected)..", got "..tostring(response.code))
        table.insert(log,{action=packet.action,code=expected or "STATE",revision=response.revision,gold=response.data and response.data.gold})
        return packet
    end
    local function send(action: string,args: any?,expected: string?): any
        return transmit({version=1,requestId=game.HttpService:GenerateGUID(false),revision=latest and latest.revision or 0,action=action,args=args or {}},expected or "OK")
    end
    local started=os.clock()
    local ok,result=pcall(function()
        progress("Verifying fresh memory profile")
        transmit({version=1,requestId=game.HttpService:GenerateGUID(false),revision=0,action="GetState",args={}},nil)
        assert(latest.status=="Active" and latest.mode:find("Studio memory",1,true),"Memory mode required before mutations")
        assert(latest.data.gold==0 and next(latest.data.adventurers)==nil and latest.data.character.classId==nil,"Fresh profile required")
        send("SetLanguage",{language="th"});send("BeginTutorial");send("SelectPlayerClass",{classId="Warrior"})
        send("Recruit",{classId="Warrior"});send("UpdateParty",{adventurerIds={"a:Warrior","a:Warrior"}},"InvalidParty")
        send("UpdateParty",{adventurerIds={"a:Foreign"}},"InvalidParty")
        local party=send("UpdateParty",{adventurerIds={"a:Warrior"}});local revision=latest.revision
        transmit(party,"AlreadyCommitted");assert(latest.revision==revision)
        party.args.adventurerIds={};transmit(party,"RequestConflict")
        send("UpgradeGuildHall",{},"HallLocked");send("StartQuest",{questId="missing"},"InvalidQuest")
        for _,id in ipairs({"trail_watch","timber_escort","quarry_patrol"}) do
            progress("Starting "..id);send("StartQuest",{questId=id})
            local active=latest.data.quests.active;local gold=latest.data.gold;revision=latest.revision
            send("CompleteQuest",{runId=active.runId},"QuestTooEarly");assert(latest.data.gold==gold and latest.revision==revision)
            send("UpdateParty",{adventurerIds={"a:Warrior"}},"QuestActive")
            progress("Waiting for real timer: "..id)
            while workspace:GetServerTimeNow()<active.completeAt+1 do task.wait(.25) end
            local claim=send("CompleteQuest",{runId=active.runId});gold=latest.data.gold;revision=latest.revision
            transmit(claim,"AlreadyCommitted");assert(latest.data.gold==gold and latest.revision==revision)
            send("CompleteQuest",{runId=active.runId},"QuestNotActive");assert(latest.data.gold==gold)
            if id=="trail_watch" then
                send("EquipItem",{instanceId="q:1:1",adventurerId="a:Warrior"});send("Recruit",{classId="Archer"})
                send("EquipItem",{instanceId="q:1:1",adventurerId="a:Archer"},"IncompatibleWeapon")
            elseif id=="timber_escort" then send("Recruit",{classId="Priest"}) end
        end
        progress("Upgrading Hall and checking saved receipt")
        assert(latest.data.gold==90 and latest.data.adventurers["a:Warrior"].xp==90)
        local hall=send("UpgradeGuildHall");assert(latest.data.gold==10 and latest.data.hallLevel==2 and latest.data.progression.tutorialCompleted)
        revision=latest.revision;transmit(hall,"AlreadyCommitted");assert(latest.data.gold==10 and latest.revision==revision)
        send("UpgradeGuildHall",{},"MissingMaterials");assert(latest.data.gold==10 and latest.revision==revision)
        return {mode=latest.mode,finalHall=latest.data.hallLevel,finalGold=latest.data.gold,heroXP=latest.data.adventurers["a:Warrior"].xp,
            tutorialCompleted=true,elapsedSeconds=os.clock()-started,steps=log,realQuestTimers=true,ordinaryProfileTouched=false,humanUAT=false}
    end)
    connection:Disconnect();assert(ok,tostring(result));return result
end
