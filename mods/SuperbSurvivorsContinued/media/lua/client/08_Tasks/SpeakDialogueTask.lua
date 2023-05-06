SpeakDialogueTask = {}
SpeakDialogueTask.__index = SpeakDialogueTask

local isLocalLoggingEnabled = false;

function SpeakDialogueTask:new(superSurvivor, TalkToMe, DialogueID)
	CreateLogLine("SpeakDialogueTask", isLocalLoggingEnabled, "function: SpeakDialogueTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.WasSelfInit = selfInitiated -- WIP - UNDEFINED GLOBAL?
	o.Aite = TalkToMe
	o.parent = superSurvivor
	o.Name = "Speak Dialogue"

	o.Current = 1
	-- WIP - "SurvivorDialogue" does not exist... unless it is referencing another mod.
	-- o.Dialogue = SurvivorDialogue[DialogueID]; 

	if (not o.Dialogue) then return nil end

	return o
end

function SpeakDialogueTask:isComplete()
	if self.Current > #self.Dialogue then
		return true
	else
		return false
	end
end

function SpeakDialogueTask:isValid()
	if not self.parent or not self.Aite then
		return false
	else
		return true
	end
end

function SpeakDialogueTask:update()
	CreateLogLine("SpeakDialogueTask", isLocalLoggingEnabled, "function: SpeakDialogueTask:update() called");
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		local distance = getDistanceBetween(self.parent.player, self.Aite)
		if (distance > 1.8) then
			self.parent:walkTo(self.Aite:getCurrentSquare())
		elseif (self:isSpeaking() == false) then
			self.parent:StopWalk()
			self.parent.player:faceThisObject(self.Aite)

			self.parent:Speak(self.Dialogue[self.Current])
			self.Current = self.Current + 1
		end
	end
end
