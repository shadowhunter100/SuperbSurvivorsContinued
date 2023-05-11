--[[
    -- WIP - Cows: The Game Options is likely conflicting with "Expanded Helicopter Events"
    https://steamcommunity.com/sharedfiles/filedetails/?id=2458631365&searchtext=exapanded+helicopter
]]
-- console.txt message below
-- ERROR: General     , 1683136409143> ExceptionLogger.logException> Exception thrown java.lang.IllegalStateException at UIManager.update line:685.

local isLocalLoggingEnabled = false;

local function getOptionText(text)
    return getText("UI_Option_SS_" .. text)
end

local function saveSurvivorOptions()
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: saveSurvivorOptions() called");
    local writeFile = getFileWriter("SurvivorOptions.lua", true, false)

    for index, value in pairs(SuperSurvivorOptions) do
        writeFile:write(tostring(index) .. " " .. tostring(value) .. "\r\n");
    end
    writeFile:close();
end

local function superSurvivorSetOption(option, ToValue)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: superSurvivorSetOption() called");
    SuperSurvivorOptions[option] = ToValue
    saveSurvivorOptions()
end

local GameOption = ISBaseObject:derive("GameOption");

function GameOption:new(name, control, arg1, arg2)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:new() called");
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.control = control
    o.arg1 = arg1
    o.arg2 = arg2
    if control.isCombobox then
        control.onChange = self.onChangeComboBox
        control.target = o
    end
    if control.isTickBox then
        control.changeOptionMethod = self.onChangeTickBox
        control.changeOptionTarget = o
    end
    if control.isSlider then
        control.targetFunc = self.onChangeVolumeControl
        control.target = o
    end
    return o
end

function GameOption:toUI()
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:toUI() called");
end

function GameOption:apply()
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:apply() called");
end

function GameOption:resetLua()
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:resetLua() called");
    MainOptions.instance.resetLua = true
end

function GameOption:restartRequired(oldValue, newValue)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:restartRequired() called");
    if getCore():getOptionOnStartup(self.name) == nil then
        getCore():setOptionOnStartup(self.name, oldValue)
    end
    if getCore():getOptionOnStartup(self.name) == newValue then
        return
    end
    MainOptions.instance.restartRequired = true
end

function GameOption:onChangeComboBox(box)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled,
        "function: GameOption:onChangeComboBox() called");
    self.gameOptions:onChange(self)
    if self.onChange then
        self:onChange(box)
    end
end

function GameOption:onChangeTickBox(index, selected)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:onChangeTickBox() called");
    self.gameOptions:onChange(self)
    if self.onChange then
        self:onChange(index, selected)
    end
end

function GameOption:onChangeVolumeControl(control, volume)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled,
        "function: GameOption:onChangeVolumeControl() called");
    self.gameOptions:onChange(self)
    if self.onChange then
        self:onChange(control, volume)
    end
end

--TODO: separate UI into sections (spawn , raiders , hotkeys)
function MainOptions:addCustomCombo(id, splitpoint, y, comboWidth, label, options, description)
    CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled, "function: GameOption:addCustomCombo() called");
    local spawnrateCombo = self:addCombo(splitpoint, y, comboWidth, 20, label, options, 1)
    if description then
        spawnrateCombo:setToolTipMap({ defaultTooltip = description });
    end

    local gameOption = GameOption:new(id, spawnrateCombo)
    function gameOption.toUI(self)
        local box = self.control
        box.selected = SuperSurvivorGetOption(id)
    end

    function gameOption.apply(self)
        local box = self.control
        if box.options[box.selected] then
            superSurvivorSetOption(id, box.selected)
            SuperSurvivorsRefreshSettings()
        else
            CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled,
                "function: gameOption:apply() called and error could not set " .. id .. " option");
        end
    end

    function gameOption:onChange(box)
        CreateLogLine("SuperSurvivorsMainMenuOptions", isLocalLoggingEnabled,
            "function: gameOption:addCustomCombo() called and changed to: " .. tostring(box.selected));
    end

    self.gameOptions:add(gameOption)
