local log = frequire("moot.src.lib.log")

mdt = {}
mdt.builder = frequire("moot.src.mdt.builder")
mdt.parser = frequire("moot.src.mdt.parser")

local group = "mdt"

-- handle GMCP by saving the map on gmcp delivery then displaying it when we see room exits
mdt.written_data = nil

function mdt.parse_written_callback()
    log.debug("triggered parse_written_callback from gmcp.room.writtenmap")
    mdt.written_data = mdt.parser.parse(gmcp.room.writtenmap)
    tools.enable_trigger(group, "display_parsed_map")
    tools.enable_trigger(group, "display_parsed_map2")
end

function mdt.display_parsed_map()
    tools.disable_trigger(group, "display_parsed_map")
    log.debug("triggered display_parsed_map, drawing map from written_data")
    print()
    mdt.builder.draw_map(mdt.written_data)
end
mdt.display_parsed_map2 = mdt.display_parsed_map

tools.add_regex_trigger(group, "display_parsed_map",  "\\[.*\\][\\.]?$")
tools.add_regex_trigger(group, "display_parsed_map2",  "^There are \\w+ obvious exits:")
tools.disable_trigger(group, "display_parsed_map")
tools.disable_trigger(group, "display_parsed_map2")

-- handle 'map text' using a multiline trigger (map text produces multiple lines of output on large markets)
mdt.written_str = ""
function mdt.parse_written_output(line)
    if mdt.written_str then
        mdt.written_str = mdt.written_str .. " " .. line
    else 
        mdt.written_str = line
    end
    if line:find("here.", -5, true) then
        log.debug("drawing written from mdt.parse_written_output")
        print()
        mdt.builder.draw_map(mdt.parser.parse(mdt.written_str))
        mdt.written_str = ""
    end
end
tools.add_regex_trigger(group, "parse_written_output",
    [[(?:(?:^A|, a|^An|, an) (?:door|exit) (?:north|northeast|east|southeast|south|southwest|west|northwest) of (?:(?:one|two|three|four|five) (?:north|northeast|east|southeast|south|southwest|west|northwest)|here)(?:, |\\.$)|(?:^Exits|^Doors|, exits) (?:north|northeast|east|southeast|south|southwest|west|northwest)|(?:one|two|three|four|five) (?:north|northeast|east|southeast|south|southwest|west|northwest)(?:, |\\.$)|the limit of your vision is)]],
    {args = {"line"},
     prerun = "deleteLine()"})
mdt.event_id = registerAnonymousEventHandler("gmcp.room.writtenmap", "mdt.parse_written_callback")

return mdt