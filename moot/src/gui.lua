frequire("moot.src.lib.guiframe")

-- topleft
GUIframe.addWindow(frequire("moot.src.quowmap").win, "Kefka's Maps (ft. Quow)", "topleft")
-- bottomleft
GUIframe.addWindow(frequire("moot.src.settings").win, "Settings", "bottomleft")
GUIframe.addWindow(frequire("moot.src.chats2").msco.win, "Comms", "bottomleft")
-- topright
-- bottomright
-- top
-- bottom
GUIframe.addWindow(frequire("moot.src.gxpc").win, "XP counter, Spots", "bottom")

GUIframe.loadSettings(false)