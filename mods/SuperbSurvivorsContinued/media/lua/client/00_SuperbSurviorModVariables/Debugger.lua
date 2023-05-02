local modId = "SuperbSurvivorsContinued";

--[[
    Credit to "haram gaming#4572" in PZ Discord for providing a text file writing example.
    Credit to "albion#0123" in PZ Discord for explaining the difference between "getFileWriter" and "getModFileWriter"
    CreateLogLine will create a log file under the "<user>/Zomboid/Lua/<modId>/logs".
--]]
function CreateLogLine(newLine)
    local timestamp = os.time();
    local formattedTimeDay = os.date("%Y-%m-%d", timestamp);
    local formattedTime = os.date("%Y-%m-%d %H:%M:%S", timestamp);
    local file = getFileWriter(modId .. "/logs/" .. formattedTimeDay .. "_".. modId .. "_Logs.txt", true, true);
    local content = formattedTime .. " : " .. "CreateLogLine called";

    if newLine then
        content = formattedTime .. " : " .. newLine;
    end

    file:write(content .. "\r\n");
    file:close();
end

-- Example usage:
CreateLogLine("Start...");
