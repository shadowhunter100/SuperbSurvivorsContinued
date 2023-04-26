--[[
Superb Survivors Quest Manager is a system that simply performs actions when triggers are triggered.
Triggers and actions are defined in simple LUA tables with certains tags required depending on the trigger type or action type

Currently theese are the list of ways you can trigger actions:
---------------------TRIGGERS----------------------------

Should have a minimum of a TriggerName,ConditionType(what condtion required to trigger), and ResultActions defined

"DistanceToSquare" -> will trigger when local players gets closer then the value in the "Distance" tag to the square defined by "SquareX" & "SquareY"
"NPCDistanceToSquare" -> will trigger when the NPC defined by the "NPCName" gets closer then the value in the "Distance" tag to the square defined by "SquareX" & "SquareY"
"DistanceToNPC" -> will trigger when local players gets closer then the value in the "Distance" tag to the NPC defined by "NPCName"
"TalkToNPC" -> will trigger when local player talks with the NPC defined by the "NPCName" tag
"AttackNPC" -> will trigger when local player attacked/PVPs with the NPC defined by the "NPCName" tag
"KillNPC" -> will trigger when local player kills the NPC defined by the "NPCName" tag
"FindItem" -> will trigger when local player finds the item (puts in inventory) defined by the "ItemType" tag
"NPCtoNPCDistance" -> will Trigger when the distance between NPCNameA and NPCNameB is less then the "Distance" tag

Example:
{TriggerName="Trigger1A",Enabled=false, TriggerOnlyOnce=true, ConditionType="DistanceToSquare",SquareX=10808,SquareY=10074,Distance=2,ResultActions={ActionType="setNPCFollow",Value=true,NPCName="Spiffo"} }


Currently theese are the Actions you can run with triggers:
---------------------ACTIONS----------------------------
multiple actions are accepted, just cast into array
"NPCQuestionDialogueDialgueW" the NPC spesified in NPCName tag will speak the dialogue string array in "Value" tag, then afterwards, they will have a "!" mark above them. indicating they need answer to a question.  must have "YesResultActions" actions array given as well as "NoResultActions" tag
"NPCDialogueW" -> the NPC spesified in NPCName tag speak the dialogue provided in the Value tag. expects Value to be an array of dialoge, one line spoken at a time. The NPC will first approach the player if too far away.
you can also add ResultActions tag which will trigger after they hit the Continue button, you can use this to trigger additional dialoge windows one after the other or other actions after speaking etc.
"NPCSpeak" -> the NPC spesified in NPCName tag will  will face local player and speak the single string text provided in the Value tag.The NPC will NOT first approach the player if too far away.
"setNPCFollow" -> the NPC spesified in NPCName tag will start to follow the local player if "Value" set to true, if set to false, will stop following.
"BeginQuest" -> The string set in the Value tag will be displayed in a banner message saying "You have began Quest <Value>", You can also set "QuestDesc" tag to put text in the quest status window explaining details of the quest
"EndQuest" -> The string set in the Value tag will be displayed in a banner message saying "You have Completed Quest <Value>", this will also clear the "QuestDesc" in the quest status window explaining details of the quest
"EnableTrigger" -> the trigger identified by the Trigger name provided in the "Value" tag will be enabled.
"DisableTrigger" -> the trigger identified by the Trigger name provided in the "Value" tag will be disabled.
"NPCGivesReward" -> the NPC spesified in NPCName tag will spawn the item type defined in "ItemType" and drop those items in front of the main player, in quantity of ItemTypeQuantity tag
"setNPCWantsToTalk"  -> the NPC spesified in NPCName tag will show an exlamation mark above their head if "Value" tag set to true, if set to false it will remove the mark
"SpawnItem" -> the item defined in "ItemType" tag will be spawned on the ground on the square defined by SquareX, and SquareY Tags, in quantity of ItemTypeQuantity Tag
"SpawnPresetNPC" -> add a preset spawn NPC into the "Value" tag. exact same table structure as  preset spawns defined in "SuperSurvivorPresetSpawns.lua"
"BannerMessage" -> the text provided in "Value" tag will be shown with the tutorial/spiffo banner message
]]






--example quest called go get spiffo----- 

