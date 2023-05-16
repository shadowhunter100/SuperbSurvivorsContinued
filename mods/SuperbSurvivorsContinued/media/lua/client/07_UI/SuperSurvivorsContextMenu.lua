require "05_Other/SuperSurvivorManager";

-- the job 'companion' has alot of embedding put into it to keep it from breaking away from main player
-- So if you add new commands for the npcs through here, make sure you keep in mind about companions
-- if you don't change the job along with the task, the npc will just return to the player

local isLocalLoggingEnabled = false;


function MedicalCheckSurvivor(test, player)
	if luautils.walkAdj(getSpecificPlayer(0), player:getCurrentSquare()) then
		ISTimedActionQueue.add(ISMedicalCheckAction:new(getSpecificPlayer(0), player))
	end
end

function AskToJoin(test, player) -- When the NPC asks another npc to join a group
	CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "function: AskToJoin() called");
	local SS = SSM:Get(player:getModData().ID)
	local MySS = SSM:Get(0)
	getSpecificPlayer(0):Say(getActionText("CanIJoin"))

	local Relationship = SS:getRelationshipWP()
	local result = ((ZombRand(10) + Relationship) >= 8)

	if (result) then
		local group = SS:getGroup()
		CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "joining group: " .. tostring(SS:getGroupID()));

		if (group) then
			SS:Speak(GetDialogueSpeech("Roger"));

			if (MySS:getGroup() ~= nil) then
				local members = MySS:getGroup():getMembers()
				for x = 1, #members do
					if (members[x] and members[x].player ~= nil) then
						members[x]:Speak(GetDialogueSpeech("Roger"));
						group:addMember(members[x], GetJobText("Partner"))
					end
				end
			else
				group:addMember(MySS, GetJobText("Partner"))
			end
		end
	else
		SS:Speak(GetDialogueSpeech("No"))
	end
	CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "--- function: AskToJoin() END ---");
end

function InviteToParty(test, player) -- When the player offers an NPC to join the group
	CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "function: InviteToParty() called");
	local SS = SSM:Get(player:getModData().ID)
	getSpecificPlayer(0):Say(getActionText("YouWantToJoin"))
	SS:PlusRelationshipWP(1.0) -- Slight bonus to what existed, npcs are a bit rude

	local Relationship = SS:getRelationshipWP()
	local result = ((ZombRand(10) + Relationship) >= 8)

	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	if (result) then
		SS:Speak(GetDialogueSpeech("Roger"))
		local GID, Group
		if (SSM:Get(0):getGroupID() == nil) then
			Group = SSGM:newGroup()
			Group:addMember(SSM:Get(0), GetJobText("Leader"))
		else
			GID = SSM:Get(0):getGroupID()
			Group = SSGM:Get(GID)
		end

		if (Group) then
			Group:addMember(SS, GetJobText("Companion")) -- was Partner
		else
			CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "error could not find or create group");
		end

		local followtask = FollowTask:new(SS, getSpecificPlayer(0))
		local tm = SS:getTaskManager()

		tm:clear()
		tm:AddToTop(followtask)

		-- This will make sure the newly joined npc will default to follow, thus not run away when first join the group
		local ASuperSurvivor = SSM:Get(player:getModData().ID)
		ASuperSurvivor:setAIMode("Follow")
		ASuperSurvivor:setGroupRole("Follow")

		SS:setGroupRole("Companion") -- Newly added
	else
		SS:Speak(GetDialogueSpeech("No"))
		SS:PlusRelationshipWP(-2.0) -- changed to -2 from -1
	end
end

function OfferFood(test, player)
	local SS = SSM:Get(player:getModData().ID)

	local RSS = SSM:Get(0)
	local realPlayer = RSS:Get()
	realPlayer:Say(getActionText("WantSomeFood"))
	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	local food = RSS:getFood()
	local foodcontainer = food:getContainer()
	local gift = RSS:getFacingSquare():AddWorldInventoryItem(food, 0.5, 0.5, 0)

	if (foodcontainer ~= nil) then foodcontainer:DoRemoveItem(food) end

	SS:getTaskManager():AddToTop(TakeGiftTask:new(SS, gift))
	SS:PlusRelationshipWP(2.0)
