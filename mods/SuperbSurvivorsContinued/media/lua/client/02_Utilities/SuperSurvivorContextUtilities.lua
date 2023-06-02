-- this file has methods related to world context
--- SQUARES ---

local isLocalLoggingEnabled = false;

---@alias direction
---| '"N"' # North
---| '"S"' # South
---| '"E"' # East
---| '"W"' # West

---Get an adjacent square based on a direction
---@param square any
---@param dir direction
---@return any the adjacent square
function GetAdjSquare(square, dir)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetAdjSquare() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"square: " .. tostring(square) ..
		" | dir: " .. tostring(dir));

	if (dir == 'N') then
		return getCell():getGridSquare(square:getX(), square:getY() - 1, square:getZ());
	elseif (dir == 'E') then
		return getCell():getGridSquare(square:getX() + 1, square:getY(), square:getZ());
	elseif (dir == 'S') then
		return getCell():getGridSquare(square:getX(), square:getY() + 1, square:getZ());
	else
		return getCell():getGridSquare(square:getX() - 1, square:getY(), square:getZ());
	end
end

function GetOutsideSquare(square, building)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetOutsideSquare() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"square: " .. tostring(square) ..
		" | building: " .. tostring(building));
	if (not building) or (not square) then
		return nil
	end

	local windowsquare = getCell():getGridSquare(square:getX(), square:getY(), square:getZ());
	if windowsquare ~= nil and windowsquare:isOutside() then
		return windowsquare
	end

	local N = GetAdjSquare(square, "N")
	local E = GetAdjSquare(square, "E")
	local S = GetAdjSquare(square, "S")
	local W = GetAdjSquare(square, "W")

	if N and N:isOutside() then
		return N
	elseif E and E:isOutside() then
		return E
	elseif S and S:isOutside() then
		return S
	elseif W and W:isOutside() then
		return W
	else
		return square
	end
end

---@param fleeGuy any
---@param attackGuy any
---@param distanceToFlee number distance that the flee guy will search for
---@return any returns a random square in a distance away from attackGuy
function GetFleeSquare(fleeGuy, attackGuy, distanceToFlee)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetFleeSquare() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		" | fleeGuy: " .. tostring(fleeGuy) ..
		" | attackGuy: " .. tostring(attackGuy) ..
		" | distanceToFlee: " .. tostring(distanceToFlee));
	local distance = 7;
	local tempx = (fleeGuy:getX() - attackGuy:getX());
	local tempy = (fleeGuy:getY() - attackGuy:getY());

	if (distanceToFlee) then
		distance = distanceToFlee;
	end

	if (tempx < 0) then
		tempx = -distance;
	else
		tempx = distance;
	end
	if (tempy < 0) then
		tempy = -distance
	else
		tempy = distance
	end

	local fleex = fleeGuy:getX() + tempx + ZombRand(-5, 5)
	local fleey = fleeGuy:getY() + tempy + ZombRand(-5, 5)

	return fleeGuy:getCell():getGridSquare(fleex, fleey, fleeGuy:getZ());
end

--- gets a square torwards a direction in a fixed distance (15)
---@param moveguy any
---@param x number
---@param y number
---@param z number
function GetTowardsSquare(moveguy, x, y, z)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetTowardsSquare() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"moveGuy: " .. tostring(moveguy) ..
		" | x: " .. tostring(x) ..
		" | y: " .. tostring(y) ..
		" | z: " .. tostring(z)
	);
	local distance = 15
	local tempx = (moveguy:getX() - x);
	local tempy = (moveguy:getY() - y);

	if (tempx > 0) and (tempx >= distance) then
		tempx = -distance;
	elseif (tempx < -distance) then
		tempx = distance
	else
		tempx = -tempx
	end

	if (tempy > 0) and (tempy >= distance) then
		tempy = -distance
	elseif (tempy < -distance) then
		tempy = distance;
	else
		tempy = -tempy
	end

	local movex = moveguy:getX() + tempx + ZombRand(-2, 2)
	local movey = moveguy:getY() + tempy + ZombRand(-2, 2)

	return moveguy:getCell():getGridSquare(movex, movey, moveguy:getZ());
end

--- END SQUARES ---

--- COORDINATES ---
--- gets the coordinate from a npc survivor
---@param id any if of the npc survivor
---@return any
function GetCoordsFromID(id)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetCoordsFromID() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "id: " .. tostring(id));

	for k, v in pairs(SurvivorMap) do
		for i = 1, #v do
			if (v[i] == id) then
				CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "SurvivorMap: " ..
					"id: " .. tostring(id) ..
					" | value: " .. tostring(v) ..
					" | index: " .. tostring(i)
				);
				return k;
			end
		end
	end

	return 0
end

