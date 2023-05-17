local isLocalLoggingEnabled = false;

SurvivorPerks = {
	"Aiming",
	"Axe",
	"Combat",
	"SmallBlade",
	"LongBlade",
	"SmallBlunt",
	"Blunt",
	"Maintenance",
	"Spear",
	"Doctor",
	"Farming",
	"Firearm",
	"Reloading",
	"Fitness",
	"Lightfoot",
	"Nimble",
	"PlantScavenging",
	"Reloading",
	"Sneak",
	"Strength",
	"Survivalist"
}

--- gets the size of a table
---@param a table
---@return integer returns the size of the table
function GetTableSize(a)
	local i = 1
	while a[i] do
		i = i + 1
	end
	return i;
end

--- Gets a random perk
---@return string a random perk name
function GetAPerk()
	local result = ZombRand(GetTableSize(SurvivorPerks) - 1) + 1;
	return SurvivorPerks[result];
end

--- checks if the table contains a value
---@param tab table table to be searched
---@param val any value to be searched
---@return boolean returns true if the value exists in the table
function CheckIfTableHasValue(tab, val)
	if (tab ~= nil) and (val ~= nil) then
		for k = 1, #tab do
			local value = tab[k]
			if value == val then
				return true
			end
		end
	end

	return false
end

function AbsoluteValue(value)
	if (value >= 0) then
		return value;
	else
		return (value * -1);
	end
end

function MakeToolTip(option, name, desc)
	local toolTip = ISToolTip:new();
	toolTip:initialise();
	toolTip:setVisible(false);
	-- add it to our current option
	option.toolTip = toolTip;
	toolTip:setName(name);
	toolTip.description = desc .. " <LINE> ";
	--toolTip:setTexture("crafted_01_16");

	--toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> More Desc" ;
	--option.notAvailable = true;
	return toolTip;
end

--- gets the square where the mouse is empty
---@return any returns the a square
function GetMouseSquare()
	local sw = (128 / getCore():getZoom(0));
	local sh = (64 / getCore():getZoom(0));

	local mapx = getSpecificPlayer(0):getX();
	local mapy = getSpecificPlayer(0):getY();
	local mousex = ((getMouseX() - (getCore():getScreenWidth() / 2)));
	local mousey = ((getMouseY() - (getCore():getScreenHeight() / 2)));

	local sx = mapx + (mousex / (sw / 2) + mousey / (sh / 2)) / 2;
	local sy = mapy + (mousey / (sh / 2) - (mousex / (sw / 2))) / 2;

	local sq = getCell():getGridSquare(sx, sy, getSpecificPlayer(0):getZ());
	return sq;
end

--- gets the world Y position of the mouse
---@return number returns the Y position
function GetMouseSquareY()
	local sw = (128 / getCore():getZoom(0));
	local sh = (64 / getCore():getZoom(0));

	local mapx = getSpecificPlayer(0):getX();
	local mapy = getSpecificPlayer(0):getY();
	local mousex = ((getMouseX() - (getCore():getScreenWidth() / 2)));
	local mousey = ((getMouseY() - (getCore():getScreenHeight() / 2)));

	local sy = mapy + (mousey / (sh / 2) - (mousex / (sw / 2))) / 2;

	return sy
end

--- gets the world X position of the mouse
---@return number returns the X position
function GetMouseSquareX()
	local sw = (128 / getCore():getZoom(0));
	local sh = (64 / getCore():getZoom(0));

	local mapx = getSpecificPlayer(0):getX();
	local mapy = getSpecificPlayer(0):getY();
	local mousex = ((getMouseX() - (getCore():getScreenWidth() / 2)));
	local mousey = ((getMouseY() - (getCore():getScreenHeight() / 2)));

	local sx = mapx + (mousex / (sw / 2) + mousey / (sh / 2)) / 2;

	return sx
end

function IsItemArray(t)
	if (not t) then return false end
	if (t[0] or t[1]) then
		return true
	else
		return false
	end
end

---comment
---@param mapKey any
---@return string
function SetSurvivorDress(mapKey)
	CreateLogLine("SuperSurvivor", isLocalLoggingEnabled, "SetSurvivorDress() called");
	local dress = "RandomBasic"
	local dressTable = {
		[1] = "Preset_MarinesCamo",
		[2] = "Preset_ArmyCamo",
		[3] = "Preset_Army",
		[4] = "Preset_Guard"
	}

	if (dressTable[mapKey]) then
		dress = dressTable[mapKey];
	end

	return dress;
end

---comment
---@param mapKey any
---@return string
function SetSurvivorWeapon(mapKey)
	CreateLogLine("SuperSurvivor", isLocalLoggingEnabled, "SetSurvivorWeapon() called");
	local weapon = "Base.Pistol3";
	local weaponTableDefault = {
		[1] = "Base.AssaultRifle",
		[2] = "Base.AssaultRifle",
		[3] = "Base.AssaultRifle"
	};

	if (weaponTableDefault[mapKey]) then
		weapon = weaponTableDefault[mapKey];
	end

	return weapon;
end