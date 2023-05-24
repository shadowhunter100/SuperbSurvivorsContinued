-- Group Size applies to both npcs and raiders.
Max_Group_Size = SandboxVars.SuperbSurvivorsContinued.Max_Group_Size;
-- Min_Group_Size = SandboxVars.SuperbSurvivorsContinued.Min_Group_Size; -- Cows: Doesn't need to be set, min group size is always 1.

-- NPC Spawning
Limit_Npc_Groups = SandboxVars.SuperbSurvivorsContinued.Limit_Npc_Groups;
Limit_Npcs_Spawn = SandboxVars.SuperbSurvivorsContinued.Limit_Npcs_Spawn;
IsWifeSpawn = SandboxVars.SuperbSurvivorsContinued.IsWifeSpawn;
NpcGroupsSpawnsSize = SandboxVars.SuperbSurvivorsContinued.NpcGroupsSpawnsSize;
NpcSpawnChance = SandboxVars.SuperbSurvivorsContinued.NpcSpawnChance;
HostileSpawnRateBase = SandboxVars.SuperbSurvivorsContinued.HostileSpawnRateBase;
HostileSpawnRateMax = SandboxVars.SuperbSurvivorsContinued.HostileSpawnRateMax;

-- Raiders, Always hostile
RaidersSpawnChance = SandboxVars.SuperbSurvivorsContinued.RaidersSpawnChance;
RaidersStartAfterHours = SandboxVars.SuperbSurvivorsContinued.RaidersStartAfterHours;

-- NPC Configuration
CanIdleChat = SandboxVars.SuperbSurvivorsContinued.CanIdleChat;
CanNpcsCreateBase = SandboxVars.SuperbSurvivorsContinued.CanNpcsCreateBase;
IsInfiniteAmmoEnabled = SandboxVars.SuperbSurvivorsContinued.IsInfiniteAmmoEnabled;
IsRoleplayEnabled = SandboxVars.SuperbSurvivorsContinued.IsRoleplayEnabled;
IsSpeakEnabled = SandboxVars.SuperbSurvivorsContinued.IsSpeakEnabled;
SurvivorCanFindWork = SandboxVars.SuperbSurvivorsContinued.SurvivorCanFindWork;
SurvivorNeedsFoodWater = SandboxVars.SuperbSurvivorsContinued.SurvivorNeedsFoodWater;
SurvivorBravery = SandboxVars.SuperbSurvivorsContinued.SurvivorBravery;
SurvivorFriendliness = SandboxVars.SuperbSurvivorsContinued.SurvivorFriendliness;
SleepGeneralHealRate = SandboxVars.SuperbSurvivorsContinued.SleepGeneralHealRate;
GFollowDistance = SandboxVars.SuperbSurvivorsContinued.GFollowDistance;
PanicDistance = SandboxVars.SuperbSurvivorsContinued.PanicDistance;
WepSpawnRateGun = SandboxVars.SuperbSurvivorsContinued.WepSpawnRateGun;
WepSpawnRateMelee = SandboxVars.SuperbSurvivorsContinued.WepSpawnRateMelee;

-- Player Related
IsPlayerBaseSafe = SandboxVars.SuperbSurvivorsContinued.IsPlayerBaseSafe;
IsPVPEnabled = SandboxVars.SuperbSurvivorsContinued.IsPVPEnabled;

-- UI Related
IsDisplayingNpcName = SandboxVars.SuperbSurvivorsContinued.IsDisplayingNpcName;
IsDisplayingHostileColor = SandboxVars.SuperbSurvivorsContinued.IsDisplayingHostileColor;

local isDebuggingLogged = true;
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "Max_Group_Size: " .. tostring(Max_Group_Size));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "Limit_Npc_Groups: " .. tostring(Limit_Npc_Groups));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "Limit_Npcs_Spawn: " .. tostring(Limit_Npcs_Spawn));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsWifeSpawn: " .. tostring(IsWifeSpawn));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "NpcGroupsSpawnsSize: " .. tostring(NpcGroupsSpawnsSize));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "NpcSpawnChance: " .. tostring(NpcSpawnChance));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "HostileSpawnRateBase: " .. tostring(HostileSpawnRateBase));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "HostileSpawnRateMax: " .. tostring(HostileSpawnRateMax));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "");
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "RaidersSpawnChance: " .. tostring(RaidersSpawnChance));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "RaidersStartAfterHours: " .. tostring(RaidersStartAfterHours));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "");
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "CanIdleChat: " .. tostring(CanIdleChat));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "CanNpcsCreateBase: " .. tostring(CanNpcsCreateBase));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsInfiniteAmmoEnabled: " .. tostring(IsInfiniteAmmoEnabled));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsRoleplayEnabled: " .. tostring(IsRoleplayEnabled));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsSpeakEnabled: " .. tostring(IsSpeakEnabled));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SurvivorCanFindWork: " .. tostring(SurvivorCanFindWork));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SurvivorNeedsFoodWater: " .. tostring(SurvivorNeedsFoodWater));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SurvivorBravery: " .. tostring(SurvivorBravery));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SurvivorFriendliness: " .. tostring(SurvivorFriendliness));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SleepGeneralHealRate: " .. tostring(SleepGeneralHealRate));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "GFollowDistance: " .. tostring(GFollowDistance));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "PanicDistance: " .. tostring(PanicDistance));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "WepSpawnRateGun: " .. tostring(WepSpawnRateGun));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "WepSpawnRateMelee: " .. tostring(WepSpawnRateMelee));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "");
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsPlayerBaseSafe: " .. tostring(IsPlayerBaseSafe));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsPVPEnabled: " .. tostring(IsPVPEnabled));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsDisplayingNpcName: " .. tostring(IsDisplayingNpcName));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "IsDisplayingHostileColor: " .. tostring(IsDisplayingHostileColor));
CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SandboxVars: " .. tostring(SandboxVars.SuperbSurvivorsContinued));

for k, v in pairs(SandboxVars.SuperbSurvivorsContinued) do
    CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SandboxVars key: " .. tostring(k));
    CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SandboxVars val: " .. tostring(v));
end

CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "Attempt to reset superb survivors SandboxVars...");

SandboxVars.SuperbSurvivorsContinued = {};

for k, v in pairs(SandboxVars.SuperbSurvivorsContinued) do
    CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SandboxVars key: " .. tostring(k));
    CreateLogLine("SS_SuperSuvivorsSandBoxOptions", isDebuggingLogged, "SandboxVars val: " .. tostring(v));
end
