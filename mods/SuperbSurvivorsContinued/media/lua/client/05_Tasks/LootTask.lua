LootCategoryTask = {}
LootCategoryTask.__index = LootCategoryTask

local isLocalLoggingEnabled = false;

function LootCategoryTask:new(superSurvivor, building, category, thisQuantity)
	CreateLogLine("LootTask", isLocalLoggingEnabled, "function: LootCategoryTask:new() called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	if (superSurvivor == nil) then return false end

	o.FoundCount = 0
	if (thisQuantity > 0) then
		o.Quantity = thisQuantity -- 0 for no limit basically
	else
		o.Quantity = 9999
	end
	o.parent = superSurvivor
	o.Name = "Loot Category"
	o.OnGoing = false
	o.Category = category

	if (not superSurvivor.player:getCurrentSquare()) then
		o.Complete = true
		return nil
	end

	o.Building = building
	o.parent:MarkBuildingExplored(o.Building)
	o.PlayerBag = superSurvivor.player:getInventory()
	o.Container = nil
	o.Complete = false
	o.Floor = 0


	return o
end

function LootCategoryTask:ForceFinish()
	self.parent:BuildingLooted()
	--self.parent:MarkBuildingExplored(self.Building)
	self.parent.TargetBuilding = nil
	self.Complete = true
	self.parent:resetContainerSquaresLooted()
	if (self.Category == "Weapon") then
		local weapon = FindAndReturnBestWeapon(self.PlayerBag)
		if (weapon == nil) then
			return
		end

		local current = self.parent:Get():getPrimaryHandItem()
		if (current == nil) then
			self.parent:Get():setPrimaryHandItem(weapon)
			return
		end

		if (instanceof(current, "HandWeapon") and (current:getMaxDamage() >= weapon:getMaxDamage())) then
			-- current weapon better than best one found so dont switch
			return
		end

		self.parent:Get():setPrimaryHandItem(weapon)
		if (weapon:isTwoHandWeapon()) then
			self.parent:Get():setSecondaryHandItem(weapon)
		end
	end
end

function LootCategoryTask:isComplete()
	if (self.Complete) then
		self:ForceFinish()
	end
	return self.Complete
end

function LootCategoryTask:isValid()
	return true
end

-- WIP - Cows: NEED TO REWORK THE NESTED LOOP CALLS
function LootCategoryTask:update()
	CreateLogLine("LootTask", isLocalLoggingEnabled, "function: LootCategoryTask:update() called");
	if (not self:isValid()) then
		self.Complete = true
		return false
	end
	if (self.parent:isInAction()) then
		return false
	end
	-- Checks if safebase is set to 'true' and if so, and the npc is inside a safebase the player made? forces task complete
	if (self.Building ~= nil) and self.parent:isTargetBuildingClaimed(self.Building) then
		self.Complete = true
		return false
	end

	if (self.Category == nil) then self.Category = "Food" end
	local loopcount

	self.PlayerBag = self.parent:getBag()

	if (not self.Building) then
		self.Complete = true
		self.parent:Speak(Get_SS_UIActionText("NotInBuilding"))
	elseif (not self.parent:hasRoomInBag()) then
		self.Container = nil
		self.Complete = true
		self.parent:Speak(Get_SS_UIActionText("CantCarryMore"))
	else
		loopcount = 0

		if (self.Container == nil)
			or ((instanceof(self.Container, "ItemContainer"))
				and (self.parent:getContainerSquareLooted(self.Container:getSourceGrid(), self.Category) == 0))
		then
			self.Container = nil
			local ID = self.parent:getID()
			local stoploop = false
			local bdef = self.Building:getDef()
			local closestSoFar = 999

			for z = 2, 0, -1 do
				for x = bdef:getX() - 2, (bdef:getX() + bdef:getW()) + 2 do
					if (stoploop) then break end

					for y = bdef:getY() - 2, (bdef:getY() + bdef:getH()) + 2 do
						if (stoploop) then break end
						loopcount = loopcount + 1
						local sq = getCell():getGridSquare(x, y, z)
						if (sq ~= nil) and (not sq:isOutside()) then
							--sq:AddWorldInventoryItem("Base.Nails",0.5,0.5,0)
							--self.parent:Explore(sq)								
							local items = sq:getObjects()
							local tempDistance = GetDistanceBetween(sq, self.parent.player); -- WIP - literally spammed inside the nested for loops...

							for j = 0, items:size() - 1 do
								if (items:get(j):getContainer() ~= nil) then
									local container = items:get(j):getContainer()

									if (sq:getZ() ~= self.parent.player:getZ()) then
										tempDistance = tempDistance + 13;
									end

									if (self.parent:getWalkToAttempt(sq) <= 8)
										and (tempDistance < closestSoFar)
										and (self.parent:getContainerSquareLooted(sq, self.Category) == 0)
									then
										self.Container = container
										closestSoFar = tempDistance
										self.Floor = z
									end
								end
							end
							if (self.Container == nil) then
								items = sq:getWorldObjects()
								for j = 0, items:size() - 1 do
									if (items:get(j):getItem()) then
										local container = items:get(j):getItem()
										if (container ~= nil and container:getCategory() == self.Category) then
											self.Container = container
											stoploop = true
											self.Floor = z
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end

		if (self.Container == nil) then
			self.Complete = true
		elseif (instanceof(self.Container, "ItemContainer")) then
			local distance = GetDistanceBetween(self.Container:getSourceGrid(), self.parent.player)
			if (distance > 2.1) or (self.parent.player:getZ() ~= self.Floor) then
				local trySquare = self.Container:getSourceGrid()

				if trySquare ~= nil and trySquare:getRoom() ~= nil then
					self.TargetBuilding = trySquare:getRoom():getBuilding()
				end
				self.parent:walkTo(trySquare)
				self.parent:WalkToAttempt(trySquare)
				if (self.Container:getSourceGrid()) and (self.parent:getWalkToAttempt(self.Container:getSourceGrid()) > 8) then
					self.Container = nil
					self.Complete = true
				end
			else
				local item = FindItemByCategory(self.Container, self.Category, self.parent)
				if (item ~= nil) then
					self.FoundCount = self.FoundCount + 1
					self.parent:RoleplaySpeak(Get_SS_UIActionText("TakesFromCont_Before") ..
						item:getDisplayName() .. Get_SS_UIActionText("TakesFromCont_After"))
					if (self.parent:hasRoomInBagFor(item)) then
						self.parent:StopWalk()
						ISTimedActionQueue.add(ISInventoryTransferAction:new(self.parent.player, item, self.Container,
							self.PlayerBag, nil))
					else
						self.parent.player:getInventory():AddItem(item)
						self.Container:DoRemoveItem(item)
					end
				else
					self.parent:ContainerSquareLooted(self.Container:getSourceGrid(), self.Category)
					self.Container = nil
				end
			end
		elseif (instanceof(self.Container, "InventoryItem")) then
			if (self.Container:getWorldItem() == nil) then
				self.Container = nil
				return false
			end
			local distance = GetDistanceBetween(self.Container:getWorldItem():getSquare(), self.parent.player);

			if (distance > 2.0) or (self.parent.player:getZ() ~= self.Floor) then
				if (self.parent.player:getPath2() == nil) then
					self.parent.player:StopAllActionQueue()
					local sq = self.Container:getWorldItem():getSquare()
					self.parent:walkTo(sq)
					if (sq:getRoom() ~= nil) then
						self.TargetBuilding = sq:getRoom():getBuilding()
					end
				end
			else
				local item = self.Container
				self.FoundCount = self.FoundCount + 1

				self.parent:RoleplaySpeak(Get_SS_UIActionText("TakesFromGround_Before") ..
					item:getDisplayName() .. Get_SS_UIActionText("TakesFromGround_After"))
				local srcContainer = item:getContainer()
				if instanceof(srcContainer, "ItemContainer") then
					--ISTimedActionQueue.add(ISInventoryTransferAction:new (self.parent.player, item, srcContainer, self.PlayerBag, nil))
					self.PlayerBag:AddItem(item)
					item:getWorldItem():removeFromSquare()
					item:setWorldItem(nil)
					self.Container = nil

					if (item ~= nil) then
						local ssquare = getSourceSquareOfItem(item, self.parent.player)

						if (ssquare ~= nil) then
							local OwnerGroupId = SSGM:GetGroupIdFromSquare(ssquare)
							local TakerGroupId = self.parent.player:getModData().Group
							if (OwnerGroupId ~= -1) and (TakerGroupId ~= OwnerGroupId) then
								SSGM:GetGroupById(OwnerGroupId):stealingDetected(self.parent.player)
							end
						end
					end
				end
			end
		end
	end
	if self.FoundCount >= self.Quantity then self.Complete = true end
	CreateLogLine("LootTask", isLocalLoggingEnabled, "--- function: LootCategoryTask:update() END ---");
end
