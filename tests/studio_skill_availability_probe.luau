--!strict
-- Synthetic skill panels only. Never sends LearnSkill or modifies a profile.
return function()
    local p=game.Players.LocalPlayer;local ui=p.PlayerScripts.Client.UI
    local draw=require(ui.ExpansionView);local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
    local gui=Instance.new("ScreenGui");gui.Name="SkillAvailabilityFixture";gui.Parent=p.PlayerGui
    local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(240,600);host.Parent=gui
    local cases={
        {level=1,build={tier=1,skills={}}},
        {level=2,build={tier=1,skills={}}},
        {level=2,build={tier=1,skills={vitality=true}}},
        {level=10,build={tier=1,skills={vitality=true,focus=true}}},
        {level=30,build={tier=2,path="guardian",skills={vitality=true}}},
        {level=70,build={tier=3,path="fortress",skills={vitality=true,path_art=true}}},
        {level=70,fighting=true,build={tier=3,path="fortress",skills={vitality=true,path_art=true}}},
        {level=30,busy=true,build={tier=2,path="guardian",skills={vitality=true}}},
        {level=30,clear=true,build={tier=1,skills={}}},
        {level=70,clear=true,build={tier=2,path="guardian",skills={vitality=true}}},
    }
    local checks=0;local advancementChecks=0
    local ok,result=pcall(function()
        for _,width in ipairs({240,640}) do for _,lang in ipairs({"en","th"}) do for _,case in ipairs(cases) do
            host:ClearAllChildren();host.Size=UDim2.fromOffset(width,600)
            local function T(s: string,values:any?): string return locale.translate(lang,s,values) end
            local function text(parent: Instance,value: string,size: number?): TextLabel
                local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.TextSize=size or 18;l.Text=T(value);l.Parent=parent;return l
            end
            local function card(parent: Instance,_title: string): Frame
                local f=Instance.new("Frame");f.Size=UDim2.new(1,0,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
                local layout=Instance.new("UIListLayout");layout.Parent=f;return f
            end
            local function button(parent: Instance,value: string,enabled: boolean,_callback: any): TextButton
                local b=Instance.new("TextButton");b.Text=T(value);b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.Size=UDim2.new(1,0,0,52);b.TextWrapped=true;b.Active=enabled;b.Selectable=enabled;b.Parent=parent;return b
            end
            local render=draw({scroll=host,T=T,text=text,card=card,button=button,act=function()error("No mutations permitted")end,navigate=function()end,render=function()end})
            local data={character={classId="Knight",level=case.level,raceId="Human"},adventurers={},quests={firstClears={quarry_patrol=case.clear}},expansion={actors={player=case.build},gathered={},buildings={},tower={highest=if case.clear then 5 else 0,active=if case.fighting then {state="Fighting"} else nil}}}
            render("Skills",data,{Character={Classes={Knight={SkillId="taunt"}}}},case.busy==true)
            task.wait(.04)
            for _,id in ipairs(rules.SkillOrder) do
                local node=assert(host:FindFirstChild("Node_"..id,true)) :: TextButton
                local detail=assert(host:FindFirstChild("Learn_"..id,true)) :: TextButton
                local expected=not case.busy and not case.fighting and rules.learnProblem(case.build,case.level,id)==nil
                assert(node.Active==expected and detail.Active==expected,"Inconsistent skill gates: "..id)
                assert(node.Selectable==expected and detail.Selectable==expected,"Locked skill takes focus")
                assert(node.TextBounds.X<=node.AbsoluteSize.X and node.TextBounds.Y<=node.AbsoluteSize.Y,"Tree text clipped: "..id.." "..lang.." "..width)
                assert(node.Text:find(detail.Text,1,true),"Different lock reason")
                checks+=1
            end
            for id in pairs(rules.Paths) do
                local choice=host:FindFirstChild("Advance_"..id,true)
                if choice and choice:IsA("TextButton") then
                    local expected=not case.busy and not case.fighting and rules.advanceProblem(data,data.character,case.build,id)==nil
                    assert(choice.Active==expected and choice.Selectable==expected,"Wrong advancement gate: "..id)
                    assert(choice.TextBounds.X<=choice.AbsoluteSize.X and choice.TextBounds.Y<=choice.AbsoluteSize.Y,"Advancement reason clipped: "..lang.." "..width)
                    assert(not choice.Text:find("AdvancementLocked",1,true),"Raw error code shown")
                    advancementChecks+=1
                end
            end
        end end end
        return {checks=checks,advancementChecks=advancementChecks,states=#cases,widths={240,640},languages={"en","th"},consistentGates=true,noClipping=true,noProfileWrites=true,synthetic=true}
    end)
    gui:Destroy();assert(ok,tostring(result));return result
end
