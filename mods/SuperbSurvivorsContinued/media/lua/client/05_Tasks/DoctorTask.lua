require "04_Group.SuperSurvivorManager";

DoctorTask = {}
DoctorTask.__index = DoctorTask

local isLocalLoggingEnabled = false;
local isLocalLoggingEnabled = false;

function DoctorNeedsCleanBandage(bp)
	if (bp:HasInjury()) and (bp:bandaged() == true) and (bp:getBandageLife() <= 0) then return true end
	return false
end

function DoctorNeedsBandage(bp)
	if (bp:bandaged() == false) and ((bp:HasInjury()) or (bp:stitched())) then
		if (tostring(bp) == "ForeArm_R") then getSpecificPlayer(0):Say("needs bandage") end
		return true
	end
	if (tostring(bp) == "ForeArm_R") then getSpecificPlayer(0):Say("NOT needs bandage") end
	return false
end

function DoctorNeedsBulletRemoval(bp)
	if (bp:HasInjury()) and (bp:haveBullet()) then return true end
	return false
end

function DoctorNeedsGlassRemoval(bp)
	if (bp:HasInjury()) and (bp:haveGlass()) then return true end
	return false
end

function DoctorNeedsStiches(bp)
	if (bp:HasInjury()) and (bp:isDeepWounded()) and (bp:stitched() == false) then return true end
	return false
end

function DoctorNeedsSplint(bp)
	if (bp:HasInjury()) and (bp:isSplint() == false) and (bp:getFractureTime() > 0) then return true end
	return false
end

function DoctorDetermineTreatement(bp)
	CreateLogLine("SuperSurvivorDoctor", isLocalLoggingEnabled, "DoctorDetermineTreatement() called");
	if not instanceof(bp, "BodyPart") then
		CreateLogLine("SuperSurvivorManager", isLocalLoggingEnabled, "error non body part given to DoctorDetermineTreatement");
		return "?"
	end

	if (DoctorNeedsSplint(bp)) then
		return "Splint"
	elseif (DoctorNeedsStiches(bp)) and (bp:bandaged()) then
		return "Bandage Removal"
	elseif (DoctorNeedsStiches(bp)) and (not bp:bandaged()) then
		return "Stich"
	elseif (DoctorNeedsGlassRemoval(bp)) and (bp:bandaged()) then
		return "Bandage Removal"
	elseif (DoctorNeedsGlassRemoval(bp)) and (not bp:bandaged()) then
		return "Remove Glass"
	elseif (DoctorNeedsBulletRemoval(bp)) and (bp:bandaged()) then
		return "Bandage Removal"
	elseif (DoctorNeedsBulletRemoval(bp)) and (not bp:bandaged()) then
		return "Remove Bullet"
	elseif (DoctorNeedsBandage(bp)) then
		return "Bandage"
	elseif (DoctorNeedsCleanBandage(bp)) then
		return "Bandage Removal"
	else
		return "None"
	end
end

function RequiresTreatment(player)
	local bodyparts = player:getBodyDamage():getBodyParts()

	for i = 0, bodyparts:size() - 1 do
		local bp = bodyparts:get(i)
		if DoctorDetermineTreatement(bp) ~= "None" then return true end
	end

	return false
end

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
			self.parent:Speak(Get_SS_Dialogue("RIPSurvivor"))
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
