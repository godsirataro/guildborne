--!strict
-- Original local WAV sources exist. Populate only creator-approved uploaded IDs.
-- Empty bindings intentionally cause no network requests or placeholder sounds.
local C: any={AssetIds={},MaxVoices=16,MaxDistance=80,Defaults={Master=.75,UI=.7,Combat=.8,Music=.45},
    Attributes={Master="GuildborneAudioMaster",UI="GuildborneAudioUI",Combat="GuildborneAudioCombat",Music="GuildborneAudioMusic",Muted="GuildborneAudioMuted"}}
C.Cues={
    hover={group="UI",duration=.1,interval=.1},press={group="UI",duration=.145,interval=.08},back={group="UI",duration=.245,interval=.1},
    modal_open={group="UI",duration=.27,interval=.15},confirm={group="UI",duration=.365,interval=.15},error={group="UI",duration=.315,interval=.25},
    reward={group="UI",duration=.595,interval=.3},level_up={group="UI",duration=.765,interval=.3},recruit_reveal={group="UI",duration=.815,interval=.3},notification={group="UI",duration=.365,interval=.2},
    sword_swing={group="Combat",duration=.28,interval=.08},melee_hit={group="Combat",duration=.22,interval=.08},shield_block={group="Combat",duration=.48,interval=.1},
    bow_release={group="Combat",duration=.3,interval=.08},arrow_hit={group="Combat",duration=.22,interval=.08},fire_cast={group="Combat",duration=.85,interval=.1},
    frost_cast={group="Combat",duration=.75,interval=.1},heal_cast={group="Combat",duration=1.1,interval=.1},enemy_warning={group="Combat",duration=.9,interval=.15},
    boss_slam={group="Combat",duration=1.2,interval=.15},enemy_defeat={group="Combat",duration=.65,interval=.1},grass_step={group="Combat",duration=.16,interval=.15},
}
function C.validAsset(id: any): boolean
    if type(id)~="string" or #id>32 then return false end
    local digits=id:match("^rbxassetid://(%d+)$");local number=digits and tonumber(digits)
    return number~=nil and number>0 and number<9007199254740992
end
function C.actionCue(class: string,effect: string): string
    if effect=="Heal" then return "heal_cast" end
    if effect=="Guard" or effect=="Taunt" then return "shield_block" end
    if effect=="Slow" then return "frost_cast" end
    if class=="Archer" then return "bow_release" end
    if class=="Mage" or class=="Priest" then return "fire_cast" end
    return "sword_swing"
end
function C.hitCue(class:string):string return if class=="Archer" then "arrow_hit" else "melee_hit" end
return C
