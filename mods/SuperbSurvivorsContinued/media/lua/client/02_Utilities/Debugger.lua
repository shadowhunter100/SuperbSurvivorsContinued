

local function log_SS_SandboxOptions()
    local isLoggingDebugInfo = true;
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "Max_Group_Size: " .. tostring(SandboxVars.SuperbSurvivorsContinued.Max_Group_Size));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "Limit_Npc_Groups: " .. tostring(SandboxVars.SuperbSurvivorsContinued.Limit_Npc_Groups));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "Limit_Npcs_Spawn: " .. tostring(SandboxVars.SuperbSurvivorsContinued.Limit_Npcs_Spawn));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsWifeSpawn: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsWifeSpawn));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "NpcGroupsSpawnsSize: " .. tostring(SandboxVars.SuperbSurvivorsContinued.NpcGroupsSpawnsSize));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "NpcSpawnChance: " .. tostring(SandboxVars.SuperbSurvivorsContinued.NpcSpawnChance));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "HostileSpawnRateBase: " .. tostring(SandboxVars.SuperbSurvivorsContinued.HostileSpawnRateBase));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "HostileSpawnRateMax: " .. tostring(SandboxVars.SuperbSurvivorsContinued.HostileSpawnRateMax));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "");
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "RaidersSpawnChance: " .. tostring(SandboxVars.SuperbSurvivorsContinued.RaidersSpawnChance));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "RaidersStartAfterHours: " .. tostring(SandboxVars.SuperbSurvivorsContinued.RaidersStartAfterHours));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "");
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "CanIdleChat: " .. tostring(SandboxVars.SuperbSurvivorsContinued.CanIdleChat));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "CanNpcsCreateBase: " .. tostring(SandboxVars.SuperbSurvivorsContinued.CanNpcsCreateBase));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsInfiniteAmmoEnabled: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsInfiniteAmmoEnabled));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsRoleplayEnabled: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsRoleplayEnabled));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsSpeakEnabled: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsSpeakEnabled));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "SurvivorCanFindWork: " .. tostring(SandboxVars.SuperbSurvivorsContinued.SurvivorCanFindWork));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "SurvivorNeedsFoodWater: " .. tostring(SandboxVars.SuperbSurvivorsContinued.SurvivorNeedsFoodWater));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "SurvivorBravery: " .. tostring(SandboxVars.SuperbSurvivorsContinued.SurvivorBravery));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "SurvivorFriendliness: " .. tostring(SandboxVars.SuperbSurvivorsContinued.SurvivorFriendliness));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "SleepGeneralHealRate: " .. tostring(SandboxVars.SuperbSurvivorsContinued.SleepGeneralHealRate));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "GFollowDistance: " .. tostring(GFollowDistance));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "PanicDistance: " .. tostring(SandboxVars.SuperbSurvivorsContinued.PanicDistance));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "WepSpawnRateGun: " .. tostring(SandboxVars.SuperbSurvivorsContinued.WepSpawnRateGun));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "WepSpawnRateMelee: " .. tostring(SandboxVars.SuperbSurvivorsContinued.WepSpawnRateMelee));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "");
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsPlayerBaseSafe: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsPlayerBaseSafe));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsPVPEnabled: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsPVPEnabled));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsDisplayingNpcName: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsDisplayingNpcName));
    CreateLogLine("SS_OptionsValues", isLoggingDebugInfo, "IsDisplayingHostileColor: " .. tostring(SandboxVars.SuperbSurvivorsContinued.IsDisplayingHostileColor));
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
