require "05_Other/SuperSurvivorManager";
require "04_Group/SuperSurvivorGroupManager"

if (not PresetSpawns) then
	PresetSpawns = {};
end
-- set ChanceToSpawn from 1 to 100, nil assumes 100
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Spiffo",
	Name = "Spiffo Mascott",
	X = 6123,
	Y = 5302,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 9571,
	Y = 11161,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 8061,
	Y = 7629,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 13617,
	Y = 7224,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 12793,
	Y = 5728,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 12864,
	Y = 6776,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 10722,
	Y = 9229,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "I thought it better I do things alone",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 10155,
	Y = 9338,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Worker",
	Greeting = "Bill here is an Idiot",
	PerkName = "Blunt",
	PerkLevel = 3,
	isFemale = false,
	Name = "Bob",
	X = 10077,
	Y = 9545,
	Z = 0,
	Weapon = "Base.ClubHammer",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Worker",
	Greeting = "Breaks over time to get back to work....haha JK",
	PerkName = "Blunt",
	PerkLevel = 3,
	isFemale = false,
	Name = "Bill",
	X = 10075,
	Y = 9545,
	Z = 0,
	Weapon = "Base.Shovel",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Hazmat",
	Greeting = "I new all this would happen.",
	Name = "Nolan",
	X = 11690,
	Y = 8363,
	Z = 0,
	Weapon = "Base.Pistol",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Santa",
	Greeting = "Hoho hoo, Merry Christmass",
	Name = "Santa",
	X = 1018,
	Y = 6765,
	Z = 0,
	Weapon = "Base.Shotgun",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Spiffo",
	Name = "Spiffo Mascott",
	X = 11979,
	Y = 6816,
	Z = 0,
	Weapon = "Base.HuntingKnife",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Police",
	Name = "Deputy Douglus",
	X = 10635,
	Y = 10411,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = false,
	PerkName = "Aiming",
	PerkLevel = 5,
	Greeting = "I suppose your here for the guns...take only what you need."
};


--WESTPOINT BEGIN

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Police",
	Name = "Prison Guard",
	X = 11899,
	Y = 6937,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Police",
	Greeting = "YOU WANT SOME?! I\'LL TAKE YOU ALL DOWN!",
	Name = "Prison Guard",
	X = 11900,
	Y = 6937,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Police",
	ChanceToSpawn = 75,
	Name = "Prison Guard",
	X = 11901,
	Y = 6937,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Standing Ground",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Name = "Gun Shop Owner",
	X = 12066,
	Y = 6759,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = 3
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "Gun Shop Owner",
	X = 12067,
	Y = 6759,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = 3
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "YOU BETTER GET OUTTA HERE!",
	Name = "Gun Shop Owner",
	X = 12068,
	Y = 6759,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = 3
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Greeting = "Pastor Bob was right, all us sinners are having to pay!",
	Name = "Giga Shop Owner",
	X = 12033,
	Y = 6849,
	Z = 1,
	Weapon = "Base.Screwdriver",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Great to see a friendly face. Take what you need",
	Name = "Giga Shop Owner",
	X = 12033,
	Y = 6850,
	Z = 1,
	Weapon = "Base.Screwdriver",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Thought you were Bob. Hope he is ok. Anyways, make yourself at home and I\'ll pour you a stiff one. Ya probably need it",
	Name = "Twiggys Shop Owner",
	X = 12063,
	Y = 6798,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Its like the end of the world out there! That military blockade made matters worse, kept the infected in town. Bastards!",
	Name = "Twiggys Shop Owner",
	X = 12062,
	Y = 6797,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Greeting = "Bonjour! Rooms are now free. Do you have somewhere better to stay?",
	Name = "Hotel Manager",
	X = 12009,
	Y = 6919,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Gangster",
	Name = "Thug",
	X = 12310,
	Y = 6729,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = -5
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Gangster",
	Name = "Thug",
	X = 12313,
	Y = 6729,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = -5
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Gangster",
	Name = "Thug",
	X = 12316,
	Y = 6729,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = -5
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Name = "Principal",
	X = 11327,
	Y = 6765,
	Z = 1,
	Weapon = "Base.Plank",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 2,
	PY = 0
};

PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 12132,
	Y = 7085,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true,
	Patrolling = true,
	PX = 10,
	PY = 10
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 12133,
	Y = 7084,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true,
	Patrolling = true,
	PX = 20,
	PY = 0
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 12130,
	Y = 7083,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true,
	Patrolling = true,
	PX = -3,
	PY = 15
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	'So now I\'m going to beat the HOLY FUCK FUCKING FUCKEDY FUCK out of you with my bat. Who I call \"Lucille\"',
	PerkName = "Blunt",
	PerkLevel = 10,
	isFemale = false,
	Name = "Negan",
	X = 12131,
	Y = 7084,
	Z = 1,
	Weapon = "Base.BaseballBat",
	Orders = "Guard",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 12138,
	Y = 7098,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true,
	Patrolling = true,
	PX = 10,
	PY = 10
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 12146,
	Y = 7098,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true,
	Patrolling = true,
	PX = 20,
	PY = 0
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 12134,
	Y = 7099,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true,
	Patrolling = true,
	PX = -3,
	PY = 15
};

PresetSpawns[#PresetSpawns + 1] = {
	PerkName = "Aiming",
	PerkLevel = 4,
	Greeting = "Hey Milton, fellow survivors are here!  Perhaps they can save us from The Governor!",
	isFemale = true,
	Name = "Andrea ",
	X = 12064,
	Y = 6922,
	Z = 0,
	Weapon = "Base.Shovel",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Okay Andrea. There\'s no such thing as a free lunch... but it might be our only option! LETS GET OUT OF HERE!",
	isFemale = false,
	Name = "Milton",
	X = 12064,
	Y = 6924,
	Z = 0,
	Weapon = "Base.Shovel",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "How did you get past the traps? You\'ll be sorry for trespassing around here!",
	PerkName = "Aiming",
	PerkLevel = 5,
	Name = "Hunter",
	X = 11827,
	Y = 6574,
	Z = 0,
	Weapon = "Base.HuntingRifle",
	Orders = "Standing Ground",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "GET OUT OF HERE ASSHOLES!!",
	Name = "Gas Station Owner",
	X = 12070,
	Y = 7140,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Shit, she is not anwering her phone...",
	PerkName = "Blunt",
	PerkLevel = 5,
	Name = "Mechanic",
	X = 11894,
	Y = 6804,
	Z = 0,
	Weapon = "Base.Wrench",
	isHostile = false,
	Orders = "Patrol",
	Patrolling = true,
	PX = 10,
	PY = 0
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Take what you need. Just dont kill me!",
	Name = "Pharmacist",
	X = 11939,
	Y = 6798,
	Z = 0,
	Weapon = "Base.HuntingKnife",
	Orders = "Explore",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "I\'m okay. I\'m okay. I\'m in control. It\'s fine, it\'s okay. Maybe I could use a little help here",
	Name = "Mayor",
	X = 11954,
	Y = 6879,
	Z = 1,
	Weapon = "Base.HuntingKnife",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Man, I don\'t get paid nearly enough for this gig",
	PerkName = "Aiming",
	PerkLevel = 5,
	Name = "Body Guard",
	X = 11955,
	Y = 6879,
	Z = 1,
	Weapon = "Base.Pistol",
	Orders = "Guard",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "You can take what you want, but take me with you! Any place is safer than here",
	Name = "Shop Owner",
	X = 11905,
	Y = 6852,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Greeting = "Praise God! Hallelujah!",
	isFemale = false,
	Name = "Pastor Bob",
	X = 11973,
	Y = 6990,
	Z = 0,
	Weapon = "Base.Plank",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Please help us!",
	Name = "Teacher",
	X = 11306,
	Y = 6785,
	Z = 1,
	Weapon = "Base.Plank",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 10,
	PY = 0
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Are you friendly?",
	Name = "Teacher",
	X = 11345,
	Y = 6785,
	Z = 1,
	Weapon = "Base.Plank",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 2,
	PY = 0
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Greeting = "He has sent me a miracle. Amen!",
	isFemale = false,
	Name = "Pastor Aaron",
	X = 11096,
	Y = 6710,
	Z = 0,
	Weapon = "Base.Plank",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	PerkName = "Aiming",
	PerkLevel = 5,
	Greeting = "Did you have to sneak up on me?",
	Name = "Sam",
	X = 11991,
	Y = 6945,
	Z = 2,
	Weapon = "Base.HuntingRifle",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Fireman",
	Greeting = "As you can tell, I\'m an axe man",
	PerkName = "Axe",
	PerkLevel = 5,
	Name = "Lumberjack",
	X = 12064,
	Y = 7213,
	Z = 0,
	Weapon = "Base.Axe",
	Orders = "Chop Wood",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Shoot, you scared me, thought you were one of those damn zombies",
	PerkName = "Axe",
	PerkLevel = 5,
	Name = "Lumberjack",
	X = 12070,
	Y = 7213,
	Z = 0,
	Weapon = "Base.Axe",
	Orders = "Chop Wood",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting = "Could have been the Russians, aliens, some secret military experiments",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 12074,
	Y = 7306,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Forage",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Survivalist",
	Greeting =
	"I focused on being prepared. Crazy is building the ark after the flood has already come. Don\'t you agree?",
	PerkName = "PlantScavenging",
	PerkLevel = 5,
	Name = "Survivalist",
	X = 12084,
	Y = 7306,
	Z = 0,
	Weapon = "Base.SpearKnife",
	Orders = "Explore",
	isHostile = false
};

