local tools = frequire("moot.src.lib.tools")

xpc = xpc or {}

xpc.xpc_history = xpc.xpc_history or {}
xpc.xpc_reset = xpc_reset or os.time()

local xpc_timer_interval = 1
function xpc.xpc_xph(seconds_ago)
	local ix = math.floor(#xpc.xpc_history - (seconds_ago / xpc_timer_interval))
	if ix < 1 or ix >= #xpc.xpc_history then
		return 0
	end

	local xp = tonumber(gmcp.char.vitals.xp)
	local xph = (xp - xpc.xpc_history[ix]) / (seconds_ago / 3600)
	return xph
end

local function xpc_format_xph(seconds_ago)
    local xph = xpc.xpc_xph(seconds_ago) / 1000
    return tostring(math.ceil(xph))
end

function xpc.get_unreduc(xph, xpdiff)
    if xph < 100000 then
		return xpdiff
	end

    local reduc = math.min(1, 500000 / xph)
    local xpdiff_u = xpdiff / reduc

	return xpdiff_u

        --[[
    local kxp = xpdiff_u - xpdiff_u / (1 + 100000 / xph)
    local kxp_u = kxp * xph / 100000
    local bxp_u = xpdiff_u - kxp

    return bxp_u + kxp_u
        --]]

end

 -- overwrite the last 'seconds' of xp history with the current xp
local function xpc_dummyhis(seconds)
    local xpc_history = xpc.xpc_history
    local xp = gmcp.char.vitals.xp
    xpc_history = {}
    for i=1, seconds do
        xpc_history[i] = xp - 1.5 * (seconds - i)
    end
end

function xpc.get_xp_report()
    return {
        reset_time = string.format("%.2dm", (os.time() - xpc.xpc_reset) / 60),
        reset_xph = xpc_format_xph(os.time() - xpc.xpc_reset),
        one = "1: " .. xpc_format_xph(60) .. "  |  ",
        five = "5: " .. xpc_format_xph(300) .. "  |  ",
        ten = "10: " .. xpc_format_xph(600) .. "  |  ",
        twenty = "20: " .. xpc_format_xph(1200) .. "  |  ",
        sixty = "60: " .. xpc_format_xph(3600) .. " ",
    }

end
function xpc.print_xp_report()
    local rep = xpc.get_xp_report()
    print(rep.reset_xph .. " over " .. rep.reset_time)
    print(rep.one .. rep.five .. rep.ten .. rep.twenty .. rep.sixty)
end

function xpc.reset_xpc()
    xpc.xpc_reset = os.time()
    print("SUCCESS: xp counter reset timer reset")
end

function xpc.tick_xp()
    if gmcp.char then
        table.insert(xpc.xpc_history, tonumber(gmcp.char.vitals.xp))
    end
end

tools.add_timer("xpc", "tick_xp", 1.0)

tools.add_alias("xpc", "reset_xpc", "^xpc reset$")
tools.add_alias("xpc", "print_xp_report", "^xpc$")

return xpc
