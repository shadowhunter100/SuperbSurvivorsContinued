require "04_Group.SuperSurvivorManager";
require "07_UI/UIUtils";

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local isLocalLoggingEnabled = false;

--****************************************************
-- DRichTextPanel
--****************************************************
local DRichTextPanel = ISRichTextPanel:derive("DRichTextPanel")

function DRichTextPanel:initialise()
    ISRichTextPanel.initialise(self)
end

function DRichTextPanel:onMouseMove(_, _)
    self.parent.mouseOver = true
end

function DRichTextPanel:onMouseMoveOutside(_, _)
    self.parent.mouseOver = false
end

function DRichTextPanel:onMouseUp(_, _)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.moving = false
    ISMouseDrag.dragView = nil
end

function DRichTextPanel:onMouseUpOutside(_, _)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.moving = false
    ISMouseDrag.dragView = nil
end

function DRichTextPanel:onMouseDown(x, y)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.downX = x
    self.parent.downY = y
    self.parent.moving = true
    self.parent:bringToTop()
end

function DRichTextPanel:new(x, y, width, height, parent)
    local o = {}
    o = ISRichTextPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.parent = parent
    return o
end

--****************************************************
-- PanelSurvivorInfo
--****************************************************
PanelSurvivorInfo = ISPanel:derive("PanelSurvivorInfo")

function remove_panel_survivor_info()
    panel_survivor_info:removeFromUIManager()
end

function create_panel_survivor_info()
    panel_survivor_info = PanelSurvivorInfo:new(100, 100, FONT_HGT_SMALL * 6 + 175, FONT_HGT_SMALL * 10 + 500 + 56)
    panel_survivor_info:addToUIManager()
    panel_survivor_info:setVisible(false)
end

function PanelSurvivorInfo:initialise()
    ISPanel.initialise(self)
end

function PanelSurvivorInfo:on_click_call()
    local group_id = SSM:Get(0):getGroupID()
    local group_members = SSGM:GetGroupById(group_id):getMembers()
    local member = group_members[self.member_index]
    if (member) then
        getSpecificPlayer(0):Say(getText("ContextMenu_SS_CallName_Before") ..
            member:getName() .. getText("ContextMenu_SS_CallName_After"))
        member:getTaskManager():AddToTop(ListenTask:new(member, getSpecificPlayer(0), false))
    end
end

function PanelSurvivorInfo:createChildren()
    -- text panel
    self.text_panel = DRichTextPanel:new(0, 0, self.width, self.height - 54, self)
    self.text_panel.clip = true
    self.text_panel.autosetheight = false
    self.text_panel:ignoreHeightChange()
    self:addChild(self.text_panel)
    -- button call
    self.button_call = ISButton:new(0, self.text_panel.height + 2, self.width, 25, "call", nil,
        function() self:on_click_call() end)
    -- button close
    self.button_close = ISButton:new(0, self.button_call.y + self.button_call.height + 2, self.width, 25, "close", nil,
        function() self:setVisible(false) end)
    self:addChild(self.text_panel)
    self:addChild(self.button_call)
    self:addChild(self.button_close)
end

function PanelSurvivorInfo:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function PanelSurvivorInfo:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function PanelSurvivorInfo:onMouseUp(_, _)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function PanelSurvivorInfo:onMouseUpOutside(_, _)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function PanelSurvivorInfo:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function PanelSurvivorInfo:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.member_index = nil
    return o
end

