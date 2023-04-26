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


--any hilltop citizen will approach you and say boss wants to speak with you
local ApproachGuardTrigger = {
	TriggerName="ApproachGuardTrigger",Enabled=true,TriggerOnlyOnce = true,ConditionType="DistanceToNPC",Distance=5,NPCName="Hilltop Citizen",ResultActions={ {ActionType="setNPCWantsToTalk", Value=true,NPCName="Hilltop Citizen"},{ActionType="NPCDialogueW",Value="Hey, I think the boss wants to talk to you. Said it was important. I’d go talk to em’.",NPCName="Hilltop Citizen"} }
}
--if you get 9 squares close govenor will show "!" and say over hear
local ApproachLeaderTrigger = {
	TriggerName="ApproachLeaderTrigger",Enabled=true,TriggerOnlyOnce = true,ConditionType="DistanceToNPC",Distance=9,NPCName="Hilltop Governor",ResultActions={ {ActionType="setNPCWantsToTalk", Value=true,NPCName="Hilltop Governor"},{ActionType="NPCSpeak",Value="Hey! Over here!",NPCName="Hilltop Governor"} }
}

--then when you get 5 squares close he will approach and speak
local SpeakLeaderTrigger = {
	TriggerName="SpeakLeaderTrigger",Enabled=true,TriggerOnlyOnce = true,ConditionType="DistanceToNPC",Distance=5,NPCName="Hilltop Governor",ResultActions={{ActionType="NPCQuestionDialogueDialgueW",Value="Hey there, friend. New here, Im assuming? I run things around here more or less, and Ill be honest with you: Theres a lot to be done around here. Weve all got our hands full contributing to keeping this place up and running, and weve got a lot of problems adding up. We need somebody that knows how to handle themselves out there to lend a hand, and you sure look the part. Tell you what, if youre willing to lend us a hand, Ill make it worth your while.",NPCName="Hilltop Governor",
		YesResultActions={{ActionType="DisableTrigger",Value="SpeakLeaderTrigger"},{ActionType="EnableTrigger",Value="FinisTrigger"},{ActionType="EnableTrigger",Value="SpawnScoutTrigger"},{ActionType="NPCDialogueW",Value="That’s a relief to hear. Everyone around here’s concerned over one of our missing scouts. I sent them up the road leading north past the gas station at the crossroads east of here to look for survivors, but my gut says they ran into a snag and didn’t get very far. Think you can take a peek around that area, see if they need an escort back? I’m sure a few deadheads won’t give you any trouble, given that you made it here by yourself.\n just talk to me if you need anything more",NPCName="Hilltop Governor",ResultActions={{ActionType="BeginQuest",Value="Hilltop Rescue Quest",Desc="Speak to the Governor for details"}}},{ActionType="EnableTrigger",Value="TalkToLeaderTrigger"}},
		NoResultActions={{ActionType="setNPCWantsToTalk", Value=false,NPCName="Hilltop Governor"},{ActionType="NPCDialogue", Value="Well, that’s a shame. If you change your mind I’ll be here",NPCName="Hilltop Governor"},{ActionType="EnableTrigger",Value="TalkToLeaderTrigger"}} }  
	}
}
--talking to him after accepting the quests gives additional details 
local TalkToLeaderTrigger = {
	TriggerName="TalkToLeaderTrigger",Enabled=true,TriggerOnlyOnce = false,ConditionType="TalkToNPC",NPCName="Hilltop Governor",ResultActions={ {ActionType="NPCQuestionDialogueDialgueW",Value="What, you need directions? Walk out our gates and take a left once you hit the road, just follow it till you reach a gas station. I sent our scout up the road to the north of there. He’s only been gone a little while and hasn’t radioed back, so I’m assuming deadheads gave him some trouble in that neighborhood.\nSo will you help?", NPCName="Hilltop Governor",
	NoResultActions={{ActionType="setNPCWantsToTalk", Value=false,NPCName="Hilltop Governor"},{ActionType="NPCDialogue", Value="Well, that’s a shame. If you change your mind I’ll be here",NPCName="Hilltop Governor"}},
	YesResultActions={{ActionType="BeginQuest",Value="Hilltop Rescue Quest",Desc="Speak to the Governor for details"},{ActionType="EnableTrigger",Value="FinisTrigger"}}
	} }
}

