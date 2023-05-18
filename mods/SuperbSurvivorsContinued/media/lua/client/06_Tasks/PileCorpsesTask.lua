PileCorpsesTask = {}
PileCorpsesTask.__index = PileCorpsesTask

local isLocalLoggingEnabled = false;

function PileCorpsesTask:new(superSurvivor, BringHere)
	CreateLogLine("PileCorpsesTask", isLocalLoggingEnabled, "function: PileCorpsesTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.BringHereSquare = BringHere
	o.parent = superSurvivor
	o.group = superSurvivor:getGroup()
	o.Name = "Pile Corpses"

	o.Target = nil
	o.TargetSquare = nil
	o.Complete = false

	o.parent:setLastWeapon()
	return o
end

function PileCorpsesTask:ForceFinish()
	self.parent:reEquipLastWeapon()
	self.Complete = true;
end

function PileCorpsesTask:isComplete()
	return self.Complete
end

function PileCorpsesTask:isValid()
	if not self.parent then
		return false
	else
		return true
	end
end

-- WIP - Cows: NEED TO REWORK THE NESTED LOOP CALLS
function PileCorpsesTask:update()
	CreateLogLine("PileCorpsesTask", isLocalLoggingEnabled, "PileCorpsesTask:update() Called");
	if (not self:isValid()) then return false end

	if (self.parent:isInAction() == false) then
		local player = self.parent.player

		if ((player:getInventory():FindAndReturn("CorpseMale") ~= nil)
				or (player:getInventory():FindAndReturn("CorpseFemale") ~= nil))
		then
			local distanceToPoint = GetDistanceBetween(self.BringHereSquare, player)

			if (distanceToPoint > 2.0) then
				self.parent:walkToDirect(self.BringHereSquare)
			else
				local Corpse = player:getInventory():FindAndReturn("CorpseMale")
				if not Corpse then Corpse = player:getInventory():FindAndReturn("CorpseFemale") end

				self.parent:StopWalk()

				ISTimedActionQueue.add(ISDropItemAction:new(self.parent:Get(), Corpse, 30))
				self.parent:Get():setPrimaryHandItem(nil)
				self.parent:Get():setSecondaryHandItem(nil)
				self.Target = nil
			end
		elseif (self.Target == nil) then
			-- WIP - Cows: "range" determines the number of scans for corpses.
			-- 45 * 45 = 2045 -- original value
			-- 30 * 30 = 900, - which reduces the scan range
			local range = 30;
			local Square;
			local minx = math.floor(player:getX() - range);
			local maxx = math.floor(player:getX() + range);
			local miny = math.floor(player:getY() - range);
			local maxy = math.floor(player:getY() + range);
			local z = 0

			if (self.group ~= nil) then
				local area = self.group:getGroupArea("TakeCorpseArea")
				if (area[1] ~= 0) then
					minx = area[1]
					maxx = area[2]
					miny = area[3]
					maxy = area[4]
					z = area[5]
				end
			end
			local closestsoFar = range + 1;
			local gamehours = getGameTime():getWorldAgeHours();

			for x = minx, maxx do

				for y = miny, maxy do
					Square = getCell():getGridSquare(x, y, z);

					if (Square ~= nil)
						and (GetDistanceBetween(self.BringHereSquare, Square) > 2)
						and (Square:getDeadBody())
					then
						local distance = GetDistanceBetween(Square, player); -- WIP - literally spammed inside the nested for loops...
						self.Target = Square:getDeadBody()
						self.TargetSquare = Square

						if (distance < closestsoFar) then
							closestsoFar = distance;
						end
					end
				end
			end
			if (self.Target ~= nil) then
				player:StopAllActionQueue();
				self.Target:getModData().isClaimed = gamehours;
				--ISTimedActionQueue.add(ISWalkToTimedAction:new(player, self.TargetSquare:getN()));
				self.parent:walkTo(self.TargetSquare);
			else
				self.Complete = true
			end
		elseif (self.Target ~= nil) then
			if (self.TargetSquare:getDeadBody()
					and (GetDistanceBetween(self.TargetSquare, player) > 2.0))
			then
				self.parent:walkTo(self.TargetSquare);
			elseif self.TargetSquare:getDeadBody() then
				ISTimedActionQueue.add(ISGrabCorpseAction:new(self.parent:Get(), self.TargetSquare:getDeadBody(), 30))

				self.parent:RoleplaySpeak(Get_SS_UIActionText("PickUpCorpse"))
			else
				self.Target = nil
			end
		end
	else
		--self.parent:Speak("waiting for non action");
	end
	CreateLogLine("PileCorpsesTask", isLocalLoggingEnabled, "--- PileCorpsesTask:update() End ---");
end
