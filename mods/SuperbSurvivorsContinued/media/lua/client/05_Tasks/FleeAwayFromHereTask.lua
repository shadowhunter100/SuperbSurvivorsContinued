FleeFromHereTask = {}
FleeFromHereTask.__index = FleeFromHereTask

local isLocalLoggingEnabled = false;

function FleeFromHereTask:new(superSurvivor, fleeFromHere)
	CreateLogLine("FleeAwayFromHereTask", isLocalLoggingEnabled, "function: FleeFromHereTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self
	superSurvivor:setRunning(true)
	o.parent = superSurvivor
	o.Name = "Flee From Spot"
	o.OnGoing = false
	o.fleeFromHere = fleeFromHere

	-- WIP - Cows: Need to figure out what is causing npcs to run around doing nothing when zombies are spotted indoors...
	if o.parent.TargetBuilding ~= nil then
		o.parent:MarkAttemptedBuildingExplored(o.parent.TargetBuilding)
	end -- otherwise he just keeps running back to the building though the threat likely lingers there

	return o
end

function FleeFromHereTask:isComplete()
	if GetDistanceBetween(self.parent.player, self.fleeFromHere) > PanicDistance then
		self.parent:StopWalk()
		self.parent:setRunning(false)
		return true
	else
		return false
	end
end

function FleeFromHereTask:isValid()
	if not self.parent or self:isComplete() then
		return false
	else
		return true
	end
end

function FleeFromHereTask:update()
	if (not self:isValid()) then return false end
	self.parent:setSneaking(false);
	self.parent:setRunning(true);

	if (self.parent.player and self.fleeFromHere) then
		self.parent:walkTo(GetFleeSquare(self.parent.player, self.fleeFromHere, 7))
		self.parent:NPC_EnforceWalkNearMainPlayer()
	end
end
