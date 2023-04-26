QuestManager = {}
QuestManager.__index = QuestManager

function QuestManager:new()

	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.QuestUpdateCount = 0
	o.QuestUpdateLimit = 0
	o.Quests = {}
	o.QuestCount = 0
	o.Quests[0] = nil
	o.CurrentQuest = 0
	o.LastQuest = 0
	o.LastLastQuest = 0
	o.Enabled = false
	o.BannerMSG = nil	
	o.ShownBannerMSGCount = 0
	
	return o

end

function QuestManager:SaveToFile()
--todo
end

function QuestManager:LoadFromFile()
--todo
end

function QuestManager:SetBannerMSG(message)
	
	if(self.BannerMSG ~= nil) then 
		self.BannerMSG:removeFromUIManager()
		self.BannerMSG = nil
	end
	
	self.BannerMSG = TutorialMessage:new(30, 30, 500, 50, true, message);
	self.BannerMSG:initialise();
	self.BannerMSG:addToUIManager();
	self.BannerMSG:setAlwaysOnTop(true);
	self.ShownBannerMSGCount = 0
end

function QuestManager:EditTriggerEnabled(Name,NewValue)

	for i=0,self.QuestCount do
		if (self.Quests[i] ~= nil) and (self.Quests[i].TriggerName == Name) then 
			self.Quests[i].Enabled = NewValue 
		end
	end

end