end

function OfferWater(test, player)
	local SS = SSM:Get(player:getModData().ID)
	getSpecificPlayer(0):Say(getActionText("YouWantWater"))
	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	local food = SSM:Get(0):getWater()
	local foodcontainer = food:getContainer()
	local gift = SSM:Get(0):getFacingSquare():AddWorldInventoryItem(food, 0.5, 0.5, 0)

	if (foodcontainer ~= nil) then foodcontainer:DoRemoveItem(food) end
	SS:getTaskManager():AddToTop(TakeGiftTask:new(SS, gift))
	SS:PlusRelationshipWP(1.0)
end

function OfferAmmo(test, player, ammo)
	local SS = SSM:Get(player:getModData().ID)
	getSpecificPlayer(0):Say(getActionText("YouWantAmmo"))
	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	local container = ammo:getContainer()
	local gift = SSM:Get(0):getFacingSquare():AddWorldInventoryItem(ammo, 0.5, 0.5, 0)

	if (container ~= nil) then container:DoRemoveItem(ammo) end
	SS:getTaskManager():AddToTop(TakeGiftTask:new(SS, gift))
	SS:PlusRelationshipWP(1.0)
end

function OfferWeapon(test, player)
	local SS = SSM:Get(player:getModData().ID)
	getSpecificPlayer(0):Say(getActionText("TakeMyWeapon"))
	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	local wep = getSpecificPlayer(0):getPrimaryHandItem()
	local gift = SSM:Get(0):getFacingSquare():AddWorldInventoryItem(wep, 0.5, 0.5, 0)
	getSpecificPlayer(0):setPrimaryHandItem(nil)
	getSpecificPlayer(0):getInventory():DoRemoveItem(wep)

	SS:getTaskManager():AddToTop(TakeGiftTask:new(SS, gift))
	SS:PlusRelationshipWP(3.0)
end

function AskToLeave(test, SS)
	local isFleeCallLogged = false;
	CreateLogLine("SuperSurvivorsContextMenu", isFleeCallLogged, "function: AskToLeave() called");
	getSpecificPlayer(0):Say("Scram! Or Die!");

	if (SS:getBuilding() ~= nil) then SS:MarkBuildingExplored(SS:getBuilding()) end
	if (SS.TargetBuilding ~= nil) then SS:MarkBuildingExplored(SS.TargetBuilding) end

	getSpecificPlayer(0):getModData().semiHostile = true
	SS.player:getModData().hitByCharacter = true
	SS:getTaskManager():clear();

	CreateLogLine("SuperSurvivorsContextMenu", isFleeCallLogged, tostring(SS:getName()) .. " is leaving...");
	SS:getTaskManager():AddToTop(FleeFromHereTask:new(SS, getSpecificPlayer(0):getCurrentSquare()))

	local GroupID = SS:getGroupID()
	if (GroupID ~= nil) then
		local group = SSGM:Get(GroupID)

		if (group) then
			group:PVPAlert(getSpecificPlayer(0))
		end
	end
	SS.player:getModData().hitByCharacter = true

	SS:Speak("!!")
end

function AskToDrop(test, SS)
	local isFleeCallLogged = false;
	CreateLogLine("SuperSurvivorsContextMenu", isFleeCallLogged, "function: AskToDrop() called");
	getSpecificPlayer(0):Say("Drop your Loot!!");
	SS:Speak("Okay dont shoot!");
	if (SS:getBuilding() ~= nil) then SS:MarkBuildingExplored(SS:getBuilding()) end
	if (SS.TargetBuilding ~= nil) then SS:MarkBuildingExplored(SS.TargetBuilding) end
	getSpecificPlayer(0):getModData().semiHostile = true;
	SS:getTaskManager():clear();
	CreateLogLine("SuperSurvivorsContextMenu", isFleeCallLogged, tostring(SS:getName()) .. " dropped and is leaving...");
	SS:getTaskManager():AddToTop(FleeFromHereTask:new(SS, getSpecificPlayer(0):getCurrentSquare()))
	SS:getTaskManager():AddToTop(CleanInvTask:new(SS, SS.player:getCurrentSquare(), true))

	local GroupID = SS:getGroupID()
	if (GroupID ~= nil) then
		local group = SSGM:Get(GroupID)
		if (group) then
			CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "pvp alert being robbed");
			group:PVPAlert(getSpecificPlayer(0))
		end
	end
	SS.player:getModData().hitByCharacter = true

	SS:Speak("!!")
