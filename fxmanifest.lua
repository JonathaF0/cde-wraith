fx_version 'cerulean'
game 'gta5'

name 'cde-wraith'
description 'CDE CAD Integration for Wraith ARS | Automatic plate reader lookups via CDECAD'
author 'CDECAD'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', -- Optional: only needed if Config.Notifications.UseOxLib = true
    'shared/config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'client/nui/index.html'

files {
    'client/nui/index.html'
}

dependencies {
    'wk_wars2x'
}
