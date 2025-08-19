local log = frequire("moot.src.lib.log")

dbquow = dbquow or {}

function dbquow.create_quowmap_db()
    tools.restore_database_if_needed("Database_quowmap.db")
    local items_schema = {item_name='',
                          description='',
                          appraise_text='',
                          weight='',
                          dollar_value=0.0,
                          searchable=0,
                          special_find_note='',}
    local npc_info_schema = {npc_id='',
                                map_id=0,
                                npc_name='',
                                room_id='',}
    local npc_items_schema = {npc_id='',
                                item_name='',
                                sale_price='',}
    local room_descriptions_schema = {room_hash='',
                                        room_id='',}
    local room_exits_schema = {room_id='',
                                connect_id='',
                                exit='',
                                guessed=0}
    local rooms_schema = {room_id='',
                            map_id=0,
                            xpos=0,
                            ypos=0,
                            room_short='',
                            room_type='',}
    local shop_items_schema = {room_id='',
                                item_name='',
                                sale_price='',}
    local room_shop_schema = {room_id='',
                              stock_code='',
                              stock_name='',
                              stock_price='',}
    local bookmarks = {room_id='',}
    return db:create("quowmap",
                          {items=items_schema,
                           npc_info=npc_info_schema,
                           npc_items=npc_items_schema,
                           room_descriptions=room_descriptions_schema,
                           room_exits=room_exits_schema,
                           rooms=rooms_schema,
                           shop_items=shop_items_schema,
                           room_shop=room_shop_schema,
                           bookmarks=bookmarks,})
end

dbquow.db = dbquow.create_quowmap_db()

-- sQuowLocationsByRoomID
dbquow.locs_by_id = dbquow.locs_by_id or {}
-- sQuowExitsByID
dbquow.exits_by_id = dbquow.exits_by_id or {}
-- sQuowExitsByExit
dbquow.exits_by_exit = dbquow.exits_by_exit or {}

local function parse_dbquow()
    local rooms = db:fetch(dbquow.db.rooms)
    for i=1, #rooms do
        local row = rooms[i]
        dbquow.locs_by_id[row.room_id] = {row.map_id, row.xpos, row.ypos, row.room_short, row.room_type}
        dbquow.exits_by_id[row.room_id] = {}
        dbquow.exits_by_exit[row.room_id] = {}
    end

    local room_exits = db:fetch(dbquow.db.room_exits)
    for i=1, #room_exits do
        local row = room_exits[i]
        dbquow.exits_by_id[row.room_id][row.connect_id] = row.exit
        dbquow.exits_by_exit[row.room_id][row.exit] = row.connect_id
    end
end
parse_dbquow()

