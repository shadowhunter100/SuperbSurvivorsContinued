require "04_Group.SuperSurvivorManager";

-- the job 'companion' has alot of embedding put into it to keep it from breaking away from main player
-- So if you add new commands for the npcs through here, make sure you keep in mind about companions
-- if you don't change the job along with the task, the npc will just return to the player

local isLocalLoggingEnabled = false;

--- Cows: By Request, SwapWeaponsSurvivor() will be restored when/if it is fixed...
---@param test any
---@param SS any
---@param Type any
function SwapWeaponsSurvivor(test, SS, Type)
	local player = SS:Get(); -- Cows: I'm guessing this is actually the current player character...
	local PP = getSpecificPlayer(0):getPrimaryHandItem();
	local PS = getSpecificPlayer(0):getSecondaryHandItem();

	local toPlayer; -- Cows: And this is supposed to be the NPC...

	if (Type == "Gun") then
		toPlayer = SS.LastGunUsed;
		SS:setGunWep(PP);
	else
		toPlayer = SS.LastMeleUsed;
		SS:setMeleWep(PP);
	end

	local PNW; -- Cows: Dunno what PNW is and there is no explanation.
	if (toPlayer) then
		PNW = getSpecificPlayer(0):getInventory():AddItem(toPlayer);
	end
	getSpecificPlayer(0):setPrimaryHandItem(PNW);
	if (PNW) and (PNW:isTwoHandWeapon()) then
		getSpecificPlayer(0):setSecondaryHandItem(PNW);
	end
	if (toPlayer) then
		player:getInventory():Remove(toPlayer)
		if (SS:getBag():contains(toPlayer)) then
			SS:getBag():Remove(toPlayer);
		end
	end

	if (PP == PS) then
		getSpecificPlayer(0):setSecondaryHandItem(nil);
	end

	local SNW = player:getInventory():AddItem(PP); -- Cows: Dunno what SNW is and there is no explanation.

	player:setPrimaryHandItem(SNW)
	if (SNW:isTwoHandWeapon()) then
		player:setSecondaryHandItem(SNW);
	end

	if (player:getSecondaryHandItem() == toPlayer) then
		player:setSecondaryHandItem(nil);
		player:removeFromHands(nil);
	end
	getSpecificPlayer(0):getInventory():Remove(PP);

	if SNW and SNW:getBodyLocation() ~= "" then
		player:removeFromHands(nil);
		player:setWornItem(item:getBodyLocation(), SNW);
	end
	triggerEvent("OnClothingUpdated", player)
	player:initSpritePartsEmpty();

	if PNW and PNW:getBodyLocation() ~= "" then
		getSpecificPlayer(0):removeFromHands(nil)
		getSpecificPlayer(0):setWornItem(item:getBodyLocation(), PNW);
	end
	triggerEvent("OnClothingUpdated", getSpecificPlayer(0));
	getSpecificPlayer(0):initSpritePartsEmpty();
end

function MedicalCheckSurvivor(test, player)
	if luautils.walkAdj(getSpecificPlayer(0), player:getCurrentSquare()) then
		ISTimedActionQueue.add(ISMedicalCheckAction:new(getSpecificPlayer(0), player))
	end
end

function AskToJoin(test, player) -- When the NPC asks another npc to join a group
	CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "function: AskToJoin() called");
	local SS = SSM:Get(player:getModData().ID)
	local MySS = SSM:Get(0)
	getSpecificPlayer(0):Say(Get_SS_UIActionText("CanIJoin"))

	local Relationship = SS:getRelationshipWP()
	local result = ((ZombRand(10) + Relationship) >= 8)

	if (result) then
		local group = SS:getGroup()
		CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "joining group: " .. tostring(SS:getGroupID()));

		if (group) then
			SS:Speak(Get_SS_DialogueSpeech("Roger"));

			if (MySS:getGroup() ~= nil) then
				local members = MySS:getGroup():getMembers()
				for x = 1, #members do
					if (members[x] and members[x].player ~= nil) then
						members[x]:Speak(Get_SS_DialogueSpeech("Roger"));
						group:addMember(members[x], Get_SS_JobText("Companion"));
					end
				end
			else
				group:addMember(MySS, Get_SS_JobText("Companion"));
			end
		end
	else
		SS:Speak(Get_SS_DialogueSpeech("No"))
	end
	CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "--- function: AskToJoin() END ---");
end

