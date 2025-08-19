local log = frequire("moot.src.lib.log")
local dbquow = frequire("moot.src.lib.dbquow")
local xpc = frequire("moot.src.xpc")

npcdb = npcdb or {}

npcdb.just_buried = npcdb.just_buried or false
npcdb.area = npcdb.area or "ephebe"
npcdb.last_kill = nil
local lastxp = lastxp or nil
local last_trans = last_trans or nil

local function create_npcs_db()
    tools.restore_database_if_needed("Database_npcs.db")
    local npc_schema = {name="",
                        avg=0,
                        low=0,
                        high=0,
                        count=0,
                        _unique={"name"}}
    return db:create("npcs", {am=npc_schema,
                              cwc=npc_schema,
                              ephebe=npc_schema,
                              stolat=npc_schema,
                              genua=npc_schema,
                              oc=npc_schema,
                              djb=npc_schema})
end
npcdb.db = create_npcs_db()

local function add_kill(n, xp)
	if n == nil or n == "" then
		log.err("cannot add kill for nil or emptystring")
		return
	end
	if xp == nil or xp < 100 then
		log.err("cannot add kill for nil or < 100 xp")
		return
	end

	local xph = xpc.xpc_xph(3600)
	local xp_u = xpc.get_unreduc(xph, xp)

	local npcs = db:get_database("npcs")
	local sheet = npcs[npcdb.area]
	local row = db:fetch(sheet, db:eq(sheet.name, n))[1]
	if row ~= nil then
		if xp_u < row.avg / 3 then
			log.err(xp_u .. " was more than 3 times less than the row.avg " .. row.avg)
			return
		end

		last_trans = {}
		for k, v in pairs(row) do
			last_trans[k] = v
		end

		row.avg = (row.avg * row.count + xp_u) / (row.count + 1)
		if xp_u < row.low then
			row.low = xp_u
		elseif xp_u > row.high then
			row.high = xp_u
		end
	else
		db:add(sheet, {name=n})
		row = db:fetch(sheet, db:eq(sheet.name, n))[1]
		if row == nil then
			log.err("row is empty after explicit add and fetch")
			return
		end
		row.avg = xp_u
		row.low = xp_u
		row.high = xp_u
	end
	row.count = row.count + 1

	display(row)

	db:update(sheet, row)
end

function npcdb.on_xp_update()
	local currxp = tonumber(gmcp.char.vitals.xp)
	if lastxp == nil then
		log.debug("lastxp is nil, not attempting to log to npcs db")
		lastxp = currxp
		return
	end
	local diff = currxp - lastxp
	lastxp = currxp

	if npcdb.just_buried == false or npcdb.last_kill == nil then
		 return
	end

	npcdb.just_buried = false
	local save_kill = npcdb.last_kill
	npcdb.last_kill = nil
	add_kill(save_kill, diff)
end

local name_from_id = {
  [1] = "am",
  [2] = "assassins",
  [3] = "am buildings",
  [4] = "shaker",
  [5] = "am docks",
  [6] = "am guilds",
  [7] = "isle of gods",
  [8] = "shades",
  [9] = "tosg",
  [10] = "temples",
  [11] = "am thieves",
  [12] = "uu",
  [13] = "warriors",
  [14] = "watch house",
  [15] = "magpyr",
  [16] = "bois",
  [17] = "cwc",
  [18] = "bp buildings",
  [19] = "bp estates",
  [20] = "bp wizards",
  [21] = "brown islands",
  [22] = "deaths domain",
  [23] = "djb",
  [24] = "iil",
  [25] = "ephebe",
  [26] = "smugglers",
  [27] = "genua",
  [28] = "genua sewers",
  [29] = "grflx",
  [30] = "hashishim",
  [31] = "oasis",
  [32] = "lancre castle",
  [33] = "mano rossa",
  [34] = "monks",
  [35] = "netherworld",
  [37] = "pumpkin town",
  [38] = "ramtops",
  [39] = "stolat",
  [40] = "aoa",
  [41] = "cabbage warehouse",
  [42] = "aoa library",
  [43] = "stolat sewers",
  [44] = "sprites",
  [45] = "sto plains",
  [46] = "uberwald",
  [47] = "uu library",
  [48] = "farmsteads",
  [49] = "ctf arena",
  [50] = "pk arena",
  [51] = "am po",
  [52] = "undefined",
  [53] = "t-shop",
  [54] = "slippery hollow",
  [56] = "specials",
  [57] = "wolf trail",
  [58] = "medina",
}

local avail_names = {am=true, cwc=true, ephebe=true, stolate=true, genua=true,
                     oc=true, djb=true}
function npcdb.on_room_id()
    if not (gmcp.room and gmcp.room.info and gmcp.room.info.identifier) then
        return
    end
    local rid = gmcp.room.info.identifier
    local now = os.clock()
    local id = db:fetch(dbquow.db.rooms, db:eq(dbquow.db.rooms.room_id, rid))[1]
    if not id then
        return
    end
    id = id.map_id

    --print("DEBUG: quowmap lookup time: " .. os.clock()-now)
    local name = name_from_id[id]
    if not avail_names[name] then
        return
    end
    if npcdb.area ~= name then
        log.debug('changing npcdb.area to: ' .. name)
    end
    npcdb.area = name
    --print("DEBUG: npcdb.area: " .. npcdb.area)
