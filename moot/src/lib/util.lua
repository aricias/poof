local log = require("moot.src.lib.log")

local rex = require "rex_pcre"

local npc_end_re = rex.new("^(is|are)$")

local zero_re = rex.new("(?:^|(?<!')\\b)(?:fruitbat|dragon)s?(?:\\b|$)", "i")
local high_re = rex.new("(?:^|(?<!')\\b)(?:(?:wasted|dazed|giggly) (?:m.n|wom.n)|d\'reg|ms. crane|rahn-fara-wai|phos-phor|scowling dark.skinned man|mr. hyena|casanunda|helmsman|vyrt|heric|casso|kang wu|grflx soldier|(?:citadel|hattian|imperial|ceremonial|city) guard|the grflx|clemence|gumboni|cicone|althea|debois|(?:lumbering|towering|hulking|huge|mean|terrifying|looming) troll|fighter|marchella|persuica|harvard|ciaco|rujona|hoplite|student|outlaw|samurai|ronin|ninja|ceremonial sentry|hippopotamus(?:\\')?|hamish|truckle|giant|vincent|willie|ceremonial sentries|knight|smuggler)s?(?:\\b|$)", "i")
local mid_high_re = rex.new("(?:^|(?<!')\\b)(?:pkara stainmaster|mihk-gran-bohp|appiristus|bulos|chryphon|didorus|red.bearded dwarf|teh-takk-eht|cheerful kebab vendor|orangutan|barbarian|frail old lady|tag-ahn-ruhn|splatter|palace guard|the weasel|khepresh|prodo|assassin|(?:stern.looking|golden.muscled young|tough|wiry|twisty|bury|muscular|muscled|sinewy|grizzled|hefty) m.n|security guard|pirate|brindisian (?:boy|m.n|wom.n|girl|nonna)|noblem.n|sebboh|watchm.n|(?:powerful|stalwart) athlete|thug|noblewom.n|bodyguard|grflx mentor|grflx|(?:swarthy|burly|muscular) slave|priestess|noc-noc-bang|priest|crocodile|spy|lascarim|(?:athletic|rowdy|sophisticated) wom.n|genteel lad(?:y|ies)|bois|mugger|cutthroat|captain|teh-takk-eht|soldier|mercenar(?:y|ies)|monk|tsimo handler|tsimo wrestler|mercenerie|nitsuni|gentlem.n|drunk patron|stevedore|skipper|sergeant|warrior|noble wom.n|dancer|officer|weapon master|evil cabbage|character|courtesan)s?(\\b|$)", "i")
local mid_re = rex.new("(?:(?<!')\\b|^)(?:ptyler stonecutter|ptarquet shazam|drowsy dread-locked girl|deckhand|(?:flamboyant|grinning young) man|souvlakios|lip-phon lap-top|daft bugger|zevgatis|fair wenche|yclept|(?:sniffy young|deliberate old|wispy.haired old|dark uptight|colourful middle-aged) woman|excited old man|hopper|vendor|travelling troll|tallyman|hrun|tourist|onuwen|stren|crewman|conwom.n|conm.n|gnirble|lotheraniel|notserp|dogbottler|adnew|protester|dwarf warrior|trickster|lawyer|corporal nobbs|deborah macghi|masqued magician|gritjaw thighsplitter|ebony|tuchoille|tfat chick|crier|Thibeau|recruit|trader|mandarin|silversmith|salesm.n|saleswom.n|fibre|courtesan|poet|actor|merchant|calligrapher|fisherm[ae]n|athlete|brawler|royal judge|civil servant|philosopher|cobbler|bureaucrat|housewife|(?!old )lad(?:y|ies)|wenche|druid|hawker|banker|wizard|jeweller|dealer|donkey)s?(?:\\b|$)", "i")
local low_mid_re = rex.new("(?:^|(?<!')\\b)(?:follower|prophet|madm.n|official|camel herder|camel trader|laggy-san|stallowner|drunk wino|bumblebee|odeas|anaxabraxas|adelphe|xenophobios|akhos|anaideia|kharites|sle-pingh-beuh-tei|euphrosyne|eosforos|sinoe|sandy ptate|sle-pingh-beuh-tei|stone mason|engineer|cynere|architect|lea|limos|odeas|calleis|dinoe|snaxabraxas|ulive|juggler|shopkeeper|dog|starlet|drunk guest|dwarf|ylit|servant|mother|father|accountant|brat|old lad(?:y|ies)|farmer|goat|sensei|docker|driver|old m.n|old wom.n|beggar|cat|citizen|m.n|wom.n|vagabond|labourer|cadger|sow|sweeper|pickpocket|worshipper|believer|sailor|paperboy|Nacirrut|scribe|seller|troll|ambassador|urchin|artisan|slave|thief)s?(?:\\b|$)", "i")
local low_re = rex.new("(?:^|(?<!')\\b)(?:threereed|hen|zombie|mendicant|schoolboy|cadger|potter|duckling|duck|scorpion|child|hen|tortoise|rat|salamander|crow|boy|seagull|girl|children|snake|youth|drunkard|cabbage|bullfrog|mouse|tramp|kitten|rat)s?(?:\\b|$)", "i")

