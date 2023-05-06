--[[
    WIP - Cows: This entire file was cut-pasted from "07_UI/SuperSurvivorsContextMenu.lua".
    There are NO active references  in this mod project to any of the functions here...
    What was even planned with these functions?
--]]
require "TimedActions/ISBaseTimedAction"

ISUnStuckAction = ISBaseTimedAction:derive("ISUnStuckAction");

function ISUnStuckAction:isValid()
    return true
end

function ISUnStuckAction:update()
    if self.character then
        self.character:getModData().felldown = true
        self.character:setMetabolicTarget(Metabolics.LightDomestic);
    end
end

function ISUnStuckAction:start()
    self:setActionAnim("Loot")
    self:setOverrideHandModels(nil, nil)
end

function ISUnStuckAction:stop()
    self.character:getModData().felldown = nil
    ISBaseTimedAction.stop(self);
end

function ISUnStuckAction:perform()
    self.character:getModData().felldown = nil
    ISBaseTimedAction.perform(self);
end

function ISUnStuckAction:new(character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.stopOnWalk = false;
    o.stopOnRun = false;
    o.forceProgressBar = false;
    o.mul = 2;
    o.maxTime = 1;

    return o;
end
