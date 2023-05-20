--- WIP - Cows: Need to rework the spawning functions and logic...
---
---@return any
function SuperSurvivorsRaiderManager()
	local isLocalFunctionLoggingEnabled = false;
	local mySS = SSM:Get(0);
	local hisGroup = mySS:getGroup();

	if (getSpecificPlayer(0) == nil or hisGroup == nil) then
		return false;
	end

	if (getSpecificPlayer(0):getModData().LastRaidTime == nil) then
		getSpecificPlayer(0):getModData().LastRaidTime = (RaidersStartAfterHours + 2);
	end

	local hours = math.floor(getGameTime():getWorldAgeHours());
	local LastRaidTime = getSpecificPlayer(0):getModData().LastRaidTime;
	local spawnChanceVal = RaidersSpawnChance;

	local activeNpcs = Get_SS_Alive_Count();
	local RaidersStartTimePassed = (hours >= RaidersStartAfterHours);
	local RaiderAtLeastTimedExceeded = ((hours - LastRaidTime) >= RaidersSpawnFrequencyByHours);
	-- Cows: Spawn if spawnChanceVal is greater than the random roll between 0 and 100, and activeNPCs are less than the limit.
   local isSpawning = (spawnChanceVal > ZombRand(0, 100) and activeNpcs < Limit_Raiders_Spawn);

	if RaidersStartTimePassed and (RaiderAtLeastTimedExceeded or isSpawning) then
		CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "spawning raiders...");

		local center = Get_SS_PlayerGroupBoundsCenter(hisGroup);
		local spawnSquare = Set_SS_SpawnSquare(hisGroup, center);

		-- WIP - Cows: Need to rework the spawning functions and logic...
		-- TODO: Capped the number of groups, now to cap the number of survivors and clean up dead ones.
		if (spawnSquare ~= nil) then
			-- RAIDER GROUPS
			local raiderGroup;

			if (SSGM.GroupCount < Limit_Raiders_Groups) then
				raiderGroup = SSGM:newGroup();
			else
				-- something ... repopulate the previous groups?
				local rng = ZombRand(1, Limit_Raiders_Groups);
                raiderGroup = SSGM:GetGroupById(rng);
            end

            local GroupSize = ZombRand(1, Max_Group_Size);
            local nearestRaiderDistance = 30;

            for i = 1, GroupSize do
                local raider = SuperSurvivorSpawnNpc(spawnSquare);
                if (raider) then
                    local name = raider:getName();

                    if (i == 1) then
                        raiderGroup:addMember(raider, "Leader");
                    else
                        raiderGroup:addMember(raider, "Guard");
                    end
                    raider:setHostile(true);
                    raider.player:getModData().isRobber = true;
                    raider:setName("Raider " .. name);
                    raider:getTaskManager():AddToTop(PursueTask:new(raider, mySS:Get()));

                    Equip_SS_RandomNpc(raider, true);

                    local number = ZombRand(1, 3);
                    SetRandomSurvivorSuit(raider, "Rare", "Bandit" .. tostring(number));
                    local currentRaiderDistanceFromPlayer = GetDistanceBetween(raider, mySS);

                    if (nearestRaiderDistance > currentRaiderDistanceFromPlayer) then
                        nearestRaiderDistance = currentRaiderDistanceFromPlayer;
                    end
                end
            end

			getSpecificPlayer(0):getModData().LastRaidTime = hours;
			if (getSpecificPlayer(0):isAsleep() and nearestRaiderDistance < 15) then
				getSpecificPlayer(0):Say(Get_SS_Dialogue("IGotABadFeeling"));
				getSpecificPlayer(0):forceAwake();
			else
				getSpecificPlayer(0):Say(Get_SS_Dialogue("WhatWasThatSound"));
			end

			-- RaiderGroup:AllSpokeTo(); -- Cows: seems useless?
		end
	end
end

Events.EveryHours.Add(SuperSurvivorsRaiderManager);