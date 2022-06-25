fx_version 'cerulean'
game 'gta5'

author 'Wert'
description 'wert-notes'
version '1.0.0'

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/style.css',
	'html/js/*',
}

client_scripts {
	'client.lua',
} 
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua',
}

lua54 'yes'