local first_re = rex.new("(?:^|\\b)(?:foul warrior|giant fruitbat|ispor|worshipper|surplus warrior|drunk wino|(?:well.off|rich) citizen|(?:rich|colourful middle-aged|debonair) wom.n|red.beared dwarf|cheerful kebab vendor|frail old lady|travelling troll|(?:debonair|scowling dark.skinned|fishy|rich|excited old|grinning young|golden.muscled young|stern.looking|grizzled|old|burly|athletic|sinewy|hefty|muscular|muscled|tough|wiry|twisty|flamboyant|giggly) m.n|(?:powerful|stalwart) athlete|drunk (?:patron|guest)|brindisian (?:boy|m.n|wom.n|girl|nonna)|young girl|weapon master|(?:rowdy|old|proud|athletic|grubby|supercilious|noble|sophisticated|sniffy young|wispy.haired old|giggly) wom.n|(?:drowsy dread.locked|earnest little) girl|(?:swarthy|muscular|burly) slave|evil cabbage|ceremonial sentr(?:y|ies)|(?:athletic|rowdy|sophisticated|dark uptight|sniffy young|deliberate old|wispy.haired old|colourful middle-aged|noble) wom.n|(?:palace|city|imperial|security|hattian|ceremonial) guard|grflx (?:adolescent|workleader|mentor|worker|soldier)|the grflx|civil servant|stone mason|rose seller|royal judge|tsimo handler|tsimo wrestler|troll warrior|..m.n of low moral fibre|warrior mercenar(?:y|ies)|dwarf warrior|stallowner|stall owner|troll bodyguard|troll child|camel trader|camel herder|giant leader|(?:beautiful|enticing|elegant|genteel|old) lad(?:y|ies))s?(?: \\(?:hiding\\) )?(?:\\b|$)", 'i')
local second_re = rex.new("(?:^|\\b)(?:lion|ptrakti|ptyler stonecutter|hin-lop-heds|ptarquet shazam|madm.n|mihk-gran-bohp|threereed|laggy-san|tag-ahn-ruhn|yclept|sle-pingh-beuh-tei|odeas|ms\. crane|rahn-fara-wai|phos-phor|mr\. hyena|casanunda|vyrt|heric|casso|kang wu|fighter|ninja|noc-noc-bang|hamish|truckle|vincent|willie|teh-takk-eht|appiristus|bulos|chryphon|didorus|red.bearded dwarf|barbarian|splatter|the weasel|khepresh|prodo|clemence|gumboni|cicone|althea|debois|marchella|persuica|harvard|ciaco|sebboh|bois|stevedore|sergeant|dancer|officer|lip-phon lap-top|daft bugger|zevgatis|hopper|tallyman|hrun|tourist|onuwen|stren|conwom.n|conm.n|gnirble|lotheraniel|notserp|dogbottler|adnew|protester|trickster|lawyer|corporal nobbs|deborah macghi|masqued magician|gritjaw thighsplitter|ebony|tuchoille|tfat chick|crier|Thibeau|recruit|poet|calligrapher|brawler|druid|banker|adelphe|sandy ptate|cynere|architect|lea|limos|calleis|dinoe|snaxabraxas|ulive|juggler|starlet|ylit|mother|father|accountant|brat|farmer|docker|sow|believer|paperboy|Nacirrut|ambassador|zombie|mendicant|potter|duckling|duck|seagull|children|snake|pamphilos|andrapodokapelos|endos|bumblebee|telonis|sparrow|talaria|kharites|euphrosyne|amaryllis|xenophobios|akhos|anaideia|makimba|eosforos|sinoe|anaxabraxas|salamander|follower|student|pkara stainmaster|duty clerk|mandarin|rujona|outlaw|lioness|wom.n|m.n|scribe|kitten|vagabond|nitsuni|spy|thug|thief|hitm.n|assassin|mugger|cat|cutthroat|soldier|cloud|fruitbat|dragon|priest|priestess|priestesses|tortoise|labourer|warrior|sailor|beetle|camel|mercenar(?:y|ies)|madman|engineer|prophet|dealer|merchant|trader|d\'reg|tramp|scorpion|child|pickpocket|urchin|hog|shopper|donkey|goat|athlete|rat|actor|ronin|samurai|monk|captain|noblem.n|noblewom.n|dog|driver|crow|beggar|servant|retriever|skipper|deckhand|troll|wizard|crewman|boy|sweeper|hag|youth|bodyguard|salesm.n|saleswom.n|sensei|philosopher|cobbler|girl|wenche|official|hen|shopkeeper|silversmith|stallowner|rooster|dwarf|slave|jeweller|orangutan|hawker|lad(?:y|ies)|artisan|hoplite|penguin|bureaucrat|pirate|nonna|mouse|character|citizen|smuggler|courtesan|bullfrog|knight|cadger|schoolboy|drunkard|gentlem.n|lascarim|fisherm.n|tortoise|vendor|silversmith)s?(?: \\(?:hiding\\) )?(?:\\b|$)", 'i')

