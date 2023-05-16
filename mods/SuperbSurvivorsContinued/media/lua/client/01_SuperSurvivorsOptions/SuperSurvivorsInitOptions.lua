--[[
	thanks and some credit to Fenris_Wolf from ORGM mod for creating this hotkeys file!
	I just tweaked it to use my own key bindings! and added support for settings too ~Nolan
	Cows: I've added the Fenris_Wolf in the github credits.
--]]
-- WIP - Cows: Need to review for issues, and separating the functions into smaller blocks for readability and easier maintenance.
local isLocalLoggingEnabled = false;

-- ----------------------- --
-- Options Menu controller --
-- ----------------------- --

-- WIP - Cows: SuperSurvivorOptions variables...
-- NPC Spawning
-- Cows: There were no documentation on what the hell the AlternativeSpawning and spawnrate meant... but there were multiple possible values in ascending order.
--[[
	AlternativeSpawning
	1 - Off
	2 - five percent
	3 - ten percent
	4 - twenty percent
	5 - thirty percent
	6 - fourty percent
	7 - fifty percent
--]]
-- Cows: AlternativeSpawnChance (formerly "AlternativeSpawning") is used when the player is in the current map area
AlternativeSpawnChance = 5; -- WIP - Cows: Confusing spawning mechanics... needs another look...
AltSpawnGroupSize = 1;
--[[
	SpawnRate
	0 - Off
	64000 - "Ultra Low"
	32000 - "Extremely Low"
	26000 - "Very Low"
	20000 - "Low"
	16000 - "Slightly Lower"
	12000 - "Normal"
	8000 - "Slightly Higher"
	4000 - "High"
	2500 - "Very High"
	1000 - "Extremely High"
	400 - "Ultra High"
--]]
-- Cows: BaseNpcSpawnChance (formerly "SpawnRate") is used when the player enters an unvisited map area
BaseNpcSpawnChance = 0;     -- WIP - Cows: Default to Off by default.
HostileSpawnRateBase = 1; -- Cows: Chance that NPCs will be hostile initially on spawn
HostileSpawnRateMax = 17; -- Cows: Chance the NPCs will be hostile on spawn as time pass, capped at this value
NoPresetSpawn = true;     -- Cows: true to disable preset spawns.
WifeSpawn = true;         -- Cows: true to spawn wife / 1st follower, false to not spawn wife / 1st follower

-- NPC Configuration
CanNpcsCreateBase = false;    -- WIP - Cows: Allow npcs to create bases on their own... this has a huge performance impact.
IsInfiniteAmmoEnabled = true; -- Cows: Npc Survivors has infinite ammo if true.
IsRoleplayEnabled = false;    -- WIP - Cows: I don't even think roleplay is actually working... disabling it for now.
WepSpawnRateGun = 50;         -- Cows: Gun Weapon Spawn rate... should be set betwen 0 and 100.
WepSpawnRateMelee = 100;      -- Cows: Melee Weapon Spawn rate... should be set betwen 0 and 100.


-- NPC Behaviors
CanIdleChat = false;            -- Cows: true to allow npcs to speak while idle
PanicDistance = 21;             -- WIP - Cows: Value is used in FleeFromHereTask()... but Fleeing needs to be reworked eventually...
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

-- WIP - Cows: There were no documentations on Raiders Spawning ... so this section requires testing...
-- Raiders, Always hostile
RaidersSpawnFrequencyByHours = 24; -- WIP - Cows: Spawn frequency in this example is to guarantee a raiders spawn once every 24 hours
RaidersStartAfterHours = 0;        -- WIP - Cows: Supposedly determines when raider can start spawning after set hours.
RaidersSpawnChance = 10;           -- WIP - Cows: this is still in testing... apparently used to check for a raiders spawn every 10 minutes...

-- Player Related
IsPlayerBaseSafe = true; -- WIP - Cows: true to prevent NPCs from claiming or visiting the player base... this needs to be verified and tested.
IsPVPEnabled = true;

-- UI Related
IsDisplayingNpcName = true;
IsDisplayingHostileColor = true;
