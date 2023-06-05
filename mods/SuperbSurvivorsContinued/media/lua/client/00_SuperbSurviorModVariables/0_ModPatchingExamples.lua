-- Cows: Thanks to albion#0123 for sharing this function.
-- This will retrieve a list of ALL the active mods the user currently has.
local activatedMods = getActivatedMods();

-- Cows: Check if active mod lists includes <ModId> and write for handler for dealing with it.
-- This block may need to be added to relevant functions such as equipment, perks, traits.
function CheckForMod()
    if activatedMods:contains("ModId") then
        -- Do Something
    end
end
