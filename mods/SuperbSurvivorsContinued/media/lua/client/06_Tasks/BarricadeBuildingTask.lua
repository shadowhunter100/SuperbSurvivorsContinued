BarricadeBuildingTask = {}
BarricadeBuildingTask.__index = BarricadeBuildingTask

local isLocalLoggingEnabled = false;

function BarricadeBuildingTask:new(superSurvivor)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.parent = superSurvivor
	o.Name = "Barricade Building"
	o.OnGoing = true
	o.TargetBuilding = nil
	o.TargetSquare = nil
	o.Window = nil
	o.PreviousSquare = nil
	o.Complete = false
	o.parent:setLastWeapon()

	CreateLogLine("BarricadeBuildingTask", isLocalLoggingEnabled, "function: BarricadeBuildingTask:new() called");

	local inv = o.parent.player:getInventory()
	local temp = inv:FindAndReturn("Hammer")
	if (temp) then
		o.Hammer = temp
	else
		o.Hammer = inv:AddItem("Base.Hammer")
	end

	temp = inv:FindAndReturn("Plank")
	if (temp) then
		o.Plank = temp
	else
		o.Plank = inv:AddItem("Base.Plank")
	end

	if inv:getItemCount("Base.Nails", true) < 2 then
		inv:AddItem(instanceItem("Base.Nails"))
		inv:AddItem(instanceItem("Base.Nails"))
	end

	return o
end

function BarricadeBuildingTask:ForceComplete()
	self:OnComplete()
	self.Complete = true
end

function BarricadeBuildingTask:OnComplete()
	self.parent:reEquipLastWeapon()
end

function BarricadeBuildingTask:isComplete()
	if (self.Complete) then
		self:ForceComplete()
	end
	return self.Complete
end

function BarricadeBuildingTask:isValid()
	if not self.parent then
		return false
	else
		return true
	end
end

function BarricadeBuildingTask:update()
	CreateLogLine("BarricadeBuildingTask", isLocalLoggingEnabled, "function: BarricadeBuildingTask:update() called");
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		local building = self.parent:getBuilding();
		if (building ~= nil) then
			if (self.Window == nil) then self.Window = self.parent:getUnBarricadedWindow(building) end
			if (not self.Window) then
				CreateLogLine("BarricadeBuildingTask", isLocalLoggingEnabled, "No window found...");
				self.Complete = true
				return false
			end
		else
			self.Complete = true
			return false
		end

		local barricade = self.Window:getBarricadeForCharacter(self.parent.player)
		local distance = GetDistanceBetween(self.parent.player, self.Window:getIndoorSquare());
		if (distance > 2) or (self.parent.player:getZ() ~= self.Window:getZ()) then
			local attempts = self.parent:getWalkToAttempt(self.Window:getIndoorSquare())
			self.parent:walkTo(self.Window:getIndoorSquare())

			if (attempts > 8) then
				self.Complete = true
				return false
			end
		elseif barricade == nil or (barricade:canAddPlank()) then
			self.parent.player:setPrimaryHandItem(self.Hammer)
			self.parent.player:setSecondaryHandItem(self.Plank)
			if not self.parent.player:getInventory():contains("Nails", true) then
				self.parent.player:getInventory():AddItem("Base.Nails")
			end

			self.parent:StopWalk()
			ISTimedActionQueue.add(ISBarricadeAction:new(self.parent.player, self.Window, false, false, 100));


			self.Window = nil
		else
			self.Window = nil
		end
	else
		CreateLogLine("BarricadeBuildingTask", isLocalLoggingEnabled, "waiting for non action");
	end
end
