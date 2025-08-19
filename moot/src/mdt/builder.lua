local util = frequire("moot.src.lib.util")
local log = frequire("moot.src.lib.log")

local Rgb = util.Rgb

local atoz = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local symbols = "0123456789" .. atoz
local psyms = "ABCDEFGH"
local pcolors = {A = util.Rgb:new{204, 0, 204},
                 B = util.Rgb:new{102, 0, 204},
                 C = util.Rgb:new{255, 102, 255},
                 D = util.Rgb:new{178, 102, 255},
                 E = util.Rgb:new{76, 0, 153},
                 F = util.Rgb:new{153, 0, 153},
                 G = util.Rgb:new{204, 153, 255},
                 H = util.Rgb:new{255, 153, 255},}

local exits = {
	north      = {{0, -1}, '|'},
	northeast  = {{1, -1}, '/'},
	east       = {{1, 0}, '-'},
	southeast  = {{1, 1}, '\\'},
	south      = {{0, 1}, '|'},
	southwest  = {{-1, 1}, '/'},
	west       = {{-1, 0}, '-'},
	northwest  = {{-1, -1}, '\\'}
}

local player_rooms = 0

local Room = {def_sym = ' ',
              def_fg = Rgb:new{255,255,255},
              def_bg = Rgb:new{0,0,0}}
function Room:new(sym, fg, bg)
    local o = {npcl = nil,
               sym = sym or self.def_sym,
               fg = fg or self.def_fg,
               bg = bg or self.def_bg,}
    self.__index = self
    setmetatable(o, self)
    return o
end
function Room:draw()
    decho(string.format("<%d,%d,%d:%d,%d,%d>%s",
                        self.fg.r, self.fg.g, self.fg.b,
                        self.bg.r, self.bg.g, self.bg.b,
                        self.sym))
end
function Room:set_exit(d)
    if self.sym ~= ' ' and self.sym ~= exits[d][2] then
        self.sym = 'x'
    else
        self.sym = exits[d][2]
    end
end
function Room:set_empty()
    if self.sym == ' ' then
        self.sym = '*'
        self.fg = Rgb:new{0,0,255}
    end
end
function Room:set_door()
    self.sym = '+'
    self.fg = Rgb:new{178,34,34}
end
function Room:set_npcs(npcl)
    self.npcl = npcl
    if #self.npcl.players > 0 then
        player_rooms = player_rooms + 1
        self.sym = psyms:sub(player_rooms, player_rooms)
        self.fg = pcolors[self.sym]
    else
        self.sym = sym_from_xp(self.npcl.movxp)
        self.fg = rgb_from_xp(self.npcl.movxp)
        self.bg = rgb_static_from_xp(self.npcl.staticxp)
        self.fg = fg_from_bg(self.fg, self.bg)
    end
end

function newmap()
    local map = {nil, nil, nil}
    for i=1, 23 do
        map[i] = {nil, nil, nil}
        for j=1, 23 do
            map[i][j] = Room:new()
        end
    end
    -- origin
    map[12][12] = Room:new('@', Rgb:new{255,255,0}, Rgb:new{0,0,0})
    return map
end

local who = frequire("moot.src.lib.who")

function draw_map(paths)
    player_rooms = 0

    -- compile map and npc_list
    local map = newmap()
    local npc_list = {}
    local max_chars = getColumnCount() - #map - 2
    for i=1, #paths do
        local p = paths[i]
        insert_path(map,p)
        if p.type == 'npc' then
            insert_npclines(npc_list, p, max_chars)
        end
    end

    -- write map and npc_list to screen
    local lines_printed = 0
    for i=1, #map do
        local has_data = false
        for k=1, #map[i] do
            if map[i][k].sym ~= ' ' then
                has_data = true
                break
            end
        end
        if has_data then
            lines_printed = lines_printed + 1

            for k=1, #map[i] do
                r = map[i][k]
                r:draw()
            end

            if lines_printed <= #npc_list then
                decho(npc_list[lines_printed])
            end
            echo('\n')
        end
    end
    while lines_printed < #npc_list do
        lines_printed = lines_printed + 1
        local line = "                       " .. npc_list[lines_printed]
        decho(line)
        echo('\n')
    end

    if not who.compiled_players then
        print("No player list, run 'qwho' to fix")
    end
end

function insert_path(map, path)
    local dirs = path.path
    local x,y = 12,12
    local r = map[y][x]

    for i=1, #dirs do
        local d = dirs[i]
        if exits[d] then
            x = x + exits[d][1][1]
            y = y + exits[d][1][2]
            r = map[y][x]
            r:set_exit(d)

            x = x + exits[d][1][1]
            y = y + exits[d][1][2]
            r = map[y][x]
            r:set_empty()
        end
    end
    if path.type == 'npc' and (y ~= 12 or x ~= 12) then
        r:set_npcs(path.npcl)
    end

    for i=1, #path.exits do
        local d = path.exits[i]
        if exits[d] then
            r = map[y + exits[d][1][2]][x + exits[d][1][1]]
            if path.type == 'door' then
                r:set_door()
            elseif path.type == 'exit' then
                r:set_exit(d)
            end
        end
    end
end

