require "ISUI/ISLayoutManager"

DialogueWindow = ISCollapsableWindow:derive("DialogueWindow");


function DialogueWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function DialogueWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "NPC Dialogue";
	o.pin = false;
	--o:noBackground();
	o.currentCharacter = 0
	o.textspeed = 5
	o.speedticks = 0
	o.text = ""
	o.strlen = 0
	o.complete = false
	o.TalkingSSID = 0
	o.YesOrNoQuestion = false
	
	
	return o;
end

 
function DialogueWindow:skip()
	if(self:getIsVisible()) then
		self.currentCharacter = self.strlen 
		self:setText(self.text)
	end
end
		

function DialogueWindow:onUpdate()
		
	if(self:getIsVisible()) then
	local cutstring = string.sub(self.text,1,self.currentCharacter)
	
		if(self.strlen > self.currentCharacter) then
			self.speedticks = self.speedticks + 1
			if(self.speedticks > self.textspeed ) then
				self.currentCharacter = self.currentCharacter + 1
				
				--getSoundManager():PlaySound("blip", false, 0.3);	-- playing sounds dont work when paused
				self:setText(cutstring)
				self.speedticks = 0			
				
			end
		
		elseif(self.YesOrNoQuestion and not self.YesButton:getIsVisible()) then
			self.YesButton:setVisible(true)
			self.NoButton:setVisible(true)			
		end
	end
	
end

function DialogueWindow:start(SS,text,YesOrNoQuestion)
	
	
	if(is_array(text)) then
		self.text = "";
		for i=0,#text do
			if(text[i]) then
				self.text = self.text .. "\n" .. text[i];
			end
		end
	else 
		self.text = text
	end
	self.strlen = string.len(self.text)
	self.YesOrNoQuestion = YesOrNoQuestion
	
	self.TalkingSSID = SS:getID()
	self.complete = false
	self:setText("")
	self.currentCharacter = 1
	self:setVisible(true)
	setGameSpeed(0) -- pause game speed so dialogue can be read leaisurly
	self:setTitle(SS:getName())
	self.YesButton:setVisible(false)
	self.NoButton:setVisible(false)
	
	if(not YesOrNoQuestion) then self.ContinueButton:setVisible(true) 
	else self.ContinueButton:setVisible(false) end
	
	self.avatarPanel:setCharacter(SS.player)
	--self.avatarPanel:setZoom(4.0)
	
end


function DialogueWindow:setText(newText)
	self.HomeWindow.text = newText;
	self.HomeWindow:paginate();
end

function YesButtonPressed()
	local SS = SSM:Get(myDialogueWindow.TalkingSSID)
	print("SSQM: Answered Yes to question of survivor " .. tostring(SS:getName()))
	if(SS.YesResultActions == nil) then print("warning AnswerTriggerQuestionYes detect nil YesResultActions") end
	SSQM:QuestionAnswered(SS.TriggerName,"YES",SS.NoResultActions ,SS.YesResultActions,SS.ContinueResultActions)
	SS.HasQuestion = false -- erase question option
	SS.HasBikuri = false -- erase question option
	SS.NoResultActions = nil -- erase question option
	SS.YesResultActions = nil -- erase question option
	SS.ContinueResultActions = nil -- erase question option
	SS.TriggerName = nil -- erase question option
	setGameSpeed(1)
	myDialogueWindow:setVisible(false)
end
function NoButtonPressed()
	local SS = SSM:Get(myDialogueWindow.TalkingSSID)
	print("SSQM: Answered No to question of survivor " .. tostring(SS:getName()))
	if(SS.NoResultActions == nil) then print("warning AnswerTriggerQuestionNo detect nil NoResultActions") end
	SSQM:QuestionAnswered(SS.TriggerName,"NO",SS.NoResultActions ,SS.YesResultActions,SS.ContinueResultActions)
	SS.HasQuestion = false -- erase question option
	SS.HasBikuri = false -- erase question option
	SS.NoResultActions = nil -- erase question option
	SS.ContinueResultActions = nil -- erase question option
	SS.YesResultActions = nil -- erase question option
	SS.TriggerName = nil -- erase question option
	setGameSpeed(1)
	myDialogueWindow:setVisible(false)
