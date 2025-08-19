local tools = frequire("moot.src.lib.tools")
local Msco = frequire("moot.src.msco").Msco

chats2 = chats or {}
chats2.msco = Msco:new("chats2", {"talker", "tells", "group"}, {"1", "2", "3"})

function chats2.add_line(source, line) 
    chats2.msco:add_line(source, line)
end

-- TRIGGERS 
local group = "chats2"

function chats2.on_talker(line)
    chats2.add_line("talker", copy2decho())
end
tools.add_regex_trigger(group, "on_talker", "^\\(.*\\) \\w+ wisps:? .*$", {args = {"line"}})

function chats2.on_group(line)
    chats2.add_line("group", copy2decho())
end
tools.add_regex_trigger(group, "on_group", "^\\[.*\\] .*$", {args = {"line"}})

function chats2.on_tell(line)
    chats2.add_line("tells", copy2decho())
end
chats2.on_tell2 = chats2.on_tell

-- TODO break this up into 3 triggers to easy the burden on the regex engine
tools.add_regex_trigger(group, "on_tell", " (?:asks|exclaims|tells)(?: to| to .* and| .* and)? you:", {args = {"line"}})
tools.add_regex_trigger(group, "on_tell2", "^You (?:ask|exclaim|tell) .*:", {args = {"line"}})

return chats2