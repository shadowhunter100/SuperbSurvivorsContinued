-- this file has methods related to npc combat
local isLocalLoggingEnabled = false;

--- Gets a ammo box of an ammo typ
---@param bullets string any ammo type
---@return string returns the ammo box name
function GetAmmoBox(bullets)
	CreateLogLine("SuperSuvivorsCombatUtilities", isLocalLoggingEnabled, "GetAmmoBox() called");
	if (bullets == "BB177") then
		return "BB177Box"
	elseif (bullets == "Bullets22") then
		return "Bullets22Box"
	elseif (bullets == "Bullets57") then
		return "Bullets57Box"
	elseif (bullets == "Bullets380") then
		return "Bullets380Box"
	elseif (bullets == "Bullets9mm") then
		return "Bullets9mmBox"
	elseif (bullets == "Bullets38") then
		return "Bullets38Box"
	elseif (bullets == "Bullets357") then
		return "Bullets357Box"
	elseif (bullets == "Bullets45") then
		return "Bullets45Box"
	elseif (bullets == "Bullets45LC") then
		return "Bullets45LCBox"
	elseif (bullets == "Bullets44") then
		return "Bullets44Box"
	elseif (bullets == "Bullets4570") then
		return "Bullets4570Box"
	elseif (bullets == "410gShotgunShells") then
		return "410gShotgunShellsBox"
	elseif (bullets == "20gShotgunShells") then
		return "20gShotgunShellsBox"
	elseif (bullets == "ShotgunShells") then
		return "ShotgunShellsBox"
	elseif (bullets == "10gShotgunShells") then
		return "10gShotgunShellsBox"
	elseif (bullets == "4gShotgunShells") then
		return "4gShotgunShellsBox"
	elseif (bullets == "223Bullets") then
		return "223Box"
	elseif (bullets == "556Bullets") then
		return "556Box"
	elseif (bullets == "762x39Bullets") then
		return "762x39Box"
	elseif (bullets == "308Bullets") then
		return "308Box"
	elseif (bullets == "762x51Bullets") then
		return "762x51Box"
	elseif (bullets == "762x54rBullets") then
		return "762x54rBox"
	elseif (bullets == "3006Bullets") then
		return "3006Box"
	elseif (bullets == "50BMGBullets") then
		return "50BMGBox"
	elseif (bullets == "Nails") then
		return "NailsBox" -- For Nailgun Mod
	end

	return ""
end

--- func desc
---@param box string ammo box name
---@return integer returns the amount of bullets inside of the ammo box
function GetBoxCount(box)
	CreateLogLine("SuperSuvivorsCombatUtilities", isLocalLoggingEnabled, "GetBoxCount() called");
	if (box == "BB177Box") then
		return 500
	elseif (box == "Bullets22Box") then
		return 100
	elseif (box == "Bullets57Box") then
		return 50
	elseif (box == "Bullets380Box") then
		return 50
	elseif (box == "Bullets9mmBox") then
		return 50
	elseif (box == "Bullets38Box") then
		return 50
	elseif (box == "Bullets357Box") then
		return 50
	elseif (box == "Bullets45Box") then
		return 50
	elseif (box == "Bullets45LCBox") then
		return 50
	elseif (box == "Bullets44Box") then
		return 50
	elseif (box == "Bullets4570Box") then
		return 20
	elseif (box == "410gShotgunShellsBox") then
		return 25
	elseif (box == "20gShotgunShellsBox") then
		return 25
	elseif (box == "ShotgunShellsBox") then
		return 25
	elseif (box == "10gShotgunShellsBox") then
		return 25
	elseif (box == "4gShotgunShellsBox") then
		return 10
	elseif (box == "223Box") then
		return 20
	elseif (box == "556Box") then
		return 20
	elseif (box == "762x39Box") then
		return 20
	elseif (box == "308Box") then
		return 20
	elseif (box == "762x51Box") then
		return 20
	elseif (box == "762x54rBox") then
		return 20
	elseif (box == "3006Box") then
		return 20
	elseif (box == "50BMGBox") then
		return 10
	elseif (box == "NailsBox") then
		return 100 -- For Nailgun Mod
	else
		return 0
	end
end

function SurvivorTogglePVP()
	CreateLogLine("SuperSuvivorsCombatUtilities", isLocalLoggingEnabled, "SurvivorTogglePVP() called");
	if (IsoPlayer.getCoopPVP() == true) then
		getSpecificPlayer(0):Say("PVP Disabled");
		IsoPlayer.setCoopPVP(false);
		getSpecificPlayer(0):getModData().PVP = false;
		PVPDefault = false;
		PVPButton:setImage(PVPTextureOff)
	elseif (IsoPlayer.getCoopPVP() == false) then
		IsoPlayer.setCoopPVP(true);
		if (ForcePVPOn ~= true) then
			getSpecificPlayer(0):getModData().PVP = true;
			PVPDefault = true;
			getSpecificPlayer(0):Say("PVP Enabled");
		else
			getSpecificPlayer(0):Say("PVP Forced On");
		end
		ForcePVPOn = false;
		PVPButton:setImage(PVPTextureOn)
	end
end

---	gets in the database the ammo type for the weapon 'weapon'
---@param weapon any weapon to have the ammo searched
---@return any returns the ammo type of the gun or nil if not found
local function getAmmoType(weapon)
	CreateLogLine("SuperSuvivorsCombatUtilities", isLocalLoggingEnabled, "getAmmoType() called");
	if (weapon == nil) or (weapon:getAmmoType() == nil) then
		return nil
	end

	local wepType = weapon:getType();
	local out = weapon:getAmmoType()

	-- search for a magazine
	if (out == nil) then
		local s = weapon:getMagazineType();
		local i = string.find(s, "Clip")
		out = s:sub(i)
	end

	if (out == nil) then
		CreateLogLine("SuperSuvivorsCombatUtilities", isLocalLoggingEnabled, "no ammo found");
		return nil
	end

	out = out:sub(6);

	return out;
end

--- gets in the database bullets for the weapon 'weapon'
---@param weapon any a HandWeapon
function GetAmmoBullets(weapon)
	CreateLogLine("SuperSuvivorsCombatUtilities", isLocalLoggingEnabled, "GetAmmoBullets() called");
	if (weapon == nil) then
		return nil
	end

	if (instanceof(weapon, "HandWeapon")) and (weapon:isAimedFirearm()) then
		local bullets = {}

		table.insert(bullets, getAmmoType(weapon))

		return bullets;
	end

	return nil
end