local npc_static_re = rex.new("(?:^|(?<!')\\b)(?:troll warrior|mercenary|pkara stainmaster|tag-ahn-ruhn|warrior|daft bugger|ptyler stonecutter|prophet|teh-takk-eht|noc-noc-bang|ptarquet shazam|crocodile|(?:swarthy|burly|muscular) slave|talaria|young girl|didorus|appiristus|chryphon|bulos|kharites|euphrosyne|vyrt|khepresh|hen|bumblebee|odeas|souvlakios|rat|stallowner|stall owner|adelphe|cynere|lea|limos|odeas|calleis|cheerful kebab vendor|sinoe|anaxabraxas|(?:wispy.haired|deliberate) old woman|zevgatis|red.bearded dwarf|fair wenche|ulive|orangutan|(?:golden.muscled young|grinning young|scowling dark.skinned|fishy) man|shopkeeper|pickpocket|(?:excited old|twisty|flamboyant|grizzled) m.n|(?:sniffy young|grubby|noble|proud|dark uptight|colourful middle.aged|spercilious|haughty|supercilious) wom.n|(?:swarthy|burly) slave|frail old lady|cobbler|cutthroat|orangutan|(?:city|citadel|palace) guard|goat|(?:drowsy dread-locked|earnest little|drowsy) girl|housewife|donkey|driver|xenophobios|urchin|akhos|anaideia|seagull|scorpion|salamander)s?(?: \\(?:hiding\\) )?(?:\\b|$)", "i")

local number_strings = {one=1, a=1, an=1, the=1,
                        two=2, three=3, four=4, five=5, six=6, seven=7, eight=8,
                        nine=9, ten=10, eleven=11, twelve=12, thirteen=13,
                        fourteen=14, fifteen=15, sixteen=16, seventeen=17,
                        eighteen=18, nineteen=19, twenty=20, zero=0, many=23}
local function str_to_count(s)
    local count = number_strings[s]
    if count == nil then
        return 1
    end
    return count
end
local string_numbers = {
    [0]='zero', [1]='one', [2]='two', [3]='three', [4]='four', [5]='five',
    [6]='six', [7]='seven', [8]='eight', [9]='nine', [10]='ten', [11]='eleven',
    [12]='twelve', [13]='thirteen', [14]='fourteen', [15]='fifteen',
    [16]='sixteen', [17]='seventeen', [18]='eighteen', [19]='nineteen',
    [20]='twenty',
}
setmetatable(string_numbers,
    {__index = function(_, v)
                   if type(v) == 'number' and v > 20 then
                       return 'many'
                   end
                   return nil
               end,})

local function count_to_str(i)
    local str = string_numbers[i]
    if str == nil then
        return "one"
    end
    return str
end

local count_re = rex.new("^(one|two|three|four|five)$")
local function is_count(s)
    if s == nil then return false end

    return count_re:find(s) ~= nil
end

local dir_re = rex.new("^(north|south|east|west|northeast|northwest|southeast|southwest)$")
local function is_dir(s)
    if s == nil then return false end

    return dir_re:find(s) ~= nil
end