function QuestManager:PerformTriggerActions(Actions,TriggerName)
 --todo
	if(not Actions) then
		print("SSQM: warning nil actions fed into PerformTriggerActions")
		return false
	end
 
	print("SSQM: number of actions to run is for trigger ".. tostring(TriggerName) .." is " .. tostring(#Actions))
	for i=0,#Actions do
		if(Actions[i]) then
			print("Action# " .. tostring(#Actions) .. " " .. tostring(Actions[i].ActionType))
			if(Actions[i].ActionType == "NPCDialogue") then
			
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
				if(TargetSurvivor) then
					print("SSQM: DialogueTask " .. tostring(TargetSurvivor:getName()))
					TargetSurvivor:getTaskManager():AddToTop(DialogueTask:new(TargetSurvivor,getSpecificPlayer(0), Actions[i].Value,false,TriggerName,{},{},{},false))
				end
				
			elseif(Actions[i].ActionType == "NPCDialogueW") then
			
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
				if(TargetSurvivor) then
					print("SSQM: DialogueTask /w Window " .. tostring(TargetSurvivor:getName()))
						--TargetSurvivor:getTaskManager():removeTaskFromName("Direct Dialogue")
						TargetSurvivor:getTaskManager():AddToTop(DialogueTask:new(TargetSurvivor,getSpecificPlayer(0), Actions[i].Value,false,TriggerName,{},{},Actions[i].ResultActions,true))
						TargetSurvivor:getTaskManager():setTaskUpdateLimit(0)
					
				end
				
			elseif(Actions[i].ActionType == "BannerMessage") then
				self:SetBannerMSG(Actions[i].Value)
			elseif(Actions[i].ActionType == "NPCSpeak") then
			
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
				if(TargetSurvivor) then
					print("SSQM: NPCSpeak " .. tostring(TargetSurvivor:getName()))
					TargetSurvivor.player:faceThisObject(getSpecificPlayer(0))
					TargetSurvivor:Speak(Actions[i].Value)
				end
			elseif(Actions[i].ActionType == "setNPCFollow") then
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
							
				if(TargetSurvivor) then
					print("SSQM: FollowTask " .. tostring(TargetSurvivor:getName()))
					if(Actions[i].Value == true) then 
						TargetSurvivor:getTaskManager():AddToTop(FollowTask:new(TargetSurvivor,getSpecificPlayer(0))) 
						TargetSurvivor:getTaskManager():setTaskUpdateLimit(0)
						TargetSurvivor:setAIMode("Follow")
					else 
						print("SSQM: Clearing FollowTask " .. tostring(TargetSurvivor:getName()))
						TargetSurvivor:getTaskManager():clear() 
						TargetSurvivor:setAIMode("Stand Ground")
					end
				end
				
			elseif(Actions[i].ActionType == "setNPCWantsToTalk") then -- adds the "!" exlclamation mark
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
							
				if(TargetSurvivor) then
					print("SSQM: setNPCWantsToTalk " .. tostring(TargetSurvivor:getName()) .. " " .. tostring(Actions[i].Value))					
					TargetSurvivor.HasBikuri = Actions[i].Value					
				end
				
			elseif(Actions[i].ActionType == "BeginQuest") then
			
				--make spiffo banner message and set the quest info window with details
				self:SetBannerMSG("You have Accepted Quest '" .. tostring(Actions[i].Value).."'\n\nPress 'i' For more quest details")
				myQuestInfoWindow:setText("No Quest Details provided")
				if(Actions[i].Desc) then
					myQuestInfoWindow:setText(Actions[i].Desc)
				end
				getSoundManager():PlaySound("unlock", false, 0.8);	
				
			elseif(Actions[i].ActionType == "EndQuest") then
			
				--make spiffo banner message and set the quest info window with details
				self:SetBannerMSG("You have Completed Quest '" .. tostring(Actions[i].Value).."'")
				myQuestInfoWindow:setText("Quest Complete")
				getSoundManager():PlaySound("unlock", false, 0.8);	
			
				
			elseif(Actions[i].ActionType == "SpawnItem") then
			
				local z = 0;
				if Actions[i].SquareZ then z = Actions[i].SquareZ end
				
				local q = 1;
				if Actions[i].ItemTypeQuantity then q = Actions[i].ItemTypeQuantity end
				
				local dropItem =  Actions[i].ItemType								
				local square = getCell():getGridSquare(Actions[i].SquareX,Actions[i].SquareY,0)	
				
				for i=0, q do
					print("spawning item: " .. tostring(dropItem))
					square:AddWorldInventoryItem(dropItem, (ZombRand(99)/100), (ZombRand(99)/100),0)
				end
				
			elseif(Actions[i].ActionType == "EnableTrigger") then
			
				print("SSQM: enabled trigger " .. tostring(Actions[i].Value))
				self:EditTriggerEnabled(Actions[i].Value,true)
				
			elseif(Actions[i].ActionType == "DisableTrigger") then
			
				print("SSQM: disabled trigger " .. tostring(Actions[i].Value))
				self:EditTriggerEnabled(Actions[i].Value,false)
				
			elseif(Actions[i].ActionType == "NPCGivesReward") then
				
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
				if(TargetSurvivor) then
					print("SSQM: added GiveRewardToPlayerTask")
					TargetSurvivor:getTaskManager():AddToTop(GiveRewardToPlayerTask:new(TargetSurvivor,getSpecificPlayer(0),Actions[i].ItemType,Actions[i].ItemTypeQuantity))
					TargetSurvivor:getTaskManager():setTaskUpdateLimit(0)
				end
				
			elseif(Actions[i].ActionType == "CompleteQuest") then
			
				--make spiffo banner message and clear the quest info window with details
				self:SetBannerMSG("You have Completed Quest '" .. tostring(Actions[i].Value) .."'")
				myQuestInfoWindow:setText("Quest Complete")
				
			elseif(Actions[i].ActionType == "NPCQuestionDialogueDialgue") then
			
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
				if(TargetSurvivor) then
					print("SSQM: added task QuestionDialogueTask")
						--TargetSurvivor:getTaskManager():removeTaskFromName("Direct Dialogue")
						local task = DialogueTask:new(TargetSurvivor,getSpecificPlayer(0), Actions[i].Value,true,TriggerName,Actions[i].YesResultActions,Actions[i].NoResultActions,{},false)
						TargetSurvivor:getTaskManager():AddToTop(task)
						TargetSurvivor:getTaskManager():setTaskUpdateLimit(0)
					
				end
				
			elseif(Actions[i].ActionType == "NPCQuestionDialogueDialgueW") then
			
				local TargetSurvivor = SSM:GetSurvivorByName(Actions[i].NPCName)
				if(TargetSurvivor) then
					print("SSQM: added task QuestionDialogueTask")
					local task = DialogueTask:new(TargetSurvivor,getSpecificPlayer(0), Actions[i].Value,true,TriggerName,Actions[i].YesResultActions,Actions[i].NoResultActions,{},true)
					TargetSurvivor:getTaskManager():AddToTop(task)
					TargetSurvivor:getTaskManager():setTaskUpdateLimit(0)
				end
				
			elseif(Actions[i].ActionType == "SpawnPresetNPC") then
			
				print("SSQM: added SuperSurvivorPresetSpawnThis")
				SuperSurvivorPresetSpawnThis(Actions[i].Value)
			
			end
		end
	end

end

function QuestManager:CheckTrigger(Trigger, EventTypeToCheck,Param1)
	
	if(not Trigger) then return end
	
	if(EventTypeToCheck == "KillNPC") and (Trigger.ConditionType == "KillNPC") and (Param1 == Trigger.NPCName) then
		print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
		return true		
		
	elseif(EventTypeToCheck == "TalkToNPC") and (Trigger.ConditionType == "TalkToNPC") and (Param1 == Trigger.NPCName) then
		print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
		return true
		
	elseif(EventTypeToCheck == "AttackNPC") and (Trigger.ConditionType == "AttackNPC") and (Param1 == Trigger.NPCName) then
		print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
		return true
		
	elseif(Trigger.ConditionType=="DistanceToSquare") and (EventTypeToCheck == "DistanceToSquare") then
			local player = getSpecificPlayer(0)
			local x = player:getX()
			local y = player:getY()
			local dist = getDistanceBetweenPoints(x,y,Trigger.SquareX,Trigger.SquareY)
			--print("TEMP: ".. tostring(Trigger.TriggerName) .. " DistanceToSquare is " .. tostring(dist) .." need less than " .. tostring(Trigger.Distance) )
			if(dist <= Trigger.Distance) and Trigger.Enabled then 
				print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
				return true 
			end
	elseif(Trigger.ConditionType=="NPCDistanceToSquare") and (EventTypeToCheck == "NPCDistanceToSquare") then
			local SS = SSM:GetSurvivorByName(Trigger.NPCName)
			if(SS) then
				local dist = getDistanceBetweenPoints(Trigger.SquareX,Trigger.SquareY,SS.player:getX(),SS.player:getY())
				if(dist <= Trigger.Distance) and Trigger.Enabled then 
					print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
					return true 
				end
			end
	elseif(Trigger.ConditionType=="NPCtoNPCDistance") and (EventTypeToCheck == "NPCtoNPCDistance")  then
			
			local SSA = SSM:GetSurvivorByName(Trigger.NPCNameA)
			local SSB = SSM:GetSurvivorByName(Trigger.NPCNameB)
			if(SSA and SSB) then
				local dist = getDistanceBetweenPoints(SSA.player:getX(),SSA.player:getY(),SSB.player:getX(),SSB.player:getY())
				--print("dist = " .. tostring(dist))
				if(dist <= Trigger.Distance) and Trigger.Enabled then 
					print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
					return true 
				end
			end
	elseif(Trigger.ConditionType=="DistanceToNPC") and (EventTypeToCheck == "DistanceToNPC")  then
			local player = getSpecificPlayer(0)
			local x = player:getX()
			local y = player:getY()
			local SS = SSM:GetSurvivorByName(Trigger.NPCName)
			if(SS) then
				local dist = getDistanceBetweenPoints(x,y,SS.player:getX(),SS.player:getY())
				--print("dist = " .. tostring(dist))
				if(dist <= Trigger.Distance) and Trigger.Enabled then 
					print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
					return true 
				end
			end
	elseif(Trigger.ConditionType=="FindItem") and (EventTypeToCheck == "FindItem") then
			local player = getSpecificPlayer(0)
			local inv = player:getInventory()
			local item = inv:getItemFromTypeRecurse(Trigger.ItemType)
			if(item) and Trigger.Enabled then 
				print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
				return true 
			end
			item = inv:getItemFromTypeRecurse("Base."..tostring(Trigger.ItemType))
			if(item) and Trigger.Enabled then 
				print("SSQM: quest/trigger " .. tostring(Trigger.TriggerName) .. " Was Triggered via TriggerType:" .. tostring(Trigger.ConditionType).. " param1: " .. tostring(Param1))
				return true 
			end
	end
	
	
	
	return false
end


function QuestManager:AddToTop(newTrigger)
	
	if(newTrigger == nil) then return false end
		
	self.CurrentQuest = newTrigger.Name
	
	
	self.QuestUpdateCount = 0
	for i=self.QuestCount,1,-1 do
		self.Quests[i] = self.Quests[i-1]
	end
	
	self.Quests[0] = newTrigger
	
	self.QuestCount = self.QuestCount + 1
	
end

function QuestManager:AddToBottom(newTrigger)

	self.Quests[self.QuestCount] = newTrigger 
	self.QuestCount = self.QuestCount + 1

end

function QuestManager:Display()	
	for i=0,self.QuestCount do
		if (self.Quests[i] ~= nil) then return print(self.Quests[i].Name) end
	end
end

function QuestManager:clear()

	for i=0,self.QuestCount do  -- before clearing run the force complete task of any task that has one
		if (self.Quests[i] ~= nil) and (self.Quests[i].ForceComplete ~= nil) then return self.Quests[i]:ForceComplete() end
	end

	self.QuestCount = 0
	self.Quests[0] = nil
end

function QuestManager:moveDown()

	
	while ((not self.Quests[0]) or (self.Quests[0]:isComplete() == true)) do
	
		if(self.Quests[0] ~= nil) and (self.Quests[0].OnComplete ~= nil) then self.Quests[0]:OnComplete() end
	
		if(self.QuestCount <= 1) then 
			self:clear()	
			break
		else		
			for i=0,self.QuestCount do
				
				self.Quests[i-1] = self.Quests[i]		

			end		
			self.QuestCount = self.QuestCount - 1
		end
	end
		
	self.QuestUpdateCount = 0
	--self.QuestUpdateLimit = 0
	
	return false
end

function QuestManager:getCurrentQuest()
	if (self.Quests[0] ~= nil) and (self.Quests[0].Name ~= nil) then return self.Quests[0].Name
	else return "None" end
end

function QuestManager:getQuest()
	if (self.Quests[0] ~= nil) then return self.Quests[0]
	else return nil end
end

function QuestManager:getThisQuest(index)
	if (self.Quests[index] ~= nil) then return self.Quests[index]
	else return nil end
end

function QuestManager:removeQuestFromName(thisName)

	for i=0,self.QuestCount do
		if (self.Quests[i] ~= nil) and (self.Quests[i].Name == thisName) then 
		 if(self.Quests[i].OnComplete) then  self.Quests[i]:OnComplete() end
		 self.Quests[i] = nil;
		end
	end
	return nil
end

function QuestManager:getQuestFromName(thisName)
	
	print("SSQM: QuestCount: " .. tostring(self.QuestCount))
	for i=0,self.QuestCount do
		if(self.Quests[i]) then
			--print("SSQM: "..tostring(self.Quests[i].TriggerName) .. " = " .. tostring(thisName) .. " ?")
			if (self.Quests[i] ~= nil) and (self.Quests[i].TriggerName == thisName) then return self.Quests[i] end
		end
	end
	return nil
end

function QuestManager:QuestionAnswered(triggername,answer, noresultactions,yesresultactions,continueactions)
	
	local trigger = self:getQuestFromName(triggername)
	if(not trigger) then
		print("SSQM: warning failed to get quest/trigger from name: " .. tostring(getQuestFromName))		
		return
	end
	
	if(answer == "YES") then
		self:PerformTriggerActions(yesresultactions,triggername)
	elseif(answer == "CONTINUE") then
		print("continueactions: ")
		self:PerformTriggerActions(continueactions,triggername)
	elseif(answer == "NO") then
		self:PerformTriggerActions(noresultactions,triggername)
	end
end
function QuestManager:TalkedTo(thisNPCName)
	self:update("TalkToNPC",thisNPCName)
end

function QuestManager:update(ThisEventType, Param1)


	if (self == nil) or not self.Enabled then	
		return
	end
	
	
	--print("SSQM: number of quests to check is " .. tostring(self.QuestCount))
	
	for i=0,self.QuestCount do
		if (self.Quests[i] ~= nil) then 
		
			local trigger = self.Quests[i]
		
			if(trigger ~= nil) 
			and (trigger ~= false)  then 
				
				if(self:CheckTrigger(trigger, ThisEventType, Param1))
				then					
					
					if (trigger.Enabled) then
						--trigger:lol()					
						print("SSQM: quest/trigger " .. tostring(trigger.TriggerName) .. " Was Triggered w " .. tostring(Param1))
						self:PerformTriggerActions(trigger.ResultActions,trigger.TriggerName)	
						
						if(trigger.TriggerOnlyOnce == true) then
							self:EditTriggerEnabled(trigger.TriggerName,false) -- disable if TriggerOnlyOnce is true
						end
					else
						print("SSQM: quest/trigger " .. tostring(trigger.TriggerName) .. " diabled therefore not Triggered w " .. tostring(Param1))					
					end
					
				end
			
			end
		
		end
	end

	
	
		
	
end

--and add the gloabl quest manager object
SSQM = QuestManager:new()

function QuestManagerInit(newplayerID)
		
	SSQM.Enabled = true

end

Events.OnCreatePlayer.Add(QuestManagerInit)


function QuestManagerKeyDownHandle(keyNum)

	if(getSpecificPlayer(0)) then
	
		--print("keyNum: " .. tostring(keyNum))
		--57 = space
		--23 = "i"
		
	
		if( keyNum == getCore():getKey("Open Quest Info Window")) then -- i key
			myQuestInfoWindow:setVisible(not myQuestInfoWindow:getIsVisible())
		elseif( keyNum == 57) then -- space key
				
			if(SSQM and SSQM.BannerMSG) then
			SSQM.BannerMSG:removeFromUIManager()
			SSQM.BannerMSG = nil
			SSQM.ShownBannerMSGCount = 0
			end
			
			myDialogueWindow:skip()
		
		elseif( keyNum == 199) then -- home key
		
			myQuestInfoWindow:setVisible(true)
			getSpecificPlayer(0):Say(tostring(getSpecificPlayer(0):getX()) .. "," .. tostring(getSpecificPlayer(0):getY()))
			
		elseif( keyNum == 200) then -- up key
		
		
		elseif( keyNum == 208) then -- down key
		--[[
		local player = getSpecificPlayer(0)
		player:Say("teli")
		player:setX(10816)
		player:setY(10060)
		player:setZ(0)
		player:setLx(10816)
		player:setLy(10060)
		player:setLz(0)
		]]
		end
		
	end

end

Events.OnKeyPressed.Add(QuestManagerKeyDownHandle)



function QuestManagerUpdate() 
	--print("QuestManagerUpdate tick")
	SSQM:update("NPCtoNPCDistance") -- check if distance to square events should be triggered every minute
	SSQM:update("DistanceToSquare") -- check if distance to square events should be triggered every minute
	SSQM:update("NPCDistanceToSquare") -- check if distance to square events should be triggered every minute
	SSQM:update("DistanceToNPC") -- check if distance to square events should be triggered every minute
	-- need to add "DistanceToNPC"
	SSQM:update("FindItem") -- check if player has item
	
	SSQM.ShownBannerMSGCount = SSQM.ShownBannerMSGCount + 1
	if(SSQM.ShownBannerMSGCount >= 3) and (SSQM.BannerMSG ~= nil) then
		SSQM.BannerMSG:removeFromUIManager()
		SSQM.BannerMSG = nil
		SSQM.ShownBannerMSGCount = 0
	end
	
end

Events.EveryOneMinute.Add(QuestManagerUpdate) 


function QuestManagerOnRenderTickUpdate() 
	if(myDialogueWindow) then myDialogueWindow:onUpdate() end
end
Events.OnRenderTick.Add(QuestManagerOnRenderTickUpdate)


