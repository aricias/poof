local log = frequire("moot.src.lib.log")
local dbquow = frequire("moot.src.lib.dbquow")

quowmap = quowmap or {}

local function px2i(s)
    local s = string.gsub(s, "px", "")
    return tonumber(s)
end

quowmap.win = quowmap.win or Geyser.Container:new({
  name = "quowmap_container",
  x=0, y=0,
  width="100%", height="100%"
})

quowmap.map_image = quowmap.map_image or Geyser.Label:new({
        name = "quowmap_image",
        x = 0, y = 0,
        width = "100%", height = "100%",
    }, quowmap.win)

quowmap.center_dot = quowmap.center_dot or Geyser.Label:new({
       name = "quowmap_center_dot", color = "red",
       x = px2i(quowmap.win.container.width, false) / 2 - 4,
       y = px2i(quowmap.win.container.height, false) / 2 - 4,
       width = 11, height = 11,
   }, quowmap.win)
quowmap.center_dot:setStyleSheet([[
    border: 3px solid chartreuse;
    border-radius: 5px;
    background-color: red;
]])

local function update_map(room)
    local map_path = getMudletHomeDir() .. "/moot/assets/quowmaps/" .. dbquow.map_files[room.map_id][1]
    quowmap.map_image:setStyleSheet([[
        background-image: url("]]..map_path..[[");
        background-repeat: no-repeat;
    ]])

    local w = px2i(quowmap.win.container.width)
    local h = px2i(quowmap.win.container.height)

    local new_x = w / 2 - w - room.xpos
    local new_y = h / 2 - h - room.ypos
    local new_w = 0 - new_x
    local new_h = 0 - new_y

    --[[
    print("vals")
    print("room.xpos ", room.xpos)
    print("room.ypos ", room.ypos)
    print("w ", w)
    print("h ", h)

    print("new_x ", new_x)
    print("new_y ", new_y)

    print("new_w ", new_w)
    print("new_h ", new_h)
    --]]

    quowmap.map_image:set_constraints({x = new_x, y = new_y, width = new_w, height = new_h})
    quowmap.center_dot:set_constraints({x = w/2-4,  y = h/2-4, width=11, height=11})
end

function quowmap.on_room_id()
    local room = db:fetch(dbquow.db.rooms,
                          db:eq(dbquow.db.rooms.room_id, gmcp.room.info.identifier))
    if room == nil or room[1] == nil then
        echo("Can't find this room in the db!")
        return
    else
        room = room[1]
    end
    update_map(room)
end

-- EVENTS
registerAnonymousEventHandler("gmcp.room.info", "quowmap.on_room_id")

return quowmap