-- WESTPOINT END PlantScavenging

-- MULDRAUGH BEGIN

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "All life is precious",
	PerkName = "Blunt",
	PerkLevel = 10,
	isFemale = false,
	NoParty = true,
	Name = "Morgan",
	X = 9834,
	Y = 9515,
	Z = 0,
	Weapon = "Base.WoodenLance",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "We get comfortable here, we let our guard down, this place is gonna make us weak",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = false,
	NoParty = true,
	Name = "Carol",
	X = 9833,
	Y = 9517,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = -15,
	PY = 0
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Have you ever had to kill people because they had already killed your friends and were coming for you next? Have you ever done things that made you feel afraid of yourself afterward? Have you ever been covered in so much blood that you didn\'t know if it was yours or walkers\' or your friends\'? Huh? Then you don\'t know",
	PerkName = "Blunt",
	PerkLevel = 10,
	isFemale = true,
	NoParty = true,
	Name = "Michonne",
	X = 9809,
	Y = 9501,
	Z = 0,
	Weapon = "Base.Katana",
	Orders = "Guard",
	isHostile = false
}; --ALT QUOTE: Don\'t you want one more day with a chance?
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Why are we running? What are we doing?",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = false,
	Name = "Carl",
	X = 9833,
	Y = 9519,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "I\'ve already lost three of the people that I care about most in this world",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = true,
	NoParty = true,
	Name = "Maggie",
	X = 9803,
	Y = 9507,
	Z = 0,
	Weapon = "Base.HuntingKnife",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Nice moves there, Clint Eastwood. You\'re the new sheriff come riding in to clean up the town?",
	PerkName = "Blunt",
	PerkLevel = 10,
	isFemale = false,
	NoParty = true,
	Name = "Glenn",
	X = 9806,
	Y = 9506,
	Z = 0,
	Weapon = "Base.BaseballBat",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "You want to know what I was before all this? I was nobody. Nothing",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = false,
	NoParty = true,
	Name = "Daryl",
	X = 9799,
	Y = 9503,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = 10
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Everyone who made it this far, we\'ve all done worse kinds of things, just to stay alive.. But we can still come back. We\'re not too far gone",
	PerkName = "Axe",
	PerkLevel = 10,
	isFemale = false,
	Name = "Rick",
	X = 9800,
	Y = 9488,
	Z = 0,
	Weapon = "Base.Axe",
	Orders = "Guard",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "It\'s so good to see friendly faces",
	PerkName = "Axe",
	PerkLevel = 5,
	Name = "Lumberjack",
	X = 10470,
	Y = 9277,
	Z = 0,
	Weapon = "Base.Axe",
	Orders = "Chop Wood",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "We came back to McCoy\'s looking for supplies. Muldraugh is a god awful mess",
	PerkName = "Axe",
	PerkLevel = 5,
	Name = "Lumberjack",
	X = 10472,
	Y = 9279,
	Z = 0,
	Weapon = "Base.Axe",
	Orders = "Chop Wood",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	Greeting = "Doctor Kildare? Oh.. how did you get up here? The doors should have been locked. Are you bitten?",
	PerkName = "Doctor",
	PerkLevel = 3,
	isFemale = true,
	Name = "Nurse",
	X = 10880,
	Y = 10029,
	Z = 1,
	Weapon = "Base.KitchenKnife",
	Orders = "Doctor",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"They should be terrified. The world\'s ending. Otherwise, who gives a shit. With God, it\'s never too late to make things right",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = false,
	Name = "Preacher",
	X = 10787,
	Y = 10172,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "HELP! HELP! They are trying to eat me!",
	Name = "Food Inspector",
	X = 10621,
	Y = 9829,
	Z = 1,
	Weapon = "Base.Plank",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Stay...STAY AWAY FROM ME! ARRRRGGH!!!",
	PerkName = "Aiming",
	PerkLevel = 1,
	isFemale = false,
	Name = "Security Guard",
	X = 10627,
	Y = 9410,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Ya know wut? This is the most exciting goddamn thing that\'s ever happened in this town",
	PerkName = "Blade",
	PerkLevel = 5,
	isFemale = false,
	Name = "Mad Man",
	X = 10686,
	Y = 10328,
	Z = 0,
	Weapon = "Base.HuntingKnife",
	Orders = "Standing Ground",
	isHostile = false
};