end

function OfferArmor(test, SS, item)
	local player = SS:Get()
	getSpecificPlayer(0):Say(getActionText("TakeArmor"))
	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	local gift = SSM:Get(0):getFacingSquare():AddWorldInventoryItem(item, 0.5, 0.5, 0)

	getSpecificPlayer(0):getInventory():DoRemoveItem(item)

	SS:getTaskManager():AddToTop(TakeGiftTask:new(SS, gift))
	SS:PlusRelationshipWP(1.5)
end

function SwapWeaponsSurvivor(test, SS, Type)
	local player = SS:Get()
	local PP = getSpecificPlayer(0):getPrimaryHandItem();
	local PS = getSpecificPlayer(0):getSecondaryHandItem();

	local toPlayer

	if (Type == "Gun") then
		toPlayer = SS.LastGunUsed
		SS:setGunWep(PP)
	else
		toPlayer = SS.LastMeleUsed
		SS:setMeleWep(PP)
	end

	local PNW;
	if (toPlayer) then PNW = getSpecificPlayer(0):getInventory():AddItem(toPlayer); end
	getSpecificPlayer(0):setPrimaryHandItem(PNW);
	if (PNW) and (PNW:isTwoHandWeapon()) then getSpecificPlayer(0):setSecondaryHandItem(PNW); end
	if (toPlayer) then
		player:getInventory():Remove(toPlayer)
		if (SS:getBag():contains(toPlayer)) then SS:getBag():Remove(toPlayer) end
	end

	if (PP == PS) then getSpecificPlayer(0):setSecondaryHandItem(nil); end
	local SNW = player:getInventory():AddItem(PP);

	player:setPrimaryHandItem(SNW)
	if (SNW:isTwoHandWeapon()) then player:setSecondaryHandItem(SNW) end
	if (player:getSecondaryHandItem() == toPlayer) then
		player:setSecondaryHandItem(nil)
		player:removeFromHands(nil)
	end
	getSpecificPlayer(0):getInventory():Remove(PP);

	if SNW and SNW:getBodyLocation() ~= "" then
		player:removeFromHands(nil)
		player:setWornItem(item:getBodyLocation(), SNW);
	end
	triggerEvent("OnClothingUpdated", player)
	player:initSpritePartsEmpty();

	if PNW and PNW:getBodyLocation() ~= "" then
		getSpecificPlayer(0):removeFromHands(nil)
		getSpecificPlayer(0):setWornItem(item:getBodyLocation(), PNW);
	end
	triggerEvent("OnClothingUpdated", getSpecificPlayer(0))
	getSpecificPlayer(0):initSpritePartsEmpty();
end

function ForceWeaponType(test, SS, useMele)
	if (not useMele) then
		SS:reEquipMele()
	else
		SS:reEquipGun()
	end
end

function TalkToSurvivor(test, SS)
	getSpecificPlayer(0):Say(GetDialogueSpeech("HelloThere"))

	if SS:Get():CanSee(getSpecificPlayer(0)) then
		if (SS:Get():getModData().Greeting ~= nil) then
			SS:Speak(SS:Get():getModData().Greeting)
		else
			SS:Speak(GetDialogueSpeech("IdleChatter"))
		end
	else
		SS:Speak(GetDialogue("WhoSaidThat"));
	end
end

