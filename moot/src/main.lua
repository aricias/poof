-- to reload changes in devlopment use global frequire instead of require
-- frequire clears the module cache
frequire = require("moot.src.lib.util").frequire
local tools = frequire("moot.src.lib.tools")
local log = frequire("moot.src.lib.log")

main = {}
function main.load_all_plugins()
    tools.config_gmcp()
    main.mdt = frequire("moot.src.mdt.mdt")
    main.colorscor = frequire("moot.src.colorscore")
    main.spots = frequire("moot.src.spots")
    main.xpc = frequire("moot.src.xpc")
    main.gui = frequire("moot.src.gui")
    main.settings = frequire("moot.src.settings")
end

-- some features will not install correctly untill we're connected but we'd like to have the UI and
--    general functionality in place by the time Mudlet itself shows the main window
-- so, we load all plugins when we parse main the first time at profile open then again once we're connected to the mud
main.load_all_plugins()
tools.add_regex_trigger("main", "load_all_plugins", "^Welcome to Discworld: the stuff of which dreams are made\\.$")

-- MUDLET CONFIGURATION
disableScrollBar()

log.info("main loaded")

return main