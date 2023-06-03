SuperSurvivorManager = {}
SuperSurvivorManager.__index = SuperSurvivorManager

local isLocalLoggingEnabled = false;

function SuperSurvivorManager:new()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.SuperSurvivors = {}
	o.SurvivorCount = 3
	o.MainPlayer = 0

	return o
end

function SuperSurvivorManager:getRealPlayerID()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:getRealPlayerID() called");
	return self.MainPlayer
end

function SuperSurvivorManager:init()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:init() called");
	self.SuperSurvivors[0] = SuperSurvivor:newSet(getSpecificPlayer(0))
	self.SuperSurvivors[0]:setID(0)
end

function SuperSurvivorManager:setPlayer(player, ID)
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:setPlayer() called");
	self.SuperSurvivors[ID] = SuperSurvivor:newSet(player)
	self.SuperSurvivors[0]:setID(ID)
	self.SuperSurvivors[0]:setName("Player " .. tostring(ID))

	return self.SuperSurvivors[ID];
end

function SuperSurvivorManager:LoadSurvivor(ID, square)
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:LoadSurvivor() called");
	if (not checkSaveFileExists("Survivor" .. tostring(ID))) then return false end

	if (ID ~= nil) and (square ~= nil) then --
		if (self.SuperSurvivors[ID] ~= nil) and (self.SuperSurvivors[ID].player ~= nil) then
			if (self.SuperSurvivors[ID]:isInCell()) then
				return false
			else
				self.SuperSurvivors[ID]:deleteSurvivor()
			end
		end

		self.SuperSurvivors[ID] = SuperSurvivor:newLoad(ID, square)
		if (self.SuperSurvivors[ID]:Get():getPrimaryHandItem() == nil) and (self.SuperSurvivors[ID]:getWeapon() ~= nil) then
			self.SuperSurvivors[ID]:Get():setPrimaryHandItem(self.SuperSurvivors[ID]:getWeapon())
		end

		self.SuperSurvivors[ID]:refreshName()

		if (self.SuperSurvivors[ID]:Get():getModData().isHostile == true) then
			self.SuperSurvivors[ID]:setHostile(true)
		end

		if (self.SurvivorCount == nil) then
			self.SurvivorCount = 1
		end

		if (ID > self.SurvivorCount) then
			self.SurvivorCount = ID;
		end
		self.SuperSurvivors[ID].player:getModData().LastSquareSaveX = nil
		self.SuperSurvivors[ID]:SaveSurvivor()

		local melewep = self.SuperSurvivors[ID].player:getModData().meleWeapon
		local gunwep = self.SuperSurvivors[ID].player:getModData().gunWeapon

		if (melewep ~= nil) then
			self.SuperSurvivors[ID].LastMeleUsed = self.SuperSurvivors[ID].player:getInventory():FindAndReturn(melewep)
			if not self.SuperSurvivors[ID].LastMeleUsed then
				self.SuperSurvivors[ID].LastMeleUsed = self.SuperSurvivors
					[ID]:getBag():FindAndReturn(melewep)
			end
		end

		if (gunwep ~= nil) then
			self.SuperSurvivors[ID].LastGunUsed = self.SuperSurvivors[ID].player:getInventory():FindAndReturn(gunwep)
			if not self.SuperSurvivors[ID].LastGunUsed then
				self.SuperSurvivors[ID].LastGunUsed = self.SuperSurvivors
					[ID]:getBag():FindAndReturn(gunwep)
			end
		end

		if (self.SuperSurvivors[ID]:getAIMode() == "Follow") then
			self.SuperSurvivors[ID]:getTaskManager():AddToTop(FollowTask:new(self.SuperSurvivors[ID], nil))
		elseif (self.SuperSurvivors[ID]:getAIMode() == "Guard") then
			if self.SuperSurvivors[ID]:getGroup() ~= nil then
				local area = self.SuperSurvivors[ID]:getGroup():getGroupArea("GuardArea")
				if (area) then
					self.SuperSurvivors[ID]:getTaskManager():AddToTop(WanderInAreaTask:new(self.SuperSurvivors[ID], area))
					self.SuperSurvivors[ID]:getTaskManager():setTaskUpdateLimit(10)
				else
					self.SuperSurvivors[ID]:getTaskManager():AddToTop(GuardTask:new(self.SuperSurvivors[ID],
						self.SuperSurvivors[ID].player:getCurrentSquare()))
				end
			end
		elseif (self.SuperSurvivors[ID]:getAIMode() == "Patrol") then
			self.SuperSurvivors[ID]:getTaskManager():AddToTop(PatrolTask:new(self.SuperSurvivors[ID], nil, nil))
		elseif (self.SuperSurvivors[ID]:getAIMode() == "Wander") then
			self.SuperSurvivors[ID]:getTaskManager():AddToTop(WanderTask:new(self.SuperSurvivors[ID]))
		elseif (self.SuperSurvivors[ID]:getAIMode() == "Stand Ground") then
			self.SuperSurvivors[ID]:getTaskManager():AddToTop(GuardTask:new(self.SuperSurvivors[ID],
				self.SuperSurvivors[ID].player:getCurrentSquare()))
			self.SuperSurvivors[ID]:setWalkingPermitted(false)
		elseif (self.SuperSurvivors[ID]:getAIMode() == "Doctor") then
			self.SuperSurvivors[ID]:getTaskManager():AddToTop(DoctorTask:new(self.SuperSurvivors[ID]))
		end


		local phi = self.SuperSurvivors[ID]:Get():getPrimaryHandItem() -- to trigger onEquipPrimary
		self.SuperSurvivors[ID]:Get():setPrimaryHandItem(nil)
		self.SuperSurvivors[ID]:Get():setPrimaryHandItem(phi)
	end
