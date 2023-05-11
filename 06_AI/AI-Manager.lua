require "05_Other/SuperSurvivorManager";

-- IDEA: If zombies near companion while reloading or something particular, run to player if player is further out
-- Bug: companions are pursing a target without they returning to the player when out of range

-- ---------------------------------------------------------- --
-- Functions to Attempt-Clean / Make this file easier to read --
-- #CleanCode      		                                      --
-- ---------------------------------------------------------- --
local isLocalLoggingEnabled = false;

--- Checks if TaskName the current task of the AiTmi
---@param AiTmi (table) Task Manager
---@param TaskName (string) Task name to be checked
---@return (boolean) returns true if the TaskName is the current task of AiTmi
function AiNPC_Task_Is(AiTmi, TaskName)
	return (AiTmi:getCurrentTask() == TaskName)
end

function AiNPC_TaskIsNot(AiTmi, TaskName) -- AiNPC_TaskIsNot(AiTmi,"TaskName")
	return (AiTmi:getCurrentTask() ~= TaskName)
end

function AiNPC_Job_Is(NPC, JobName) -- AiNPC_Job_Is(NPC,"JobName")
	return (NPC:getGroupRole() == JobName)
end

function AiNPC_Job_IsNot(NPC, JobName) -- AiNPC_Job_IsNot(NPC, "JobName")
	return (NPC:getGroupRole() ~= JobName)
end

