		
function SuperSurvivorsRefreshSettings()

				Option_WarningMSG = SuperSurvivorGetOptionValue("Option_WarningMSG")
			
			Option_Perception_Bonus = SuperSurvivorGetOptionValue("Option_Perception_Bonus")
			
			Option_Display_Survivor_Names = SuperSurvivorGetOptionValue("Option_Display_Survivor_Names")
			Option_Display_Hostile_Color = SuperSurvivorGetOptionValue("Option_Display_Hostile_Color")
			
			Option_Panic_Distance = SuperSurvivorGetOptionValue("Option_Panic_Distance")
			
			Option_ForcePVP = SuperSurvivorGetOptionValue("Option_ForcePVP")
			Option_FollowDistance = SuperSurvivorGetOptionValue("Option_FollowDistance")
			SuperSurvivorBravery = SuperSurvivorGetOptionValue("Bravery")
			RoleplayMessage = SuperSurvivorGetOptionValue('RoleplayMessage')

			AlternativeSpawning = SuperSurvivorGetOptionValue("AltSpawn")
			AltSpawnGroupSize = SuperSurvivorGetOptionValue("AltSpawnAmount")
			AltSpawnPercent = SuperSurvivorGetOptionValue("AltSpawnPercent")
			NoPreSetSpawn = SuperSurvivorGetOptionValue("NoPreSetSpawn")
			NoIdleChatter = SuperSurvivorGetOptionValue("NoIdleChatter")
			
			DebugOptions = SuperSurvivorGetOptionValue("DebugOptions")
			DebugOption_DebugSay = SuperSurvivorGetOptionValue("DebugSay")
			DebugOption_DebugSay_Distance = SuperSurvivorGetOptionValue("DebugSay_Distance")
			
			SafeBase = SuperSurvivorGetOptionValue("SafeBase")
			SurvivorBases = SuperSurvivorGetOptionValue("SurvivorBases")
			SuperSurvivorSpawnRate = SuperSurvivorGetOptionValue("SpawnRate")
			ChanceToSpawnWithGun = SuperSurvivorGetOptionValue("GunSpawnRate")
			ChanceToSpawnWithWep = SuperSurvivorGetOptionValue("WepSpawnRate")
			ChanceToBeHostileNPC = SuperSurvivorGetOptionValue("HostileSpawnRate")
			MaxChanceToBeHostileNPC = SuperSurvivorGetOptionValue("MaxHostileSpawnRate") -- Fixed, it used to contain 'HostileSpawnRate', previously making MaxHostileSpawnRate a useless option
			
			SurvivorInfiniteAmmo = SuperSurvivorGetOptionValue("InfinitAmmo")
			SurvivorHunger = SuperSurvivorGetOptionValue("SurvivorHunger")
			SurvivorsFindWorkThemselves = SuperSurvivorGetOptionValue("FindWork")
			
			
			RaidsAtLeastEveryThisManyHours = SuperSurvivorGetOptionValue("RaidersAtLeastHours") --(60 * 24)
			RaidsStartAfterThisManyHours = SuperSurvivorGetOptionValue("RaidersAfterHours") -- (5 * 24)
			
			RaidChanceForEveryTenMinutes = SuperSurvivorGetOptionValue("RaidersChance") --(6 * 24 * 14)
	

end

SuperSurvivorsRefreshSettings()