-- Check if SSM is loaded and game speed isn't on pause before updating the Survivors routines.
function SuperSurvivorsOnTick()
	if SSM ~= nil and getGameSpeed() ~= 0 then
		SSM:UpdateSurvivorsRoutine();
	end
end

Events.OnRenderTick.Add(SuperSurvivorsOnTick);

--- WIP - Cows: Saves all the relevant mod data... it works, but I think it can be better.
function SuperSurvivorsSaveData()
	local isSaveFunctionLoggingEnabled = false;
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "function: SuperSurvivorsSaveData() called");
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "Saving...");
	SSM:SaveAll();
	SSGM:Save();
	SaveSurvivorMap();
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "--- SuperSurvivorsSaveData() end ---");
end

Events.OnPostSave.Add(SuperSurvivorsSaveData);

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorsLoadGridsquare(square)
	if (square ~= nil) then
		local x = square:getX()
		local y = square:getY()
		local z = square:getZ()
		local key = x .. y .. z

		if (SurvivorMap == nil) then
			SSM:init();
			SSGM:Load();

			if (DoesFileExist("SurvivorLocX")) then
				SurvivorMap = LoadSurvivorMap() -- matrix grid containing info on location of all survivors for re-spawning purposes
			else
				SurvivorMap = {};
				SurvivorLocX = {};
				SurvivorLocY = {};
				SurvivorLocZ = {};
			end
		end

		if (key) and (SurvivorMap[key] ~= nil) and (#SurvivorMap[key] > 0) then
			local i = 1;

			while (SurvivorMap[key][i] ~= nil) do
				SSM:LoadSurvivor(SurvivorMap[key][i], square);
				i = i + 1;
			end
			i = 1;
			SurvivorMap[key] = {} -- i think this is faster
		end
	end
end

Events.LoadGridsquare.Add(SuperSurvivorsLoadGridsquare); --- This is a potential performance killer... because it scans through all the known map squares.

function SuperSurvivorsOnSwing(player, weapon)
	local ID = player:getModData().ID
	if (ID ~= nil) then
		local SS = SSM:Get(ID)
		if (SS) and not player:isLocalPlayer() then
			if weapon:isRanged() then
				if weapon:haveChamber() then
					weapon:setRoundChambered(false);
				end
				-- remove ammo, add one to chamber if we still have some
				if weapon:getCurrentAmmoCount() >= weapon:getAmmoPerShoot() then
					if weapon:haveChamber() then
						weapon:setRoundChambered(true);
					end
					weapon:setCurrentAmmoCount(weapon:getCurrentAmmoCount() - weapon:getAmmoPerShoot())
				end
				if weapon:isRackAfterShoot() then -- shotgun need to be rack after each shot to rechamber round
					player:setVariable("RackWeapon", weapon:getWeaponReloadType());
				end
			end

			if (weapon:isRoundChambered()) then
				local range = weapon:getSoundRadius()
				local volume = weapon:getSoundVolume()
				addSound(player, player:getX(), player:getY(), player:getZ(), range, volume)
				getSoundManager():PlayWorldSound(weapon:getSwingSound(), player:getCurrentSquare(), 0.5, range, 1.0,
					false)
			end

			player:NPCSetAttack(false)
			player:NPCSetMelee(false)
		elseif (player:isLocalPlayer()) and weapon:isRanged() then
			SSM:GunShotHandle(SS)
		end
	end
end

Events.OnWeaponSwing.Add(SuperSurvivorsOnSwing)

--- Cows: "SurvivorOrder" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
--- Cows: This also seems to be redundant ... given the player can also order their group members from the SuperSurvivorWindow much faster and simpler.
---@param test any -- Cows: Even if it is unused this is apparently required for the function to work... otherwise the function simply returns nil.
---@param player any
---@param order any
---@param orderParam any
function SurvivorOrder(test, player, order, orderParam)
	local isLoggingSurvivorOrder = false;
	CreateLogLine("SuperSurvivorsMod", isLoggingSurvivorOrder, "function: SurvivorOrder() called");
	CreateLogLine("SuperSurvivorsMod", isLoggingSurvivorOrder, "player: " .. tostring(player));
	CreateLogLine("SuperSurvivorsMod", isLoggingSurvivorOrder, "order: " .. tostring(order));
	CreateLogLine("SuperSurvivorsMod", isLoggingSurvivorOrder, "orderParam: " .. tostring(orderParam));
	if (player ~= nil) then
		local ASuperSurvivor = SSM:Get(player:getModData().ID)
		local TaskMangerIn = ASuperSurvivor:getTaskManager()
		ASuperSurvivor:setAIMode(order)
		TaskMangerIn:setTaskUpdateLimit(0)

		ASuperSurvivor:setWalkingPermitted(true)
		TaskMangerIn:clear();

		local followtask = TaskMangerIn:getTaskFromName("Follow") --giving an outright order should remove follow so that "needToFollow" function will not detect a follow task and calc followdistance >

		if (followtask) then
			followtask:ForceComplete();
		end

		if (order == "Loot Room") and (orderParam ~= nil) then
			TaskMangerIn:AddToTop(LootCategoryTask:new(ASuperSurvivor, ASuperSurvivor:getBuilding(), orderParam, 0))
		elseif (order == "Follow") then
			ASuperSurvivor:setAIMode("Follow")
			ASuperSurvivor:setGroupRole("Follow")
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Companion"))
			TaskMangerIn:AddToTop(FollowTask:new(ASuperSurvivor, getSpecificPlayer(0)))
			ASuperSurvivor:setAIMode("Follow")
		elseif (order == "Pile Corpses") then
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Dustman"))
			local dropSquare = getSpecificPlayer(0):getCurrentSquare()
			local storagearea = ASuperSurvivor:getGroup():getGroupArea("CorpseStorageArea")
			if (storagearea[1] ~= 0) then
				dropSquare = GetCenterSquareFromArea(storagearea[1], storagearea[2], storagearea[3], storagearea[4],
					storagearea[5])
			end
			TaskMangerIn:AddToTop(PileCorpsesTask:new(ASuperSurvivor, dropSquare))
		elseif (order == "Guard") then
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Guard"))
			local area = ASuperSurvivor:getGroup():getGroupArea("GuardArea")
			if (area) then
				ASuperSurvivor:Speak(Get_SS_ContextMenuText("IGoGuard"))
				TaskMangerIn:AddToTop(WanderInAreaTask:new(ASuperSurvivor, area))
				TaskMangerIn:setTaskUpdateLimit(300) -- WIP - Cows: the value used to be "AutoWorkTaskTimeLimit", which was undefined locally... found "AutoWorkTaskTimeLimit" in AI-Manager.lua, defaults to 300... so 300 will be assigned here
				TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, GetRandomAreaSquare(area)))
				ASuperSurvivor:Speak("And Where are you wanting me to guard at again? Show me an area to guard at.")
			else
				TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, getSpecificPlayer(0):getCurrentSquare()))
			end
		elseif (order == "Patrol") then
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Sheriff"))
			TaskMangerIn:AddToTop(PatrolTask:new(ASuperSurvivor, getSpecificPlayer(0):getCurrentSquare(),
				ASuperSurvivor:Get():getCurrentSquare()))
		elseif (order == "Return To Base") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end -- To prevent follower companion tasks overwrite
			TaskMangerIn:AddToTop(ReturnToBaseTask:new(ASuperSurvivor))
		elseif (order == "Explore") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			TaskMangerIn:AddToTop(WanderTask:new(ASuperSurvivor))
		elseif (order == "Stop") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
		elseif (order == "Relax") and (ASuperSurvivor:getBuilding() ~= nil) then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(ASuperSurvivor, ASuperSurvivor:getBuilding()))
		elseif (order == "Relax") and (ASuperSurvivor:getBuilding() == nil) then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(ASuperSurvivor, nil))
			TaskMangerIn:AddToTop(FindBuildingTask:new(ASuperSurvivor))
		elseif (order == "Barricade") then
			TaskMangerIn:AddToTop(BarricadeBuildingTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
		elseif (order == "Stand Ground") then
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Guard"))
			TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, getSpecificPlayer(0):getCurrentSquare()))
			ASuperSurvivor:setWalkingPermitted(false)
		elseif (order == "Forage") then
			TaskMangerIn:AddToTop(ForageTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Junkman"))
		elseif (order == "Farming") then
			if (true) then --if(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Farming")) >= 3) then
				TaskMangerIn:AddToTop(FarmingTask:new(ASuperSurvivor))
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Farmer"))
			else
				ASuperSurvivor:Speak(Get_SS_UIActionText("IDontKnowHowFarming"))
			end
		elseif (order == "Chop Wood") then
			TaskMangerIn:AddToTop(ChopWoodTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Timberjack"))
		elseif (order == "Gather Wood") then
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Hauler"))
			local dropSquare = getSpecificPlayer(0):getCurrentSquare()
			local woodstoragearea = ASuperSurvivor:getGroup():getGroupArea("WoodStorageArea")
			if (woodstoragearea[1] ~= 0) then
				dropSquare = GetCenterSquareFromArea(woodstoragearea[1], woodstoragearea
					[2], woodstoragearea[3], woodstoragearea[4], woodstoragearea[5])
			end
			TaskMangerIn:AddToTop(GatherWoodTask:new(ASuperSurvivor, dropSquare))
		elseif (order == "Lock Doors") then
			TaskMangerIn:AddToTop(LockDoorsTask:new(ASuperSurvivor, true))
		elseif (order == "Sort Loot Into Base") then
			TaskMangerIn:AddToTop(SortLootTask:new(ASuperSurvivor, false))
		elseif (order == "Dismiss") then
			ASuperSurvivor:setAIMode("Random Solo")
			local group = SSGM:GetGroupById(ASuperSurvivor:getGroupID())
			if (group) then
				group:removeMember(ASuperSurvivor:getID())
			end

			ASuperSurvivor:getTaskManager():clear()
			if (ZombRand(3) == 0) then
				ASuperSurvivor:setHostile(true)
				ASuperSurvivor:Speak(Get_SS_DialogueSpeech("HowDareYou"))
			else
				ASuperSurvivor:Speak(Get_SS_DialogueSpeech("IfYouThinkSo"))
			end
		elseif (order == "Go Find Food") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Food", "Category", 1))
		elseif (order == "Go Find Weapon") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Weapon", "Category", 1))
		elseif (order == "Go Find Water") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Water", "Category", 1))
		elseif (order == "Clean Up Inventory") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(Get_SS_JobText("Worker"))
			end
			local group = ASuperSurvivor:getGroup()
			if (group) then
				-- check containers in square
				local containerobj = group:getGroupAreaContainer("FoodStorageArea")
				TaskMangerIn:AddToTop(CleanInvTask:new(ASuperSurvivor, containerobj, false))
			end
		elseif (order == "Doctor")
			and (ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Doctor")) >= 1
				or ASuperSurvivor:Get():getPerkLevel(Perks.FromString("First Aid")) >= 1)
		then
			TaskMangerIn:AddToTop(DoctorTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(Get_SS_JobText("Doctor"))
		elseif (order == "Doctor") then
			ASuperSurvivor:Speak(Get_SS_DialogueSpeech("IDontKnowHowDoctor"))
		end

		ASuperSurvivor:Speak(Get_SS_DialogueSpeech("Roger"))
		CreateLogLine("SuperSurvivorsMod", isLoggingSurvivorOrder, "Order Name: " .. tostring(OrderDisplayName[order]));
		getSpecificPlayer(0):Say(
			tostring(ASuperSurvivor:getName()) ..
			", " .. OrderDisplayName[order]
		);
	end
end

---comment
---@param player any
---@param weapon any
---@return boolean
function SuperSurvivorsOnEquipPrimary(player, weapon)
	if (player:isLocalPlayer() == false) then
		local ID = player:getModData().ID
		local SS = SSM:Get(ID)
		if (SS == nil) then return false end
		SS.UsingFullAuto = false

		if (weapon ~= nil) and (instanceof(weapon, "HandWeapon")) then
			-- WIP - Cows: Not sure why the attack range had to be nerfed by 60% here... commented out for now
			SS.AttackRange = ((player:getPrimaryHandItem():getMaxRange() + player:getPrimaryHandItem():getMinRange())); -- * 0.60);

			if (weapon:isAimedFirearm()) then
				local ammotypes = GetAmmoBullets(weapon);

				if (ammotypes ~= nil) and (ID ~= nil) then
					SS.AmmoTypes = ammotypes
					player:getModData().ammotype = ""
					player:getModData().ammoBoxtype = ""
					for i = 1, #SS.AmmoTypes do
						SS.AmmoBoxTypes[i] = GetAmmoBox(SS.AmmoTypes[i])
						player:getModData().ammotype = player:getModData().ammotype .. " " .. SS.AmmoTypes[i]
						player:getModData().ammoBoxtype = player:getModData().ammoBoxtype .. " " .. SS.AmmoBoxTypes[i]
					end

					SS.LastGunUsed = weapon;
				end
			end
		end
	end
end

Events.OnEquipPrimary.Add(SuperSurvivorsOnEquipPrimary);

