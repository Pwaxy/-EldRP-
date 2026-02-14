fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'eld_auth'
author 'Pwaxy'
version '0.0.1'
server_only 'yes'
description 'Eld Auth'

dependencies {
  'eld_db'
}

server_scripts {
	'server/auth.lua'
}
