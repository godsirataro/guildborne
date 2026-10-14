--!strict
-- Candidate selection only. Never changes the saved XP/Hall rules or enables cloud writes.
return {
 Id="guildborne.launch.lv35.1",
 MaxLevel=35, MaxHall=4, CampaignChapters=12,
 Zones={City=true,Guild=true,Greenwood=true,Ironveil=true,Crownford=true,Sylvaris=true,Deepforge=true,Astralis=true,Crosshaven=true,Ironroot=true},
 Class2Paths={berserker=true,duelist=true,guardian=true,paladin=true,ranger=true,sniper=true,elementalist=true,spellblade=true,cleric=true,oracle=true},
 BlockedTasks={spire_entry=true,nyra_stonecharts=true,ashen_watch=true,ashen_warden=true,mogra_ashen_herbs=true,borga_ashen_stone=true},
 BlockedNodes={ashen_herbs=true,ashen_stone=true},
}
