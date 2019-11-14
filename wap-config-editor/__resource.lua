name "Webadmin Config Editor"
author "glitchdetector"
contact "glitchdetector@gmail.com"
version "1.0"

description "Allows users to edit config files from Webadmin"

dependency 'webadmin-lua'
webadmin_plugin 'yes'

webadmin_settings 'yes'
convar_category 'Config Editor' {
    'Basic options',
    {
        {'Enable', 'wap_config_enable', 'CV_BOOL', true, 'Enable the Config Editor'},
        {'Read Only', 'wap_config_readonly', 'CV_BOOL', false, 'Make the editor read-only to prevent editing'},
        {'', 'Type of config file to list'},
        {'File Type', 'wap_config_extension', 'CV_MULTI', {
            {"Server Config File (.cfg)", "*.cfg"},
            {"Script Config File", "config.*"},
            {"Resource Manifest", "__resource.lua"},
        }},
    }
}

server_script 'secret.lua'
server_script 'config-editor-list.lua'
server_script 'config-editor.lua'