end

-- ---------------------------------------- --
-- Context options to clean up code further --
-- You can use these functions to return    --
-- Basic answers to. 						--
-- HashTagLetsKeepCodeClean					--
-- ---------------------------------------- --

function NPC_Options_OffOn() -- Because Order of position Matters of if 'Off' and 'On' is first in the options in question
    return { getOptionText("Off"), getOptionText("On") }
end

function NPC_Options_ZeroToOneHundred()
    return { "0%", "1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%", "10%", "11%", "12%", "13%", "14%", "15%",
        "16%", "17%", "18%", "19%", "20%", "21%", "22%", "23%", "24%", "25%", "26%", "27%", "28%", "29%", "30%",
        "31%", "32%", "33%", "34%", "35%", "36%", "37%", "38%", "39%", "40%", "41%", "42%", "43%", "44%", "45%",
        "46%", "47%", "48%", "49%", "50%", "51%", "52%", "53%", "54%", "55%", "56%", "57%", "58%", "59%", "60%",
        "61%", "62%", "63%", "64%", "65%", "66%", "67%", "68%", "69%", "70%", "71%", "72%", "73%", "74%", "75%",
        "76%", "77%", "78%", "79%", "80%", "81%", "82%", "83%", "84%", "85%", "86%", "87%", "88%", "89%", "90%",
        "91%", "92%", "93%", "94%", "95%", "96%", "97%", "98%", "99%", "100%" }
end

function NPC_Options_ZeroToOneHundredAbsolute()
    return { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18",
        "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36",
        "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54",
        "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72",
        "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
        "91", "92", "93", "94", "95", "96", "97", "98", "99", "100" }
end

-- store the original MainOptions:create() method in a variable
local oldCreate = MainOptions.create

