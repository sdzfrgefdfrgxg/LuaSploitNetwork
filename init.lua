local base = "https://raw.githubusercontent.com/sdzfrgefdfrgxg/LuaSploitNetwork/main/"

local function loadModule(path)
    return loadstring(game:HttpGet(base .. path))()
end

local LSN = loadModule("LuaSploitNetworkLib.lua")

-- load modules inside the lib
LSN.modules = {
    Keybind = loadModule("modules/keybind.lua"),
    ColorPicker = loadModule("modules/colorpicker.lua"),
    Textbox = loadModule("modules/textbox.lua"),
    Resize = loadModule("modules/resize.lua"),
    Theme = loadModule("modules/theme.lua"),
    Notify = loadModule("modules/notifications.lua"),
}

return LSN