function CallSurvivor(test, player)
	if (getDistanceBetween(getSpecificPlayer(0), player) > 3) then
		getSpecificPlayer(0):Say(getActionText("OverHere"))
	else
		getSpecificPlayer(0):Say(GetDialogue("HelloThere"))
	end

	local SS = SSM:Get(player:getModData().ID)

	SS:getTaskManager():AddToTop(ListenTask:new(SS, getSpecificPlayer(0), false))
end

local function survivorMenu(context, o)
	if (instanceof(o, "IsoPlayer") and o:getModData().ID ~= nil and o:getModData().ID ~= SSM:getRealPlayerID()) then -- make sure its a valid survivor
		local ID = o:getModData().ID
		local SS = SSM:Get(o:getModData().ID)
		local survivorOption = context:addOption(SS:getName(), worldobjects, nil);
		local submenu = context:getNew(context);

		if (SS.player:getModData().surender) then submenu:addOption("Scram!", nil, AskToLeave, SS, nil) end
		if (SS.player:getModData().surender) then submenu:addOption("Drop Your loot!", nil, AskToDrop, SS, nil) end
		if (o:getModData().isHostile ~= true) then
			local medicalOption = submenu:addOption(getText("ContextMenu_Medical_Check"), nil, MedicalCheckSurvivor, o,
				nil);
			local toolTip = MakeToolTip(medicalOption, getContextMenuText("AidCheck"), getContextMenuText("AidCheckDesc"));
		end
		if (o:getModData().isHostile ~= true)
			and ((SS:getTaskManager():getCurrentTask() == "Listen")
				or (SS:getTaskManager():getCurrentTask() == "Take Gift")
				or (getDistanceBetween(SS:Get(), getSpecificPlayer(0)) < 2))
		then
			local selectOption = submenu:addOption(getContextMenuText("TalkOption"), nil, TalkToSurvivor, SS, nil);
			local toolTip = MakeToolTip(selectOption, getContextMenuText("TalkOption"),
				getContextMenuText("TalkOption_Desc"));
			if ((SS:getGroupID() ~= SSM:Get(0):getGroupID()) or SS:getGroupID() == nil) then -- not in group
				if (o:getModData().NoParty ~= true) then
					submenu:addOption(getContextMenuText("InviteToGroup"), nil, InviteToParty, o, nil);
				end
				if ((SS:getGroup() ~= nil) and (SS:getGroupID() ~= SSM:Get(0):getGroupID())) --[[and (o:getModData().NoParty ~= true)]] then
					submenu:addOption(getContextMenuText("AskToJoin"), nil, AskToJoin, o, nil);
				end
				if ((o:getPrimaryHandItem() == nil) and (getSpecificPlayer(0):getPrimaryHandItem() ~= nil)) then
					submenu:addOption(getContextMenuText("OfferWeapon"), nil, OfferWeapon, o, nil);
				end
			elseif ((SS:getGroupID() == SSM:Get(0):getGroupID()) and SS:getGroupID() ~= nil) then
				---orders
				local i = 1;
				local orderOption = submenu:addOption(getContextMenuText("GiveOrder"), worldobjects, nil);
				local subsubmenu = submenu:getNew(submenu);
				while (Orders[i]) do
					if (Orders[i] == "Loot Room") then
						local subsubsubmenu = subsubmenu:getNew(subsubmenu);
						local lootTypeOption = subsubmenu:addOption(OrderDisplayName[Orders[i]], nil, SurvivorOrder, o,
							Orders[i])
						local q = 1;
						while (LootTypes[q]) do
							subsubsubmenu:addOption(getText("IGUI_ItemCat_" .. LootTypes[q]), nil, SurvivorOrder, o,
								Orders[i], LootTypes[q]);
							q = q + 1;
						end
						subsubmenu:addSubMenu(lootTypeOption, subsubsubmenu);
					else
						MakeToolTip(subsubmenu:addOption(OrderDisplayName[Orders[i]], nil, SurvivorOrder, o, Orders[i]),
							getContextMenuText("OrderDescription"), OrderDesc[Orders[i]]);
					end
					i = i + 1;
				end
				submenu:addSubMenu(orderOption, subsubmenu)

				if (getSpecificPlayer(0):getPrimaryHandItem() ~= nil) and (instanceof(getSpecificPlayer(0):getPrimaryHandItem(), "HandWeapon")) then
					local OfferWeapon = getSpecificPlayer(0):getPrimaryHandItem()
					local Type = "Gun"
					local Label = ""
					local SurvivorWeaponName = getActionText("Nothing")
					if (o:getPrimaryHandItem() ~= nil) then SurvivorWeaponName = o:getPrimaryHandItem():getDisplayName() end
					if (not OfferWeapon:isAimedFirearm()) then Type = "Mele" end
					local swapweaponsOption, tooltipText
					if (Type == "Gun") then
						if SS.LastGunUsed == nil then
							Label = getContextMenuText("GiveGun")
							--tooltipText = "Give your "..getSpecificPlayer(0):getPrimaryHandItem():getDisplayName() .. " to this Survivor to be his Gun type Weapon"
						else
							Label = getContextMenuText("SwapGuns")
							--tooltipText = "Trade your "..getSpecificPlayer(0):getPrimaryHandItem():getDisplayName().." with ".. o:getForname().."\'s ".. SurvivorWeaponName						
						end
						swapweaponsOption = submenu:addOption(Label, nil, SwapWeaponsSurvivor, SS, "Gun");
					else
						if SS.LastMeleUsed == nil then
							Label = getContextMenuText("GiveWeapon")
							--tooltipText = "Give your "..getSpecificPlayer(0):getPrimaryHandItem():getDisplayName() .. " to this Survivor to be his Mele type Weapon"
						else
							Label = getContextMenuText("SwapWeapons")
							--tooltipText = "Trade your "..getSpecificPlayer(0):getPrimaryHandItem():getDisplayName().." with ".. o:getForname().."\'s ".. SurvivorWeaponName
						end
						swapweaponsOption = submenu:addOption(Label, nil, SwapWeaponsSurvivor, SS, "Mele");
					end
					--local tooltip = MakeToolTip(swapweaponsOption,Label,tooltipText);
				end


				if (o:getPrimaryHandItem() ~= SS.LastMeleUsed) and (SS.LastMeleUsed ~= nil) then
					local ForceMeleOption = submenu:addOption(getContextMenuText("UseMele"), nil, ForceWeaponType, SS,
						false)

					local tooltip = MakeToolTip(ForceMeleOption, getContextMenuText("UseMele"),
						getContextMenuText("UseMeleDesc"))
				end
				if (o:getPrimaryHandItem() ~= SS.LastGunUsed) and (SS.LastGunUsed ~= nil) then
					local ForceMeleOption = submenu:addOption(getContextMenuText("UseGun"), nil, ForceWeaponType, SS,
						true)

					local tooltip = MakeToolTip(ForceMeleOption, getContextMenuText("UseGun"),
						getContextMenuText("UseGunDesc"))
				end

				local SetNameOption = submenu:addOption(getContextMenuText("SetName"), nil, SetName, SS, true)
			end

			if (SSM:Get(0):hasFood()) then
				submenu:addOption(getContextMenuText("OfferFood"), nil, OfferFood, o, nil);
			end
			if (SSM:Get(0):hasWater()) then
				submenu:addOption(getContextMenuText("OfferWater"), nil, OfferWater, o, nil);
			end


			local armors = SSM:Get(0):getUnEquipedArmors()
			if (armors) then
				--getSpecificPlayer(0):Say("hereiam2")
				local selectOption = submenu:addOption(getContextMenuText("OfferArmor"), worldobjects, nil);
				local armormenu = submenu:getNew(submenu);

				for i = 1, #armors do
					--getSpecificPlayer(0):Say("hereiam2" .. armors[i]:getDisplayName())
					armormenu:addOption(armors[i]:getDisplayName(), nil, OfferArmor, SS, armors[i])
				end

				submenu:addSubMenu(selectOption, armormenu);
			end


			local ammoBox
			for i = 1, #SS.AmmoBoxTypes do
				ammoBox = SSM:Get(0):FindAndReturn(SS.AmmoBoxTypes[i])
				if (ammoBox) then break end
			end

			if (ammoBox ~= nil) then
				submenu:addOption(getContextMenuText("OfferAmmoBox"), nil, OfferAmmo, o, ammoBox);
			end

			local ammoRound
			for i = 1, #SS.AmmoTypes do
				ammoRound = SSM:Get(0):FindAndReturn(SS.AmmoTypes[i])
				if (ammoRound) then break end
			end

			if (ammoRound ~= nil) then
				submenu:addOption(getContextMenuText("OfferAmmoRound"), nil, OfferAmmo, o, ammoRound);
			end
		end
		if (o:getModData().isHostile ~= true) and (SS:getDangerSeenCount() == 0) and (SS:getTaskManager():getCurrentTask() ~= "Listen") then
			local selectOption = submenu:addOption(getContextMenuText("CallOver"), nil, CallSurvivor, o, nil);
			local toolTip = MakeToolTip(selectOption, getContextMenuText("CallOver"), getContextMenuText("CallOverDesc"));
		end



		context:addSubMenu(survivorOption, submenu);
	end
