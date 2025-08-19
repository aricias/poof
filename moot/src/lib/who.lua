local util = frequire("moot.src.lib.util")

local rex = frequire "rex_pcre"

who = who or {}

who.compiled_players = who.compiled_players or false

who.player_list = who.player_list or {}
who.player_re = who.player_re or rex.new("^STANDINREGEX$")

local name_re = rex.new("^\\w+")

local function compile_regex()
    local ptable = {"(?:^|\\b)(?:", nil, nil}
    for i=1, #who.player_list do
        ptable[#ptable+1] = who.player_list[i]
        ptable[#ptable+1] = '|'
    end
    ptable[#ptable+1] = "noplayereverinever)(?:$|\\b)"
    who.player_re = rex.new(table.concat(ptable, ''))
end

local n_add_player_list = "add_player_list"
who[n_add_player_list] = function(line)
    local list = util.split(line, ' ')
    if list[2] == 'Creator:' or list[2] == 'Creators:' then
        who.player_list = {}
    elseif list[2] == 'Players:' then
        who.compiled_players = true
        for i=3, #list do
            who.player_list[#who.player_list+1] = list[i]
        end
        compile_regex()
    else
        for i=3, #list do
            who.player_list[#who.player_list+1] = name_re:match(list[i])
        end
    end
end

local n_player_login = "player_login"
who[n_player_login] = function(line)
    local index = string.find(line, ' ')
    local player = string.sub(line, 2, index)
    who.player_list[#who.player_list+1] = player
    compile_regex()
end

local n_player_logoff = "player_logoff"
who[n_player_logoff] = function(line)
    local index = string.find(line, ' ')
    local player = string.sub(line, 2, index)
    local arri = -1
    for i=1, #who.player_list do
        if who.player_list[i] == player then
            arri = i
        end
    end
    if arri > -1 then
        who.player_list[arri] = "STANDINVALUE" -- cheap compared to remove+consolidate
    end
    compile_regex()
end

--TRIGGERS
local group = "who"

local opts = {args = {"line"}}
tools.add_regex_trigger(group, n_add_player_list,
    "^\\d+ (?:Creator(s)?|Playtesters?|Friends|Players): (?:.+)$", opts)
tools.add_regex_trigger(group, n_player_logoff, "^\\[\\w+ leaves Discworld", opts)
tools.add_regex_trigger(group, n_player_login, "^\\[\\w+ enters Discworld", opts)

return who