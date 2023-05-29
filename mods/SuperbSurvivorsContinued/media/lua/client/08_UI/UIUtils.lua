require "00_SuperbSurviorModVariables/SuperSurvivorsOrders";
require "04_Group.SuperSurvivorManager";

--****************************************************
-- RGB functions
--****************************************************
local function rgb_to_dec(color)
    return { r = color.r / 255, g = color.g / 255, b = color.b / 255, a = color.a }
end

local function hex_to_rgb(hex, opacity)
    hex = hex:gsub("#", "")
    return {
        r = tonumber(hex:sub(1, 2), 16),
        g = tonumber(hex:sub(3, 4), 16),
        b = tonumber(hex:sub(5, 6), 16),
        a = opacity
    }
end

local function hex_to_dec(hex, opacity)
    return rgb_to_dec(hex_to_rgb(hex, opacity))
end

HexColors = {
    ["red"] = hex_to_dec("#CB4C4D", 0.8),
    ["orange"] = hex_to_dec("#CBA74C", 0.8),
    ["yellow"] = hex_to_dec("#C8E744", 0.8),
    ["green"] = hex_to_dec("#23C81F", 0.8),
    ["blue"] = hex_to_dec("#4C9ECB", 0.8),
    ["purple"] = hex_to_dec("#8A4CCB", 0.8),
    ["magenta"] = hex_to_dec("#CB4CAD", 0.8),
    ["brown"] = hex_to_dec("#A57E4C", 0.8)
}

AreaColors = {
    ["Bounds"] = HexColors.blue,
    ["ChopTreeArea"] = HexColors.yellow,
    ["TakeCorpseArea"] = HexColors.brown,
    ["TakeWoodArea"] = HexColors.brown,
    ["FarmingArea"] = HexColors.green,
    ["ForageArea"] = HexColors.yellow,
    ["CorpseStorageArea"] = HexColors.red,
    ["FoodStorageArea"] = HexColors.green,
    ["WoodStorageArea"] = HexColors.brown,
    ["ToolStorageArea"] = HexColors.orange,
    ["WeaponStorageArea"] = HexColors.yellow,
    ["MedicalStorageArea"] = HexColors.purple,
    ["GuardArea"] = HexColors.blue
}

--****************************************************
-- Utility
--****************************************************
function UIUtil_GetGroup()
    local mySS = SSM:Get(0);
    if not mySS then return nil end -- inhibit group management while the main player is dead.
    local group_id = mySS:getGroupID()
    local group = SSGM:GetGroupById(group_id)
    if group == nil then
        group = SSGM:newGroup()
        group:addMember(mySS, Get_SS_ContextMenuText("Job_Leader"))
    end
    if group then
        if not group:isMember(mySS) then
            group:addMember(mySS, Get_SS_ContextMenuText("Job_Leader"))
        elseif not group:hasLeader() then
            group:setLeader(0)
        end
    end
    return group
end

function UIUtil_GetMemberInfo(member_index)
    local group_id = SSM:Get(0):getGroupID()
    local group = SSGM:GetGroupById(group_id)
    if group == nil then
        group = SSGM:newGroup()
        group:addMember(SSM:Get(0), Get_SS_ContextMenuText("Job_Leader"))
    end
    if group then
        if not group:isMember(SSM:Get(0)) then
            group:addMember(SSM:Get(0), Get_SS_ContextMenuText("Job_Leader"))
        elseif not group:hasLeader() then
            group:setLeader(0)
        end
    end
    local group_members = group:getMembers()
    local member = group_members[member_index]
    local name = "none"
    local role = "none"
    local task = "none"
    local ai_mode = "none"
    if member.getName ~= nil and member:isInCell() then
        name = member:getName()
        role = tostring(member:getGroupRole())
        task = member.MyTaskManager.Tasks[member.MyTaskManager.CurrentTask]
        ai_mode = tostring(group_members[member_index]:getAIMode())
    elseif member.getName ~= nil and (member:isDead() or not member:saveFileExists()) then
        name = member:getName()
        role = getText("IGUI_health_Deceased")
        group:removeMember(member:getID())
    elseif member.getName ~= nil and member:isInCell() == false then
        name = member:getName()
        local coords = GetCoordsFromID(member:getID())
        -- WIP - Cows: WHAT WAS "coord"? IS THIS A TYPO? Renamed to "coords"
        if coords == 0 then
            SSM:LoadSurvivor(member:getID(), getSpecificPlayer(0):getCurrentSquare())
            coords = "0"
        end
        -- role = coords -- WIP - Cows: why is "role" assigned coords?
    elseif not checkSaveFileExists("Survivor" .. tostring(member)) then
        name = Get_SS_ContextMenuText("MIASurvivor") .. "[" .. tostring(member) .. "]"
        role = getText("IGUI_health_Deceased")
        group:removeMember(member)
    else
        name = Get_SS_ContextMenuText("MIASurvivor") .. "[" .. tostring(member) .. "]"
        local coords = GetCoordsFromID(member)
        if coords == 0 then
            SSM:LoadSurvivor(member, getSpecificPlayer(0):getCurrentSquare())
            coords = "0"
        end
        role = tostring(coords)
    end
    return name, role, task, ai_mode
end

function UIUtil_GiveOrder(order_index, member_index)
    local isLoggingSurvivorOrder = false;
    CreateLogLine("UIUtils", isLoggingSurvivorOrder, "function: UIUtil_GiveOrder() called");
    CreateLogLine("UIUtils", isLoggingSurvivorOrder, "order_index: " .. tostring(order_index));
    CreateLogLine("UIUtils", isLoggingSurvivorOrder, "member_index: " .. tostring(member_index));
    CreateLogLine("UIUtils", isLoggingSurvivorOrder, "Order: " .. tostring(Orders[order_index]));

    local group_id = SSM:Get(0):getGroupID()
    local group_members = SSGM:GetGroupById(group_id):getMembers()
    local member = group_members[member_index]
    if member then
        getSpecificPlayer(0):Say(Get_SS_UIActionText("CallName_Before") .. member:getName() .. Get_SS_UIActionText("CallName_After"))
        member:getTaskManager():AddToTop(ListenTask:new(member, getSpecificPlayer(0), false))
        SurvivorOrder(nil, member.player, Orders[order_index], nil)
    end
end

