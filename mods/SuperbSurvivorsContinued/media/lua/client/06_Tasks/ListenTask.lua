require "04_Group.SuperSurvivorManager";

ListenTask = {}
ListenTask.__index = ListenTask

local isLocalLoggingEnabled = false;

function ListenTask:new(superSurvivor, TalkToMe, selfInitiated)
	CreateLogLine("ListenTask", isLocalLoggingEnabled, "function: ListenTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.WasSelfInit = selfInitiated
	o.Aite = TalkToMe
	o.SSAite = SSM:Get(TalkToMe:getModData().ID)
	o.parent = superSurvivor
	o.Name = "Listen"
	o.OnGoing = true
	o.TicksSinceLastExchange = 0
	o.Spoke = false
	o.IsNPConNPC = ((o.parent.player:isLocalPlayer() == false) and (TalkToMe:isLocalPlayer() == false))
	o.parent:StopWalk()
	superSurvivor:Speak(Get_SS_DialogueSpeech("Respond"))

	return o
end

function ListenTask:isComplete()
	if (self.TicksSinceLastExchange > 15) or (self.parent:getDangerSeenCount() > 0) or (self.parent:needToFollow()) then
		if (not self.parent:isInGroup(self.Aite)) then
			self.parent:Speak(Get_SS_Dialogue("Bye1"))
		end
		return true
	else
		return false
	end
end

function ListenTask:isValid()
	if not self.parent or not self.Aite or not self.SSAite then
		return false
	else
		return true
	end
end

function ListenTask:Talked()
	self.TicksSinceLastExchange = 0
end

function ListenTask:update()
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		self.TicksSinceLastExchange = self.TicksSinceLastExchange + 1
		local distance = GetDistanceBetween(self.parent.player, self.Aite)
		if (distance > 1.8) then
			self.parent:walkTo(self.Aite:getCurrentSquare())
		else
			self.parent:StopWalk()
			self.parent.player:faceThisObject(self.Aite)
			if (self.Spoke == false) then
				self.Spoke = true
				self.TicksSinceLastExchange = 0
				self.parent:SpokeTo(self.Aite:getModData().ID)
				if (self.parent:Get():getModData().InitGreeting ~= nil) and (not self.IsNPConNPC) then
					self.parent:Speak(self.parent:Get():getModData().InitGreeting)
				elseif (self.WasSelfInit) then
					self.parent:Speak(Get_SS_Dialogue("HiThere"))
				else
					self.parent:Speak(Get_SS_Dialogue("WhatYouWant"))
				end
			elseif (self.parent.player:isLocalPlayer() == false) then
				if (ZombRand(2) == 0) and
					(self.parent:isSpeaking() == false) and
					(self.SSAite:isSpeaking() == false) and (not CanIdleChat) then
					self.parent:Speak(Get_SS_DialogueSpeech("IdleChatter"))
				end
			end
		end
	else
		self.TicksSinceLastExchange = self.TicksSinceLastExchange + 0.5
	end
end