-- overwrite it
function MainOptions:create()
    oldCreate(self)
    for _, keyTextElement in pairs(MainOptions.keyText) do
        repeat
            -- if keyTextElement is nil or doesn't have a ISLabel, break out of the
            -- "repeat ... until true"  loop, and continue with the "for .. do ... end"
            -- loop
            if not keyTextElement or not keyTextElement.txt then break end
            local label = keyTextElement.txt -- our ISLabel item is stored in keyTextElement.txt
            -- We need to do a few things here to prep the new entries.
            -- 1) We wont have a proper translation, and the translation will be set to
            --    "UI_optionscreen_binding_Equip/Unequip Pistol", which will look funny on the
            --    options screen, so we need to fix
            -- 2) the new translation doesn't properly adjust the x position and width, so we need to
            --    manually adjust these

            if label.name == "Call Closest Group Member" then
                label:setTranslation(getOptionText("CallClosestGroupMember"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "Call Closest Non-Group Member" then
                label:setTranslation(getOptionText("CallClosestNonGroupMember"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "Ask Closest Group Member to Follow" then
                label:setTranslation(getOptionText("AskClosestGroupMembertoFollow"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "Spawn Wild Survivor" then
                label:setTranslation(getOptionText("SpawnWildSurvivor"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "Toggle Group Window" then
                label:setTranslation(getOptionText("ToggleGroupWindow"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "Lower Follow Distance" then
                label:setTranslation(getOptionText("LowerFollowDistance"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "Raise Follow Distance" then
                label:setTranslation(getOptionText("RaiseFollowDistance"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "SSHotkey_1" then
                label:setTranslation(getOptionText("SShotkey1"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "SSHotkey_2" then
                label:setTranslation(getOptionText("SShotkey2"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "SSHotkey_3" then
                label:setTranslation(getOptionText("SShotkey3"))
                label:setX(label.x)
                label:setWidth(label.width)
            elseif label.name == "SSHotkey_4" then
                label:setTranslation(getOptionText("SShotkey4"))
                label:setX(label.x)
                label:setWidth(label.width)
            end
        until true
    end

    ----- Survivor options in Game Options -----
    local spacing = 3
    local spacing2x = 20
    local spacing4x = 30

    self:addPage("Superb Survivors")
    self.addY = 0

    local label
    local y = 5
    local comboWidth = 300
    local splitpoint = self:getWidth() / 3;
    -------------------------------------------

    y = y + spacing2x

    local options =
    {
        getOptionText("Off"),
        getOptionText("UltraLow"),
        getOptionText("ExtremelyLow"),
        getOptionText("VeryLow"),
        getOptionText("Low"),
        getOptionText("SlightlyLower"),
        getOptionText("Normal"),
        getOptionText("SlightlyHigher"),
        getOptionText("High"),
        getOptionText("VeryHigh"),
        getOptionText("ExtremelyHigh"),
        getOptionText("UltraHigh")
    }
    self:addCustomCombo('SpawnRate', splitpoint, y, comboWidth, getOptionText("SurvivorSpawnRate"), options,
        getOptionText("SurvivorSpawnRateDesc"))

    y = y + spacing4x

    local options =
    {
        getOptionText("AltSpawnOff"),
        getOptionText("UpTo1"), getOptionText("UpTo2"),
        getOptionText("UpTo3"), getOptionText("UpTo4"),
        getOptionText("UpTo5"), getOptionText("UpTo6")
    }
    self:addCustomCombo('AltSpawn', splitpoint, y, comboWidth, getOptionText("AltSpawn"), options,
        getOptionText("AltSpawnDesc"))

    local options = NPC_Options_ZeroToOneHundred()
    self:addCustomCombo('AltSpawnPercent', splitpoint, y, comboWidth, getOptionText("AltSpawnPercent"), options,
        getOptionText("AltSpawnPercentDesc"))

    local options =
    {
        getOptionText("AltSpawnAmount_1"),
        getOptionText("AltSpawnAmount_2"),
        getOptionText("AltSpawnAmount_3"),
        getOptionText("AltSpawnAmount_4"),
        getOptionText("AltSpawnAmount_5"),
        getOptionText("AltSpawnAmount_6")
    }
    self:addCustomCombo('AltSpawnAmount', splitpoint, y, comboWidth, getOptionText("AltSpawnAmount"), options,
        getOptionText("AltSpawnAmountDesc"))


    y = y + spacing4x


    local options =
    {
        getOptionText("Every5Days"), getOptionText("Every10Days"), getOptionText("Every15Days"),
        getOptionText("Every20Days"),
        getOptionText("Every25Days"), getOptionText("Every30Days"), getOptionText("Every35Days"),
        getOptionText("Every40Days"),
        getOptionText("Every45Days"), getOptionText("Every50Days"), getOptionText("Every55Days"),
        getOptionText("Every60Days"),
        getOptionText("Every65Days"), getOptionText("Every70Days"), getOptionText("Every75Days"),
        getOptionText("Every80Days"),
        getOptionText("Every85Days"), getOptionText("Every90Days"), getOptionText("Every95Days"),
        getOptionText("Every100Days"),
        getOptionText("EveryDay"), getOptionText("EveryHour"), getOptionText("Every10Minutes")
    }
    self:addCustomCombo('RaidersAtLeastHours', splitpoint, y, comboWidth, getOptionText("RaidersGuaranteed"), options,
        getOptionText("RaidersGuaranteedDesc"))

    local options =
    {
        getOptionText("StartImmediately"), getOptionText("AfterDay1"),
        getOptionText("AfterDay5"), getOptionText("AfterDay10"),
        getOptionText("AfterDay15"), getOptionText("AfterDay20"),
        getOptionText("AfterDay25"), getOptionText("AfterDay30"),
        getOptionText("AfterDay35"), getOptionText("AfterDay40"),
        getOptionText("AfterDay45"), getOptionText("AfterDay50"),
        getOptionText("AfterDay55"), getOptionText("AfterDay60"),
        getOptionText("AfterDay65"), getOptionText("AfterDay70"),
        getOptionText("AfterDay75"), getOptionText("AfterDay80"),
        getOptionText("AfterDay85"), getOptionText("AfterDay90"),
        getOptionText("AfterDay95"), getOptionText("Never")
    }
    self:addCustomCombo('RaidersAfterHours', splitpoint, y, comboWidth, getOptionText("RaidersAfterHours"), options,
        getOptionText("RaidersAfterHoursDesc"))

    local options =
    {
        getOptionText("VeryHigh"), getOptionText("High"),
        getOptionText("Normal"),
        getOptionText("Low"), getOptionText("VeryLow")
    }
    self:addCustomCombo('RaidersChance', splitpoint, y, comboWidth, getOptionText("RaidersChance"), options,
        getOptionText("RaidersChanceDesc"))

    y = y + spacing4x

    local options = NPC_Options_ZeroToOneHundred()
    self:addCustomCombo('WepSpawnRate', splitpoint, y, comboWidth, getOptionText("WepSpawnRate"), options,
        getOptionText("WepSpawnRateDesc"))

    local options = NPC_Options_ZeroToOneHundred()
    self:addCustomCombo('GunSpawnRate', splitpoint, y, comboWidth, getOptionText("ChancetoSpawnWithGun"), options,
        getOptionText("ChancetoSpawnWithGunDesc"))

    y = y + spacing4x

    local options = { getOptionText("Off"), getOptionText("On") }
    self:addCustomCombo('ForcePVP', splitpoint, y, comboWidth, getOptionText("PVPInfoBar"), options,
        getOptionText("PVPInfoBarDesc"))

    local options = NPC_Options_ZeroToOneHundred()
    self:addCustomCombo('HostileSpawnRate', splitpoint, y, comboWidth, getOptionText("ChancetobeHostile"), options,
        getOptionText("ChancetobeHostileDesc"))


    local options = NPC_Options_ZeroToOneHundred() -- Hostile Over Time Odds
    self:addCustomCombo('MaxHostileSpawnRate', splitpoint, y, comboWidth, getOptionText("MaxHostileSpawnRate"),
        options, getOptionText("MaxHostileSpawnRateDesc"))

    y = y + spacing4x

    local options = NPC_Options_OffOn()
    self:addCustomCombo('Option_Display_Survivor_Names', splitpoint, y, comboWidth,
        getOptionText("Display_Survivor_Names"), options, getOptionText("Display_Survivor_NamesDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('Option_Display_Hostile_Color', splitpoint, y, comboWidth,
        getOptionText("Display_Hostile_Color"), options, getOptionText("Display_Hostile_ColorDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('RoleplayMessage', splitpoint, y, comboWidth, getOptionText("RoleplayMessage"), options,
        getOptionText("RoleplayMessageDesc"))

    y = y + spacing4x

    local options = NPC_Options_OffOn()
    self:addCustomCombo('WifeSpawn', splitpoint, y, comboWidth, getOptionText("WifeSpawn"), options,
        getOptionText("WifeSpawnDesc"))

    y = y + spacing4x

    local options = { "3", "4", "5", "6", "7", "8", "9", "10" }
    self:addCustomCombo('FollowDistance', splitpoint, y, comboWidth, getOptionText("FollowGlobalRange"), options,
        getOptionText("FollowGlobalRangeDesc"))

    local options = NPC_Options_ZeroToOneHundredAbsolute()
    self:addCustomCombo('Panic_Distance', splitpoint, y, comboWidth, getOptionText("Panic_Distance"), options,
        getOptionText("Panic_DistanceDesc"))

    y = y + spacing4x

    local options =
    {
        getOptionText("DesperateforHumanContact"), getOptionText("VeryFriendly"),
        getOptionText("Friendly"), getOptionText("Normal"),
        getOptionText("Mean"), getOptionText("VeryMean")
    }
    self:addCustomCombo('SurvivorFriendliness', splitpoint, y, comboWidth, getOptionText("SurvivorFriendliness"),
        options, getOptionText("SurvivorFriendlinessDesc"))

    local options =
    {
        getOptionText("Cowardly"), getOptionText("Normal"),
        getOptionText("Brave"), getOptionText("VeryBrave"),
        "RAMBO!", "Suicidal!"
    }
    self:addCustomCombo('Bravery', splitpoint, y, comboWidth, getOptionText("SurvivorBravery"), options,
        getOptionText("SurvivorBraveryDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('NoPreSetSpawn', splitpoint, y, comboWidth, getOptionText("NoPreSetSpawn"), options,
        getOptionText("NoPreSetSpawnDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('NoIdleChatter', splitpoint, y, comboWidth, "No Idle Chatter", options,
        "Prevent NPCs from randomly chattering on about things while they follow you among other times.")

    y = y + spacing4x

    local options = NPC_Options_OffOn()
    self:addCustomCombo('InfinitAmmo', splitpoint, y, comboWidth, getOptionText("InfinitAmmo"), options,
        getOptionText("InfinitAmmoDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('FindWork', splitpoint, y, comboWidth, getOptionText("FindWork"), options,
        getOptionText("FindWorkDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('SurvivorHunger', splitpoint, y, comboWidth, getOptionText("SurvivorHunger"), options,
        getOptionText("SurvivorHungerDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('SafeBase', splitpoint, y, comboWidth, getOptionText("SafeBase"), options,
        getOptionText("SafeBaseDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('SurvivorBases', splitpoint, y, comboWidth, getOptionText("SurvivorBases"), options,
        getOptionText("SurvivorBasesDesc"))

    y = y + spacing4x

    local options = SSHotKeyOptions
    self:addCustomCombo('SSHotkey1', splitpoint, y, comboWidth, getOptionText("hotkey1"), options,
        getOptionText("hotkeyDesc"))

    local options = SSHotKeyOptions
    self:addCustomCombo('SSHotkey2', splitpoint, y, comboWidth, getOptionText("hotkey2"), options,
        getOptionText("hotkeyDesc"))

    local options = SSHotKeyOptions
    self:addCustomCombo('SSHotkey3', splitpoint, y, comboWidth, getOptionText("hotkey3"), options,
        getOptionText("hotkeyDesc"))

    local options = SSHotKeyOptions
    self:addCustomCombo('SSHotkey4', splitpoint, y, comboWidth, getOptionText("hotkey4"), options,
        getOptionText("hotkeyDesc"))

    y = y + spacing4x

    local options = NPC_Options_OffOn()
    self:addCustomCombo('DebugOptions', splitpoint, y, comboWidth, getOptionText("DebugOptions"), options,
        getOptionText("DebugOptionsDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('DebugSay', splitpoint, y, comboWidth, getOptionText("DebugSay"), options,
        getOptionText("DebugSayDesc"))

    local options = NPC_Options_ZeroToOneHundredAbsolute()
    self:addCustomCombo('DebugSay_Distance', splitpoint, y, comboWidth, getOptionText("DebugSay_Distance"), options,
        getOptionText("DebugSay_DistanceDesc"))

    local options = NPC_Options_OffOn()
    self:addCustomCombo('WarningMSG', splitpoint, y, comboWidth, getOptionText("WarningMSG"), options,
        getOptionText("WarningMSGDesc"))

    -- Controls the rest of the menu, don't put options under this line you're reading --
    self.addY = self.addY + MainOptions.translatorPane:getHeight() + 22;

    self.mainPanel:setScrollHeight(y + self.addY + 20)
end