--MULDRAUGH END

--WAREHOUSES OUTSIDE OF MULDRAUGH
--Barney Calhoun ;-)
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Hey Gordon, is that you? What the bejesus?! Put your weapons away or I\'ll shoot!",
	isFemale = false,
	Name = "Security Guard",
	X = 9987,
	Y = 10962,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = false
};
--WAREHOUSES END

--MARCH RIDGE
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"To hell with circumstances; I create opportunities. Knowing is not enough, we must apply. Willing is not enough, we must do",
	PerkName = "Blunt",
	PerkLevel = 10,
	isFemale = false,
	Name = "Martial Arts Instructor",
	X = 10010,
	Y = 12735,
	Z = 1,
	Weapon = "Base.BaseballBat",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	Greeting =
	"We\'ve got to get out of here! Its not safe. There is a gang of lunatics coming back here for me and the supplies. They want a doctor",
	isFemale = true,
	PerkLevel = 4,
	PerkName = "Doctor",
	Name = "Doctor",
	X = 10167,
	Y = 12754,
	Z = 0,
	Weapon = "Base.BaseballBat",
	Orders = "Doctor",
	isHostile = false
};

--MARCH RIDGE END

--ROSEWOOD
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Fireman",
	Greeting =
	"Howdy. You can call me Tex. Been waiting for the military or some such, but you\'ll do my friend. Welcome!",
	PerkName = "Axe",
	PerkLevel = 5,
	isFemale = false,
	Name = "Fire Fighter",
	X = 8143,
	Y = 11736,
	Z = 1,
	Weapon = "Base.Axe",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Greeting = "ARRRRGGH!!!! Got you! Don\'t even think about escaping!",
	Name = "Attorney",
	X = 7991,
	Y = 11449,
	Z = 0,
	Weapon = "Base.Golfclub",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Formal",
	Greeting = "Thank God! Please help me!",
	Name = "Librarian",
	X = 8335,
	Y = 11615,
	Z = 0,
	Weapon = "Base.BaseballBat",
	Orders = "Standing Ground",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"I\'ve been to eight county fairs and a goat rodeo, but I\'ve never seen anything like that. Thanks for the rescue. Now I gotta find Rick",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = false,
	NoParty = true,
	Name = "Abraham",
	X = 8211,
	Y = 11805,
	Z = 0,
	Weapon = "Base.HuntingRifle",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Thank you for saving me. So you\'re aware, I\'’'m on record as stating that I\'m not combat ready or even for that matter combat inclined",
	PerkName = "Blunt",
	PerkLevel = 3,
	isFemale = false,
	NoParty = true,
	Name = "Eugene",
	X = 8231,
	Y = 11816,
	Z = 0,
	Weapon = "Base.Plank",
	Orders = "Guard",
	isHostile = false
};
--ROSEWOOD END

--RAILYARD SOUTH OF MULD
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Hey! Who goes there?! Better watch yer self pally!",
	PerkName = "Blunt",
	PerkLevel = 5,
	isFemale = false,
	Name = "Hobo",
	X = 11629,
	Y = 9852,
	Z = 0,
	Weapon = "Base.BaseballBat",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -15
};

---RAILYARD END

--cabins far east of muldraugh
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Hunter",
	Greeting = "I\'ve have been watching you, but you seem friendly. How did you make it out alive?",
	PerkName = "Aiming",
	PerkLevel = 7,
	isFemale = false,
	Name = "Hunter",
	X = 12475,
	Y = 8969,
	Z = 0,
	Weapon = "Base.HuntingRifle",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 10,
	PY = 0
};

--end cabins

--DIXIE

PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"I\'ve had my gun sight on you for the last 5 minutes, but you seem friendly. How did you make it out alive?",
	PerkName = "Aiming",
	PerkLevel = 7,
	isFemale = false,
	Name = "Hunter",
	X = 11608,
	Y = 9303,
	Z = 0,
	Weapon = "Base.HuntingRifle",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 10,
	PY = 0
};
---END DIXIE