function InviteToParty(test, player) -- When the player offers an NPC to join the group
	CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "function: InviteToParty() called");
	local SS = SSM:Get(player:getModData().ID)
	getSpecificPlayer(0):Say(Get_SS_UIActionText("YouWantToJoin"))
	SS:PlusRelationshipWP(1.0) -- Slight bonus to what existed, npcs are a bit rude

	local Relationship = SS:getRelationshipWP()
	local result = ((ZombRand(10) + Relationship) >= 8)

	local task = SS:getTaskManager():getTaskFromName("Listen")
	if (task ~= nil) and (task.Name == "Listen") then task:Talked() end

	if (result) then
		SS:Speak(Get_SS_DialogueSpeech("Roger"))
		local GID, Group
		if (SSM:Get(0):getGroupID() == nil) then
			Group = SSGM:newGroup()
			Group:addMember(SSM:Get(0), Get_SS_JobText("Leader"))
		else
			GID = SSM:Get(0):getGroupID()
			Group = SSGM:GetGroupById(GID)
		end

		if (Group) then
			Group:addMember(SS, Get_SS_JobText("Companion"))
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
		SS:Speak(Get_SS_DialogueSpeech("No"))
		SS:PlusRelationshipWP(-2.0) -- changed to -2 from -1
	end
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
		local group = SSGM:GetGroupById(GroupID)

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
		local group = SSGM:GetGroupById(GroupID)
		if (group) then
			CreateLogLine("SuperSurvivorsContextMenu", isLocalLoggingEnabled, "pvp alert being robbed");
			group:PVPAlert(getSpecificPlayer(0))
		end
	end
	SS.player:getModData().hitByCharacter = true

	SS:Speak("!!")
end

function ForceWeaponType(test, SS, useMele)
	if (not useMele) then
		SS:reEquipMele()
	else
		SS:reEquipGun()
	end
end

function TalkToSurvivor(test, SS)
	getSpecificPlayer(0):Say(Get_SS_DialogueSpeech("HelloThere"))

	if SS:Get():CanSee(getSpecificPlayer(0)) then
		if (SS:Get():getModData().Greeting ~= nil) then
			SS:Speak(SS:Get():getModData().Greeting)
		else
			SS:Speak(Get_SS_DialogueSpeech("IdleChatter"))
		end
	else
		SS:Speak(Get_SS_Dialogue("WhoSaidThat"));
	end
end

function CallSurvivor(test, player)
	if (GetDistanceBetween(getSpecificPlayer(0), player) > 3) then
		getSpecificPlayer(0):Say(Get_SS_UIActionText("OverHere"))
	else
		getSpecificPlayer(0):Say(Get_SS_Dialogue("HelloThere"))
	end

	local SS = SSM:Get(player:getModData().ID)

	SS:getTaskManager():AddToTop(ListenTask:new(SS, getSpecificPlayer(0), false))
end

local function contextMenuOnSetName(test, button, SS)
	if button.internal == "OK" then
		if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
			SS:setName(button.parent.entry:getText())
		end
	end
end