PresetSpawns[#PresetSpawns+1] = {Suit="Preset_Spiffo", Name = "Spiffo", X = 10806, Y = 10063, Z = 0 , Weapon = getWeapon("Base.SpearKnife"), Orders = "Standing Ground", isHostile = false};


local GetSpiffoQuestBeginActions = {
{ActionType="NPCDialogueW",Value={"great! thank you for helping","lets go"},NPCName="Spiffo"},
{ActionType="setNPCFollow",Value=true,NPCName="Spiffo"},
{ActionType="BeginQuest",Value="Get Spiffo Quest",Desc="You just need to go find a Spiffo Doll\ngood luck!..."},
{ActionType="EnableTrigger",Value="GetSpiffoMidQuestTrigger"},-- enable the other sub quest triggers
{ActionType="EnableTrigger",Value="GetSpiffoMidQuestCompleteTrigger"} -- enable the other sub quest triggers
}
 
 local GetSpiffoQuestRejectActions = {
	{ActionType="NPCDialogueW",Value={"...ok","if you change your mind let me know"}}
 }
  local GetSpiffoMidQuestLetGuyJoinActions = {
	
	{ActionType="SpawnItem",ItemType="Base.Spiffo",SquareX=10803,SquareY=10074},
	{ActionType="setNPCFollow",Value=true,NPCName="Police"},
	{ActionType="NPCDialogueW",Value={"great! ","lets go","oh by the way...","I think we might find spiffo in the bedroom"},NPCName="Police"}
 } 
 -- 10803,10074
 
  local GetSpiffoQuestFinishActions = {
	{ActionType="NPCDialogueW",Value={"Yes, we found the Spiffo", "thank you for the help "," take this as a thank you"},NPCName="Spiffo"},
	{ActionType="setNPCFollow",Value=false,NPCName="Spiffo"},
	{ActionType="setNPCFollow",Value=false,NPCName="Police"},
	{ActionType="CompleteQuest",Value="Get Spiffo Quest"},
	{ActionType="DisableTrigger",Value="GetSpiffoMidQuestTrigger"},
	{ActionType="DisableTrigger",Value="GetSpiffoMidQuestCompleteTrigger"},
	{ActionType="DisableTrigger",Value="EnableGetSpiffoQuest"},
	{ActionType="NPCGivesReward",ItemType="Base.CannedCorn",ItemTypeQuantity=5,NPCName="Spiffo"}
 } 
 
 -- added to GetSpiffoQuestTrigger1
 local GetSpiffoQuestAskActions = {
	{ActionType="NPCQuestionDialogueDialgueW", NPCName="Spiffo", Value = {"Hey There","Will you help me go find spiffo doll?"},YesResultActions=GetSpiffoQuestBeginActions,NoResultActions=GetSpiffoQuestRejectActions}
 }
 
--a sub quest NPC to spawn mid quest. same structure as the PresetSapawns in SuperSurvivorPresetSpawns.lua
local GetSpiffoMidQuestSpawnedNPC = {Suit="Police", Name = "Police", X = 10804, Y = 10078, Z = 0 , Weapon = getWeapon("Base.SpearKnife"), Orders = "Standing Ground", isHostile = false}
 
  local GetSpiffoMidQuestTriggerActions = {	
	{ActionType="SpawnPresetNPC",Value=GetSpiffoMidQuestSpawnedNPC}, -- must match the name of the 
	{ActionType="NPCQuestionDialogueDialgueW",NPCName="Police", Value = {"Hey there!","You guys looking for spiffo too i see.","I have always loved spiffo you know","ever since I was a boy","Could I join you guys?"},YesResultActions=GetSpiffoMidQuestLetGuyJoinActions,NoResultActions=GetSpiffoQuestRejectActions},		
 } 
 
 -- these triggers will be added/loadedinto the QuestManager class at startup. only the first one is enabled until the quest is accepted
local GetSpiffoQuestTrigger4 = {
	TriggerName="ApproachSpiffoTrigger",Enabled=true,TriggerOnlyOnce = true,ConditionType="DistanceToNPC",Distance=5,NPCName="Spiffo",ResultActions={ {ActionType="setNPCWantsToTalk", Value=true,NPCName="Spiffo"},{ActionType="NPCDialogueW",Value={"Hey there!","Please help!"},NPCName="Spiffo"} }
}
-- these triggers will be added/loadedinto the QuestManager class at startup. only the first one is enabled until the quest is accepted
local GetSpiffoQuestTrigger1 = {
	TriggerName="EnableGetSpiffoQuest",Enabled=true,TriggerOnlyOnce = true,ConditionType="TalkToNPC",Distance=5,NPCName="Spiffo",ResultActions=GetSpiffoQuestAskActions
}
-- sub quest trigger, if you go to area it will spawn another npc that will ask you if he can join the quest too
local GetSpiffoQuestTrigger2 = {
	TriggerName="GetSpiffoMidQuestTrigger",Enabled=false, TriggerOnlyOnce = true, ConditionType="DistanceToSquare",SquareX=10808,SquareY=10074, Distance=2,ResultActions=GetSpiffoMidQuestTriggerActions
}
--arrive at target location which is a food storeage
local GetSpiffoQuestTrigger3 = {
	TriggerName="GetSpiffoMidQuestCompleteTrigger",Enabled=false,TriggerOnlyOnce = true, ConditionType="FindItem",ItemType="Spiffo",ResultActions=GetSpiffoQuestFinishActions
}

SSQM:AddToTop(GetSpiffoQuestTrigger1)
SSQM:AddToTop(GetSpiffoQuestTrigger2)
SSQM:AddToTop(GetSpiffoQuestTrigger3)
SSQM:AddToTop(GetSpiffoQuestTrigger4)

--other ConditionType = DistanceToSquare,DistanceToNPC,TalkToNPC,AttackNPC,KillNPC,FindItem(ItemType)

--example quest called go get food----- END