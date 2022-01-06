version '0.1.0-alpha'
description 'A quick staff mode toggle for QB-Core Framework.'
author 'Matthew Johnson <maej@pm.me>'
repository 'https://github.com/maej20/mj-quickstaff'

fx_version 'cerulean'
game 'gta5'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

dependencies {
	'qb-core',
	'qb-interior',
	'qb-houses',
	'qb-apartments',
	'qb-policejob',
	'qb-ambulancejob',
	'qb-clothing',
	'qb-hud',
  'interact-sound',
  'oxmysql'
}

lua54 'yes'
