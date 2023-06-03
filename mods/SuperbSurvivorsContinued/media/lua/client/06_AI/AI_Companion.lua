-- --------------------------------------- --
-- Companion follower related code         --
-- --------------------------------------- --
---Cows: to my knowledge, "Companion" role is exclusive to the player group...
---@param TaskMangerIn any
function AI_Companion(TaskMangerIn)
    local currentNPC = TaskMangerIn.parent; -- replaces both "ASuperbSurvivor" and "NPC".
    local npcBravery = currentNPC:getBravePoints();
    local npcIsInjured = currentNPC:HasInjury();
    local npcWeapon = currentNPC.player:getPrimaryHandItem();
    --
    local npcAttackRange = currentNPC:getAttackRange();
    local followedTarget = currentNPC:getFollowChar();
    local followAttackRange = GFollowDistance + npcAttackRange;
    --
    local dangerRange = 6;
    local distanceBetweenEnemyAndFollowTarget = 5;
    local distance_AnyEnemy = 10;
    -- Cows: Added a check... otherwise distance_AnyEnemy is always 1 or nil.
    if (currentNPC.LastEnemeySeen ~= nil) then
        distance_AnyEnemy = GetDistanceBetween(currentNPC.LastEnemeySeen, currentNPC:Get()); -- idk if this works
        distanceBetweenEnemyAndFollowTarget = GetDistanceBetween(currentNPC.LastEnemeySeen, followedTarget)
    end

    local isEnemyZombie = (instanceof(currentNPC.LastEnemeySeen, "IsoZombie"));
    local isEnemySurvivor = (instanceof(currentNPC.LastEnemeySeen, "IsoPlayer"));
    local enemySurvivor = nil;

    if (isEnemySurvivor) then
        local id = currentNPC.LastEnemeySeen:getModData().ID;
        enemySurvivor = SSM:Get(id);
    end

    -- local help functions
    local function Task_Is(TaskName)
        return (TaskMangerIn:getCurrentTask() == TaskName)
    end

    -- Cows: No clue what the deal is here...
    if (currentNPC:needToFollow()) then
        currentNPC.LastEnemeySeen = nil;
        TaskMangerIn:clear();
        TaskMangerIn:AddToTop(FollowTask:new(currentNPC, getSpecificPlayer(0)));
    end
    --
    -- Cows: Updated the distance code... so companions should NEVER leave the player's side.
    local distanceFromMainPlayer = GetDistanceBetween(getSpecificPlayer(0), currentNPC.player);
    -- Cows: Cut from SuperSurvivor:NPC_FleeWhileReadyingGun(), thsi should prevent companions from moving beyond GFollowDistance...
    if (distanceFromMainPlayer > GFollowDistance) then
        currentNPC:getTaskManager():clear();
        currentNPC:getTaskManager():AddToTop(FollowTask:new(currentNPC, getSpecificPlayer(0)));
        return TaskMangerIn; -- Cows: Stops further processing...
    end

    -- ------------ --
    -- Pursue
    -- ------------ --
    if AiNPC_TaskIsNot(TaskMangerIn, "First Aide")
        and AiNPC_TaskIsNot(TaskMangerIn, "Pursue")
        and AiNPC_TaskIsNot(TaskMangerIn, "Attack")
        and AiNPC_TaskIsNot(TaskMangerIn, "Flee")
        and (currentNPC.LastEnemeySeen ~= nil
            and distance_AnyEnemy < currentNPC:NPC_CheckPursueScore()
        )
    then
        if (isEnemySurvivor or isEnemyZombie) then
            TaskMangerIn:AddToTop(PursueTask:new(currentNPC, currentNPC.LastEnemeySeen));
        end
    end
    -- ----------- --
    -- Attack
    -- ----------- --
    if ((TaskMangerIn:getCurrentTask() ~= "Attack")
            and (TaskMangerIn:getCurrentTask() ~= "Threaten")
            and (TaskMangerIn:getCurrentTask() ~= "First Aide")
            and (currentNPC:isInSameRoom(currentNPC.LastEnemeySeen))
            and (not Task_Is("Flee"))
        )
        -- Cows: npcs can only attack seen danger.
        and (currentNPC:getDangerSeenCount() > 0)
        -- Cows: npcs only engages enemies while they're within the followAttackRange
        and ((distanceBetweenEnemyAndFollowTarget < followAttackRange))
    then
        if (currentNPC.player ~= nil)
            and (currentNPC.player:getModData().isRobber)
            and (not currentNPC.player:getModData().hitByCharacter)
            and isEnemySurvivor
            and (not enemySurvivor.player:getModData().dealBreaker)
        then
            TaskMangerIn:AddToTop(ThreatenTask:new(currentNPC, enemySurvivor, "Scram"));
        else
            TaskMangerIn:AddToTop(AttackTask:new(currentNPC));
        end
    end

    -- --------------------------------- --
    -- 	Reload Gun
    -- --------------------------------- --
    if (currentNPC:getNeedAmmo()) and (currentNPC:hasAmmoForPrevGun()) then
        currentNPC:setNeedAmmo(false);
        currentNPC:reEquipGun();
    end

    -- --------------------------------- --
    -- 	Ready Weapon
    -- --------------------------------- --
    if ((currentNPC:needToReload())
            or (currentNPC:needToReadyGun(npcWeapon)))
        and ((currentNPC:hasAmmoForPrevGun())
            or IsInfiniteAmmoEnabled)
        and currentNPC:usingGun() -- removed and (currentNPC:getNeedAmmo() condition -
    then
        currentNPC:ReadyGun(npcWeapon);
    end

    -- ----------------------------- --
    -- 	Equip Weapon                 --
    -- ----------------------------- --
    if (currentNPC:hasWeapon()) and (currentNPC:Get():getPrimaryHandItem() == nil) and (TaskMangerIn:getCurrentTask() ~= "Equip Weapon") then
        TaskMangerIn:AddToTop(EquipWeaponTask:new(currentNPC))
    end

    -- Cows: Conditions for fleeing and healing...
    if (TaskMangerIn:getCurrentTask() ~= "Flee") then
        --
        if (npcIsInjured and currentNPC:getDangerSeenCount() > 0) then
            currentNPC:Speak("Cover me! I'm hurt and I need to heal!");
            TaskMangerIn:AddToTop(FleeTask:new(currentNPC));
        elseif ((currentNPC:getDangerSeenCount() > npcBravery)
                and (currentNPC:hasWeapon())
                and (not currentNPC:usingGun()) -- Melee
                and (currentNPC.EnemiesOnMe > 2)
            )
        then
            currentNPC:Speak("This is too much! Let's get out of here!");
            TaskMangerIn:AddToTop(FleeTask:new(currentNPC));
        elseif (currentNPC:getDangerSeenCount() > npcBravery)
            and ((currentNPC:hasWeapon()) and (currentNPC:usingGun())) -- Gun
            and (currentNPC:needToReload() or not ISReloadWeaponAction.canShoot(npcWeapon))
        then
            -- Cows: Added this check to stop companions from shitting themselves while using a gun.
            if (distance_AnyEnemy < dangerRange) then
                currentNPC:Speak("Cover me! I need to back off for a bit!");
                TaskMangerIn:AddToTop(FleeTask:new(currentNPC));
            end
        end
    end
    -- Heal self if there are no dangers nearby
    if (npcIsInjured and currentNPC:getDangerSeenCount() <= 0) then
        if (TaskMangerIn:getCurrentTask() ~= "First Aide") then
            TaskMangerIn:AddToTop(FirstAideTask:new(currentNPC));
        end
    end
end
