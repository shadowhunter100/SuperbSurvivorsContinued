本地isLocalLoggingEnabled = false ;

---
--[[
	合并 SuperSurvivorsNewSurvivorManager() 和 SuperSurvivorDoRandomSpawns() 中的相同代码块
	Cows：显然，无论出于何种原因，这些功能都需要定期运行......
	我能理解睡眠召唤，因为NPC可以在玩家睡觉时进行治疗。
	不知道内部愈合是否会影响感染状态或受伤...
--]]
函数Refresh_SS_NpcStatus()
    --这与袭击者无关，但需要偶尔运行一次
    -- WIP - 奶牛：为什么需要运行？
    getSpecificPlayer( 0 ):getModData().hitByCharacter = false ;
    getSpecificPlayer( 0 ):getModData().semiHostile = false ;
    getSpecificPlayer( 0 ):getModData().dealBreaker = nil ;

    if (getSpecificPlayer( 0 ):isAsleep()) then
        SSM:AsleepHealAll()
    结尾
结尾

--- 合并 SuperSurvivorsNewSurvivorManager() 和 SuperSurvivorDoRandomSpawns() 中的相同代码块
---@param playerGroup 任意
---@返回任何
函数Get_SS_PlayerGroupBoundsCenter(playerGroup)
    本地边界=playerGroup:getBounds();
    当地中心；

    如果（界限）那么
        中心 = GetCenterSquareFromArea(边界[ 1 ], 边界[ 2 ], 边界[ 3 ], 边界[ 4 ], 边界[ 5 ]);
    结尾

    如果（不是中心）那么
        中心 = getSpecificPlayer( 0 ):getCurrentSquare();
    结尾

    退货中心；
结尾

