Config = {}

Config.Debug = true -- Make commands available
Config.Multicharacter = true -- Exprimental, should load tattoos in when previewing characters in multicharater. 
Config.Discount = 10 --- This is how much the original price should be divided with.
Config.UseTarget = false --- This to use BoxZone
Config.UseObject = true -- Tattoo related objects. Recommended. 
Config.TattooObjects = {
	1334823285,
	-1326130575,
	-1805606583
}

Config.Zones = {
	[1] = {zone = "ZONE_TORSO",			camPos = { vec(0.0, 1.0, 0.2) },		lookAt = vec(0.0, 0.0, 0.2),	},
	[2] = {zone = "ZONE_HEAD",			camPos = { vec(0.0, 1.0, 0.7)},			lookAt = vec(0.0, 0.0, 0.5),	},
	[3] = {zone = "ZONE_LEFT_ARM",		camPos = { vec(-0.4, 1.0, 0.2)},		lookAt = vec(-0.2, 0.0, 0.2),	},
	[4] = {zone = "ZONE_RIGHT_ARM", 	camPos = { vec(0.4, 1.0, 0.2)}, 		lookAt = vec(0.2, 0.0, 0.2),	},
	[5] = {zone = "ZONE_LEFT_LEG", 		camPos = { vec(-0.2, 1.0, -0.7)},		lookAt = vec(-0.2, 0.0, -0.6),	},
	[6] = {zone = "ZONE_RIGHT_LEG", 	camPos = { vec(0.2, 1.0, -0.7)}, 		lookAt = vec(0.2, 0.0, -0.6),	},
	[7] = {zone = "ZONE_HAIR", 			camPos = { vec(0.0, 1.0, 0.7)}, 		lookAt = vec(0.0, 0.0, 0.5),	},	
	
}
Config.Labels = {
	Zones = {
		ZONE_TORSO = "Torso",
		ZONE_HEAD = "Head",
		ZONE_LEFT_ARM = "Left arm",
		ZONE_RIGHT_ARM = "Right arm",
		ZONE_LEFT_LEG = "Left leg",
		ZONE_RIGHT_LEG = "Right leg",
		ZONE_HAIR = "Hair",
	},
	Collections = {
		mpairraces_overlays = "Air Races",
		mpbeach_overlays = "Beach",
		mpbiker_overlays = "Biker",
		mpbusiness_overlays = "Business",
		mpchristmas2017_overlays = "Christmas 2k17",
		mpchristmas2018_overlays = "Christmas 2k18",
		mpchristmas2_overlays = "Christmas 2",
		mpchristmas3_overlays = "Christmas 3",
		mpgunrunning_overlays = "Gunrunning",
		mpheist3_overlays = "Heist 3",
		mpheist4_overlays = "Heist 4",
		mphipster_overlays = "Hipster",
		mpimportexport_overlays = "Import & Export",
		mplowrider2_overlays = "Lowrider 2",
		mplowrider_overlays = "Lowrider",
		mpluxe2_overlays = "Luxury 2",
		mpluxe_overlays = "Luxury",
		mpsecurity_overlays = "Security",
		mpsmuggler_overlays = "Smuggler",
		mpstunt_overlays = "Stunt",
		mpsum2_overlays = "Summer 2",
		mpvinewood_overlays = "Vinewood",
		multiplayer_overlays = "Multiplayer"
	},
}

Config.TattooShops = {
	vector3(1322.74, -1651.95, 52.28),
	vector3(-1153.6, -1425.6, 4.9),
	vector3(322.1, 180.4, 103.5),
	vector3(-3170.0, 1075.0, 20.8),
	vector3(1864.6, 3747.7, 33.0),
	vector3(-293.7, 6200.0, 31.4)
}

Config.TattooZones = {
	[1] = {position = vector3(1322.6, -1651.9, 51.2),  	length = 6.2, width = 2.0,  heading = 250, 	minZ = 27.17, maxZ = 31.17 },
	[2] = {position = vector3(-1153.6, -1425.6, 4.9),	length = 6.6, width = 2.0,  heading = 250,	minZ = 51.97, maxZ = 55.97 },
	[3] = {position = vector3(322.1, 180.4, 103.5),		length = 6.4, width = 2.0, 	heading = 71,	minZ = 46.84, maxZ = 50.84},
	[4] = {position = vector3(-3170.0, 1075.0, 20.8),	length = 6.4, width = 2.0, 	heading = 297,	minZ = 35.58, maxZ = 39.58},
	[5] = {position = vector3(1864.6, 3747.7, 33.0),	length = 6.6, width = 2.0, 	heading = 358,	minZ = 13.7,  maxZ = 17.7},
	[6] = {position = vector3(-293.7, 6200.0, 31.4),	length = 6.6, width = 2.0, 	heading = 90,	minZ = 35.89, maxZ = 39.89}

}

if not IsDuplicityVersion() then
	Config.interiorIds = {}
	for k, v in ipairs(Config.TattooShops) do
		Config.interiorIds[#Config.interiorIds + 1] = GetInteriorAtCoords(v)
	end
end

function debugPrint(text) -- function to handle debug prints
	if Config.Debug then
    	tPrint(text, 0)
	end
end

function tPrint(tbl, indent)
    indent = indent or 0
    if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
            local tblType = type(v)
            local formatting = ("%s ^3%s:^0"):format(string.rep("  ", indent), k)

            if tblType == "table" then
                print(formatting)
                tPrint(v, indent + 1)
            elseif tblType == 'boolean' then
                print(("%s^1 %s ^0"):format(formatting, v))
            elseif tblType == "function" then
                print(("%s^9 %s ^0"):format(formatting, v))
            elseif tblType == 'number' then
                print(("%s^5 %s ^0"):format(formatting, v))
            elseif tblType == 'string' then
                print(("%s ^2'%s' ^0"):format(formatting, v))
            else
                print(("%s^2 %s ^0"):format(formatting, v))
            end
        end
    else
        print(("%s ^0%s"):format(string.rep("  ", indent), tbl))
    end
end