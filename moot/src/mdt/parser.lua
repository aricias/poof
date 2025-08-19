local util = frequire("moot.src.lib.util")
local NpcL = frequire("moot.src.lib.npclist")

function parse(maptext)
    local text, p = clean(maptext)

    local data = {p, nil, nil}

    local i = 1
    while text[i] do
        local f = get_parse_function(text, i)
        i, p = f(text, i)
        data[#data+1] = p
        i = i + 1
    end

    return data
end

function get_parse_function(t, i)
    if t[i] == 'a' and t[i+1] == 'door' or t[i] == 'doors' then
        return parse_door
    end

    if t[i] == 'an' and t[i+1] == 'exit'
            or t[i] == 'exits'
            or t[i] == 'a' and t[i+1] == 'hard' and t[i+2] == 'to' then
        return parse_exits
    end

    if t[i] == 'the' and t[i+1] == 'limit' then
        return parse_limit
    end

    return parse_npc
end

function new_path(type, npcl, exits, path)
    return {type=type,
            npcl=npcl,
            exits=exits,
            path=path,}
end

function parse_door(t, i)
    local paths = {nil, nil, nil}

    local exits = {nil, nil, nil}
    local p
    if t[i] == 'a' then
        exits = {t[i+2]}
        i, p = get_path(t, i+4)
    else
        local start = i
        while t[i+1] ~= 'of' and i - start < 10 do
            i = i + 1
            if t[i] == 'and' then
                i = i + 1
            end
            exits[#exits+1] = del_comma(t[i])
        end
        i, p = get_path(t, i+2)
    end

    return i, new_path('door', nil, exits, p, {})
end

function parse_exits(t, i)
    local exits = {nil, nil, nil}
    local p

    if t[i] == 'a' and t[i+1] == 'hard' and t[i+2] == 'to' then
        i = i + 4
    end

    if t[i] == 'an' or t[i] == 'through' then
        exits[#exits+1] = t[i+2]
        i, p = get_path(t, i+4)
    else
        i = i + 1
        while t[i] and t[i] ~= 'and' do
            exits[#exits+1] = del_comma(t[i])
            i = i + 1
        end
        i = i + 1
        exits[#exits+1] = t[i]
        i, p = get_path(t, i+2)
    end

    return i, new_path('exit', nil, exits, p)
end

function parse_limit(t, i)
    local p
    i, p = get_path(t, i+6)
    return i+2, new_path('limit', nil, {}, p)
end

function parse_npc(t, i)
    local npcs = {nil, nil, nil}
    local players = {}

    local and_count = 0
    local e = i
    while t[e] and not util.npc_end_re:find(t[e]) do
        if t[e] == 'and' then
            and_count = and_count + 1
        end
        e = e + 1
    end
    while i < e do
        local start_word = t[i]

        local npc_str = del_comma(t[i])
        i = i + 1
        local handle_and = t[e] == 'are'
        while not util.has_comma(t[i-1]) and i < e do
            if handle_and and t[i] == 'and' then
                if and_count == 2 and t[i+1] == 'a' or t[i+1] == 'an' then
                    handle_and = false
                    break
                elseif and_count == 1 then
                    handle_and = false
                    break
                end
                and_count = and_count - 1
            end
            npc_str = npc_str .. " " .. del_comma(t[i])
            i = i + 1
        end

        npc_str = util.strip_ansi_colours(npc_str)

        if npc_str:sub(-1, -1) == ')'
                and npc_str:sub(-9) == " (hiding)" then
            npc_str = npc_str:sub(1, #npc_str-9)
        end
        npcs[#npcs+1] = npc_str

        if t[i] == 'and' then
            i = i + 1
        end
    end
    i = e + 1

    local p
    i, p = get_path(t, i)
    
    local npcl = NpcL.from_list(npcs)
    --print(npcl:tostring())

    return i, new_path('npc', npcl, {}, p), total_player_rooms
end

function get_path(t, i)
    local p = {nil, nil, nil}

    if del_comma(t[i]) == 'here' then
        return i, p
    end

    repeat
        local count = util.str_to_count(t[i])
        for _=1, count do
            p[#p+1] = del_comma(t[i+1])
        end
        if t[i+2] == 'and' then
            i = i + 3
        else
            i = i + 2
        end
    until not util.is_count(t[i])
        or not util.is_dir(del_comma(t[i+1]))
        or not t[i]

    -- returns {index_last_word, list_of_dirs_in_path}
    return i-1, p
end

function del_comma(s)
    -- strip trailing comma
    if s == nil then
        return nil
    elseif s:sub(#s) == ',' then
        return s:sub(1, #s-1)
    else
        return s
    end
end

function clean(mt)
    local text = util.split(mt, ' ')

    if text[1] == 'A' or text[1] == 'An' or text[1] == 'The'
            or text[1] == 'Exits' or text[1] == 'Doors' then
        text[1] = text[1]:lower()
    end

    -- remove period from last word
    local last = text[#text]
    text[#text] = last:sub(1, #last - 1)

    local done = false
    local stop_i = #text - 5
    while not done and stop_i > 1 do
        if text[stop_i+1] == 'the' then
            done = true
        else
            stop_i = stop_i - 1
        end
    end

    local p = {}
    if stop_i == 1 then
        _, p = parse_limit(text, stop_i)
    else
        _, p = parse_limit(text, stop_i+1)
    end

    for i=stop_i, #text do
        text[i] = nil
    end

    return text, p
end


return {
    parse = parse
}
