AttemptEntryIntoBuildingTask = {}
AttemptEntryIntoBuildingTask.__index = AttemptEntryIntoBuildingTask

local isLocalLoggingEnabled = false;

function AttemptEntryIntoBuildingTask:new(superSurvivor, building)
	CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "function: AttemptEntryIntoBuildingTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.parent = superSurvivor
	o.Name = "Enter New Building"
	o.OnGoing = false
	o.Window = nil
	o.TryWindow = false
	o.Door = nil
	o.TargetSquare = nil
	o.PreviousSquare = nil
	o.ClimbThroughWindowAttempts = 0
	o.WanderDirection = nil
	o.TicksSinceReversedDir = 0
	o.ReEquipGunOnFinish = false
	o.BreakInAttempts = 0
	o.Toggle = false

	if (building) then o.parent.TargetBuilding = building end

	return o
end

function AttemptEntryIntoBuildingTask:OnComplete()
	if (self.ReEquipGunOnFinish) then
		self.parent:reEquipGun()
		self.parent:setSneaking(false)
	end
end

function AttemptEntryIntoBuildingTask:isComplete()
	if (self.parent:inUnLootedBuilding()) or (self.parent.TargetBuilding == nil) or (self.parent:isInBuilding(self.parent.TargetBuilding)) then
		self.parent:MarkBuildingExplored(self.parent:getBuilding())
		return true
	else
		return false
	end
end

function AttemptEntryIntoBuildingTask:isValid()
	if not self.parent or not self.parent.TargetBuilding then
		return false
	else
		return true
	end
end

function AttemptEntryIntoBuildingTask:giveUpOnBuilding()
	if (self.parent.TargetBuilding ~= nil) then
		self.parent:MarkAttemptedBuildingExplored(self.parent.TargetBuilding)
		self.parent.TargetBuilding = nil
		self.TargetSquare = nil
		self.TryWindow = false
	end
end

function AttemptEntryIntoBuildingTask:update()
	CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "function: AttemptEntryIntoBuildingTask:update() called");

	if (not self:isValid()) then return false end

	if (self.parent:getSeenCount() == 0) then self.parent:setSneaking(true) end

	if (self.parent:getDangerSeenCount() > 1) or (self.ClimbThroughWindowAttempts > 4) then
		CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "giving up on window climb through...");
		self:giveUpOnBuilding()
	end
	if (self.parent:isInAction() == false) then
		if (self.TargetSquare == nil) then
			self.TargetSquare = GetRandomFreeBuildingSquare(self.parent.TargetBuilding);
		end
		if (self.TargetSquare ~= nil) then
			local door = self.parent:inFrontOfDoor()

			if self.TryWindow == false
				and (door ~= nil)
				and (door:isLocked()
					or door:isLockedByKey()
					or door:isBarricaded())
				and (not door:isDestroyed())
			then
				self.TryWindow = true
				self.Door = door
			end

			if (self.parent:inFrontOfWindow()) then
				self.TryWindow = true
			end
			if not self.TryWindow and not self.TryBreakDoor then
				if (self.parent:getWalkToAttempt(self.TargetSquare) < 6) then -- was 10
					self.parent:walkToDirect(self.TargetSquare)   -- If this doesn't work, use the other
					self.parent:walkTo(self.TargetSquare)
					CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "Trying a door");
				else
					self.TryWindow = true
				end
			elseif self.TryWindow then
				if (self.Window == nil) then
					self.Window = self.parent:getUnBarricadedWindow(self.parent.TargetBuilding)
					CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "Trying a window");
				end

				if (not self.Window) then
					if (self.parent.LastMeleUsed ~= nil) then
						self.TryWindow = nil
						self.TryBreakDoor = true
						if (self.parent.LastMeleUsed ~= self.parent.player:getPrimaryHandItem()) then self.ReEquipGunOnFinish = true end
						self.parent:reEquipMele()
						return false
					else
						CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "Giving up on a building");
						self:giveUpOnBuilding();
					end
				else
					local distanceToWindow = GetDistanceBetween(self.Window, self.parent.player)

					if distanceToWindow > 1.0 then
						local outsidesquare = GetOutsideSquare(self.Window, self.parent.TargetBuilding)
						if (outsidesquare == nil) or (self.parent:getWalkToAttempt(outsidesquare) > 10) then
							self.TryWindow = nil
							self.TryBreakDoor = true
							if (self.parent.LastMeleUsed ~= self.parent.player:getPrimaryHandItem()) then self.ReEquipGunOnFinish = true end
							self.parent:reEquipMele()
							return false
						end
						self.parent:walkToDirect(outsidesquare)
					else
						self.parent.player:faceThisObject(self.Window)
						if (self.Window:isSmashed() == false) and (self.Window:IsOpen() == false) then
							if (self.parent:isInBase()) then
								self.Window:ToggleWindow(self.parent.player)
							else
								self.parent:StopWalk()
								ISTimedActionQueue.add(ISSmashWindow:new(self.parent.player, self.Window, 20))
							end
							self.parent:Wait(3)
						else
							if (self.Window:isSmashed()) and (self.Window:isGlassRemoved() == false) and self.parent:hasWeapon() then
								self.parent:StopWalk()
								ISTimedActionQueue.add(ISRemoveBrokenGlass:new(self.parent.player, self.Window, 20))

								self.parent:Wait(1)
							else
								if (self.Window:getZ() < 2) and ((self.Window:IsOpen() == true) or (self.Window:isGlassRemoved() or (not self.parent:hasWeapon()))) then
									self.parent:Wait(3)
									self.parent.player:setBlockMovement(false)
									self.parent.player:climbThroughWindow(self.Window)
									self.parent.player:setBlockMovement(true)
									self.ClimbThroughWindowAttempts = self.ClimbThroughWindowAttempts + 1
								end
							end
						end
					end
				end
			elseif self.TryBreakDoor then

				local doorSquare = GetDoorsOutsideSquare(self.Door, self.parent.player)

				if (doorSquare == nil) then
					CreateLogLine("AttemptEntryIntoBuildingTask", isLocalLoggingEnabled, "No door found...");
					self:giveUpOnBuilding();
				end

				local distanceToDoor = GetDistanceBetween(self.parent.player, doorSquare)

				if (distanceToDoor > 1.0) then
					self.parent:walkToDirect(self.Door)
				else
					if (self.BreakInAttempts > 10) then
						self:giveUpOnBuilding()
					else
						if (self.Door) then self.parent.player:faceThisObject(self.Door) end
						local isInBuilding = (self.parent:getBuilding() == self.TargetBuilding)
						if (self.Door) then --(not isInBuilding) then
							if (not self.Toggle) or (self.Door == nil) then
								self.parent:walkTo(self.TargetSquare)
							else
								self.parent.player:AttemptAttack()
							end

							self.Toggle = not self.Toggle
							self.BreakInAttempts = self.BreakInAttempts + 1
						elseif (self.Door == nil) then
							return true
						end
					end
				end
			end
		else
			self:giveUpOnBuilding()
		end
	end
end