--VALLEY & MALL AREA
PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Oh my God! Normal people for a change! This is my BOOMSTICK! Groovy. Found it off a dead dude. Luckily they sell ammo at S-MART",
	PerkName = "Aiming",
	PerkLevel = 3,
	isFemale = false,
	Name = "B-Movie Actor",
	X = 13643,
	Y = 5868,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = 15
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Honey, we\'ve got some visitors. Stop looking for where you left the champagne and get over here!",
	isFemale = true,
	Name = "Shopper Kim",
	X = 13923,
	Y = 5829,
	Z = 2,
	Weapon = "Base.KitchenKnife",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 0,
	PY = 15
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "What\'s up Goldigger?...Nothing in life is promised except.... death!",
	isFemale = false,
	Name = "Shopper Kanye",
	X = 13923,
	Y = 5824,
	Z = 2,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = -15,
	PY = 0
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Worker",
	Greeting = "Ya better be real cool buddy, or I\'ll shovel your sorry ass outta here.",
	PerkName = "Blunt",
	PerkLevel = 3,
	isFemale = false,
	Name = "Construction Worker",
	X = 14087,
	Y = 5453,
	Z = 0,
	Weapon = "Base.Shovel",
	Orders = "Standing Ground",
	isHostile = false
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"Finally! Help has arrived! I..I...came to the Academy during the curfew to grab some books before we tried to escape by foot around the military blockade",
	isFemale = true,
	Name = "Professor",
	X = 12869,
	Y = 4848,
	Z = 0,
	Weapon = "Base.BaseballBat",
	Orders = "Standing Ground",
	isHostile = false
};

--END VALLEY & MALL AREA

-- OTHER START

PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 8217,
	Y = 11810,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 10,
	PY = 0
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 8256,
	Y = 11845,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Guard",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 8255,
	Y = 11850,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 8248,
	Y = 11859,
	Z = 0,
	Weapon = "Base.AssaultRifle",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Name = "A Savior",
	X = 8235,
	Y = 11837,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "Hi, I\'m Negan",
	isFemale = false,
	Name = "I\'m Negan",
	X = 8226,
	Y = 11869,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Patrol",
	isHostile = true,
	Patrolling = true,
	PX = 10,
	PY = -10
};

PresetSpawns[#PresetSpawns + 1] = {
	Greeting =
	"The Lord sent you here to finally punish me. I'm damned. I was damned before. I always lock the doors. I always lock the doors",
	PerkName = "Blade",
	PerkLevel = 5,
	isFemale = false,
	Name = "Father Gabriel",
	X = 10323,
	Y = 12787,
	Z = 0,
	Weapon = "Base.HuntingKnife",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = " Nobody\'s got to die today",
	PerkName = "Axe",
	PerkLevel = 5,
	isFemale = false,
	Name = "Tyreese",
	X = 9206,
	Y = 12139,
	Z = 0,
	Weapon = "Base.Axe",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "I move through town... I\'m quiet... like a fire",
	PerkName = "Aiming",
	PerkLevel = 5,
	isFemale = true,
	Name = "Sasha",
	X = 9207,
	Y = 12143,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Guard",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Greeting = "The people around you dying...that\'s the hard part",
	PerkName = "Aiming",
	PerkLevel = 10,
	isFemale = true,
	Name = "Rosita",
	X = 14421,
	Y = 4628,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Guard",
	isHostile = false
};

-- OTHER END

-- prison
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Halt!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7753,
	Y = 11884,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Stop!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7753,
	Y = 11889,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Standing Ground",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Halt!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7743,
	Y = 11905,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Guard",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Stop!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7709,
	Y = 11878,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Guard",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Halt!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7680,
	Y = 11878,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Explore",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Stop!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7680,
	Y = 11878,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Halt!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7651,
	Y = 11855,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Explore",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Stop!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7651,
	Y = 11855,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true
};

PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Halt!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7729,
	Y = 11913,
	Z = 0,
	Weapon = "Base.Shotgun",
	Orders = "Explore",
	isHostile = true
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Guard",
	Greeting = "Stop!",
	PerkName = "Aiming",
	PerkLevel = 5,
	NoParty = true,
	isFemale = false,
	Name = "Soldier",
	X = 7729,
	Y = 11913,
	Z = 0,
	Weapon = "Base.Pistol",
	Orders = "Explore",
	isHostile = true
};

