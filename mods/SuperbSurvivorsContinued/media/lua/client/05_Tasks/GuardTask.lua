GuardTask = {}
GuardTask.__index = GuardTask

local isLocalLoggingEnabled = false;

function GuardTask:new(superSurvivor, square)
	CreateLogLine("GuardTask", isLocalLoggingEnabled, "function: GuardTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.Square = square
	o.parent = superSurvivor
	o.Name = "Guard"
	o.OnGoing = true

	return o
end

function GuardTask:isComplete()
	return false
end

function GuardTask:isValid()
	if not self.parent or not self.Square then
		return false
	else
		return true
	end
end

function GuardTask:update()
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) and (self.parent.player:getCurrentSquare() ~= self.Square) and (self.parent:getDangerSeenCount() == 0) then
		self.parent:walkToDirect(self.Square)
	end
end
