fx_version 'cerulean'

game 'gta5'

author 'MaXxaM#0511'

version '1.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}