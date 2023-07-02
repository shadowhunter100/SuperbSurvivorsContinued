function Get_SS_SandboxOptions()
    local ss_options = SandboxVars.SuperbSurvivorsContinued;
    -- Group Size applies to both npcs and raiders.
    Max_Group_Size = ss_options.Max_Group_Size;
    -- Min_Group_Size = ss_options.Min_Group_Size; -- Cows: Doesn't need to be set, min group size is always 1.

    -- NPC Spawning
    Limit_Npc_Groups = ss_options.Limit_Npc_Groups;
    Limit_Npcs_Spawn = ss_options.Limit_Npcs_Spawn;
    -- Set the skill level of all NPCs to 10. 设置所有npc的技能等级为10级
    Perk_Level = ss_options.Perk_Level;
    IsWifeSpawn = ss_options.IsWifeSpawn;
    -- add Optional number of Wife.
    IsWifeSpawnNumb = ss_options.IsWifeSpawnNumb;
    NpcGroupsSpawnsSize = ss_options.NpcGroupsSpawnsSize;
    NpcSpawnChance = ss_options.NpcSpawnChance;
    HostileSpawnRateBase = ss_options.HostileSpawnRateBase;
    HostileSpawnRateMax = ss_options.HostileSpawnRateMax;

    -- Raiders, Always hostile
    RaidersSpawnChance = ss_options.RaidersSpawnChance;
    RaidersStartAfterHours = ss_options.RaidersStartAfterHours;

    -- NPC Configuration
    CanIdleChat = ss_options.CanIdleChat;
    CanNpcsCreateBase = ss_options.CanNpcsCreateBase;
    IsInfiniteAmmoEnabled = ss_options.IsInfiniteAmmoEnabled;
    IsRoleplayEnabled = ss_options.IsRoleplayEnabled;
    IsSpeakEnabled = ss_options.IsSpeakEnabled;
    SurvivorCanFindWork = ss_options.SurvivorCanFindWork;
    SurvivorNeedsFoodWater = ss_options.SurvivorNeedsFoodWater;
    SurvivorBravery = ss_options.SurvivorBravery;
    SurvivorFriendliness = ss_options.SurvivorFriendliness;
    SleepGeneralHealRate = ss_options.SleepGeneralHealRate;
    GFollowDistance = ss_options.GFollowDistance;
    PanicDistance = ss_options.PanicDistance;
    WepSpawnRateGun = ss_options.WepSpawnRateGun;
    WepSpawnRateMelee = ss_options.WepSpawnRateMelee;

    -- Player Related
    IsPlayerBaseSafe = ss_options.IsPlayerBaseSafe;
    IsPVPEnabled = ss_options.IsPVPEnabled;

    -- UI Related
    IsDisplayingNpcName = ss_options.IsDisplayingNpcName;
    IsDisplayingHostileColor = ss_options.IsDisplayingHostileColor;

    return ss_options;
end

-- Cows: Credits to "albion#0123" on discord for explaining Events orders... otherwise sandbox-options are never updated.
Events.OnInitGlobalModData.Add(Get_SS_SandboxOptions);