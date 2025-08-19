local tools = frequire("moot.src.lib.tools")
local log = frequire("moot.src.lib.log")
local statedb = frequire("moot.src.lib.statedb")

local group = "settings"

settings = settings or {}
settings.recorded = settings.recorded or {}
settings.win = settings.win or Geyser.Container:new({
    name="Settings", x=0, y=0, width="100%", height="100%"})
settings.left_vbox = settings.left_vbox or Geyser.VBox:new({
    name="settings.left_vbox", x=0, y=0, 
    width=160, height=120}, settings.win)

local button_style = [[
    QLabel{ 
        margin: 3px;
        border-radius: 4px;
        border: 4px double DarkSlateGrey;
    }
    QLabel::hover{
        background-color: rgba(0,0,0,0%);
        border: 4px double LightSeaGreen;
        border-radius: 4px;
    }
]]
settings.set_mud_lbl = settings.set_mud_lbl or Geyser.Label:new({
    name="settings.set_mud_lbl", }, settings.left_vbox)
settings.set_mud_lbl:setStyleSheet(button_style)
settings.set_mud_lbl:setClickCallback("settings.set_mud_settings")
settings.set_mud_lbl:echo("Set discworld options", nil, "c")
settings.set_mud_lbl:setToolTip("Send commands to the mud to set a character's options to values compatibile with this plug")

settings.set_mudlet_lbl = settings.set_mudlet_lbl or Geyser.Label:new({
    name="settings.set_mudlet_lbl", }, settings.left_vbox)
settings.set_mudlet_lbl:setStyleSheet(button_style)
settings.set_mudlet_lbl:setClickCallback("settings.set_mudlet_settings")
settings.set_mudlet_lbl:echo("Set mudlet settings", nil, "c")
settings.set_mudlet_lbl:setToolTip("Currently does nothing. Will set mudlet options when important ones are found")

local Option = {}
Option.__index = Option
function Option:new(opt, set_to)
    local o = {}
    setmetatable(o, self)
    o.opt = opt
    -- use for sending to the mud
    o.opt_str = table.concat(o.opt, " ")
    -- use in codea s a human readable unique identifier
    o.opt_name = table.concat(o.opt, "_")
    o.set_to = set_to
    o.old = db:fetch(statedb.db.mud_options, db:eq(statedb.db.mud_options.name, o.opt_name))[1]

    if o.old then
        o.old = o.old.old_val
        log.debug(string.format("option '%s' is originally set as %s", o.opt_name, o.old))
    end

    -- add a trigger to record the option setting if we haven't recorded it already
    settings[o.opt_name] = function(matches)
        o:disable_trigger()
        if o.old then
            print()
            log.info(string.format("NOT recording option '%s' as we've previously recorded it as '%s'", o.opt_name, o.old))
            return
        end
        settings.recorded[o.opt_name] = matches[2]
        db:add(statedb.db.mud_options, {name=o.opt_name, old_val=matches[2]})
        print()
        log.info(string.format("Recorded option '%s' as '%s'", o.opt_name, matches[2]))
    end
    local rex = string.gsub(o.opt_str, "^%l", string.upper) .. "\\s+= (\\w+)"
    log.debug(string.format("%s rex: '%s'", o.opt_str, rex))
    tools.add_regex_trigger(group, o.opt_name, rex, {args = {"matches"}})

    return o
end
function Option:set()
    local cmd = string.format("options %s = %s", self.opt_str, self.set_to)
    send(cmd)
end
function Option:enable_trigger()
    log.debug("enable trigger " .. self.opt_name)
    enableTrigger(group, self.opt_name)
end
function Option:disable_trigger()
    log.debug("disable trigger " .. self.opt_name)
    disableTrigger(group, self.opt_name)
end
function Option:record_old()
    local cmd = string.format("options %s", self.opt_str)
    send(cmd)
end

local opts = {
    Option:new({"output", "map", "written"}, "on"),
    Option:new({"output", "map", "lookcity"}, "off"),
    Option:new({"output", "map", "glancecity"}, "off"),
}

function settings.set_mud_settings()
    log.info("Sending commands to record your current options..")
    for i=1, #opts do
        local o = opts[i]
        o:enable_trigger()
        o:record_old()
    end

    log.info("Sending commands to set your new options..")
    for i=1, #opts do
        local o = opts[i]
        o:disable_trigger()
        o:set()
    end
end

function settings.set_mudlet_settings()
    return 1
end

return settings