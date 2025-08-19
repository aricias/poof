local util = frequire("moot.src.lib.util")
local tools = frequire("moot.src.lib.tools")
local xpc = frequire("moot.src.xpc")

colorscore = {}

local Status = {full_hp = util.Rgb:new{107,142,35},
                hurt_hp = util.Rgb:new{255,255,0},
                wound_hp = util.Rgb:new{255,0,0},

                full_gp = util.Rgb:new{107,142,35},
                half_gp = util.Rgb:new{100,149,237},
                no_gp = util.Rgb:new{147,112,219},

                no_xp = util.Rgb:new{107,142,35},
                low_xp = util.Rgb:new{255,255,255},
                mid_xp = util.Rgb:new{255,255,0},
                high_xp = util.Rgb:new{255,0,0},}
function Status:new()
    local o = {hp=0, maxhp=0, hp_delta=0,
               gp=0, maxgp=0, gp_delta=0,
               xp=0, xp_delta=0,
               burden=0,}
    self.__index = self
    setmetatable(o, self)
    return o
end
function Status:hp_line()
    return string.format('Hp:%d(%d)%s',
            self.hp, self.maxhp, self:delta_string(self.hp_delta))
end
function Status:hp_color()
    if self.maxhp == 0 then
        return self.full_hp
    end

    local third = 1/3
    local ratio = self.hp / self.maxhp
    local color = self.wound_hp
    if ratio > 2 * third then
        local percent = 1 - ((ratio - 2 * third) / third)
        color = util.rgb_gradient(self.full_hp, self.hurt_hp, percent)
    elseif ratio >= third then
        local percent = 1 - ((ratio - third) / third)
        color = util.rgb_gradient(self.hurt_hp, self.wound_hp, percent)
    end
    return color
end
function Status:gp_color()
    if self.max_gp == 0 then
        return self.full_gp
    end
    local half = 0.5
    local ratio = self.gp / self.maxgp
    if ratio >= half then
        local percent = 1 - ((ratio - half) / half)
        return util.rgb_gradient(self.full_gp, self.half_gp, percent)
    else
        local percent = 1 - (ratio / half)
        return util.rgb_gradient(self.half_gp, self.no_gp, percent)
    end
end
function Status:xp_color()
    local minxp = 1000
    if self.xp_delta <= minxp then
        return self.no_xp
    end
    -- TODO: determina lua equiv of math.log10
    local ratio = math.log10(self.xp_delta - minxp)
    if ratio <= 4 then
        return util.rgb_gradient(self.no_xp, self.low_xp, ratio / 4.0)
    elseif ratio <= 5 then
        return util.rgb_gradient(self.low_xp, self.mid_xp, ratio / 5.0)
    elseif ratio <= 6 then
        return util.rgb_gradient(self.mid_xp, self.high_xp, ratio / 6.0)
    else
        return self.high_xp
    end
end
function Status:gp_line()
    return string.format("Gp:%d(%d)%s",
                self.gp, self.maxgp, self:delta_string(self.gp_delta))
end
function Status:xp_line()
    local delta = ''
    if self.xp_delta ~= 0 then
        delta = tostring(self.xp_delta)

        -- TODO: how to cal xpc_xph, which is defined in xml for thebeast?
        xp_rate = xpc.xpc_xph(60*10)
        if xp_rate ~= 0 then
            delta = string.format("%s %d/10", delta, xp_rate)
        end
        xp_rate = xpc.xpc_xph(3600)
        if xp_rate ~= 0 then
            delta = string.format("%s %d/h", delta, xp_rate)
        end
    end
    return string.format("Xp:%d[%s]", self.xp, delta)
end
function Status:delta_string(delta)
    if delta == 0 then
        return ''
    end
    return string.format("[%d]", delta)
end

local status = Status:new()
local defbg = util.Rgb:new{}
local function run_monitor(hp, maxhp, gp, maxgp, xp, burden)
    status.hp_delta = hp - status.hp
    status.hp = hp
    status.maxhp = maxhp

    status.gp_delta = gp - status.gp
    status.gp = gp
    status.maxgp = maxgp

    status.xp_delta = xp - status.xp
    status.xp = xp
    if burden then
        status.burden = burden
    end

    local hpl = util.Dstr:new(util.pad_string(status:hp_line(), 21),
                              status:hp_color(), defbg)
    local gpl = util.Dstr:new(util.pad_string(status:gp_line(), 18),
                              status:gp_color(), defbg)
    local xpl = util.Dstr:new(status:xp_line(), status:xp_color(), defbg)
    decho(hpl:tostring())
    decho(gpl:tostring())
    decho(xpl:tostring())
end

local n_on_monitor = "on_monitor"
colorscore[n_on_monitor] = function(matches)
    deleteLine()

    local hp = matches[2]
    local maxhp = matches[3]
    local gp = matches[4]
    local maxgp = matches[5]
    local xp = matches[6]
    local burden = matches[7] or 0
    print()
    run_monitor(hp, maxhp, gp, maxgp, xp, burden)
end

-- TRIGGERS
local group = "colorscore"

tools.add_regex_trigger(group, n_on_monitor,
    "^Hp: +(\\d{1,4}) *\\((\\d{3,4})\\) +Gp: +(\\d{1,3}) *\\((\\d{2,3})\\) +Xp: +(\\d+)(?: +Burden: (\\d+)%)?",
    {args = {"matches"}})

return coloscore
