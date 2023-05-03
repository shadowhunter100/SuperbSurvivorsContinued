--[[
	thanks and some credit to Fenris_Wolf from ORGM mod for creating this hotkeys file!
	I just tweaked it to use my own key bindings! and added support for settings too ~Nolan
--]]

-- WIP - Need to review for issues, and separating the functions into smaller blocks for readability and easier maintenance.
local isLocalLoggingEnabled = false;

local function doesOptionsFileExist()
	local readFile = getFileReader("SurvivorOptions.lua", false)

	if (readFile) then
		return true
	else
		return false
	end
end

SuperSurvivorOptions = {};

local function loadSurvivorOptions()
	if (doesOptionsFileExist() == false) then
		return nil
	end

	local fileTable = {}
	local readFile = getFileReader("SurvivorOptions.lua", false)
	local scanLine = readFile:readLine()
	while scanLine do
		local values = {}
		for input in scanLine:gmatch("%S+") do
			table.insert(values, input);
		end

		if (fileTable[values[1]] == nil) then
			fileTable[values[1]] = {};
		end
		fileTable[values[1]] = tonumber(values[2]);
		scanLine = readFile:readLine();
		if not scanLine then break; end
	end
	readFile:close();

	return fileTable;
end

SuperSurvivorOptions = loadSurvivorOptions()
if (not SuperSurvivorOptions) then SuperSurvivorOptions = {} end
if (not SuperSurvivorOptions["SpawnRate"]) then SuperSurvivorOptions["SpawnRate"] = 7 end
if (not SuperSurvivorOptions["WifeSpawn"]) then SuperSurvivorOptions["WifeSpawn"] = 1 end
if (not SuperSurvivorOptions["LockNLoad"]) then SuperSurvivorOptions["LockNLoad"] = 1 end
if (not SuperSurvivorOptions["GunSpawnRate"]) then SuperSurvivorOptions["GunSpawnRate"] = 1 end
if (not SuperSurvivorOptions["WepSpawnRate"]) then SuperSurvivorOptions["WepSpawnRate"] = 99 end
if (not SuperSurvivorOptions["HostileSpawnRate"]) then SuperSurvivorOptions["HostileSpawnRate"] = 1 end
if (not SuperSurvivorOptions["MaxHostileSpawnRate"]) then SuperSurvivorOptions["MaxHostileSpawnRate"] = 17 end
if (not SuperSurvivorOptions["InfinitAmmo"]) then SuperSurvivorOptions["InfinitAmmo"] = 2 end
if (not SuperSurvivorOptions["NoPreSetSpawn"]) then SuperSurvivorOptions["NoPreSetSpawn"] = 2 end
if (not SuperSurvivorOptions["NoIdleChatter"]) then SuperSurvivorOptions["NoIdleChatter"] = 2 end
if (not SuperSurvivorOptions["SafeBase"]) then SuperSurvivorOptions["SafeBase"] = 2 end
if (not SuperSurvivorOptions["SurvivorBases"]) then SuperSurvivorOptions["SurvivorBases"] = 2 end
if (not SuperSurvivorOptions["FindWork"]) then SuperSurvivorOptions["FindWork"] = 2 end
if (not SuperSurvivorOptions["SurvivorHunger"]) then SuperSurvivorOptions["SurvivorHunger"] = 2 end
if (not SuperSurvivorOptions["SurvivorFriendliness"]) then SuperSurvivorOptions["SurvivorFriendliness"] = 3 end

if (not SuperSurvivorOptions["Option_WarningMSG"]) then SuperSurvivorOptions["Option_WarningMSG"] = 2 end

if (not SuperSurvivorOptions["Option_Perception_Bonus"]) then SuperSurvivorOptions["Option_Perception_Bonus"] = 2 end

if (not SuperSurvivorOptions["RaidersAtLeastHours"]) then SuperSurvivorOptions["RaidersAtLeastHours"] = 13 end
if (not SuperSurvivorOptions["RaidersAfterHours"]) then SuperSurvivorOptions["RaidersAfterHours"] = 7 end
if (SuperSurvivorOptions["RaidersAfterHours"] > 22) then SuperSurvivorOptions["RaidersAfterHours"] = 22 end -- fix legacy bad value
if (not SuperSurvivorOptions["RaidersChance"]) then SuperSurvivorOptions["RaidersChance"] = 3 end
if (not SuperSurvivorOptions["Option_FollowDistance"]) then SuperSurvivorOptions["Option_FollowDistance"] = 5 end
if (not SuperSurvivorOptions["Option_ForcePVP"]) then SuperSurvivorOptions["Option_ForcePVP"] = 2 end

if (not SuperSurvivorOptions["Option_Panic_Distance"]) then SuperSurvivorOptions["Option_Panic_Distance"] = 21 end