function AIManager(TaskMangerIn)
	local ASuperSurvivor = TaskMangerIn.parent -- the previous variable, trying to convert to "NPC"
	local AiTmi          = TaskMangerIn     -- Used for AiNPC_TaskIsNot code cleanup/easier-to-read
	local NPC            = TaskMangerIn.parent -- Used to Cleanup some of the function's long names

	if (ASuperSurvivor:needToFollow()) or (ASuperSurvivor:Get():getVehicle() ~= nil) then return TaskMangerIn end -- if in vehicle skip AI -- or high priority follow

	if (TaskMangerIn == nil) or (ASuperSurvivor == nil) then
		return false
	end

	local Bravery = ASuperSurvivor:getBravePoints()
	if (Bravery == 0) then ASuperSurvivor:setBravePoints(4) end -- should never be 0
	local isRAMBO = 0                                        --  use to bypass some fleeing logic etc
	local CanTollerateEnemiesOnMe = 1;
	if (Bravery >= 10) then
		isRAMBO = 1
		CanTollerateEnemiesOnMe = 2
	end                          --need to by pass some hard coded values to give players option to have more fearless fighters
	if (SuperSurvivorBravery >= 20) -- suicidal
	then
		isRAMBO = 2
		CanTollerateEnemiesOnMe = 20
	end

	local EnemyIsSurvivor = (instanceof(ASuperSurvivor.LastEnemeySeen, "IsoPlayer"))
	local EnemyIsZombie = (instanceof(ASuperSurvivor.LastEnemeySeen, "IsoZombie"))
	local EnemySuperSurvivor = nil
	local LastSuperSurvivor = nil
	local EnemyIsSurvivorHasGun = false
	local LastSurvivorHasGun = false

	if (EnemyIsSurvivor) then
		local id = ASuperSurvivor.LastEnemeySeen:getModData().ID

		EnemySuperSurvivor = SSM:Get(id)
		if (EnemySuperSurvivor) then
			EnemyIsSurvivorHasGun = EnemySuperSurvivor:hasGun()
		end
	end
	if (ASuperSurvivor.LastSurvivorSeen) then
		local lsid = ASuperSurvivor.LastSurvivorSeen:getModData().ID

		LastSuperSurvivor = SSM:Get(lsid)
		if (LastSuperSurvivor) then
			LastSurvivorHasGun = LastSuperSurvivor:hasGun()
		end
	end

	local HostileInNPCsRange = NPC:isEnemyInRange(NPC.LastEnemeySeen)
	local IHaveInjury = ASuperSurvivor:HasInjury()
	local weapon = ASuperSurvivor.player:getPrimaryHandItem()
	local AttackRange = ASuperSurvivor:getAttackRange()
	local IsInAction = ASuperSurvivor:isInAction()
	local HisGroup = ASuperSurvivor:getGroup()
	local IsInBase = ASuperSurvivor:isInBase()
	local CenterBaseSquare = nil
	local DistanceBetweenMainPlayer = getDistanceBetween(getSpecificPlayer(0), ASuperSurvivor:Get())
	local Distance_AnyEnemy = getDistanceBetween(ASuperSurvivor.LastEnemeySeen, ASuperSurvivor:Get()) -- idk if this works
	if (HisGroup) then CenterBaseSquare = HisGroup:getBaseCenter() end
	local ImFollowingThisChar = ASuperSurvivor:getFollowChar()

	-- Simplified Local functions
	local function Task_Is_Not(TaskName)
		return (AiTmi:getCurrentTask() ~= TaskName)
	end
	local function Task_Is(TaskName)
		return (AiTmi:getCurrentTask() == TaskName)
	end

	-- --------------------------------------- --
	-- Companion follower related code         --
	-- --------------------------------------- --
	if (ASuperSurvivor:getGroupRole() == "Companion") then
		if (ASuperSurvivor:needToFollow())
		then
			NPC.LastEnemeySeen = nil
			TaskMangerIn:clear()
			TaskMangerIn:AddToTop(FollowTask:new(ASuperSurvivor, getSpecificPlayer(0)))
		end
	end

	if (AiNPC_Job_Is(NPC, "Companion")) then --and (DistanceBetweenMainPlayer <= 12)) then
		-- ------------------------- --   				
		-- reminder: NPC:NPCTask_DoAttack() already
		-- checks 'if task ~= attack, then do attack' in it
		-- Adding it to here too just makes the companions freeze
		-- ------------------------- --
		-- Edit: I have trid so many other ways to do this. Any other way the companion just doesn't do anything.
		-- So it's staying like this for now
		-- Don't add 'and AiNPC_TaskIsNot(AiTmi,"First Aide")' because you want companions to still attack enemies while hurt
		-- ------------------------- --

		-- ----- Perception Buff --- --

		-- ------------ --
		-- Pursue
		-- ------------ --
		if AiNPC_TaskIsNot(AiTmi, "First Aide") and AiNPC_TaskIsNot(AiTmi, "Pursue") and AiNPC_TaskIsNot(AiTmi, "Attack") and AiNPC_TaskIsNot(AiTmi, "Flee") and (NPC.LastEnemeySeen ~= nil and Distance_AnyEnemy < NPC:NPC_CheckPursueScore()) then
			if (EnemyIsSurvivor or EnemyIsZombie) then
				TaskMangerIn:AddToTop(PursueTask:new(ASuperSurvivor, ASuperSurvivor.LastEnemeySeen))
			end
		end
		-- ----------- --
		-- Attack
		-- ----------- --
		-- ----- Perception Buff --- --
		-- ------------------------- --
		--Nolan:removed a lot of conditions here so that we can just focus on adjusting conditions inside isTooScaredToFight() function
		if (
				(TaskMangerIn:getCurrentTask() ~= "Attack")
				and (TaskMangerIn:getCurrentTask() ~= "Threaten")
				and (TaskMangerIn:getCurrentTask() ~= "First Aide")
				and (Task_Is_Not("Flee"))
				and (ASuperSurvivor:isInSameRoom(ASuperSurvivor.LastEnemeySeen))

			)
			--and ( (ASuperSurvivor:isEnemyInRange(ASuperSurvivor.LastEnemeySeen)))  -- this make them not move to engage zombie even a few tiles away when in follow mode? is that intentional
			and (ASuperSurvivor:getDangerSeenCount() > 0)                                                           -- cant attack what you don't see. must have seen an enemy in danger range to attack
			and ((getDistanceBetween(ASuperSurvivor.LastEnemeySeen, ImFollowingThisChar) < (GFollowDistance + AttackRange))) -- move to engage an enemie only if they within follow range (when following)

			and (not NPC:isTooScaredToFight())
		--	and (ASuperSurvivor:inFrontOfLockedDoor() == false)
		then
			if (ASuperSurvivor.player ~= nil)
				and (ASuperSurvivor.player:getModData().isRobber)
				and (not ASuperSurvivor.player:getModData().hitByCharacter)
				and EnemyIsSurvivor
				and (not EnemySuperSurvivor.player:getModData().dealBreaker)
			then
				TaskMangerIn:AddToTop(ThreatenTask:new(ASuperSurvivor, EnemySuperSurvivor, "Scram"))
			else
				TaskMangerIn:AddToTop(AttackTask:new(ASuperSurvivor))
			end
		end

		-- --------------------------------- --
		-- 	Reload Gun
		--  NPC:getDangerSeenCount() removed
		-- --------------------------------- --
		if (ASuperSurvivor:getNeedAmmo()) and (ASuperSurvivor:hasAmmoForPrevGun())
		then
			NPC:setNeedAmmo(false)
			NPC:reEquipGun()
		end

		-- --------------------------------- --
		-- 	Ready Weapon
		--  NPC:getDangerSeenCount() removed
		-- --------------------------------- --
		if ((NPC:needToReload())
				or (NPC:needToReadyGun(weapon)))
			and ((ASuperSurvivor:hasAmmoForPrevGun())
				or SurvivorInfiniteAmmo)
			and NPC:usingGun() -- removed and (ASuperSurvivor:getNeedAmmo() condition -
		then
			NPC:ReadyGun(weapon)
		end

		-- ----------------------------- --
		-- 	Equip Weapon                 --
		-- ----------------------------- --
		if (ASuperSurvivor:hasWeapon()) and (ASuperSurvivor:Get():getPrimaryHandItem() == nil) and (TaskMangerIn:getCurrentTask() ~= "Equip Weapon") then
			TaskMangerIn:AddToTop(EquipWeaponTask:new(ASuperSurvivor))
		end

		-- Careful setting up Flee to heal and 'healing', they will conflict very easily.
		-- -----------   --
		-- Flee to heal  --
		-- -----------   --
		if (TaskMangerIn:getCurrentTask() ~= "Flee")
			and (isRAMBO < 2)
			and (
				((NPC.EnemiesOnMe > CanTollerateEnemiesOnMe) and (NPC.dangerSeenCount > Bravery) and (NPC:hasWeapon()) and (not NPC:usingGun())) -- Melee
				or ((NPC.EnemiesOnMe > CanTollerateEnemiesOnMe) and (NPC.dangerSeenCount > Bravery) and (NPC:hasWeapon()) and (NPC:usingGun())) -- Gun general
				or ((NPC.EnemiesOnMe > 0) and ((ASuperSurvivor:needToReload()) or (ASuperSurvivor:needToReadyGun(weapon))))
				or (IHaveInjury and NPC.dangerSeenCount > 0)
				or (NPC.dangerSeenCount >= 5)
			)
		then
			TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
		end

		-- ----------- --
		-- Healing	   --
		-- ----------- --
		if (IHaveInjury and NPC.dangerSeenCount <= 0) then
			if (TaskMangerIn:getCurrentTask() ~= "First Aide")
			then
				TaskMangerIn:AddToTop(FirstAideTask:new(ASuperSurvivor)) -- If general healing
			end
		end
	end

	-- --------------------------------------- --
	-- Companion follower related code | END   --
	-- --------------------------------------- --



	-- --------------------------------------------------------------------- --
	-- ------------------- Non Companion Shared ---------------------------- --
	-- 	if(ASuperSurvivor:Get():getModData().isHostile) and (ASuperSurvivor:isSpeaking() == false) then ASuperSurvivor:Speak(getSpeech("GonnaGetYou")) end
	--	Removed. You want it? Add it back in the line above pursuetask		 --
	-- --------------------------------------------------------------------- --

	-- 'If enemy is in a fair range and Pursue_SC checks out, and the NPC's enemy is in Pursue Score's range'
	-- --------------------------------------- --
	-- Pursue Task 							   --
	-- --------------------------------------- --
	-- To make NPCs find their target that's very close by
	if not (AiNPC_Job_Is(NPC, "Companion")) then
		if (ASuperSurvivor:Task_IsPursue_SC() == true) and (Distance_AnyEnemy <= 9) and (Distance_AnyEnemy < NPC:NPC_CheckPursueScore()) then
			if (NPC:NPC_FleeWhileReadyingGun()) then
				TaskMangerIn:AddToTop(PursueTask:new(ASuperSurvivor, ASuperSurvivor.LastEnemeySeen)) -- If all checks out, pursue target
			end
		end
	end

	-- I haven't tampered with this one, it does OK for the most part.
	-- Bug: If you shoot the gun and it has nothing in it, the NPC will still keep their hands up
	-- ----------------------------- --
	-- 		Surrender Task	
	-- ----------------------------- --
	if (getSpecificPlayer(0) ~= nil) then
		local facingResult = getSpecificPlayer(0):getDotWithForwardDirection(ASuperSurvivor.player:getX(),
			ASuperSurvivor.player:getY())
		--ASuperSurvivor:Speak( tostring(facingResult) )
		if ((TaskMangerIn:getCurrentTask() ~= "Surender")
				and (TaskMangerIn:getCurrentTask() ~= "Flee")
				and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
				and (TaskMangerIn:getCurrentTask() ~= "Clean Inventory")
				and (SSM:Get(0) ~= nil and SSM:Get(0):usingGun())
				and getSpecificPlayer(0)
				and getSpecificPlayer(0):CanSee(ASuperSurvivor.player)
				and (not ASuperSurvivor:usingGun() or (not ASuperSurvivor:RealCanSee(getSpecificPlayer(0)) and DistanceBetweenMainPlayer <= 3))
				and getSpecificPlayer(0):isAiming()
				and IsoPlayer.getCoopPVP()
				and not ASuperSurvivor:isInGroup(getSpecificPlayer(0))
				and (facingResult > 0.95)
				and (DistanceBetweenMainPlayer < 6))
		then
			TaskMangerIn:clear()
			TaskMangerIn:AddToTop(SurenderTask:new(ASuperSurvivor, SSM:Get(0)))
			return TaskMangerIn
		end
	end

	-- ----------------------------- --
	-- Attack / Threaten Target Task --
	-- ----------------------------- --
	--	if ((TaskMangerIn:getCurrentTask() ~= "Attack") and (TaskMangerIn:getCurrentTask() ~= "Threaten") and not ((TaskMangerIn:getCurrentTask() == "Surender") and EnemyIsSurvivor) and (TaskMangerIn:getCurrentTask() ~= "Doctor") and (ASuperSurvivor:isInSameRoom(ASuperSurvivor.LastEnemeySeen)) and (TaskMangerIn:getCurrentTask() ~= "Flee")) and ((ASuperSurvivor:hasWeapon() and ((ASuperSurvivor:getDangerSeenCount() >= 1) or (ASuperSurvivor:isEnemyInRange(ASuperSurvivor.LastEnemeySeen)))) or (ASuperSurvivor:hasWeapon() == false and (ASuperSurvivor:getDangerSeenCount() == 1) and (not EnemyIsSurvivor))) and (IHaveInjury == false) and (ASuperSurvivor:inFrontOfLockedDoor() == false)  then

	if not (AiNPC_Job_Is(NPC, "Companion")) then
		--Nolan:removed a lot of conditions here so that we can just focus on adjusting conditions inside isTooScaredToFight() function
		if (
				(TaskMangerIn:getCurrentTask() ~= "Attack")
				and (TaskMangerIn:getCurrentTask() ~= "Threaten")
				and (TaskMangerIn:getCurrentTask() ~= "First Aide")
				and (Task_Is_Not("Flee"))

				and (ASuperSurvivor:isInSameRoom(ASuperSurvivor.LastEnemeySeen))
			)
			--and ( (ASuperSurvivor:isEnemyInRange(ASuperSurvivor.LastEnemeySeen)))  -- this make them not move to engage zombie even a few tiles away when in follow mode? is that intentional
			and (ASuperSurvivor:getDangerSeenCount() > 0)                                                                                               -- cant attack what you don't see. must have seen an enemy in danger range to attack
			and (NPC:getCurrentTask() ~= "Follow" or (getDistanceBetween(ASuperSurvivor.LastEnemeySeen, ImFollowingThisChar) < (GFollowDistance + AttackRange))) -- move to engage an enemie only if they within follow range (when following)

			and (not NPC:isTooScaredToFight())
		--	and (ASuperSurvivor:inFrontOfLockedDoor() == false)
		then
			if (ASuperSurvivor.player ~= nil)
				and (ASuperSurvivor.player:getModData().isRobber)
				and (not ASuperSurvivor.player:getModData().hitByCharacter)
				and EnemyIsSurvivor
				and (not EnemySuperSurvivor.player:getModData().dealBreaker)
			then
				TaskMangerIn:AddToTop(ThreatenTask:new(ASuperSurvivor, EnemySuperSurvivor, "Scram"))
			else
				TaskMangerIn:AddToTop(AttackTask:new(ASuperSurvivor))
			end
		end
	end

	-- ----------------------------- --
	-- New: To attempt players that are NOT trying to encounter a fight,
	-- should be able to run away. maybe a dice roll for the future?
	-- ----------------------------- --
	if not (AiNPC_Job_Is(NPC, "Companion")) then
		if (EnemyIsSurvivor) and ((Task_Is("Threaten")) and (Distance_AnyEnemy > 10)) and (Task_Is_Not("Flee")) then
			TaskMangerIn:AddToTop(WanderTask:new(ASuperSurvivor))
			TaskMangerIn:AddToTop(AttemptEntryIntoBuildingTask:new(ASuperSurvivor, nil))
			TaskMangerIn:AddToTop(WanderTask:new(ASuperSurvivor))
			TaskMangerIn:AddToTop(FindBuildingTask:new(ASuperSurvivor))
		end
	end

	-- ----------------------------- --
	-- find safe place if injured and enemies near		this needs updating
	-- ----------------------------- --
	--	if (TaskMangerIn:getCurrentTask() ~= "Find Building") and (TaskMangerIn:getCurrentTask() ~= "Flee") and (IHaveInjury) and (ASuperSurvivor:getDangerSeenCount() > 0) then
	if not (AiNPC_Job_Is(NPC, "Companion")) then
		if (TaskMangerIn:getCurrentTask() ~= "Find Building")
			and (TaskMangerIn:getCurrentTask() ~= "First Aide")
			and (TaskMangerIn:getCurrentTask() ~= "Flee")
			and ((IHaveInjury) and (ASuperSurvivor:isTooScaredToFight()))
			and (ASuperSurvivor:getDangerSeenCount() > 0)
		then
			TaskMangerIn:AddToTop(FindBuildingTask:new(ASuperSurvivor))
		end
	end
	-- ----------------------------- --
	-- bandage injuries if no threat near by
	-- Companions have their own healing rule
	-- ----------------------------- --
	if not (AiNPC_Job_Is(NPC, "Companion")) then
		if (IHaveInjury) then
			if (TaskMangerIn:getCurrentTask() ~= "First Aide")
				and (TaskMangerIn:getCurrentTask() ~= "Flee")
				and (TaskMangerIn:getCurrentTask() ~= "Doctor")
				and (TaskMangerIn:getCurrentTask() ~= "Hold Still")
				and (isRAMBO < 2)
				and ((NPC:getSeenCount() >= 1) and (Distance_AnyEnemy <= 6)) -- This line doesn't make sense, what if the npc needs to heal outside of hostiles?
			then
				TaskMangerIn:AddToTop(FirstAideTask:new(ASuperSurvivor)) -- If general healing
				TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
				if (ZombRand(3) == 0) then
					NPC:NPC_ShouldRunOrWalk()
				end

				if ((NPC:getSeenCount() >= 3) and (Distance_AnyEnemy <= 3)) then -- If EMERGENCY run away and heal
					TaskMangerIn:AddToTop(FirstAideTask:new(ASuperSurvivor))
					TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
					TaskMangerIn:AddToTop(FleeFromHereTask:new(ASuperSurvivor, ASuperSurvivor:Get():getCurrentSquare()))
				end
			end
		end
	end

	-- ----------------------------- --
	-- flee from too many zombies
	-- ----------------------------- --
	if not (AiNPC_Job_Is(NPC, "Companion")) then -- To ABSOLUTELY prevent these two jobs from listening to this task.
		if (TaskMangerIn:getCurrentTask() ~= "Flee")
			and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
			and (TaskMangerIn:getCurrentTask() ~= "Surender")
			and ((TaskMangerIn:getCurrentTask() ~= "Surender") and not EnemyIsSurvivor)
			and (isRAMBO < 2)
			and
			(
				(((NPC:needToReload()) or (NPC:needToReadyGun(weapon))) and ((NPC:getDangerSeenCount() > 1 and (Distance_AnyEnemy < 3) and (EnemyIsZombie)) or ((NPC:getSeenCount() >= 2) and (Distance_AnyEnemy <= 2) and (EnemyIsZombie)))) -- AH HA, gun running away for non-companions when the npc is trying to reload or ready gun
				or (((NPC:needToReload()) or (NPC:needToReadyGun(weapon))) and ((NPC:getDangerSeenCount() > 1 and (Distance_AnyEnemy <= 2) and (EnemyIsSurvivor)) or ((Distance_AnyEnemy <= 2) and (EnemyIsSurvivor))))           -- AH HA, gun running away for non-companions when the npc is trying to reload or ready gun
				-- To check for EnemyIsZombie, which will look there and go 'OH GOD, I can't fight THIS many zombies'
				-- Update: I may of already fixed this issue on the lines above...
				-- now that I understand that getDangerSeenCount means if something is like SUPER close to the npc, you can simulate
				-- the idea of 'there's an enemy basically on me and I see more in the distance, I don't think this is worth fighting'
				or (
					(NPC.EnemiesOnMe > 3 and NPC:getDangerSeenCount() > 3 and NPC:getSeenCount() > 3)

					or (not ASuperSurvivor:hasWeapon() and (ASuperSurvivor:getDangerSeenCount() > 0))

					or (IHaveInjury and ASuperSurvivor:getDangerSeenCount() > 0)

					or (EnemyIsSurvivorHasGun and ASuperSurvivor:hasGun() == false)

					or (ASuperSurvivor:isTooScaredToFight())

				)
			)
		then
			--when piling corpses the survivor may not be holding weapon, this should not count as not having a weapon so in this case simply end the pile corpse task (which will cause re-equip weapon and trigger more reasonable reaction)
			if ((TaskMangerIn:getCurrentTask() == "LootCategoryTask") or (TaskMangerIn:getCurrentTask() == "Pile Corpses")) then -- currently to dangerous to loot said building. so give up it
				local task = TaskMangerIn:getTask();
				if (task ~= nil) then task:ForceFinish() end
			else
				ASuperSurvivor:getTaskManager():clear()
				TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))

				if not (AiNPC_Job_Is(NPC, "Guard")) and not (AiNPC_Job_Is(NPC, "Doctor")) then
					TaskMangerIn:AddToTop(FleeFromHereTask:new(ASuperSurvivor, ASuperSurvivor:Get():getCurrentSquare()))
				end
			end
		end
	end

	if ((TaskMangerIn:getCurrentTask() ~= "Flee")
			and (TaskMangerIn:getCurrentTask() ~= "Surender")
			and ((TaskMangerIn:getCurrentTask() ~= "Surender") and (not EnemyIsSurvivor)))
		and (isRAMBO < 2)
	then
		if ((NPC.EnemiesOnMe > CanTollerateEnemiesOnMe)) then
			TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
		end
		if ((NPC.EnemiesOnMe > 0) and (ASuperSurvivor:usingGun() and ((ASuperSurvivor:needToReload()) or (ASuperSurvivor:needToReadyGun(weapon))))) then
			TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
		end
		if (IHaveInjury and (NPC.dangerSeenCount > 0)) then
			TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
		end
		if (NPC.dangerSeenCount > Bravery) then
			TaskMangerIn:AddToTop(FleeTask:new(ASuperSurvivor))
		end
	end

	-- ----------------------------- --
	-- If NPC is Starving or drhydrating, force leave group
	-- To do - Give player option to let this task happen or not too
	-- ----------------------------- --
	if (false) and (ASuperSurvivor:getAIMode() ~= "Random Solo") and ((ASuperSurvivor:isStarving()) or (ASuperSurvivor:isDyingOfThirst())) then
		-- leave group and look for food if starving

		ASuperSurvivor:setAIMode("Random Solo")

		if (ASuperSurvivor:getGroupID() ~= nil) then
			local group = SSGM:Get(ASuperSurvivor:getGroupID())
			group:removeMember(ASuperSurvivor:getID())
		end
		ASuperSurvivor:getTaskManager():clear()
		if (ASuperSurvivor:Get():getStats():getHunger() > 0.40) then ASuperSurvivor:Get():getStats():setHunger(0.40) end
		if (ASuperSurvivor:Get():getStats():getThirst() > 0.40) then ASuperSurvivor:Get():getStats():setThirst(0.40) end
		ASuperSurvivor:Speak(GetDialogue("LeaveGroupHungry"))
	elseif (TaskMangerIn:getCurrentTask() ~= "Enter New Building") and (TaskMangerIn:getCurrentTask() ~= "Clean Inventory") and (IsInAction == false) and (TaskMangerIn:getCurrentTask() ~= "Eat Food") and (TaskMangerIn:getCurrentTask() ~= "Find This") and (TaskMangerIn:getCurrentTask() ~= "First Aide") and (TaskMangerIn:getCurrentTask() ~= "Listen") and (((ASuperSurvivor:isHungry()) and (IsInBase)) or ASuperSurvivor:isVHungry()) and (ASuperSurvivor:getDangerSeenCount() == 0) then
		if (not ASuperSurvivor:hasFood()) and (ASuperSurvivor:getNoFoodNearBy() == false) and ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep())) then
			if (HisGroup) then
				local area = HisGroup:getGroupAreaCenterSquare("FoodStorageArea")
				if (area) then
					ASuperSurvivor:walkTo(area)
				end
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Food", "Category", 1))
		elseif (ASuperSurvivor:hasFood()) then
			TaskMangerIn:AddToTop(EatFoodTask:new(ASuperSurvivor, ASuperSurvivor:getFood()))
		end
	end

	-- ----------------------------- --
	-- Find food / drink - like task --
	-- ----------------------------- --
	if (TaskMangerIn:getCurrentTask() ~= "Enter New Building") and (IsInAction == false) and (TaskMangerIn:getCurrentTask() ~= "Eat Food") and (TaskMangerIn:getCurrentTask() ~= "Find This") and (TaskMangerIn:getCurrentTask() ~= "First Aide") and (((ASuperSurvivor:isThirsty()) and (IsInBase)) or ASuperSurvivor:isVThirsty()) and (ASuperSurvivor:getDangerSeenCount() == 0) then
		if (ASuperSurvivor:getNoWaterNearBy() == false) and ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep())) then
			if (HisGroup) then
				local area = HisGroup:getGroupAreaCenterSquare("FoodStorageArea")
				if (area) then ASuperSurvivor:walkTo(area) end
				ASuperSurvivor:Speak("I'm going to get some food before I die of hunger.")
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Water", "Category", 1))
		end
	end


	-- ----------------------------- --
	-- 			Listen to Task
	-- ----------------------------- --
	if (
			(ASuperSurvivor:Get():getModData().InitGreeting ~= nil)
			or (ASuperSurvivor:getAIMode() == "Random Solo")
		)
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (TaskMangerIn:getCurrentTask() ~= "Surender")
		and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
		and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
		and (ASuperSurvivor.LastSurvivorSeen ~= nil)
		--and (ASuperSurvivor.LastSurvivorSeen:isGhostMode() == false)
		and (ASuperSurvivor:getSpokeTo(ASuperSurvivor.LastSurvivorSeen:getModData().ID) == false)
		and (getDistanceBetween(ASuperSurvivor.LastSurvivorSeen, ASuperSurvivor:Get()) < 8)
		and (ASuperSurvivor:getDangerSeenCount() == 0) and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (ASuperSurvivor:Get():CanSee(ASuperSurvivor.LastSurvivorSeen))
	then
		ASuperSurvivor:Speak(GetDialogue("HeyYou"))
		ASuperSurvivor:SpokeTo(ASuperSurvivor.LastSurvivorSeen:getModData().ID)
		TaskMangerIn:AddToTop(ListenTask:new(ASuperSurvivor, ASuperSurvivor.LastSurvivorSeen, true))
	end


	-- ----------------------------- --
	-- 	Gun Readying / Reloading     --
	-- ----------------------------- --
	if not (AiNPC_Job_Is(NPC, "Companion")) then
		if (ASuperSurvivor:getNeedAmmo())
			and (ASuperSurvivor:hasAmmoForPrevGun())
			and (IsInAction == false)
			and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
			and (TaskMangerIn:getCurrentTask() ~= "Flee")  -- New
			and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot") -- New
			and (ASuperSurvivor:getDangerSeenCount() == 0)
		then
			ASuperSurvivor:setNeedAmmo(false)
			-- Reminder: re-enable this
			ASuperSurvivor:reEquipGun()
		end
	end

	-- ----------------------------- --
	-- 	Equip Weapon Task            --
	-- ----------------------------- --
	if not (AiNPC_Job_Is(NPC, "Companion")) then
		if (ASuperSurvivor:hasWeapon()) and (ASuperSurvivor:Get():getPrimaryHandItem() == nil) and (TaskMangerIn:getCurrentTask() ~= "Equip Weapon") then
			TaskMangerIn:AddToTop(EquipWeaponTask:new(ASuperSurvivor))
		end
	end

	-- ----------------------------- --
	-- 	Equip Weapon Task            --
	-- ----------------------------- --
	if not (AiNPC_Job_Is(NPC, "Companion")) then -- removed and (ASuperSurvivor:getNeedAmmo() == false) condition as I dont remember what that is for
		if (IsInAction == false)
			and ASuperSurvivor:usingGun()
			and (ASuperSurvivor:getDangerSeenCount() == 0)
			and ((ASuperSurvivor:needToReload())
				or (ASuperSurvivor:needToReadyGun(weapon)))
			and (NPC:NPC_FleeWhileReadyingGun())
		then
			ASuperSurvivor:ReadyGun(weapon)
		end
	end

	-- ----------------------------- --
	-- 	Shift task quickly to attack --
	--  QuickFix for the stuck task  --
	-- ----------------------------- --
	--if not (AiNPC_Job_Is(NPC,"Companion"))  then
	--	if (NPC.LastEnemeySeen ~= nil) and ((NPC:isInSameRoom(NPC.LastEnemeySeen)) or (NPC:RealCanSee(NPC.LastEnemeySeen))) and (AiNPC_Task_Is(NPC,"Enter New Building")) then
	--		TaskMangerIn:AddToTop(AttackTask:new(ASuperSurvivor))
	--	end
	--end

	-- ---------------------------------------------------------- --
	-- ------ END -------- Shared AI ------ END ----------------- --
	-- ---------------------------------------------------------- --




	-- ---------------------------------------------------------- --
	-- ------------------- Base Tasks---------------------------- --
	-- ---------------------------------------------------------- --


	if ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep())) and (ASuperSurvivor:getAIMode() ~= "Stand Ground") then
		SafeToGoOutAndWork = true
		local AutoWorkTaskTimeLimit = 300

		-- -------
		-- Guard
		-- -------
		if (ASuperSurvivor:getGroupRole() == "Guard") then
			-- if getGroupArea 'getGroupArea = does this area exist'

			if (Task_Is_Not("Attack") and Task_Is_Not("Threaten") and Task_Is_Not("Pursue") and Task_Is_Not("Flee") and Task_Is_Not("First Aide") and Task_Is_Not("Find This") and Task_Is_Not("Eat Food") and Task_Is_Not("Follow") and (IsInAction == false)) then
				if (HisGroup:getGroupAreaCenterSquare("GuardArea") ~= nil) and (HisGroup:getGroupArea("GuardArea")) then
					if (getDistanceBetween(HisGroup:getGroupAreaCenterSquare("GuardArea"), NPC:Get():getCurrentSquare()) > 10) then
						TaskMangerIn:clear()
						TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor,
							GetRandomAreaSquare(HisGroup:getGroupArea("GuardArea"))))
					end
				end

				if (getDistanceBetween(HisGroup:getGroupAreaCenterSquare("GuardArea"), NPC:Get():getCurrentSquare()) <= 10) then
					if (HisGroup:getGroupAreaCenterSquare("GuardArea") ~= nil) and (HisGroup:getGroupArea("GuardArea")) then
						TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor,
							GetRandomAreaSquare(HisGroup:getGroupArea("GuardArea"))))
					end
				end

				if (HisGroup:getGroupAreaCenterSquare("GuardArea") == nil) and (CenterBaseSquare ~= nil) and not (IsInBase) then
					TaskMangerIn:AddToTop(WanderInBaseTask:new(ASuperSurvivor))
				elseif (HisGroup:getGroupAreaCenterSquare("GuardArea") == nil) and (CenterBaseSquare == nil) and not (IsInBase) then
					TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, HisGroup:getRandomBaseSquare()))
				end
			else
				if Task_Is("Flee") then NPC:NPC_ShouldRunOrWalk() end
			end
		end

		if (ASuperSurvivor:getCurrentTask() == "None") and (IsInBase) and (not IsInAction) and (ZombRand(4) == 0) then
			if (not SurvivorsFindWorkThemselves) and (ASuperSurvivor:getGroupRole() == "Doctor") then
				local randresult = ZombRand(10) + 1
				if (randresult == 1) then
					ASuperSurvivor:Speak(getActionText("IGoRelax"))
					TaskMangerIn:AddToTop(WanderInBaseTask:new(ASuperSurvivor))
				else
					local medicalarea = HisGroup:getGroupArea("MedicalStorageArea")

					local gotoSquare
					if (medicalarea) and (medicalarea[1] ~= 0) then
						gotoSquare = GetCenterSquareFromArea(medicalarea[1],
							medicalarea[2], medicalarea[3], medicalarea[4], medicalarea[5])
					end
					if (not gotoSquare) then gotoSquare = CenterBaseSquare end

					if (gotoSquare) then ASuperSurvivor:walkTo(gotoSquare) end
					TaskMangerIn:AddToTop(DoctorTask:new(ASuperSurvivor))
					return TaskMangerIn
				end
			elseif (not SurvivorsFindWorkThemselves) and (ASuperSurvivor:getGroupRole() == "Farmer") then
				if (SurvivorsFindWorkThemselves) and (RainManager.isRaining() == false) then
					local randresult = ZombRand(10) + 1

					if (randresult == 1) then
						ASuperSurvivor:Speak(getActionText("IGoRelax"))
						TaskMangerIn:AddToTop(WanderInBaseTask:new(ASuperSurvivor))
						TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
					else
						local area = HisGroup:getGroupArea("FarmingArea")
						if (area) then
							ASuperSurvivor:Speak(getActionText("IGoFarm"))
							TaskMangerIn:AddToTop(FarmingTask:new(ASuperSurvivor))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						else
							CreateLogLine("AI-Manager", isLocalLoggingEnabled, "farming area was nil");
						end
					end
				end

				-- ModderNote: From what I've observed, companion isn't used on anything else except to follow
				-- So exploiting that knowledge, I made the companion more of a 'class job priority' set of jobs at the top of the code.
				-- So if you are another modder that has the torch, that's looking to make Followers listen to you more, Follower = 'companion'
			elseif (ASuperSurvivor:getGroupRole() == "Companion") then -- Not new, this was here before
				TaskMangerIn:AddToTop(FollowTask:new(ASuperSurvivor, getSpecificPlayer(0)))
			elseif (SurvivorsFindWorkThemselves)
				and not (AiNPC_Job_Is(NPC, "Guard"))
				and not (AiNPC_Job_Is(NPC, "Leader"))
				and not (AiNPC_Job_Is(NPC, "Doctor"))
				and not (AiNPC_Job_Is(NPC, "Farming"))
			then
				if (ASuperSurvivor:Get():getBodyDamage():getWetness() < 0.2) then
					
					if (SafeToGoOutAndWork) then
						TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)

						local forageSquare = HisGroup:getGroupAreaCenterSquare("ForageArea")
						local chopWoodSquare = HisGroup:getGroupAreaCenterSquare("ChopTreeArea")
						local farmingArea = HisGroup:getGroupArea("FarmingArea")
						local guardArea = HisGroup:getGroupArea("GuardArea")

						local jobScores = {}
						local job = "Relax"
						-- idle tasks
						jobScores["Relax"] = 0 + math.floor(ASuperSurvivor:Get():getStats():getBoredom() * 20.0)
						jobScores["Wash Self"] = 1

						-- maintenance
						jobScores["Clean Inventory"] = 2
						jobScores["Gather Wood"] = 2
						jobScores["Pile Corpses"] = 2

						-- skilled work
						jobScores["Chop Wood"] = 2 +
							math.min(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Axe")), 3)
						jobScores["Forage"] = 2 +
							math.min(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Foraging")), 3)

						-- deprioritize assigned tasks
						jobScores["Farming"] = 0 +
							math.min(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Farming")), 3)
						jobScores["Doctor"] = -2 +
							math.min(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Doctor")), 3) +
							math.min(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("First Aid")), 3)
						jobScores["Guard"] = 2 +
							math.min(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Aiming")), 3)

						-- jobs requiring zoned areas
						if (forageSquare == nil) then jobScores["Forage"] = -10 end
						if (chopWoodSquare == nil) then jobScores["Chop Wood"] = -10 end
						if (farmingArea[1] == 0) then jobScores["Farming"] = -10 end
						if (guardArea[1] == 0) then jobScores["Guard"] = -10 end

						-- reduce scores for jobs already being worked on
						for key, value in pairs(jobScores) do
							if key == "Guard" then
								jobScores[key] = value - HisGroup:getTaskCount("Wander In Area")
							elseif key == "Doctor" then
								-- no point in more than one doctor at a time
								jobScores[key] = value - (HisGroup:getTaskCount(key) * 10)
							elseif key == "Farming" then
								-- no point in more than one farmer at a time
								jobScores[key] = value - (HisGroup:getTaskCount(key) * 10)
							elseif key == "Forage" then
								-- little point in more than one forager at a time
								jobScores[key] = value - (HisGroup:getTaskCount(key) * 2)
							else
								jobScores[key] = value - HisGroup:getTaskCount(key)
							end
						end

						-- rainy days
						if RainManager.isRaining() then
							jobScores["Wash Self"] = jobScores["Wash Self"] + 2 -- can wash in puddles
							jobScores["Farming"] = jobScores["Farming"] - 10 -- really no reason to do this
							jobScores["Gather Wood"] = jobScores["Gather Wood"] - 1
							jobScores["Pile Corpses"] = jobScores["Pile Corpses"] - 2
							jobScores["Chop Wood"] = jobScores["Chop Wood"] - 3
							jobScores["Forage"] = jobScores["Forage"] - 3
						end
						if ASuperSurvivor:Get():getBodyDamage():getWetness() > 0.5 then
							-- do indoor stuff to dry off
							jobScores["Relax"] = jobScores["Relax"] + 3
							jobScores["Clean Inventory"] = jobScores["Clean Inventory"] + 3
							jobScores["Wash Self"] = jobScores["Wash Self"] + 2
						end

						-- personal needs
						local filth = ASuperSurvivor:getFilth()
						if filth < 1 then
							jobScores["Wash Self"] = jobScores["Wash Self"] - 2
						elseif filth < 5 then
							jobScores["Wash Self"] = jobScores["Wash Self"] - 1
						elseif filth < 10 then
							jobScores["Wash Self"] = jobScores["Wash Self"] + 1
						elseif filth < 15 then
							jobScores["Wash Self"] = jobScores["Wash Self"] + 2
						else
							jobScores["Wash Self"] = jobScores["Wash Self"] + 3
						end

						-- randomize
						for key, value in pairs(jobScores) do
							jobScores[key] = ZombRand(0, value)
						end

						-- find the best task
						for key, value in pairs(jobScores) do
							if value >= jobScores[job] then job = key end
						end

						ASuperSurvivor:Get():getStats():setBoredom(ASuperSurvivor:Get():getStats():getBoredom() +
							(ZombRand(5) / 100.0))
						if (job == "Relax") then
							ASuperSurvivor:Speak(getActionText("IGoRelax"))
							ASuperSurvivor:Get():getStats():setBoredom(0.0)
							TaskMangerIn:AddToTop(WanderInBaseTask:new(ASuperSurvivor))
						elseif (job == "Gather Wood") then
							ASuperSurvivor:Speak(getActionText("IGoGetWood"))
							local dropSquare = CenterBaseSquare
							local woodstoragearea = HisGroup:getGroupArea("WoodStorageArea")
							if (woodstoragearea[1] ~= 0) then
								dropSquare = GetCenterSquareFromArea(woodstoragearea[1],
									woodstoragearea[2], woodstoragearea[3], woodstoragearea[4], woodstoragearea[5])
							end
							TaskMangerIn:AddToTop(GatherWoodTask:new(ASuperSurvivor, dropSquare))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						elseif (job == "Pile Corpses") then
							ASuperSurvivor:Speak(getActionText("IGoPileCorpse"))
							local baseBounds = HisGroup:getBounds()
							local dropSquare = getCell():getGridSquare(baseBounds[1] - 5, baseBounds[3] - 5, 0)
							local storagearea = HisGroup:getGroupArea("CorpseStorageArea")
							if (storagearea[1] ~= 0) then
								dropSquare = GetCenterSquareFromArea(storagearea[1],
									storagearea[2], storagearea[3], storagearea[4], storagearea[5])
							end
							if (dropSquare) then
								TaskMangerIn:AddToTop(PileCorpsesTask:new(ASuperSurvivor, dropSquare))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							end
						elseif (job == "Forage") then
							local dropSquare = CenterBaseSquare
							local FoodStorageCenter = HisGroup:getGroupAreaCenterSquare("FoodStorageArea")
							if (FoodStorageCenter) then dropSquare = FoodStorageCenter end

							if (forageSquare ~= nil) then
								ASuperSurvivor:Speak(getActionText("IGoForage"))
								ASuperSurvivor:walkTo(forageSquare)
								TaskMangerIn:AddToTop(SortLootTask:new(ASuperSurvivor, false))
								TaskMangerIn:AddToTop(ForageTask:new(ASuperSurvivor))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "forage area was nil");
							end
						elseif (job == "Chop Wood") then
							if (chopWoodSquare) then
								ASuperSurvivor:Speak(getActionText("IGoChopWood"))
								TaskMangerIn:AddToTop(ChopWoodTask:new(ASuperSurvivor))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "chopWoodArea area was nil");
							end
						elseif (job == "Farming") then
							if (farmingArea) then
								ASuperSurvivor:Speak(getActionText("IGoFarm"))
								TaskMangerIn:AddToTop(FarmingTask:new(ASuperSurvivor))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "farmingArea area was nil");
							end
						elseif (job == "Guard") then
							if (guardArea) then
								ASuperSurvivor:Speak(getActionText("IGoGuard"))
								TaskMangerIn:AddToTop(WanderInAreaTask:new(ASuperSurvivor, guardArea))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "guardArea area was nil");
							end
						elseif (job == "Doctor") then
							local medicalarea = HisGroup:getGroupArea("MedicalStorageArea")

							local gotoSquare
							if (medicalarea) and (medicalarea[1] ~= 0) then
								gotoSquare = GetCenterSquareFromArea(
									medicalarea[1], medicalarea[2], medicalarea[3], medicalarea[4], medicalarea[5])
							end
							if (not gotoSquare) then gotoSquare = CenterBaseSquare end

							if (gotoSquare) then ASuperSurvivor:walkTo(gotoSquare) end
							TaskMangerIn:AddToTop(DoctorTask:new(ASuperSurvivor))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						elseif (job == "Clean Inventory") then
							ASuperSurvivor:Speak("Cleaning Inventory")
							local dropSquare = CenterBaseSquare
							local ToolStorageCenter = HisGroup:getGroupAreaCenterSquare("ToolStorageArea")
							if (ToolStorageCenter) then dropSquare = ToolStorageCenter end
							TaskMangerIn:AddToTop(SortLootTask:new(ASuperSurvivor, false))
						elseif (job == "Wash Self") then
							ASuperSurvivor:Speak("Washing Self")
							TaskMangerIn:AddToTop(WashSelfTask:new(ASuperSurvivor))
						end
					else
						TaskMangerIn:AddToTop(WanderInBaseTask:new(ASuperSurvivor))
					end -- safeto go out end
				end -- allowed to go out work end
			end
		end

		-- Oop, found this. I could use this for followers to get back to main player
		if (ASuperSurvivor:getCurrentTask() == "None") and (IsInBase == false) and (not IsInAction) and (HisGroup ~= nil) then
			local baseSq = CenterBaseSquare
			if (baseSq ~= nil) then
				ASuperSurvivor:Speak(getActionText("IGoBackBase"))
				TaskMangerIn:AddToTop(ReturnToBaseTask:new(ASuperSurvivor))
			end
		end
	end

	-- ----------------------------------------------------------- --
	-- ------ END -------- Base Tasks ------- END ---------------- --
	-- ----------------------------------------------------------- --

	-- TODO test: maybe add 'if not in attack / pursue / threaten , then do ' along with the 'none tasks'

	if (ASuperSurvivor:getAIMode() == "Random Solo")
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
	then -- solo random survivor AI flow	
		if (TaskMangerIn:getCurrentTask() == "None")
			and (ASuperSurvivor.TargetBuilding ~= nil)
			and (not ASuperSurvivor:getBuildingExplored(ASuperSurvivor.TargetBuilding))
			and (not ASuperSurvivor:isEnemyInRange(ASuperSurvivor.LastEnemeySeen))
		then
			TaskMangerIn:AddToTop(AttemptEntryIntoBuildingTask:new(ASuperSurvivor, ASuperSurvivor.TargetBuilding))
		elseif (TaskMangerIn:getCurrentTask() == "None") and ((not EnemyIsSurvivor) or (not ASuperSurvivor:isEnemyInRange(ASuperSurvivor.LastEnemeySeen))) then
			TaskMangerIn:AddToTop(FindUnlootedBuildingTask:new(ASuperSurvivor))
		end

		if (ASuperSurvivor.TargetBuilding ~= nil) or (ASuperSurvivor:inUnLootedBuilding()) then
			if ASuperSurvivor.TargetBuilding == nil then ASuperSurvivor.TargetBuilding = ASuperSurvivor:getBuilding() end
			if (not ASuperSurvivor:hasWeapon()) and (TaskMangerIn:getCurrentTask() ~= "Loot Category")
				and (ASuperSurvivor:getDangerSeenCount() <= 0)
				and (ASuperSurvivor:inUnLootedBuilding())
				and (NPC:isTargetBuildingClaimed(ASuperSurvivor.TargetBuilding) == false)
			then
				TaskMangerIn:AddToTop(LootCategoryTask:new(ASuperSurvivor, ASuperSurvivor.TargetBuilding, "Food", 2))
				TaskMangerIn:AddToTop(EquipWeaponTask:new(ASuperSurvivor))
				TaskMangerIn:AddToTop(LootCategoryTask:new(ASuperSurvivor, ASuperSurvivor.TargetBuilding, "Weapon", 2))
			elseif (ASuperSurvivor:hasRoomInBag())
				and (TaskMangerIn:getCurrentTask() ~= "Loot Category")
				and (ASuperSurvivor:getDangerSeenCount() <= 0) and (ASuperSurvivor:inUnLootedBuilding())
				and (NPC:isTargetBuildingClaimed(ASuperSurvivor.TargetBuilding) == false)
			then
				TaskMangerIn:AddToTop(LootCategoryTask:new(ASuperSurvivor, ASuperSurvivor.TargetBuilding, "Food", 1))
			end
		end
		if (SurvivorBases) and
			(IsInAction == false) and -- New. Hopefully to stop spam
			(ASuperSurvivor:getBaseBuilding() == nil) and
			(ASuperSurvivor:getBuilding()) and
			(TaskMangerIn:getCurrentTask() ~= "First Aide") and
			(TaskMangerIn:getCurrentTask() ~= "Attack") and
			(TaskMangerIn:getCurrentTask() ~= "Threaten") and  -- new
			(TaskMangerIn:getCurrentTask() ~= "Pursue") and    -- new
			(TaskMangerIn:getCurrentTask() ~= "Enter New Building") and -- new
			(TaskMangerIn:getCurrentTask() ~= "Barricade Building") and
			(ASuperSurvivor:hasWeapon()) and
			(ASuperSurvivor:getGroupRole() ~= "Companion") and  -- New
			(ASuperSurvivor:isInSameBuildingWithEnemyAlt() == false) and -- That way npc doesn't stop what they're doing moment they look away from a hostile
			(ASuperSurvivor:hasFood())
		then
			TaskMangerIn:clear()
			ASuperSurvivor:setBaseBuilding(ASuperSurvivor:getBuilding())
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(ASuperSurvivor, ASuperSurvivor:getBuilding()))
			TaskMangerIn:AddToTop(LockDoorsTask:new(ASuperSurvivor, true))
			TaskMangerIn:AddToTop(BarricadeBuildingTask:new(ASuperSurvivor))
			ASuperSurvivor:Speak("This will be my base.")
			local GroupId = SSGM:GetGroupIdFromSquare(ASuperSurvivor:Get():getCurrentSquare())

			CreateLogLine("AI-Manager", isLocalLoggingEnabled, tostring(ASuperSurvivor:getName()) .. " is making a base");
			CreateLogLine("AI-Manager", isLocalLoggingEnabled, tostring(GroupId) .. " is the base id");

			if (GroupId == -1) then -- if the base this npc is gonna stay in is not declared as another base then they set it as thier base.
				local nGroup = SSGM:newGroup()
				nGroup:addMember(ASuperSurvivor, "Leader")
				local def = ASuperSurvivor:getBuilding():getDef()
				local bounds = { def:getX() - 1, (def:getX() + def:getW() + 1), def:getY() - 1,
					(def:getY() + def:getH() + 1), 0 }
				nGroup:setBounds(bounds)
			elseif ((SSM:Get(0) == nil) or (GroupId ~= SSM:Get(0):getGroupID())) then
				local OwnerGroup = SSGM:Get(GroupId)
				local LeaderID = OwnerGroup:getLeader()
				if (LeaderID ~= 0) then
					OwnerGroup:addMember(ASuperSurvivor, "Worker")
					ASuperSurvivor:Speak("Please let me stay here")
					local LeaderObj = SSM:Get(LeaderID)
					if (LeaderObj) then
						LeaderObj:Speak("Welcome to our Group")
					end
				end
			end
		end


		if ((SurvivorBases) and (ASuperSurvivor:isStarving()) or (ASuperSurvivor:isDyingOfThirst())) and (ASuperSurvivor:getBaseBuilding() ~= nil) then -- leave group and look for food if starving
			-- random survivor in base is starving - reset so he goes back out looking for food and re base there
			ASuperSurvivor:setAIMode("Random Solo")
			if (ASuperSurvivor:getGroupID() ~= nil) then
				local group = SSGM:Get(ASuperSurvivor:getGroupID())
				group:removeMember(ASuperSurvivor:getID())
			end
			ASuperSurvivor:getTaskManager():clear()
			ASuperSurvivor:Speak(getActionText("LeaveBCHungry"))
			CreateLogLine("AI-Manager", isLocalLoggingEnabled, tostring(ASuperSurvivor:getName()) .. ": clearing task manager because too hungry");
			ASuperSurvivor:resetAllTables()
			ASuperSurvivor:setBaseBuilding(nil)
			if (ASuperSurvivor:Get():getStats():getHunger() > 0.30) then ASuperSurvivor:Get():getStats():setHunger(0.30) end
			if (ASuperSurvivor:Get():getStats():getThirst() > 0.30) then ASuperSurvivor:Get():getStats():setThirst(0.30) end
		end
	end

	return TaskMangerIn
end
