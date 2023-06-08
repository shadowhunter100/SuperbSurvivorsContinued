--[[
    WIP - Cows: Found the documentation...
    https://projectzomboid.com/modding/zombie/core/Core.html#addKeyBinding(java.lang.String,java.lang.Integer)
    Does the key override? How do we create a category in keys.ini?
    Maybe look into ModOptions to handle the key bindings?
--]]

-- 06-08-2023 - Cows: Commented out, don't actually need all these insertions if keynum can be set and matched in SuperSurvivorsModHotkeys
-- local isLocalLoggingEnabled = false;

-- WIP - Cows: The keybinding needs to be reworked.
-- Using the global keyBinding table, to store all our binding values
-- local function insertKeyBinding()
-- 	CreateLogLine("SuperSurvivorsKeyBindings", isLocalLoggingEnabled, "function: insertKeyBinding() called");
-- 	local index = nil -- index will be the position we want to insert into the table

-- 	for i, b in ipairs(keyBinding) do
-- 		CreateLogLine("SuperSurvivorsKeyBindings", isLocalLoggingEnabled, "index: " .. tostring(i));
-- 		CreateLogLine("SuperSurvivorsKeyBindings", isLocalLoggingEnabled, "key: " .. tostring(b.key));
-- 		CreateLogLine("SuperSurvivorsKeyBindings", isLocalLoggingEnabled, "value: " .. tostring(b.value));
-- 		-- "Shout" is the NPC interaction section in key.ini
-- 		if b.value == "Shout" then
-- 			index = i -- found the index, set it and break from the loop
-- 			break;
-- 		end
-- 	end
-- 	-- WIP - Cows: The hotkeys bindings are hard-coded here... it replaces all previous keybinds that were created perviously.
-- 	if index then
-- 		CreateLogLine("SuperSurvivorsKeyBindings", isLocalLoggingEnabled, "Inserting keyBinding ...");
-- 		-- we got a index, first lets insert our new entries
-- 		table.insert(keyBinding, index + 1, { value = "Call Closest Group Member", key = 55 });     -- Used to be key "T", updated to "numpad *" button
-- 		table.insert(keyBinding, index + 2, { value = "Call Closest Non-Group Member", key = 181 }); -- Used to be key "Y", updated to "numpad /" button
-- 		table.insert(keyBinding, index + 3, { value = "Ask Closest Group Member to Follow", key = 209 }); -- Used to be key "G", updated to "Page Down" button
-- 		table.insert(keyBinding, index + 4, { value = "Toggle Group Window", key = 201 });          -- Used to be key "Backspace", updated to "Page Up" button
-- 		table.insert(keyBinding, index + 5, { value = "Spawn Wild Survivor", key = 156 });          -- Used to be key "6", updated to "numpad Enter" button
-- 		table.insert(keyBinding, index + 6, { value = "Lower Follow Distance", key = 74 });         -- "numpad -"
-- 		table.insert(keyBinding, index + 7, { value = "Raise Follow Distance", key = 78 });         -- "numpad +"
-- 		table.insert(keyBinding, index + 8, { value = "SSHotkey_1", key = 200 });                   -- Up Arrow key
-- 		table.insert(keyBinding, index + 9, { value = "SSHotkey_2", key = 208 });                   -- Down Arrow key
-- 		table.insert(keyBinding, index + 10, { value = "SSHotkey_3", key = 203 });                  -- Left Arrow key
-- 		table.insert(keyBinding, index + 11, { value = "SSHotkey_4", key = 205 });                  -- Right Arrow key
-- 		table.insert(keyBinding, index + 12, { value = "NumPad_5", key = 76 });
-- 	end
-- end

-- insertKeyBinding()
