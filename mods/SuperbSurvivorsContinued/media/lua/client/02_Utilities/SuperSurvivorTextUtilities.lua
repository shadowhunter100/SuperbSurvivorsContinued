--- Cows: seems to be used to identify actions, orders, and roles when context menu or panel window is open.
---@param text any
---@return unknown
function getActionText(text)
  return getText("IGUI_SS_" .. text)
end

--- WIP - Cows: This is a terrible function name... the return value doesn't really seem to make sense if it is looking at Moodles...
--- WIP - Cows: Also, "getName()" is also the name of a core function... so this should be replaced or renamed when possible.
---@param name any
---@return unknown
function getName(name)
  return getText("Moodles_SS_" .. name)
end

-- WIP - Cows: getContextMenuText() is a globl function... should consider updating the casing to reflect that.
---@param text any
---@return unknown
function getContextMenuText(text)
	return getText("ContextMenu_SS_" .. text)
end

--- Cows: "GetJobText" was cut-pasted here from "SuperSurvivorsContextMenu.lua" to address a load order issue...
---@param text any
---@return unknown
function GetJobText(text)
	return getContextMenuText("Job_" .. text)
end