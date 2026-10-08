--!strict
return {
	Tick = .2, DetectionRange = 26, LeaderLeash = 38, EnemyLeash = 30,
	RecoveryDelay = 8, RecoveryPerSecond = 8, DownSeconds = 10,
	Classes = {
		Knight = { Range = 5, Interval = 1.5, Speed = 16, Threat = 3, Ability = "taunt" },
		Warrior = { Range = 5, Interval = 1.1, Speed = 17, Threat = 1, Ability = "power_strike" },
		Archer = { Range = 21, Interval = 1.5, Speed = 17, Threat = 1, Ability = "piercing_shot" },
		Mage = { Range = 19, Interval = 1.8, Speed = 16, Threat = 1, Ability = "fireball" },
		Priest = { Range = 17, Interval = 2.2, Speed = 16, Threat = .7, Ability = "heal" },
	},
	Abilities = {
		taunt = { Id = "taunt", Name = "Taunt", Cooldown = 9, Range = 14, TargetType = "Enemy", Effect = "Taunt", Duration = 3 },
		power_strike = { Id = "power_strike", Name = "Power Strike", Cooldown = 6, Range = 5, TargetType = "Enemy", Effect = "Physical", Multiplier = 2 },
		piercing_shot = { Id = "piercing_shot", Name = "Piercing Shot", Cooldown = 7, Range = 23, TargetType = "Enemy", Effect = "Physical", Multiplier = 1.8 },
		fireball = { Id = "fireball", Name = "Fireball", Cooldown = 8, Range = 22, TargetType = "Enemy", Effect = "Magic", Multiplier = 2.3 },
		heal = { Id = "heal", Name = "Heal", Cooldown = 5, Range = 23, TargetType = "Ally", Effect = "Heal", Multiplier = 2, Flat = 8 },
	},
	Goblin = { MaxHealth = 135, Attack = 12, Defense = 3, MoveSpeed = 12, AttackRange = 5, AttackInterval = 1.6,
		DetectionRange = 22, RespawnSeconds = 18, Reward = { Gold = 3, XP = 2 } },
}
