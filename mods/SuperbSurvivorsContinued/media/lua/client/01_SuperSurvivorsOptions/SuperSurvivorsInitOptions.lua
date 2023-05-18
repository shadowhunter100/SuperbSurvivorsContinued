--[[
	thanks and some credit to Fenris_Wolf from ORGM mod for creating this hotkeys file!
	I just tweaked it to use my own key bindings! and added support for settings too ~Nolan
	Cows: I've added the Fenris_Wolf in the github credits.
--]]
-- WIP - Cows: Need to review for issues, and separating the functions into smaller blocks for readability and easier maintenance.
local isLocalLoggingEnabled = false;

-- WIP - Cows: SuperSurvivorOptions variables...
-- NPC Spawning
NpcSpawnChance = 50;       -- WIP - Cows: NpcSpawnChance (formerly "AlternativeSpawning") is used when the player is in the current map area
HostileSpawnRateBase = 1; -- Cows: Chance that NPCs will be hostile initially on spawn
HostileSpawnRateMax = 17; -- WIP - Cows: Chance the NPCs will be hostile on spawn as time pass, capped at this value... need to test and verify.
IsWifeSpawn = true;       -- Cows: true to spawn wife / 1st follower, false to not spawn wife / 1st follower
NoPresetSpawn = true;     -- Cows: true to disable preset spawns.
Limit_Npc_Groups = 4;     -- WIP - PlaceHolder - Cows: Max npc groups, independent of Raider Groups.
Limit_Npcs_Spawn = 12;    -- WIP - PlaceHolder - Cows: Max npc spwans, independent of raiders spawns.
Max_Group_Size = 4;       -- WIP - PlaceHolder - Cows: Max number of members in a group
Min_Group_Size = 1;       -- WIP - PlaceHolder - Cows: Min number of members in a group

-- Raiders, Always hostile
Limit_Raiders_Groups = 4; -- WIP - PlaceHolder - Cows: Max raider groups, independent of npc groups.
Limit_Raiders_Spawn = 8;  -- WIP - PlaceHolder - Cows: Max raiders spaws, independent of npcs spawns.
RaidersSpawnFrequencyByHours = 24; -- WIP - Cows: Spawn frequency in this example is to guarantee a raiders spawn once every 24 hours
RaidersStartAfterHours = 0;        -- WIP - Cows: Supposedly determines when raider can start spawning after set hours.
RaidersSpawnChance = 50;           -- WIP - Cows: this is still in testing... apparently used to check for a raiders spawn every 10 minutes...

-- NPC Configuration
CanNpcsCreateBase = false;    -- WIP - Cows: Allow npcs to create bases on their own... this has a huge performance impact.
IsInfiniteAmmoEnabled = true; -- Cows: Npc Survivors has infinite ammo if true.
IsRoleplayEnabled = false;    -- WIP - Cows: I don't even think roleplay is actually working... disabling it for now.
IsSpeakEnabled = true;        -- WIP - Cows: Need to determine how this differs from CanIdleChat..
SleepGeneralHealRate = 5;     -- WIP - Cows: NPCs heal while the player is asleep... higher value = more healing
WepSpawnRateGun = 50;         -- Cows: Gun Weapon Spawn rate... should be set betwen 0 and 100.
WepSpawnRateMelee = 100;      -- Cows: Melee Weapon Spawn rate... should be set betwen 0 and 100.

-- NPC Behaviors
CanIdleChat = false;            -- Cows: true to allow npcs to speak while idle
-- old comment - Update: Don't try to turn gfollowdistance into a variable from what it equals to. I made followtask add what it needs to add on its own.
GFollowDistance = 5;            -- WIP - Cows: need to verify the old comment in testing...
PanicDistance = 21;             -- WIP - Cows: Value is used in FleeFromHereTask()... but Fleeing needs to be reworked eventually...
SuperSurvivorBravery = 6;       -- WIP - Cows: Bravery needs to be reworked... because it is literally useless at the moment.
SurvivorCanFindWork = true;     -- Cows: true to allow npcs to "find work" when they have no tasks at base.
SurvivorNeedsFoodWater = false; -- Cows: true to activate npc survivor's hunger and thirst needs.
--[[
	-- WIP - Cows: There were no documentation on SurvivorFriendliness ... but there were 6 possible "num" values in ascending order.
	1 - "Desperate for Human Contact"
	2 - "Very Friendly"
	3 - "Friendly"
	4 - "Normal"
	5 - "Mean"
	6 - "Very Mean"
	Originally Calculated as such...  (10 - ((num - 1) * 2));
	Assuming higher = friendlier, why even bother with the calculation?
--]]
SurvivorFriendliness = 10;


-- Player Related
IsPlayerBaseSafe = true; -- WIP - Cows: true to prevent NPCs from claiming or visiting the player base... this needs to be tested and verified.
IsPVPEnabled = true;

-- UI Related
IsDisplayingNpcName = true;
IsDisplayingHostileColor = true;
