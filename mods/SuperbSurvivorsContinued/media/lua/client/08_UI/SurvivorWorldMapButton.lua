require "07_UI/UIUtils";

local ButtonShowLocators = ISButton:derive("ButtonShowLocators")
local flag_show = false

function ButtonShowLocators:initialise()
    ISButton.initialise(self)
end

function ButtonShowLocators:update()
    if ISWorldMap_instance then
        if ISWorldMap_instance:isVisible() then
            self:setVisible(true)
        else
            self:setVisible(false)
        end
    end
    if flag_show then
        self:setTitle("Hide Survivors")
    else
        self:setTitle("Show Survivors")
    end
end

function ButtonShowLocators:new(x, y, width, height, title, clicktarget, onclick)
    local o = {}
    o = ISButton:new(x, y, width, height, title, clicktarget, onclick)
    setmetatable(o, self)
    self.__index = self
    return o
end

local function createButtonShowGroupMembers()
    local btnShowGroupMembersLocation = ButtonShowLocators:new(
        (getCore():getScreenWidth() / 2) - 75, -- x, from the left
        25,                                    -- y, from the top
        150,                                   -- button width
        25,                                    -- button height
        "Show Survivors",                      -- button text
        nil,                                   -- click target... safe as nil
        function()                             -- onClick behavior
            if flag_show then
                flag_show = false
            else
                flag_show = true
            end
        end
    )
    btnShowGroupMembersLocation:addToUIManager()
    btnShowGroupMembersLocation:setVisible(false)
    btnShowGroupMembersLocation:setAlwaysOnTop(true)
end

Events.OnGameStart.Add(createButtonShowGroupMembers)

local worldmap_render = ISWorldMap.render
ISWorldMap.render = function(self)
    worldmap_render(self)
    if flag_show then
        local group = UIUtil_GetGroup()
        if not group then return end--no more member drawing on map while player dead
        local group_members = group:getMembers()
        for i = 2, #group_members do
            local member = group_members[i]
            local x = self.mapAPI:worldToUIX(member.player:getX(), member.player:getY()) - 3
            local y = self.mapAPI:worldToUIY(member.player:getX(), member.player:getY()) - 3
            self:drawRect(x, y, 6, 6, 1, 0, 0, 1)
            local member_name = member:getName()
            local name_size = getTextManager():MeasureStringX(UIFont.NewSmall, member_name)
            self:drawRect(x - 1, y + 8, name_size + 1, 15, 0.5, 0, 0, 0)
            self:drawText(member_name, x, y + 9, 1, 1, 1, 1, UIFont.NewSmall)
        end
    end
end
