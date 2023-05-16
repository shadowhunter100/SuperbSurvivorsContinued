require "00_SuperbSurviorModVariables.SuperSurviorsGlobalVariables";

ModId = "SuperbSurvivorsContinued";
local isLocalLoggingEnabled = false;

--[[
    Credit to "haram gaming#4572" in PZ Discord for providing a text file writing example.
    Credit to "albion#0123" in PZ Discord for explaining the difference between "getFileWriter" and "getModFileWriter"
    CreateLogLine will create a log file under the "<user>/Zomboid/Lua/<ModId>/logs".
--]]
-- Use this function to write a line to a text file, this is useful to identify when and how many times a function is called.
function CreateLogLine(fileName, isEnabled, newLine)
    if (isEnabled) then
        local timestamp = os.time();
        local formattedTimeDay = os.date("%Y-%m-%d", timestamp);
        local formattedTime = os.date("%Y-%m-%d %H:%M:%S", timestamp);
        local file = getFileWriter(
            ModId .. "/logs/" .. formattedTimeDay .. "_" .. ModId .. "_" .. fileName .. "_Logs.txt", true, true);
        local content = formattedTime .. " : " .. "CreateLogLine called";

        if newLine then
            content = formattedTime .. " : " .. newLine;
        end

        file:write(content .. "\r\n");
        file:close();
    end
end

--[[
    Log the key-value pairs of a table to a specified file.
-- ]]
function LogTableKVPairs(fileName, isEnabled, table)
    if (isEnabled) then
        for key, value in pairs(table) do
            CreateLogLine(fileName, isEnabled, "key:" .. tostring(key) .. " | value: " .. tostring(value));

            if (pairs(value)) then
                for key1, val1 in pairs(value) do
                    CreateLogLine(fileName, isEnabled,
                        "key1: " .. tostring(key1) ..
                        " | val1: " .. tostring(val1)
                    );

                    if (key1 == "Members") then
                        CreateLogLine(fileName, isEnabled, "--- BEGIN GROUP MEMBERS LINE BREAK ---");
                        if (pairs(val1)) then
                            for memberNo, survivorId in pairs(val1) do
                                CreateLogLine(fileName, isEnabled,
                                    "memberNo: " .. tostring(memberNo) ..
                                    " | survivorId: " .. tostring(survivorId)
                                );
                            end
                        end
                        CreateLogLine(fileName, isEnabled, "--- END GROUP MEMBERS LINE BREAK ---");
                    end
                end
            end
        end
    end
end

-- Example usage:
CreateLogLine("Debugger", isLocalLoggingEnabled, "Start...");
