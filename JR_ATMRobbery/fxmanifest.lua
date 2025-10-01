fx_version 'cerulean'
games {'gta5'}
version '1.0.0'
lua54 'yes'
author 'JRScripts'
description 'Simple ATM Robbery Script'

files {
    'locales/*.json'
}

shared_scripts { 
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/cl_editable.lua',
    'client/cl_main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge/*.lua',
    'server/sv_main.lua',
}
