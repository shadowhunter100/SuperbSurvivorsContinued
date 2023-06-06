require "00_SuperbSurviorModVariables/SuperSurvivorsSuitsList"
-- this file has the functions for survivor's suits

local isLocalLoggingEnabled = false;

--- Gets a random outfit for a survivor
---@param SS any survivor that will wear the outfit
function GetRandomSurvivorSuit(SS)
	CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "GetRandomSurvivorSuit() called");

	local roll = ZombRand(0, 101)
	local tempTable = nil
	CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "rolled: " .. tostring(roll));

	if (roll == 1) then -- choose legendary suit
		CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Got: " .. "Legendary suit");
		tempTable = SurvivorRandomSuits["Legendary"]
	elseif (roll <= 5) then -- choose veryrare suit
		CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Got: " .. "VeryRare suit");
		tempTable = SurvivorRandomSuits["VeryRare"]
	elseif (roll <= 15) then -- choose rare suit
		CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Got: " .. "Rare suit");
		tempTable = SurvivorRandomSuits["Rare"]
	elseif (roll <= 25) then -- chose normal suit
		CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Got: " .. "Normal suit");
		tempTable = SurvivorRandomSuits["Normal"]
	elseif (roll <= 40) then -- chose uncommon suit
		CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Got: " .. "Uncommon suit");
		tempTable = SurvivorRandomSuits["Uncommon"]
	else -- chose common suit
		CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Got: " .. "Common suit");
		tempTable = SurvivorRandomSuits["Common"]
	end

	local result = table.randFrom(tempTable)
	CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "result: " .. tostring(result));

	while (string.sub(result, -1) == "F"
			and not SS.player:isFemale())
		or (string.sub(result, -1) == "M"
			and SS.player:isFemale()) do
		result = table.randFrom(tempTable)
	end

	CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "Random suit result: " .. tostring(result));

	local suitTable = tempTable[result];
	-- WIP - Cows: Why even iterate? I thought the suit was mapped?...
	for i = 1, #suitTable do
		if (suitTable[i] ~= nil) then
			SS:WearThis(suitTable[i])
		end
	end

	CreateLogLine("SuperSurvivorSuitsUtilities", isLocalLoggingEnabled, "--- GetRandomSurvivorSuit() end ---");
end

---@alias rarity
---| "Common"
---| "Uncommon"
---| "Normal"
---| "Rare"
---| "VeryRare"
---| "Legendary"
---| "Preset"

--- sets an outfit for a survivor given if table and outfit found
---@param SS any
---@param tbl rarity table name to be searched
---@param name string outfit name
function SetRandomSurvivorSuit(SS, tbl, name)
	local suitTable = SurvivorRandomSuits[tbl][name]
	if suitTable then
		-- WIP - Cows: Why even iterate? I thought the suit was mapped?...
		for i = 1, #suitTable do
			if (suitTable[i] ~= nil) then
				SS:WearThis(suitTable[i])
			end
		end
	end
end
