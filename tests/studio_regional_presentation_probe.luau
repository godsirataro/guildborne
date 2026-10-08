--!strict
-- Client-only presentation fixtures: no remotes, damage, rewards or audio uploads.
return function():any
    local player=game.Players.LocalPlayer
    local source=player.PlayerScripts.Client.Controllers.CombatController
    local module=source:Clone();module.Name="RegionalPresentationFixtureModule"
    module.Source=module.Source:gsub('gui.Name="GuildborneCombatUI"','gui.Name="RegionalPresentationFixture"')
        :gsub('bar.Name="CombatHealthBar"','bar.Name="RegionalPresentationFixtureBar"')
        :gsub('local Audio=require%(script.Parent.AudioController%)',[[local Audio={Play=function(cue: string) script:SetAttribute(cue,(script:GetAttribute(cue) or 0)+1) end}]])
        :gsub('local effect=require%(script.Parent.SkillEffects%)%(%)',[[local effect=function() script:SetAttribute("Effects",(script:GetAttribute("Effects") or 0)+1) end]])
        :gsub('if not m:IsA%("Model"%) or entities%[m%] or','if not m:IsA("Model") or not m:GetAttribute("PresentationFixture") or entities[m] or')
        :gsub('Localization.translate%(language,key%)','Localization.translate(script:GetAttribute("FixtureLanguage") or "en",key)')
    module.Parent=source.Parent
    local active:any=nil;local fixtures={}
    local function make(owner:number):Model
        local model=Instance.new("Model");model.Name="PresentationFixture"
        local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Transparency=1
        root.Position=Vector3.new(29000,300,0);root.Parent=model;model.PrimaryPart=root
        model:SetAttribute("PresentationFixture",true);model:SetAttribute("GuildborneEnemy",true)
        model:SetAttribute("OwnerUserId",owner);model:SetAttribute("CombatHealth",100);model:SetAttribute("CombatMaxHealth",100)
        model:SetAttribute("EnemyTitle","Rune Hound");model:SetAttribute("CombatState","Windup");model:SetAttribute("TelegraphName","Rune Pounce")
        model.Parent=workspace;table.insert(fixtures,model);return model
    end
    local ok,result=pcall(function():any
        active=(require :: any)(module)()
        local own=make(player.UserId);local foreign=make(player.UserId-1234)
        local now=workspace:GetServerTimeNow()
        for _,model in ipairs({own,foreign}) do model:SetAttribute("RegionalTelegraphAt",now);model:SetAttribute("RegionalTelegraphUntil",now+1) end
        task.wait(.25)
        assert(module:GetAttribute("enemy_warning")==1,"Only owned warning should sound once")
        local bar=own:FindFirstChild("RegionalPresentationFixtureBar") :: BillboardGui
        local label=bar:FindFirstChildWhichIsA("TextLabel") :: TextLabel
        assert(label.Text:find("Rune Pounce") and label.Text:match("%d%.%ds"),"Visible warning countdown missing")
        assert(not (foreign:FindFirstChild("RegionalPresentationFixtureBar") :: BillboardGui).Enabled,"Foreign warning exposed")
        task.wait(.2);assert(module:GetAttribute("enemy_warning")==1,"Warning repeated every frame")
        own:SetAttribute("RegionalTelegraphUntil",nil);own:SetAttribute("CombatState","Attack")
        own:SetAttribute("RegionalImpactAt",workspace:GetServerTimeNow());task.wait(.2)
        assert(module:GetAttribute("melee_hit")==1 and not label.Text:match("%d%.%ds"),"Impact/cancel presentation wrong")
        own:SetAttribute("RegionalTelegraphAt",now-5);own:SetAttribute("RegionalTelegraphUntil",now-4)
        own:SetAttribute("RegionalImpactAt",now-5);task.wait(.2)
        assert(module:GetAttribute("enemy_warning")==1 and module:GetAttribute("melee_hit")==1,"Stale cues replayed")
        assert(module:GetAttribute("Effects")==nil,"Regional footprints invoked legacy circular VFX")
        local cases={
            {title="Greenwood Scout",hp=135,patterns={}}, {title="Greenwood Archer",hp=105,patterns={}},
            {title="Greenwood Boar",hp=180,patterns={"Boar Rush"}}, {title="Forest Captain",hp=650,boss=true,patterns={"Antler Cleave","Root Burst"}},
            {title="Quarry Raider",hp=210,patterns={}}, {title="Stone Guard",hp=320,patterns={}}, {title="Crystal Shaman",hp=165,patterns={}},
            {title="Quarry Guardian",hp=950,boss=true,patterns={"Hammer Fall","Fault Line"}}, {title="Arcane Sentinel",hp=260,patterns={}},
            {title="Rune Caster",hp=195,patterns={"Rune Flare"}}, {title="Rune Hound",hp=235,patterns={"Rune Pounce"}},
            {title="Arcane Warden",hp=1100,boss=true,patterns={"Rune Lance","Hollow Nova"}},
        }
        local checked=0
        local measurement=label:Clone();measurement.Name="BillboardTextMeasurement"
        measurement.Size=UDim2.fromOffset(bar.Size.X.Offset,bar.Size.Y.Offset);measurement.Position=UDim2.fromOffset(-1000,0)
        measurement.Parent=player.PlayerGui:FindFirstChild("RegionalPresentationFixture")
        for _,lang in ipairs({"en","th"}) do for _,row in ipairs(cases) do
            module:SetAttribute("FixtureLanguage",lang);own:SetAttribute("EnemyTitle",row.title)
            own:SetAttribute("CombatHealth",row.hp);own:SetAttribute("CombatMaxHealth",row.hp);own:SetAttribute("BossPhase",if row.boss then 2 else nil)
            local actions={"Idle"};for _,name in ipairs(row.patterns) do table.insert(actions,name) end
            for _,name in ipairs(actions) do
                own:SetAttribute("CombatState",if name=="Idle" then "Idle" else "Windup");own:SetAttribute("TelegraphName",name)
                own:SetAttribute("RegionalTelegraphUntil",if name=="Idle" then nil else workspace:GetServerTimeNow()+1.9)
                task.wait(.12);measurement.Text=label.Text;task.wait()
                assert(measurement.TextBounds.Y>0 and measurement.TextBounds.Y<=measurement.AbsoluteSize.Y-4 and measurement.TextBounds.X<=measurement.AbsoluteSize.X,"Billboard clipped "..lang.." "..row.title.." "..name)
                checked+=1
            end
        end end
        active.Destroy();active=nil
        assert(not own:FindFirstChild("RegionalPresentationFixtureBar"),"Billboard leaked after cleanup")
        return {countdown=true,ownedWarningOnce=true,foreignSilent=true,staleSilent=true,impactOnce=true,noLegacyCircle=true,bilingualBillboardCases=checked,cleanup=true,noProfileWrites=true,audioAssetPlaybackVerified=false}
    end)
    if active then active.Destroy() end
    for _,model in ipairs(fixtures) do model:Destroy() end
    module:Destroy();assert(ok,tostring(result));return result
end
