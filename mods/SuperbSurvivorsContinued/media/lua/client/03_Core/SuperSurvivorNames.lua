---  Below is hundreds of girl names and boy names. you dont need to translate them if you don't want to. translate as in, replace them with common names in area of language or change to your phonetic alphabeht. if you do. know that there does not need to be this many. you could just do like 50 of each.

local function getGirlNames()
  local girlNamesCount = 500

  local names = {}
  for i = 1, girlNamesCount, 1 do
    names[i] = Get_SS_Name("Names" .. tostring(i))
  end

  return names
end

local function getBoyNames()
  local boyNamesCount = 160

  local names = {}
  for i = 1, boyNamesCount, 1 do
    names[i] = Get_SS_Name("Namb" .. tostring(i))
  end

  return names
end

---@alias	gender
---| "GirlNames"
---| "BoyNames"

SurvivorNameTable = {};
SurvivorNameTable["GirlNames"] = getGirlNames();
SurvivorNameTable["BoyNames"] = getBoyNames();

--- gets a random survivor name based on gender
---@param key gender key of the name
---@return string a random survivor name
function GetRandomName(key)
  if (not SurvivorNameTable[key]) then
    return "?"
  end

  local result = ZombRand(1, #SurvivorNameTable[key]);
  return tostring(SurvivorNameTable[key][result]);
end