local function contextMenuSetName(test, SS)
	local name = SS:getName()
	local modal = ISTextBox:new(0, 0, 280, 180, Get_SS_ContextMenuText("SetName"), name, nil, contextMenuOnSetName, 0, SS)
	modal:initialise()
	modal:addToUIManager()
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
			local toolTip = MakeToolTip(medicalOption, Get_SS_ContextMenuText("AidCheck"),
				Get_SS_ContextMenuText("AidCheckDesc"));
		end
		if (o:getModData().isHostile ~= true)
			and ((SS:getTaskManager():getCurrentTask() == "Listen")
				or (SS:getTaskManager():getCurrentTask() == "Take Gift")
				or (GetDistanceBetween(SS:Get(), getSpecificPlayer(0)) < 2))
		then
			local selectOption = submenu:addOption(Get_SS_ContextMenuText("TalkOption"), nil, TalkToSurvivor, SS, nil);
			local toolTip = MakeToolTip(selectOption, Get_SS_ContextMenuText("TalkOption"),
				Get_SS_ContextMenuText("TalkOption_Desc"));
			if ((SS:getGroupID() ~= SSM:Get(0):getGroupID()) or SS:getGroupID() == nil) then -- not in group
				if (o:getModData().NoParty ~= true) then
					submenu:addOption(Get_SS_ContextMenuText("InviteToGroup"), nil, InviteToParty, o, nil);
				end
				if ((SS:getGroup() ~= nil) and (SS:getGroupID() ~= SSM:Get(0):getGroupID())) --[[and (o:getModData().NoParty ~= true)]] then
					submenu:addOption(Get_SS_ContextMenuText("AskToJoin"), nil, AskToJoin, o, nil);
				end
			elseif ((SS:getGroupID() == SSM:Get(0):getGroupID()) and SS:getGroupID() ~= nil) then
				---orders
				local i = 1;
				local orderOption = submenu:addOption(Get_SS_ContextMenuText("GiveOrder"), worldobjects, nil);
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
							Get_SS_ContextMenuText("OrderDescription"), OrderDesc[Orders[i]]);
					end
					i = i + 1;
				end
				submenu:addSubMenu(orderOption, subsubmenu);


				if (getSpecificPlayer(0):getPrimaryHandItem() ~= nil) and (instanceof(getSpecificPlayer(0):getPrimaryHandItem(), "HandWeapon")) then
					local OfferWeapon = getSpecificPlayer(0):getPrimaryHandItem()
					local Type = "Gun"
					local Label = ""

					if (not OfferWeapon:isAimedFirearm()) then
						Type = "Mele"
					end
					local swapWeaponsOption, tooltipText;

					if (Type == "Gun") then
						-- Cows: this is likely where the issue arose... if the npc had no weapon to begin with, they can't "swap" the gun.
						if SS.LastGunUsed == nil then
							Label = Get_SS_ContextMenuText("GiveGun")
						else
							Label = Get_SS_ContextMenuText("SwapGuns")
						end
						swapWeaponsOption = submenu:addOption(Label, nil, SwapWeaponsSurvivor, SS, "Gun");
					else
						if SS.LastMeleUsed == nil then
							Label = Get_SS_ContextMenuText("GiveWeapon")
						else
							Label = Get_SS_ContextMenuText("SwapWeapons")
						end
						swapWeaponsOption = submenu:addOption(Label, nil, SwapWeaponsSurvivor, SS, "Mele");
					end
				end

				if (o:getPrimaryHandItem() ~= SS.LastMeleUsed) and (SS.LastMeleUsed ~= nil) then
					local ForceMeleOption = submenu:addOption(Get_SS_ContextMenuText("UseMele"), nil, ForceWeaponType, SS,
						false)

					local tooltip = MakeToolTip(ForceMeleOption, Get_SS_ContextMenuText("UseMele"),
						Get_SS_ContextMenuText("UseMeleDesc"))
				end
				if (o:getPrimaryHandItem() ~= SS.LastGunUsed) and (SS.LastGunUsed ~= nil) then
					local ForceMeleOption = submenu:addOption(Get_SS_ContextMenuText("UseGun"), nil, ForceWeaponType, SS,
						true)

					local tooltip = MakeToolTip(ForceMeleOption, Get_SS_ContextMenuText("UseGun"),
						Get_SS_ContextMenuText("UseGunDesc"))
				end

				local SetNameOption = submenu:addOption(Get_SS_ContextMenuText("SetName"), nil, contextMenuSetName, SS,
					true)
			end
		end
		if (o:getModData().isHostile ~= true) and (SS:getDangerSeenCount() == 0) and (SS:getTaskManager():getCurrentTask() ~= "Listen") then
			local selectOption = submenu:addOption(Get_SS_ContextMenuText("CallOver"), nil, CallSurvivor, o, nil);
			local toolTip = MakeToolTip(selectOption, Get_SS_ContextMenuText("CallOver"),
				Get_SS_ContextMenuText("CallOverDesc"));
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

function SetRulesOfEngagement(test, value)
	getSpecificPlayer(0):getModData().ROE = value;

	local SS = SSM:Get(0)
	local group = SS:getGroup()
	if (group) then
		group:setROE(value)
		getSpecificPlayer(0):Say(Get_SS_ContextMenuText("ROESet"));
	end
end

function SetMeleOrGun(test, value)
	local mySS = SSM:Get(0)
	if (mySS:getGroupID() ~= nil) then
		local myGroup = SSGM:GetGroupById(mySS:getGroupID())
		if (myGroup) then
			if (value == "gun") then
				mySS:Get():Say(Get_SS_ContextMenuText("EveryOneUseGun"))
			else
				mySS:Get():Say(Get_SS_ContextMenuText("EveryOneUseMele"))
			end
			myGroup:UseWeaponType(value)
		end
	end
end

function SuperSurvivorsAreaSelect(context, area, Display)
	local selectOption = context:addOption(Display, worldobjects, nil);
	local submenu = context:getNew(context);

	if (SuperSurvivorSelectArea[area]) then
		submenu:addOption(Get_SS_ContextMenuText("SetAreaConfirm"), nil, SelectingArea, area, 1)
		submenu:addOption(Get_SS_ContextMenuText("SetAreaCancel"), nil, SelectingArea, area, 0)
		submenu:addOption(Get_SS_ContextMenuText("SetAreaClear"), nil, SelectingArea, area, -1)
	else
		MakeToolTip(submenu:addOption(Get_SS_ContextMenuText("SetAreaSelect"), nil, StartSelectingArea, area),
			Get_SS_ContextMenuText("SetAreaSelect"), Get_SS_ContextMenuText("SetAreaSelectDesc"))
	end

	context:addSubMenu(selectOption, submenu);
