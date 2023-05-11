require "00_SuperbSurviorModVariables.SuperSurvivorWeaponsList";
require "05_Other/SuperSurvivorManager";

-- WIP - Cows: ... what was the plan for this "OnTickTicks"? and what "other mods" may call it?
-- To-Do: Change OnTickTicks to NPC_SSM_OnTicks , reason is , I don't know if other mods may try to call that variable.
OnTickTicks = 0;
SuperSurvivorSelectAnArea = false;
SuperSurvivorMouseDownTicks = 0;

local isLocalLoggingEnabled = false;

function SuperSurvivorsOnTick()
	if (SuperSurvivorSelectAnArea) then
		if (Mouse.isLeftDown()) then
			SuperSurvivorMouseDownTicks = SuperSurvivorMouseDownTicks + 1
		else
			SuperSurvivorMouseDownTicks = 0
			SuperSurvivorSelectingArea = 0
		end

		if (SuperSurvivorMouseDownTicks > 15) then -- 10 acts instant, so a left click would reset the select area finalization.
			if (Highlightcenter == nil) or (not SuperSurvivorSelectingArea) then
				Highlightcenter = GetMouseSquare()
				HighlightX1 = GetMouseSquareX()
				HighlightX2 = GetMouseSquareX()
				HighlightY1 = GetMouseSquareY()
				HighlightY2 = GetMouseSquareY()
			end

			SuperSurvivorSelectingArea = true

			if (HighlightX1 == nil) or (HighlightX1 > GetMouseSquareX()) then HighlightX1 = GetMouseSquareX() end
			if (HighlightX2 == nil) or (HighlightX2 <= GetMouseSquareX()) then HighlightX2 = GetMouseSquareX() end
			if (HighlightY1 == nil) or (HighlightY1 > GetMouseSquareY()) then HighlightY1 = GetMouseSquareY() end
			if (HighlightY2 == nil) or (HighlightY2 <= GetMouseSquareY()) then HighlightY2 = GetMouseSquareY() end
		elseif (SuperSurvivorSelectingArea) then
			SuperSurvivorSelectingArea = false
		end

		if (Mouse.isLeftPressed()) then
			SuperSurvivorSelectAreaHOLD = false -- I did a folder scan, this var doesn't do anything?
			SuperSurvivorSelectingArea = false -- new
		end

		if (HighlightX1) and (HighlightX2) then
			local x1 = HighlightX1
			local x2 = HighlightX2
			local y1 = HighlightY1
			local y2 = HighlightY2

			for xx = x1, x2 do
				for yy = y1, y2 do
					local sq = getCell():getGridSquare(xx, yy, getSpecificPlayer(0):getZ())
					if (sq) and (sq:getFloor()) then sq:getFloor():setHighlighted(true) end
				end
			end
		end
	end

	if SSM ~= nil and getGameSpeed() ~= 0 then
		SSM:update()
		OnTickTicks = OnTickTicks + 1

		if (OnTickTicks % 1000 == 0) then
			SSGM:Save()
			SaveSurvivorMap()
		end
	end
end

