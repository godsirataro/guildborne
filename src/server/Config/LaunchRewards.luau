--!strict
-- Preview balance only. No real season dates or commerce IDs are configured.
return {
 Version=1,Enabled=true,PremiumEnabled=false,ProductId=0,PassId=0,
 Daily={{Id="herb",Quantity=2},{Id="timber",Quantity=2},{Id="stone",Quantity=2},{Id="iron_ore",Quantity=1},{Id="herb",Quantity=3},{Id="timber",Quantity=3},{Id="iron_ingot",Quantity=1}},
 SeasonId="launch_preview_01",
 Tiers={
  {Milestone="MAIN_01_06",Claimed=6,Free={Id="herb",Quantity=2},Premium={Id="herb",Quantity=2}},
  {Milestone="MAIN_02_01",Claimed=7,Free={Id="timber",Quantity=2},Premium={Id="timber",Quantity=2}},
  {Milestone="MAIN_02_02",Claimed=8,Free={Id="stone",Quantity=2},Premium={Id="stone",Quantity=2}},
  {Milestone="MAIN_02_03",Claimed=9,Free={Id="iron_ore",Quantity=1},Premium={Id="iron_ore",Quantity=1}},
  {Milestone="MAIN_02_04",Claimed=10,Free={Id="herb",Quantity=3},Premium={Id="herb",Quantity=3}},
  {Milestone="MAIN_02_05",Claimed=11,Free={Id="iron_ingot",Quantity=1},Premium={Id="iron_ingot",Quantity=1}},
 },
}
