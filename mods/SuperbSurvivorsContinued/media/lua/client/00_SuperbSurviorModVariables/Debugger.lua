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

local function log_SS_SandboxOptions()
    CreateLogLine("SS_OptionsValues", true, "Max_Group_Size: " .. tostring(Max_Group_Size));
    CreateLogLine("SS_OptionsValues", true, "Limit_Npc_Groups: " .. tostring(Limit_Npc_Groups));
    CreateLogLine("SS_OptionsValues", true, "Limit_Npcs_Spawn: " .. tostring(Limit_Npcs_Spawn));
    CreateLogLine("SS_OptionsValues", true, "IsWifeSpawn: " .. tostring(IsWifeSpawn));
    CreateLogLine("SS_OptionsValues", true, "NoPresetSpawn: " .. tostring(NoPresetSpawn));
    CreateLogLine("SS_OptionsValues", true, "NpcGroupsSpawnsSize: " .. tostring(NpcGroupsSpawnsSize));
    CreateLogLine("SS_OptionsValues", true, "NpcSpawnChance: " .. tostring(NpcSpawnChance));
    CreateLogLine("SS_OptionsValues", true, "HostileSpawnRateBase: " .. tostring(HostileSpawnRateBase));
    CreateLogLine("SS_OptionsValues", true, "HostileSpawnRateMax: " .. tostring(HostileSpawnRateMax));
    CreateLogLine("SS_OptionsValues", true, "");
    CreateLogLine("SS_OptionsValues", true, "RaidersSpawnChance: " .. tostring(RaidersSpawnChance));
    CreateLogLine("SS_OptionsValues", true, "RaidersStartAfterHours: " .. tostring(RaidersStartAfterHours));
    CreateLogLine("SS_OptionsValues", true, "");
    CreateLogLine("SS_OptionsValues", true, "CanIdleChat: " .. tostring(CanIdleChat));
    CreateLogLine("SS_OptionsValues", true, "CanNpcsCreateBase: " .. tostring(CanNpcsCreateBase));
    CreateLogLine("SS_OptionsValues", true, "IsInfiniteAmmoEnabled: " .. tostring(IsInfiniteAmmoEnabled));
    CreateLogLine("SS_OptionsValues", true, "IsRoleplayEnabled: " .. tostring(IsRoleplayEnabled));
    CreateLogLine("SS_OptionsValues", true, "IsSpeakEnabled: " .. tostring(IsSpeakEnabled));
    CreateLogLine("SS_OptionsValues", true, "SurvivorCanFindWork: " .. tostring(SurvivorCanFindWork));
    CreateLogLine("SS_OptionsValues", true, "SurvivorNeedsFoodWater: " .. tostring(SurvivorNeedsFoodWater));
    CreateLogLine("SS_OptionsValues", true, "SurvivorBravery: " .. tostring(SurvivorBravery));
    CreateLogLine("SS_OptionsValues", true, "SurvivorFriendliness: " .. tostring(SurvivorFriendliness));
    CreateLogLine("SS_OptionsValues", true, "SleepGeneralHealRate: " .. tostring(SleepGeneralHealRate));
    CreateLogLine("SS_OptionsValues", true, "GFollowDistance: " .. tostring(GFollowDistance));
    CreateLogLine("SS_OptionsValues", true, "PanicDistance: " .. tostring(PanicDistance));
    CreateLogLine("SS_OptionsValues", true, "WepSpawnRateGun: " .. tostring(WepSpawnRateGun));
    CreateLogLine("SS_OptionsValues", true, "WepSpawnRateMelee: " .. tostring(WepSpawnRateMelee));
    CreateLogLine("SS_OptionsValues", true, "");
    CreateLogLine("SS_OptionsValues", true, "IsPlayerBaseSafe: " .. tostring(IsPlayerBaseSafe));
    CreateLogLine("SS_OptionsValues", true, "IsPVPEnabled: " .. tostring(IsPVPEnabled));
    CreateLogLine("SS_OptionsValues", true, "IsDisplayingNpcName: " .. tostring(IsDisplayingNpcName));
    CreateLogLine("SS_OptionsValues", true, "IsDisplayingHostileColor: " .. tostring(IsDisplayingHostileColor));
end

