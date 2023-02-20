fx_version 'cerulean'
game 'gta5'

description 'QB-Tattoos'

shared_script 'config.lua'

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

file 'AllTattoos.json'
