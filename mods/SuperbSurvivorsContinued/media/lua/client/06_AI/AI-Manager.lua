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
	local currentNPC = TaskMangerIn.parent; -- replaces both "ASuperbSurvivor" and "NPC".

	if (TaskMangerIn == nil) or (currentNPC == nil) then
		return false;
	end

	if (currentNPC:needToFollow())
		or (currentNPC:Get():getVehicle() ~= nil)
	then
		return TaskMangerIn
	end -- if in vehicle skip AI -- or high priority follow

	local dangerRange = 6;
	local npcIsInAction = currentNPC:isInAction();
	local npcGroup = currentNPC:getGroup();
	local npcIsInBase = currentNPC:isInBase();
	local centerBaseSquare = nil;
	local distanceBetweenMainPlayer = GetDistanceBetween(getSpecificPlayer(0), currentNPC:Get());
	local isEnemySurvivor = (instanceof(currentNPC.LastEnemeySeen, "IsoPlayer"));
	--
	if (npcGroup) then
		centerBaseSquare = npcGroup:getBaseCenter();
	end

	-- Simplified Local functions
	local function Task_Is(TaskName)
		return (TaskMangerIn:getCurrentTask() == TaskName)
	end
	-- 
	if (AiNPC_Job_Is(currentNPC, "Companion")) then
		AI_Companion(TaskMangerIn);
	else
		AI_NonCompanion(TaskMangerIn);
	end

	-- ----------------------------- --
	-- Find food / drink - like task --
	-- ----------------------------- --
	if (TaskMangerIn:getCurrentTask() ~= "Enter New Building")
		and (npcIsInAction == false)
		and (TaskMangerIn:getCurrentTask() ~= "Eat Food")
		and (TaskMangerIn:getCurrentTask() ~= "Find This")
		and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (((currentNPC:isThirsty())
				and (npcIsInBase))
			or currentNPC:isVThirsty())
		and (currentNPC:getDangerSeenCount() == 0)
	then
		if (currentNPC:getNoWaterNearBy() == false)
			and ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep()))
		then
			if (npcGroup) then
				local area = npcGroup:getGroupAreaCenterSquare("FoodStorageArea")
				if (area) then currentNPC:walkTo(area) end
				currentNPC:Speak("I'm going to get some food before I die of hunger.")
			end
			TaskMangerIn:AddToTop(FindThisTask:new(currentNPC, "Water", "Category", 1))
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
		if (AiNPC_Job_Is(currentNPC, "Guard")) then
			-- if getGroupArea 'getGroupArea = does this area exist'

			if (not Task_Is("Attack")
					and not Task_Is("Threaten")
					and not Task_Is("Pursue")
					and not Task_Is("Flee")
					and not Task_Is("First Aide")
					and not Task_Is("Find This")
					and not Task_Is("Eat Food")
					and not Task_Is("Follow")
					and (npcIsInAction == false))
			then
				if (npcGroup:getGroupAreaCenterSquare("GuardArea") ~= nil) and (npcGroup:getGroupArea("GuardArea")) then
					if (GetDistanceBetween(npcGroup:getGroupAreaCenterSquare("GuardArea"), currentNPC:Get():getCurrentSquare()) > 10) then
						TaskMangerIn:clear();
						TaskMangerIn:AddToTop(
							GuardTask:new(currentNPC, GetRandomAreaSquare(npcGroup:getGroupArea("GuardArea")))
						);
					end
				end

				if (GetDistanceBetween(npcGroup:getGroupAreaCenterSquare("GuardArea"), currentNPC:Get():getCurrentSquare()) <= 10) then
					if (npcGroup:getGroupAreaCenterSquare("GuardArea") ~= nil) and (npcGroup:getGroupArea("GuardArea")) then
						TaskMangerIn:AddToTop(GuardTask:new(currentNPC,
							GetRandomAreaSquare(npcGroup:getGroupArea("GuardArea"))))
					end
				end

				if (npcGroup:getGroupAreaCenterSquare("GuardArea") == nil) and (centerBaseSquare ~= nil) and not (npcIsInBase) then
					TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
				elseif (npcGroup:getGroupAreaCenterSquare("GuardArea") == nil) and (centerBaseSquare == nil) and not (npcIsInBase) then
					TaskMangerIn:AddToTop(GuardTask:new(currentNPC, npcGroup:getRandomBaseSquare()))
				end
			else
				if Task_Is("Flee") then currentNPC:NPC_ShouldRunOrWalk() end
			end
		end

		if (currentNPC:getCurrentTask() == "None") and (npcIsInBase) and (not npcIsInAction) and (ZombRand(4) == 0) then
			if (AiNPC_Job_Is(currentNPC, "Companion")) then
				TaskMangerIn:AddToTop(FollowTask:new(currentNPC, getSpecificPlayer(0)));
			elseif (not SurvivorCanFindWork) and (AiNPC_Job_Is(currentNPC, "Doctor")) then
				local randresult = ZombRand(10) + 1;
				--
				if (randresult == 1) then
					currentNPC:Speak(Get_SS_UIActionText("IGoRelax"))
					TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
				else
					local medicalarea = npcGroup:getGroupArea("MedicalStorageArea");
					local gotoSquare;
					--
					if (medicalarea) and (medicalarea[1] ~= 0) then
						gotoSquare = GetCenterSquareFromArea(medicalarea[1],
							medicalarea[2], medicalarea[3], medicalarea[4], medicalarea[5]);
					end
					--
					if (not gotoSquare) then
						gotoSquare = centerBaseSquare;
					end
					--
					if (gotoSquare) then
						currentNPC:walkTo(gotoSquare);
					end
					TaskMangerIn:AddToTop(DoctorTask:new(currentNPC))
					return TaskMangerIn
				end
			elseif (not SurvivorCanFindWork) and (AiNPC_Job_Is(currentNPC, "Farmer")) then
				if (SurvivorCanFindWork) and (RainManager.isRaining() == false) then
					local randresult = ZombRand(10) + 1

					if (randresult == 1) then
						currentNPC:Speak(Get_SS_UIActionText("IGoRelax"))
						TaskMangerIn:AddToTop(WanderInBaseTask:new(currentNPC))
						TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
					else
						local area = npcGroup:getGroupArea("FarmingArea")
						if (area) then
							currentNPC:Speak(Get_SS_UIActionText("IGoFarm"))
							TaskMangerIn:AddToTop(FarmingTask:new(currentNPC))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						else
							CreateLogLine("AI-Manager", isLocalLoggingEnabled, "farming area was nil");
						end
					end
				end
			elseif (SurvivorCanFindWork)
				and not (AiNPC_Job_Is(currentNPC, "Guard"))
				and not (AiNPC_Job_Is(currentNPC, "Leader"))
				and not (AiNPC_Job_Is(currentNPC, "Doctor"))
				and not (AiNPC_Job_Is(currentNPC, "Farming"))
			then
				if (currentNPC:Get():getBodyDamage():getWetness() < 0.2) then
					if (SafeToGoOutAndWork) then
						TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)

						local forageSquare = npcGroup:getGroupAreaCenterSquare("ForageArea")
						local chopWoodSquare = npcGroup:getGroupAreaCenterSquare("ChopTreeArea")
						local farmingArea = npcGroup:getGroupArea("FarmingArea")
						local guardArea = npcGroup:getGroupArea("GuardArea")

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
								jobScores[key] = value - npcGroup:getTaskCount("Wander In Area")
							elseif key == "Doctor" then
								-- no point in more than one doctor at a time
								jobScores[key] = value - (npcGroup:getTaskCount(key) * 10)
							elseif key == "Farming" then
								-- no point in more than one farmer at a time
								jobScores[key] = value - (npcGroup:getTaskCount(key) * 10)
							elseif key == "Forage" then
								-- little point in more than one forager at a time
								jobScores[key] = value - (npcGroup:getTaskCount(key) * 2)
							else
								jobScores[key] = value - npcGroup:getTaskCount(key)
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
							local dropSquare = centerBaseSquare
							local woodstoragearea = npcGroup:getGroupArea("WoodStorageArea")
							if (woodstoragearea[1] ~= 0) then
								dropSquare = GetCenterSquareFromArea(woodstoragearea[1],
									woodstoragearea[2], woodstoragearea[3], woodstoragearea[4], woodstoragearea[5])
							end
							TaskMangerIn:AddToTop(GatherWoodTask:new(currentNPC, dropSquare))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						elseif (job == "Pile Corpses") then
							currentNPC:Speak(Get_SS_UIActionText("IGoPileCorpse"))
							local baseBounds = npcGroup:getBounds()
							local dropSquare = getCell():getGridSquare(baseBounds[1] - 5, baseBounds[3] - 5, 0)
							local storagearea = npcGroup:getGroupArea("CorpseStorageArea")
							if (storagearea[1] ~= 0) then
								dropSquare = GetCenterSquareFromArea(storagearea[1],
									storagearea[2], storagearea[3], storagearea[4], storagearea[5])
							end
							if (dropSquare) then
								TaskMangerIn:AddToTop(PileCorpsesTask:new(currentNPC, dropSquare))
								TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
							end
						elseif (job == "Forage") then
							local dropSquare = centerBaseSquare
							local FoodStorageCenter = npcGroup:getGroupAreaCenterSquare("FoodStorageArea")
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
							local medicalarea = npcGroup:getGroupArea("MedicalStorageArea")

							local gotoSquare
							if (medicalarea) and (medicalarea[1] ~= 0) then
								gotoSquare = GetCenterSquareFromArea(
									medicalarea[1], medicalarea[2], medicalarea[3], medicalarea[4], medicalarea[5])
							end
							if (not gotoSquare) then gotoSquare = centerBaseSquare end

							if (gotoSquare) then currentNPC:walkTo(gotoSquare) end
							TaskMangerIn:AddToTop(DoctorTask:new(currentNPC))
							TaskMangerIn:setTaskUpdateLimit(AutoWorkTaskTimeLimit)
						elseif (job == "Clean Inventory") then
							currentNPC:Speak("Cleaning Inventory")
							local dropSquare = centerBaseSquare
							local ToolStorageCenter = npcGroup:getGroupAreaCenterSquare("ToolStorageArea")
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
		if (currentNPC:getCurrentTask() == "None") and (npcIsInBase == false) and (not npcIsInAction) and (npcGroup ~= nil) then
			local baseSq = centerBaseSquare;
			--
			if (baseSq ~= nil) then
				currentNPC:Speak(Get_SS_UIActionText("IGoBackBase"))
				TaskMangerIn:AddToTop(ReturnToBaseTask:new(currentNPC))
			end
		end
	end

	-- ----------------------------------------------------------- --
	-- ------ END -------- Base Tasks ------- END ---------------- --
	-- ----------------------------------------------------------- --

	-- ----------------------------- --
	-- Cows: Begin Random Solo(?)
	-- ----------------------------- --
	-- If NPC is Starving or dehydrating, force leave group
	-- To do - Give player option to let this task happen or not too
	-- ----------------------------- --
	if (false) and (currentNPC:getAIMode() ~= "Random Solo") and ((currentNPC:isStarving()) or (currentNPC:isDyingOfThirst())) then
		currentNPC:setAIMode("Random Solo");

		-- leave group and look for food if starving
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
		and (npcIsInAction == false)
		and (TaskMangerIn:getCurrentTask() ~= "Eat Food")
		and (TaskMangerIn:getCurrentTask() ~= "Find This")
		and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (((currentNPC:isHungry())
				and (npcIsInBase))
			or currentNPC:isVHungry())
		and (currentNPC:getDangerSeenCount() == 0)
	then
		if (not currentNPC:hasFood()) and (currentNPC:getNoFoodNearBy() == false) and ((getSpecificPlayer(0) == nil) or (not getSpecificPlayer(0):isAsleep())) then
			if (npcGroup) then
				local area = npcGroup:getGroupAreaCenterSquare("FoodStorageArea")
				if (area) then
					currentNPC:walkTo(area)
				end
			end
			TaskMangerIn:AddToTop(FindThisTask:new(currentNPC, "Food", "Category", 1))
		elseif (currentNPC:hasFood()) then
			TaskMangerIn:AddToTop(EatFoodTask:new(currentNPC, currentNPC:getFood()))
		end
	end

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
			and ((not isEnemySurvivor)
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
			(npcIsInAction == false) and -- New. Hopefully to stop spam
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

	-- ----------------------------- --
	-- 			Listen to Task
	-- ----------------------------- --
	if ((currentNPC:Get():getModData().InitGreeting ~= nil) or (currentNPC:getAIMode() == "Random Solo"))
		and (TaskMangerIn:getCurrentTask() ~= "Listen")
		and (TaskMangerIn:getCurrentTask() ~= "Surender")
		and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot")
		and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
		and (currentNPC.LastSurvivorSeen ~= nil)
		and (currentNPC:getSpokeTo(currentNPC.LastSurvivorSeen:getModData().ID) == false)
		and (GetDistanceBetween(currentNPC.LastSurvivorSeen, currentNPC:Get()) < 8)
		and (currentNPC:getDangerSeenCount() == 0) and (TaskMangerIn:getCurrentTask() ~= "First Aide")
		and (currentNPC:Get():CanSee(currentNPC.LastSurvivorSeen))
	then
		currentNPC:Speak(Get_SS_Dialogue("HeyYou"))
		currentNPC:SpokeTo(currentNPC.LastSurvivorSeen:getModData().ID)
		TaskMangerIn:AddToTop(ListenTask:new(currentNPC, currentNPC.LastSurvivorSeen, true))
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
				and (not currentNPC:usingGun() or (not currentNPC:RealCanSee(getSpecificPlayer(0)) and distanceBetweenMainPlayer <= 3))
				and getSpecificPlayer(0):isAiming()
				and IsoPlayer.getCoopPVP()
				and not currentNPC:isInGroup(getSpecificPlayer(0))
				and (facingResult > 0.95)
				and (distanceBetweenMainPlayer < dangerRange))
		then
			TaskMangerIn:clear()
			TaskMangerIn:AddToTop(SurenderTask:new(currentNPC, SSM:Get(0)))
			return TaskMangerIn
		end
	end

	return TaskMangerIn
end
