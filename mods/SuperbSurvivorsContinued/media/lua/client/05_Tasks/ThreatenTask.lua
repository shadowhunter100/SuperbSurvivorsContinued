ThreatenTask = {}
ThreatenTask.__index = ThreatenTask

local isLocalLoggingEnabled = false;

function ThreatenTask:new(superSurvivor, Aite, Demands)
	CreateLogLine("ThreatenTask", isLocalLoggingEnabled, "function: ThreatenTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	Demands = "Scram"

	o.parent = superSurvivor
	o.Name = "Threaten"
	o.OnGoing = false
	o.Demands = Demands    -- scram or drop loot
	o.DemandsSpeech = Demands -- scram or drop loot
	o.Aite = Aite
	o.DealBroke = false
	o.Complete = false
	o.StartedThreatening = false
	o.DistanceAtThreat = 99
	o.theDistance = 999
	o.SquareAtThreat = nil
	o.TicksWaitedForResponse = 0

	return o
end

function ThreatenTask:isComplete()
	if (not self.Complete) then
		return false
	else
		self.parent:StopWalk()
		return true
	end
end

function ThreatenTask:isValid()
	if (not self.parent) then
		return false
	else
		return true
	end
end

function ThreatenTask:dealBreaker()
	if self.StartedThreatening then
		if self.Demands == "Scram" then
			if self.Aite.player:isAiming() then return true end
			if (self.DistanceAtThreat - self.theDistance) > 2 then return true end
			if (self.TicksWaitedForResponse > 20) and self.parent:RealCanSee(self.Aite.player) then return true end
		end
	end

	if (self.parent.player:getModData().hitByCharacter) then return true end -- Aite is actively pvping this survivor so no deal

	return false
end

function ThreatenTask:dealComplete()
	if self.StartedThreatening then
		if self.Demands == "Scram" then -- WIP - Cows: "Demands" was undefined... prefixing it with "self." should fix it.
			if self.theDistance >= 20 and not self.parent.player:CanSee(self.Aite.player) then
				return true
			end
		end
	end

	return false
end

function ThreatenTask:update()
	local isFleeCallLogged = false;
	CreateLogLine("ThreatenTask", isFleeCallLogged, "function: ThreatenTask:update() called");
	local weapon = self.parent.player:getPrimaryHandItem(); -- WIP - Cows: This is a test assignment...

	if (not self:isValid()) or (self:isComplete()) then return false end

	if self.parent:hasGun() then -- Despite the name, it means 'has gun in the npc's hand'
		if (self.parent:needToReadyGun(weapon)) then -- WIP - Cows: "weapon" is undefined...
			self.parent:ReadyGun(weapon)
			return false
		end
	end

	self.theDistance = GetDistanceBetween(self.Aite, self.parent.player)
	self.parent:NPC_ShouldRunOrWalk()
	self.parent:NPC_EnforceWalkNearMainPlayer()

	if (self.StartedThreatening == true) then
		if (self:dealBreaker()) then
			self.parent:Speak("alright you asking for it!")
			self.Aite.player:getModData().dealBreaker = true
			self.Complete = true
		end

		if (self:dealComplete()) then
			self.parent.player:NPCSetAiming(false)
			self.Complete = true
		end

		self.TicksWaitedForResponse = self.TicksWaitedForResponse + 1
	end


	if (self.parent.player:IsAttackRange(self.Aite:getX(), self.Aite:getY(), self.Aite:getZ())) or (self.theDistance < 0.65) then
		self.parent:StopWalk()
		self.parent.player:NPCSetAiming(true)
		self.parent.player:faceThisObject(self.Aite.player)
		if (self.StartedThreatening == false) then
			self.parent:Speak("get out of here or else!")
			self.DistanceAtThreat = self.theDistance
			self.SquareAtThreat = self.Aite.player:getCurrentSquare()

			if self.Aite.player:isLocalPlayer() == false then
				self.Aite:StopWalk()
				self.Aite:getTaskManager():clear()
				CreateLogLine("ThreatenTask", isFleeCallLogged, "Survivor is fleeing from here");
				self.Aite:getTaskManager():AddToTop(FleeFromHereTask:new(self.parent, self.Aite.player:getCurrentSquare()))
			end
			self.StartedThreatening = true
		end

	elseif (self.parent:isWalkingPermitted()) then
		self.parent:NPC_ManageLockedDoors() -- This function should force walking away if stuck
		self.parent:NPC_ShouldRunOrWalk()
		self.parent:NPC_EnforceWalkNearMainPlayer()

		local cs = self.Aite.player:getCurrentSquare()

		if self.parent:hasGun() then -- Despite the name, it means 'has gun in the npc's hand'
			if (self.parent:needToReadyGun(weapon)) then
				self.parent:ReadyGun(weapon)
				return false
			else
				self.parent:walkToDirect(cs)
				self.parent:NPC_ShouldRunOrWalk()
				self.parent:NPC_EnforceWalkNearMainPlayer()
			end
		else
			self.parent:walkToDirect(cs)
			self.parent:NPC_ShouldRunOrWalk()
			self.parent:NPC_EnforceWalkNearMainPlayer()
		end
	else -- Added to the 'if anything fails, go somewhere else'
		self.parent:NPCTask_DoWander()
		self.parent:NPCTask_DoAttemptEntryIntoBuilding()
		return false
	end
end
