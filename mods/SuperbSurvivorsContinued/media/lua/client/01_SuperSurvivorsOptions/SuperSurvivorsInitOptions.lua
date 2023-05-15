--[[
	thanks and some credit to Fenris_Wolf from ORGM mod for creating this hotkeys file!
	I just tweaked it to use my own key bindings! and added support for settings too ~Nolan
	Cows: I've added the Fenris_Wolf in the github credits.
--]]
-- WIP - Cows: Need to review for issues, and separating the functions into smaller blocks for readability and easier maintenance.
local isLocalLoggingEnabled = true;

SuperSurvivorOptions = {
	["AltSpawn"]        = 2,
	["AltSpawnPercent"] = 10,
	["AltSpawnAmount"]  = 1
};

function SuperSurvivorGetOption(option)
	CreateLogLine("SuperSurvivorsInitOptions", isLocalLoggingEnabled, "function: SuperSurvivorGetOption() called");
	CreateLogLine("SuperSurvivorsInitOptions", isLocalLoggingEnabled,
		"option: " .. tostring(option) .. " | orderIndex: " .. tostring(SuperSurvivorOptions[option]));
	if (SuperSurvivorOptions[option] ~= nil) then
		return tonumber(SuperSurvivorOptions[option])
	else
		return 1
	end
end

function SuperSurvivorGetOptionValue(option)
	CreateLogLine("SuperSurvivorsInitOptions", isLocalLoggingEnabled, "function: SuperSurvivorGetOptionValue() called");
	local num = SuperSurvivorGetOption(option);
	CreateLogLine("SuperSurvivorsInitOptions", isLocalLoggingEnabled,
		"option: " .. tostring(option) .. " | num: " .. tostring(num));
	if (option == "AltSpawn") and (num == 1) then
		return 1   -- If false
	elseif (option == "AltSpawn") and (num == 2) then
		return 2   -- If true
	elseif (option == "AltSpawn") and (num == 3) then
		return 3   -- If true
	elseif (option == "AltSpawn") and (num == 4) then
		return 4   -- If true
	elseif (option == "AltSpawn") and (num == 5) then
		return 5   -- If true
	elseif (option == "AltSpawn") and (num == 6) then
		return 6   -- If true
	elseif (option == "AltSpawn") and (num == 7) then
		return 7   -- If true
	elseif (option == "AltSpawnPercent") then
		return (num - 1) -- % chance. in this case, 'num - 1' will make it goto 0 for what 'option 1' is.
	elseif (option == "AltSpawnAmount") and (num == 1) then
		return 1
	elseif (option == "AltSpawnAmount") and (num == 2) then
		return 2
	elseif (option == "AltSpawnAmount") and (num == 3) then
		return 3
	elseif (option == "AltSpawnAmount") and (num == 4) then
		return 4
	elseif (option == "AltSpawnAmount") and (num == 5) then
		return 5
	elseif (option == "AltSpawnAmount") and (num == 6) then
		return 6
	else
		return num
	end
end

-- ----------------------- --
-- Options Menu controller --
-- ----------------------- --

-- WIP - Cows: SuperSurvivorOptions variables...
-- NPC Spawning
-- Cows: There were no documentation on what the hell the spawnrate meant... but there were 12 possible values in ascending order.
--[[
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
BaseNpcSpawnRate = 0;     -- WIP - Cows: Default to Off by default.
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
CanFindWork = true;             -- Cows: true to allow npcs to "find work" when they have no tasks at base.
CanIdleChat = false;            -- Cows: true to allow npcs to speak while idle
PanicDistance = 21;             -- WIP - Cows: Value is used in FleeFromHereTask()... but Fleeing needs to be reworked eventually...
SurvivorNeedsFoodWater = false; -- Cows: true to activate npc survivor's hunger and thirst needs.
SurvivorFriendliness = 10;      -- WIP - Cows: There were no documentation on SurvivorFriendliness ... but there were 6 possible "num" values in ascending order.
--[[
	1 - "Desperate for Human Contact"
	2 - "Very Friendly"
	3 - "Friendly"
	4 - "Normal"
	5 - "Mean"
	6 - "Very Mean"
	Originally Calculated as such...  (10 - ((num - 1) * 2));
	Assuming higher = friendlier, why even bother with the calculation?
--]]
-- WIP - Cows: There were no documentations on Raiders Spawning ... so this section requires testing...
-- Raiders, Always hostile
local raidersSpawnFrequency = 1;                           -- Cows: Modify this value to determine spawn frequency
RaidersSpawnFrequencyByHours = raidersSpawnFrequency * 24; -- WIP - Cows: Spawn frequency in this example is once every 24 hours
--[[
	Originally calculated as ((num * 5) * 24)...
--]]
RaidersStartAfterHours = 0; -- WIP - Cows: Supposedly determines when raider can start spawning after set hours.
--[[
	Originally calculated as (((num - 2) * 5) * 24)...
--]]
RaidersChance = 70;
--[[
	There were 5 num values defined for RaidersChance...
	1 - Very High
	2 - High
	3 - Normal
	4 - Low
	5 - Very Low
	Originally calculated as ((num + 2) * 24 * 14) = (5 * 24 * 14)... wtf? wouldn't this always exceed 100?
--]]
-- Player Related
IsPlayerBaseSafe = true; -- WIP - Cows: true to prevent NPCs from claiming or visiting the player base... this needs to be verified and tested.
IsPVPEnabled = true;

-- UI Related
IsDisplayingNpcName = true;
IsDisplayingHostileColor = true;

function SuperSurvivorsRefreshSettings()
	Option_Display_Survivor_Names = IsDisplayingNpcName;
	Option_Display_Hostile_Color = IsDisplayingHostileColor;

	Option_Panic_Distance = PanicDistance;
	Option_ForcePVP = IsPVPEnabled;

	AlternativeSpawning = SuperSurvivorGetOptionValue("AltSpawn")
	AltSpawnGroupSize = SuperSurvivorGetOptionValue("AltSpawnAmount")
	AltSpawnPercent = SuperSurvivorGetOptionValue("AltSpawnPercent")
	NoPreSetSpawn = NoPresetSpawn;
	NoIdleChatter = CanIdleChat;

	IsSafeBaseActive = IsPlayerBaseSafe;
	NpcSurvivorCanCreateBases = CanNpcsCreateBase;
	SuperSurvivorSpawnRate = BaseNpcSpawnRate;
	ChanceToSpawnWithGun = WepSpawnRateGun;
	ChanceToSpawnWithWep = WepSpawnRateMelee;
	ChanceToBeHostileNPC = HostileSpawnRateBase;
	MaxChanceToBeHostileNPC = HostileSpawnRateMax; -- Fixed, it used to contain 'HostileSpawnRate', previously making MaxHostileSpawnRate a useless option

	SurvivorInfiniteAmmo = IsInfiniteAmmoEnabled;
	SurvivorHunger = SurvivorNeedsFoodWater;
	SurvivorsFindWorkThemselves = CanFindWork;

	RaidsAtLeastEveryThisManyHours = RaidersSpawnFrequencyByHours;
	RaidsStartAfterThisManyHours = RaidersStartAfterHours;
	RaidChanceForEveryTenMinutes = RaidersChance;
end

SuperSurvivorsRefreshSettings();
