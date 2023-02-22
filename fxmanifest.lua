fx_version 'cerulean'
game 'gta5'

description 'QB-Tattoo'

shared_script {
	'shared/**'

}

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/**'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

file 'AllTattoos.json'
