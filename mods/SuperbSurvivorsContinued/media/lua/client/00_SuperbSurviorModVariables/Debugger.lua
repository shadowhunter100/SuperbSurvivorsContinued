require "00_SuperbSurviorModVariables.SuperSurviorsGlobalVariables";

local modId = "SuperbSurvivorsContinued";
local isLocalLoggingEnabled = false;

--[[
    Credit to "haram gaming#4572" in PZ Discord for providing a text file writing example.
    Credit to "albion#0123" in PZ Discord for explaining the difference between "getFileWriter" and "getModFileWriter"
    CreateLogLine will create a log file under the "<user>/Zomboid/Lua/<modId>/logs".
--]]
-- Use this function to write a line to a text file, this is useful to identify when and how many times a function is called.
function CreateLogLine(fileName, isEnabled, newLine)
    if (isEnabled) then
        local timestamp = os.time();
        local formattedTimeDay = os.date("%Y-%m-%d", timestamp);
        local formattedTime = os.date("%Y-%m-%d %H:%M:%S", timestamp);
        local file = getFileWriter(modId .. "/logs/" .. formattedTimeDay .. "_" .. modId .. "_".. fileName .. "_Logs.txt", true, true);
        local content = formattedTime .. " : " .. "CreateLogLine called";

        if newLine then
            content = formattedTime .. " : " .. newLine;
        end

        file:write(content .. "\r\n");
        file:close();
    end
end

-- Example usage:
CreateLogLine("Debugger", isLocalLoggingEnabled, "Start...");
