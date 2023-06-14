local isLocalLoggingEnabled = false;

-- WIP - Cows: This was made so the 4 arrow keys can be used to call the assigned orders in SuperSurvivorKeyBindAction() ...
local function superSurvivorsHotKeyOrder(index)
    local order, isListening;
    --
    if (index <= #Orders) then
        order = Orders[index];
        isListening = false;
    else --single
        order = Orders[(index - #Orders)];
        isListening = true;
    end

    local myGroup = SSM:Get(0):getGroup();
    --
    if (myGroup) then
        local myMembers = myGroup:getMembersInRange(SSM:Get(0):Get(), 25, isListening);
        --
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
    --
    if (playerSurvivor and playerSurvivor:isAlive()) then
        --
        if (keyNum == 156) then -- the NumPad enter key
            local activeNpcs = Get_SS_Alive_Count();
            --
            if (activeNpcs < Limit_Npcs_Spawn) then
                local ss = SuperSurvivorSpawnNpcAtSquare(playerSurvivor:getCurrentSquare());
                -- Check if superb survivor spawned successfully
                if (ss) then
                    local name = ss:getName();
                    ss.player:getModData().isRobber = false;
                    ss:setName("Spawned " .. name);
                end
            else
                playerSurvivor:Say("activeNpcs limit reached, no spawn.");
            end
        elseif (keyNum == 78) then  -- "numpad +" key
            if (GFollowDistance < 50) then
                GFollowDistance = GFollowDistance + 1;
            end
            playerSurvivor:Say("Spread out more(" .. tostring(GFollowDistance) .. ")");
        elseif (keyNum == 74) then -- "numpad -" key
            if (GFollowDistance > 0) then
                GFollowDistance = GFollowDistance - 1;
            end
            playerSurvivor:Say("Stay closer(" .. tostring(GFollowDistance) .. ")");
        elseif (keyNum == 181) then --  "numpad /" key
            local mySS = SSM:Get(0);
            local SS = SSM:GetClosestNonParty();
            --
            if (SS) then
                mySS:Speak(Get_SS_Dialogue("HeyYou"))
                SS:getTaskManager():AddToTop(ListenTask:new(SS, mySS:Get(), false));
            end
        elseif (keyNum == 201) then -- "Page Up" key
            window_super_survivors_visibility();
        elseif (keyNum == 209) then -- "Page Down" key
            local mySS = SSM:Get(0);
            --
            if (mySS:getGroupID() ~= nil) then
                local myGroup = SSGM:GetGroupById(mySS:getGroupID());
                --
                if (myGroup ~= nil) then
                    local member = myGroup:getClosestMember(nil, mySS:Get());
                    --
                    if (member) then
                        mySS:Get():Say(Get_SS_UIActionText("ComeWithMe_Before") ..
                            member:Get():getForname() .. Get_SS_UIActionText("ComeWithMe_After")
                        );
                        member:getTaskManager():clear();
                        member:getTaskManager():AddToTop(FollowTask:new(member, mySS:Get()));
                    else
                        playerSurvivor:Say("getClosestMember returned nil");
                    end
                else
                    playerSurvivor:Say("no group for player found");
                end
            end
        elseif (keyNum == 55) then -- "numpad *" key
            local mySS = SSM:Get(0);
            --
            if (mySS:getGroupID() ~= nil) then
                local myGroup = SSGM:GetGroupById(mySS:getGroupID());
                --
                if (myGroup ~= nil) then
                    local member = myGroup:getClosestMember(nil, mySS:Get());
                    --
                    if (member) then
                        mySS:Get():Say(member:Get():getForname() .. ", come here.");
                        member:getTaskManager():AddToTop(ListenTask:new(member, mySS:Get(), false));
                    else
                        playerSurvivor:Say("getClosestMember returned nil");
                    end
                end
            end
        elseif (keyNum == 200) then -- Up key, Order "Follow"
            superSurvivorsHotKeyOrder(6);
        elseif (keyNum == 208) then -- Down key, Order "Stop"
            superSurvivorsHotKeyOrder(19);
        elseif (keyNum == 203) then -- Left key, Order "Stand Ground"
            superSurvivorsHotKeyOrder(18);
        elseif (keyNum == 205) then -- Right key, Order "Barricade"
            superSurvivorsHotKeyOrder(1);
        elseif (keyNum == 76) then -- Numpad 5 key, log debug info.
            LogSSDebugInfo();
        end
    end
end

local function ss_HotKeyPress()
    Events.OnKeyPressed.Add(SuperSurvivorKeyBindAction);
end

Events.OnGameStart.Add(ss_HotKeyPress); -- Cows: This is to prevent the function from being called BEFORE the game starts.
