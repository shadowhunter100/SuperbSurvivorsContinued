DialogueTask = {}
DialogueTask.__index = DialogueTask

function DialogueTask:new(superSurvivor, TalkToMe, Dialogue,isYesOrNoQuestion,Trigger,YesResultActions,NoResultActions,ContinueResultActions,useWindowDialogue)

	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	if(not is_array(Dialogue)) then
		Dialogue = {Dialogue}
	end
	
	superSurvivor:StopWalk()
		
	o.WasSelfInit = selfInitiated
	o.Aite = TalkToMe
	o.parent = superSurvivor
	o.Name = "Direct Dialogue"
	o.TriggerName = Trigger
	o.useWindowDialogue = useWindowDialogue
	o.isYesOrNoQuestion = isYesOrNoQuestion
	o.YesResultActions = YesResultActions
	o.ContinueResultActions = ContinueResultActions
	o.NoResultActions = NoResultActions
	
	o.Current = 1
	o.Dialogue = Dialogue
	
	if(isYesOrNoQuestion) and (YesResultActions == nil) then
		print("Warning: YesResultActions=nil on question dialogue!")
	else
		print("SSQM: YesResultActions were detected making DialogueTask for " .. tostring(superSurvivor:getName()))
	end
	
	if(not o.Dialogue) then return nil end
	
	
	
	return o

end

function DialogueTask:isComplete()
	if self.Current > #self.Dialogue then
	
		self.parent.ContinueResultActions = self.ContinueResultActions -- 
		self.parent.TriggerName = self.TriggerName -- 
		
		if(self.isYesOrNoQuestion) then
			self.parent.HasQuestion = true
			self.parent.NoResultActions = self.NoResultActions -- 
			self.parent.YesResultActions = self.YesResultActions -- 			
			print ("set QuestionTrigger moddata onto " .. tostring(self.parent:getName()))
		end
		return true
	else return false end	
end

function DialogueTask:isValid()
	if not self.parent or not self.Aite then return false 
	else return true end
end


function DialogueTask:update()
	
	if(not self:isValid()) then return false end
	
	if(self.parent:isInAction() == false) then
	
		local distance = getDistanceBetween(self.parent.player,self.Aite)
		if (distance > 1.8) then
			self.parent:walkTo(self.Aite:getCurrentSquare()) 				 		
		else
			self.parent:DebugSay("DialogueTask is about to trigger a StopWalk! ")
			self.parent:StopWalk()
			self.parent.player:faceThisObject(self.Aite)
			
			if(not self.useWindowDialogue) then
				self.parent:Speak(self.Dialogue[self.Current])
				self.parent.player:getModData().lastThingIsaid = self.Dialogue[self.Current]
				self.Current = self.Current + 1
				self.parent:Wait(4)
			else
				self.Current = 99999
				self.parent:Wait(1)
				print("SSQM: added task QuestionDialogueTaskW")
				myDialogueWindow:start(self.parent,self.Dialogue,self.isYesOrNoQuestion)
			end
			
			self:isComplete()
		end
	
	
	end

end
