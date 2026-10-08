--!strict
export type EquipmentSlots = { weapon: string?, armor: string?, accessory: string? }
export type Weapon = { definitionId: string, upgradeLevel: number, binding: string }
export type Adventurer = { id: string, name: string, classId: string, level: number, xp: number,
	baseStats: { Health: number, Attack: number, Defense: number }, equipmentSlots: EquipmentSlots }
export type PlayerCharacter = { definitionVersion: number, raceId: string, tier: number, classId: string?, classPathId: string?, skillId: string?, level: number, xp: number, equipmentSlots: EquipmentSlots }
export type SkillBuild = {tier: number,path: string?,skills: {[string]: boolean},equipped: string?}
export type PlacedBuilding = {kind: string,x: number,z: number,rotation: number}
export type TowerRun = {id: string,floor: number,state: string}
export type ExpansionState = {buildings: {[string]: PlacedBuilding},nextBuilding: number,gatherReady: {[string]: number},gathered: {[string]: boolean},actors: {[string]: SkillBuild},raceChosen: boolean,tower: {highest: number,checkpoint: number,nextRun: number,active: TowerRun?}}
export type CombatIntent = { action: "Basic" | "Ability" }
export type Command = { version: number, requestId: string, action: string, revision: number, args: { [string]: any } }
export type Result = { code: string, reward: any?, questName: string?, revision: number? }
export type SessionStatus = "Loading" | "Active" | "Saving" | "Degraded" | "LoadFailed" | "LeaseLost" | "Closing"
return {}
