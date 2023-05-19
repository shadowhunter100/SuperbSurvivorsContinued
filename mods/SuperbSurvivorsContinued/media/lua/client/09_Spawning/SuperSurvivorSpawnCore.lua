local isLocalLoggingEnabled = false;

---
--[[
	Merged identical code block from SuperSurvivorsNewSurvivorManager() and SuperSurvivorDoRandomSpawns()
	Cows: Apparently for whatever reason those functions needs to be run regularly...
	The sleep call I can understand because npcs can heal while the player sleeps.
	No clue if gernal healing affects infection status or injuries...
--]]
function Refresh_SS_NpcStatus()
    --this unrelated to raiders but need this to run every once in a while
    -- WIP - Cows: WHY DOES THIS NEED TO RUN?
    getSpecificPlayer(0):getModData().hitByCharacter = false;
    getSpecificPlayer(0):getModData().semiHostile = false;
    getSpecificPlayer(0):getModData().dealBreaker = nil;

    if (getSpecificPlayer(0):isAsleep()) then
        SSM:AsleepHealAll()
    end
end

--- Merged identical code block from SuperSurvivorsNewSurvivorManager() and SuperSurvivorDoRandomSpawns()
---@param playerGroup any
---@return any
function Get_SS_PlayerGroupBoundsCenter(playerGroup)
    local bounds = playerGroup:getBounds();
    local center;

    if (bounds) then
        center = GetCenterSquareFromArea(bounds[1], bounds[2], bounds[3], bounds[4], bounds[5]);
    end

    if (not center) then
        center = getSpecificPlayer(0):getCurrentSquare();
    end

    return center;
end

---comment
---@param npc any
---@param isRaider any
---@return any
function Equip_SS_RandomNpc(npc, isRaider)
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "function: Equip_SS_RandomNpc() called");

    if (npc:hasWeapon() == false) then
        npc:giveWeapon(SS_MeleeWeapons[ZombRand(1, #SS_MeleeWeapons)]);
    end

    local bag = npc:getBag();
    local food;
    local count = ZombRand(0, 3);

    if (isRaider) then
        for i = 1, count do
            food = "Base.CannedCorn";
            bag:AddItem(food);
        end
        local rCount = ZombRand(0, 3);
        for i = 1, rCount do
            food = "Base.Apple";
            bag:AddItem(food);
        end
    else
        for i = 1, count do
            food = "Base." .. tostring(CannedFoods[ZombRand(#CannedFoods) + 1]);
            bag:AddItem(food);
        end

        local rCount = ZombRand(0, 3);
        for i = 1, rCount do
            food = "Base.TinnedBeans";
            bag:AddItem(food);
        end
    end

    return npc;
end

--- Merged identical code block from SuperSurvivorsNewSurvivorManager() and SuperSurvivorDoRandomSpawns()
---@param hisGroup any
---@param center any
---@return unknown
function Set_SS_SpawnSquare(hisGroup, center)
    local spawnSquare;
    local range = 45;
    local drange = range * 2;

    for i = 1, 10 do
        local spawnLocation = ZombRand(4);
        local x, y; -- WIP - Cows: x, y are not used anywhere else... keep it local for each iteration.
        if (spawnLocation == 0) then
            --mySS:Speak("spawn from north")
            x = center:getX() + (ZombRand(drange) - range);
            y = center:getY() - range;
        elseif (spawnLocation == 1) then
            --mySS:Speak("spawn from east")
            x = center:getX() + range;
            y = center:getY() + (ZombRand(drange) - range);
        elseif (spawnLocation == 2) then
            --mySS:Speak("spawn from south")
            x = center:getX() + (ZombRand(drange) - range);
            y = center:getY() + range;
        elseif (spawnLocation == 3) then
            --mySS:Speak("spawn from west")
            x = center:getX() - range;
            y = center:getY() + (ZombRand(drange) - range);
        end

        spawnSquare = getCell():getGridSquare(x, y, 0);

        if (spawnSquare ~= nil)
            and (not hisGroup:IsInBounds(spawnSquare))
            and spawnSquare:isOutside()
            and (not spawnSquare:IsOnScreen())
            and (not spawnSquare:isSolid())
            and (spawnSquare:isSolidFloor())
        then
            break;
        end
    end

    return spawnSquare;
end

--- WIP - Cows: Need to rework the spawning functions and logic...
--- Cows: formerly "SuperSurvivorRandomSpawn()"... which had no randomness or chance in itself - it simply spawned an npc at the specified square on call.
---@param square any
---@return unknown|nil
function SuperSurvivorSpawnNpc(square)
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "function: SuperSurvivorSpawnNpc() called");
    local hoursSurvived = math.floor(getGameTime():getWorldAgeHours());
    local ASuperSurvivor = SSM:spawnSurvivor(nil, square);

    if (ASuperSurvivor ~= nil) then
        if (ZombRand(0, 100) < (WepSpawnRateGun + math.floor(hoursSurvived / 48))) then
            ASuperSurvivor:giveWeapon(SS_RangeWeapons[ZombRand(1, #SS_RangeWeapons)], true);
            -- make sure they have at least some ability to use the gun
            ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
            ASuperSurvivor.player:LevelPerk(Perks.FromString("Aiming"));
        elseif (ZombRand(0, 100) < (WepSpawnRateMelee + math.floor(hoursSurvived / 48))) then
            ASuperSurvivor:giveWeapon(SS_MeleeWeapons[ZombRand(1, #SS_MeleeWeapons)], true)
        end
    end

    -- clear the immediate area
    -- Cows: What exactly is happening here?... I don't think I ever seen the zombies get removed on an npx spawn...
    local zlist = getCell():getZombieList();
    local zRemoved = 0;
    if (zlist ~= nil) then
        CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "Z List Size" .. tostring(zlist:size()));
        CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "Clearing Zs from cell...");
        for i = zlist:size() - 1, 0, -1 do
            local z = zlist:get(i);

            -- Cows: The issue is with non-removal probably in this conditional check...
            if (z ~= nil)
                and (math.abs(z:getX() - square:getX()) < 2)
                and (math.abs(z:getY() - square:getY()) < 2)
                and (z:getZ() == square:getZ())
            then
                zRemoved = zRemoved + 1;
                z:removeFromWorld();
            end
        end
    end

    CreateLogLine("SuperSurvivorsMod", isLocalLoggingEnabled, "--- function: SuperSurvivorSpawnNpc() end ---");
    return ASuperSurvivor;
end
