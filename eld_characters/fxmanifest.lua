fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'eld_characters'
author 'Pwaxy'
version '0.0.1'
description 'Eld Characters'

server_dependencies {
  'eld_db',
  'eld_auth'
}

ui_page 'ui/index.html'

files {
	'ui/index.html',
	'ui/assets/css/style.css',
	'ui/assets/js/app.js'
}

server_scripts {
	'server/server.lua'
}

client_scripts {
	'client/client.lua'
}
