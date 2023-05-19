SuperSurvivorGroupManager = {}
SuperSurvivorGroupManager.__index = SuperSurvivorGroupManager

function SuperSurvivorGroupManager:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.Groups = {}
	o.GroupCount = 0

	return o
end

function SuperSurvivorGroupManager:GetGroupById(thisID)
	return self.Groups[thisID]
end

function SuperSurvivorGroupManager:GetGroupIdFromSquare(square)
	for i = 0, self.GroupCount do
		if (self.Groups[i]) and (self.Groups[i]:IsInBounds(square)) then
			return self.Groups[i]:getID()
		end
	end
	return -1
end

function SuperSurvivorGroupManager:getCount()
	return self.GroupCount
end

function SuperSurvivorGroupManager:newGroup()
	local groupID = self.GroupCount
	for i = 0, self.GroupCount do
		if (self.Groups[i]) and (self.Groups[i]:getID() >= groupID) then
			groupID = self.Groups[i]:getID() + 1
		end
	end

	self.Groups[groupID] = SuperSurvivorGroup:new(groupID)
	self.GroupCount = groupID + 1
	return self.Groups[groupID]
end

function SuperSurvivorGroupManager:Save()
	for i = 0, self.GroupCount do
		if (self.Groups[i]) then
			self.Groups[i]:Save() -- WIP - console.txt logged an error tracing to this line
		end
	end
end

function SuperSurvivorGroupManager:Load()
	if (DoesFileExist("SurvivorGroup0.lua")) then -- only load if any groups detected at all
		self.GroupCount = 0

		while DoesFileExist("SurvivorGroup" .. tostring(self.GroupCount) .. ".lua") do
			local newGroup = self:newGroup()
			newGroup:Load()
		end
	end
end

SSGM = SuperSurvivorGroupManager:new()