if (not SuperSurvivorOptions["Option_Display_Survivor_Names"]) then SuperSurvivorOptions["Option_Display_Survivor_Names"] = 2 end
if (not SuperSurvivorOptions["Option_Display_Hostile_Color"]) then SuperSurvivorOptions["Option_Display_Hostile_Color"] = 2 end

if (not SuperSurvivorOptions["Bravery"]) then SuperSurvivorOptions["Bravery"] = 4 end

if (not SuperSurvivorOptions["AltSpawn"]) then SuperSurvivorOptions["AltSpawn"] = 2 end
if (not SuperSurvivorOptions["AltSpawnPercent"]) then SuperSurvivorOptions["AltSpawnPercent"] = 10 end
if (not SuperSurvivorOptions["AltSpawnAmount"]) then SuperSurvivorOptions["AltSpawnAmount"] = 1 end
if (not SuperSurvivorOptions["SSHotkey1"]) then SuperSurvivorOptions["SSHotkey1"] = 6 end
if (not SuperSurvivorOptions["SSHotkey2"]) then SuperSurvivorOptions["SSHotkey2"] = 10 end
if (not SuperSurvivorOptions["SSHotkey3"]) then SuperSurvivorOptions["SSHotkey3"] = 27 end
if (not SuperSurvivorOptions["SSHotkey4"]) then SuperSurvivorOptions["SSHotkey4"] = 42 end

function SuperSurvivorGetOption(option)
	if (SuperSurvivorOptions[option] ~= nil) then
		return tonumber(SuperSurvivorOptions[option])
	else
		return 1
	end
end

function SuperSurvivorGetOptionValue(option)
	local num = SuperSurvivorGetOption(option)

	if (option == "WifeSpawn") then
		return (num ~= 1)
	elseif (option == "LockNLoad") then
		return (num ~= 1)
	elseif (option == "SpawnRate") and (num == 1) then
		return 0
	elseif (option == "SpawnRate") and (num == 2) then
		return 64000
	elseif (option == "SpawnRate") and (num == 3) then
		return 32000
	elseif (option == "SpawnRate") and (num == 4) then
		return 26000
	elseif (option == "SpawnRate") and (num == 5) then
		return 20000
	elseif (option == "SpawnRate") and (num == 6) then
		return 16000
	elseif (option == "SpawnRate") and (num == 7) then
		return 12000
	elseif (option == "SpawnRate") and (num == 8) then
		return 8000
	elseif (option == "SpawnRate") and (num == 9) then
		return 4000
	elseif (option == "SpawnRate") and (num == 10) then
		return 2500
	elseif (option == "SpawnRate") and (num == 11) then
		return 1000
	elseif (option == "SpawnRate") and (num == 12) then
		return 400
	elseif (option == "WepSpawnRate") then
		return (num - 1) -- then return (num * 5) - 5	-- Marked out old instead of removing it to test
	elseif (option == "GunSpawnRate") then
		return (num - 1) -- then return (num * 5) - 5	-- Marked out old instead of removing it to test
	elseif (option == "HostileSpawnRate") then
		return (num - 1) -- then return (num * 5) - 5
	elseif (option == "MaxHostileSpawnRate") then
		return (num - 1) -- then return (num * 5) - 5
	elseif (option == "InfinitAmmo") then
		return (num ~= 1)
	elseif (option == "NoPreSetSpawn") then
		return (num ~= 1)
	elseif (option == "NoIdleChatter") then
		return (num ~= 1)
	elseif (option == "SafeBase") then
		return (num ~= 1)
	elseif (option == "SurvivorBases") then
		return (num ~= 1)
	elseif (option == "DebugOptions") then
		return (num ~= 1)
	elseif (option == "DebugSay") then
		return (num ~= 1)
	elseif (option == "DebugSay_Distance") then
		return (num - 1)
	elseif (option == "FindWork") then
		return (num ~= 1)
	elseif (option == "SurvivorHunger") then
		return (num ~= 1)
	elseif (option == "SurvivorFriendliness") then
		return (10 - ((num - 1) * 2)) -- 1 = 10, 2 = 8, 3 = 6
	elseif (option == "RaidersAtLeastHours") and (num == 21) then
		return 24
	elseif (option == "RaidersAtLeastHours") and (num == 22) then
		return 1
	elseif (option == "RaidersAtLeastHours") and (num == 23) then
		return 0
	elseif (option == "RaidersAtLeastHours") then
		return ((num * 5) * 24)
	elseif (option == "RaidersAfterHours") and (num == 2) then
		return 24
	elseif (option == "RaidersAfterHours") and (num >= 22) then
		return 9999999
	elseif (option == "RaidersAfterHours") then
		return (((num - 2) * 5) * 24)
	elseif (option == "RaidersChance") then
		return ((num + 2) * 24 * 14) -- (6 * 24 * 14)
	elseif (option == "Option_FollowDistance") then
		return (num + 2)
	elseif (option == "Option_Perception_Bonus") then
		return (num)
	elseif (option == "Option_ForcePVP") and (num == 1) then
		return 0
	elseif (option == "Option_ForcePVP") and (num == 2) then
		return 1
	elseif (option == "RoleplayMessage") and (num == 1) then
		return 0
	elseif (option == "RoleplayMessage") and (num == 2) then
		return 1
	elseif (option == "Option_Display_Survivor_Names") then
		return (num ~= 1)
	elseif (option == "Option_Display_Hostile_Color") then
		return (num ~= 1)
	elseif (option == "Bravery") and (num == 1) then
		return 2
	elseif (option == "Bravery") and (num == 2) then
		return 4
	elseif (option == "Bravery") and (num == 3) then
		return 6
	elseif (option == "Bravery") and (num == 4) then
		return 8
	elseif (option == "Bravery") and (num == 5) then
		return 10
	elseif (option == "Bravery") and (num == 6) then
		return 20
	elseif (option == "AltSpawn") and (num == 1) then
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

