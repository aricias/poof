-- msco (Multi Source Console) is a single console with tabs to toggle display of different sources. 
-- All displayed sources are in the order they're received.
local os = require("os")
local statedb = frequire("moot.src.lib.statedb")

local Line = {}
function Line:new(source, line)
    local o = {}
    self.__index = self
    setmetatable(o, self)
    o.source = source
    o.line = line
    o.timestamp = os.date("%X")
    return o
end
function Line:format()
    return self.timestamp .. " " .. self.line
end

local Msco = {
    name = "mscosingleton_",
    tabs = {"please pass tab names"},
    sources = {"please pass source names"},
    tab_height = 22, -- px
    active_tab_bg_color = "LightSeaGreen",
    inactive_tab_bg_color = "DarkSlateGrey",
    tab_fg_color = "white",
    font = "Bitstream Vera Sans Mono",
    refs = {} -- global table of references to all msco objects
}
function Msco:new(name, sources, tabs)
    -- name: name main geyser container name as well as the name we can reference this msco instance
    --       using Msco[name]
    -- sources: a list of strings, each string is the name of source that can be enabled or disable
    -- tabs: a list of strings, each string is the name of a tab that when clicked, shows a set of sources
    --       individual sources can be enabled/disabled per tab by right-clicking the tab

    local o = {}
    self.__index = self
    setmetatable(o, self)

    if #name > 0 then o.name = name end
    if #sources > 0 then o.sources = sources end
    if #tabs > 0 then o.tabs = tabs end
    Msco.refs = Msco.refs or {}
    Msco.refs[o.name] = o

    o.active_sources = {}
    for i=1, #o.tabs do
        local t = o.tabs[i]
        o.active_sources[t] = o.sources
    end
    o.active_tab = o.tabs[1]
    o.lines = {}

    o.win = Geyser.Container:new({name=o.name, x=0, y=0, width="100%", height="100%"})
    o.tabbox_label = Geyser.Label:new(
        {name=o.name.."_tabbox_label", x=0, y=0, width="100%", height=o.tab_height}, o.win)
    o.tabbox = Geyser.HBox:new({name=o.name.."_tabbox", x=0, y=0, width="100%", height="100%"}, o.tabbox_label)
    o.tab_labels = o:make_tabs(o.tabs, o.tabbox)
    o.console = Geyser.MiniConsole:new({
        name=o.name.."_console",
        x=0, y=o.tab_height + 2, width="100%", height="100%",
        autoWrap=true, color="black",
        scrollBar=false, fontSize=10}, o.win)

    o:load_history()

    return o
end
function Msco:load_history()
    local line_history = db:fetch(statedb.db.msco, db:eq(statedb.db.msco.name, self.name))
    for i=1, #line_history do
        local row = line_history[i]
        self.lines[#self.lines+1] = Line:new(row.source, row.raw_line)
    end
    self:refresh_lines()
end
function Msco:make_tabs(tabs, parent)
    local labels = {}
    for i=1, #tabs do
        local t = tabs[i]

        local bg_color
        if t == self.active_tab then
            bg_color = self.active_tab_bg_color
        else
            bg_color = self.inactive_tab_bg_color
        end

        local l = Geyser.Label:new({
            name = self.name .. t,
            fgColor = self.tab_fg_color,
            color = bg_color, font=self.font,
            message = "<center>" .. t .. "</center",
        }, parent)
        l:createRightClickMenu({
            MenuItems = self.sources,
            Style = "Dark", 
            MenuWidth2 = 80, 
            MenuFormat1 = "c10",
            MenuStyle2 = [[QLabel::hover{ background-color: rgba(0,255,150,100%); color: white;} QLabel::!hover{color: brown; background-color: rgba(100,240,240,100%);} ]]
        })
        for i=1, #self.sources do
            local s = self.sources[i]
            l:setMenuAction(s, self.source_clicked, self.name, s, t)
            local el = l:findMenuElement(s)
            if self:is_active_source(s, t) then
                el:setStyleSheet("background-color: " .. self.active_tab_bg_color .. ";")
            else
                el:setStyleSheet("background-color: " .. self.inactive_tab_bg_color .. ";")
            end
        end
        l:setClickCallback(self.tab_clicked, self.name, t)
        labels[t] = l
    end
    return labels
end
function Msco.tab_clicked(msco_name, tab_name, evt)
    local o = Msco.refs[msco_name]
    o.tab_labels[tab_name]:onRightClick(evt)
    if evt.button == "LeftButton" then
        if tab_name ~= o.active_tab then
            o.tab_labels[o.active_tab]:setStyleSheet(
                "background-color: " .. o.inactive_tab_bg_color .. ";")
            o.tab_labels[tab_name]:setStyleSheet(
                "background-color: " .. o.active_tab_bg_color .. ";")
            o.active_tab = tab_name
            o:refresh_lines()
        end
    end
end
function Msco.source_clicked(msco_name, source_name, tab_name)
    local o = Msco.refs[msco_name]
    local menu_element = o.tab_labels[tab_name]:findMenuElement(source_name)
    if o:is_active_source(source_name, tab_name) then
        menu_element:setStyleSheet("background-color: " .. o.inactive_tab_bg_color .. ";")
        o:disable_source(source_name, tab_name)
    else
        menu_element:setStyleSheet("background-color: " .. o.active_tab_bg_color .. ";")
        o:enable_source(source_name, tab_name)
    end
end
function Msco:is_active_source(n, tabname)
    local t = tabname or self.active_tab
    local srcs = self.active_sources[t]
    for i=1, #srcs do
        if n == srcs[i] then
            return true
        end
    end
    return false
end
function Msco:display_line(l)
    -- l : Line object
    if self:is_active_source(l.source) then
        self.console:decho(l:format() .. "\n")
    end
end
function Msco:add_line(source, line)
    local l = Line:new(source, line)
    self.lines[#self.lines+1] = l
    self:display_line(l)
    -- only add it to the db if we add it we can successfully process it
    db:add(statedb.db.msco, {name=self.name, source=source, raw_line=line})
end
function Msco:refresh_lines()
    self.console:clear()
    for i=1, #self.lines do
        local l = self.lines[i]
        self:display_line(l)
    end
end

function Msco:set_menu_element_style(s, t)
    local t = t or self.active_tab
end
function Msco:enable_source(s, t)
    local t = t or self.active_tab

    -- change the background
    local menu_element = self.tab_labels[t]:findMenuElement(s)
    menu_element:setStyleSheet("background-color: " .. self.active_tab_bg_color .. ";")

    -- add s to actives sources for t
    local new_sources = {s}
    local srcs = self.active_sources[t]
    for i=1, #srcs do
        local s2 = srcs[i]
        if s ~= s2 then
            new_sources[#new_sources+1] = s2
        end
    end
    self.active_sources[t] = new_sources
    self:refresh_lines()
end
function Msco:disable_source(s, t)
    local t = t or self.active_tab

    -- change the background
    local menu_element = self.tab_labels[t]:findMenuElement(s)
    menu_element:setStyleSheet("background-color: " .. self.inactive_tab_bg_color .. ";")

    -- remove s from actives sources for t
    local new_sources = {}
    local srcs = self.active_sources[t]
    for i=1, #srcs do
        local s2 = srcs[i]
        if s ~= s2 then
            new_sources[#new_sources+1] = s2
        end
    end
    self.active_sources[t] = new_sources
    self:refresh_lines()
end

return {
    Msco = Msco,
    Line = Line
}