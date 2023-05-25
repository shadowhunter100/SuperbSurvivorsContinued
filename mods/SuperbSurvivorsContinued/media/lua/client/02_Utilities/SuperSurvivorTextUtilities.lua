--- Cows: seems to be used to identify actions, orders, and roles when context menu or panel window is open.
---@param text any
---@return unknown
function Get_SS_UIActionText(text)
  return getText("IGUI_SS_" .. text)
end

--- WIP - Cows: Formerly "getName()", which has been renamed to "Get_SS_Name" because "getName() is also the name of a core function... 
---@param name any
---@return unknown
function Get_SS_Name(name)
  return getText("Moodles_SS_" .. name)
end

-- WIP - Cows: Frankly, I don't udnerstand why "ContextMenus_SS_" prefix is needed.
---@param text any
---@return unknown
function Get_SS_ContextMenuText(text)
	return getText("ContextMenu_SS_" .. text)
end

--- Cows: "Get_SS_JobText" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
---@param text any
---@return unknown
function Get_SS_JobText(text)
	return Get_SS_ContextMenuText("Job_" .. text)
end

function Get_SS_Dialogue(text)
  return getText("GameSound_Dialogues_SS_" .. text)
end