-- **********************************************************************
-- *                 Map File Names/Core Locations & Data               *
-- **********************************************************************
-- The file names and the "friendly title" for the titlewindow of the map, for each location
-- Also contains the "grid size" - a value to move the map by automatically for an average 1 room size (guesstimate tracking)
-- A default "centre-point" for those maps
-- A temp variable used for map caching
-- And finally the background colour for the window (for displaying off the edges of the actual graphic)
-- sQuowMapFiles
dbquow.map_files = {
  [1] = { "am.png", "Ankh-Morpork", 14, 14, 718, 802, "AM", false, 16777215, },
  [2] = { "am_assassins.png", "AM Assassins", 28, 28, 457, 61, "AM", false, 16777215, },
  [3] = { "am_buildings.png", "AM Buildings", 25, 25, 208, 76, "AM", false, 16777215, },
  [4] = { "am_cruets.png", "AM Cruets", 24, 24, 300, 69, "AM", false, 16777215, },
  [5] = { "am_docks.png", "AM Docks", 14, 14, 174, 216, "AM", false, 16777215, },
  [6] = { "am_guilds.png", "AM Guilds", 28, 28, 487, 245, "AM", false, 16777215, },
  [7] = { "am_isle_gods.png", "AM Isle of Gods", 24, 24, 342, 587, "AM", false, 16777215, },
  [8] = { "am_shades.png", "Shades Maze", 80, 80, 46, 179, "AM", false, 12895428, },
  [9] = { "am_smallgods.png", "Temple of Small Gods", 24, 24, 221, 224, "AM", false, 16777215, },
  [10] = { "am_temples.png", "AM Temples", 24, 24, 575, 419, "AM", false, 16777215, },
  [11] = { "am_thieves.png", "AM Thieves", 28, 28, 431, 300, "AM", false, 16777215, },
  [12] = { "am_uu.png", "Unseen University", 28, 28, 166, 393, "AM", false, 16777215, },
  [13] = { "am_warriors.png", "AM Warriors", 32, 25, 135, 104, "AM", false, 16777215, },
  [14] = { "am_watch_house.png", "Pseudopolis Watch House", 24, 24, 88, 104, "AM", false, 16777215, },
  [15] = { "magpyr.png", "Magpyr's Castle", 20, 20, 141, 440, "Magpyr", false, 16777215, },
  [16] = { "bois.png", "Bois", 14, 14, 239, 169, "Bois", false, 16777215, },
  [17] = { "bp.png", "Bes Pelargic", 14, 14, 1070, 748, "BP", false, 16777215, },
  [18] = { "bp_buildings.png", "BP Buildings", 24, 24, 428, 177, "BP", false, 16777215, },
  [19] = { "bp_estates.png", "BP Estates", 14, 14, 540, 506, "BP", false, 16777215, },
  [20] = { "bp_wizards.png", "BP Wizards", 20, 20, 101, 517, "BP", false, 16777215, },
  [21] = { "brown_islands.png", "Brown Islands", 28, 28, 105, 101, "Brown", false, 16777215, },
  [22] = { "deaths_domain.png", "Death's Domain", 28, 28, 98, 86, "Death", false, 16777215, },
  [23] = { "djb.png", "Djelibeybi", 14, 14, 438, 369, "DJB", false, 16777215, },
  [24] = { "djb_wizards.png", "IIL - DJB Wizards", 28, 28, 210, 210, "DJB", false, 16777215, },
  [25] = { "ephebe.png", "Ephebe", 14, 14, 407, 349, "Ephebe", false, 16777215, },
  [26] = { "ephebe_under.png", "Ephebe Underdocks", 14, 14, 247, 285, "Ephebe", false, 16777215, },
  [27] = { "genua.png", "Genua", 14, 14, 470, 242, "Genua", false, 16777215, },
  [28] = { "genua_sewers.png", "Genua Sewers", 21, 21, 405, 312, "Genua", false, 16777215, },
  [29] = { "grflx.png", "GRFLX Caves", 20, 20, 303, 222, "GRFLX", false, 16777215, },
  [30] = { "hashishim_caves.png", "Hashishim Caves", 28, 28, 258, 132, "Klatch", false, 16777215, },
  [31] = { "klatch.png", "Klatch Region", 14, 14, 724, 515, "Klatch", false, 16777215, },
  [32] = { "lancre_castle.png", "Lancre Region", 14, 14, 285, 33, "Ramtops", false, 16777215, },
  [33] = { "mano_rossa.png", "Mano Rossa", 28, 28, 298, 202, "Genua", false, 16777215, },
  [34] = { "monks_cool.png", "Monks of Cool", 14, 14, 113, 170, "Ramtops", false, 16777215, },
  [35] = { "netherworld.png", "Netherworld", 14, 14, 42, 75, "Nether", false, 16777215, },
  [37] = { "pumpkin_town.png", "Pumpkin Town", 48, 48, 375, 194, "Pumpkin", false, 16777215, },
  [38] = { "ramtops.png", "Ramtops Regions", 14, 14, 827, 223, "Ramtops", false, 16777215, },
  [39] = { "sl.png", "Sto-Lat", 14, 14, 367, 222, "Sto-Lat", false, 16777215, },
  [40] = { "sl_aoa.png", "Academy of Artificers", 25, 25, 47, 87, "Sto-Lat", false, 16777215, },
  [41] = { "sl_cabbages.png", "Cabbage Warehouse", 28, 28, 60, 92, "Sto-Lat", false, 16777215, },
  [42] = { "sl_library.png", "AoA Library", 57, 57, 220, 411, "Sto-Lat", false, 16777215, },
  [43] = { "sl_sewers.png", "Sto-Lat Sewers", 14, 14, 162, 204, "Sto-Lat", false, 16777215, },
  [44] = { "sprite_caves.png", "Sprite Caves", 14, 14, 113, 182, "Sprites", false, 16777215, },
  [45] = { "sto_plains.png", "Sto Plains Region", 14, 14, 752, 390, "Sto-Plains", false, 16777215, },
  [46] = { "uberwald.png", "Uberwald Region", 14, 14, 673, 643, "Uber", false, 16777215, },
  [47] = { "uu_library_full.png", "UU Library", 30, 30, 165, 4810, "UU", false, 16777215, },
  [48] = { "farmsteads.png", "Klatchian Farmsteads", 28, 28, 445, 171, "Klatch", false, 16777215, },
  [49] = { "ctf_arena.png", "CTF Arena", 48, 48, 307, 283, "CTF", false, 16777215, },
  [50] = { "pk_arena.png", "PK Arena", 30, 30, 155, 331, "PK", false, 16777215, },
  [51] = { "am_postoffice.png", "AM Post Office", 28, 28, 156, 69, "AM", false, 16777215, },
  [52] = { "bp_ninjas.png", "Ninja Guild", 28, 28, 109, 56, "BP", false, 16777215, },
  [53] = { "tshop.png", "The Travelling Shop", 28, 28, 355, 315, "T-Shop", false, 16777215, },
  [54] = { "slippery_hollow.png", "Slippery Hollow", 14, 14, 215, 123, "S-Hollow", false, 16777215, },
  [55] = { "creel_guild.png", "House of Magic - Creel", 28, 28, 38, 86, "Ramtops", false, 16777215, },
  [56] = { "quow_specials.png", "Special Areas", 28, 28, 288, 28, "Misc", false, 16777215, },
  [57] = { "skund_wolftrails.png", "Skund Wolf Trail", 12, 12, 41, 587, "Skund", false, 16777215, },
  [58] = { "medina.png", "Medina", 38, 38, 131, 126, "BP", false, 16777215, },
  [59] = { "copperhead.png", "Copperhead", 12, 12, 55, 47, "Copper", false, 16777215, },
  [60] = { "ephebe_citadel.png", "The Citadel", 11, 11, 37, 74, "Ephebe", false, 16777215, },
  [61] = { "am_fools.png", "AM Fools' Guild", 28, 28, 13, 65, "AM", false, 16777215, },
  [62] = { "thursday.png", "Thursday's Island", 28, 28, 112, 65, "Thursday", false, 16777215, },
  [99] = { "discwhole.png", "Whole Disc", 1, 1, 1175, 3726, "Terrains", false, 0, },
}

return dbquow
