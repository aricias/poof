local EMCO = frequire("moot.src.lib.emco")
local tools = frequire("moot.src.lib.tools")

--Chats = Chats or {}
Chats = {}
Chats.chatEMCO = Chats.chatEMCO or EMCO:new({
  name = "Chats",
  x = 0,
  y = 0,
  height = "100%",
  width = "100%",
  consoles = {"All", "room", "talker", "tell", "group", "lel", "misc"},
  allTab = true,
  allTabName = "All",
  blankLine = true,
  blink = true,
  bufferSize = 10000,
  deleteLines = 500,
  timestamp = true,
  fontSize = 10,
  font = "Bitstream Vera Sans Mono",
  commandLine = false,
})
local chatEMCO = Chats.chatEMCO
local filename = getMudletHomeDir() .. "/EMCO/" .. Chats.chatEMCO.name .. ".lua"
if io.exists(filename) then
  chatEMCO:load()
end
function Chats.echo(msg)
  msg = msg or ""
  cecho(f"<green>Chats: <reset>{msg}\n")
end

function Chats.load()
  if io.exists(filename) then
    chatEMCO:load()
  end
end

function Chats.save()
  chatEMCO:save()
end

-- TRIGGERS 

local group = "Chats"

local n_on_talker = "on_talker"
Chats[n_on_talker] = function(line)
  chatEMCO:decho("talker", copy2decho())
end
tools.add_regex_trigger(group, n_on_talker, "^\\(.*\\) \\w+ wisps:? .*$", {args = {"line"}})

local n_on_group = "on_group"
Chats[n_on_group] = function(line)
  chatEMCO:decho("group", copy2decho())
end
tools.add_regex_trigger(group, n_on_group, "^\\[.*\\] .*$", {args = {"line"}})

local n_on_tell = "on_tell"
local n_on_tell2 = "on_tell2"
Chats[n_on_tell] = function(line)
  chatEMCO:decho("tell", copy2decho())
end
Chats[n_on_tell2] = Chats[n_on_tell]

tools.add_regex_trigger(group, n_on_tell, " (?:asks|exclaims|tells)(?:to|to .* and)? you:", {args = {"line"}})
tools.add_regex_trigger(group, n_on_tell2, "^You (?:ask|exclaim|tell) .*:", {args = {"line"}})

return Chats