end
function ContinueButtonPressed()	
	setGameSpeed(1)
	myDialogueWindow:setVisible(false)
	local SS = SSM:Get(myDialogueWindow.TalkingSSID)
	print("ContinueButtonPressed " .. tostring(myDialogueWindow.TalkingSSID))
	if(SS) then 
	SSQM:QuestionAnswered(SS.TriggerName,"CONTINUE",SS.NoResultActions ,SS.YesResultActions,SS.ContinueResultActions)
	SS.HasQuestion = false -- erase question option
	SS.HasBikuri = false -- erase question option
	SS.NoResultActions = nil -- erase question option
	SS.YesResultActions = nil -- erase question option
	SS.ContinueResultActions = nil -- erase question option
	SS.TriggerName = nil -- erase question option
	else
		print("error could not get SS from this ID " .. tostring(myDialogueWindow.TalkingSSID))	
	end 
	

end

function DialogueWindow:createChildren()

	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	self.HomeWindow = ISRichTextPanel:new(75, FONT_HGT_SMALL + 1, FONT_HGT_SMALL * 6 + 220, FONT_HGT_SMALL * 10 + 220);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow:ignoreHeightChange()
	self:addChild(self.HomeWindow)
	
	self.YesButton = ISButton:new(FONT_HGT_SMALL * 7 , FONT_HGT_SMALL + 225, 60, 25, "Yes", self, YesButtonPressed);			
	self.YesButton:setEnable(true);
	self.YesButton:initialise();
	--MyCallButton.textureColor.r = 255;
	self.YesButton:addToUIManager();
	self:addChild(self.YesButton)	
	self.YesButton:setVisible(true);
	
	self.NoButton = ISButton:new(FONT_HGT_SMALL * 7 + 120, FONT_HGT_SMALL + 225, 60, 25, "No", self, NoButtonPressed);			
	self.NoButton:setEnable(true);
	self.NoButton:initialise();
	--MyCallButton.textureColor.r = 255;
	self.NoButton:addToUIManager();
	self:addChild(self.NoButton)	
	self.NoButton:setVisible(true);
	
	self.ContinueButton = ISButton:new(FONT_HGT_SMALL * 7 + 60, FONT_HGT_SMALL + 225, 60, 25, "Continue", self, ContinueButtonPressed);			
	self.ContinueButton:setEnable(true);
	self.ContinueButton:initialise();
	--MyCallButton.textureColor.r = 255;
	self.ContinueButton:addToUIManager();
	self:addChild(self.ContinueButton)	
	self.ContinueButton:setVisible(true);
	
	
	self.avatarPanel = ISCharacterScreenAvatar:new(0, 35, 100, 185)
	self.avatarPanel:setVisible(true)
	self:addChild(self.avatarPanel)
	self.avatarPanel:setOutfitName("Foreman", false, false)
	self.avatarPanel:setState("idle")
	self.avatarPanel:setDirection(IsoDirections.S)
	self.avatarPanel:setIsometric(false)
	
		
	ISCollapsableWindow.createChildren(self);
end
function DialogueWindow:Load(newText)	
	self:setText(newText)	
end

function DialogueWindowCreate()
	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	myDialogueWindow = DialogueWindow:new(400, 270, FONT_HGT_SMALL * 6 + 290, FONT_HGT_SMALL * 10 + 150)
	myDialogueWindow:addToUIManager();
	myDialogueWindow:setVisible(false);
	myDialogueWindow.pin = true;
	myDialogueWindow.resizable = true
	
	
	
end

Events.OnGameStart.Add(DialogueWindowCreate);