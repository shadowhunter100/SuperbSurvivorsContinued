require "ISUI/ISLayoutManager"
local ThePVPButton = ISButton:derive("ThePVPButton");

local isLocalLoggingEnabled = false;

function SurvivorTogglePVP()
	if (IsoPlayer.getCoopPVP() == true) then
		getSpecificPlayer(0):Say(Get_SS_ContextMenuText("PVPDisabled"));
		IsoPlayer.setCoopPVP(false);
		getSpecificPlayer(0):getModData().PVP = false;
		PVPDefault = false;
		PVPButton:setImage(PVPTextureOff)
	elseif (IsoPlayer.getCoopPVP() == false) then
		IsoPlayer.setCoopPVP(true);
		if (ForcePVPOn ~= true) then
			getSpecificPlayer(0):getModData().PVP = true;
			PVPDefault = true;
			getSpecificPlayer(0):Say(Get_SS_ContextMenuText("PVPEnabled"));
		else
			getSpecificPlayer(0):Say(Get_SS_ContextMenuText("PVPForced"));
		end
		ForcePVPOn = false;
		PVPButton:setImage(PVPTextureOn)
	end
end

function SurvivorsCreatePVPButton()
	CreateLogLine("SuperSurvivorPVPButton", isLocalLoggingEnabled, "SurvivorsCreatePVPButton() called");
	PVPTextureOn = getTexture("media/textures/PVPOn.png");
	PVPTextureOff = getTexture("media/textures/PVPOff.png");

	PVPButton = ThePVPButton:new(getCore():getScreenWidth() - 100, getCore():getScreenHeight() - 50, 25, 25, "", nil,
		SurvivorTogglePVP);
	PVPButton:setImage(PVPTextureOff);
	PVPButton:setVisible(true);
	PVPButton:setEnable(true);
	--PVPButton.textureColor.r = 255;
	PVPButton:addToUIManager();
end