local function log_SS_PlayerInfo()
    local isLoggingDebugInfo = true;
    local mySS = SSM:Get(0);
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Begin Player Data");
    if (mySS) then
        local mySS_squareX = mySS:getCurrentSquare():getX();
        local mySS_squareY = mySS:getCurrentSquare():getY();
        local mySS_squareZ = mySS:getCurrentSquare():getZ();
        CreateLogLine("SS_Debugger", isLoggingDebugInfo, "SurvivorName: " .. tostring(mySS:getName()));
        CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Group ID: " .. tostring(mySS:getGroupID()));
        CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Group Role: " .. tostring(mySS:getGroupRole())); -- Cows: This should be "Leader", as 0 should be the player...

        CreateLogLine("SS_Debugger", isLoggingDebugInfo,
            "Survivor Square: " ..
            tostring("locationX: " ..
                mySS_squareX .. " | locationY: " .. mySS_squareY .. " | locationZ: " .. mySS_squareZ));
    else
        CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Failed to get player data...");
    end
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "--- LINE BREAK ---");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
end

local function log_SS_GroupsInfo()
    local isLoggingDebugInfo = true;
    local groupsWithActualMembers = 0;
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Begin Groups Data");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
    -- Get the total number of groups
    for i = 0, SSGM.GroupCount + 1 do
        if (SSGM.Groups[i] ~= nil) then
            CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Group ID: " .. tostring(i));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Leader ID: " .. tostring(SSGM.Groups[i]:getLeader()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Total Members: " .. tostring(SSGM.Groups[i]:getMemberCount()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
            --
            if (SSGM.Groups[i]:getMemberCount() > 0) then
                groupsWithActualMembers = groupsWithActualMembers + 1;
            end
        end
    end

    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Total Survivor Groups: " .. tostring(SSGM.GroupCount));
    CreateLogLine("SS_Debugger", isLoggingDebugInfo,
        "Actual Active Groups: " .. tostring(groupsWithActualMembers));

    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "--- LINE BREAK ---");
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
end

local function log_SS_SurvivorsInfo()
    local isLoggingDebugInfo = true;
    local actualLivingSurvivors = 0;

    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Begin Survivors Data");
    -- Get the total number of survivors
    for i = 0, SSM.SurvivorCount + 1 do
        -- Cows: SurvivorCount is horribly inaccurate ... when npcs are dead and removed from the game the count doesn't decrease.
        -- But the npcs IDs are based on the SurvivorCount index... so there is a lot of wasted cycle here.
        -- A better npc management system needs to be created to deal with this issue.
        if (SSM.SuperSurvivors[i] ~= nil) then
            CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Survivor ID: " .. tostring(i));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Survivor Name: " .. tostring(SSM.SuperSurvivors[i]:getName()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Is Dead? " .. tostring(SSM.SuperSurvivors[i]:isDead()));
            --
            if (SSM.SuperSurvivors[i]:getCurrentSquare()) then
                local ss_squareX = SSM.SuperSurvivors[i]:getCurrentSquare():getX();
                local ss_squareY = SSM.SuperSurvivors[i]:getCurrentSquare():getY();
                local ss_squareZ = SSM.SuperSurvivors[i]:getCurrentSquare():getZ();
                CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                    "Survivor Square: " ..
                    tostring("locationX: " ..
                        ss_squareX .. " | locationY: " .. ss_squareY .. " | locationZ: " .. ss_squareZ));
            else
                CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Survivor Square: nil");
            end
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Survivor in Group ID: " .. tostring(SSM.SuperSurvivors[i]:getGroupID()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Group Role: " .. tostring(SSM.SuperSurvivors[i]:getGroupRole()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo,
                "Current Task: " .. tostring(SSM.SuperSurvivors[i]:getCurrentTask()));
            CreateLogLine("SS_Debugger", isLoggingDebugInfo, "");
            --
            if (not SSM.SuperSurvivors[i]:isDead()) then
                actualLivingSurvivors = actualLivingSurvivors + 1;
            end
        end
    end
    CreateLogLine("SS_Debugger", isLoggingDebugInfo, "Total Survivors: " .. tostring(SSM.SurvivorCount));
    CreateLogLine("SS_Debugger", isLoggingDebugInfo,
        "Actual Living NPCs: " .. tostring(actualLivingSurvivors));
end

function LogSSDebugInfo()
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:Say("Logging Debug info...");
    log_SS_SandboxOptions();
    log_SS_PlayerInfo();
    log_SS_GroupsInfo();
    log_SS_SurvivorsInfo();
    playerSurvivor:Say("Logging Debug info complete...");
end

-- Example usage:
CreateLogLine("SS_Debugger", isLocalLoggingEnabled, "Start...");
