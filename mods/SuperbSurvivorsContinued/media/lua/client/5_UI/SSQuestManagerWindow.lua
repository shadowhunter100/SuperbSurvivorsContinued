require "ISUI/ISLayoutManager"

QuestInfoWindow = ISCollapsableWindow:derive("QuestInfoWindow");


function QuestInfoWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function QuestInfoWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "Quest Info";
	o.pin = false;
	o:noBackground();
	return o;
end

function QuestInfoWindow:setText(newText)
	self.HomeWindow.text = newText;
	self.HomeWindow:paginate();
end


function QuestInfoWindow:createChildren()

	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	self.HomeWindow = ISRichTextPanel:new(0, FONT_HGT_SMALL + 1, FONT_HGT_SMALL * 6 + 300, FONT_HGT_SMALL * 10 + 300);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow:ignoreHeightChange()
	self:addChild(self.HomeWindow)
		
	ISCollapsableWindow.createChildren(self);
end
function QuestInfoWindow:Load(newText)	
	self:setText(newText)	
end

function QuestInfoWindowCreate()
	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	myQuestInfoWindow = QuestInfoWindow:new(400, 270, FONT_HGT_SMALL * 6 + 175, FONT_HGT_SMALL * 10 + 300)
	myQuestInfoWindow:addToUIManager();
	myQuestInfoWindow:setVisible(false);
	myQuestInfoWindow.pin = true;
	myQuestInfoWindow.resizable = true	
	
end

Events.OnGameStart.Add(QuestInfoWindowCreate);