end

function SuperSurvivorManager:spawnSurvivor(isFemale, square)
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:spawnSurvivor() called");
	if (square ~= nil) then
		local newSurvivor = SuperSurvivor:newSurvivor(isFemale, square)

		if (newSurvivor ~= nil) then
			self.SuperSurvivors[self.SurvivorCount + 1] = newSurvivor
			self.SurvivorCount = self.SurvivorCount + 1;
			self.SuperSurvivors[self.SurvivorCount]:setID(self.SurvivorCount)
			return self.SuperSurvivors[self.SurvivorCount]
		else
			return nil
		end
	end
end

function SuperSurvivorManager:Get(thisID)
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:Get() called");
	if (not self.SuperSurvivors[thisID]) then
		return nil
	else
		return self.SuperSurvivors[thisID]
	end
end

function SuperSurvivorManager:OnDeath(ID)
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:OnDeath() called");
	self.SuperSurvivors[ID] = nil
end

function SuperSurvivorManager:UpdateSurvivorsRoutine()
	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil and self.MainPlayer ~= i) then
			if (self.SuperSurvivors[i]:updateTime())
				and (not self.SuperSurvivors[i].player:isAsleep())
				and (self.SuperSurvivors[i]:isInCell())
			then
				self.SuperSurvivors[i]:updateSurvivorStatus();
			end
			-- Cows: Have the npcs wander if there are no tasks, otherwise they are stuck in place...
			if (self.SuperSurvivors[i]:getCurrentTask() == "None")
				and (SurvivorRoles[self.SuperSurvivors[i]:getGroupRole()] == nil) -- Cows: This check is to ensure actual assigned roles do not wander off to die.
			then
				self.SuperSurvivors[i]:NPCTask_DoWander();
			end
		end
	end
end

---comment
function SuperSurvivorManager:AsleepHealAll()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:AsleepHealAll() called");
	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil) and (self.MainPlayer ~= i) and (self.SuperSurvivors[i].player) then
			self.SuperSurvivors[i].player:getBodyDamage():AddGeneralHealth(SleepGeneralHealRate);
		end
	end
end

function SuperSurvivorManager:PublicExecution(SSW, SSV)
	local isFleeCallLogged = false;
	CreateLogLine("SuperSurvivorManager", isFleeCallLogged, "function: PublicExecution() called");
	local maxdistance = 20

	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil) and (self.SuperSurvivors[i]:isInCell()) then
			local distance = GetDistanceBetween(self.SuperSurvivors[i]:Get(), getSpecificPlayer(0))
			if (distance < maxdistance) and (self.SuperSurvivors[i]:Get():CanSee(SSV:Get())) then
				if (not self.SuperSurvivors[i]:isInGroup(SSW:Get()) and not self.SuperSurvivors[i]:isInGroup(SSV:Get())) then
					if (self.SuperSurvivors[i]:usingGun()) and (ZombRand(2) == 1) then
						--chance to attack with gun if see someone near by get executed
						self.SuperSurvivors[i]:Get():getModData().hitByCharacter = true
					else
						CreateLogLine("SuperSurvivorManager", isFleeCallLogged, " is fleeing from PublicExecution");
						-- flee from the crazy murderer						
						self.SuperSurvivors[i]:getTaskManager():AddToTop(FleeFromHereTask:new(self.SuperSurvivors[i],
							SSW:Get():getCurrentSquare()))
					end
					self.SuperSurvivors[i]:SpokeTo(SSW:Get():getModData().ID)
					self.SuperSurvivors[i]:SpokeTo(SSV:Get():getModData().ID)
				end
			end
		end
	end
end

