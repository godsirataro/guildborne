--!strict
-- Borrowed training actors never grant or replace the saved player's class/gear.
return {
 practice_attack={Claimed=1,Level=3,Class="Warrior",EnemyHealth=120,Goals={basic_hit=1}},
 defeat_keeper={Claimed=3,Level=7,Class="Warrior",EnemyHealth=240,Goals={victory=1}},
 clear_abandoned_hall={Claimed=5,Level=10,SelectedClass=true,EnemyHealth=360,Goals={victory=1}},
 try_Warrior={Claimed=4,Level=9,Class="Warrior",EnemyHealth=700,Goals={skill_used=1}},
 try_Knight={Claimed=4,Level=9,Class="Knight",EnemyHealth=700,Goals={skill_used=1}},
 try_Archer={Claimed=4,Level=9,Class="Archer",EnemyHealth=700,Goals={skill_used=1}},
 try_Mage={Claimed=4,Level=9,Class="Mage",EnemyHealth=700,Goals={skill_used=1}},
 try_Priest={Claimed=4,Level=9,Class="Priest",EnemyHealth=700,Goals={skill_used=1}},
}
