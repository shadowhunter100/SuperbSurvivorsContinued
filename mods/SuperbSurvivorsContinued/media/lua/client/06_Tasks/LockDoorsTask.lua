LockDoorsTask = {}
LockDoorsTask.__index = LockDoorsTask

local isLocalLoggingEnabled = false;

function LockDoorsTask:new(superSurvivor, lock)
	CreateLogLine("LockDoorsTask", isLocalLoggingEnabled, "function: LockDoorsTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.Lock = lock
	o.parent = superSurvivor
	o.Name = "Lock Doors"
	o.OnGoing = true
	o.TargetBuilding = nil
	o.TargetSquare = nil
	o.PreviousSquare = nil
	o.Complete = false

	return o
end

function LockDoorsTask:isComplete()
	return self.Complete
end

function LockDoorsTask:isValid()
	if not self.parent then
		return false
	else
		return true
	end
end

function LockDoorsTask:update()
	CreateLogLine("LockDoorsTask", isLocalLoggingEnabled, "function: LockDoorsTask:update() called");
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		local door;
		local building = self.parent:getBuilding();
		if (building ~= nil) then
			door = GetUnlockedDoor(building, self.parent.player)
			if (not door) then
				CreateLogLine("LockDoorsTask", isLocalLoggingEnabled, "No door found...");
				self.Complete = true
				return false
			end
		else
			self.Complete = true
			return false
		end


		local distance = GetDistanceBetween(self.parent.player, GetDoorsInsideSquare(door));

		if (distance > 2) or (self.parent.player:getZ() ~= door:getZ()) then
			self.parent:walkToDirect(GetDoorsInsideSquare(door))
		else
			if (door:IsOpen()) then
				door:ToggleDoor(self.parent.player)
			else
				self.parent.player:getEmitter():playSound("LockDoor", false);
				door:setIsLocked(true)
			end
		end
	end
end
