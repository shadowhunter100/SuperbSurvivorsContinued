-- --------------------------------------- --
-- Non-Companion related code         --
-- --------------------------------------- --
---comment
---@param TaskMangerIn any
function AI_NonCompanion(TaskMangerIn)
    local currentNPC = TaskMangerIn.parent; -- replaces both "ASuperbSurvivor" and "NPC".
    local npcBravery = currentNPC:getBravePoints();
    local npcIsInAction = currentNPC:isInAction();
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
        distanceBetweenEnemyAndFollowTarget = GetDistanceBetween(currentNPC.LastEnemeySeen, followedTarget);
    end

    local isEnemySurvivor = (instanceof(currentNPC.LastEnemeySeen, "IsoPlayer"));
    local enemySurvivor = nil;

    if (isEnemySurvivor) then
        local id = currentNPC.LastEnemeySeen:getModData().ID;
        enemySurvivor = SSM:Get(id);
        --
    end

    -- local help functions
    local function Task_Is(TaskName)
        return (TaskMangerIn:getCurrentTask() == TaskName)
    end
    -- --------------------------------------- --
    -- Pursue Task 							   --
    -- --------------------------------------- --
    if (currentNPC:Task_IsPursue_SC() == true) and (distance_AnyEnemy <= 9) and (distance_AnyEnemy < currentNPC:NPC_CheckPursueScore()) then
        if (currentNPC:NPC_FleeWhileReadyingGun()) then
            TaskMangerIn:AddToTop(PursueTask:new(currentNPC, currentNPC.LastEnemeySeen)) -- If all checks out, pursue target
        end
    end
    --
    if ((TaskMangerIn:getCurrentTask() ~= "Attack")
            and (TaskMangerIn:getCurrentTask() ~= "Threaten")
            and (TaskMangerIn:getCurrentTask() ~= "First Aide")
            and (not Task_Is("Flee"))
            and (currentNPC:isInSameRoom(currentNPC.LastEnemeySeen))
        )
        and (currentNPC:getDangerSeenCount() > 0)                        -- cant attack what you don't see. must have seen an enemy in danger range to attack
        and (currentNPC:getCurrentTask() ~= "Follow"
            or (distanceBetweenEnemyAndFollowTarget < followAttackRange) -- move to engage an enemie only if they within follow range (when following)
        )
    then
        if (currentNPC.player ~= nil)
            and (currentNPC.player:getModData().isRobber)
            and (not currentNPC.player:getModData().hitByCharacter)
            and isEnemySurvivor
            and (not enemySurvivor.player:getModData().dealBreaker)
        then
            TaskMangerIn:AddToTop(ThreatenTask:new(currentNPC, enemySurvivor, "Scram"))
        else
            TaskMangerIn:AddToTop(AttackTask:new(currentNPC))
        end
    end
    -- ----------------------------- --
    -- New: To attempt players that are NOT trying to encounter a fight,
    -- should be able to run away. maybe a dice roll for the future?
    -- ----------------------------- --
    if (isEnemySurvivor) and ((Task_Is("Threaten")) and (distance_AnyEnemy > 10)) and (not Task_Is("Flee")) then
        TaskMangerIn:AddToTop(WanderTask:new(currentNPC))
        TaskMangerIn:AddToTop(AttemptEntryIntoBuildingTask:new(currentNPC, nil))
        TaskMangerIn:AddToTop(WanderTask:new(currentNPC))
        TaskMangerIn:AddToTop(FindBuildingTask:new(currentNPC))
    end

    -- ----------------------------- --
    -- 	Gun Readying / Reloading     --
    -- ----------------------------- --
    if (currentNPC:getNeedAmmo())
        and (currentNPC:hasAmmoForPrevGun())
        and (npcIsInAction == false)
        and (TaskMangerIn:getCurrentTask() ~= "Take Gift")
        and (TaskMangerIn:getCurrentTask() ~= "Flee")           -- New
        and (TaskMangerIn:getCurrentTask() ~= "Flee From Spot") -- New
        and (currentNPC:getDangerSeenCount() == 0)
    then
        currentNPC:setNeedAmmo(false);
        currentNPC:reEquipGun();
    end
    -- ----------------------------- --
    -- 	Equip Weapon Task            --
    -- ----------------------------- --
    if (currentNPC:hasWeapon())
        and (currentNPC:Get():getPrimaryHandItem() == nil)
        and (TaskMangerIn:getCurrentTask() ~= "Equip Weapon")
    then
        TaskMangerIn:AddToTop(EquipWeaponTask:new(currentNPC));
    end

    if (npcIsInAction == false)
        and currentNPC:usingGun()
        and (currentNPC:getDangerSeenCount() == 0)
        and ((currentNPC:needToReload())
            or (currentNPC:needToReadyGun(npcWeapon)))
        and (currentNPC:NPC_FleeWhileReadyingGun())
    then
        currentNPC:ReadyGun(npcWeapon);
    end
    -- Cows: Conditions for fleeing and healing...
    if (TaskMangerIn:getCurrentTask() ~= "Flee") then
        --
        if (npcIsInjured and currentNPC:getDangerSeenCount() > 0) then
            currentNPC:Speak("Fuck! I'm hurt and I need to heal!");
            TaskMangerIn:AddToTop(FleeTask:new(currentNPC));
        elseif ((currentNPC:getDangerSeenCount() > npcBravery)
                and (currentNPC:hasWeapon())
                and (not currentNPC:usingGun()) -- Melee
                and (currentNPC.EnemiesOnMe > 2)
            )
        then
            currentNPC:Speak("This is too much for me!");
            TaskMangerIn:AddToTop(FleeTask:new(currentNPC));
        elseif (currentNPC:getDangerSeenCount() > npcBravery)
            and ((currentNPC:hasWeapon()) and (currentNPC:usingGun()))     -- Gun
            and (currentNPC:needToReload() or not ISReloadWeaponAction.canShoot(npcWeapon))
        then
            if (distance_AnyEnemy < dangerRange) then -- Cows: Added this check to stop companions from shitting themselves while using a gun.
                currentNPC:Speak("I need some space here!");
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