- -评论
---@param npc 任意
---@param isRaider 任意
---@返回任何
函数Equip_SS_RandomNpc(npc, isRaider)
    本地isLocalFunctionLoggingEnabled = false ;
    CreateLogLine( "NpcGroupsSpawnsCore" , isLocalFunctionLoggingEnabled, "函数：调用了 Equip_SS_RandomNpc()" );

    if (npc:hasWeapon() == false )那么
        npc:giveWeapon(SS_MeleeWeapons[ZombRand( 1 , #SS_MeleeWeapons)]);
    结尾

    本地包 = npc:getBag();
    当地食物；
    本地计数 = ZombRand( 0 , 3 );

    if (isRaider) then
        对于i = 1，数do
            食物= “Base.CannedCorn” ;
            袋：AddItem(食物);
        结尾
        本地rCount = ZombRand( 0 , 3 );
        对于i = 1， rCount做
            食物= “Base.Apple”；
            袋：AddItem(食物);
        结尾
    别的
        对于i = 1，数do
            食物= “基础”。.. tostring(CannedFoods[ZombRand(#CannedFoods) + 1 ]);
            袋：AddItem(食物);
        结尾

        本地rCount = ZombRand( 0 , 3 );
        对于i = 1， rCount做
            食物= “Base.TinnedBeans”；
            袋：AddItem(食物);
        结尾
    结尾

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
function SuperSurvivorSpawnNpcAtSquare(square)
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("NpcGroupsSpawnsCore", isLocalFunctionLoggingEnabled, "function: SuperSurvivorSpawnNpcAtSquare() called");
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
    -- Cows: What exactly is happening here?... I don't think I ever seen the zombies get removed on an npc spawn...
    local zlist = getCell():getZombieList();
    local zRemoved = 0;
    if (zlist ~= nil) then
        CreateLogLine("NpcGroupsSpawnsCore", isLocalFunctionLoggingEnabled, "Z List Size: " .. tostring(zlist:size()));
        CreateLogLine("NpcGroupsSpawnsCore", isLocalFunctionLoggingEnabled, "Clearing Zs from cell...");
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

    CreateLogLine("NpcGroupsSpawnsCore", isLocalFunctionLoggingEnabled, "zRemoved: " .. tostring(zRemoved));
    CreateLogLine("NpcGroupsSpawnsCore", isLocalFunctionLoggingEnabled, "--- function: SuperSurvivorSpawnNpcAtSquare() end ---");
    return ASuperSurvivor;
end

--- Cows: Separated from SuperSurvivorPlayerInit()
---@param player any
function SuperSurvivorSpawnWife(player)
    local wife
    if (player:getModData().WifeID == nil)
        and (IsWifeSpawn)
    then
        -- set SuperSurvivor gender to girl
        if WifeIsFemale == true then
            gender = true
        else
            gender = (not player:isFemale())
        end
        --Control the number of  generated by wife. 
        for i = 1, WifeCount do
            player:getModData().WifeID = 0;

            wife = SSM:spawnSurvivor(gender, player:getCurrentSquare());

            local MData = wife:Get():getModData();

            wife:Get():getModData().InitGreeting = Get_SS_DialogueSpeech("WifeIntro");
            wife:Get():getModData().seenZombie = true;
            local pistol = wife:Get():getInventory():AddItem("Base.Pistol");
            local baseballBat = wife:Get():getInventory():AddItem("Base.BaseballBat");
            wife:Get():getInventory():AddItem("Base.TinOpener");
            wife:Get():getInventory():AddItem("Base.ElectronicsMag4");

            wife:Get():setPrimaryHandItem(baseballBat);
            wife:Get():setSecondaryHandItem(baseballBat);
            wife:setMeleWep(baseballBat);
            wife:setGunWep(pistol);


            MData.MetPlayer = true;
            MData.isHostile = false;

            local GID, Group;

            if (SSM:Get(0):getGroupID() == nil) then
                Group = SSGM:newGroup();
                GID = Group:getID();
                Group:addMember(SSM:Get(0), "Leader");
            else
                GID = SSM:Get(0):getGroupID();
                Group = SSGM:GetGroupById(GID);
            end

            Group:addMember(wife, Get_SS_JobText("Companion"))

            local followtask = FollowTask:new(wife, getSpecificPlayer(0));
            local tm = wife:getTaskManager();
            wife:setAIMode("Follow");
            tm:AddToTop(followtask);
            Add_SS_NpcPerkLevel(wife.player, "Aiming", 3); -- Cows: So wife can actually hit things with the pistol...
        end
    end
end

--- Cows: This is supposed to execute On Player creation, very close to the start of a game.
---@param player any
function SuperSurvivorPlayerInit(player)
	CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled, "function: SuperSurvivorPlayerInit() called");
	player:getModData().isHostile = false
	player:getModData().semiHostile = false
	player:getModData().hitByCharacter = false
	player:getModData().ID = 0
	player:setBlockMovement(false)
	player:setNPC(false)
	CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled,
		"initing player index " .. tostring(player:getPlayerNum()));

	if (player:getPlayerNum() == 0) then
		SSM:init();
		MyGroup = SSGM:newGroup();
		MyGroup:addMember(SSM:Get(0), "Leader");
		local spawnBuilding = SSM:Get(0):getBuilding();

        SuperSurvivorSpawnWife(player);

		if (spawnBuilding) then -- spawn building is default group base
			CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled, "set building " .. tostring(MyGroup:getID()));
			local def = spawnBuilding:getDef()
			local bounds = { def:getX(), (def:getX() + def:getW()), def:getY(), (def:getY() + def:getH()), 0 }
			MyGroup:setBounds(bounds)
		else
			CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled, "Did not spawn in a building!");
		end

		local mydesc = getSpecificPlayer(0):getDescriptor();

		if (SSM:Get(0)) then
			SSM:Get(0):setName(mydesc:getForename());
		end
	else
		CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled,
			"finished initing player index " .. tostring(player:getPlayerNum()));
	end
end

NumberOfLocalPlayers = 0; -- Cows: NOTE: NPCs and Raiders are treated as "local players" in Superb Survivors

function SSCreatePlayerHandle(newplayerID)
	local newplayer = getSpecificPlayer(newplayerID);
	local MD = newplayer:getModData();

	if (not MD.ID) and (newplayer:isLocalPlayer()) then
		SuperSurvivorPlayerInit(newplayer)

		if (getSpecificPlayer(0) and (not getSpecificPlayer(0):isDead()) and (getSpecificPlayer(0) ~= newplayer)) then
			local MainSS = SSM:Get(0);
			local MainSSGroup = MainSS:getGroup();
			NumberOfLocalPlayers = NumberOfLocalPlayers + 1;
			local newSS = SSM:setPlayer(newplayer, NumberOfLocalPlayers);
			newSS:setID(NumberOfLocalPlayers);
			MainSSGroup:addMember(newSS, "Guard");
		end
	end
end

Events.OnCreatePlayer.Add(SSCreatePlayerHandle)

function SuperSurvivorsInit()
	SurvivorsCreatePVPButton();
	SurvivorTogglePVP();

	if (IsoPlayer.getCoopPVP() == true
			or IsPVPEnabled == true) then
		SurvivorTogglePVP()
	end

	local player = getSpecificPlayer(0)
	player:getModData().isHostile = false
	player:getModData().ID = 0

	if (player:getX() >= 7679 and player:getX() <= 7680) and (player:getY() >= 11937 and player:getY() <= 11938) then -- if spawn in prizon
		local keyid = player:getBuilding():getDef():getKeyId();

		if (keyid) then
			local key = player:getInventory():AddItem("Base.Key1");
			key:setKeyId(keyid);
			player:getCurrentSquare():getE():AddWorldInventoryItem(key, 0.5, 0.5, 0);
			player:getInventory():Remove(key);
		end
	end
end

Events.OnGameStart.Add(SuperSurvivorsInit)
