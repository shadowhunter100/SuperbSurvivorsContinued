WanderInBaseTask = {}
WanderInBaseTask.__index = WanderInBaseTask

local isLocalLoggingEnabled = false;

function WanderInBaseTask:new(superSurvivor)
	CreateLogLine("WanderInBaseTask", isLocalLoggingEnabled, "function: WanderInBaseTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self
	if (superSurvivor == nil) then return nil end
	o.Complete = false
	o.parent = superSurvivor
	o.Name = "Wander In Base"
	o.OnGoing = true
	o.Group = nil
	o.UpdateCount = 0

	return o
end

function WanderInBaseTask:isComplete()
	return self.Complete
end

function WanderInBaseTask:isValid()
	if not self.parent or not self.Group then
		self.Complete = true
		return false
	else
		return true
	end
end

function WanderInBaseTask:update()
	CreateLogLine("WanderInBaseTask", isLocalLoggingEnabled, "function: WanderInBaseTask:update() called");
	if self.parent:getGroupID() ~= nil then
		self.Group = SSGM:GetGroupById(self.parent:getGroupID())
	end

	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) and (ZombRand(4) == 0) then
		local sq = self.Group:getRandomBaseSquare()
		if (sq ~= nil) then
			self.parent:walkTo(sq);
		else
			CreateLogLine("WanderInBaseTask", isLocalLoggingEnabled, "error getting walk sq");
		end
	end

	self.UpdateCount = self.UpdateCount + 1
	if (self.UpdateCount > 300) then self.Complete = true end
end