-- WIP - Cows: this function is literally spammed between all active instances, slowing down the game performance drastically.
-- WIP - Cows: in about 30 seconds, this function was called over 11,000 times.
--- gets the distance between 2 things (objects, zombies, npcs or players)
---@param z1 any instance one
---@param z2 any instance two
---@return number the distance between the 2 instances
function GetDistanceBetween(z1, z2)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetDistanceBetween() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"z1: " .. tostring(z1) ..
		" | z2: " .. tostring(z2)
	);
	if (z1 == nil) or (z2 == nil) then
		return 1;
	end

	local z1x = z1:getX()
	local z1y = z1:getY()
	local z1z = z1:getZ()

	local z2x = z2:getX()
	local z2y = z2:getY()
	local z2z = z2:getZ()

	local dx = z1x - z2x
	local dy = z1y - z2y
	local dz = z1z - z2z

	local distance = math.sqrt(dx * dx + dy * dy + (dz * dz * 2));
	--
	if (distance ~= nil) then
		return distance;
	end

	return 1;
end

--- gets the distance between 2 coordinates
---@param Ax number
---@param Ay number
---@param Bx number
---@param By number
---@return number the distance between the 2 points
function GetDistanceBetweenPoints(Ax, Ay, Bx, By)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetDistanceBetweenPoints() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"Ax: " .. tostring(Ax) ..
		"| Ay: " .. tostring(Ay) ..
		"| Bx: " .. tostring(Bx) ..
		"| By: " .. tostring(By)
	);
	if (Ax == nil) or (Bx == nil) then
		return -1
	end

	local dx = Ax - Bx
	local dy = Ay - By

	return math.sqrt(dx * dx + dy * dy)
end

--- END COORDINATES ---

--- AREAS ----

--- checks if the square is inside of the area 'area'
---@param sq any
---@param area table a table with 4 positions representing a square of points(number)
function IsSquareInArea(sq, area)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: IsSquareInArea() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"sq: " .. tostring(sq) ..
		" | area: " .. tostring(area)
	);
	local x1 = area[1]
	local x2 = area[2]
	local y1 = area[3]
	local y2 = area[4]

	if (sq:getX() > x1) and (sq:getX() <= x2) and (sq:getY() > y1) and (sq:getY() <= y2) and (sq:getZ() == area[5]) then
		return true
	else
		return false
	end
end

--- gets the center square of an area
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@param z  number
---@return any the center square given the coordinates
function GetCenterSquareFromArea(x1, x2, y1, y2, z)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetCenterSquareFromArea() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"x1: " .. tostring(x1) ..
		" | x2: " .. tostring(x2) ..
		" | y1: " .. tostring(y1) ..
		" | y2: " .. tostring(y2) ..
		" | z: " .. tostring(z)
	);
	local xdiff = x2 - x1
	local ydiff = y2 - y1

	local result = getCell():getGridSquare(x1 + math.floor(xdiff / 2), y1 + math.floor(ydiff / 2), z)

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"--- function: GetCenterSquareFromArea() End ---");
	return result
end

--- gets a random square inside of an area
---@param area any
function GetRandomAreaSquare(area)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetRandomAreaSquare() called");
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"area: " .. tostring(area)
	);
	local x1 = area[1]
	local x2 = area[2]
	local y1 = area[3]
	local y2 = area[4]
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"x1: " .. tostring(x1) ..
		" | x2: " .. tostring(x2) ..
		" | y1: " .. tostring(y1) ..
		" | y2: " .. tostring(y2)
	);
	if (x1 ~= nil) then
		local xrand = ZombRand(x1, x2)
		local yrand = ZombRand(y1, y2)
		local result = getCell():getGridSquare(xrand, yrand, area[5])

		return result
	end
end

--- END AREAS ----

--- OBJECTS ---

--- WINDOWS ----

--- gets a window square
---@param cs any a square
---@return any the window object if found or nil
local function getSquaresWindow(cs)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: getSquaresWindow() called");
	if not cs then
		return nil
	end

	local objs = cs:getObjects()
	for i = 1, objs:size() do
		local obj = objs:get(i)
		if (instanceof(obj, "IsoWindow")) then
			return obj
		end
	end


	return nil
end

-- WIP - Cows: GetSquaresNearWindow() is the second most frequently called function after GetDistanceBetween().
--- gets the nearest adjacent window square of 'cs'
---@param cs any a square
---@return any the adjacent square next to window if found or nil
function GetSquaresNearWindow(cs)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetSquaresNearWindow() called");
	local directions = { "N", "E", "S", "W" }

	for k, dir in ipairs(directions) do
		local square = GetAdjSquare(cs, dir)
		local res = getSquaresWindow(square)

		if cs and square and res then
			return res
		end
	end

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "--- function: GetSquaresNearWindow() END ---");
	return nil
end

--- END WINDOWS ----

--- DOORS ----

--- gets the inside square of a door
---@param door any
---@param player any
---@return any returns the inside square of a door or nil if not found
function GetDoorsInsideSquare(door, player)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetDoorsInsideSquare() called");
	if (player == nil) or not (instanceof(door, "IsoDoor")) then
		return nil
	end

	local sq1 = door:getOppositeSquare()
	local sq2 = door:getSquare()
	local sq3 = door:getOtherSideOfDoor(player)

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "--- function: GetDoorsInsideSquare() END ---");
	if (not sq1:isOutside()) then
		return sq1
	elseif (not sq2:isOutside()) then
		return sq2
	elseif (not sq3:isOutside()) then
		return sq3
	else
		return nil
	end
