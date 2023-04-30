-- This file is replacing the old "SuperSurvivorSettings.lua" file.

-- Global Variables are loaded in order of appearance... so they must be loaded before everything else to be used.
-- Otherwise, you can expect a "nil" return when a global variable is referenced before it is loaded.

-- Global Boolean
SpeakEnabled = true;

-- Global Integer
DebugSayEnabled = DebugOptions;
GFollowDistance = 5; -- Update: Don't try to turn gfollowdistance into a variable from what it equals to. I made followtask add what it needs to add on its own.
PVPDefault = Option_ForcePVP;

-- Global String
StringTest = "This is a Global String Test";