Events.OnRenderTick.Add(SuperSurvivorsOnTick)

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorRandomSpawn(square)
	local hoursSurvived = math.floor(getGameTime():getWorldAgeHours())
	local ASuperSurvivor = SSM:spawnSurvivor(nil, square)

	local FinalChanceToBeHostile = ChanceToBeHostileNPC + math.floor(hoursSurvived / 48)
	if (FinalChanceToBeHostile > MaxChanceToBeHostileNPC) and (ChanceToBeHostileNPC < MaxChanceToBeHostileNPC) then
		FinalChanceToBeHostile = MaxChanceToBeHostileNPC;
	end

	if (ASuperSurvivor ~= nil) then
		if (ZombRand(100) < (ChanceToSpawnWithGun + math.floor(hoursSurvived / 48))) then
			ASuperSurvivor:giveWeapon(RangeWeapons[ZombRand(1, #RangeWeapons)], true);
			-- make sure they have at least some ability to use the gun
			ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
			ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
		elseif (ZombRand(100) < (ChanceToSpawnWithWep + math.floor(hoursSurvived / 48))) then
			ASuperSurvivor:giveWeapon(MeleWeapons[ZombRand(1, #MeleWeapons)], true)
		end
		if (ZombRand(100) < FinalChanceToBeHostile) then ASuperSurvivor:setHostile(true) end
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
			SSM:init()
			SSGM:Load()

			-- I don't think we need this now? But Further testing is needed
			-- WIP - Cows: IS IT SAFE TO REMOVE? AND WHICH ARE NOT SAFE TO REMOVE?
			local gameVersion = getCore():getGameVersion()
			IsDamageBroken = (gameVersion:getMajor() >= 41 and gameVersion:getMinor() > 50 and gameVersion:getMinor() < 53)
			IsNpcDamageBroken = (gameVersion:getMajor() >= 41 and gameVersion:getMinor() >= 53)

			if IsDamageBroken then
				MaxChanceToBeHostileNPC = 0
			end
			if IsDamageBroken then
				RaidsStartAfterThisManyHours = 9999999
			end

			if (DoesFileExist("SurvivorLocX")) then
				SurvivorMap = LoadSurvivorMap() -- matrix grid containing info on location of all survivors for re-spawning purposes
			else
				SurvivorMap = {}
				SurvivorLocX = {}
				SurvivorLocY = {}
				SurvivorLocZ = {}
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

			if (SuperSurvivorSpawnRate ~= 0)
				and (ZombRand(SuperSurvivorSpawnRate + hoursSurvived) == 0)
				and (square:getZoneType() == "TownZone")
				and (not square:isSolid())
			then
				-- NON ALT SPAWNING GROUPS
				if (ZombRand(15) == 0) then -- spawn group
					local hours = getGameTime():getWorldAgeHours()
					local RaiderGroup = SSGM:newGroup()
					if (RaiderGroup:getID() == getSpecificPlayer(0):getModData().Group) then RaiderGroup = SSGM:newGroup() end
					local GroupSize = ZombRand(2, 5) + math.floor(hours / (24 * 30))
					if (GroupSize > Max_Group_Size) then
						GroupSize = Max_Group_Size
					elseif (GroupSize < Min_Group_Size) then
						GroupSize = Min_Group_Size
					end
					local oldGunSpawnChance = ChanceToSpawnWithGun
					ChanceToSpawnWithGun = ChanceToSpawnWithGun --* 1.5
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
							raider:giveWeapon(MeleWeapons[ZombRand(1, #MeleWeapons)]);
						end
					end
					ChanceToSpawnWithGun = oldGunSpawnChance
				else
					SuperSurvivorRandomSpawn(square)
				end
			end
		end
	end
end

Events.LoadGridsquare.Add(SuperSurvivorsLoadGridsquare);

function SuperSurvivorsInit()
	GroupWindowCreate()

	SurvivorsCreatePVPButton()

	SurvivorTogglePVP()

	if (IsoPlayer.getCoopPVP() == true
			or Option_ForcePVP == 1) then
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

--[[
	"GetJobText" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
	and specifications are clearly defined and set.
--]]
function GetJobText(text)
	return getContextMenuText("Job_" .. text)
end

--[[
	"SurvivorOrder" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
	and specifications are clearly defined and set.
--]]
function SurvivorOrder(test, player, order, orderParam)
	if (player ~= nil) then
		local ASuperSurvivor = SSM:Get(player:getModData().ID)
		local TaskMangerIn = ASuperSurvivor:getTaskManager()
		ASuperSurvivor:setAIMode(order)
		TaskMangerIn:setTaskUpdateLimit(0)

		ASuperSurvivor:setWalkingPermitted(true)

		local followtask = TaskMangerIn:getTaskFromName("Follow") --giving an outright order should remove follow so that "needToFollow" function will not detect a follow task and calc followdistance >
		if (followtask) then followtask:ForceComplete() end

		if (order == "Loot Room") and (orderParam ~= nil) then
			TaskMangerIn:AddToTop(LootCategoryTask:new(ASuperSurvivor, ASuperSurvivor:getBuilding(), orderParam, 0))
		elseif (order == "Follow") then
			ASuperSurvivor:setAIMode("Follow")
			ASuperSurvivor:setGroupRole("Follow")
			TaskMangerIn:clear()
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
			TaskMangerIn:clear()
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
			TaskMangerIn:clear()
		elseif (order == "Relax") and (ASuperSurvivor:getBuilding() ~= nil) then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:clear()
			TaskMangerIn:AddToTop(WanderInBuildingTask:new(ASuperSurvivor, ASuperSurvivor:getBuilding()))
		elseif (order == "Relax") and (ASuperSurvivor:getBuilding() == nil) then
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Worker"))
			end
			TaskMangerIn:clear()
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
		elseif (order == "Hold Still") then
			TaskMangerIn:AddToTop(HoldStillTask:new(ASuperSurvivor, true))
			if (ASuperSurvivor:getGroupRole() == "Companion") then
				ASuperSurvivor:setGroupRole(GetJobText("Guard"))
			end
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
		getSpecificPlayer(0):Say(tostring(ASuperSurvivor:getName()) .. ", " .. OrderDisplayName[order]);
	end
end

function SuperSurvivorsHotKeyOrder(index)
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

		if (keyNum == getCore():getKey("Spawn Wild Survivor")) then -- the 6 key
			local ss = SuperSurvivorRandomSpawn(playerSurvivor:getCurrentSquare());
		elseif (keyNum == getCore():getKey("Raise Follow Distance")) then
			if (GFollowDistance ~= 50) then
				GFollowDistance = GFollowDistance + 1;
			end
			playerSurvivor:Say("Spread out more(" .. tostring(GFollowDistance) .. ")");
		elseif (keyNum == getCore():getKey("Lower Follow Distance")) then
			if (GFollowDistance ~= 0) then
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
		elseif (keyNum == 1) then -- esc key
			local isSaveFunctionLoggingEnabled = false;
			SSM:SaveAll();
			SSGM:Save();
			SaveSurvivorMap();
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
		elseif (keyNum == getCore():getKey("SSHotkey_1")) then -- Up key
			local index = SuperSurvivorGetOption("SSHotkey1")
			SuperSurvivorsHotKeyOrder(index)
		elseif (keyNum == getCore():getKey("SSHotkey_2")) then -- Down key
			local index = SuperSurvivorGetOption("SSHotkey2")
			SuperSurvivorsHotKeyOrder(index)
		elseif (keyNum == getCore():getKey("SSHotkey_3")) then -- Left key
			local index = SuperSurvivorGetOption("SSHotkey3")
			SuperSurvivorsHotKeyOrder(index)
		elseif (keyNum == getCore():getKey("SSHotkey_4")) then -- Right key
			local index = SuperSurvivorGetOption("SSHotkey4")
			SuperSurvivorsHotKeyOrder(index)
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
	-- To make sure if the player has chosen not to use Alt spawning
	if (AlternativeSpawning == 1) or (getSpecificPlayer(0):isAsleep()) then
		return false
	end

	local hoursSurvived = math.floor(getGameTime():getWorldAgeHours())
	local FinalChanceToBeHostile = ChanceToBeHostileNPC + math.floor(hoursSurvived / 48);

	if (FinalChanceToBeHostile > MaxChanceToBeHostileNPC)
		and (ChanceToBeHostileNPC < MaxChanceToBeHostileNPC)
	then
		FinalChanceToBeHostile = MaxChanceToBeHostileNPC;
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
		local spawnLocation = ZombRand(4)
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
		-- ALT SPAWNING SECTION --
		-- SURVIVOR, NON RAIDER SPAWNING
		local RaiderGroup = SSGM:newGroup()
		local GroupSize = ZombRand(1, AltSpawnGroupSize)

		if (GroupSize > AltSpawnGroupSize) then
			GroupSize = AltSpawnGroupSize
		elseif (GroupSize < Min_Group_Size) then
			GroupSize = Min_Group_Size
		end

		-- Since the options update 0-100 , this may need changing
		local oldGunSpawnChance = ChanceToSpawnWithGun
		ChanceToSpawnWithGun    = ChanceToSpawnWithGun --* 1.5

		for i = 1, GroupSize do
			local raider = SuperSurvivorRandomSpawn(spawnSquare)
			--if(i == 1) then RaiderGroup:addMember(raider,"Leader")
			--else RaiderGroup:addMember(raider,"Guard") end

			-- Updated so alt spawns can decide to be hostile or not.
			if (ZombRand(100) < FinalChanceToBeHostile) then
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
			if (raider:hasWeapon() == false) then raider:giveWeapon(MeleWeapons[ZombRand(1, #MeleWeapons)]) end

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

			GetRandomSurvivorSuit(raider) -- Even if it says 'raider' it's not giving raider outfits
		end
		ChanceToSpawnWithGun = oldGunSpawnChance
		RaiderGroup:AllSpokeTo()
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurSurvivorSpawnGenFivePercent()
	if (AlternativeSpawning == 2) then
		SuperSurvivorsNewSurvivorManager()
	else
		return false
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurSurvivorSpawnGenTenPercent()
	if (AlternativeSpawning == 3) then
		SuperSurvivorsNewSurvivorManager()
	else
		return false
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurSurvivorSpawnGenTwentyPercent()
	if (AlternativeSpawning == 4) then
		SuperSurvivorsNewSurvivorManager()
	else
		return false
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurSurvivorSpawnGenThirtyPercent()
	if (AlternativeSpawning == 5) then
		SuperSurvivorsNewSurvivorManager()
	else
		return false
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurSurvivorSpawnGenFourtyPercent()
	if (AlternativeSpawning == 6) then
		SuperSurvivorsNewSurvivorManager()
	else
		return false
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurSurvivorSpawnGenFiftyPercent()
	if (AlternativeSpawning == 7) then
		SuperSurvivorsNewSurvivorManager()
	else
		return false
	end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorDoRandomSpawns()
	local RealAlternativeSpawning = AlternativeSpawning - 1
	for i = RealAlternativeSpawning, 1, -1 do
		if (AltSpawnPercent > ZombRand(100)) and (AlternativeSpawning == 2) then
			SuperSurSurvivorSpawnGenFivePercent();
		end
		if (AltSpawnPercent > ZombRand(100)) and (AlternativeSpawning == 3) then
			SuperSurSurvivorSpawnGenTenPercent();
		end
		if (AltSpawnPercent > ZombRand(100)) and (AlternativeSpawning == 4) then
			SuperSurSurvivorSpawnGenTwentyPercent()
		end
		if (AltSpawnPercent > ZombRand(100)) and (AlternativeSpawning == 5) then
			SuperSurSurvivorSpawnGenThirtyPercent()
		end
		if (AltSpawnPercent > ZombRand(100)) and (AlternativeSpawning == 6) then
			SuperSurSurvivorSpawnGenFourtyPercent()
		end
		if (AltSpawnPercent > ZombRand(100)) and (AlternativeSpawning == 7) then SuperSurSurvivorSpawnGenFiftyPercent() end
	end
end

Events.EveryHours.Add(SuperSurvivorDoRandomSpawns);
-- Yes the variables have 'percent' in the name, that's because before this version, I had made alt spawning work different.
-- Do not be confused, the naming scheme means nothing here.

function SuperSurvivorsRaiderManager()
	if (getSpecificPlayer(0) == nil) then return false end
	--this unrelated to raiders but need this to run every once in a while
	getSpecificPlayer(0):getModData().hitByCharacter = false
	getSpecificPlayer(0):getModData().semiHostile = false
	getSpecificPlayer(0):getModData().dealBreaker = nil

	if (getSpecificPlayer(0):isAsleep()) then
		SSM:AsleepHealAll()
	end

	if (getSpecificPlayer(0):getModData().LastRaidTime == nil) then getSpecificPlayer(0):getModData().LastRaidTime = (RaidsStartAfterThisManyHours + 2) end
	local LastRaidTime = getSpecificPlayer(0):getModData().LastRaidTime

	local mySS = SSM:Get(0)
	local hours = math.floor(getGameTime():getWorldAgeHours())
	local chance = RaidChanceForEveryTenMinutes
	if (mySS ~= nil and not mySS:isInBase()) then
		chance = (RaidChanceForEveryTenMinutes * 1.5)
	end

	local RaidersStartTimePassed = (hours >= RaidsStartAfterThisManyHours)
	local RaiderResult = (ZombRand(chance) == 0)
	local RaiderAtLeastTimedExceeded = ((hours - LastRaidTime) >= RaidsAtLeastEveryThisManyHours)

	if RaidersStartTimePassed and (RaiderResult or RaiderAtLeastTimedExceeded) and mySS ~= nil then
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
			local spawnLocation = ZombRand(4)
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
				raider = SuperSurvivorRandomSpawn(spawnSquare)
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
				if (raider:hasWeapon() == false) then raider:giveWeapon(MeleWeapons[ZombRand(1, #MeleWeapons)]) end

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
NumberOfLocalPlayers = 0

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
