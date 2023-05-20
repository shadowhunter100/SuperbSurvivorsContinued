local isLocalLoggingEnabled = false;

--- Cows: This seems redundant? The SuperSurvivor file and SSM already have OnDeath functions defined... will need another look.
---@param player any
function SuperSurvivorOnDeath(player)
	if (player and player:getModData().ID ~= nil) then
		local SS = SSM:Get(player:getModData().ID);

		if (SS ~= nil) then
			SS:OnDeath();
		end
	end
end

function SuperSurvivorGlobalUpdate(player)
	CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled, "function: SuperSurvivorGlobalUpdate() called");

	CreateLogLine("SuperSurvivorUpdate", isLocalLoggingEnabled, "updating player id...");
	if (player and player:getModData().ID ~= nil) then
		local SS = SSM:Get(player:getModData().ID)
		if (SS ~= nil) then SS:PlayerUpdate() end
	end
end

local function getGunShotWoundBP(player)
	if (not instanceof(player, "IsoPlayer")) then
		return nil
	end

	local BD = player:getBodyDamage()
	local bps = BD:getBodyParts();
	local foundBP = false
	local list = {};
	if (bps) then
		for i = 1, bps:size() - 1 do
			if (bps:get(i) ~= nil) and (bps:get(i):HasInjury()) and (bps:get(i):getHealth() > 0) then
				table.insert(list, i);
				foundBP = true
			end
		end
	end
	if (not foundBP) then
		return nil
	end
	local result = ZombRand(1, #list)
	local index = list[result]
	local outBP = bps:get(index)
	return outBP
end

function SuperSurvivorPVPHandle(wielder, victim, weapon, damage)
	local SSW = SSM:Get(wielder:getModData().ID);
	local SSV = SSM:Get(victim:getModData().ID);

	local fakehit = false

	if (SSV == nil) or (SSW == nil) then return false end

	if (victim.setAvoidDamage ~= nil) then
		if (SSW:isInGroup(victim)) then
			fakehit = true;
			victim:setAvoidDamage(true);
		end
	elseif (victim.setNoDamage ~= nil) then
		if (SSW:isInGroup(victim)) then
			fakehit = true;
			victim:setNoDamage(true);
		else
			victim:setNoDamage(false);
		end
	end

	if fakehit then return false end

	local extraDamage;
	local shotPartshotPart = getGunShotWoundBP(victim);

	if (shotPartshotPart ~= nil) and (SSV:getID() ~= 0) then
		extraDamage = 100; --(damage*24)

		shotPartshotPart:AddDamage(extraDamage);
		shotPartshotPart:DamageUpdate();
		victim:getBodyDamage():DamageFromWeapon(weapon);
		victim:update();
	end

	if instanceof(victim, "IsoPlayer") then
		local GroupID = SSV:getGroupID()
		if (GroupID ~= nil) then
			local group = SSGM:GetGroupById(GroupID)
			if (group) then
				group:PVPAlert(wielder)
			end
		else
			victim:getModData().hitByCharacter = true
		end

		if (weapon ~= nil) and (not weapon:isAimedFirearm()) and (weapon:getPushBackMod() > 0.3) then
			victim:StopAllActionQueue()
			local dot = victim:getDotWithForwardDirection(wielder:getX(), wielder:getY());
			if (dot < 0) then
				ISTimedActionQueue.add(ISGetHitFromBehindAction:new(victim, wielder))
			elseif (dot > 0) then
				ISTimedActionQueue.add(ISGetHitFromFrontAction:new(victim, wielder))
			end
		end

		wielder:getModData().semiHostile = true;

		if (victim:getModData().surender) and weapon and weapon:isRanged() then -- defenceless player hit, they die
			victim:getBodyDamage():getBodyPart(BodyPartType.Head):AddDamage(500);
			victim:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(500);
			victim:getBodyDamage():getBodyPart(BodyPartType.Hand_L):AddDamage(500);
			victim:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(500);
			victim:getBodyDamage():Update();

			SSM:PublicExecution(SSW, SSV)
		end

		if instanceof(victim, "IsoPlayer") and instanceof(wielder, "IsoPlayer") and not (victim:isLocalPlayer()) then
			if weapon:getType() == "BareHands" then
				return
			end

			local b = true;
			local bindex = ZombRand(BodyPartType.Hand_L:index(), BodyPartType.MAX:index());
			local b2 = false;
			local b3 = false;
			local b4 = false;
			local n;
			if (weapon:getCategories():contains("Blunt") or weapon:getCategories():contains("SmallBlunt")) then
				n = 0;
				b2 = true;
			elseif not (weapon:isAimedFirearm()) then
				n = 1;
				b3 = true;
			else
				b4 = true;
				n = 2;
			end
			local bodydamage = victim:getBodyDamage()
			local bodypart = bodydamage:getBodyPart(BodyPartType.FromIndex(bindex));
			if (ZombRand(0, 100) < victim:getBodyPartClothingDefense(bindex, b3, b4)) then
				b = false;
			end
			if b == false then
				return;
			end
			victim:addHole(BloodBodyPartType.FromIndex(bindex));
			if (b3) then
				if (ZombRand(0, 6) == 6) then
					bodypart:generateDeepWound();
				elseif (ZombRand(0, 3) == 3) then
					bodypart:setCut(true);
				else
					bodypart:setScratched(true, true);
				end
			elseif (b2) then
				if (ZombRand(0, 4) == 4) then
					bodypart:setCut(true);
				else
					bodypart:setScratched(true, true);
				end
			elseif (b4) then
				bodypart:setHaveBullet(true, 0);
			end
			local n2 = ZombRand(weapon:getMinDamage(), weapon:getMaxDamage()) * 15.0;
			if (bindex == BodyPartType.Head:index()) then
				n2 = n2 * 4.0;
			end
			if (bindex == BodyPartType.Neck:index()) then
				n2 = n2 * 4.0;
			end
			if (bindex == BodyPartType.Torso_Upper:index()) then
				n2 = n2 * 2.0;
			end
			bodydamage:AddDamage(bindex, n2);
			local stats = victim:getStats();
			if n == 0 then
				stats:setPain(stats:getPain() + bodydamage:getInitialThumpPain() * BodyPartType.getPainModifyer(bindex));
			elseif n == 1 then
				stats:setPain(stats:getPain() + bodydamage:getInitialScratchPain() * BodyPartType.getPainModifyer(bindex));
			elseif n == 2 then
				stats:setPain(stats:getPain() + bodydamage:getInitialBitePain() * BodyPartType.getPainModifyer(bindex));
			end
			if stats:getPain() > 100 then
				stats:setPain(100)
			end

			SSV:NPCcalculateWalkSpeed();
		end
	end
end

Events.OnWeaponHitCharacter.Add(SuperSurvivorPVPHandle);
Events.OnPlayerUpdate.Add(SuperSurvivorGlobalUpdate);
Events.OnCharacterDeath.Add(SuperSurvivorOnDeath);