function ShowSurvivorInfo(member_index)
    local group = UIUtil_GetGroup()
    if not group then
        panel_survivor_info:setVisible(false)
        return
    end
    local group_members = group:getMembers()
    local group_member = group_members[member_index]
    local text_info = getText("ContextMenu_SS_SurvivorInfoName_Before") ..
        group_member:getName() .. getText("ContextMenu_SS_SurvivorInfoName_After") .. "\n"
    local player = group_member:Get()
    text_info = text_info .. "(" ..
        tostring(group_member:getGroupRole()) .. "/" .. group_member:getCurrentTask() .. ")" .. "\n\n"
    for i = 1, GetTableSize(SurvivorPerks) do
        player:getModData().PerkCount = i

        local level = player:getPerkLevel(Perks.FromString(SurvivorPerks[i]));

        if level ~= nil and SurvivorPerks[i] ~= nil and level > 0 then
            local display_perk = PerkFactory.getPerkName(Perks.FromString(SurvivorPerks[i]))
            if display_perk == nil then
                display_perk = tostring(SurvivorPerks[i]) .. "?"
            end
            text_info = text_info .. getText("ContextMenu_SS_Level") .. " " .. tostring(level) .. " " ..
                display_perk .. "\n"
        end
    end
    text_info = text_info .. "\n"
    text_info = text_info ..
        getText("Tooltip_food_Hunger") .. ": " .. tostring(math.floor((player:getStats():getHunger() * 100))) .. "\n"
    text_info = text_info ..
        getText("Tooltip_food_Thirst") .. ": " .. tostring(math.floor((player:getStats():getThirst() * 100))) .. "\n"
    text_info = text_info .. "Morale: " .. tostring(math.floor(player:getStats():getMorale() * 100)) .. "\n"
    text_info = text_info .. "Sanity: " .. tostring(math.floor(player:getStats():getSanity() * 100)) .. "\n"
    text_info = text_info ..
        getText("Tooltip_food_Boredom") .. ": " .. tostring(math.floor(player:getStats():getBoredom() * 100)) .. "\n"
    text_info = text_info .. "IdleBoredom: " .. tostring(math.floor(player:getStats():getIdleboredom() * 100)) .. "\n"
    text_info = text_info ..
        getText("Tooltip_food_Unhappiness") ..
        ": " .. tostring(math.floor(player:getBodyDamage():getUnhappynessLevel() * 100)) .. "\n"
    text_info = text_info ..
        getText("Tooltip_Wetness") .. ": " .. tostring(math.floor(player:getBodyDamage():getWetness() * 100)) .. "\n"
    text_info = text_info ..
        getText("Tooltip_clothing_dirty") .. ": " .. tostring(math.floor(group_member:getFilth() * 100)) .. "\n"
    text_info = text_info .. "\n"
    local melewepName = getText("Nothing")
    local gunwepName = getText("Nothing")
    if group_member.LastMeleUsed ~= nil then melewepName = group_member.LastMeleUsed:getDisplayName() end
    if group_member.LastGunUsed ~= nil then gunwepName = group_member.LastGunUsed:getDisplayName() end
    local phi
    if player:getPrimaryHandItem() ~= nil then
        phi = player:getPrimaryHandItem():getDisplayName()
    else
        phi = getText("Nothing")
    end
    text_info = text_info .. getText("ContextMenu_SS_PrimaryHandItem") .. ": " .. tostring(phi) .. "\n"
    text_info = text_info .. getText("ContextMenu_SS_MeleWeapon") .. ": " .. tostring(melewepName) .. "\n"
    text_info = text_info .. getText("ContextMenu_SS_GunWeapon") .. ": " .. tostring(gunwepName) .. "\n"
    text_info = text_info .. getText("ContextMenu_SS_CurrentTask") .. ": " ..
        tostring(group_member:getCurrentTask()) .. "\n"
    text_info = text_info .. "\n"
    text_info = text_info ..
        getText("ContextMenu_SS_AmmoCount") .. ": " .. tostring(group_member.player:getModData().ammoCount) .. "\n"
    text_info = text_info ..
        getText("ContextMenu_SS_AmmoType") .. ": " .. tostring(group_member.player:getModData().ammotype) .. "\n"
    text_info = text_info ..
        getText("ContextMenu_SS_AmmoBoxType") .. ": " .. tostring(group_member.player:getModData().ammoBoxtype) .. "\n"
    text_info = text_info .. "\n"

    text_info = text_info .. getText("ContextMenu_SS_SurvivorID") .. ": " .. tostring(group_member:getID()) .. "\n"
    text_info = text_info .. getText("ContextMenu_SS_GroupID") .. ": " .. tostring(group_member:getGroupID()) .. "\n"
    text_info = text_info .. getText("ContextMenu_SS_GroupRole") .. ": " .. tostring(group_member:getGroupRole()) .. "\n"
    text_info = text_info .. "AI mode: " .. tostring(group_member:getAIMode()) .. "\n"
    panel_survivor_info.member_index = member_index
    panel_survivor_info.text_panel.text = text_info
    panel_survivor_info.text_panel:paginate()
    panel_survivor_info:setVisible(true)
end

--****************************************************
-- SuperSurvivorInfoPanel entry point
--****************************************************
function super_survivor_info_entry_point()
    create_panel_survivor_info()
end

Events.OnGameStart.Add(super_survivor_info_entry_point)
