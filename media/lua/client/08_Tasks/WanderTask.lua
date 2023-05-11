WanderTask = {}
WanderTask.__index = WanderTask

local isLocalLoggingEnabled = false;

function WanderTask:new(superSurvivor)
	CreateLogLine("WanderTask", isLocalLoggingEnabled, "function: WanderTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.parent = superSurvivor
	o.Name = "Wander"
	o.OnGoing = true

	return o
end

function WanderTask:isComplete()
	return false
end

function WanderTask:isValid()
	if not self.parent then
		return false
	else
		return true
	end
end

function WanderTask:update()
	CreateLogLine("WanderTask", isLocalLoggingEnabled, "function: WanderTask:update() called");
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		local sq = getCell():getGridSquare(self.parent.player:getX() + ZombRand(-10, 10),
			self.parent.player:getY() + ZombRand(-10, 10), self.parent.player:getZ());
		if (sq ~= nil) then
			self.parent:walkTo(sq);
		else
			CreateLogLine("WanderTask", isLocalLoggingEnabled, "error getting walk sq");
		end
	end
end
