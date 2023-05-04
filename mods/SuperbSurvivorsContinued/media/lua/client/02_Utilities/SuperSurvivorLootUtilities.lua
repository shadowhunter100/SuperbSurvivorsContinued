--this file has methods related to looting

local isLocalLoggingEnabled = false;
--- CATEGORIES ---

---@alias itemCategory
---| "Food"
---| "Water"
---| "Weapon"

--- finds the item inside of a 'container' based on the 'category'
---@param container any the container that the item will be searched
---@param category itemCategory the type of item that the item will be searched
---@param survivor any survivor searching for item (only in food searching)
---@return any returns the item insde of the container with the selected category or nil if not found
function FindItemByCategory(container, category, survivor)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindItemByCategory() called");
	if (category == "Food") then
		return FindAndReturnBestFood(container, survivor)
	elseif (category == "Water") then
		return FindAndReturnWater(container)
	elseif (category == "Weapon") then
		return FindAndReturnWeapon(container)
	else
		return container:FindAndReturnCategory(category)
	end
end

--- checks if the 'item' belongs to the 'category'
---@param item any
---@param category itemCategory category to be checked
---@return boolean returns true if the item belongs to the category
function HasCategory(item, category)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: HasCategory() called");
	if (category == "Water") and (IsItemWater(item)) then
		return true
	elseif (category == "Weapon") and (item:getCategory() == category) and (item:getMaxDamage() > 0.1) then
		return true
	else
		return (item:getCategory() == category)
	end
end

--- END CATEGORIES ---

--- WEAPONS ---
--- gets a weapon inside of a 'container'
---@param container any container to be searched
---@return any returns the first weapon inside the container or nil if not found
function FindAndReturnWeapon(container)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindAndReturnWeapon() called");
	if (not container) then
		return nil
	end

	local items = container:getItems()

	if (items ~= nil) and (items:size() > 0) then
		local count = items:size()

		for i = 1, count - 1 do
			local item = items:get(i)
			if (item ~= nil) and (item:getCategory() == "Weapon") and (item:getMaxDamage() > 0.1) then
				return item
			end
		end
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "no weapon found");
	end

	return nil
end

--- gets the best weapon inside of a 'container'
---@param container any container to be searched
---@return any returns the best weapon inside the container or nil if not found
function FindAndReturnBestWeapon(container)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindAndReturnBestWeapon() called");
	if (container == nil) then
		return nil
	end

	local items = container:getItems()
	local bestItem = nil

	if (items ~= nil) and (items:size() > 0) then
		local itemSize = items:size()

		for i = 1, itemSize - 1 do
			local item = items:get(i)
			if (item ~= nil) and (item:getCategory() == "Weapon") then
				if (item:getMaxDamage() > 0.1) and (bestItem == nil or bestItem:getMaxDamage() < item:getMaxDamage()) then
					bestItem = item
				end
			end
		end
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "no weapon found");
	end

	if (bestItem ~= nil) then
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled,
		"best weapon" .. tostring(bestItem:getDisplayName()) ..
		" | maxDamage: " .. tostring(bestItem:getMaxDamage())
	);
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "no best weapon found");
	end

	return bestItem
end

--- END WEAPONS ---

--- FOODS ---

local FoodsToExlude = { "Bleach", "Cigarettes", "HCCigar", "Antibiotics", "Teabag2", "Salt", "Pepper", "EggCarton" }

--- gets any kind of food that is not in 'FoodsToExlude' and not poisoned
---@param thisItemContainer any
---@return any returns the first found food inside the container
function FindAndReturnFood(thisItemContainer)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindAndReturnFood() called");
	if (not thisItemContainer) then
		return nil
	end

	local items = thisItemContainer:getItems()

	if (items ~= nil) and (items:size() > 0) then
		local count = items:size()

		for i = 1, count - 1 do
			local item = items:get(i)

			if (item ~= nil) and (item:getCategory() == "Food") then

				if not (item:getPoisonPower() > 1) and not (CheckIfTableHasValue(FoodsToExlude, item:getType())) then
					return item
				end
			end
		end
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "empty container food");
	end

	return nil
end

