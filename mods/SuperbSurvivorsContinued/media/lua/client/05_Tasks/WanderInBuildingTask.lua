WanderInBuildingTask = {}
WanderInBuildingTask.__index = WanderInBuildingTask

local isLocalLoggingEnabled = false;

function WanderInBuildingTask:new(superSurvivor, building)
	CreateLogLine("WanderInBuildingTask", isLocalLoggingEnabled, "function: WanderInBuildingTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.Complete = false
	o.parent = superSurvivor
	o.Name = "Wander In Building"
	o.OnGoing = true
	if building == nil and superSurvivor:getBuilding() ~= nil then
		o.Building = superSurvivor:getBuilding()
	elseif superSurvivor.TargetBuilding ~= nil then
		o.Building = superSurvivor.TargetBuilding
	else
		o.Building = building
	end

	return o
end

function WanderInBuildingTask:isComplete()
	return self.Complete
end

function WanderInBuildingTask:isValid()
	if not self.parent or not self.Building then
		self.Complete = true
		return false
	else
		return true
	end
end

function WanderInBuildingTask:update()
	if self.Building == nil and self.parent:getBuilding() ~= nil then
		self.Building = self.parent:getBuilding()
	elseif self.parent.TargetBuilding ~= nil then
		self.Building = self.parent.TargetBuilding
	end

	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) and (ZombRand(4) == 0) then
		local sq = GetRandomBuildingSquare(self.Building)
		if (sq ~= nil) and (not sq:isOutside()) then
			self.parent:walkTo(sq);
		else
			CreateLogLine("WanderInBuildingTask", isLocalLoggingEnabled, "error getting walk sq");
		end
	end
end
