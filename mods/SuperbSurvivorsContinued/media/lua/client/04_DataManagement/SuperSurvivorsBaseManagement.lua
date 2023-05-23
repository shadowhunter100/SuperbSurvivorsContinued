SuperSurvivorSelectArea = {};

-- WIP - Cows: This was moved out of SuperSurvivorsMod.lua... it had nothing to do with "survivor" itself, and its only the handling group's base area selection.
SuperSurvivorSelectAnArea = false;
SuperSurvivorMouseDownTicks = 0;

-- Begin selectBaseArea
local function selectBaseArea()
    if (SuperSurvivorSelectAnArea) then
        if (Mouse.isLeftDown()) then
            SuperSurvivorMouseDownTicks = SuperSurvivorMouseDownTicks + 1
        else
            SuperSurvivorMouseDownTicks = 0;
            SuperSurvivorSelectingArea = false;
        end

        if (SuperSurvivorMouseDownTicks > 15) then -- 10 acts instant, so a left click would reset the select area finalization.
            if (Highlightcenter == nil) or (not SuperSurvivorSelectingArea) then
                Highlightcenter = GetMouseSquare();
                HighlightX1 = GetMouseSquareX();
                HighlightX2 = GetMouseSquareX();
                HighlightY1 = GetMouseSquareY();
                HighlightY2 = GetMouseSquareY();
            end

            SuperSurvivorSelectingArea = true;

            if (HighlightX1 == nil) or (HighlightX1 > GetMouseSquareX()) then HighlightX1 = GetMouseSquareX() end
            if (HighlightX2 == nil) or (HighlightX2 <= GetMouseSquareX()) then HighlightX2 = GetMouseSquareX() end
            if (HighlightY1 == nil) or (HighlightY1 > GetMouseSquareY()) then HighlightY1 = GetMouseSquareY() end
            if (HighlightY2 == nil) or (HighlightY2 <= GetMouseSquareY()) then HighlightY2 = GetMouseSquareY() end
        elseif (SuperSurvivorSelectingArea) then
            SuperSurvivorSelectingArea = false;
        end

        if (Mouse.isLeftPressed()) then
            SuperSurvivorSelectingArea = false; -- new
        end

        if (HighlightX1) and (HighlightX2) then
            local x1 = HighlightX1;
            local x2 = HighlightX2;
            local y1 = HighlightY1;
            local y2 = HighlightY2;

            for xx = x1, x2 do
                for yy = y1, y2 do
                    local sq = getCell():getGridSquare(xx, yy, getSpecificPlayer(0):getZ());
                    if (sq) and (sq:getFloor()) then
                        sq:getFloor():setHighlighted(true);
                    end
                end
            end
        end
    end
end

--
function StartSelectingArea(test, area)
    local isLocalFunctionLoggingEnabled = false;
    for k, v in pairs(SuperSurvivorSelectArea) do
        SuperSurvivorSelectArea[k] = false
    end

    CreateLogLine("SuperSurvivorsBaseManagement", isLocalFunctionLoggingEnabled, "starting selectBaseArea()...");
    SuperSurvivorSelectArea[area] = true;
    SuperSurvivorSelectAnArea = true;
    Events.OnRenderTick.Add(selectBaseArea);
    local mySS = SSM:Get(0)
    local gid = mySS:getGroupID()
    if (not gid) then return false end
    local group = SSGM:GetGroupById(gid)
    if (not group) then return false end

    if (area == "BaseArea") then
        local baseBounds = group:getBounds();
        HighlightX1 = baseBounds[1];
        HighlightX2 = baseBounds[2];
        HighlightY1 = baseBounds[3];
        HighlightY2 = baseBounds[4];
        HighlightZ = baseBounds[5];
    else
        local bounds = group:getGroupArea(area);
        HighlightX1 = bounds[1];
        HighlightX2 = bounds[2];
        HighlightY1 = bounds[3];
        HighlightY2 = bounds[4];
        HighlightZ = bounds[5];
    end
end

--
function SelectingArea(test, area, value)
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("SuperSurvivorsBaseManagement", isLocalFunctionLoggingEnabled, "function: SelectingArea() called");
    -- value 0 means cancel, -1 is clear, 1 is set
    if (value ~= 0) then
        if (value == -1) then
            HighlightX1 = 0
            HighlightX2 = 0
            HighlightY1 = 0
            HighlightY2 = 0
        end

        local mySS = SSM:Get(0)
        local gid = mySS:getGroupID()
        if (not gid) then return false end
        local group = SSGM:GetGroupById(gid)
        if (not group) then return false end

        if (area == "BaseArea") then
            local baseBounds = {
                math.floor(HighlightX1),
                math.floor(HighlightX2),
                math.floor(HighlightY1),
                math.floor(HighlightY2),
                math.floor(getSpecificPlayer(0):getZ())
            }
            group:setBounds(baseBounds);
            CreateLogLine("SuperSurvivorsBaseManagement", isLocalFunctionLoggingEnabled, "set base bounds:" ..
                tostring(HighlightX1) .. "," ..
                tostring(HighlightX2) .. " : " .. tostring(HighlightY1) .. "," .. tostring(HighlightY2));
        else
            group:setGroupArea(area, math.floor(HighlightX1), math.floor(HighlightX2), math.floor(HighlightY1),
                math.floor(HighlightY2), getSpecificPlayer(0):getZ())
        end
    end

    CreateLogLine("SuperSurvivorsBaseManagement", isLocalFunctionLoggingEnabled, "stopping SelectBaseArea()...");
    SuperSurvivorSelectArea[area] = false;
    SuperSurvivorSelectAnArea = false;
    Events.OnRenderTick.Remove(selectBaseArea);
    CreateLogLine("SuperSurvivorsBaseManagement", isLocalFunctionLoggingEnabled, "--- function: SelectingArea() end ---");
end
