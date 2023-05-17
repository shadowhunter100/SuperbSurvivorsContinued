---@diagnostic disable: need-check-nil
require "00_SuperbSurviorModVariables/SuperSurvivorsOrders";
require "00_SuperbSurviorModVariables/SuperSurvivorWeaponsList";
require "05_Other/SuperSurvivorManager";

-- WIP - Cows: ... what was the plan for this "OnTickTicks"? and what "other mods" may call it?
-- To-Do: Change OnTickTicks to NPC_SSM_OnTicks , reason is , I don't know if other mods may try to call that variable.
local isLocalLoggingEnabled = false;

-- Check if SSM is loaded and game speed isn't on pause before updating the Survivors routines.
function SuperSurvivorsOnTick()
	if SSM ~= nil and getGameSpeed() ~= 0 then
		SSM:UpdateSurvivorsRoutine();
	end
end

Events.OnRenderTick.Add(SuperSurvivorsOnTick);

-- WIP - Cows: Ticks are calculated very inconsistently... 1 in-game minute is about 2 seconds IRL time
-- The data is also saved when the user presses the "Esc" key under SuperSurvivorKeyBindAction()... so is this even needed?
function SuperSurvivorsSaveData()
	local isLocalFunctionLoggingEnabled = false;
	CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "function: SuperSurvivorsSaveData() called");
	CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "Saving...");
	SSM:SaveAll();
	SSGM:Save();
	SaveSurvivorMap();
	local isSaveFunctionLoggingEnabled = false;
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "Logging groups...");
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled,
		"Groups Count: " .. tostring(SSGM.GroupCount));
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, tostring(SSGM.Groups));
	LogTableKVPairs("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, SSGM.Groups);
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "--- LINE BREAK ---");
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "Logging Survivors...");
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled,
		"Survivors Count:" .. tostring(SSM.SurvivorCount));
	CreateLogLine("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, "Survivors:" .. tostring(SSM.SuperSurvivors));
	LogTableKVPairs("SuperSurvivorsMod", isSaveFunctionLoggingEnabled, SSM.SuperSurvivors);
end

Events.OnPostSave.Add(SuperSurvivorsSaveData);

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorRandomSpawn(square)
	local hoursSurvived = math.floor(getGameTime():getWorldAgeHours())
	local ASuperSurvivor = SSM:spawnSurvivor(nil, square)

	-- WIP - Cows: Why was chance to be hostile called and calculated twice...? and why divide by 48?
	local FinalChanceToBeHostile = HostileSpawnRateBase + math.floor(hoursSurvived / 48);

	if (FinalChanceToBeHostile > HostileSpawnRateMax) and (HostileSpawnRateBase < HostileSpawnRateMax) then
		FinalChanceToBeHostile = HostileSpawnRateMax;
	end

	if (ASuperSurvivor ~= nil) then
		if (ZombRand(0, 100) < (WepSpawnRateGun + math.floor(hoursSurvived / 48))) then
			ASuperSurvivor:giveWeapon(SS_RangeWeapons[ZombRand(1, #SS_RangeWeapons)], true);
			-- make sure they have at least some ability to use the gun
			ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
			ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
		elseif (ZombRand(0, 100) < (WepSpawnRateMelee + math.floor(hoursSurvived / 48))) then
			ASuperSurvivor:giveWeapon(SS_MeleeWeapons[ZombRand(1, #SS_MeleeWeapons)], true)
		end
		if (ZombRand(0, 100) < FinalChanceToBeHostile) then ASuperSurvivor:setHostile(true) end
	end

	-- clear the immediate area
	local zlist = getCell():getZombieList();
	if (zlist ~= nil) then
		for i = zlist:size() - 1, 0, -1 do
			local z = zlist:get(i);

			if z ~= nil and (math.abs(z:getX() - square:getX()) < 2) and (math.abs(z:getY() - square:getY()) < 2) and (z:getZ() == square:getZ()) then
				z:removeFromWorld();
			end
		end
	end

	return ASuperSurvivor;
end

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

		-- WIP - Cows: Need to rework the spawning functions and logic...
		if (square:getModData().SurvivorSquareLoaded == nil)
			and (square:getZ() == 0 or square:isOutside() == false)
			and (not SuperSurvivorPresetSpawn(square))
		then
			SurvivorMap[key] = {}
			square:getModData().SurvivorSquareLoaded = true
			local hoursSurvived = math.floor(getGameTime():getWorldAgeHours());

			if (BaseNpcSpawnChance ~= 0)
				and (ZombRand(BaseNpcSpawnChance + hoursSurvived) == 0) -- WIP - Cows: How does this work? Random number between spawnrate plus hours survived?
				and (square:getZoneType() == "TownZone")
				and (not square:isSolid())
			then
				-- NON ALT SPAWNING GROUPS
				if (ZombRand(15) == 0) then -- spawn group
					local hours = getGameTime():getWorldAgeHours()
					local RaiderGroup = SSGM:newGroup()

					if (RaiderGroup:getID() == getSpecificPlayer(0):getModData().Group) then
						RaiderGroup = SSGM:newGroup()
					end

					local GroupSize = ZombRand(2, 5) + math.floor(hours / (24 * 30))
					if (GroupSize > Max_Group_Size) then
						GroupSize = Max_Group_Size
					elseif (GroupSize < Min_Group_Size) then
						GroupSize = Min_Group_Size
					end
					local groupHostility
					local Leader

					for i = 1, GroupSize do
						local raider = SuperSurvivorRandomSpawn(square);
						if (i == 1) then
							RaiderGroup:addMember(raider, "Leader")
							groupHostility = raider.player:getModData().isHostile
							Leader = raider
						else
							RaiderGroup:addMember(raider, "Guard")
							raider:setHostile(groupHostility)
							raider:getTaskManager():AddToTop(FollowTask:new(raider, Leader:Get()))
						end

						if (raider:hasWeapon() == false) then
							raider:giveWeapon(SS_MeleeWeapons[ZombRand(1, #SS_MeleeWeapons)]);
						end
					end
				else
					SuperSurvivorRandomSpawn(square)
				end
			end
		end
	end
end

Events.LoadGridsquare.Add(SuperSurvivorsLoadGridsquare);

function SuperSurvivorsInit()
	GroupWindowCreate();
	SurvivorsCreatePVPButton();
	SurvivorTogglePVP();

	if (IsoPlayer.getCoopPVP() == true
			or IsPVPEnabled == true) then
		SurvivorTogglePVP()
	end

	local player = getSpecificPlayer(0)
	player:getModData().isHostile = false
	player:getModData().ID = 0

	if (player:getX() >= 7679 and player:getX() <= 7680) and (player:getY() >= 11937 and player:getY() <= 11938) then -- if spawn in prizon
		local keyid = player:getBuilding():getDef():getKeyId();

		if (keyid) then
			local key = player:getInventory():AddItem("Base.Key1");
			key:setKeyId(keyid);
			player:getCurrentSquare():getE():AddWorldInventoryItem(key, 0.5, 0.5, 0);
			player:getInventory():Remove(key);
		end

		local DeadGuardSquare = getCell():getGridSquare(7685, 11937, 1);

		if (DeadGuardSquare ~= nil) then
			local SuperSurvivorDeadGuard = SSM:spawnSurvivor(false, DeadGuardSquare);
			local DeadGuard = SuperSurvivorDeadGuard.player
			SuperSurvivorDeadGuard:giveWeapon("Base.Pistol");

			DeadGuard:Kill(nil);
		end
	end
end

Events.OnGameStart.Add(SuperSurvivorsInit)

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

-- WIP - Cows: getContextMenuText() is a globl function... should consider updating the casing to reflect that.
function getContextMenuText(text)
	return getText("ContextMenu_SS_" .. text)
end

--[[
	"GetJobText" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
	and specifications are clearly defined and set.
--]]
function GetJobText(text)
	return getContextMenuText("Job_" .. text)
end

--- Cows: "SurvivorOrder" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
--- Cows: This also seems to be redundant ... given the player can also order their group members from the SuperSurvivorWindow much faster and simpler.
---@param test any
---@param player any
---@param order any
---@param orderParam any
function SurvivorOrder(test, player, order, orderParam)
	local isLoggingSurvivorOrder = true;
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
			ASuperSurvivor:setGroupRole(GetJobText("Companion"))
			TaskMangerIn:AddToTop(FollowTask:new(ASuperSurvivor, getSpecificPlayer(0)))
			ASuperSurvivor:setAIMode("Follow")
		elseif (order == "Pile Corpses") then
			ASuperSurvivor:setGroupRole(GetJobText("Dustman"))
			local dropSquare = getSpecificPlayer(0):getCurrentSquare()
			local storagearea = ASuperSurvivor:getGroup():getGroupArea("CorpseStorageArea")
			if (storagearea[1] ~= 0) then
				dropSquare = GetCenterSquareFromArea(storagearea[1], storagearea[2], storagearea[3], storagearea[4],
					storagearea[5])
			end
			TaskMangerIn:AddToTop(PileCorpsesTask:new(ASuperSurvivor, dropSquare))
		elseif (order == "Guard") then
			ASuperSurvivor:setGroupRole(GetJobText("Guard"))
			local area = ASuperSurvivor:getGroup():getGroupArea("GuardArea")
			if (area) then
				ASuperSurvivor:Speak(getContextMenuText("IGoGuard"))
				TaskMangerIn:AddToTop(WanderInAreaTask:new(ASuperSurvivor, area))
				TaskMangerIn:setTaskUpdateLimit(300) -- WIP - Cows: the value used to be "AutoWorkTaskTimeLimit", which was undefined locally... found "AutoWorkTaskTimeLimit" in AI-Manager.lua, defaults to 300... so 300 will be assigned here
				TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, GetRandomAreaSquare(area)))
				ASuperSurvivor:Speak("And Where are you wanting me to guard at again? Show me an area to guard at.")
			else
				TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, getSpecificPlayer(0):getCurrentSquare()))
			end
		elseif (order == "Patrol") then
			ASuperSurvivor:setGroupRole(GetJobText("Sheriff"))
			TaskMangerIn:AddToTop(PatrolTask:new(ASuperSurvivor, getSpecificPlayer(0):getCurrentSquare(),
				ASuperSurvivor:Get():getCurrentSquare()))
		elseif (order == "Return To Base") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end -- To prevent follower companion tasks overwrite
			TaskMangerIn:AddToTop(ReturnToBaseTask:new(ASuperSurvivor))
		elseif (order == "Explore") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:AddToTop(WanderTask:new(ASuperSurvivor))
		elseif (order == "Stop") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
		elseif (order == "Relax") and (ASuperSurvivor:getBuilding() ~= nil) then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(ASuperSurvivor, ASuperSurvivor:getBuilding()))
		elseif (order == "Relax") and (ASuperSurvivor:getBuilding() == nil) then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(ASuperSurvivor, nil))
			TaskMangerIn:AddToTop(FindBuildingTask:new(ASuperSurvivor))
		elseif (order == "Barricade") then
			TaskMangerIn:AddToTop(BarricadeBuildingTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(GetJobText("Worker"))
		elseif (order == "Stand Ground") then
			ASuperSurvivor:setGroupRole(GetJobText("Guard"))
			TaskMangerIn:AddToTop(GuardTask:new(ASuperSurvivor, getSpecificPlayer(0):getCurrentSquare()))
			ASuperSurvivor:setWalkingPermitted(false)
		elseif (order == "Forage") then
			TaskMangerIn:AddToTop(ForageTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(GetJobText("Junkman"))
		elseif (order == "Farming") then
			if (true) then --if(ASuperSurvivor:Get():getPerkLevel(Perks.FromString("Farming")) >= 3) then
				TaskMangerIn:AddToTop(FarmingTask:new(ASuperSurvivor))
				ASuperSurvivor:setGroupRole(GetJobText("Farmer"))
			else
				ASuperSurvivor:Speak(getActionText("IDontKnowHowFarming"))
			end
		elseif (order == "Chop Wood") then
			TaskMangerIn:AddToTop(ChopWoodTask:new(ASuperSurvivor))
			ASuperSurvivor:setGroupRole(GetJobText("Timberjack"))
		elseif (order == "Gather Wood") then
			ASuperSurvivor:setGroupRole(GetJobText("Hauler"))
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
			local group = SSGM:Get(ASuperSurvivor:getGroupID())
			if (group) then
				group:removeMember(ASuperSurvivor:getID())
			end

			ASuperSurvivor:getTaskManager():clear()
			if (ZombRand(3) == 0) then
				ASuperSurvivor:setHostile(true)
				ASuperSurvivor:Speak(GetDialogueSpeech("HowDareYou"))
			else
				ASuperSurvivor:Speak(GetDialogueSpeech("IfYouThinkSo"))
			end
		elseif (order == "Go Find Food") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Food", "Category", 1))
		elseif (order == "Go Find Weapon") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Weapon", "Category", 1))
		elseif (order == "Go Find Water") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:AddToTop(FindThisTask:new(ASuperSurvivor, "Water", "Category", 1))
		elseif (order == "Clean Up Inventory") then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
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
			ASuperSurvivor:setGroupRole(GetJobText("Doctor"))
		elseif (order == "Doctor") then
			ASuperSurvivor:Speak(GetDialogueSpeech("IDontKnowHowDoctor"))
		end

		ASuperSurvivor:Speak(GetDialogueSpeech("Roger"))
		CreateLogLine("SuperSurvivorsMod", isLoggingSurvivorOrder, "Order Name: " .. tostring(OrderDisplayName[order]));
		getSpecificPlayer(0):Say(
			tostring(ASuperSurvivor:getName()) ..
			", " .. OrderDisplayName[order]
		);
	end
end

-- WIP - Cows: This was made so the 4 arrow keys can be used to call the assigned orders in SuperSurvivorKeyBindAction() ...
local function superSurvivorsHotKeyOrder(index)
	local order, isListening
	if (index <= #Orders) then
		order = Orders[index]
		isListening = false
	else --single
		order = Orders[(index - #Orders)]
		isListening = true
	end
	local myGroup = SSM:Get(0):getGroup()
	if (myGroup) then
		local myMembers = myGroup:getMembersInRange(SSM:Get(0):Get(), 25, isListening)
		for i = 1, #myMembers do
			SurvivorOrder(nil, myMembers[i].player, order, nil)
		end
	end
end

-- WIP - Cows: Renamed from "supersurvivortemp()" to "SuperSurvivorKeyBindAction()"
function SuperSurvivorKeyBindAction(keyNum)
	CreateLogLine("SuperSurvivorsMod", isLocalLoggingEnabled, "function: SuperSurvivorKeyBindAction called");
	local playerSurvivor = getSpecificPlayer(0);

	if (playerSurvivor) then
		-- playerSurvivor:Say(tostring(keyNum));

		if (keyNum == getCore():getKey("Spawn Wild Survivor")) then -- the NumPad enter key
			local ss = SuperSurvivorRandomSpawn(playerSurvivor:getCurrentSquare());
		elseif (keyNum == getCore():getKey("Raise Follow Distance")) then
			if (GFollowDistance < 50) then
				GFollowDistance = GFollowDistance + 1;
			end
			playerSurvivor:Say("Spread out more(" .. tostring(GFollowDistance) .. ")");
		elseif (keyNum == getCore():getKey("Lower Follow Distance")) then
			if (GFollowDistance > 0) then
				GFollowDistance = GFollowDistance - 1;
			end
			playerSurvivor:Say("Stay closer(" .. tostring(GFollowDistance) .. ")");
		elseif (keyNum == getCore():getKey("Call Closest Non-Group Member")) then
			local mySS = SSM:Get(0)

			local SS = SSM:GetClosestNonParty()
			if (SS) then
				mySS:Speak(GetDialogue("HeyYou"))
				SS:getTaskManager():AddToTop(ListenTask:new(SS, mySS:Get(), false))
			end
		elseif (keyNum == getCore():getKey("Toggle Group Window")) then
			window_super_survivors_visibility()
		elseif (keyNum == getCore():getKey("Ask Closest Group Member to Follow")) then
			local mySS = SSM:Get(0)
			if (mySS:getGroupID() ~= nil) then
				local myGroup = SSGM:Get(mySS:getGroupID())
				if (myGroup ~= nil) then
					local member = myGroup:getClosestMember(nil, mySS:Get())
					if (member) then
						mySS:Get():Say(getActionText("ComeWithMe_Before") ..
							member:Get():getForname() .. getActionText("ComeWithMe_After"))
						member:getTaskManager():clear()
						member:getTaskManager():AddToTop(FollowTask:new(member, mySS:Get()))
					else
						CreateLogLine("SuperSurvivorsMod", isLocalLoggingEnabled, "getClosestMember returned nil");
					end
				else
					CreateLogLine("SuperSurvivorsMod", isLocalLoggingEnabled, "no group for player found");
				end
			end
		elseif (keyNum == getCore():getKey("Call Closest Group Member")) then -- t key
			local mySS = SSM:Get(0)
			if (mySS:getGroupID() ~= nil) then
				local myGroup = SSGM:Get(mySS:getGroupID())
				if (myGroup ~= nil) then
					local member = myGroup:getClosestMember(nil, mySS:Get())
					if (member) then
						mySS:Get():Say(member:Get():getForname() .. ", come here.")
						member:getTaskManager():AddToTop(ListenTask:new(member, mySS:Get(), false))
					else
						CreateLogLine("SuperSurvivorsMod", isLocalLoggingEnabled, "getClosestMember returned nil");
					end
				else
					CreateLogLine("SuperSurvivorsMod", isLocalLoggingEnabled, "no group for player found");
				end
			end
		elseif (keyNum == getCore():getKey("SSHotkey_1")) then -- Up key, Order "Follow"
			superSurvivorsHotKeyOrder(6);
		elseif (keyNum == getCore():getKey("SSHotkey_2")) then -- Down key, Order "Stop"
			superSurvivorsHotKeyOrder(20);
		elseif (keyNum == getCore():getKey("SSHotkey_3")) then -- Left key, Order "Stand Ground"
			superSurvivorsHotKeyOrder(19);
		elseif (keyNum == getCore():getKey("SSHotkey_4")) then -- Right key, Order "Barricade"
			superSurvivorsHotKeyOrder(1);
		elseif (keyNum == getCore():getKey("NumPad_5")) then
			LogSSDebugInfo();
		end
	end
end

Events.OnKeyPressed.Add(SuperSurvivorKeyBindAction);

function SuperSurvivorsOnEquipPrimary(player, weapon)
	if (player:isLocalPlayer() == false) then
		local ID = player:getModData().ID
		local SS = SSM:Get(ID)
		if (SS == nil) then return false end
		SS.UsingFullAuto = false

		if (weapon ~= nil) and (instanceof(weapon, "HandWeapon")) then
			SS.AttackRange = ((player:getPrimaryHandItem():getMaxRange() + player:getPrimaryHandItem():getMinRange()) * 0.60)

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

-- ALT SPAWNING
-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorsNewSurvivorManager()
	local hoursSurvived = math.floor(getGameTime():getWorldAgeHours())
	local FinalChanceToBeHostile = HostileSpawnRateBase + math.floor(hoursSurvived / 48);

	if (FinalChanceToBeHostile > HostileSpawnRateMax)
		and (HostileSpawnRateBase < HostileSpawnRateMax)
	then
		FinalChanceToBeHostile = HostileSpawnRateMax;
	end

	if (getSpecificPlayer(0) == nil) then return false end
	--this unrelated to raiders but need this to run every once in a while
	-- WIP - Cows: WHY DOES THIS NEED TO RUN?
	getSpecificPlayer(0):getModData().hitByCharacter = false
	getSpecificPlayer(0):getModData().semiHostile = false
	getSpecificPlayer(0):getModData().dealBreaker = nil

	if (getSpecificPlayer(0):isAsleep()) then
		SSM:AsleepHealAll()
	end

	local mySS = SSM:Get(0)
	local hisGroup = mySS:getGroup()

	if (hisGroup == nil) then return false end

	local bounds = hisGroup:getBounds()
	local center
	if (bounds) then center = GetCenterSquareFromArea(bounds[1], bounds[2], bounds[3], bounds[4], bounds[5]) end
	if not center then center = getSpecificPlayer(0):getCurrentSquare() end

	local spawnSquare

	local success = false
	local range = 45
	local drange = range * 2

	for i = 1, 10 do
		local spawnLocation = ZombRand(4);
		local x, y; -- WIP - Cows: x, y are not used anywhere else... keep it local for each iteration.
		if (spawnLocation == 0) then
			--mySS:Speak("spawn from north")
			x = center:getX() + (ZombRand(drange) - range);
			y = center:getY() - range;
		elseif (spawnLocation == 1) then
			--mySS:Speak("spawn from east")
			x = center:getX() + range;
			y = center:getY() + (ZombRand(drange) - range);
		elseif (spawnLocation == 2) then
			--mySS:Speak("spawn from south")
			x = center:getX() + (ZombRand(drange) - range);
			y = center:getY() + range;
		elseif (spawnLocation == 3) then
			--mySS:Speak("spawn from west")
			x = center:getX() - range;
			y = center:getY() + (ZombRand(drange) - range);
		end

		spawnSquare = getCell():getGridSquare(x, y, 0)

		if (spawnSquare ~= nil)
			and (not hisGroup:IsInBounds(spawnSquare))
			and spawnSquare:isOutside()
			and (not spawnSquare:IsOnScreen())
			and (not spawnSquare:isSolid())
			and (spawnSquare:isSolidFloor())
		then
			success = true
			break
		end
	end


	-- WIP - Cows: Need to rework the spawning functions and logic...
	if (success) and (spawnSquare) then
		-- ALT SPAWNING SECTION --
		-- SURVIVOR, NON RAIDER SPAWNING
		-- WIP - Cows: Then why the hell are survivors called Raiders? Need to rename those for context...
		local RaiderGroup = SSGM:newGroup()
		local GroupSize = ZombRand(1, AltSpawnGroupSize)

		if (GroupSize > AltSpawnGroupSize) then
			GroupSize = AltSpawnGroupSize
		elseif (GroupSize < Min_Group_Size) then
			GroupSize = Min_Group_Size
		end

		for i = 1, GroupSize do
			local raider = SuperSurvivorRandomSpawn(spawnSquare)
			--if(i == 1) then RaiderGroup:addMember(raider,"Leader")
			--else RaiderGroup:addMember(raider,"Guard") end

			-- Updated so alt spawns can decide to be hostile or not.
			if (ZombRand(0, 100) < FinalChanceToBeHostile) then
				raider:setHostile(true)
			else
				raider:setHostile(false)
			end

			-- raider:setHostile(false)
			raider.player:getModData().isRobber = false
			local name = raider:getName()
			-- raider:setName("Raider "..name)
			raider:setName("Survivor " .. name)
			raider:getTaskManager():AddToTop(WanderTask:new(raider))
			if (raider:hasWeapon() == false) then raider:giveWeapon(SS_MeleeWeapons[ZombRand(1, #SS_MeleeWeapons)]) end

			local food, bag
			bag = raider:getBag()
			local count = ZombRand(0, 3)
			for i = 1, count do
				food = "Base." .. tostring(CannedFoods[ZombRand(#CannedFoods) + 1])
				bag:AddItem(food)
			end
			local count = ZombRand(0, 3)
			for i = 1, count do
				food = "Base.TinnedBeans"
				bag:AddItem(food)
			end

			GetRandomSurvivorSuit(raider) -- WIP: Cows - Consider creating a preset outfit for raiders?
		end
		RaiderGroup:AllSpokeTo()
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorDoRandomSpawns()
	if (getSpecificPlayer(0) == nil) then return false end
	local isLocalFunctionLoggingEnabled = false;
	CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "function: SuperSurvivorDoRandomSpawns() called");
	local spawnChanceVal = AlternativeSpawnChance;
	local isSpawning = (spawnChanceVal > ZombRand(0, 100)); -- spawn if spawnChanceVal is greater than the random roll between 0 and 100.

	if (isSpawning) then
		CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "spawning npc survivor...");
		SuperSurvivorsNewSurvivorManager();
	end
end

Events.EveryHours.Add(SuperSurvivorDoRandomSpawns);
-- Yes the variables have 'percent' in the name, that's because before this version, I had made alt spawning work different.
-- Do not be confused, the naming scheme means nothing here.

function SuperSurvivorsRaiderManager()
	local isLocalFunctionLoggingEnabled = false;
	if (getSpecificPlayer(0) == nil) then return false end
	--this unrelated to raiders but need this to run every once in a while
	getSpecificPlayer(0):getModData().hitByCharacter = false
	getSpecificPlayer(0):getModData().semiHostile = false
	getSpecificPlayer(0):getModData().dealBreaker = nil

	if (getSpecificPlayer(0):isAsleep()) then
		SSM:AsleepHealAll()
	end

	if (getSpecificPlayer(0):getModData().LastRaidTime == nil) then
		getSpecificPlayer(0):getModData().LastRaidTime = (RaidersStartAfterHours + 2);
	end

	local LastRaidTime = getSpecificPlayer(0):getModData().LastRaidTime;

	local mySS = SSM:Get(0);
	local hours = math.floor(getGameTime():getWorldAgeHours());
	local spawnChanceVal = RaidersSpawnChance;

	local RaidersStartTimePassed = (hours >= RaidersStartAfterHours);
	local RaiderAtLeastTimedExceeded = ((hours - LastRaidTime) >= RaidersSpawnFrequencyByHours);
	local RaiderResult = (spawnChanceVal > ZombRand(0, 100)); -- spawn if spawnChanceVal is greater than the random roll between 0 and 100.

	if RaidersStartTimePassed and (RaiderResult or RaiderAtLeastTimedExceeded) and mySS ~= nil then
		CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "spawning raiders...");
		local hisGroup = mySS:getGroup()

		if (hisGroup == nil) then return false end

		local bounds = hisGroup:getBounds()
		local center
		if (bounds) then center = GetCenterSquareFromArea(bounds[1], bounds[2], bounds[3], bounds[4], bounds[5]) end
		if not center then center = getSpecificPlayer(0):getCurrentSquare() end

		local spawnSquare

		local success = false
		local range = 45
		local drange = range * 2

		for i = 1, 10 do
			local spawnLocation = ZombRand(4);
			local x, y;
			if (spawnLocation == 0) then
				--mySS:Speak("spawn from north")
				x = center:getX() + (ZombRand(drange) - range);
				y = center:getY() - range;
			elseif (spawnLocation == 1) then
				--mySS:Speak("spawn from east")
				x = center:getX() + range;
				y = center:getY() + (ZombRand(drange) - range);
			elseif (spawnLocation == 2) then
				--mySS:Speak("spawn from south")
				x = center:getX() + (ZombRand(drange) - range);
				y = center:getY() + range;
			elseif (spawnLocation == 3) then
				--mySS:Speak("spawn from west")
				x = center:getX() - range;
				y = center:getY() + (ZombRand(drange) - range);
			end

			spawnSquare = getCell():getGridSquare(x, y, 0)

			if (spawnSquare ~= nil) and (not hisGroup:IsInBounds(spawnSquare)) and spawnSquare:isOutside() and (not spawnSquare:IsOnScreen()) and (not spawnSquare:isSolid()) and (spawnSquare:isSolidFloor()) then
				success = true
				break
			end
		end

		-- WIP - Cows: Need to rework the spawning functions and logic...
		if (success) and (spawnSquare) then
			getSpecificPlayer(0):getModData().LastRaidTime = hours
			if (getSpecificPlayer(0):isAsleep()) then
				getSpecificPlayer(0):Say(GetDialogue("IGotABadFeeling"))
				getSpecificPlayer(0):forceAwake()
			else
				getSpecificPlayer(0):Say(GetDialogue("WhatWasThatSound"));
			end
			-- RAIDER GROUPS
			local RaiderGroup = SSGM:newGroup()
			local GroupSize = ZombRand(1, hisGroup:getMemberCount()) + math.floor(hours / (24 * 30))
			if (GroupSize > 10) then
				GroupSize = 10
			elseif (GroupSize < 2) then
				GroupSize = 2
			end

			for i = 1, GroupSize do
				-- WIP - Cows: why is "raider" a global variable? it wasn't even initiated previously...
				local raider = SuperSurvivorRandomSpawn(spawnSquare)
				if (i == 1) then
					RaiderGroup:addMember(raider, "Leader")
				else
					RaiderGroup:addMember(raider, "Guard")
				end
				raider:setHostile(true)
				raider.player:getModData().isRobber = true
				local name = raider:getName()
				raider:setName("Raider " .. name)
				raider:getTaskManager():AddToTop(PursueTask:new(raider, mySS:Get()))
				if (raider:hasWeapon() == false) then raider:giveWeapon(SS_MeleeWeapons[ZombRand(1, #SS_MeleeWeapons)]) end

				local food, bag
				bag = raider:getBag()
				local count = ZombRand(0, 3)
				for i = 1, count do
					food = "Base.CannedCorn"
					bag:AddItem(food)
				end
				local count = ZombRand(0, 3)
				for i = 1, count do
					food = "Base.Apple"
					bag:AddItem(food)
				end

				local number = ZombRand(1, 3)
				SetRandomSurvivorSuit(raider, "Rare", "Bandit" .. tostring(number))
			end

			RaiderGroup:AllSpokeTo()
		end
	end
end

Events.EveryTenMinutes.Add(SuperSurvivorsRaiderManager);
NumberOfLocalPlayers = 0;

function SSCreatePlayerHandle(newplayerID)
	local newplayer = getSpecificPlayer(newplayerID)
	local MD = newplayer:getModData()

	if (not MD.ID) and (newplayer:isLocalPlayer()) then
		SuperSurvivorPlayerInit(newplayer)

		if (getSpecificPlayer(0) and (not getSpecificPlayer(0):isDead()) and (getSpecificPlayer(0) ~= newplayer)) then
			local MainSS = SSM:Get(0);
			local MainSSGroup = MainSS:getGroup()
			NumberOfLocalPlayers = NumberOfLocalPlayers + 1
			local newSS = SSM:setPlayer(newplayer, NumberOfLocalPlayers)
			newSS:setID(NumberOfLocalPlayers)
			MainSSGroup:addMember(newSS, "Guard");
		end
	end
end

Events.OnCreatePlayer.Add(SSCreatePlayerHandle)
