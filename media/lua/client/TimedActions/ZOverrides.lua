require "TimedActions/ISInventoryTransferAction"

local SSIsInventoryTransferAction = {}
SSIsInventoryTransferAction.ISInventoryTransferAction = {}

SSIsInventoryTransferAction.ISInventoryTransferAction.perform = ISInventoryTransferAction.perform
function ISInventoryTransferAction:perform()

		print("SSIsInventoryTransferAction perform");
	if(self.item ~= nil) then -- edits
	local ssquare = getSourceSquareOfItem(self.item,self.character)
	--print(tostring(ssquare))
	if(ssquare ~= nil) and (self.destContainer:getType() ~= "floor") then
		local OwnerGroupId = SSGM:GetGroupIdFromSquare(ssquare)
		local TakerGroupId = self.character:getModData().Group
			if(OwnerGroupId ~= -1) and (self.item:getModData().FreeToTake == nil)  and (TakerGroupId ~= OwnerGroupId) and (self.character:getModData().ID ~= self.item:getModData().LastOwner) then
				print("ga stealing detected!")
				SSGM:Get(OwnerGroupId):stealingDetected(self.character)
			end
		end
	end

	SSIsInventoryTransferAction.ISInventoryTransferAction.perform(self)

	
end


require "TimedActions/ISGrabItemAction"

local SSISGrabItemAction = {}
SSISGrabItemAction.ISGrabItemAction = {}

SSISGrabItemAction.ISGrabItemAction.perform = ISGrabItemAction.perform
function ISGrabItemAction:perform()
	
	print("SSISGrabItemAction perform");
	if(self.item ~= nil) then
		local ssquare = getSourceSquareOfItem(self.item,self.character)
		if(ssquare ~= nil) then
			local OwnerGroupId = SSGM:GetGroupIdFromSquare(ssquare)
			local TakerGroupId = self.character:getModData().Group
			if(OwnerGroupId ~= -1) and (self.item:getModData().FreeToTake == nil) and  (TakerGroupId ~= OwnerGroupId) then
				print("ga stealing detected!")
				SSGM:Get(OwnerGroupId):stealingDetected(self.character)
			end
		end
	end
	
	SSISGrabItemAction.ISGrabItemAction.perform(self)
end