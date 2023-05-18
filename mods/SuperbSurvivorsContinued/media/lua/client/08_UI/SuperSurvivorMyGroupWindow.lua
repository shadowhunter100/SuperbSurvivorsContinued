require "05_Other/SuperSurvivorManager";

GroupWindow = ISCollapsableWindow:derive("GroupWindow");

local isLocalLoggingEnabled = false;

function GroupWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

local function SSItemClickHandle()
	CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled, "SSItemClickHandle() called");
	local GID = SSM:Get(0):getGroupID()
	local members = SSGM:GetGroupById(GID):getMembers()
	local selected = tonumber(MyGroupWindow:getSelected())
	local member = members[selected]

end

function GroupWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = Get_SS_ContextMenuText("YourGroupMembers");
	o.pin = false;

	return o;
end

function GroupWindow:setText(newText)
	self.HomeWindow.text = newText;
	self.HomeWindow:paginate();
end

function GroupWindow:getSelected()
	local index = self.HomeWindow.selected;
	local item = self.HomeWindow.items[index];

	if (item) then
		return item.item
	else
		return nil
	end
end

function GroupWindow:setSelected(CodeName)
	for i = 1, #self.HomeWindow.items do
		local v = self.HomeWindow.items[i]

		if v.item == CodeName then
			self.HomeWindow.mouseoverselected = i
			self.HomeWindow.selected = i
			self.HomeWindow:ensureVisible(i)
			return true
		end
	end
end

function GroupWindow:AddItem(DisplayName, CodeName)
	self.HomeWindow:addItem(DisplayName, CodeName)
end

function GroupWindow:RemoveAll()
	self.HomeWindow:clear()
end

MyGroupMembers = {}
function GroupWindow:Update()
	local selected = self.HomeWindow.selected
	self.HomeWindow:clear()

	local GID = SSM:Get(0):getGroupID()
	local Group = SSGM:GetGroupById(GID)

	if (Group == nil) then
		CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled, "Fixing player has no group...");
		Group = SSGM:newGroup()
		Group:addMember(SSM:Get(0), Get_SS_ContextMenuText("Job_Leader"))
	end

	if (Group) then
		MyGroupMembers = Group:getMembers()

		if not Group:isMember(SSM:Get(0)) then
			CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled, "Fixing Player is not in own group...");
			Group:addMember(SSM:Get(0), Get_SS_ContextMenuText("Job_Leader"))
		elseif not Group:hasLeader() then
			CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled, "Fixing no group leader...");
			Group:setLeader(0)
		end

		--for index,value in ipairs(MyGroupMembers) do
		for index = 1, #MyGroupMembers do
			local value = MyGroupMembers[index]
			local name, role

			if (value.getName ~= nil) and (value:isInCell()) then
				name = value:getName()
				role = " (" .. tostring(value:getGroupRole()) .. ")"
			elseif (value.getName ~= nil) and ((value:isDead()) or (not value:saveFileExists())) then
				name = value:getName()
				role = " (" .. getText("IGUI_health_Deceased") .. ")";

				CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled, "removing loaded survivor (" ..
					name .. ") from group by obj bc no save file detected or isDead was true[" ..
					tostring(value:isDead()) .. "]"
				);
				Group:removeMember(value:getID())
			elseif (value.getName ~= nil) and (value:isInCell() == false) then
				name = value:getName()
				local coords = GetCoordsFromID(value:getID())
				if (coords == 0) then
					CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled,
						"re-loading survivor who has no loc on survivor map");
					SSM:LoadSurvivor(value:getID(), getSpecificPlayer(0):getCurrentSquare())
					coords = "re-loaded!"
				end
				role = " (" .. tostring(coords) .. ")"
			elseif (not checkSaveFileExists("Survivor" .. tostring(value))) then
				name = Get_SS_ContextMenuText("MIASurvivor") .. "[" .. tostring(value) .. "]"
				role = " (" .. getText("IGUI_health_Deceased") .. ")"
				CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled, "removing unloaded survivor "
					.. tostring(value)
					.. " from group by id bc no save file detected"
				);
				Group:removeMember(value)
			else
				name = Get_SS_ContextMenuText("MIASurvivor") .. "[" .. tostring(value) .. "]"
				local coords = GetCoordsFromID(value)
				if (coords == 0) then
					CreateLogLine("SuperSurvivorMyGroupWindow", isLocalLoggingEnabled,
						"re-loading survivor who has no loc on survivor map");
					SSM:LoadSurvivor(value, getSpecificPlayer(0):getCurrentSquare())
					coords = "re-loaded!"
				end
				role = " (" .. tostring(coords) .. ")"
			end
			self:AddItem(tostring(name .. role .. ""), tostring(index))
		end


		local baseloc = Group:getBaseCenter()
		--local basebounds = Group:getBounds()
		local base = ""
		if (baseloc ~= nil) then base = tostring(baseloc:getX()) .. "," .. tostring(baseloc:getY()) end
		self:setHeaderText(Get_SS_ContextMenuText("BaseLocation") ..
			"(" .. getSpecificPlayer(0):getModData().Group .. "): " .. base)
	end

	self.HomeWindow:sort()
	self.HomeWindow.selected = selected
	self.HomeWindow.mouseoverselected = selected
	self.HomeWindow:ensureVisible(selected)
end

function GroupWindow:setHeaderText(newtext)
	self.Header.text = newtext
	self.Header:paginate()
end

function GroupWindow:createChildren()
	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	ISCollapsableWindow.createChildren(self);
	self.Header = ISRichTextPanel:new(0, FONT_HGT_SMALL + 1, 300, 50);
	self.Header:initialise();
	self.Header.autosetheight = false
	self.Header:ignoreHeightChange()
	self:addChild(self.Header)

	self.HomeWindow = ISScrollingListBox:new(0, FONT_HGT_SMALL * 2 + 15, 300, 570);
	self.HomeWindow.onmousedblclick = SSItemClickHandle;
	self.HomeWindow.itemheight = FONT_HGT_SMALL + 15
	self.HomeWindow:initialise();
	self:addChild(self.HomeWindow)
end

function GroupWindowCreate()
	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	MyGroupWindow = GroupWindow:new(15, 285, 300, 620 + FONT_HGT_SMALL)
	MyGroupWindow:addToUIManager();
	MyGroupWindow:setVisible(false);
	MyGroupWindow.pin = true;
	MyGroupWindow.resizable = true
end