end

function SurvivorsSquareContextHandle(square, context)
	if (square ~= nil) then
		for i = 0, square:getMovingObjects():size() - 1 do
			local o = square:getMovingObjects():get(i)
			if (instanceof(o, "IsoPlayer")) and (o:getModData().ID ~= SSM:getRealPlayerID()) then
				survivorMenu(context, o);
			end
		end
	end
end

-- WIP - Cows: This was moved out of SuperSurvivorsMod.lua... it had nothing to do with "survivor" itself, and its only the handling group's area selection.
SuperSurvivorSelectAnArea = false;
SuperSurvivorMouseDownTicks = 0;
-- Begin function handling for selecting BaseArea.
function SelectBaseArea()
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
end

function StartSelectingArea(test, area)
	local isLocalFunctionLoggingEnabled = true;
	for k, v in pairs(SuperSurvivorSelectArea) do
		SuperSurvivorSelectArea[k] = false
	end

	CreateLogLine("SuperSurvivorsContextMenu", isLocalFunctionLoggingEnabled, "starting SelectBaseArea()...");
	SuperSurvivorSelectArea[area] = true;
	SuperSurvivorSelectAnArea = true;
	Events.OnRenderTick.Add(SelectBaseArea);
	local mySS = SSM:Get(0)
	local gid = mySS:getGroupID()
	if (not gid) then return false end
	local group = SSGM:Get(gid)
	if (not group) then return false end

	if (area == "BaseArea") then
		local baseBounds = group:getBounds();
		HighlightX1 = baseBounds[1];
		HighlightX2 = baseBounds[2];
		HighlightY1 = baseBounds[3];
		HighlightY2 = baseBounds[4];
		HighlightZ = baseBounds[5];
	else
		local bounds = group:getGroupArea(area);
		HighlightX1 = bounds[1];
		HighlightX2 = bounds[2];
		HighlightY1 = bounds[3];
		HighlightY2 = bounds[4];
		HighlightZ = bounds[5];
	end
