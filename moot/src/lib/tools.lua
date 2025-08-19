local log = frequire("moot.src.lib.log")
local io = require("io")

tools = tools or {} 
tools.triggers = tools.triggers or {}
tools.aliases = tools.aliases or {}
tools.timers = tools.timers or {}

-- generate function signature to call your callback from your trigger
local function code_from_opts(group, name, opts)
   local code = ""

    if opts and opts.prerun ~= nil then
        code = code .. "\n" .. opts.prerun
    end

    local args = ""
    if opts and opts.args ~= nil then
        args = table.concat(opts.args, ', ')
    end
    local func = group .. "." .. name .. "(" .. args .. ")"
    code = code .. "\n" .. func

    return code
end

local default_trigger_args = {
    name = 0, -- passed through add_regex_trigger
    regex = 0, -- passed through add_regex_trigger
    code = 0,  -- passed through add_regex_trigger
    multiline = 0,
    fg_color = 0,
    bg_color = 0,
    filter = 0,
    match_all = 0,
    highlight_fg_color = 0,
    highlight_bg_color = 0,
    play_sound_file = 0,
    fire_length = 0,
    line_delta = 0,
    expireAfter = nil,
}
function tools.add_regex_trigger(group, name, re, opts, trigger_args_override)
    -- group: namespace of callback
    -- name: name of callback
    -- re: regex to match on
    -- opts: table of possible modifications to the code
    --    opts.prerun: code to run before your callback
    --    opts.args: list of arguments to pass to your callback
    -- trigger_args_override: table to override values in default_trigger_args

    -- setup the trigger group if needed
    if not tools.triggers[group] then
        tools.triggers[group] = {}
    end
    -- kill any previous instances of ourselves
    local old_t = tools.triggers[group][name]
    if old_t then
        local n = group .. "." .. name
        if not killTrigger(old_t) then
            error("failed to kill previous version of " .. n .. " with id " .. old_t)
        end
    end

    -- add the trigger
    local trigger_id
    -- currently there is a bug in Mudlet with tempComplexRegexTrigger where the return value is the regex
    --    instead of the id of the trigger. Once this is fixed we can use tempComplexRegexTrigger for
    --    everything
    if trigger_args_override then
        log.debug("adding tempComplexRegexTrigger " .. name)
        -- https://wiki.mudlet.org/w/Special:MyLanguage/Manual:Technical_Manual#tempComplexRegexTrigger
        -- https://github.com/Mudlet/Mudlet/blob/development/src/TLuaInterpreter.cpp#L6528
        -- local trig_ret = tempComplexRegexTrigger("anyText", "^(.*)$", [[echo("Text received!")]], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil)

        -- build tempComplexRegexTrigger arguments
        local args = {}
        for k, v in pairs(default_trigger_args) do
            args[k] = v
        end
        trigger_args_override = trigger_args_override or {}
        for k, v in pairs(trigger_args_override) do
            if not default_trigger_args[k] then
                error("all keys in the parameter 'trigger_args_override' must also exist in 'default_trigger_args'")
            end
            args[k] = v
        end
        args.name = name
        args.regex = re
        args.code = code_from_opts(group, name, opts)

        trigger_id = tempComplexRegexTrigger(
            args.name,
            args.regex,
            args.code,
            args.multiline,
            args.fg_color,
            args.bg_color,
            args.filter,
            args.match_all,
            args.highlight_fg_color,
            args.highlight_bg_color,
            args.play_sound_file,
            args.fire_length,
            args.line_delta,
            args.expireAfter)
    else
        log.debug("adding tempRegexTrigger " .. name)
        trigger_id = tempRegexTrigger(re, code_from_opts(group, name, opts))
    end
    tools.triggers[group][name] = trigger_id
end

function tools.add_timer(group, name, interval)
    if not tools.timers[group] then
        tools.timers[group] = {}
    end
    if tools.timers[group][name] then
        killTimer(tools.timers[group][name])
        tools.timers[group][name] = nil
    end
    tools.timers[group][name] = tempTimer(interval, group .. "." .. name .. "()", true)
end

function tools.add_alias(group, name, re, opts)
    if not tools.aliases[group] then
        tools.aliases[group] = {}
    end
    if tools.aliases[group][name] then
        killAlias(tools.aliases[group][name])
        tools.aliases[group][name] = nil
    end

    local code = code_from_opts(group, name, opts)

    tools.aliases[group][name] = tempAlias(re, code)
end

function tools.enable_trigger(group, name)
    if not tools.triggers[group] or not tools.triggers[group][name] then
        log.warn("failed to enable nonexistent trigger " .. group .. " " .. name)
        return
    end
    enableTrigger(tools.triggers[group][name])
end

function tools.disable_trigger(group, name)
    if not tools.triggers[group] or not tools.triggers[group][name] then
        log.warn("failed to disable nonexistent trigger " .. group .. " " .. name)
        return
    end
    disableTrigger(tools.triggers[group][name])
end

function tools.enable_alias(group, name)
    if not tools.aliases[group] or not tools.aliases[group][name] then
        log.warn("failed to enable nonexistent alias " .. group .. " " .. name)
        return
    end
    enableAlias(tools.aliases[group][name])
end

function tools.disable_alias(group, name)
    if not tools.aliases[group] or not tools.aliases[group][name] then
        log.warn("failed to disable nonexistent alias " .. group .. " " .. name)
        return
    end
    disableAlias(tools.aliases[group][name])
end

function tools.config_gmcp()
    sendGMCP(string.format(
            'core.supports.set ["%s","%s","%s","%s","%s","%s"]',
            "char.login", "char.info", "char.vitals", "room.info", "room.map", "room.writtenmap"))
end

function tools.restore_database_if_needed(dbname)
    -- copy database from plugin directory to mudlet home directory that db:create can find it
    log.debug("checking needs restore database for " .. dbname)

    local normal_db_file = getMudletHomeDir() .. "/" .. dbname
    local backup_db_file = getMudletHomeDir() .. "/moot/" .. dbname
    local sz_norm, sz_backup = 0, 0

    if io.exists(backup_db_file) then
        local infile = io.open(backup_db_file, "r")
        sz_backup = infile:seek("end")
        infile:close()
    end
    if io.exists(normal_db_file) then
        local infile = io.open(normal_db_file, "r")
        sz_norm = infile:seek("end")
        infile:close()
    end
    log.debug(string.format("db at %s is sz %s", backup_db_file, sz_backup))
    log.debug(string.format("db at %s is sz %s", normal_db_file, sz_norm))

    if sz_backup > sz_norm then
        log.debug(dbname .. " looks newer in backup, is this a first time install?")
        local infile = io.open(backup_db_file, "rb")
        local outfile = io.open(normal_db_file, "wb")

        local instr = infile:read(4096)
        while instr and #instr > 0 do
            outfile:write(instr)
            instr = infile:read(4096)
        end
        outfile:close()
        infile:close()
    end
end

return tools
