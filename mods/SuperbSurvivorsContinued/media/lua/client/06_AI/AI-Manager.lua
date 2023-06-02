require "04_Group.SuperSurvivorManager";

--- Cows: I'll regret working on this but I need the NPCs to stop shitting themselves when enemies are only at the edge of their attack range.
--- Cows: Also need Companion NPCs to actually FOLLOW over any other tasks at hand.

-- Bug: companions are pursing a target without they returning to the player when out of range
local isLocalLoggingEnabled = false;

function AiNPC_TaskIsNot(AiTmi, TaskName)
	return (AiTmi:getCurrentTask() ~= TaskName)
end

function AiNPC_Job_Is(currentNPC, JobName)
	return (currentNPC:getGroupRole() == JobName)
end

---@param TaskMangerIn any
---@return any
function AIManager(TaskMangerIn)
	local isFleeCallLogged = false;
	local currentNPC = TaskMangerIn.parent; -- replaces both "ASuperbSurvivor" and "NPC".

	if (TaskMangerIn == nil) or (currentNPC == nil) then
		return false;
	end

	if (currentNPC:needToFollow())
		or (currentNPC:Get():getVehicle() ~= nil)
	then
		return TaskMangerIn
	end -- if in vehicle skip AI -- or high priority follow


	local EnemyIsSurvivor = (instanceof(currentNPC.LastEnemeySeen, "IsoPlayer"))
	local EnemyIsZombie = (instanceof(currentNPC.LastEnemeySeen, "IsoZombie"))
	local EnemySuperSurvivor = nil
	local EnemyIsSurvivorHasGun = false

	if (EnemyIsSurvivor) then
		local id = currentNPC.LastEnemeySeen:getModData().ID;

		EnemySuperSurvivor = SSM:Get(id);
		--
		if (EnemySuperSurvivor) then
			EnemyIsSurvivorHasGun = EnemySuperSurvivor:hasGun()
		end
	end

	local npcBravery = currentNPC:getBravePoints();
	local npcIsInjured = currentNPC:HasInjury();
	local npcWeapon = currentNPC.player:getPrimaryHandItem();
	local AttackRange = currentNPC:getAttackRange();
	local IsInAction = currentNPC:isInAction();
	local HisGroup = currentNPC:getGroup();
	local IsInBase = currentNPC:isInBase();
	local CenterBaseSquare = nil
	local DistanceBetweenMainPlayer = GetDistanceBetween(getSpecificPlayer(0), currentNPC:Get());
	local ImFollowingThisChar = currentNPC:getFollowChar();
	local distanceBetweenEnemyAndFollowTarget = GetDistanceBetween(currentNPC.LastEnemeySeen, ImFollowingThisChar);
	local followAttackRange = GFollowDistance + AttackRange;
	-- Cows: Why was this even used if it is not even known to work or not work?...
	local Distance_AnyEnemy = GetDistanceBetween(currentNPC.LastEnemeySeen, currentNPC:Get()); -- idk if this works
	--
	if (HisGroup) then
		CenterBaseSquare = HisGroup:getBaseCenter();
	end

	-- Simplified Local functions
	local function Task_Is_Not(TaskName)
		return (TaskMangerIn:getCurrentTask() ~= TaskName)
	end
	local function Task_Is(TaskName)
		return (TaskMangerIn:getCurrentTask() == TaskName)
	end

	-- --------------------------------------- --
	-- Companion follower related code         --
	-- --------------------------------------- --
	if (currentNPC:getGroupRole() == "Companion") then
		--
		if (currentNPC:needToFollow()) then
			currentNPC.LastEnemeySeen = nil;
			TaskMangerIn:clear();
			TaskMangerIn:AddToTop(FollowTask:new(currentNPC, getSpecificPlayer(0)));
		end
	end

	if (AiNPC_Job_Is(currentNPC, "Companion")) then
		-- ------------------------- --
		-- Edit: I have trid so many other ways to do this. Any other way the companion just doesn't do anything.
		-- So it's staying like this for now
		-- Don't add 'and AiNPC_TaskIsNot(AiTmi,"First Aide")' because you want companions to still attack enemies while hurt
		-- ------------------------- --

		-- ------------ --
		-- Pursue
		-- ------------ --
		if AiNPC_TaskIsNot(TaskMangerIn, "First Aide")
			and AiNPC_TaskIsNot(TaskMangerIn, "Pursue")
			and AiNPC_TaskIsNot(TaskMangerIn, "Attack")
			and AiNPC_TaskIsNot(TaskMangerIn, "Flee")
			and (currentNPC.LastEnemeySeen ~= nil
				and Distance_AnyEnemy < currentNPC:NPC_CheckPursueScore()
			)
		then
			if (EnemyIsSurvivor or EnemyIsZombie) then
				TaskMangerIn:AddToTop(PursueTask:new(currentNPC, currentNPC.LastEnemeySeen));
			end
		end
		-- ----------- --
		-- Attack
		-- ----------- --
		-- ------------------------- --
		--Nolan:removed a lot of conditions here so that we can just focus on adjusting conditions inside isTooScaredToFight() function
		if (
				(TaskMangerIn:getCurrentTask() ~= "Attack")
				and (TaskMangerIn:getCurrentTask() ~= "Threaten")
				and (TaskMangerIn:getCurrentTask() ~= "First Aide")
				and (Task_Is_Not("Flee"))
				and (currentNPC:isInSameRoom(currentNPC.LastEnemeySeen))
			)
			and (currentNPC:getDangerSeenCount() > 0)                -- cant attack what you don't see. must have seen an enemy in danger range to attack
			and ((distanceBetweenEnemyAndFollowTarget < (followAttackRange))) -- move to engage an enemie only if they within follow range (when following)
		then
			if (currentNPC.player ~= nil)
				and (currentNPC.player:getModData().isRobber)
				and (not currentNPC.player:getModData().hitByCharacter)
				and EnemyIsSurvivor
				and (not EnemySuperSurvivor.player:getModData().dealBreaker)
			then
				TaskMangerIn:AddToTop(ThreatenTask:new(currentNPC, EnemySuperSurvivor, "Scram"));
			else
				TaskMangerIn:AddToTop(AttackTask:new(currentNPC));
			end
		end

		-- --------------------------------- --
		-- 	Reload Gun
		-- --------------------------------- --
		if (currentNPC:getNeedAmmo()) and (currentNPC:hasAmmoForPrevGun()) then
			currentNPC:setNeedAmmo(false);
			currentNPC:reEquipGun();
		end

		-- --------------------------------- --
		-- 	Ready Weapon
		-- --------------------------------- --
		if ((currentNPC:needToReload())
				or (currentNPC:needToReadyGun(npcWeapon)))
			and ((currentNPC:hasAmmoForPrevGun())
				or IsInfiniteAmmoEnabled)
			and currentNPC:usingGun() -- removed and (currentNPC:getNeedAmmo() condition -
		then
			currentNPC:ReadyGun(npcWeapon)
		end

		-- ----------------------------- --
		-- 	Equip Weapon                 --
		-- ----------------------------- --
		if (currentNPC:hasWeapon()) and (currentNPC:Get():getPrimaryHandItem() == nil) and (TaskMangerIn:getCurrentTask() ~= "Equip Weapon") then
			TaskMangerIn:AddToTop(EquipWeaponTask:new(currentNPC))
		end

		-- Careful setting up Flee to heal and 'healing', they will conflict very easily.
		-- -----------   --
		-- Flee to heal  --
		-- -----------   --
		if (TaskMangerIn:getCurrentTask() ~= "Flee")
			and ((currentNPC:getDangerSeenCount() > npcBravery) and (currentNPC:hasWeapon()) and (not currentNPC:usingGun())) -- Melee
			or (((currentNPC:getDangerSeenCount() > npcBravery) and (currentNPC:hasWeapon()) and (currentNPC:usingGun())) -- Gun general
				or ((currentNPC.EnemiesOnMe > 0) and ((currentNPC:needToReload()) or (currentNPC:needToReadyGun(npcWeapon))))
				or (npcIsInjured and currentNPC:getDangerSeenCount() > 0)
			)
		then
			CreateLogLine("AI-Manager", isFleeCallLogged, "Survivor is fleeing...");
			CreateLogLine("AI-Manager", isFleeCallLogged, "Dangers Seen: " .. tostring(currentNPC:getDangerSeenCount()));
			CreateLogLine("AI-Manager", isFleeCallLogged, "Enemies Attacking: " .. tostring(currentNPC.EnemiesOnMe));
			CreateLogLine("AI-Manager", isFleeCallLogged,
				"Survivor is reloading: " .. tostring(currentNPC:needToReload()));
			TaskMangerIn:AddToTop(FleeTask:new(currentNPC))
		end

		-- ----------- --
		-- Healing	   --
		-- ----------- --
		if (npcIsInjured and currentNPC:getDangerSeenCount() <= 0) then
			if (TaskMangerIn:getCurrentTask() ~= "First Aide")
			then
				TaskMangerIn:AddToTop(FirstAideTask:new(currentNPC)) -- If general healing
			end
		end
	end

	-- --------------------------------------- --
	-- Companion follower related code | END   --
	-- --------------------------------------- --

	-- --------------------------------------- --
	-- Pursue Task 							   --
	-- --------------------------------------- --
	-- To make NPCs find their target that's very close by
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		if (currentNPC:Task_IsPursue_SC() == true) and (Distance_AnyEnemy <= 9) and (Distance_AnyEnemy < currentNPC:NPC_CheckPursueScore()) then
			if (currentNPC:NPC_FleeWhileReadyingGun()) then
				TaskMangerIn:AddToTop(PursueTask:new(currentNPC, currentNPC.LastEnemeySeen)) -- If all checks out, pursue target
			end
		end
	end

	-- I haven't tampered with this one, it does OK for the most part.
	-- Bug: If you shoot the gun and it has nothing in it, the NPC will still keep their hands up
	-- ----------------------------- --
	-- 		Surrender Task	
	-- ----------------------------- --
	if (getSpecificPlayer(0) ~= nil) then
		local facingResult = getSpecificPlayer(0):getDotWithForwardDirection(
			currentNPC.player:getX(),
			currentNPC.player:getY()
		);
		if ((TaskMangerIn:getCurrentTask() ~= "Surender")
				and (TaskMangerIn:getCurrentTask() ~= "Flee")
				and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
				and (TaskMangerIn:getCurrentTask() ~= "Clean Inventory")
				and (SSM:Get(0) ~= nil and SSM:Get(0):usingGun())
				and getSpecificPlayer(0)
				and getSpecificPlayer(0):CanSee(currentNPC.player)
				and (not currentNPC:usingGun() or (not currentNPC:RealCanSee(getSpecificPlayer(0)) and DistanceBetweenMainPlayer <= 3))
				and getSpecificPlayer(0):isAiming()
				and IsoPlayer.getCoopPVP()
				and not currentNPC:isInGroup(getSpecificPlayer(0))
				and (facingResult > 0.95)
				and (DistanceBetweenMainPlayer < 6))
		then
			TaskMangerIn:clear()
			TaskMangerIn:AddToTop(SurenderTask:new(currentNPC, SSM:Get(0)))
			return TaskMangerIn
		end
	end

	-- ----------------------------- --
	-- Attack / Threaten Target Task --
	-- ----------------------------- --

	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		--Nolan:removed a lot of conditions here so that we can just focus on adjusting conditions inside isTooScaredToFight() function
		if ((TaskMangerIn:getCurrentTask() ~= "Attack")
				and (TaskMangerIn:getCurrentTask() ~= "Threaten")
				and (TaskMangerIn:getCurrentTask() ~= "First Aide")
				and (Task_Is_Not("Flee"))
				and (currentNPC:isInSameRoom(currentNPC.LastEnemeySeen))
			)
			and (currentNPC:getDangerSeenCount() > 0)            -- cant attack what you don't see. must have seen an enemy in danger range to attack
			and (currentNPC:getCurrentTask() ~= "Follow"
				or (distanceBetweenEnemyAndFollowTarget < followAttackRange) -- move to engage an enemie only if they within follow range (when following)
			)

		then
			if (currentNPC.player ~= nil)
				and (currentNPC.player:getModData().isRobber)
				and (not currentNPC.player:getModData().hitByCharacter)
				and EnemyIsSurvivor
				and (not EnemySuperSurvivor.player:getModData().dealBreaker)
			then
				TaskMangerIn:AddToTop(ThreatenTask:new(currentNPC, EnemySuperSurvivor, "Scram"))
			else
				TaskMangerIn:AddToTop(AttackTask:new(currentNPC))
			end
		end
	end

	-- ----------------------------- --
	-- New: To attempt players that are NOT trying to encounter a fight,
	-- should be able to run away. maybe a dice roll for the future?
	-- ----------------------------- --
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		if (EnemyIsSurvivor) and ((Task_Is("Threaten")) and (Distance_AnyEnemy > 10)) and (Task_Is_Not("Flee")) then
			TaskMangerIn:AddToTop(WanderTask:new(currentNPC))
			TaskMangerIn:AddToTop(AttemptEntryIntoBuildingTask:new(currentNPC, nil))
			TaskMangerIn:AddToTop(WanderTask:new(currentNPC))
			TaskMangerIn:AddToTop(FindBuildingTask:new(currentNPC))
		end
	end

	-- ----------------------------- --
	-- find safe place if injured and enemies near		this needs updating
	-- ----------------------------- --
	--	if (TaskMangerIn:getCurrentTask() ~= "Find Building") and (TaskMangerIn:getCurrentTask() ~= "Flee") and (npcIsInjured) and (currentNPC:getDangerSeenCount() > 0) then
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		if (TaskMangerIn:getCurrentTask() ~= "Find Building")
			and (TaskMangerIn:getCurrentTask() ~= "First Aide")
			and (TaskMangerIn:getCurrentTask() ~= "Flee")
			and (currentNPC:getDangerSeenCount() > 0)
		then
			TaskMangerIn:AddToTop(FindBuildingTask:new(currentNPC))
		end
	end
	-- ----------------------------- --
	-- bandage injuries if no threat near by
	-- Companions have their own healing rule
	-- ----------------------------- --
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		if (npcIsInjured) then
			if (TaskMangerIn:getCurrentTask() ~= "First Aide")
				and (TaskMangerIn:getCurrentTask() ~= "Flee")
				and (TaskMangerIn:getCurrentTask() ~= "Doctor")
				and ((currentNPC:getSeenCount() >= 1) and (Distance_AnyEnemy <= 6)) -- This line doesn't make sense, what if the npc needs to heal outside of hostiles?
			then
				TaskMangerIn:AddToTop(FirstAideTask:new(currentNPC))         -- If general healing
				CreateLogLine("AI-Manager", isFleeCallLogged, "Survivor is injured... Survivor is fleeing");
				TaskMangerIn:AddToTop(FleeTask:new(currentNPC));

				if (ZombRand(3) == 0) then
					currentNPC:NPC_ShouldRunOrWalk()
				end

				if ((currentNPC:getSeenCount() >= 3) and (Distance_AnyEnemy <= 3)) then -- If EMERGENCY run away and heal
					TaskMangerIn:AddToTop(FirstAideTask:new(currentNPC))
				end
			end
		end
	end

	-- ----------------------------- --
	-- flee from too many zombies
	-- ----------------------------- --
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then -- To ABSOLUTELY prevent these two jobs from listening to this task.
		if (TaskMangerIn:getCurrentTask() ~= "Flee")
			and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
			and (TaskMangerIn:getCurrentTask() ~= "Surender")
			and ((TaskMangerIn:getCurrentTask() ~= "Surender") and not EnemyIsSurvivor)
			and
			(
				(((currentNPC:needToReload()) or (currentNPC:needToReadyGun(npcWeapon)))
					and ((currentNPC:getDangerSeenCount() > 1
						and (Distance_AnyEnemy < 3)
						and (EnemyIsZombie)) or ((currentNPC:getSeenCount() >= 2) and (Distance_AnyEnemy <= 2)
						and (EnemyIsZombie)))
				) -- AH HA, gun running away for non-companions when the npc is trying to reload or ready gun
				or (((currentNPC:needToReload()) or (currentNPC:needToReadyGun(npcWeapon)))
					and ((currentNPC:getDangerSeenCount() > 1
							and (Distance_AnyEnemy <= 2)
							and (EnemyIsSurvivor))
						or ((Distance_AnyEnemy <= 2) and (EnemyIsSurvivor))
					)
				) -- AH HA, gun running away for non-companions when the npc is trying to reload or ready gun
				-- To check for EnemyIsZombie, which will look there and go 'OH GOD, I can't fight THIS many zombies'
				-- Update: I may of already fixed this issue on the lines above...
				-- now that I understand that getDangerSeenCount means if something is like SUPER close to the npc, you can simulate
				-- the idea of 'there's an enemy basically on me and I see more in the distance, I don't think this is worth fighting'
				or (
					(currentNPC.EnemiesOnMe > 3 and currentNPC:getDangerSeenCount() > 3 and currentNPC:getSeenCount() > 3)
					or (not currentNPC:hasWeapon() and (currentNPC:getDangerSeenCount() > 0))
					or (npcIsInjured and currentNPC:getDangerSeenCount() > 0)
					or (EnemyIsSurvivorHasGun and currentNPC:hasGun() == false)
				)
			)
		then
			--when piling corpses the survivor may not be holding weapon, this should not count as not having a weapon
			-- so in this case simply end the pile corpse task (which will cause re-equip weapon and trigger more reasonable reaction)
			if ((TaskMangerIn:getCurrentTask() == "LootCategoryTask")
					or (TaskMangerIn:getCurrentTask() == "Pile Corpses"))
			then
				local task = TaskMangerIn:getTask();
				if (task ~= nil) then task:ForceFinish() end
			else
				currentNPC:getTaskManager():clear();
				CreateLogLine("AI-Manager", isFleeCallLogged, "Survivor is fleeing...");
				TaskMangerIn:AddToTop(FleeTask:new(currentNPC))

				if not (AiNPC_Job_Is(currentNPC, "Guard"))
					and not (AiNPC_Job_Is(currentNPC, "Doctor"))
				then
					CreateLogLine("AI-Manager", isFleeCallLogged, "Survivor is not a guard");
					CreateLogLine("AI-Manager", isFleeCallLogged, "Survivor is fleeing...");
					TaskMangerIn:AddToTop(FleeFromHereTask:new(currentNPC, currentNPC:Get():getCurrentSquare()))
				end
			end
		end
	end

	if ((TaskMangerIn:getCurrentTask() ~= "Flee")
			and (TaskMangerIn:getCurrentTask() ~= "Surender")
			and ((TaskMangerIn:getCurrentTask() ~= "Surender") and (not EnemyIsSurvivor)))
	then
		if ((currentNPC.EnemiesOnMe > 0) and (currentNPC:usingGun() and ((currentNPC:needToReload()) or (currentNPC:needToReadyGun(npcWeapon))))) then
			CreateLogLine("AI-Manager", isFleeCallLogged, "Enemies Attacking, but need to reload, Survivor is fleeing");
			TaskMangerIn:AddToTop(FleeTask:new(currentNPC));
			--
		elseif (npcIsInjured and (currentNPC:getDangerSeenCount() > 0)) then
			CreateLogLine("AI-Manager", isFleeCallLogged,
				"Dangers seen: " ..
				tostring(currentNPC:getDangerSeenCount()) .. " | isInjured? " .. tostring(npcIsInjured)
			);
			CreateLogLine("AI-Manager", isFleeCallLogged,
				"Survivor is injured and enemy is attacking, Survivor is fleeing..."
			);
			TaskMangerIn:AddToTop(FleeTask:new(currentNPC))
			-- Cows: Really shouldn't start fleeing unless the threat is actually within a set range... let's try "Distance_AnyEnemy" compared against 3
		elseif (currentNPC:getDangerSeenCount() > npcBravery and Distance_AnyEnemy < 3) then
			CreateLogLine("AI-Manager", isFleeCallLogged,
				"Dangers seen: " .. tostring(currentNPC:getDangerSeenCount()) .. " | npcBravery: " .. tostring(npcBravery)
			);
			CreateLogLine("AI-Manager", isFleeCallLogged, "npcBravery checked failed, Survivor is fleeing...");
			TaskMangerIn:AddToTop(FleeTask:new(currentNPC))
		end
	end

	-- ----------------------------- --
	-- If NPC is Starving or drhydrating, force leave group
	-- To do - Give player option to let this task happen or not too
	-- ----------------------------- --
	if (false) and (currentNPC:getAIMode() ~= "Random Solo") and ((currentNPC:isStarving()) or (currentNPC:isDyingOfThirst())) then
		-- leave group and look for food if starving

		currentNPC:setAIMode("Random Solo")

		if (currentNPC:getGroupID() ~= nil) then
			local group = SSGM:GetGroupById(currentNPC:getGroupID())
			group:removeMember(currentNPC:getID())
		end
		currentNPC:getTaskManager():clear()
		if (currentNPC:Get():getStats():getHunger() > 0.40) then currentNPC:Get():getStats():setHunger(0.40) end
		if (currentNPC:Get():getStats():getThirst() > 0.40) then currentNPC:Get():getStats():setThirst(0.40) end
		currentNPC:Speak(Get_SS_Dialogue("LeaveGroupHungry"))
	elseif (TaskMangerIn:getCurrentTask() ~= "Enter New Building")
		and (TaskMangerIn:getCurrentTask() ~= "Clean Inventory")
		and (IsInAction == false)
		and (TaskMangerIn:getCurrentTask() ~= "Eat Food")
		and (TaskMangerIn:getCurrentTask() ~= "Find This")
		and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (((currentNPC:isHungry())
				and (IsInBase))
			or currentNPC:isVHungry())
		and (currentNPC:getDangerSeenCount() == 0)
	then
		if (not currentNPC:hasFood()) and (currentNPC:getNoFoodNearBy() == false) and ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep())) then
			if (HisGroup) then
				local area = HisGroup:getGroupAreaCenterSquare("FoodStorageArea")
				if (area) then
					currentNPC:walkTo(area)
				end
			end
			TaskMangerIn:AddToTop(FindThisTask:new(currentNPC, "Food", "Category", 1))
		elseif (currentNPC:hasFood()) then
			TaskMangerIn:AddToTop(EatFoodTask:new(currentNPC, currentNPC:getFood()))
		end
	end

	-- ----------------------------- --
	-- Find food / drink - like task --
	-- ----------------------------- --
	if (TaskMangerIn:getCurrentTask() ~= "Enter New Building")
		and (IsInAction == false)
		and (TaskMangerIn:getCurrentTask() ~= "Eat Food")
		and (TaskMangerIn:getCurrentTask() ~= "Find This")
		and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (((currentNPC:isThirsty())
				and (IsInBase))
			or currentNPC:isVThirsty())
		and (currentNPC:getDangerSeenCount() == 0)
	then
		if (currentNPC:getNoWaterNearBy() == false)
			and ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep()))
		then
			if (HisGroup) then
				local area = HisGroup:getGroupAreaCenterSquare("FoodStorageArea")
				if (area) then currentNPC:walkTo(area) end
				currentNPC:Speak("I'm going to get some food before I die of hunger.")
			end
			TaskMangerIn:AddToTop(FindThisTask:new(currentNPC, "Water", "Category", 1))
		end
	end


	-- ----------------------------- --
	-- 			Listen to Task
	-- ----------------------------- --
	if ((currentNPC:Get():getModData().InitGreeting ~= nil)
			or (currentNPC:getAIMode() == "Random Solo")
		)
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (TaskMangerIn:getCurrentTask() ~= "Surender")
		and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
		and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
		and (currentNPC.LastSurvivorSeen ~= nil)
		--and (currentNPC.LastSurvivorSeen:isGhostMode() == false)
		and (currentNPC:getSpokeTo(currentNPC.LastSurvivorSeen:getModData().ID) == false)
		and (GetDistanceBetween(currentNPC.LastSurvivorSeen, currentNPC:Get()) < 8)
		and (currentNPC:getDangerSeenCount() == 0) and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (currentNPC:Get():CanSee(currentNPC.LastSurvivorSeen))
	then
		currentNPC:Speak(Get_SS_Dialogue("HeyYou"))
		currentNPC:SpokeTo(currentNPC.LastSurvivorSeen:getModData().ID)
		TaskMangerIn:AddToTop(ListenTask:new(currentNPC, currentNPC.LastSurvivorSeen, true))
	end


	-- ----------------------------- --
	-- 	Gun Readying / Reloading     --
	-- ----------------------------- --
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		if (currentNPC:getNeedAmmo())
			and (currentNPC:hasAmmoForPrevGun())
			and (IsInAction == false)
			and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
			and (TaskMangerIn:getCurrentTask() ~= "Flee")  -- New
			and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot") -- New
			and (currentNPC:getDangerSeenCount() == 0)
		then
			currentNPC:setNeedAmmo(false)
			-- Reminder: re-enable this
			currentNPC:reEquipGun()
		end
	end

	-- ----------------------------- --
	-- 	Equip Weapon Task            --
	-- ----------------------------- --
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then
		if (currentNPC:hasWeapon()) and (currentNPC:Get():getPrimaryHandItem() == nil) and (TaskMangerIn:getCurrentTask() ~= "Equip Weapon") then
			TaskMangerIn:AddToTop(EquipWeaponTask:new(currentNPC))
		end
	end

	-- ----------------------------- --
	-- 	Equip Weapon Task            --
	-- ----------------------------- --
	if not (AiNPC_Job_Is(currentNPC, "Companion")) then -- removed and (currentNPC:getNeedAmmo() == false) condition as I dont remember what that is for
		if (IsInAction == false)
			and currentNPC:usingGun()
			and (currentNPC:getDangerSeenCount() == 0)
			and ((currentNPC:needToReload())
				or (currentNPC:needToReadyGun(npcWeapon)))
			and (currentNPC:NPC_FleeWhileReadyingGun())
		then
			currentNPC:ReadyGun(npcWeapon)
		end
	end

	-- ---------------------------------------------------------- --
	-- ------------------- Base Tasks---------------------------- --
	-- ---------------------------------------------------------- --

	if ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep())) and (currentNPC:getAIMode() ~= "Stand Ground") then
		SafeToGoOutAndWork = true
		local AutoWorkTaskTimeLimit = 300

		-- -------
		-- Guard
		-- -------
		if (currentNPC:getGroupRole() == "Guard") then
			-- if getGroupArea 'getGroupArea = does this area exist'

			if (Task_Is_Not("Attack")
					and Task_Is_Not("Threaten")
					and Task_Is_Not("Pursue")
					and Task_Is_Not("Flee")
					and Task_Is_Not("First Aide")
					and Task_Is_Not("Find This")
					and Task_Is_Not("Eat Food")
					and Task_Is_Not("Follow")
					and (IsInAction == false))
			then
				if (HisGroup:getGroupAreaCenterSquare("GuardArea") ~= nil) and (HisGroup:getGroupArea("GuardArea")) then
					if (GetDistanceBetween(HisGroup:getGroupAreaCenterSquare("GuardArea"), currentNPC:Get():getCurrentSquare()) > 10) then
						TaskMangerIn:clear()
						TaskMangerIn:AddToTop(GuardTask:new(currentNPC,
							GetRandomAreaSquare(HisGroup:getGroupArea("GuardArea"))))
					end
				end

				if (GetDistanceBetween(HisGroup:getGroupAreaCenterSquare("GuardArea"), currentNPC:Get():getCurrentSquare()) <= 10) then
					if (HisGroup:getGroupAreaCenterSquare("GuardArea") ~= nil) and (HisGroup:getGroupArea("GuardArea")) then
						TaskMangerIn:AddToTop(GuardTask:new(currentNPC,
							GetRandomAreaSquare(HisGroup:getGroupArea("GuardArea"))))
					end
				end

				if (HisGroup:getGroupAreaCenterSquare("GuardArea") == nil) and (CenterBaseSquare ~= nil) and not (IsInBase) then
					TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
				elseif (HisGroup:getGroupAreaCenterSquare("GuardArea") == nil) and (CenterBaseSquare == nil) and not (IsInBase) then
					TaskMangerIn:AddToTop(GuardTask:new(currentNPC, HisGroup:getRandomBaseSquare()))
				end
			else
				if Task_Is("Flee") then currentNPC:NPC_ShouldRunOrWalk() end
			end
		end

		if (currentNPC:getCurrentTask() == "None") and (IsInBase) and (not IsInAction) and (ZombRand(4) == 0) then
			if (not SurvivorCanFindWork) and (currentNPC:getGroupRole() == "Doctor") then
				local randresult = ZombRand(10) + 1
				if (randresult == 1) then
					currentNPC:Speak(Get_SS_UIActionText("IGoRelax"))
					TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
				else
					local medicalarea = HisGroup:getGroupArea("MedicalStorageArea")

					local gotoSquare
					if (medicalarea) and (medicalarea[1] ~= 0) then
						gotoSquare = GetCenterSquareFromArea(medicalarea[1],
							medicalarea[2], medicalarea[3], medicalarea[4], medicalarea[5])
					end
					if (not gotoSquare) then gotoSquare = CenterBaseSquare end

					if (gotoSquare) then currentNPC:walkTo(gotoSquare) end
					TaskMangerIn:AddToTop(DoctorTask:new(currentNPC))
					return TaskMangerIn
				end
			elseif (not SurvivorCanFindWork) and (currentNPC:getGroupRole() == "Farmer") then
				if (SurvivorCanFindWork) and (RainManager.isRaining() == false) then
					local randresult = ZombRand(10) + 1

					if (randresult == 1) then
						currentNPC:Speak(Get_SS_UIActionText("IGoRelax"))
						TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
						TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
					else
						local area = HisGroup:getGroupArea("FarmingArea")
						if (area) then
							currentNPC:Speak(Get_SS_UIActionText("IGoFarm"))
							TaskMangerIn:AddToTop(FarmingTask:new(currentNPC))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						else
							CreateLogLine("AI-Manager", isLocalLoggingEnabled, "farming area was nil");
						end
					end
				end

				-- ModderNote: From what I've observed, companion isn't used on anything else except to follow
				-- So exploiting that knowledge, I made the companion more of a 'class job priority' set of jobs at the top of the code.
				-- So if you are another modder that has the torch, that's looking to make Followers listen to you more, Follower = 'companion'
			elseif (currentNPC:getGroupRole() == "Companion") then -- Not new, this was here before
				TaskMangerIn:AddToTop(FollowTask:new(currentNPC, getSpecificPlayer(0)))
			elseif (SurvivorCanFindWork)
				and not (AiNPC_Job_Is(currentNPC, "Guard"))
				and not (AiNPC_Job_Is(currentNPC, "Leader"))
				and not (AiNPC_Job_Is(currentNPC, "Doctor"))
				and not (AiNPC_Job_Is(currentNPC, "Farming"))
			then
				if (currentNPC:Get():getBodyDamage():getWetness() < 0.2) then
					if (SafeToGoOutAndWork) then
						TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)

						local forageSquare = HisGroup:getGroupAreaCenterSquare("ForageArea")
						local chopWoodSquare = HisGroup:getGroupAreaCenterSquare("ChopTreeArea")
						local farmingArea = HisGroup:getGroupArea("FarmingArea")
						local guardArea = HisGroup:getGroupArea("GuardArea")

						local jobScores = {}
						local job = "Relax"
						-- idle tasks
						jobScores["Relax"] = 0 + math.floor(currentNPC:Get():getStats():getBoredom() * 20.0)
						jobScores["Wash Self"] = 1

						-- maintenance
						jobScores["Clean Inventory"] = 2
						jobScores["Gather Wood"] = 2
						jobScores["Pile Corpses"] = 2

						-- skilled work
						jobScores["Chop Wood"] = 2 +
							math.min(currentNPC:Get():getPerkLevel(Perks.FromString("Axe")), 3)
						jobScores["Forage"] = 2 +
							math.min(currentNPC:Get():getPerkLevel(Perks.FromString("Foraging")), 3)

						-- deprioritize assigned tasks
						jobScores["Farming"] = 0 +
							math.min(currentNPC:Get():getPerkLevel(Perks.FromString("Farming")), 3)
						jobScores["Doctor"] = -2 +
							math.min(currentNPC:Get():getPerkLevel(Perks.FromString("Doctor")), 3) +
							math.min(currentNPC:Get():getPerkLevel(Perks.FromString("First Aid")), 3)
						jobScores["Guard"] = 2 +
							math.min(currentNPC:Get():getPerkLevel(Perks.FromString("Aiming")), 3)

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
						if currentNPC:Get():getBodyDamage():getWetness() > 0.5 then
							-- do indoor stuff to dry off
							jobScores["Relax"] = jobScores["Relax"] + 3
							jobScores["Clean Inventory"] = jobScores["Clean Inventory"] + 3
							jobScores["Wash Self"] = jobScores["Wash Self"] + 2
						end

						-- personal needs
						local filth = currentNPC:getFilth()
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

						currentNPC:Get():getStats():setBoredom(currentNPC:Get():getStats():getBoredom() +
							(ZombRand(5) / 100.0))
						if (job == "Relax") then
							currentNPC:Speak(Get_SS_UIActionText("IGoRelax"))
							currentNPC:Get():getStats():setBoredom(0.0)
							TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
						elseif (job == "Gather Wood") then
							currentNPC:Speak(Get_SS_UIActionText("IGoGetWood"))
							local dropSquare = CenterBaseSquare
							local woodstoragearea = HisGroup:getGroupArea("WoodStorageArea")
							if (woodstoragearea[1] ~= 0) then
								dropSquare = GetCenterSquareFromArea(woodstoragearea[1],
									woodstoragearea[2], woodstoragearea[3], woodstoragearea[4], woodstoragearea[5])
							end
							TaskMangerIn:AddToTop(GatherWoodTask:new(currentNPC, dropSquare))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						elseif (job == "Pile Corpses") then
							currentNPC:Speak(Get_SS_UIActionText("IGoPileCorpse"))
							local baseBounds = HisGroup:getBounds()
							local dropSquare = getCell():getGridSquare(baseBounds[1] - 5, baseBounds[3] - 5, 0)
							local storagearea = HisGroup:getGroupArea("CorpseStorageArea")
							if (storagearea[1] ~= 0) then
								dropSquare = GetCenterSquareFromArea(storagearea[1],
									storagearea[2], storagearea[3], storagearea[4], storagearea[5])
							end
							if (dropSquare) then
								TaskMangerIn:AddToTop(PileCorpsesTask:new(currentNPC, dropSquare))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							end
						elseif (job == "Forage") then
							local dropSquare = CenterBaseSquare
							local FoodStorageCenter = HisGroup:getGroupAreaCenterSquare("FoodStorageArea")
							if (FoodStorageCenter) then dropSquare = FoodStorageCenter end

							if (forageSquare ~= nil) then
								currentNPC:Speak(Get_SS_UIActionText("IGoForage"))
								currentNPC:walkTo(forageSquare)
								TaskMangerIn:AddToTop(SortLootTask:new(currentNPC, false))
								TaskMangerIn:AddToTop(ForageTask:new(currentNPC))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "forage area was nil");
							end
						elseif (job == "Chop Wood") then
							if (chopWoodSquare) then
								currentNPC:Speak(Get_SS_UIActionText("IGoChopWood"))
								TaskMangerIn:AddToTop(ChopWoodTask:new(currentNPC))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "chopWoodArea area was nil");
							end
						elseif (job == "Farming") then
							if (farmingArea) then
								currentNPC:Speak(Get_SS_UIActionText("IGoFarm"))
								TaskMangerIn:AddToTop(FarmingTask:new(currentNPC))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							else
								CreateLogLine("AI-Manager", isLocalLoggingEnabled, "farmingArea area was nil");
							end
						elseif (job == "Guard") then
							if (guardArea) then
								currentNPC:Speak(Get_SS_UIActionText("IGoGuard"))
								TaskMangerIn:AddToTop(WanderInAreaTask:new(currentNPC, guardArea))
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

							if (gotoSquare) then currentNPC:walkTo(gotoSquare) end
							TaskMangerIn:AddToTop(DoctorTask:new(currentNPC))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						elseif (job == "Clean Inventory") then
							currentNPC:Speak("Cleaning Inventory")
							local dropSquare = CenterBaseSquare
							local ToolStorageCenter = HisGroup:getGroupAreaCenterSquare("ToolStorageArea")
							if (ToolStorageCenter) then dropSquare = ToolStorageCenter end
							TaskMangerIn:AddToTop(SortLootTask:new(currentNPC, false))
						elseif (job == "Wash Self") then
							currentNPC:Speak("Washing Self")
							TaskMangerIn:AddToTop(WashSelfTask:new(currentNPC))
						end
					else
						TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
					end -- safeto go out end
				end -- allowed to go out work end
			end
		end

		-- Oop, found this. I could use this for followers to get back to main player
		if (currentNPC:getCurrentTask() == "None") and (IsInBase == false) and (not IsInAction) and (HisGroup ~= nil) then
			local baseSq = CenterBaseSquare
			if (baseSq ~= nil) then
				currentNPC:Speak(Get_SS_UIActionText("IGoBackBase"))
				TaskMangerIn:AddToTop(ReturnToBaseTask:new(currentNPC))
			end
		end
	end

	-- ----------------------------------------------------------- --
	-- ------ END -------- Base Tasks ------- END ---------------- --
	-- ----------------------------------------------------------- --

	-- TODO test: maybe add 'if not in attack / pursue / threaten , then do ' along with the 'none tasks'

	if (currentNPC:getAIMode() == "Random Solo")
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
	then -- solo random survivor AI flow	
		if (TaskMangerIn:getCurrentTask() == "None")
			and (currentNPC.TargetBuilding ~= nil)
			and (not currentNPC:getBuildingExplored(currentNPC.TargetBuilding))
			and (not currentNPC:isEnemyInRange(currentNPC.LastEnemeySeen))
		then
			TaskMangerIn:AddToTop(AttemptEntryIntoBuildingTask:new(currentNPC, currentNPC.TargetBuilding))
		elseif (TaskMangerIn:getCurrentTask() == "None")
			and ((not EnemyIsSurvivor)
				or (not currentNPC:isEnemyInRange(currentNPC.LastEnemeySeen)))
		then
			TaskMangerIn:AddToTop(FindUnlootedBuildingTask:new(currentNPC))
		end

		if (currentNPC.TargetBuilding ~= nil) or (currentNPC:inUnLootedBuilding()) then
			if currentNPC.TargetBuilding == nil then currentNPC.TargetBuilding = currentNPC:getBuilding() end
			if (not currentNPC:hasWeapon()) and (TaskMangerIn:getCurrentTask() ~= "Loot Category")
				and (currentNPC:getDangerSeenCount() <= 0)
				and (currentNPC:inUnLootedBuilding())
				and (currentNPC:isTargetBuildingClaimed(currentNPC.TargetBuilding) == false)
			then
				TaskMangerIn:AddToTop(LootCategoryTask:new(currentNPC, currentNPC.TargetBuilding, "Food", 2))
				TaskMangerIn:AddToTop(EquipWeaponTask:new(currentNPC))
				TaskMangerIn:AddToTop(LootCategoryTask:new(currentNPC, currentNPC.TargetBuilding, "Weapon", 2))
			elseif (currentNPC:hasRoomInBag())
				and (TaskMangerIn:getCurrentTask() ~= "Loot Category")
				and (currentNPC:getDangerSeenCount() <= 0) and (currentNPC:inUnLootedBuilding())
				and (currentNPC:isTargetBuildingClaimed(currentNPC.TargetBuilding) == false)
			then
				TaskMangerIn:AddToTop(LootCategoryTask:new(currentNPC, currentNPC.TargetBuilding, "Food", 1))
			end
		end
		if (CanNpcsCreateBase) and
			(IsInAction == false) and -- New. Hopefully to stop spam
			(currentNPC:getBaseBuilding() == nil) and
			(currentNPC:getBuilding()) and
			(TaskMangerIn:getCurrentTask() ~= "First Aide") and
			(TaskMangerIn:getCurrentTask() ~= "Attack") and
			(TaskMangerIn:getCurrentTask() ~= "Threaten") and  -- new
			(TaskMangerIn:getCurrentTask() ~= "Pursue") and    -- new
			(TaskMangerIn:getCurrentTask() ~= "Enter New Building") and -- new
			(TaskMangerIn:getCurrentTask() ~= "Barricade Building") and
			(currentNPC:hasWeapon()) and
			(currentNPC:getGroupRole() ~= "Companion") and  -- New
			(currentNPC:isInSameBuildingWithEnemyAlt() == false) and -- That way npc doesn't stop what they're doing moment they look away from a hostile
			(currentNPC:hasFood())
		then
			TaskMangerIn:clear()
			currentNPC:setBaseBuilding(currentNPC:getBuilding())
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(currentNPC, currentNPC:getBuilding()))
			TaskMangerIn:AddToTop(LockDoorsTask:new(currentNPC, true))
			TaskMangerIn:AddToTop(BarricadeBuildingTask:new(currentNPC))
			currentNPC:Speak("This will be my base.")
			local GroupId = SSGM:GetGroupIdFromSquare(currentNPC:Get():getCurrentSquare())

			CreateLogLine("AI-Manager", isLocalLoggingEnabled, tostring(currentNPC:getName()) .. " is making a base");
			CreateLogLine("AI-Manager", isLocalLoggingEnabled, tostring(GroupId) .. " is the base id");

			if (GroupId == -1) then -- if the base this npc is gonna stay in is not declared as another base then they set it as thier base.
				local nGroup = SSGM:newGroup()
				nGroup:addMember(currentNPC, "Leader")
				local def = currentNPC:getBuilding():getDef()
				local bounds = { def:getX() - 1, (def:getX() + def:getW() + 1), def:getY() - 1,
					(def:getY() + def:getH() + 1), 0 }
				nGroup:setBounds(bounds)
			elseif ((SSM:Get(0) == nil) or (GroupId ~= SSM:Get(0):getGroupID())) then
				local OwnerGroup = SSGM:GetGroupById(GroupId)
				local LeaderID = OwnerGroup:getLeader()
				if (LeaderID ~= 0) then
					OwnerGroup:addMember(currentNPC, "Worker")
					currentNPC:Speak("Please let me stay here")
					local LeaderObj = SSM:Get(LeaderID)
					if (LeaderObj) then
						LeaderObj:Speak("Welcome to our Group")
					end
				end
			end
		end


		if ((CanNpcsCreateBase)
				and (currentNPC:isStarving())
				or (currentNPC:isDyingOfThirst())
			)
			and (currentNPC:getBaseBuilding() ~= nil)
		then -- leave group and look for food if starving
			-- random survivor in base is starving - reset so he goes back out looking for food and re base there
			currentNPC:setAIMode("Random Solo")
			if (currentNPC:getGroupID() ~= nil) then
				local group = SSGM:GetGroupById(currentNPC:getGroupID())
				group:removeMember(currentNPC:getID())
			end
			currentNPC:getTaskManager():clear()
			currentNPC:Speak(Get_SS_UIActionText("LeaveBCHungry"))
			CreateLogLine("AI-Manager", isLocalLoggingEnabled,
				tostring(currentNPC:getName()) .. ": clearing task manager because too hungry");
			currentNPC:resetAllTables()
			currentNPC:setBaseBuilding(nil)
			if (currentNPC:Get():getStats():getHunger() > 0.30) then currentNPC:Get():getStats():setHunger(0.30) end
			if (currentNPC:Get():getStats():getThirst() > 0.30) then currentNPC:Get():getStats():setThirst(0.30) end
		end
	end

	return TaskMangerIn
end