local function has_comma(s)
    return s ~= nil and s:sub(#s) == ','
end

local function split(s, delimiter)
    local result = {}
    for m in (s..delimiter):gmatch("(.-)"..delimiter) do
        result[#result+1] = m
    end
    return result
end

local function trims(s)
   return s:match "^%s*(.-)%s*$"
end
local function trimc(s)
   return s:match "^[%s,]*(.-)[,%s]*$"
end

local function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    local iters = 0
    while num > 0 do
        iters = iters + 1
        if iters > 1000 then
            log.err("num2hex tried to infinite loop, num was: " .. num)
            break
        end
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

local function slice(arr, s, e)
    local new_arr = {}
    if e == nil then
        e = #arr
    end
    for i=s, e do
        new_arr[i-s+1] = arr[i]
    end
    return new_arr
end

local function strip_ansi_colours(s)
    return s:gsub('\27%[[%d;]+m', '')
end

local bad_plurals = {samurai = true,
                     ronin = true,}
local function pluralize(s)
    if bad_plurals[s] then
        return s
    end

    if s:sub(-2) == 's' then
        return s .. 'es'
    elseif s:sub(-1) == 'y' then
        return s:sub(1, -2) .. 'ies'
    elseif s:sub(-3) == 'man' then
        return s:sub(1, -3) .. 'en'
    end
    return s .. 's'
end

local function unpluralize(s)
    local lst3 = s:sub(-3)
    if lst3 == 'ies' then
        return s:sub(1, -4) .. 'y'
    elseif lst3 == 'ses' then
        return s:sub(1, -3)
    elseif lst3:sub(-1) == 's' then
        return s:sub(1, -2)
    elseif lst3 == 'men' then
        return s:sub(1, -3) .. 'an'
    end
    return s
end

local Rgb = {def_r=0, def_g=0, def_b=0}
function Rgb:new(l)
    local o = {r = l[1] or Rgb.def_r,
               g = l[2] or Rgb.def_g,
               b = l[3] or Rgb.def_b}
    self.__index = self
    setmetatable(o, self)
    return o
end

local increments = 255
local function pair_gradient(s, e, p)
    local increment = (e - s) / increments
    if p > 0 or p <= 1 then
        return math.floor(s + p * increments * increment)
    else
        log.warn("Percent must be in the range 0..1 Was: " .. p)
    end
end
local function rgb_gradient(start, end_, percent)
    local r = pair_gradient(start.r, end_.r, percent)
    local g = pair_gradient(start.g, end_.g, percent)
    local b = pair_gradient(start.b, end_.b, percent)
    return Rgb:new{r,g,b}
end

-- class for managing strings that will be printed with decho()
local Dstr= {}
function Dstr:new(txt, fg, bg)
    local o = {txt=txt, fg=fg, bg=bg}
    self.__index = self
    setmetatable(o, self)
    return o
end
function Dstr:tostring()
    return string.format("<%d,%d,%d:%d,%d,%d>%s",
            self.fg.r, self.fg.g, self.fg.b,
            self.bg.r, self.bg.g, self.bg.b, self.txt)

end
function Dstr:split(max)
    if  max > #self.txt then
        return {self}
    end

    local short = self.txt:sub(1, max)
    local _, lspace = short:find("^.*%s")
    local first = self.txt:sub(1, lspace-1)
    local second = '   ' .. self.txt:sub(lspace+1)

    return {Dstr:new(first, self.fg, self.bg),
            Dstr:new(second, self.fg, self.bg),}
end
function Dstr.get_lines(dstrs, cols)
    local lines = {}
    local line = ''
    local line_chars = 0
    local i = 1
    for i=1, #dstrs do
        local d = dstrs[i]
        if line_chars + #d.txt > cols then
            local splits = d:split(cols-line_chars)
            local one = splits[1]
            line = line .. one:tostring()
            lines[#lines+1] = line
            local two = splits[2]
            line = two:tostring()
            line_chars = #two.txt
        else
            line = line .. d:tostring()
            line_chars = line_chars + #d.txt
        end
    end
    lines[#lines+1] = line
    return lines
end

local function pad_string(s, p, pchar)
    if not pchar then
        pchar = ' '
    end
    if #s >= p then
        return s:sub(1, p)
    end
    return s .. pchar:rep(p - #s)
end

local function frequire(n)
    package.loaded[n] = nil
    return require(n)
end

return {
    -- re
    zero_re            = zero_re,
    high_re            = high_re,
    mid_high_re        = mid_high_re,
    mid_re             = mid_re,
    low_mid_re         = low_mid_re,
    low_re             = low_re,
    first_re           = first_re,
    second_re          = second_re,
    npc_static_re      = npc_static_re,
    npc_end_re         = npc_end_re,

    -- strs and numbers
    number_strings     = number_strings,
    str_to_count       = str_to_count,
    count_to_str       = count_to_str,
    is_count           = is_count,
    is_dir             = is_dir,
    has_comma          = has_comma,
    split              = split,
    trims              = trims,
    trimc              = trimc,
    num2hex            = num2hex,
    pluralize          = pluralize,
    unpluralize        = unpluralize,
    pad_string         = pad_string,

    rgb_gradient       = rgb_gradient,
    slice              = slice,
    strip_ansi_colours = strip_ansi_colours,
    Rgb                = Rgb,
    Dstr               = Dstr,

    -- lua
    frequire           = frequire
}