local xpc = frequire("moot.src.xpc")
local spots = frequire("moot.src.spots")
local tools = frequire("moot.src.lib.tools")

gxpc = gxpc or {}

gxpc.win = Geyser.MiniConsole:new({
  name = "gxpc_console",
  color = "black",
  x=0, y=0,
  width=0, height=0,
})
setFontSize("gxpc_console", 9)

function gxpc.refresh()
    local w = gxpc.win

    w:clear()

    local rep = xpc.get_xp_report()

    w:decho("\n")
    w:decho(rep.reset_xph .. " over " .. rep.reset_time)
    w:decho("\n")
    w:decho(rep.one .. rep.five .. rep.ten .. rep.twenty .. rep.sixty)

    w:decho("\n\n")

    spots:show({window_name=gxpc.win.name, rows=nil, cols=nil, prior='all', expand_horiz=false})
    --local conf1 = {window_name=gxpc.win.name, rows=nil, cols=3, prior='rhath1', expand_horiz=false}
    --local conf2 = {window_name=gxpc.win.name, rows=nil, cols=3, prior='rhath2', expand_horiz=false}
    --spots:show(conf1)
    --w:decho("\n")
    --spots:show(conf2)
end

-- TIMERS
tools.add_timer("gxpc", "refresh", 1.0)
tools.add_timer("gxpc", "refresh", 1.0)

return gxpc
