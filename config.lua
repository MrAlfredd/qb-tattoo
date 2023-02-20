Config = {}

Config.AllTattooList = json.decode(LoadResourceFile(GetCurrentResourceName(), 'AllTattoos.json'))

Config.TattooCats = {
	{"ZONE_HEAD", "Head", {vec(0.0, 0.7, 0.7), vec(0.7, 0.0, 0.7), vec(0.0, -0.7, 0.7), vec(-0.7, 0.0, 0.7)}, vec(0.0, 0.0, 0.5)},
	{"ZONE_LEFT_LEG", "Left Leg", {vec(-0.2, 0.7, -0.7), vec(-0.7, 0.0, -0.7), vec(-0.2, -0.7, -0.7)}, vec(-0.2, 0.0, -0.6)},
	{"ZONE_LEFT_ARM", "Left Arm", {vec(-0.4, 0.5, 0.2), vec(-0.7, 0.0, 0.2), vec(-0.4, -0.5, 0.2)}, vec(-0.2, 0.0, 0.2)},
	{"ZONE_RIGHT_LEG", "Right Leg", {vec(0.2, 0.7, -0.7), vec(0.7, 0.0, -0.7), vec(0.2, -0.7, -0.7)}, vec(0.2, 0.0, -0.6)},
	{"ZONE_TORSO", "Torso", {vec(0.0, 0.7, 0.2), vec(0.0, -0.7, 0.2)}, vec(0.0, 0.0, 0.2)},
	{"ZONE_RIGHT_ARM", "Right Arm", {vec(0.4, 0.5, 0.2), vec(0.7, 0.0, 0.2), vec(0.4, -0.5, 0.2)}, vec(0.2, 0.0, 0.2)},
}

Config.Discount = 10 --- This is how much the original price should be divided with.
Config.UseTarget = false

Config.UseObject = true -- Tattoo related objects.
Config.TattooObjects = {
	1334823285,
	-1326130575,
	-1805606583
}

Config.Shops = {
	vector3(1322.74, -1651.95, 52.28),
	vector3(-1153.6, -1425.6, 4.9),
	vector3(322.1, 180.4, 103.5),
	vector3(-3170.0, 1075.0, 20.8),
	vector3(1864.6, 3747.7, 33.0),
	vector3(-293.7, 6200.0, 31.4)
}

Config.Zones = {
	[1] = {
		position = vector3(1322.6, -1651.9, 51.2),
		length = 6.2, width = 2.0, heading = 250,
		minZ = 27.17, maxZ = 31.17
	},
	[2] = {
		position = vector3(-1153.6, -1425.6, 4.9),
		length = 6.6, width = 2.0, heading = 250,
		minZ = 51.97, maxZ = 55.97
	},
	[3] = {
		position = vector3(322.1, 180.4, 103.5),
		length = 6.4, width = 2.0, heading = 71,
		minZ = 46.84, maxZ = 50.84
	},
	[4] = {
		position = vector3(-3170.0, 1075.0, 20.8),
		length = 6.4, width = 2.0, heading = 297,
		minZ = 35.58, maxZ = 39.58
	},
	[5] = {
		position = vector3(1864.6, 3747.7, 33.0),
		length = 6.6, width = 2.0, heading = 358,
		minZ = 13.7, maxZ = 17.7
	},
	[6] = {
		position = vector3(-293.7, 6200.0, 31.4),
		length = 6.6, width = 2.0, heading = 90,
		minZ = 35.89, maxZ = 39.89
	}

}

if not IsDuplicityVersion() then
	Config.interiorIds = {}
	for k, v in ipairs(Config.Shops) do
		Config.interiorIds[#Config.interiorIds + 1] = GetInteriorAtCoords(v)
	end
end



function debugPrint(text) -- function to handle debug prints
    tPrint(text, 0)
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