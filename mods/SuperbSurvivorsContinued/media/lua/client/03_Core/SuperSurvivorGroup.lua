require "04_Group.SuperSurvivorManager" -- Cows: TODO: Remove all dependencies on SSM.

SuperSurvivorGroup = {}
SuperSurvivorGroup.__index = SuperSurvivorGroup

local isLocalLoggingEnabled = false;

function SuperSurvivorGroup:new(GID)
	local o = {};
	setmetatable(o, self);
	self.__index = self;

	o.ROE = 3;
	o.YouBeenWarned = {};
	o.ID = GID;
	o.Leader = -1;
	o.Members = {};
	o.Bounds = { 0, 0, 0, 0, 0 };

	o.GroupAreas = {}
	o.GroupAreas["ChopTreeArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["TakeCorpseArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["TakeWoodArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["FarmingArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["ForageArea"] = { 0, 0, 0, 0, 0 };

	o.GroupAreas["CorpseStorageArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["FoodStorageArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["WoodStorageArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["ToolStorageArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["WeaponStorageArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["MedicalStorageArea"] = { 0, 0, 0, 0, 0 };
	o.GroupAreas["GuardArea"] = { 0, 0, 0, 0, 0 };

	return o;
end

function SuperSurvivorGroup:setROE(tothis)
	self.ROE = tothis;
end

function SuperSurvivorGroup:getFollowCount()
	local count = 0;
	local members = self:getMembers();
	for i = 1, #members do
		if (members[i] ~= nil) and (members[i].getCurrentTask ~= nil) then
			if (members[i]:getCurrentTask() == "Follow") then
				count = count + 1;
			end
		end
	end
	return count;
end

function SuperSurvivorGroup:isEnemy(SS, character)
	-- zombie is enemy to anyone
	if character:isZombie() then
		return true;
	elseif (SS:isInGroup(character)) then
		return false;
	elseif (SS.player:getModData().isHostile ~= true and character:getModData().surender == true) then
		return false; -- so other npcs dont attack anyone surendering
	elseif (SS.player:getModData().hitByCharacter == true) and (character:getModData().semiHostile == true) then
		return true;
	elseif (character:getModData().isHostile ~= SS.player:getModData().isHostile) then
		return true;
	elseif (self.ROE == 4) then
		return true;
	end
	return false;
end

function SuperSurvivorGroup:UseWeaponType(thisType)
	local members = self:getMembers();
	--
	for i = 1, #members do
		if (thisType == "gun") and (members[i].reEquipGun ~= nil) then
			members[i]:reEquipGun();
		elseif (members[i].reEquipMele ~= nil) then
			members[i]:reEquipMele();
		end
	end
end

function SuperSurvivorGroup:getGroupArea(thisArea)
	return self.GroupAreas[thisArea];
end

function SuperSurvivorGroup:getGroupAreaCenterSquare(thisArea)
	local area = self.GroupAreas[thisArea];
	if (area[1] ~= 0) then
		return GetCenterSquareFromArea(area[1], area[2], area[3], area[4], area[5]);
	else
		return nil;
	end
end

function SuperSurvivorGroup:getBestGroupAreaContainerForItem(item) -- returns most appropriate container(or square) for an item based on set base areas
	local itemtype = item:getType();
	local itemcategory = item:getCategory();

	local overrideMedical = { "Bandaid", "Tweezers", "Bandage", "AlcoholBandage", "AlcoholWipes", "RippedSheets",
		"AlcoholRippedSheets" };
	local overrideTool = { "Axe", "Hammer", "Nails", "NailsBox", "BallPeenHammer", "Sledgehammer", "Sledgehammer2",
		"HammerStone", "GardenSaw", "Saw"
	, "ScrewsBox", "Screws", "Screwdriver", "HandAxe", "HandShovel", "HandScyth" };
	local overrideWood = { "Log", "Plank", "WoodenStick", "TreeBranch" };

	--using only "if" not "elseif" because this is a top down priority checking system, multiple if statements can be true for certain items so if certain areas are set those will be prioritized

	if (CheckIfTableHasValue(overrideWood, itemtype) and self:isGroupAreaSet("WoodStorageArea")) then
		return self:getGroupAreaContainer("WoodStorageArea");
	end
	if (CheckIfTableHasValue(overrideMedical, itemtype) and self:isGroupAreaSet("MedicalStorageArea")) then
		return self:getGroupAreaContainer("MedicalStorageArea");
	end
	if (CheckIfTableHasValue(overrideTool, itemtype) and self:isGroupAreaSet("ToolStorageArea")) then
		return self:getGroupAreaContainer("ToolStorageArea");
	end
	if ((itemcategory == "Food") and self:isGroupAreaSet("FoodStorageArea")) then
		return self:getGroupAreaContainer("FoodStorageArea");
	end
	--
	if (((itemcategory == "Weapon") or (itemcategory == "WeaponPart")) and self:isGroupAreaSet("WeaponStorageArea")) then
		return self:getGroupAreaContainer("WeaponStorageArea");
	end
	--
	if (((itemcategory == "Normal") or (itemcategory == "Item"))
			and self:isGroupAreaSet("ToolStorageArea")
		) then
		return self:getGroupAreaContainer("ToolStorageArea");
	end

	return nil;
end

function SuperSurvivorGroup:isGroupAreaSet(thisArea)
	local area = self.GroupAreas[thisArea];
	if (area[1] ~= 0) then
		return true;
	end

	return false;
end

---Cows: Nested loop...
---@param thisArea any
---@return unknown
function SuperSurvivorGroup:getGroupAreaContainer(thisArea) -- returns any container found in area or the center square of that area if no containers found
	local area = self.GroupAreas[thisArea]
	if (area[1] ~= 0) then
		--
		for x = area[1], area[2] do
			--
			for y = area[3], area[4] do
				local sq = getCell():getGridSquare(x, y, 0);
				--
				if (sq) then
					local objs = sq:getObjects();
					--
					for j = 0, objs:size() - 1 do
						--
						if (objs:get(j):getContainer() ~= nil) then
							return objs:get(j);
						end
					end
				end
			end
		end
	end

	return self:getGroupAreaCenterSquare(thisArea);
end

function SuperSurvivorGroup:setGroupArea(thisArea, x1, x2, y1, y2, z)
	self.GroupAreas[thisArea][1] = x1;
	self.GroupAreas[thisArea][2] = x2;
	self.GroupAreas[thisArea][3] = y1;
	self.GroupAreas[thisArea][4] = y2;
	self.GroupAreas[thisArea][5] = z;
end

function SuperSurvivorGroup:getBounds()
	return self.Bounds;
end

function SuperSurvivorGroup:setBounds(Boundaries)
	self.Bounds = Boundaries;
end

function SuperSurvivorGroup:IsInBounds(thisplayer)
	if (self.Bounds[4]) then
		if (thisplayer:getZ() == self.Bounds[5]) and (thisplayer:getX() > self.Bounds[1]) and (thisplayer:getX() <= self.Bounds[2]) and (thisplayer:getY() > self.Bounds[3]) and (thisplayer:getY() <= self.Bounds[4]) then
			return true;
		end
	end
	return false;
end

function SuperSurvivorGroup:getBaseCenter()
	if (self.Bounds[4]) then
		local xdiff = (self.Bounds[2] - self.Bounds[1]);
		local ydiff = (self.Bounds[4] - self.Bounds[3]);
		local z = 0;
		if (self.Bounds[5]) then
			z = self.Bounds[5];
		end
		local centerSquare = getCell():getGridSquare(self.Bounds[1] + (xdiff / 2), self.Bounds[3] + (ydiff / 2), z);

		return centerSquare;
	end
	return nil;
end

function SuperSurvivorGroup:getBaseCenterCoords()
	if (self.Bounds[4]) then
		local xdiff = (self.Bounds[2] - self.Bounds[1]);
		local ydiff = (self.Bounds[4] - self.Bounds[3]);

		local x = self.Bounds[1] + (xdiff / 2);
		local y = self.Bounds[3] + (ydiff / 2);
		local z = self.Bounds[5];
		local out = { x, y, z }
		return out;
	end
	return nil;
end

function SuperSurvivorGroup:getRandomBaseSquare()
	if (self.Bounds[4]) then
		local xrand = ZombRand(math.floor(self.Bounds[1]), math.floor(self.Bounds[2]));
		local yrand = ZombRand(math.floor(self.Bounds[3]), math.floor(self.Bounds[4]));

		local centerSquare = getCell():getGridSquare(xrand, yrand, self.Bounds[5]);

		return centerSquare;
	end
	return nil;
end

function SuperSurvivorGroup:WarnPlayer(ID)
	self.YouBeenWarned[ID] = true;
end

function SuperSurvivorGroup:getWarnPlayer(ID)
	if not self.YouBeenWarned[ID] then
		return false;
	end
	return true;
end

function SuperSurvivorGroup:setLeader(newLeader)
	if self.Leader ~= -1 then
		local SS = SSM:Get(self.Leader);
		-- old leader gets demoted to worker if exists
		if (SS) then
			SS:setGroupRole(Get_SS_UIActionText("Job_Worker"));
		end
	end
	self.Leader = newLeader;
	SSM:Get(self.Leader):setGroupRole(Get_SS_UIActionText("Job_Leader"));
end

function SuperSurvivorGroup:getLeader()
	return self.Leader;
end

function SuperSurvivorGroup:hasLeader()
	if self.Leader ~= -1 then
		local SS = SSM:Get(self.Leader);
		if (SS) and SS:getGroupRole() == Get_SS_UIActionText("Job_Leader") then
			return true;
		end
	end
	return false;
end

function SuperSurvivorGroup:getID()
	return self.ID;
end

function SuperSurvivorGroup:getClosestIdleMember(ofThisRole, referencePoint)
	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled,
		"function: SuperSurvivorGroup:getClosestIdleMember() called"
	);
	local closestSoFar = 999;
	local closestID = -1;
	local distance = 0;
	--
	for i = 1, #self.Members do
		local workingID = self.Members[i];

		if (workingID ~= nil) then
			distance = GetDistanceBetween(SSM:Get(workingID):Get(), referencePoint);

			if (SSM:Get(workingID):isInAction() == false)
				and (distance ~= 0)
				and (distance < closestSoFar)
				and ((SSM:Get(workingID):getGroupRole() == ofThisRole)
					or (ofThisRole == "Any")
					or (ofThisRole == nil))
			then
				closestID = workingID;
				closestSoFar = distance;
			end
		end
	end

	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled,
		"--- function: SuperSurvivorGroup:getClosestIdleMember() END --- "
	);
	if (closestID ~= -1) then
		return SSM:Get(closestID);
	else
		return nil;
	end
end

function SuperSurvivorGroup:getClosestMember(ofThisRole, referencePoint)
	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled, "function: SuperSurvivorGroup:getClosestMember() called");
	local closestSoFar = 999;
	local closestID = -1;
	local distance = 0;

	for i = 1, #self.Members do
		local workingID = self.Members[i];

		if (workingID ~= nil) then
			local workingSS = SSM:Get(workingID);
			--
			if (workingSS ~= nil) then
				distance = GetDistanceBetween(workingSS:Get(), referencePoint);

				if (distance ~= 0) and (distance < closestSoFar)
					and ((ofThisRole == nil)
						or (SSM:Get(self.Members[i]):getGroupRole() == ofThisRole)
						or (ofThisRole == "Any"))
				then
					closestID = self.Members[i];
					closestSoFar = distance;
				end
			end
		end
	end

	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled,
		"--- function: SuperSurvivorGroup:getClosestMember() END ---"
	);
	if (closestID ~= -1) then
		return SSM:Get(closestID);
	else
		return nil;
	end
end

function SuperSurvivorGroup:getMember(ofThisRole, closest)
	for i = 1, #self.Members do
		local workingID = self.Members[i];
		--
		if ((workingID ~= nil)
				and (SSM:Get(workingID):getGroupRole() == ofThisRole)
				or (ofThisRole == "Any")
				or (ofThisRole == nil)
			)
		then
			return SSM:Get(workingID);
		end
	end

	return nil;
end

function SuperSurvivorGroup:getMembers()
	local TableOut = {};
	--
	for i = 1, #self.Members do
		local workingID = self.Members[i];
		--
		if ((workingID ~= nil)) and (SSM:Get(workingID) ~= nil) then
			table.insert(TableOut, SSM:Get(workingID));
		elseif ((workingID ~= nil)) then
			table.insert(TableOut, tonumber(workingID));
		end
	end
	return TableOut;
end

function SuperSurvivorGroup:getMembersInRange(referencePoint, range, isListening)
	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled, "function: SuperSurvivorGroup:getMembersInRange() called");
	local TableOut = {};
	--
	for i = 1, #self.Members do
		local workingID = self.Members[i];

		if ((workingID ~= nil)) and (SSM:Get(workingID) ~= nil) then
			local distance = GetDistanceBetween(SSM:Get(workingID):Get(), referencePoint);

			if (distance <= range)
				and ((not isListening)
					or (SSM:Get(workingID):getCurrentTask() == "Listen")
				)
			then
				table.insert(TableOut, SSM:Get(workingID));
			end
		end
	end

	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled,
		"--- function: SuperSurvivorGroup:getMembersInRange() END ---"
	);
	return TableOut;
