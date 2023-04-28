-- This file is replacing the old "SuperSurvivorSettings.lua" file.

-- Global Variables are loaded in order of appearance... so they must be loaded before everything else to be used.
-- Otherwise, you can expect a bunch of "nil" returns when referenced.

-- Global Boolean
SpeakEnabled = true;

-- Global Integer
DebugSayEnabled = DebugOptions;
GFollowDistance = 5; -- Update: Don't try to turn gfollowdistance into a variable from what it equals to. I made followtask add what it needs to add on its own.
PVPDefault = Option_ForcePVP;

-- Global String
StringTest = "Thsi is a Global String Test";

-- Global Survivor Orders
-- This was moved out of the "SuperSurvivorUtilities.lua" file.
Orders = {
    "Barricade",
    "Chop Wood",
    "Clean Up Inventory",
    "Doctor",
    "Explore",
    "Follow",
    "Farming",
    "Forage",
    "Gather Wood",
    "Go Find Food",
    "Go Find Water",
    "Go Find Weapon",
    "Guard",
    "Hold Still",
    "Lock Doors",
    "Unlock Doors",
    "Loot Room",
    "Patrol",
    "Sort Loot Into Base",
    "Stand Ground",
    "Stop",
    "Dismiss",
    "Relax",
    "Return To Base",
    "Pile Corpses",
};
local function getOrderDesc(orderName)
    return getText("ContextMenu_SS_OrderDesc_" .. orderName)
end

OrderDesc = {}
OrderDesc["Barricade"] = getOrderDesc("Barricade")
OrderDesc["Farming"] = getOrderDesc("Farming")
OrderDesc["Chop Wood"] = getOrderDesc("Chop_Wood")
OrderDesc["Explore"] = getOrderDesc("Explore")
OrderDesc["Follow"] = getOrderDesc("Follow")
OrderDesc["Forage"] = getOrderDesc("Forage")
OrderDesc["Guard"] = getOrderDesc("Guard")
OrderDesc["Patrol"] = getOrderDesc("Patrol")
OrderDesc["Stand Ground"] = getOrderDesc("Stand_Ground")
OrderDesc["Loot Room"] = getOrderDesc("Loot_Room")
OrderDesc["Lock Doors"] = getOrderDesc("Lock_Doors")
OrderDesc["Unlock Doors"] = getOrderDesc("Unlock_Doors")
OrderDesc["Doctor"] = getOrderDesc("Doctor")
OrderDesc["Go Find Food"] = getOrderDesc("Go_Find_Food")
OrderDesc["Go Find Weapon"] = getOrderDesc("Go_Find_Weapon")
OrderDesc["Go Find Water"] = getOrderDesc("Go_Find_Water")
OrderDesc["Sort Loot Into Base"] = "Sort all held Loot Into Base Area containers based on item type"
OrderDesc["Clean Up Inventory"] = getOrderDesc("Clean_Up_Inventory")
OrderDesc["Hold Still"] = getOrderDesc("Hold_Still")
OrderDesc["Gather Wood"] = getOrderDesc("Gather_Wood")
OrderDesc["Dismiss"] = getOrderDesc("Dismiss")
OrderDesc["Relax"] = getOrderDesc("Relax")
OrderDesc["Pile Corpses"] = getOrderDesc("Pile_Corpses")
OrderDesc["Return To Base"] = getOrderDesc("Return_To_Base")
OrderDesc["Stop"] = getOrderDesc("Stop")

local function getOrderName(orderName)
    return getText("ContextMenu_SS_OrderDisplayName_" .. orderName)
end

OrderDisplayName = {}
OrderDisplayName["Farming"] = getOrderName("Farming")
OrderDisplayName["Barricade"] = getOrderName("Barricade")
OrderDisplayName["Chop Wood"] = getOrderName("Chop_Wood")
OrderDisplayName["Explore"] = getOrderName("Explore")
OrderDisplayName["Follow"] = getOrderName("Follow")
OrderDisplayName["Forage"] = getOrderName("Forage")
OrderDisplayName["Guard"] = getOrderName("Guard")
OrderDisplayName["Patrol"] = getOrderName("Patrol")
OrderDisplayName["Stand Ground"] = getOrderName("Stand_Ground")
OrderDisplayName["Loot Room"] = getOrderName("Loot_Room")
OrderDisplayName["Lock Doors"] = getOrderName("Lock_Doors")
OrderDisplayName["Unlock Doors"] = getOrderName("Unlock_Doors")
OrderDisplayName["Doctor"] = getOrderName("Doctor")
OrderDisplayName["Go Find Food"] = getOrderName("Go_Find_Food")
OrderDisplayName["Go Find Weapon"] = getOrderName("Go_Find_Weapon")
OrderDisplayName["Go Find Water"] = getOrderName("Go_Find_Water")
OrderDisplayName["Clean Up Inventory"] = getOrderName("Clean_Up_Inventory")
OrderDisplayName["Sort Loot Into Base"] = "Sort Loot Into Base"
OrderDisplayName["Hold Still"] = getOrderName("Hold_Still")
OrderDisplayName["Gather Wood"] = getOrderName("Gather_Wood");
OrderDisplayName["Dismiss"] = getOrderName("Dismiss")
OrderDisplayName["Relax"] = getOrderName("Relax");
OrderDisplayName["Pile Corpses"] = getOrderName("Pile_Corpses");
OrderDisplayName["Return To Base"] = getOrderName("Return_To_Base");
OrderDisplayName["Stop"] = getOrderName("Stop");