--- gets the score of the food based on status changes
---@param item any any food item
---@return number returns the score of the food
function GetFoodScore(item) -- TODO: improve food searching (and the logging)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: GetFoodScore() called");
	local score = 1.0

	if (item:getUnhappyChange() > 0) then
		score = score - math.floor(item:getUnhappyChange() / (item:getHungerChange() * -10.0))
	elseif (item:getUnhappyChange() < 0) then
		score = score + 1
	end

	if (item:getBoredomChange() > 0) then
		score = score - math.floor(item:getBoredomChange() / (item:getHungerChange() * -10.0) / 2.0)
	elseif (item:getBoredomChange() < 0) then
		score = score + 1
	end

	if (item:isFresh()) then
		score = score + 2
	elseif (item:IsRotten()) then
		score = score - 10
	end

	if (item:isAlcoholic()) then
		score = score - 5
	end
	if (item:isSpice()) then
		score = score - 5
	end

	if (item:isbDangerousUncooked()) and not (item:isCooked()) then
		score = score - 10
	end
	--if(item:isBurnt()) then Score = Score - 1 end

	local foodType = item:getFoodType()
	if (foodType == "NoExplicit") or (foodType == nil) then
		-- save the canned food
		if string.match(item:getDisplayName(), "Open") then
			score = score + 3
		elseif string.match(item:getDisplayName(), "Canned") then
			score = score - 5
		elseif (item:getDisplayName() == "Dog Food") then
			score = score - 10
		elseif (item:getHungerChange()) == nil or (item:getHungerChange() == 0) then
			score = -9999
		end -- unidentified, probably canned from a mod

		if (item:isCooked()) then
			score = score + 5
		end
	elseif (foodType == "Fruits") or (foodType == "Vegetables") then
		score = score + 1
	elseif (foodType == "Pasta") or (foodType == "Rice") then
		score = score - 2
	elseif ((foodType == "Egg") or (foodType == "Meat")) or item:isIsCookable() then
		if (item:isCooked()) then
			score = score + 2
		end
	elseif (foodType == "Coffee") then
		score = score - 5
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "unknown food");
	end

	return score
end

--- gets the best food in the current square of the 'survivor'
---@param sq any
---@param survivor any
---@return any returns the best food on the ground based on a score system
function FindAndReturnBestFoodOnFloor(sq, survivor)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindAndReturnBestFoodOnFloor() called");
	if (not sq) then
		return nil
	end
	local bestFood = nil
	local bestScore = 1

	if (survivor == nil) or (survivor:isStarving()) then
		-- if starving, willing to eat anything
		bestScore = -999
	elseif (survivor:isVHungry()) then
		-- not too picky, eat stale food
		bestScore = -10
	end

	local items = sq:getWorldObjects()
	local count = items:size()

	if count > 0 then

		for j = 0, count - 1 do
			local item = items:get(j):getItem()
			if (item ~= nil) and (item:getCategory() == "Food") and not (item:getPoisonPower() > 1) and (not CheckIfTableHasValue(FoodsToExlude, item:getType())) then
				local Score = GetFoodScore(item)

				if Score > bestScore then
					bestFood = item
					bestScore = Score
					CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled,
					"best food: " .. tostring(bestFood:getDisplayName()) ..
					" | food score: " .. tostring(bestScore));
				end
			end
		end
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "Empty container, no food");
	end

	return bestFood
end

--- gets the best food in a container next to the 'survivor'
---@param thisItemContainer any
---@param survivor any
---@return any returns the best food based on a score system
function FindAndReturnBestFood(thisItemContainer, survivor)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindAndReturnBestFood() called");
	if (not thisItemContainer) then
		return nil
	end

	local items = thisItemContainer:getItems()
	local bestFood = nil
	local bestScore = 1

	if (survivor == nil) or (survivor:isStarving()) then
		bestScore = -999
	elseif (survivor:isVHungry()) then
		bestScore = -10
	end

	if (items ~= nil) and (items:size() > 0) then
		local count = items:size()

		for i = 1, count - 1 do
			local item = items:get(i)

			if (item ~= nil) and (item:getCategory() == "Food") and not (item:getPoisonPower() > 1) and (not CheckIfTableHasValue(FoodsToExlude, item:getType())) then
				local Score = GetFoodScore(item)

				--ContainerItemsScore[i] = Score
				if Score > bestScore then
					bestFood = item
					bestScore = Score
					CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled,
					"best food: " .. tostring(bestFood:getDisplayName()) ..
					" | food score: " .. tostring(bestScore));
				end
			end
		end
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "Empty container, no food");
	end

	return bestFood
end

--- END FOOD ---

--- WATER ---

--- gets any water inside of 'container'
---@param container any
---@return any returns the first water found
function FindAndReturnWater(container)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: FindAndReturnWater() called");
	if (not container) then
		return nil
	end

	local items = container:getItems()

	if (items ~= nil) and (items:size() > 0) then
		local count = items:size()

		for i = 1, count - 1 do
			local item = items:get(i)
			if (item ~= nil) and IsItemWater(item) then
				CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "Water found");
				return item
			end
		end
	else
		CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "Empty container, no water");
	end
	return nil
end

--- checks if 'item' is a water source
---@param item any
---@return boolean return true if the current it is a water source (and is not Bleach)
function IsItemWater(item)
	CreateLogLine("SuperSurvivorLootUtilities", isLocalLoggingEnabled, "function: IsItemWater() called");
	return ((item:isWaterSource()) and (item:getType() ~= "Bleach"))
end

--- END WATER ---