function insert_npclines(npc_list, path, max_chars)
    if max_chars < 20 then
        max_chars = 20
    end

    local dstrs = {}

    local n = path.npcl
    local sym,fg,bg
    bg = Rgb:new{0,0,0}
    if #n.players > 0 then
        sym = psyms:sub(player_rooms, player_rooms)
        fg = pcolors[sym]
    else
        sym = sym_from_xp(n.movxp)
        fg = rgb_from_xp(n.movxp)
        bg = rgb_static_from_xp(n.staticxp)
        fg = fg_from_bg(fg, bg)
    end

    local txt = sym .. ': '
    dstrs[#dstrs+1] = util.Dstr:new(txt, fg, bg)
    txt = ''

    if #n.players > 0 then
        txt = txt .. table.concat(n.players, ', ')
        if n.count > 0 then
            txt = txt .. ' | '
        end
    end
    txt = txt .. format_multiple_npcs(n)
    txt = txt .. " (" .. format_path(path.path) .. ")"

    dstrs[#dstrs+1] = util.Dstr:new(txt, fg, bg)

    local lines = util.Dstr.get_lines(dstrs, max_chars)
    for i=1, #lines do
        npc_list[#npc_list+1] = lines[i]
    end
end

local dirsmap = {north='n', northeast='ne', east='e', southeast='se',
                 south='s', southwest='sw', west='w', northwest='nw',
                 up='u', down='d',}
function format_path(p)
    local path_str = ""
    local i = 1
    while i <= #p do
        local d = nil
        local dcount = 0
        repeat
            d = p[i]
            if dirsmap[d] then
                d = dirsmap[d]
            end
            dcount = dcount + 1
            i = i + 1
        until i > #p or p[i] ~= p[i-1]

        if dcount > 1 then
            path_str = path_str .. dcount
        end
        path_str = path_str .. d .. ", "
    end

    return path_str:sub(1,-3)
end

-- TODO: port?
function format_multiple_npcs(npcl)
    if npcl.count == 0 and #npcl.players == 0 then
        log.err("tried to format empty npc list")
        return 'FAIL'
    end

    local short_data = {}
    for n, c in pairs(npcl.data) do
        local nn = util.first_re:match(n)
        if not nn then
            nn = util.second_re:match(n)
        end
        if not nn then
            nn = n
        end
        if short_data[nn] then
            short_data[nn] = short_data[nn] + c
        else
            short_data[nn] = c
        end
    end

    local npc_str = ""
    for name, count in pairs(short_data) do
        if count > 1 then
            npc_str = npc_str .. util.count_to_str(count) .. " "
            npc_str = npc_str .. util.pluralize(name) .. ", "
        else
            npc_str = npc_str .. name .. ", "
        end
    end
    return npc_str:sub(1, -3)
end

local xp_step = 2000
local xp_cap = xp_step * #symbols
local cranges = {
    {Rgb:new{64,64,64}, Rgb:new{192,192,192}}, -- grays
    {Rgb:new{102,102,0}, Rgb:new{220,220,0}},  -- yellows
    --{Rgb:new{0,76,153}, Rgb:new{0,128,255}},   -- blue-cyans
    {Rgb:new{0,102,102}, Rgb:new{0,220,220}},  -- cyans
    {Rgb:new{0,102,0}, Rgb:new{0,220,0}},      -- greens
    {Rgb:new{102,0,0}, Rgb:new{220,0,0}},      -- reds
    {Rgb:new{102,0,51}, Rgb:new{255,0,127}},   -- pinks
}

function rgb_static_from_xp(xp)
    local rgb = rgb_from_xp(xp)
    local down = 80
    rgb.r = rgb.r - down
    rgb.g = rgb.g - down
    rgb.b = rgb.b - down
    if rgb.r < 0 then rgb.r = 0 end
    if rgb.g < 0 then rgb.g = 0 end
    if rgb.b < 0 then rgb.b = 0 end
    return rgb
end
function rgb_from_xp(xp)
    local rstep = xp_cap / #cranges
    local i = math.floor(xp / rstep) + 1
    local percent = (xp % rstep) / rstep

    if i > #cranges then
        return cranges[#cranges][2]
    end
    local cr = cranges[i]
    local r,g,b = 0,0,0
    if cr[1].r ~= cr[2].r then
        local diff = (cr[2].r - cr[1].r) * percent
        r = cr[1].r + diff
    end
    if cr[1].g ~= cr[2].g then
        local diff = (cr[2].g - cr[1].g) * percent
        g = cr[1].g + diff
    end
    if cr[1].b ~= cr[2].b then
        local diff = (cr[2].b - cr[1].b) * percent
        b = cr[1].b + diff
    end

    return Rgb:new{r,g,b}
end
function sym_from_xp(xp)
    local n = xp / xp_cap * #symbols + 1
    if n > #symbols then
        return symbols:sub(-1)
    end
    local i = math.floor(n)
    return symbols:sub(i, i)
end
function fg_from_bg(fg, bg)
    local mdiff = 30
    local black = 0
    local white = 0
    local diff = 0
    if math.abs(fg.r - bg.r) < mdiff then
        if bg.r < 255/2 then
            white = white + 1
        else
            black = black + 1
        end
    end
    if math.abs(fg.g - bg.g) < mdiff then
        if bg.g < 255/2 then
            white = white + 1
        else
            black = black + 1
        end
    end
    if math.abs(fg.b - bg.b) < mdiff then
        if bg.b < 255/2 then
            white = white + 1
        else
            black = black + 1
        end
    end
    --diff = diff + math.abs(fg.r - bg.r)
    --diff = diff + math.abs(fg.g - bg.g)
    --diff = diff + math.abs(fg.b - bg.b)
    if white + black == 3 then
    --if diff < 200 then
        if black > 1 or white > 1 then
            --log.debug("fg_from_bg firing, debug vals:")
            --log.debug("black: " .. black .. " white: " .. white)
            --log.debug(fg.r .. " " ..  fg.g .. " " .. fg.b)
            --log.debug(bg.r .. " " ..  bg.g .. " " .. bg.b)
        end
        --if black > 1 and black > white then
        if black > white then
            return Rgb:new{20,20,20}
        --elseif white > 1 then
        else
            return Rgb:new{140, 140, 140}
        end
    end
    return fg
end

return {
    draw_map = draw_map
}