end

--- gets the outside square of a door
---@param door any
---@param player any
---@return any returns the inside outside of a door or nil if not found
function GetDoorsOutsideSquare(door, player)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetDoorsOutsideSquare() called");
	if (player == nil) or not (instanceof(door, "IsoDoor")) then
		return nil
	end

	local sq1 = door:getOppositeSquare()
	local sq2 = door:getSquare()
	local sq3 = door:getOtherSideOfDoor(player)

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "--- function: GetDoorsOutsideSquare() END ---");
	if (sq1 and sq1:isOutside()) then
		return sq1
	elseif (sq2 and sq2:isOutside()) then
		return sq2
	elseif (sq3 and sq3:isOutside()) then
		return sq3
	else
		return nil
	end
end

-- WIP - Cows: NEED TO REWORK THE NESTED LOOP CALLS
--- gets the closest unlocked door
---@param building any
---@param character any
---@return any returns the closest exterior unlocked door or nil if not found
function GetUnlockedDoor(building, character)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetUnlockedDoor() called");
	local DoorOut = nil
	local closestSoFar = 100
	local bdef = building:getDef()

	for x = bdef:getX() - 1, (bdef:getX() + bdef:getW() + 1) do
		for y = bdef:getY() - 1, (bdef:getY() + bdef:getH() + 1) do
			local sq = getCell():getGridSquare(x, y, character:getZ())

			if (sq) then
				local Objs = sq:getObjects();
				local distance = GetDistanceBetween(sq, character) -- WIP - literally spammed inside the nested for loops...
				CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
					"Objects size: " .. tostring(Objs:size() - 1));

				for j = 0, Objs:size() - 1 do
					local Object = Objs:get(j)

					if (Object ~= nil) then
						if (instanceof(Object, "IsoDoor"))
							and (Object:isExteriorDoor(character))
							and (distance < closestSoFar) then
							if (not Object:isLocked()) then
								closestSoFar = distance;
								DoorOut = Object;
							end
						end
					end
				end
			end
		end
	end

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "--- function: GetUnlockedDoor() END ---");
	return DoorOut
end

--- END DOORS ----

--- BUILDINGS ---

--- gets the amount of zombies inside and around a building
---@param building any
---@return integer returns the amount of zombies found in the building
function NumberOfZombiesInOrAroundBuilding(building)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"function: NumberOfZombiesInOrAroundBuilding() called");
	local count = 0
	local padding = 10
	local bdef = building:getDef()

	local bdefX = bdef:getX()
	local bdefY = bdef:getY()

	local bdWidth = bdefX + bdef:getW() + padding
	local bdHeight = bdefY + bdef:getH() + padding

	for x = (bdefX - padding), bdWidth do
		for y = (bdefY - padding), bdHeight do
			local sq = getCell():getGridSquare(x, y, 0)
			if (sq) then
				local Objs = sq:getMovingObjects();
				for j = 0, Objs:size() - 1 do
					local Object = Objs:get(j)
					if (Object ~= nil) and (instanceof(Object, "IsoZombie")) then
						count = count + 1
					end
				end
			end
		end
	end

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"--- function: NumberOfZombiesInOrAroundBuilding() END ---");
	return count
end

--- gets a random square inside of a building
---@param building any
---@return any returns a random square inside of the building
function GetRandomBuildingSquare(building)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled, "function: GetRandomBuildingSquare() called");
	local bdef = building:getDef()
	local x = ZombRand(bdef:getX(), (bdef:getX() + bdef:getW()))
	local y = ZombRand(bdef:getY(), (bdef:getY() + bdef:getH()))

	local sq = getCell():getGridSquare(x, y, 0)
	if (sq) then
		return sq
	end

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"--- function: GetRandomBuildingSquare() END ---");
	return nil
end

--- gets a random and free square inside of a building (it tries 100 of times until it finds so be careful using it)
--- WIP - Cows: There must be a better way to handle it rather than try-spamming multiple times...
---@param building any
---@return any returns a random square inside of the building
function GetRandomFreeBuildingSquare(building)
	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"function: GetRandomFreeBuildingSquare() called");
	if (building == nil) then
		return nil
	end

	local bdef = building:getDef()

	for i = 0, 100 do
		local x = ZombRand(bdef:getX(), (bdef:getX() + bdef:getW()))
		local y = ZombRand(bdef:getY(), (bdef:getY() + bdef:getH()))

		local sq = getCell():getGridSquare(x, y, 0)
		if (sq) and sq:isFree(false) and (sq:getRoom() ~= nil) and (sq:getRoom():getBuilding() == building) then
			return sq
		end
	end

	CreateLogLine("SuperSurvivorContextUtilities", isLocalLoggingEnabled,
		"--- function: GetRandomFreeBuildingSquare() END ---");
	return nil
end

--- END BUILDINGS ---
