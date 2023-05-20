--- WIP - Cows: Need to rework the spawning functions and logic...
--- SuperSurvivorsNewSurvivorManager() is called once every in-game hour and uses NpcSpawnChance.
---@return any
function SuperSurvivorsNewSurvivorManager()
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "function: SuperSurvivorsNewSurvivorManager() called");
    local mySS = SSM:Get(0);
    local hisGroup = mySS:getGroup();

    if (getSpecificPlayer(0) == nil or hisGroup == nil) then
        return false;
    end

    local hoursSurvived = math.floor(getGameTime():getWorldAgeHours());
    local FinalChanceToBeHostile = HostileSpawnRateBase + math.floor(hoursSurvived / 48);

    if (FinalChanceToBeHostile > HostileSpawnRateMax)
        and (HostileSpawnRateBase < HostileSpawnRateMax)
    then
        FinalChanceToBeHostile = HostileSpawnRateMax;
    end

    local center = Get_SS_PlayerGroupBoundsCenter(hisGroup);
    local spawnSquare = Set_SS_SpawnSquare(hisGroup, center);

    -- WIP - Cows: Need to rework the spawning functions and logic...
    -- TODO: Capped the number of groups, now to cap the number of survivors and clean up dead ones.
    if (spawnSquare ~= nil) then
        local npcSurvivorGroup;
        if (SSGM.GroupCount < Limit_Npc_Groups) then
            npcSurvivorGroup = SSGM:newGroup();
        else
            -- something ... repopulate the previous groups?
            local rng = ZombRand(1, Limit_Npc_Groups);
            CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled,
                "function: SuperSurvivorDoRandomSpawns() rng");
            npcSurvivorGroup = SSGM:GetGroupById(rng);
        end

        local GroupSize = ZombRand(1, Max_Group_Size);

        for i = 1, GroupSize do
            local npcSurvivor = SuperSurvivorSpawnNpc(spawnSquare);
            if (npcSurvivor) then
                local name = npcSurvivor:getName();

                -- Updated so alt spawns can decide to be hostile or not.
                if (FinalChanceToBeHostile > ZombRand(0, 100)) then
                    npcSurvivor:setHostile(true);
                else
                    npcSurvivor:setHostile(false);
                end

                local isPlayerSurvivorGroup = SuperSurvivorGroup:isMember(mySS);

                if (i == 1 and not isPlayerSurvivorGroup) then
                    npcSurvivorGroup:addMember(npcSurvivor, "Leader");
                else
                    npcSurvivorGroup:addMember(npcSurvivor, "Guard");
                end

                npcSurvivor.player:getModData().isRobber = false;
                npcSurvivor:setName("Survivor " .. name);
                npcSurvivor:getTaskManager():AddToTop(WanderTask:new(npcSurvivor));

                Equip_SS_RandomNpc(npcSurvivor, false);
                GetRandomSurvivorSuit(npcSurvivor) -- WIP: Cows - Consider creating a preset outfit for raiders?
            else
                -- Cows: Consider logging an error if no npcSurvivor is found?
            end
        end
        -- npcSurvivorGroup:AllSpokeTo(); -- Cows: seems useless?
    end
end

-- WIP - Cows: Need to rework the spawning functions and logic...
function SuperSurvivorDoRandomSpawns()
    if (getSpecificPlayer(0) == nil) then return false end
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "function: SuperSurvivorDoRandomSpawns() called");
    local activeNpcs = Get_SS_Alive_Count();
    local spawnChanceVal = NpcSpawnChance;
     -- Cows: Spawn if spawnChanceVal is greater than the random roll between 0 and 100, and activeNPCs are less than the limit.
    local isSpawning = (spawnChanceVal > ZombRand(0, 100) and activeNpcs < Limit_Npcs_Spawn);

    if (isSpawning) then
        CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "spawning npc survivor...");
        SuperSurvivorsNewSurvivorManager();
    end
end

Events.EveryHours.Add(SuperSurvivorDoRandomSpawns);
Events.EveryHours.Add(Refresh_SS_NpcStatus);
