require "00_SuperbSurviorModVariables.SuperSurviorsGlobalVariables";

ModId = "SuperbSurvivorsContinued";
local isLocalLoggingEnabled = false;

--[[
    Credit to "haram gaming#4572" in PZ Discord for providing a text file writing example.
    Credit to "albion#0123" in PZ Discord for explaining the difference between "getFileWriter" and "getModFileWriter"
    CreateLogLine will create a log file under the "<user>/Zomboid/Lua/<ModId>/logs".
--]]
-- Use this function to write a line to a text file, this is useful to identify when and how many times a function is called.
function CreateLogLine(fileName, isEnabled, newLine)
    if (isEnabled) then
        local timestamp = os.time();
        local formattedTimeDay = os.date("%Y-%m-%d", timestamp);
        local formattedTime = os.date("%Y-%m-%d %H:%M:%S", timestamp);
        local file = getFileWriter(
            ModId .. "/logs/" .. formattedTimeDay .. "_" .. ModId .. "_" .. fileName .. "_Logs.txt", true, true);
        local content = formattedTime .. " : " .. "CreateLogLine called";

        if newLine then
            content = formattedTime .. " : " .. newLine;
        end

        file:write(content .. "\r\n");
        file:close();
    end
end

--[[
    Log the key-value pairs of a table to a specified file.
-- ]]
function LogTableKVPairs(fileName, isEnabled, table)
    if (isEnabled) then
        for key, value in pairs(table) do
            CreateLogLine(fileName, isEnabled, "key:" .. tostring(key) .. " | value: " .. tostring(value));
        end
    end
end

function LogSSDebugInfo()
    local playerSurvivor = getSpecificPlayer(0);
    local isLoggingDebugInfo = true;
    local groupsWithActualMembers = 1; -- Starting at 1, because player group is 0...
    playerSurvivor:Say("Logging Debug info...");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Begin Groups Data");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Group ID: " .. tostring(0));
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Leader ID: " .. tostring(SSGM.Groups[0]:getLeader()));
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Total Members: " .. tostring(SSGM.Groups[0]:getMemberCount()));
    -- Get the total number of groups
    for i = 0, SSGM.GroupCount + 1 do
        if (SSGM.Groups[i] ~= nil and SSM.MainPlayer ~= i) then
            CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Group ID: " .. tostring(i));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Leader ID: " .. tostring(SSGM.Groups[i]:getLeader()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Total Members: " .. tostring(SSGM.Groups[i]:getMemberCount()));

            if (SSGM.Groups[i]:getMemberCount() > 0) then
                groupsWithActualMembers = groupsWithActualMembers + 1;
            end
        end
    end

    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Total Survivor Groups: " .. tostring(SSGM.GroupCount));
    CreateLogLine("SS_Debugger", isLoggingDebugInfo,
        "Actual Active Groups: " .. tostring(GroupWithActualMembers));

    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "--- LINE BREAK ---");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");

    local actualLivingSurvivors = 0;

    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Begin Survivors Data");
    -- Get the total number of survivors
    for i = 0, SSM.SurvivorCount + 1 do
        if (SSM.SuperSurvivors[i] ~= nil and SSM.MainPlayer ~= i) then
            CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Survivor ID: " .. tostring(i));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Survivor Name: " .. tostring(SSM.SuperSurvivors[i]:getName()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Survivor in Group ID: " .. tostring(SSM.SuperSurvivors[i]:getGroupID()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Group Role: " .. tostring(SSM.SuperSurvivors[i]:getGroupRole()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Current Task: " .. tostring(SSM.SuperSurvivors[i]:getCurrentTask()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Is Dead? " .. tostring(SSM.SuperSurvivors[i]:isDead()));
            if (not SSM.SuperSurvivors[i]:isDead()) then
                actualLivingSurvivors = actualLivingSurvivors + 1;
            end
        end
    end
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Total Survivors: " .. tostring(SSM.SurvivorCount));
    CreateLogLine("SS_Debugger", isLoggingDebugInfo,
        "Actual Living NPCs: " .. tostring(actualLivingSurvivors));

    playerSurvivor:Say("Logging Debug info complete...");
end

-- Example usage:
CreateLogLine("SS_Debugger", isLocalLoggingEnabled, "Start...");