end

function SurvivorsFillWorldObjectContextMenu(player, context, worldobjects, test)
	--only player 1 can manipulate survivors
	if player ~= 0 then
		return
	end

	local selectOption = context:addOption(Get_SS_ContextMenuText("AreaSelecting"), worldobjects, nil);
	local submenu = context:getNew(context);

	SuperSurvivorsAreaSelect(submenu, "BaseArea", Get_SS_ContextMenuText("BaseArea"))
	SuperSurvivorsAreaSelect(submenu, "ChopTreeArea", Get_SS_ContextMenuText("ChopTreeArea"))
	SuperSurvivorsAreaSelect(submenu, "TakeCorpseArea", Get_SS_ContextMenuText("TakeCorpseArea"))
	SuperSurvivorsAreaSelect(submenu, "CorpseStorageArea", Get_SS_ContextMenuText("CorpseStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "TakeWoodArea", Get_SS_ContextMenuText("TakeWoodArea"))
	SuperSurvivorsAreaSelect(submenu, "WoodStorageArea", Get_SS_ContextMenuText("WoodStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "FoodStorageArea", Get_SS_ContextMenuText("FoodStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "WeaponStorageArea", Get_SS_ContextMenuText("WeaponStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "ToolStorageArea", Get_SS_ContextMenuText("ToolStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "MedicalStorageArea", Get_SS_ContextMenuText("MedicalStorageArea"))
	SuperSurvivorsAreaSelect(submenu, "FarmingArea", Get_SS_ContextMenuText("FarmingArea")) -- Farming does not work
	SuperSurvivorsAreaSelect(submenu, "ForageArea", Get_SS_ContextMenuText("ForageArea"))
	SuperSurvivorsAreaSelect(submenu, "GuardArea", Get_SS_ContextMenuText("GuardArea"))

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

	local SurvivorOptions = context:addOption(Get_SS_ContextMenuText("SurvivorOptions"), worldobjects, nil);
	local submenu = context:getNew(context);

	local RulesOfEngagementOption = submenu:addOption(Get_SS_ContextMenuText("RulesOfEngagement"), worldobjects, nil);
	local subsubmenu = submenu:getNew(submenu);

	MakeToolTip(subsubmenu:addOption(Get_SS_ContextMenuText("AttackAnyoneOnSight"), nil, SetRulesOfEngagement, 4),
		"Rules of Engagement",
		"Shoot or Attack on sight Anything that may come along. Zombies, hostile survivors, friendly survivors neutral. Only party members are the exception");
	MakeToolTip(subsubmenu:addOption(Get_SS_ContextMenuText("AttackHostilesOnSight"), nil, SetRulesOfEngagement, 3),
		"Rules of Engagement",
		"Shoot or Attack on sight Anything hostile that may come along. Zombies or obviously hostile survivors");
	--MakeToolTip(subsubmenu:addOption("Attack Zombies", nil, SetRulesOfEngagement, 2),"Rules of Engagement","Shoot or Attack on sight Any zombies that may come along.");
	--MakeToolTip(subsubmenu:addOption("No Attacking", nil, SetRulesOfEngagement, 1),"Rules of Engagement","Do not shoot or attack anything or anyone. Just avoid when possible.");

	submenu:addSubMenu(RulesOfEngagementOption, subsubmenu);

	local MeleOrGunOption = submenu:addOption(Get_SS_ContextMenuText("CallToArms"), worldobjects, nil);
	subsubmenu = submenu:getNew(submenu);

	MakeToolTip(subsubmenu:addOption(Get_SS_ContextMenuText("UseMele"), nil, SetMeleOrGun, 'mele'),
		Get_SS_ContextMenuText("UseMele"), Get_SS_ContextMenuText("UseMeleDesc"));
	MakeToolTip(subsubmenu:addOption(Get_SS_ContextMenuText("UseGun"), nil, SetMeleOrGun, 'gun'),
		Get_SS_ContextMenuText("UseGun"), Get_SS_ContextMenuText("UseGunDesc"));
	submenu:addSubMenu(MeleOrGunOption, subsubmenu);

	context:addSubMenu(SurvivorOptions, submenu); --Add ">"
end

Events.OnFillWorldObjectContextMenu.Add(SurvivorsFillWorldObjectContextMenu);
