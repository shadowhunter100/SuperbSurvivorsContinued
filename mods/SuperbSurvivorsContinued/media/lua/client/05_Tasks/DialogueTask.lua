DialogueTask = {}
DialogueTask.__index = DialogueTask

local isLocalLoggingEnabled = false;

function DialogueTask:new(superSurvivor, TalkToMe, Dialogue, Trigger, YesResultActions,
						  NoResultActions, ContinueResultActions, useWindowDialogue)
	CreateLogLine("DialogueTask", isLocalLoggingEnabled, "DialogueTask:new() Called");

	local o = {}
	setmetatable(o, self)
	self.__index = self

	if (not IsItemArray(Dialogue)) then
		Dialogue = { Dialogue }
	end

	superSurvivor:StopWalk()

	-- WIP - Cows: When and where was "selfInitiated" assigned a value? This is still unassigned...
	o.WasSelfInit = selfInitiated
	o.Aite = TalkToMe
	o.parent = superSurvivor
	o.Name = "Direct Dialogue"
	o.TriggerName = Trigger
	o.useWindowDialogue = useWindowDialogue
	o.YesResultActions = YesResultActions
	o.ContinueResultActions = ContinueResultActions
	o.NoResultActions = NoResultActions

	o.Current = 1
	o.Dialogue = Dialogue

	if (not o.Dialogue) then return nil end

	return o
end

function DialogueTask:isComplete()
	if self.Current > #self.Dialogue then
		self.parent.ContinueResultActions = self.ContinueResultActions --
		self.parent.TriggerName = self.TriggerName               --
		return true
	else
		return false
	end
end

function DialogueTask:isValid()
	if not self.parent or not self.Aite then
		return false
	else
		return true
	end
end

function DialogueTask:update()
	CreateLogLine("DialogueTask", isLocalLoggingEnabled, "DialogueTask:update() Called");
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		local distance = GetDistanceBetween(self.parent.player, self.Aite)
		if (distance > 1.8) then
			self.parent:walkTo(self.Aite:getCurrentSquare())
		else
			self.parent:StopWalk()
			self.parent.player:faceThisObject(self.Aite)

			if (not self.useWindowDialogue) then
				self.parent:Speak(self.Dialogue[self.Current])
				self.parent.player:getModData().lastThingIsaid = self.Dialogue[self.Current]
				self.Current = self.Current + 1
				self.parent:Wait(4)
			else
				self.Current = 99999
				self.parent:Wait(1)
			end

			self:isComplete()
		end
	end
end
