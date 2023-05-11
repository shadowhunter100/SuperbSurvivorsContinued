-- this file only has methods related to deal with saving and loading Superb Survivors data.

local isLocalLoggingEnabled = false;

--- gets the full path of a .lua of a save file
---@param fileName string any Name
---@return string
local function getFileFullPath(fileName)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "getFileFullPath() called");
	return getWorld():getWorld() .. getFileSeparator() .. fileName
end

--- Checks if a file of a savegame exists
---@param fileName string file to be searched
---@return boolean returns true if the current file exists
function DoesFileExist(fileName)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "DoesFileExist() called");
	local readFile = getModFileReader(ModId, getFileFullPath(fileName), false)

	if (readFile) then
		return true;
	else
		return false;
	end
end

--- gets a random item from a table
---@param t table a table
---@return any an random item of t table
function table.randFrom(t)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "table.randFrom() called");
	local keys = {}

	for key, value in pairs(t) do
		keys[#keys + 1] = key --Store keys in another table
	end

	local key = ZombRand(1, #keys)
	return keys[key]
end

--- loads a table from a .lua file
---@param fileName string the filename that the table will be loaded
---@return table a table with all data from filename or nil if not found
function table.load(fileName)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "table.load() called");
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "Loading file: " .. tostring(fileName));

	local fileTable = {}
	local readFile = getModFileReader(ModId, getFileFullPath(fileName .. ".lua"), true)

	if (readFile) then
		local scanLine = readFile:readLine()

		while scanLine do

			fileTable[#fileTable + 1] = scanLine
			scanLine = readFile:readLine()

			if not scanLine then
				break
			end
		end

		readFile:close()
	end

	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "--- table.load() end --- ");
	return fileTable
end

--- saves a table into a .lua file
---@param tbl table a table with data
---@param fileName string the name of the file to be created
function table.save(tbl, fileName)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "table.save() called");
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "Saving file: " .. tostring(fileName));
	local thepath = getFileFullPath(fileName .. ".lua")
	local writeFile = getModFileWriter(ModId, thepath, true, false)

	for i = 1, #tbl do
		writeFile:write(tbl[i] .. "\r\n");
	end

	writeFile:close();

	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "--- table.save() END ---");
end

--- loads a table from a file
---@param fileName string the filename that the table will be loaded
---@return table a table with all data from filename or nil if not found
function KVTableLoad(fileName)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "KVTableLoad() called");
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "loading file: " .. tostring(fileName));

	local fileTable = {}
	local readFile = getModFileReader(ModId, getFileFullPath(fileName), true)

	if (not readFile) then
		return {}
	end

	local scanLine = readFile:readLine()
	while scanLine do
		local values = {}

		for input in scanLine:gmatch("%S+") do
			table.insert(values, input)
		end

		fileTable[values[1]] = values[2]

		scanLine = readFile:readLine()

		if not scanLine then
			break;
		end
	end
	readFile:close();

	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "--- KVTableLoad() end ---");
	return fileTable
end

--- saves a table into a file
---@param fileTable table a table with data
---@param fileName string the name of the file to be created
function KVTablesave(fileTable, fileName)
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "KVTablesave() called");
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "saving file: " .. tostring(fileName));

	if (not fileTable) then
		CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "fileTable is empty");
		return false
	end

	local writeFile = getModFileWriter(ModId, getFileFullPath(fileName), true, false);

	for index, value in pairs(fileTable) do
		writeFile:write(tostring(index) .. " " .. tostring(value) .. "\r\n");
	end

	writeFile:close();

	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "--- KVTablesave() end ---");
end

function GetModSaveDir()
	CreateLogLine("SuperSurvivorTablesUtilities", isLocalLoggingEnabled, "GetModSaveDir() called");
	return Core.getMyDocumentFolder() ..
		getFileSeparator() ..
		"Saves" ..
		getFileSeparator() ..
		getWorld():getGameMode() .. getFileSeparator() .. getWorld():getWorld() .. getFileSeparator();
end
