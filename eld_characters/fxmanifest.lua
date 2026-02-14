fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'eld_characters'
author 'Pwaxy'
version '0.0.1'
description 'Eld Characters'

ui_page 'client/ui/index.html'

file {
	'client/ui/index.html',
	'client/ui/assets/css/style.css',
	'client/ui/assets/js/app.js'
}

dependency 'eld_core'
dependency 'eld_auth'
dependency 'eld_db'

server_scripts {
	'server/Eld.Characters.Server.net.dll'
}

client_scripts {
	'client/Eld.Characters.Client.net.dll'
}
