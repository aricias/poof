local os = require("os")

-- NOTE: LOG_LEVEL is a global and can therefore be changed on the fly (lua LOG_LEVEL=...)
LOG_LEVEL = 4

local function logit(lvl, prefix, color, msg)
    if LOG_LEVEL > lvl then
        local ts = os.date("%X")
        cecho(string.format("<%s>%s %s: %s\n", color, ts, prefix, msg))
    end
end

local function trace(s)
    logit(5, "TRACE", "cornsilk", s)
end
local function debug(s)
    logit(4, "DEBUG", "cornsilk", s)
end
local function info(s)
    logit(3, "INFO", "khaki", s)
end
local function warn(s)
    logit(2, "WARN", "sienna", s)
end
local function err(s)
    logit(1, "ERROR", "brown", s)
end
local function critical(s)
    logit(0, "CRITICAL", "orange_red", s)
end

return {
    LOG_LEVEL = LOG_LEVEL,
    debug     = debug,
    info      = info,
    warn      = warn,
    err       = err,
    critical  = critical,
}