--recruitable farmers
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"You\'re the one stealing my crops? I\'m sure it was no damn zombie. These city folk don\'t know how to fend for themselves. We can work together here",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer John",
	X = 11137,
	Y = 6855,
	Z = 1,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Nick",
	X = 8616,
	Y = 8823,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Dan",
	X = 10824,
	Y = 9072,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Fransis",
	X = 14322,
	Y = 4957,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Franko",
	X = 11132,
	Y = 6853,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Jacob",
	X = 14394,
	Y = 4557,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Jack",
	X = 6817,
	Y = 7720,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Frank",
	X = 9067,
	Y = 12184,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Farmer",
	Greeting =
	"I bet you could use someone who knows about farming. If you make it worth my while I just might go with you.",
	isFemale = false,
	PerkName = "Farming",
	PerkLevel = 5,
	Name = "Farmer Phil",
	X = 12059,
	Y = 7363,
	Z = 0,
	Weapon = "Base.Hammer",
	Orders = "Patrol",
	isHostile = false,
	Patrolling = true,
	PX = 0,
	PY = -4
};


--recuritable doctors
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	X = 10877,
	Y = 10029,
	Z = 0,
	Greeting = "Need some treatment?",
	PerkName = "Doctor",
	PerkLevel = 5,
	isFemale = false,
	Name = getText("ContextMenu_SD_DoctorPrefix_Before") ..
		GetDialogueSpeech("BoyNames") .. getText("ContextMenu_SD_DoctorPrefix_After"),
	Weapon = "Base.HuntingKnife",
	Orders = "Doctor",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	X = 8093,
	Y = 11521,
	Z = 0,
	Greeting = "Need some treatment?",
	PerkName = "Doctor",
	PerkLevel = 5,
	isFemale = false,
	Name = getText("ContextMenu_SD_DoctorPrefix_Before") ..
		GetDialogueSpeech("BoyNames") .. getText("ContextMenu_SD_DoctorPrefix_After"),
	Weapon = "Base.HuntingKnife",
	Orders = "Doctor",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	X = 11882,
	Y = 6883,
	Z = 0,
	Greeting = "Need some treatment?",
	PerkName = "Doctor",
	PerkLevel = 5,
	isFemale = false,
	Name = getText("ContextMenu_SD_DoctorPrefix_Before") ..
		GetDialogueSpeech("BoyNames") .. getText("ContextMenu_SD_DoctorPrefix_After"),
	Weapon = "Base.HuntingKnife",
	Orders = "Doctor",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	X = 11937,
	Y = 6797,
	Z = 0,
	Greeting = "Need some treatment?",
	PerkName = "Doctor",
	PerkLevel = 5,
	isFemale = false,
	Name = getText("ContextMenu_SD_DoctorPrefix_Before") ..
		GetDialogueSpeech("BoyNames") .. getText("ContextMenu_SD_DoctorPrefix_After"),
	Weapon = "Base.HuntingKnife",
	Orders = "Doctor",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	X = 10143,
	Y = 12750,
	Z = 0,
	Greeting = "Need some treatment?",
	PerkName = "Doctor",
	PerkLevel = 5,
	isFemale = false,
	Name = getText("ContextMenu_SD_DoctorPrefix_Before") ..
		GetDialogueSpeech("BoyNames") .. getText("ContextMenu_SD_DoctorPrefix_After"),
	Weapon = "Base.HuntingKnife",
	Orders = "Doctor",
	isHostile = false
};
PresetSpawns[#PresetSpawns + 1] = {
	Suit = "Preset_Doctor",
	X = 6477,
	Y = 5259,
	Z = 0,
	Greeting = "Need some treatment?",
	PerkName = "Doctor",
	PerkLevel = 5,
	isFemale = false,
	Name = getText("ContextMenu_SD_DoctorPrefix_Before") ..
		GetDialogueSpeech("BoyNames") .. getText("ContextMenu_SD_DoctorPrefix_After"),
	Weapon = "Base.HuntingKnife",
	Orders = "Doctor",
	isHostile = false
};

CannedFoods = { "TinnedBeans", "CannedBolognese", "CannedCarrots2", "CannedChili", "CannedCorn", "CannedCornedBeef",
	"CannedMushroomSoup", "CannedPeas", "CannedPotato2", "CannedSardines", "TinnedSoup", "CannedTomato2" };

