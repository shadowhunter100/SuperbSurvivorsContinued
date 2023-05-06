require "05_Other/SuperSurvivorManager";

--[[
	The functions here were cut-pasted here from "SuperSurvivorsMod.lua"; the spawning functions should only come after all configurations 
	and specifications are clearly defined and set.
--]]

function SuperSurvivorSoldierSpawn(square)
	local ASuperSurvivor = SSM:spawnSurvivor(nil, square)
	ASuperSurvivor:SuitUp("Preset_MarinesCamo")

	ASuperSurvivor:giveWeapon(RangeWeapons[ZombRand(1, #RangeWeapons)], true)
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));

	return ASuperSurvivor
end

function SuperSurvivorSoldierSpawnMelee(square)
	local ASuperSurvivor = SSM:spawnSurvivor(nil, square)
	ASuperSurvivor:SuitUp("Preset_MarinesCamo")

	ASuperSurvivor:giveWeapon(MeleWeapons[ZombRand(1, #MeleWeapons)], true)
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));

	return ASuperSurvivor
end

function SuperSurvivorSoldierSpawnHostile(square)
	local ASuperSurvivor = SSM:spawnSurvivor(nil, square)
	ASuperSurvivor:SuitUp("Preset_MarinesCamo")

	ASuperSurvivor:giveWeapon(RangeWeapons[ZombRand(1, #RangeWeapons)], true)
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor:setHostile(true)

	return ASuperSurvivor
end

function SuperSurvivorSoldierSpawnMeleeHostile(square)
	local ASuperSurvivor = SSM:spawnSurvivor(nil, square)
	ASuperSurvivor:SuitUp("Preset_MarinesCamo")

	ASuperSurvivor:giveWeapon(MeleWeapons[ZombRand(1, #MeleWeapons)], true)
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
	ASuperSurvivor:setHostile(true)

	return ASuperSurvivor
end
