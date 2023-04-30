GiveRewardToPlayerTask = {}
GiveRewardToPlayerTask.__index = GiveRewardToPlayerTask

function GiveRewardToPlayerTask:new(superSurvivor, DropSquare, itemType,quantity)

	local o = {}
	setmetatable(o, self)
	self.__index = self
	superSurvivor:DebugSay("GiveRewardToPlayerTask is about to trigger a StopWalk! ")
	superSurvivor:StopWalk()
	
	if(instanceof(DropSquare,"IsoPlayer")) then o.TheDropSquare = DropSquare:getCurrentSquare()
	elseif(instanceof(DropSquare,"IsoObject")) then 
		print("GiveRewardToPlayerTask given a ISOObject container")
		o.TheDropContainer = DropSquare
		o.TheDropSquare = DropSquare:getSquare()	 
	else o.TheDropSquare = DropSquare end
	
	if(not quantity) then quantity = 1 end
	if(not itemType) then itemType = "Base.CannedCorn" end
	
	o.parent = superSurvivor
	o.Name = "Give Reward To Player"
	o.OnGoing = false
	o.Complete = false
	o.itemType = itemType
	o.itemQuantity = quantity
	o.itemsprocessedcount = 0
	
	return o

end

function GiveRewardToPlayerTask:isComplete()
	if(self.itemsprocessedcount >= self.itemQuantity) then self.Complete = true end
	
	if(self.Complete == true) then
		triggerEvent("OnClothingUpdated", self.parent.player)
	end
	return self.Complete
	
end

function GiveRewardToPlayerTask:isValid()
	if not self.parent or (not self.TheDropSquare and not self.TheDropContainer) then return false 
	else return true end
end

function GiveRewardToPlayerTask:Talked()
	self.TicksSinceLastExchange = 0
end

function GiveRewardToPlayerTask:update()
	
	if(not self:isValid()) then 
		self.Complete = true 
		return false 
	end
	
	if (self.parent:isInAction() == false) then
		
		local distance = getDistanceBetween(self.parent.player,self.TheDropSquare)
		if (distance > 2.0) then
			self.parent:walkTo(self.TheDropSquare) 	
		else		
			local inv = self.parent.player:getInventory()
			local item = inv:AddItem(instanceItem(self.itemType))
			item:getModData().FreeToTake = true
			ISTimedActionQueue.add(ISDropItemAction:new (self.parent.player, item, 30))	
			self.itemsprocessedcount = self.itemsprocessedcount + 1
			
		end
					
		
		
	end
	
	if(self.itemsprocessedcount >= self.itemQuantity) then self.Complete = true end

end