end

function SuperSurvivorGroup:AllSpokeTo()
	local members = self:getMembers();
	--
	for x = 1, #members do
		--
		for y = 1, #members do
			members[x]:SpokeTo(members[y]:getID());
		end
	end
end

function SuperSurvivorGroup:getIdleMember(ofThisRole, closest)
	for i = 1, #self.Members do
		local workingID = self.Members[i];
		--
		if (workingID ~= nil)
			and (SSM:Get(workingID):isInAction() == false)
			and ((SSM:Get(workingID):getGroupRole() == ofThisRole)
				or (ofThisRole == "Any") or (ofThisRole == nil))
		then
			return SSM:Get(workingID);
		end
	end

	return nil;
end

function SuperSurvivorGroup:getMembersThisCloseCount(range, referencePoint)
	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled,
		"function: SuperSurvivorGroup:getMembersThisCloseCount() called"
	);
	local count = 0;

	for i = 1, #self.Members do
		local workingID = self.Members[i];

		if (workingID ~= nil) and (SSM:Get(workingID)) then
			local distance = GetDistanceBetween(referencePoint, SSM:Get(workingID):Get());

			if (distance <= range) then
				count = count + 1;
			end
		end
	end
	CreateLogLine("SuperSurvivorGroup", isLocalLoggingEnabled,
		"--- function: SuperSurvivorGroup:getMembersThisCloseCount() end ---"
	);
	return count;