end

function SelectingArea(test, area, value)
	local isLocalFunctionLoggingEnabled = true;
	CreateLogLine("SuperSurvivorsContextMenu", isLocalFunctionLoggingEnabled, "function: SelectingArea() called");
	-- value 0 means cancel, -1 is clear, 1 is set
	if (value ~= 0) then
		if (value == -1) then
			HighlightX1 = 0
			HighlightX2 = 0
			HighlightY1 = 0
			HighlightY2 = 0
		end

		local mySS = SSM:Get(0)
		local gid = mySS:getGroupID()
		if (not gid) then return false end
		local group = SSGM:Get(gid)
		if (not group) then return false end

		if (area == "BaseArea") then
			local baseBounds = {
				math.floor(HighlightX1),
				math.floor(HighlightX2),
				math.floor(HighlightY1),
				math.floor(HighlightY2),
				math.floor(getSpecificPlayer(0):getZ())
			}
			group:setBounds(baseBounds);
			CreateLogLine("SuperSurvivorsContextMenu", isLocalFunctionLoggingEnabled, "set base bounds:" ..
				tostring(HighlightX1) .. "," ..
				tostring(HighlightX2) .. " : " .. tostring(HighlightY1) .. "," .. tostring(HighlightY2));
		else
			group:setGroupArea(area, math.floor(HighlightX1), math.floor(HighlightX2), math.floor(HighlightY1),
				math.floor(HighlightY2), getSpecificPlayer(0):getZ())
		end
	end

	CreateLogLine("SuperSurvivorsContextMenu", isLocalFunctionLoggingEnabled, "stopping SelectBaseArea()...");
	SuperSurvivorSelectArea[area] = false;
	SuperSurvivorSelectAnArea = false;
	Events.OnRenderTick.Remove(SelectBaseArea);
	CreateLogLine("SuperSurvivorsContextMenu", isLocalFunctionLoggingEnabled, "--- function: SelectingArea() end ---");
