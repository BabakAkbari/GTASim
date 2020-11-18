fx_version 'cerulean'
game 'gta5'

author 'An awesome dude'
description 'An awesome, but short, description'
version '1.0.0'

-- resource_type 'gametype' { name = 'My awesome game type!' }



client_scripts{
    'Copter/copter_client.lua',
    -- 'Plane/plane_client.lua',
    -- 'Sub/sub_client.lua',
    'Rover/rover_client.lua',
}
server_scripts {
    'copter_server.js',
    -- 'Plane/plane_server.js',
    -- 'Sub/sub_server.js',
    'Rover/rover_server.js'
}