end

function SuperSurvivorGroup:PVPAlert(attacker)
	local count = 0;
	--
	for i = 1, #self.Members do
		local workingID = self.Members[i];
		local ss = SSM:Get(workingID);
		--
		if (ss) then
			local member = SSM:Get(workingID):Get();
			--
			if (workingID ~= nil) and (member) and (member:CanSee(attacker)) then
				member:getModData().hitByCharacter = true;
			end
		end
	end
	return count;
end

function SuperSurvivorGroup:getMemberCount()
	return #self.Members;
end

function SuperSurvivorGroup:isMember(survivor)
	return CheckIfTableHasValue(self.Members, survivor:getID());
end

-- Cows: WHAT ARE THE VALID ROLES? THERE ARE NO DOCUMENTATIONS!
function SuperSurvivorGroup:addMember(newSurvivor, Role)
	if (newSurvivor == nil) or (newSurvivor:getID() == nil) then
		return false;
	end

	local currentGroup = newSurvivor:getGroup();
	--
	if (currentGroup) then
		currentGroup:removeMember(newSurvivor:getID());
	end

	--if(newSurvivor:getGroupID() == self.ID) then return false end
	if (Role == nil) then
		Role = "Worker";
	end

	if (newSurvivor ~= nil) and (not CheckIfTableHasValue(self.Members, newSurvivor:getID())) then
		table.insert(self.Members, newSurvivor:getID());

		newSurvivor:setGroupRole(Role);
		newSurvivor:setGroupID(self.ID);

		if (Role == Get_SS_UIActionText("Job_Leader")) then
			self:setLeader(newSurvivor:getID());
		end
		return self.Members[#self.Members];
	elseif (newSurvivor ~= nil) then
		newSurvivor:setGroupID(self.ID);
		return nil;
	end
end

function SuperSurvivorGroup:checkMember(newSurvivorID)
	if (newSurvivorID ~= nil) and (not CheckIfTableHasValue(self.Members, newSurvivorID)) then
		table.insert(self.Members, newSurvivorID);
	end
end

function SuperSurvivorGroup:removeMember(ID)
	local member = SSM:Get(ID);
	if (member) then
		member:setGroupID(nil);
	end

	if (CheckIfTableHasValue(self.Members, ID)) then
		--#region
		for i = 1, #self.Members do
			--
			if (ID == self.Members[i]) then
				table.remove(self.Members, i);
			end
		end
	end
end

function SuperSurvivorGroup:stealingDetected(thief)
	for i = 1, #self.Members do
		local workingID = self.Members[i];
		local workingSS = SSM:Get(workingID);
		--
		if (workingID ~= nil) and (thief ~= nil)
			and (thief:getModData().ID ~= nil)
			and (workingSS ~= nil)
			and (workingSS:getGroupID() == self.ID)
		then
			--
			if (self:getWarnPlayer(thief:getModData().ID)) and SSM:Get(workingID):Get():CanSee(thief) then
				SSM:Get(workingID):Speak(Get_SS_Dialogue("IAttackFoodThief"));
				thief:getModData().semiHostile = true;
				SSM:Get(workingID):Get():getModData().hitByCharacter = true;
			elseif (not self:getWarnPlayer(thief:getModData().ID)) and SSM:Get(workingID):Get():CanSee(thief) then
				SSM:Get(workingID):Speak(Get_SS_Dialogue("IWarnFoodThief"));
				self:WarnPlayer(thief:getModData().ID);
			end
		end
	end
end

function SuperSurvivorGroup:getTaskCount(task)
	local count = 0;
	--
	for i = 1, #self.Members do
		local SS = SSM:Get(self.Members[i]);
		--
		if (SS ~= nil and SS:getCurrentTask() == task) then
			count = count + 1;
		end
	end

	return count;
end

function SuperSurvivorGroup:Save()
	local tabletoSave = {};
	tabletoSave[1] = #self.Members;
	tabletoSave[2] = self.Leader;
	table.save(tabletoSave, "SurvivorGroup" .. tostring(self.ID) .. "metaData");
	table.save(self.Members, "SurvivorGroup" .. tostring(self.ID));
	table.save(self.Bounds, "SurvivorGroup" .. tostring(self.ID) .. "Bounds");

	tabletoSave = {};
	table.sort(self.GroupAreas);

	for k, v in pairs(self.GroupAreas) do
		local area = self.GroupAreas[k];

		for i = 1, #area do
			table.insert(tabletoSave, area[i]);
		end
	end

	table.save(tabletoSave, "SurvivorGroup" .. tostring(self.ID) .. "Areas");
end

function SuperSurvivorGroup:Load()
	local tabletoSave = table.load("SurvivorGroup" .. tostring(self.ID) .. "metaData");
	--
	if (tabletoSave) then
		local temp = tonumber(tabletoSave[1]);
		self.Leader = tonumber(tabletoSave[2]);
	end

	self.Members = table.load("SurvivorGroup" .. tostring(self.ID));
	--
	if self.Members then
		for i = 1, #self.Members do
			if (self.Members[i] ~= nil) then
				self.Members[i] = tonumber(self.Members[i]);
			end
		end
	else
		self.Members = {};
	end

	self.Bounds = table.load("SurvivorGroup" .. tostring(self.ID) .. "Bounds");
	--
	if (self.Bounds) then
		--
		for i = 1, #self.Bounds do
			if (self.Bounds[i] ~= nil) then
				self.Bounds[i] = tonumber(self.Bounds[i]);
			end
		end
	else
		self.Bounds = { 0, 0, 0, 0, 0 };
	end

	local AreasTable = table.load("SurvivorGroup" .. tostring(self.ID) .. "Areas");

	if (AreasTable) then
		table.sort(self.GroupAreas);
		local gcount = 1;
		--
		for k, v in pairs(self.GroupAreas) do
			if not AreasTable[gcount] then
				break;
			end
			--
			for i = 1, 5 do
				self.GroupAreas[k][i] = tonumber(AreasTable[gcount]);
				gcount = gcount + 1;
			end
		end
	end
end