end

local group = "npcdb"

-- EVENTS
registerAnonymousEventHandler("gmcp.char.vitals", "npcdb.on_xp_update")
registerAnonymousEventHandler("gmcp.room.info", "npcdb.on_room_id")

-- TRIGGERS
local n_log_kill = "log_kill"

tools.add_regex_trigger(group, n_log_kill, "^You kill (?:the |a )?(.+)\\.$", {args = {"matches"}})

npcdb[n_log_kill] = function(matches)
    npcdb.last_kill = matches[2]
end

-- ALIASES
local n_log_xp_on_bury = "log_xp_on_bury"
local n_cli = "cli"
local n_kill_only_one_thing = "kill_only_one_thing"
local n_fix_bugged_data = "fix_bugged_data"
local n_set_zero_xp = "set_zero_xp"

tools.add_alias(group, n_set_zero_xp, "^npcdb zero (.*)$")

tools.add_alias(group, n_log_xp_on_bury, "^(b|rb)$")
tools.disable_alias(group, n_log_xp_on_bury)

tools.add_alias(group, n_cli, "^npcdb(?: (on|off|show|rollback))?$", {args = {"matches"}})

tools.add_alias(group, n_kill_only_one_thing, "^ka$")
tools.disable_alias(group, n_kill_only_one_thing)

tools.add_alias(group, n_fix_bugged_data,
    "^alter_row (setlow|sethigh|low|high|avg|count) (\\d+) (.+)$",
    {args = {"matches"}})

npcdb[n_fix_bugged_data] = function(matches)
    local command = matches[2]
    local xp = matches[3]
    local name = matches[4]

    local sheet = db:get_database("npcs")[npcdb.area]
    if sheet == nil then
        print("ERROR: sheet is nil")
    end

    local row = db:fetch(sheet, db:eq(sheet.name, name))[1]
    if row == nil then
        print("ERROR: row is nil")
    end

    if command == "low" then
        row.avg = (row.avg * row.count - row.low) / (row.count - 1)
        row.low = xp
            row.count = row.count - 1
    elseif command == "high" then
        row.avg = (row.avg * row.count - row.high) / (row.count - 1)
            row.high = xp
            row.count = row.count - 1
    elseif command == "avg" then
        row.avg = xp
    elseif command == "count" then
        row.count = xp
    elseif command == "setlow" then
        row.low = xp
    elseif command == "sethigh" then
        row.high = xp
    end

    db:update(sheet, row)
    print("updated record to:")
    display(row)
end

npcdb[n_kill_only_one_thing] = function()
    send("kill living thing -1")
end

npcdb[n_log_xp_on_bury] = function()
    npcdb.just_buried = true
end

npcdb[n_cli] = function(matches)
    local aliases = {n_log_xp_on_bury, n_kill_only_one_thing}

    local command = matches[2]
    if command == "on" then
        print("enabling npcdb aliases, current area: " .. npcdb.area)
        for _, v in pairs(aliases) do
            tools.enable_alias(group, v)
        end
    elseif command == "off" then
        print("disableing npcdb aliases..")
        for _, v in pairs(aliases) do
            tools.disable_alias(group, v)
        end
    elseif command == "show" then
        local area = ""
        if matches[3] == "" then
            area = matches[2]
        else
            area = npcdb.area
        end

        local sheet = db:get_database('npcs')[area]
        if next(sheet) == nil then
            print("ERROR: sheet is nil")
        else
            local ones = db:fetch(sheet, db:eq(sheet.count, 1))
            local twos = db:fetch(sheet, db:eq(sheet.count, 2))
            local threes = db:fetch(sheet, db:eq(sheet.count, 3))

            print("DEBUG: 1: " .. #ones)
            print("DEBUG: 2: " .. #twos)
            print("DEBUG: 3: " .. #threes)
        end
    elseif command == "rollback" then
        if last_trans == nil or next(last_trans) == nil then
            print("ERROR: last_trans is nil or {}")
        else
            local sheet = db:get_database("npcs")[npcdb.area]
            db:update(sheet, last_trans)
            print("rolled back to:")
            display(last_trans)
            last_trans = nil
        end
    else
        print("USAGE:")
        print("\t npcdb on            Enable npcdb related aliases")
        print("\t npcdb off           Disable npcdb related aliases")
        print("\t npcdb show          Show all npcs we've killed only 1, 2, or 3 of")
        print("\t npcdb zero 'name'   Log an npc as zero xp in the database")
        print("\t npcdb rollback      Roll back the last logged bury")
        print("\t alter_row (setlow|sethigh|low|high|avg|count) <xp_value> <npc_name>")
    end
end

return npcdb
