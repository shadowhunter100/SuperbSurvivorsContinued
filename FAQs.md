__**No, I am not actively working on this mod anymore and I have no intention of creating mod patchers.**__

# If you want to do something on your own in your own interest, the code is all here:
- https://github.com/shadowhunter100/SuperbSurvivorsContinued/tree/main
- *Edit: I will do code reviews PRs and update the workshop item accordingly... Please don't pollute the workshop with more SS versions.*
- *All issues listed here are what I have found to be frequently asked and explained.*

# NPCs are not taking any damage
- There are 2 possibilities
1. You have Advanced Trajectory, figure it out on your own or disable it.
2. You have terrible rolls, legit, I've seen the function for damage calculation and literally NPCs will take no damage if your roll is low and didn't penetrate cloth on hit. 
- No, I looked and I decided it wasn't worth my time here.
  - SSC Cleaned up code - https://github.com/shadowhunter100/SuperbSurvivorsContinued/blob/main/mods/SuperbSurvivorsContinued/media/lua/client/04_DataManagement/SuperSurvivorUpdate.lua#L51
  - SS Original Code - https://github.com/shadowhunter100/SuperbSurvivorsSteam20230425/blob/main/mods/Superb-Survivors/media/lua/client/3_Other/SuperSurvivorUpdate.lua#L234

## NPCs are stuck in a ...
- Reloading - Well, SS/SSC spams reload calls onRenderTick, which is about 40-80 times a second... hence a need for 60 FPS lock (yes I know, lol).
- Queued Actions on said RenderTick are not always cleared, hence NPCs may queue up to dozens of actions that never gets carried out.
- Yeah, No, I am not touching that anymore. Good luck to the brave soul who wants to try.

## RVs Support
- This is based on user report - SS NPCs do not work with RVs, and I can't tell you why as I am not running RV mods.
  - If I have to guess, it's because some data are cleared on entering the RV and NPCs simply die or disappear.

## Changing Sandbox Options
- Download the Change Sandbox Options mod by Star
- https://steamcommunity.com/sharedfiles/filedetails/?id=2894296454

## Inventory Management and Equipping
- Go to Survivors Menu -> Inventory -> Transfer.
- Survivors Menu -> Equip
- *Yes the inventory will lag a lot because that was an old code I couldn't figure out how to rewrite.* 

Multiplayer Support
- No, and I will simply summarize the issues below: 
  - Most APIs and action related functions in PZ are designed to and work only with Player inputs and player data (via [b]getSpecificPlayer() API calls[/b]).
  - Working with MP requires a server setup and server side data management, leading to at least double the workload that I have no interest in.
  - NPCs function based on real-time events or programmed events, whereas Players work based on key inputs... Think on that for a bit and why it is hard to make things that work for you work for NPCs.


## Custom Maps
- Yes, SS and SSC can and will spawn random NPCs on custom maps.

## Why won't original SS work with SSC?
Because original SS included its own custom maps. Once your game save has *any* custom map loaded, it is practically locked to it. 
Which is why disabling original SS will break your game and prevent the save from loading. But disabling SSC should still allow you to load your game save, albeit with a lot of orphaned/unused/undeleted garbage data.

## Mouse Cursor Disappearing
- Turn on show cursor while aiming in the main options.

## Why Won't I (Cows with Guns) Continue Developing SSC?
- Pain. Suffering. Time. Also on the GitHub readme https://github.com/shadowhunter100/SuperbSurvivorsContinued/tree/main#readme

- There are over 20,000 lines of code in the original SS.
- I have fixed the known issues to the best I can and cleaned up a lot things involving the custom maps, npcs, and some of the AI stuff.
- SS/SSC is simply not extensible for truly custom NPCs due to how it was written.
- There are already many issues with the mod itself that it is questionable all of the issues can be fixed.


## About PZNS (Project Zomboid NPC Spawning) Framework
- I am working on a separate new framework, the preview is available on the workshop.
- https://steamcommunity.com/sharedfiles/filedetails/?id=3001908830
- I have added a basic tutorial draft pdf for creating your own NPC with the framework
  - https://github.com/shadowhunter100/PZNS_AgentWong/blob/main/Creating%20Your%20Own%20NPC%20in%20Project%20Zomboid%20with%20PZNS.pdf
- Remember to have fun and *ask questions*.
