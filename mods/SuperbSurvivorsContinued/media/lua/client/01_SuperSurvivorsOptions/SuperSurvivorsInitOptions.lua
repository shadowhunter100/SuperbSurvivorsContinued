--[[
	thanks and some credit to Fenris_Wolf from ORGM mod for creating this hotkeys file!
	I just tweaked it to use my own key bindings! and added support for settings too ~Nolan
	
	Cows: I've added the Fenris_Wolf in the github credits and this file is replacing the old "SuperSurvivorSettings.lua" and "SuperSurvivorOptions".
	WIP - Cows: Need to review for issues, search for the "-- WIP -" comments
--]]
-- Group Size applies to both npcs and raiders.
Max_Group_Size = 4; -- WIP - PlaceHolder - Cows: Max number of members in a group
Min_Group_Size = 1; -- WIP - PlaceHolder - Cows: Min number of members in a group

-- NPC Spawning
Limit_Npc_Groups = 8;     -- WIP - PlaceHolder - Cows: Max npc groups
Limit_Npcs_Spawn = 22;    -- WIP - PlaceHolder - Cows: Max npc spwans
IsWifeSpawn = true;       -- Cows: true to spawn wife / 1st follower, false to not spawn wife / 1st follower
NoPresetSpawn = true;     -- Cows: true to disable preset spawns.
NPCGroupsSpawnsSize = 4; -- Cows: The max number of groups that can spawn every time.
NpcSpawnChance = 50;      -- WIP - Cows: NpcSpawnChance (formerly "AlternativeSpawning") is used when the player is in the current map area
HostileSpawnRateBase = 1; -- Cows: Chance that NPCs will be hostile initially on spawn
HostileSpawnRateMax = 10; -- WIP - Cows: Chance the NPCs will be hostile on spawn as time pass, capped at this value... need to test and verify.

-- Raiders, Always hostile
RaidersSpawnChance = 50;    -- WIP - Cows: Chance that NPCs spawns as raiders.
RaidersStartAfterHours = 0; -- WIP - Cows: Supposedly determines when raider can start spawning after set hours. 0 means raiders can spawn at start.

-- NPC Configuration
CanIdleChat = false;            -- Cows: true to allow npcs to speak while idle
CanNpcsCreateBase = false;      -- WIP - Cows: Allow npcs to create bases on their own... this has a huge performance impact.
IsInfiniteAmmoEnabled = true;   -- Cows: Npc Survivors has infinite ammo if true.
IsRoleplayEnabled = false;      -- WIP - Cows: I don't even think roleplay is actually working... disabling it for now.
IsSpeakEnabled = true;          -- WIP - Cows: Need to determine how this differs from CanIdleChat..
SurvivorCanFindWork = true;     -- Cows: true to allow npcs to "find work" when they have no tasks at base.
SurvivorNeedsFoodWater = false; -- Cows: true to activate npc survivor's hunger and thirst needs.
SurvivorBravery = 6;            -- WIP - Cows: Bravery needs to be reworked... because it is literally useless at the moment.
SurvivorFriendliness = 10;      -- WIP - Cows: There were no documentation on SurvivorFriendliness ... but there were 6 possible "num" values in ascending order.
SleepGeneralHealRate = 5;       -- WIP - Cows: NPCs heal while the player is asleep... higher value = more healing
GFollowDistance = 5;            -- WIP - Cows: need to verify the old comment in testing...
PanicDistance = 21;             -- WIP - Cows: Value is used in FleeFromHereTask()... but Fleeing needs to be reworked eventually...
WepSpawnRateGun = 50;           -- Cows: Gun Weapon Spawn rate... should be set betwen 0 and 100.
WepSpawnRateMelee = 100;        -- Cows: Melee Weapon Spawn rate... should be set betwen 0 and 100.
-- Player Related
IsPlayerBaseSafe = true; -- WIP - Cows: true to prevent NPCs from claiming or visiting the player base... this needs to be tested and verified.
IsPVPEnabled = true;

-- UI Related
IsDisplayingNpcName = true;
IsDisplayingHostileColor = true;

local isDebuggingLogged = true;
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "Max_Group_Size: " .. tostring(Max_Group_Size));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "Limit_Npc_Groups: " .. tostring(Limit_Npc_Groups));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "Limit_Npcs_Spawn: " .. tostring(Limit_Npcs_Spawn));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsWifeSpawn: " .. tostring(IsWifeSpawn));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "NoPresetSpawn: " .. tostring(NoPresetSpawn));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "NPCGroupsSpawnsSize: " .. tostring(NPCGroupsSpawnsSize));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "NpcSpawnChance: " .. tostring(NpcSpawnChance));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "HostileSpawnRateBase: " .. tostring(HostileSpawnRateBase));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "HostileSpawnRateMax: " .. tostring(HostileSpawnRateMax));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "");
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "RaidersSpawnChance: " .. tostring(RaidersSpawnChance));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "RaidersStartAfterHours: " .. tostring(RaidersStartAfterHours));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "");
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "CanIdleChat: " .. tostring(CanIdleChat));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "CanNpcsCreateBase: " .. tostring(CanNpcsCreateBase));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsInfiniteAmmoEnabled: " .. tostring(IsInfiniteAmmoEnabled));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsRoleplayEnabled: " .. tostring(IsRoleplayEnabled));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsSpeakEnabled: " .. tostring(IsSpeakEnabled));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "SurvivorCanFindWork: " .. tostring(SurvivorCanFindWork));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "SurvivorNeedsFoodWater: " .. tostring(SurvivorNeedsFoodWater));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "SurvivorBravery: " .. tostring(SurvivorBravery));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "SurvivorFriendliness: " .. tostring(SurvivorFriendliness));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "SleepGeneralHealRate: " .. tostring(SleepGeneralHealRate));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "GFollowDistance: " .. tostring(GFollowDistance));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "PanicDistance: " .. tostring(PanicDistance));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "WepSpawnRateGun: " .. tostring(WepSpawnRateGun));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "WepSpawnRateMelee: " .. tostring(WepSpawnRateMelee));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "");
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsPlayerBaseSafe: " .. tostring(IsPlayerBaseSafe));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsPVPEnabled: " .. tostring(IsPVPEnabled));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsDisplayingNpcName: " .. tostring(IsDisplayingNpcName));
CreateLogLine("SS_SuperSurvivorsInitOptions", isDebuggingLogged, "IsDisplayingHostileColor: " .. tostring(IsDisplayingHostileColor));