end

SuperSurvivorSelectArea = {}
function SuperSurvivorsAreaSelect(context, area, Display)
	local selectOption = context:addOption(Display, worldobjects, nil);
	local submenu = context:getNew(context);

	if (SuperSurvivorSelectArea[area]) then
		submenu:addOption(getContextMenuText("SetAreaConfirm"), nil, SelectingArea, area, 1)
		submenu:addOption(getContextMenuText("SetAreaCancel"), nil, SelectingArea, area, 0)
		submenu:addOption(getContextMenuText("SetAreaClear"), nil, SelectingArea, area, -1)
	else
		MakeToolTip(submenu:addOption(getContextMenuText("SetAreaSelect"), nil, StartSelectingArea, area),
			getContextMenuText("SetAreaSelect"), getContextMenuText("SetAreaSelectDesc"))
	end

	context:addSubMenu(selectOption, submenu);
end

function SurvivorsFillWorldObjectContextMenu(player, context, worldobjects, test)
	--only player 1 can manipulate survivors
	if player ~= 0 then
		return
	end

	local selectOption = context:addOption(getContextMenuText("AreaSelecting"), worldobjects, nil);
	local submenu = context:getNew(context);

	SuperSurvivorsAreaSelect(submenu, "BaseArea", getContextMenuText("BaseArea"))
	SuperSurvivorsAreaSelect(submenu, "ChopTreeArea", getContextMenuText("ChopTreeArea"))
	SuperSurvivorsAreaSelect(submenu, "TakeCorpseArea", getContextMenuText("TakeCorpseArea"))
	SuperSurvivorsAreaSelect(submenu, "CorpseStorageArea", getContextMenuText("CorpseStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "TakeWoodArea", getContextMenuText("TakeWoodArea"))
	SuperSurvivorsAreaSelect(submenu, "WoodStorageArea", getContextMenuText("WoodStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "FoodStorageArea", getContextMenuText("FoodStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "WeaponStorageArea", getContextMenuText("WeaponStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "ToolStorageArea", getContextMenuText("ToolStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "MedicalStorageArea", getContextMenuText("MedicalStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "FarmingArea", getContextMenuText("FarmingArea")) -- Farming does not work
	SuperSurvivorsAreaSelect(submenu, "ForageArea", getContextMenuText("ForageArea"))
	SuperSurvivorsAreaSelect(submenu, "GuardArea", getContextMenuText("GuardArea"))

	context:addSubMenu(selectOption, submenu);


	local square = GetMouseSquare();

	SurvivorsSquareContextHandle(square, context);
	if (square ~= nil) then
		local osquare = square:getN();
		if (osquare ~= nil) then
			SurvivorsSquareContextHandle(osquare:getE(), context);
			SurvivorsSquareContextHandle(osquare:getW(), context);
			SurvivorsSquareContextHandle(osquare, context);
		end
		osquare = square:getS();
		if (osquare ~= nil) then
			SurvivorsSquareContextHandle(osquare:getE(), context);
			SurvivorsSquareContextHandle(osquare:getW(), context);
			SurvivorsSquareContextHandle(osquare, context);
		end
		osquare = square:getE();
		if (osquare ~= nil) then
			SurvivorsSquareContextHandle(osquare, context);
		end
		osquare = square:getW();
		if (osquare ~= nil) then
			SurvivorsSquareContextHandle(osquare, context);
		end
	end

	local SurvivorOptions = context:addOption(getContextMenuText("SurvivorOptions"), worldobjects, nil);
	local submenu = context:getNew(context);

	local RulesOfEngagementOption = submenu:addOption(getContextMenuText("RulesOfEngagement"), worldobjects, nil);
	local subsubmenu = submenu:getNew(submenu);

	MakeToolTip(subsubmenu:addOption(getContextMenuText("AttackAnyoneOnSight"), nil, SetRulesOfEngagement, 4),
		"Rules of Engagement",
		"Shoot or Attack on sight Anything that may come along. Zombies, hostile survivors, friendly survivors neutral. Only party members are the exception");
	MakeToolTip(subsubmenu:addOption(getContextMenuText("AttackHostilesOnSight"), nil, SetRulesOfEngagement, 3),
		"Rules of Engagement",
		"Shoot or Attack on sight Anything hostile that may come along. Zombies or obviously hostile survivors");
	--MakeToolTip(subsubmenu:addOption("Attack Zombies", nil, SetRulesOfEngagement, 2),"Rules of Engagement","Shoot or Attack on sight Any zombies that may come along.");
	--MakeToolTip(subsubmenu:addOption("No Attacking", nil, SetRulesOfEngagement, 1),"Rules of Engagement","Do not shoot or attack anything or anyone. Just avoid when possible.");

	submenu:addSubMenu(RulesOfEngagementOption, subsubmenu);

	local MeleOrGunOption = submenu:addOption(getContextMenuText("CallToArms"), worldobjects, nil);
	subsubmenu = submenu:getNew(submenu);

	MakeToolTip(subsubmenu:addOption(getContextMenuText("UseMele"), nil, SetMeleOrGun, 'mele'),
		getContextMenuText("UseMele"), getContextMenuText("UseMeleDesc"));
	MakeToolTip(subsubmenu:addOption(getContextMenuText("UseGun"), nil, SetMeleOrGun, 'gun'),
		getContextMenuText("UseGun"), getContextMenuText("UseGunDesc"));
	submenu:addSubMenu(MeleOrGunOption, subsubmenu);

	context:addSubMenu(SurvivorOptions, submenu); --Add ">"
end

function SetRulesOfEngagement(test, value)
	getSpecificPlayer(0):getModData().ROE = value;

	local SS = SSM:Get(0)
	local group = SS:getGroup()
	if (group) then
		group:setROE(value)
		getSpecificPlayer(0):Say(getContextMenuText("ROESet"));
	end
end

function SetMeleOrGun(test, value)
	local mySS = SSM:Get(0)
	if (mySS:getGroupID() ~= nil) then
		local myGroup = SSGM:Get(mySS:getGroupID())
		if (myGroup) then
			if (value == "gun") then
				mySS:Get():Say(getContextMenuText("EveryOneUseGun"))
			else
				mySS:Get():Say(getContextMenuText("EveryOneUseMele"))
			end
			myGroup:UseWeaponType(value)
		end
	end
end

function OnSetName(test, button, SS)
	if button.internal == "OK" then
		if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
			SS:setName(button.parent.entry:getText())
		end
	end
end

function SetName(test, SS)
	local name = SS:getName()
	local modal = ISTextBox:new(0, 0, 280, 180, getContextMenuText("SetName"), name, nil, OnSetName, 0, SS)
	modal:initialise()
	modal:addToUIManager()
end

Events.OnFillWorldObjectContextMenu.Add(SurvivorsFillWorldObjectContextMenu);
