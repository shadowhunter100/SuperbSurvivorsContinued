require "05_Other/SuperSurvivorManager";

DoctorTask = {}
DoctorTask.__index = DoctorTask

local isLocalLoggingEnabled = false;

function DoctorTask:new(superSurvivor)
	CreateLogLine("DoctorTask", isLocalLoggingEnabled, "DoctorTask:new() Called");
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.parent = superSurvivor
	o.Patient = nil
	o.Name = "Doctor"
	o.OnGoing = false
	o.Complete = false
	o.ReturnSquare = superSurvivor:Get():getCurrentSquare()

	return o
end

function DoctorTask:isComplete()
	return self.Complete
end

function DoctorTask:isValid()
	if (not self.parent) then
		return false
	else
		return true
	end
end

-- WIP - Cows: NEED TO REWORK THE NESTED LOOP CALLS
function DoctorTask:FindPatient()
	CreateLogLine("DoctorTask", isLocalLoggingEnabled, "DoctorTask:FindPatient() Called");
	local player = self.parent.player
	local patient = nil
	local range = 15;
	local Square, closestsoFarSquare;
	local minx = math.floor(player:getX() - range);
	local maxx = math.floor(player:getX() + range);
	local miny = math.floor(player:getY() - range);
	local maxy = math.floor(player:getY() + range);
	local closestsoFar = range;

	for x = minx, maxx do

		for y = miny, maxy do
			Square = getCell():getGridSquare(x, y, player:getZ())

			if (Square ~= nil) then
				local distance = GetDistanceBetween(Square, player); -- WIP - Cows: literally spammed inside the nested for loops...
				local closeobjects = Square:getMovingObjects()

				for i = 0, closeobjects:size() - 1 do
					local obj = closeobjects:get(i)
					if (obj ~= nil) then
						if (instanceof(obj, "IsoPlayer") and (self.parent.player:CanSee(obj)) and (obj:isDead() == false) and (obj:getModData().isHostile ~= true) and RequiresTreatment(obj) and (distance < closestsoFar)) then
							patient = obj
						end
					end
				end
			end
		end
	end

	CreateLogLine("DoctorTask", isLocalLoggingEnabled, "--- DoctorTask:FindPatient() END ---");
	return patient
end

function DoctorTask:update()
	if (not self:isValid()) then return false end
	if (not self.parent:isInAction() == false) then return false end

	if (self.Patient ~= nil) then
		if (self.Patient:isDead()) then
			self.parent:Speak(GetDialogue("RIPSurvivor"))
			self.Patient = nil
			return false
		end

		local distance = GetDistanceBetween(self.Patient, self.parent:Get())

		if (distance < 2.0) then
			local bodyparts = self.Patient:getBodyDamage():getBodyParts()
			local foundbodypartneedingtreatment = false
			for i = 0, bodyparts:size() - 1 do
				local bp = bodyparts:get(i)
				local treatment = DoctorDetermineTreatement(bp)


				if treatment ~= "None" and (self.Patient ~= nil) then
					local doctor = self.parent:Get()

					local alcohol = doctor:getInventory():FindAndReturn("AlcoholWipes")
					if (alcohol == nil) then alcohol = doctor:getInventory():AddItem("Base.AlcoholWipes") end
					local bandage = doctor:getInventory():FindAndReturn("Bandage")
					if (bandage == nil) then bandage = doctor:getInventory():AddItem("Base.Bandage") end
					local rippedsheets = doctor:getInventory():FindAndReturn("RippedSheets")
					if (rippedsheets == nil) then rippedsheets = doctor:getInventory():AddItem("Base.RippedSheets") end

					foundbodypartneedingtreatment = true;
					self.parent:StopWalk()
					if treatment == "Splint" then
						self.parent:RoleplaySpeak(Get_SS_UIActionText("DoctorSplint"))
						ISTimedActionQueue.add(ISSplint:new(doctor, self.Patient, rippedsheets,
							doctor:getInventory():AddItem("Base.Plank"), bp, true))
					elseif treatment == "Bandage Removal" then
						self.parent:RoleplaySpeak(Get_SS_UIActionText("DoctorBandageRemove"))
						ISTimedActionQueue.add(ISApplyBandage:new(doctor, self.Patient, bandage, bp, false))
					elseif treatment == "Stich" then
						self.parent:RoleplaySpeak(Get_SS_UIActionText("DoctorStitches"))
						ISTimedActionQueue.add(ISStitch:new(doctor, self.Patient,
							doctor:getInventory():AddItem("Base.SutureNeedle"), bp, true))
					elseif treatment == "Remove Glass" then
						self.parent:RoleplaySpeak(Get_SS_UIActionText("DoctorGlass"))
						ISTimedActionQueue.add(ISRemoveGlass:new(doctor, self.Patient, bp))
					elseif treatment == "Remove Bullet" then
						self.parent:RoleplaySpeak(Get_SS_UIActionText("DoctorBullet"))
						ISTimedActionQueue.add(ISRemoveBullet:new(doctor, self.Patient, bp))
					elseif treatment == "Bandage" then
						ISTimedActionQueue.add(ISDisinfect:new(doctor, self.Patient, alcohol, bp))
						self.parent:RoleplaySpeak(Get_SS_UIActionText("DoctorBandage"))
						ISTimedActionQueue.add(ISApplyBandage:new(doctor, self.Patient, bandage, bp, true))
					end
				end
			end
		end
	else
		self.Patient = self:FindPatient()

		if (self.Patient == nil) and (self.parent:Get():getCurrentSquare() ~= self.ReturnSquare) then
			self.parent:walkToDirect(self.ReturnSquare);
		end
	end
end