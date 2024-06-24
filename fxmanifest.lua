shared_script '@WaveShield/resource/waveshield.lua' --this line was automatically written by WaveShield

fx_version 'cerulean'
game 'gta5'

description 'Script para cambiar nombre y apellido de un jugador en QBCore'
author 'Driieen'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
  --  'config.lua'
}

--client_scripts {
--    'client.lua'
--}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core'
}