function SuperSurvivorManager:GunShotHandle(SSW)
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:GunShotHandle() called");
	local maxdistance = 20
	local weapon = getSpecificPlayer(0):getPrimaryHandItem()

	if not weapon then return false end

	local range = weapon:getSoundRadius();
	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil) and (self.SuperSurvivors[i]:isInCell()) then
			local distance = GetDistanceBetween(self.SuperSurvivors[i]:Get(), getSpecificPlayer(0))

			if (self.SuperSurvivors[i].player:getModData().surender)
				and (distance < maxdistance)
				and self.SuperSurvivors[i]:Get():CanSee(SSW:Get())
				and self.SuperSurvivors[i].player:CanSee(getSpecificPlayer(0))
			then
				-- flee from the crazy murderer
				self.SuperSurvivors[i]:getTaskManager():AddToTop(FleeFromHereTask:new(self.SuperSurvivors[i],
					SSW:Get():getCurrentSquare()))
				self.SuperSurvivors[i]:SpokeTo(SSW:Get():getModData().ID)
			end

			if (self.SuperSurvivors[i].player:getModData().isHostile
					or self.SuperSurvivors[i]:getCurrentTask() == "Guard"
					or self.SuperSurvivors[i]:getCurrentTask() == "Patrol")
				and self.SuperSurvivors[i]:getTaskManager():getCurrentTask() ~= "Surender"
				and not self.SuperSurvivors[i].player:isDead()
				and not self.SuperSurvivors[i]:RealCanSee(getSpecificPlayer(0))
				and (GetDistanceBetween(getSpecificPlayer(0), self.SuperSurvivors[i].player) <= range)
			then
				self.SuperSurvivors[i]:getTaskManager():AddToTop(GoCheckItOutTask:new(self.SuperSurvivors[i],
					getSpecificPlayer(0):getCurrentSquare()))
			end
		end
	end
end

function SuperSurvivorManager:GetClosest()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:GetClosest() called");
	local closestSoFar = 20
	local closestID = 0

	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil) and (self.SuperSurvivors[i]:isInCell()) then
			local distance = GetDistanceBetween(self.SuperSurvivors[i]:Get(), getSpecificPlayer(0))
			if (distance < closestSoFar) then
				closestID = i
				closestSoFar = distance
			end
		end
	end

	if (closestID ~= 0) then
		return self.SuperSurvivors[closestID]
	else
		return nil
	end
end

function SuperSurvivorManager:GetClosestNonParty()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:GetClosestNonParty() called");
	local closestSoFar = 20;
	local closestID = 0;

	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil) and (self.SuperSurvivors[i]:isInCell()) then
			local distance = GetDistanceBetween(self.SuperSurvivors[i]:Get(), getSpecificPlayer(0));
			if (distance < closestSoFar) and (self.SuperSurvivors[i]:getGroupID() == nil) then
				closestID = i;
				closestSoFar = distance;
			end
		end
	end

	if (closestID ~= 0) then
		return self.SuperSurvivors[closestID];
	else
		return nil;
	end
end

function SuperSurvivorManager:SaveAll()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:SaveAll() called");
	for i = 1, self.SurvivorCount + 1 do
		if (self.SuperSurvivors[i] ~= nil) and (self.SuperSurvivors[i]:isInCell()) then
			self.SuperSurvivors[i]:SaveSurvivor()
		end
	end
end

SSM = SuperSurvivorManager:new()

function LoadSurvivorMap()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:LoadSurvivorMap() called");
	local tempTable = {}
	tempTable = table.load("SurvivorManagerInfo");

	if (tempTable) and (tempTable[1]) then
		SSM.SurvivorCount = tonumber(tempTable[1]);
	else
		CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "LoadSurvivorMap Failed, possibly corrupted");
	end

	SurvivorLocX = KVTableLoad("SurvivorLocX")
	SurvivorLocY = KVTableLoad("SurvivorLocY")
	SurvivorLocZ = KVTableLoad("SurvivorLocZ")

	local fileTable = {}

	for k, v in pairs(SurvivorLocX) do --- trying new way of saving & loading survivor map
		local key = SurvivorLocX[k] .. SurvivorLocY[k] .. SurvivorLocZ[k]

		if (not fileTable[key]) then
			fileTable[key] = {}
		end

		table.insert(fileTable[key], tonumber(k))
	end

	return fileTable
end

function SaveSurvivorMap()
	CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "SuperSurvivorManager:SaveSurvivorMap() called");
	local tempTable = {}
	tempTable[1] = SSM.SurvivorCount
	table.save(tempTable, "SurvivorManagerInfo");

	if (not SurvivorMap) then return false end

	KVTablesave(SurvivorLocX, "SurvivorLocX");
	KVTablesave(SurvivorLocY, "SurvivorLocY");
	KVTablesave(SurvivorLocZ, "SurvivorLocZ");
end