PresetSpawns[#PresetSpawns + 1] = { X = 11726, Y = 7941, Z = 0, itemType = "Base.WaterPot", count = 2, isItemSpawn = true }
PresetSpawns[#PresetSpawns + 1] = { X = 11728, Y = 7940, Z = 0, itemType = "Base.Log", count = 4, isItemSpawn = true }

SurvivorCount = 1;

SurvivorRoutes = {
	TrainTracksToValleyStation = {
		{ x = 12181, y = 6821, z = 0 },
		{ x = 12296, y = 6775, z = 0 },
		{ x = 12298, y = 6609, z = 0 },
		{ x = 12576, y = 6606, z = 0 },
		{ x = 12621, y = 6564, z = 0 },
		{ x = 12620, y = 5863, z = 0 },
		{ x = 12735, y = 5772, z = 0 },
	},

}


function SuperSurvivorPresetSpawnThis(PresetSpawn)
	local square = getCell():getGridSquare(PresetSpawn.X, PresetSpawn.Y, PresetSpawn.Z);
	local isFemale = false;
	local x = square:getX();
	local y = square:getY();
	local z = square:getZ();

	if (square:getModData().thisSquareSpawnedPreset == true) then
		return false
	end

	if (PresetSpawn.isItemSpawn ~= nil) and (PresetSpawn.itemType ~= nil) then
		local item = PresetSpawn.itemType
		local count = PresetSpawn.count
		if not count then count = 1 end
		local dropItem = item
		for i = 0, count - 1 do
			if (item == "RandomCannedFood") then
				dropItem = "Base." .. tostring(CannedFoods[ZombRand(#CannedFoods) + 1])
			else
				dropItem = item
			end
			square:AddWorldInventoryItem(dropItem, (ZombRand(99) / 100), (ZombRand(99) / 100), 0)
		end
		if (PresetSpawn.GroupID) then square:getModData().Group = PresetSpawn.GroupID end -- who it belongs to
	else
		if PresetSpawn.isFemale ~= nil then isFemale = PresetSpawn.isFemale end
		local SuperSurvivor = SSM:spawnSurvivor(isFemale, square)
		if (SuperSurvivor == nil) then return false end

		local Buddy = SuperSurvivor.player

		if (PresetSpawn.AIMode ~= nil) then SuperSurvivor:setAIMode(PresetSpawn.AIMode) end

		SuperSurvivor.player:setZ(PresetSpawn.Z);

		local tempTM = SuperSurvivor:getTaskManager()
		tempTM:clear()

		if (PresetSpawn.Orders ~= nil) and (PresetSpawn.Orders == "Guard") then
			tempTM:AddToTop(GuardTask:new(SuperSurvivor, SuperSurvivor.player:getCurrentSquare()))
			SuperSurvivor:setAIMode("Guard")
		end

		if (PresetSpawn.Orders ~= nil) and (PresetSpawn.Orders == "Doctor") then
			tempTM:AddToTop(DoctorTask:new(SuperSurvivor))
			SuperSurvivor:setAIMode("Doctor")
		end

		if (PresetSpawn.Orders ~= nil) and (PresetSpawn.Orders == "Farming") then
			tempTM:AddToTop(FarmingTask:new(SuperSurvivor))
			SuperSurvivor:setAIMode("Farmer")
		end

		if (PresetSpawn.Orders ~= nil) and (PresetSpawn.Orders == "Wander") or (PresetSpawn.Orders == "Explore") then
			tempTM:AddToTop(WanderTask:new(SuperSurvivor))
			SuperSurvivor:setAIMode("Wander")
		end

		if (PresetSpawn.Orders ~= nil) and (PresetSpawn.Orders == "FollowRoute") then
			local routeID = PresetSpawn.RouteID
			tempTM:AddToTop(FollowRouteTask:new(SuperSurvivor, routeID))
			SuperSurvivor:setAIMode("FollowRoute")
		end

		if (PresetSpawn.Orders ~= nil) and (PresetSpawn.Orders == "Standing Ground") then
			SuperSurvivor:setWalkingPermitted(false)
			SuperSurvivor:setAIMode("Stand Ground")
		end

		if (PresetSpawn.Patrolling ~= nil) then
			local patrolSquare = getCell():getGridSquare(x + PresetSpawn.PX, y + PresetSpawn.PY, PresetSpawn.Z) -- WIP - Cows: Console.txt logged an error at this line
			SuperSurvivor.player:getModData().PX = x + PresetSpawn.PX
			SuperSurvivor.player:getModData().PY = y + PresetSpawn.PY
			SuperSurvivor.player:getModData().PZ = PresetSpawn.Z
			tempTM:AddToTop(PatrolTask:new(SuperSurvivor, SuperSurvivor.player:getCurrentSquare(), patrolSquare))
			SuperSurvivor:setAIMode("Patrol")
		end

		if (PresetSpawn.GroupID ~= nil) then
			local Role = PresetSpawn.Role
			if not Role then Role = "Worker" end
			local tempGroup = SSGM:GetGroupById(PresetSpawn.GroupID)

			tempGroup:addMember(SuperSurvivor, Role)
		end

		if (PresetSpawn.NoParty ~= nil) then
			SuperSurvivor.player:getModData().NoParty = true;
		end

		if (PresetSpawn.isHostile == true) then SuperSurvivor:setHostile(true) end
		SuperSurvivor.player:getModData().seenZombie = true;

		if (PresetSpawn.Weapon ~= nil) then
			SuperSurvivor:giveWeapon(PresetSpawn.Weapon, true);
		end
		if (PresetSpawn.ShowName ~= nil) then
			SuperSurvivor.player:getModData().ShowName = true;
		end
		if (PresetSpawn.Greeting) then
			SuperSurvivor.player:getModData().Greeting = PresetSpawn.Greeting;
		end
		if (PresetSpawn.InitGreeting) then
			SuperSurvivor.player:getModData().InitGreeting = PresetSpawn.InitGreeting;
		end
		SuperSurvivor:setName(PresetSpawn.Name)

		if (PresetSpawn.PerkLevel ~= nil and PresetSpawn.PerkName ~= nil) then
			local perk = Perks.FromString(PresetSpawn.PerkName);
			local level
			if perk and (tostring(perk) ~= "MAX") then
				if (PresetSpawn.PerkLevel == nil) then
					level = ZombRand(3, 9)
				else
					level = PresetSpawn.PerkLevel
				end
				local count = 0;

				while (count < level) do
					SuperSurvivor.player:LevelPerk(perk);
					count = count + 1;
				end
			end
		end

		if (PresetSpawn.Suit ~= nil) then
			SuperSurvivor:SuitUp(PresetSpawn.Suit)
		end

		-- WIP - Cows: WHAT ARE THE CHANGES? THIS MAKES NO SENSE AND I SEE NO NUMBER VALUE ASSIGNED
		--  WIP - Cows: why is Aresenal[26] uncredited...?
		--	Arsenal[26]'s changes -- start
		--	NOTE : This previously started at line #455, didn't work since NPC not spawned yet.
		--	NOTE : I've always started additional PresetSpawn parameters way down here without issues.
		--	==============================
		--	= 0 - 4  Lightest to Darkest
		--	==============================
		if (PresetSpawn.Skin ~= nil) then
			SuperSurvivor:Get():getHumanVisual():setSkinTextureIndex(PresetSpawn.Skin)
		end

		--	================================================
		--	= UNISEX - Hat, Bald, Ponytail
		--	= FEMALE - Spike, OverEye, Bob, Demi, Kate, Long, Long2, Back
		--	= MALE - CrewCut, Picard, Baldspot, Recede
		--	= MALE - Messy, Short, Mullet, Metal, Fabian
		--	================================================
		if (PresetSpawn.Hair ~= nil) then
			SuperSurvivor:Get():getHumanVisual():setHairModel(PresetSpawn.Hair)
		end
		--	================================================
		--	= MALE - None, Chops, Moustache, Goatee, BeardOnly, Full, Long, LongScruffy
		--	================================================
		if (PresetSpawn.Beard ~= nil) then
			SuperSurvivor:Get():getHumanVisual():setBeardModel(PresetSpawn.Beard)
		end

		--	================================================
		--	= COLOR - White, Grey, Blond, Sand, Brown, Red, Pink, Purple, Blue, Black
		--	================================================
		if (PresetSpawn.Color ~= nil) then
			SuperSurvivor:Get():getHumanVisual():setHairColor(HairColors[PresetSpawn.Color]);
		end
		--	Arsenal[26]'s changes -- end

		PresetSpawn = nil;
	end

	square:getModData().thisSquareSpawnedPreset = true

	return true
end

function SuperSurvivorPresetSpawn(square)
	local sc = 1;

	RPresetSpawns = {};

	while PresetSpawns[sc] do
		if PresetSpawns[sc].Z == nil then PresetSpawns[sc].Z = 0 end
		local pindex = PresetSpawns[sc].X .. PresetSpawns[sc].Y .. PresetSpawns[sc].Z;
		RPresetSpawns[pindex] = PresetSpawns[sc];
		RPresetSpawns[pindex].ID = sc;
		sc = sc + 1;
	end

	if (RPresetSpawns ~= nil) then
		if (NoPresetSpawn) then
			return false
		end

		local x = square:getX();
		local y = square:getY();
		local z = square:getZ();

		local i = x .. y .. z;

		if (RPresetSpawns[i]) and square:getModData().SurvivorSquareLoaded == nil
			and (RPresetSpawns[i].ChanceToSpawn == nil
				or ZombRand(1, 100) > RPresetSpawns[i].ChanceToSpawn)
		then
			square:getModData().SurvivorSquareLoaded = true;

			SuperSurvivorPresetSpawnThis(RPresetSpawns[i]);
			return true
		end
	end

	return false
end
