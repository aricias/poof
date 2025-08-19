local npcdb = frequire("moot.src.lib.npcdb")
local log = frequire("moot.src.lib.log")
local util = frequire("moot.src.lib.util")

local NpcL = {}

function NpcL:new()
    local o = {data = {}, -- table of all npc data
               count = 0,
               players = {}, -- list of player names
               mov_names = {},
               static_names = {},
               totalxp = 0,
               movxp = 0,
               staticxp= 0,}
    self.__index = self
    setmetatable(o, self)
    return o
end

function get_xp(name)
    local sheet = npcdb.db[npcdb.area]
    local row = db:fetch(sheet, db:eq(sheet.name, name))[1]
    if row then
        if log.LOG_LEVEL > 5 then
            cecho("<green>npcdb found - " .. row.count .. " ".. name .. ": " .. row.avg .. "\n")
        end
        return row.avg
    else
        if log.LOG_LEVEL > 5 then
            cecho("<red>npcdb not found - " .. name .. "\n")
        end
    end

    -- fallback to regex
    if util.zero_re:find(name) then
        return 0
    elseif util.high_re:find(name) then
        return 10000
    elseif util.mid_high_re:find(name) then
        return 5000
    elseif util.mid_re:find(name) then
        return 2500
    elseif util.low_mid_re:find(name) then
        return 1250
    elseif util.low_re:find(name) then
        return 625
    end

    --log.err(could not determine xp for '" .. name .. "', using 300")
    return nil
end

function NpcL.from_list(l)
    local npcl = NpcL:new()
    local total_count = 0
    local no_xp_vals = {}

    for i=1, #l do
        local splits = util.split(l[i], ' ')
        local count = util.number_strings[splits[1]]
        local name = l[i]
        local player = nil
        if count then
            if count > 1 then
                splits[#splits] = util.unpluralize(splits[#splits])
            end
            name = table.concat(splits, ' ', 2)
        elseif who.player_re then -- unique npc or player
            player = who.player_re:match(name)
        end
        
        if not count then
            count = 1
        end

        if player then
            npcl.players[#npcl.players+1] = player
        else
            local xp = get_xp(name)
            if not xp then
                no_xp_vals[#no_xp_vals+1] = name
                xp = 300
            end

            -- data and count
            if npcl.data[name] then
                npcl.data[name] = npcl.data[name] + count
            else
                npcl.data[name] = count
            end
            npcl.count = npcl.count + count
            npcl.totalxp = npcl.totalxp + xp * count

            -- mov_name, static_name
            if util.npc_static_re:find(name) then
                npcl.static_names[#npcl.static_names+1] = name
                npcl.staticxp = npcl.staticxp + xp * count
            else
                npcl.mov_names[#npcl.mov_names+1] = name
                npcl.movxp = npcl.movxp + xp * count
            end
        end
    end

    if #no_xp_vals > 0 then
        log.debug("npcdb no entries found for: " .. table.concat(no_xp_vals, ' '))
    end

    return npcl
end

function NpcL:tostring()
    local lines = {'{', '\tdata:', nil}
    for k, v in pairs(self.data) do
        lines[#lines+1] = '\t\t' .. k .. ': ' ..  v
    end
    lines[#lines+1] = '\tcount: ' .. self.count

    lines[#lines+1] = '\tplayers: '
    for i=1, #self.players do
        lines[#lines+1] = '\t\t' .. self.players[i]
    end

    lines[#lines+1] = '\tmov_names: '
    for i=1, #self.mov_names do
        lines[#lines+1] = '\t\t' .. self.mov_names[i]
    end

    lines[#lines+1] = '\tstatic_names: '
    for i=1, #self.static_names do
        lines[#lines+1] = '\t\t' .. self.static_names[i]
    end

    lines[#lines+1] = '\tmovxp: ' .. self.movxp
    lines[#lines+1] = '\tstaticxp: ' .. self.staticxp
    lines[#lines+1] = '\ttotalxp: ' .. self.totalxp

    return table.concat(lines, '\n') .. '\n}'
end

return NpcL
