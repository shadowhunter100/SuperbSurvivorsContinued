local isLocalLoggingEnabled = false;

-- WIP - Cows: This was made so the 4 arrow keys can be used to call the assigned orders in SuperSurvivorKeyBindAction() ...
local function superSurvivorsHotKeyOrder(index)
    local order, isListening;
    if (index <= #Orders) then
        order = Orders[index];
        isListening = false;
    else --single
        order = Orders[(index - #Orders)];
        isListening = true;
    end
    local myGroup = SSM:Get(0):getGroup()
    if (myGroup) then
        local myMembers = myGroup:getMembersInRange(SSM:Get(0):Get(), 25, isListening);
        for i = 1, #myMembers do
            SurvivorOrder(nil, myMembers[i].player, order, nil)
        end
    end
end

-- WIP - Cows: Renamed from "supersurvivortemp()" to "SuperSurvivorKeyBindAction()"
function SuperSurvivorKeyBindAction(keyNum)
    local isLocalFunctionLoggingEnabled = false;
    CreateLogLine("SuperSurvivorsHotKeys", isLocalFunctionLoggingEnabled, "function: SuperSurvivorKeyBindAction called");
    local playerSurvivor = getSpecificPlayer(0);

    if (playerSurvivor) then
        -- playerSurvivor:Say(tostring(keyNum));

        if (keyNum == getCore():getKey("Spawn Wild Survivor")) then -- the NumPad enter key
            local activeNpcs = Get_SS_Alive_Count();
            if (activeNpcs < Limit_Npcs_Spawn) then
                CreateLogLine("SuperSurvivorsHotKeys", isLocalFunctionLoggingEnabled, "Spawning NPC");
                CreateLogLine("SuperSurvivorsHotKeys", isLocalFunctionLoggingEnabled, "activeNpcs: " .. tostring(activeNpcs));
                CreateLogLine("SuperSurvivorsHotKeys", isLocalFunctionLoggingEnabled, "Limit_Npcs_Spawn: " .. tostring(Limit_Npcs_Spawn));
                local ss = SuperSurvivorSpawnNpc(playerSurvivor:getCurrentSquare());
                local name = ss:getName();
                ss.player:getModData().isRobber = false;
                ss:setName("Spawned " .. name);
            else
                CreateLogLine("SuperSurvivorsHotKeys", isLocalFunctionLoggingEnabled, "activeNpcs limit reached, no spawn.");
            end
        elseif (keyNum == getCore():getKey("Raise Follow Distance")) then
            if (GFollowDistance < 50) then
                GFollowDistance = GFollowDistance + 1;
            end
            playerSurvivor:Say("Spread out more(" .. tostring(GFollowDistance) .. ")");
        elseif (keyNum == getCore():getKey("Lower Follow Distance")) then
            if (GFollowDistance > 0) then
                GFollowDistance = GFollowDistance - 1;
            end
            playerSurvivor:Say("Stay closer(" .. tostring(GFollowDistance) .. ")");
        elseif (keyNum == getCore():getKey("Call Closest Non-Group Member")) then
            local mySS = SSM:Get(0);
            local SS = SSM:GetClosestNonParty();

            if (SS) then
                mySS:Speak(Get_SS_Dialogue("HeyYou"))
                SS:getTaskManager():AddToTop(ListenTask:new(SS, mySS:Get(), false))
            end
        elseif (keyNum == getCore():getKey("Toggle Group Window")) then
            window_super_survivors_visibility()
        elseif (keyNum == getCore():getKey("Ask Closest Group Member to Follow")) then
            local mySS = SSM:Get(0)
            if (mySS:getGroupID() ~= nil) then
                local myGroup = SSGM:GetGroupById(mySS:getGroupID())
                if (myGroup ~= nil) then
                    local member = myGroup:getClosestMember(nil, mySS:Get())
                    if (member) then
                        mySS:Get():Say(Get_SS_UIActionText("ComeWithMe_Before") ..
                            member:Get():getForname() .. Get_SS_UIActionText("ComeWithMe_After"))
                        member:getTaskManager():clear()
                        member:getTaskManager():AddToTop(FollowTask:new(member, mySS:Get()))
                    else
                        CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "getClosestMember returned nil");
                    end
                else
                    CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "no group for player found");
                end
            end
        elseif (keyNum == getCore():getKey("Call Closest Group Member")) then -- t key
            local mySS = SSM:Get(0)
            if (mySS:getGroupID() ~= nil) then
                local myGroup = SSGM:GetGroupById(mySS:getGroupID())
                if (myGroup ~= nil) then
                    local member = myGroup:getClosestMember(nil, mySS:Get())
                    if (member) then
                        mySS:Get():Say(member:Get():getForname() .. ", come here.")
                        member:getTaskManager():AddToTop(ListenTask:new(member, mySS:Get(), false))
                    else
                        CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "getClosestMember returned nil");
                    end
                else
                    CreateLogLine("SuperSurvivorsMod", isLocalFunctionLoggingEnabled, "no group for player found");
                end
            end
        elseif (keyNum == getCore():getKey("SSHotkey_1")) then -- Up key, Order "Follow"
            superSurvivorsHotKeyOrder(6);
        elseif (keyNum == getCore():getKey("SSHotkey_2")) then -- Down key, Order "Stop"
            superSurvivorsHotKeyOrder(19);
        elseif (keyNum == getCore():getKey("SSHotkey_3")) then -- Left key, Order "Stand Ground"
            superSurvivorsHotKeyOrder(18);
        elseif (keyNum == getCore():getKey("SSHotkey_4")) then -- Right key, Order "Barricade"
            superSurvivorsHotKeyOrder(1);
        elseif (keyNum == getCore():getKey("NumPad_5")) then
            LogSSDebugInfo();
        end
    end
end

Events.OnKeyPressed.Add(SuperSurvivorKeyBindAction);