-- npc scout located at 11385,8317
--spawns the scout NPC when you get 60 square distance to spawn point, disabled by default, accepting quest from govenor enables this trigger
local SpawnScoutTrigger = {
	TriggerName="SpawnScoutTrigger",Enabled=false, TriggerOnlyOnce=true, ConditionType="DistanceToSquare",SquareX=11385,SquareY=8317, Distance=60,ResultActions={{ActionType="SpawnPresetNPC",Value={NoParty = true,  Name = "Hilltop Scout", X = 11385, Y = 8317, Z = 0 , Weapon = "Base.HuntingKnife", Orders = "Standing Ground", isHostile = false, AIMode = "Stand Ground"}}}
}

-- when close to scout by 5 squares he will approach and speak with you, will follow you after you close dialoge
local ApproachScoutTrigger = {
	TriggerName="ApproachScoutTrigger",Enabled=true,TriggerOnlyOnce = true,ConditionType="DistanceToNPC",Distance=5,NPCName="Hilltop Scout",ResultActions={ {ActionType="setNPCWantsToTalk", Value=true,NPCName="Hilltop Scout"},{ActionType="NPCDialogueW",Value="Who’re you?! You’d better back the hell off, I don’t have any –\n Wait, the boss sent you to find me? Oh, thank fucking God. I was poking through the gas station for supplies, not what I was told to do, I know, and a gunshot from Muldraugh lead a buncha dead shitheads towards me, lost my weapon getting away from em’. Look, I’m willing to just cut my losses and head back. I’ll explain it all to the boss myself, can we get going?",NPCName="Hilltop Scout",
	ResultActions={ {ActionType="setNPCFollow",Value=true,NPCName="Hilltop Scout"},{ActionType="EnableTrigger",Value="ApproachScoutTrigger2"} }} }
}
-- in case scout gets chased away from you, approching him again after will always make him re-follow you
local ApproachScoutTrigger2 = {
	TriggerName="ApproachScoutTrigger2",Enabled=false,TriggerOnlyOnce = false,ConditionType="DistanceToNPC",Distance=5,NPCName="Hilltop Scout",ResultActions={ {ActionType="setNPCFollow",Value=true,NPCName="Hilltop Scout"}  }  
}
--when scout and govenor are close to each other make quest complete and govenor gives reward of axe
local FinisTrigger = {
	TriggerName="FinisTrigger",Enabled=false,TriggerOnlyOnce = true,ConditionType="NPCtoNPCDistance",Distance=5,NPCNameA="Hilltop Scout",NPCNameB="Hilltop Governor",ResultActions={ {ActionType="setNPCWantsToTalk", Value=true,NPCName="Hilltop Governor"},{ActionType="NPCDialogueW",Value="Nice work, friend. Appreciate your help. If you need to rest up here you’re welcome to anytime, and take this. It’s one of our better picks from the armory.",NPCName="Hilltop Governor",
	ResultActions={ {ActionType="DisableTrigger",Value="FinisTrigger"}, {ActionType="setNPCFollow",Value=false,NPCName="Hilltop Scout"},{ActionType="EndQuest",Value="Hilltop Rescue"},{ActionType="NPCGivesReward",NPCName="Hilltop Governor",ItemType="Base.Axe",ItemTypeQuantity=1},{ActionType="NPCSpeak",Value="Thanks again",NPCName="Hilltop Governor"} }} }
}

-- add our created quest triggers to the Super Survivor Quest Manager (SSQM)
SSQM:AddToTop(ApproachLeaderTrigger)
SSQM:AddToTop(ApproachGuardTrigger)
SSQM:AddToTop(SpeakLeaderTrigger)
SSQM:AddToTop(TalkToLeaderTrigger)
SSQM:AddToTop(ApproachScoutTrigger)
SSQM:AddToTop(FinisTrigger)
SSQM:AddToTop(SpawnScoutTrigger)

--other ConditionType = DistanceToSquare,DistanceToNPC,TalkToNPC,AttackNPC,KillNPC,FindItem(ItemType)