-- -- -- -- --
-- WIP - getContextMenuText() is a globl function... should consider updating the casing to reflect that.
function getContextMenuText(text)
	return getText("ContextMenu_SS_" .. text)
end

SSHotKeyOptions = {}

for i = 1, #Orders do
	SSHotKeyOptions[i] = getContextMenuText("OrderAll") .. " " .. OrderDisplayName[Orders[i]];
	table.insert(SSHotKeyOptions, OrderDisplayName[Orders[i]]);
end

-- ----------------------- --
-- Options Menu controller --
-- ----------------------- --
function SuperSurvivorsRefreshSettings()
	Option_WarningMSG = SuperSurvivorGetOptionValue("Option_WarningMSG")

	Option_Perception_Bonus = SuperSurvivorGetOptionValue("Option_Perception_Bonus")

	Option_Display_Survivor_Names = SuperSurvivorGetOptionValue("Option_Display_Survivor_Names")
	Option_Display_Hostile_Color = SuperSurvivorGetOptionValue("Option_Display_Hostile_Color")

	Option_Panic_Distance = SuperSurvivorGetOptionValue("Option_Panic_Distance")

	Option_ForcePVP = SuperSurvivorGetOptionValue("Option_ForcePVP")
	Option_FollowDistance = SuperSurvivorGetOptionValue("Option_FollowDistance")
	SuperSurvivorBravery = SuperSurvivorGetOptionValue("Bravery")
	RoleplayMessage = SuperSurvivorGetOptionValue('RoleplayMessage')

	AlternativeSpawning = SuperSurvivorGetOptionValue("AltSpawn")
	AltSpawnGroupSize = SuperSurvivorGetOptionValue("AltSpawnAmount")
	AltSpawnPercent = SuperSurvivorGetOptionValue("AltSpawnPercent")
	NoPreSetSpawn = SuperSurvivorGetOptionValue("NoPreSetSpawn")
	NoIdleChatter = SuperSurvivorGetOptionValue("NoIdleChatter")

	DebugOptions = SuperSurvivorGetOptionValue("DebugOptions")
	DebugOption_DebugSay = SuperSurvivorGetOptionValue("DebugSay")
	DebugOption_DebugSay_Distance = SuperSurvivorGetOptionValue("DebugSay_Distance")

	SafeBase = SuperSurvivorGetOptionValue("SafeBase")
	SurvivorBases = SuperSurvivorGetOptionValue("SurvivorBases")
	SuperSurvivorSpawnRate = SuperSurvivorGetOptionValue("SpawnRate")
	ChanceToSpawnWithGun = SuperSurvivorGetOptionValue("GunSpawnRate")
	ChanceToSpawnWithWep = SuperSurvivorGetOptionValue("WepSpawnRate")
	ChanceToBeHostileNPC = SuperSurvivorGetOptionValue("HostileSpawnRate")
	MaxChanceToBeHostileNPC = SuperSurvivorGetOptionValue("MaxHostileSpawnRate") -- Fixed, it used to contain 'HostileSpawnRate', previously making MaxHostileSpawnRate a useless option

	SurvivorInfiniteAmmo = SuperSurvivorGetOptionValue("InfinitAmmo")
	SurvivorHunger = SuperSurvivorGetOptionValue("SurvivorHunger")
	SurvivorsFindWorkThemselves = SuperSurvivorGetOptionValue("FindWork")


	RaidsAtLeastEveryThisManyHours = SuperSurvivorGetOptionValue("RaidersAtLeastHours") --(60 * 24)
	RaidsStartAfterThisManyHours = SuperSurvivorGetOptionValue("RaidersAfterHours")  -- (5 * 24)

	RaidChanceForEveryTenMinutes = SuperSurvivorGetOptionValue("RaidersChance")      --(6 * 24 * 14)
end

SuperSurvivorsRefreshSettings()
