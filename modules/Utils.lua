local Utils = {}
local ffi = require 'ffi'

-- Version constant
Utils.MOJAVE_VERSION = '3.1.1'

-- Shared Library Hashes (used for library updates)
-- If these change, we'll re-extract the corresponding library when the app starts.
Utils.SHARED_LIBRARY_MD5_HASHES = {
    libcurl = {
        ["OS X"] = "eb3e7465c6d38cb7a4594738b7906983",
        ["Windows"] = "4d2f61c4626081102e431d2ae2c7db91",
        -- we use the distro's libcurl devel package on linux
    },
    imgui = {
        ["OS X"] = "df99fc1f73f817296fbf4cecf27605a6",
        ["Windows"] = "2cbfd53dba7233810c087cc4390fff9c",
        ["Linux"] = "e90533010dd802b94b7b1c74c1323f56",
    }
}

-- Default configuration options
Utils.DEFAULT_CONFIG = {
    appearance = {
        tilePrimaryColor = { 0/255, 0/255, 255/255, 255/255 },
        tileSecondaryColor = { 0/255, 0/255, 235/255, 255/255 },
        foodColor = { 0/255, 255/255, 160/255, 234/255 },
        hazardColor = { 24/255, 8/255, 8/255 },
        enableBloom = true,
        fadeOutTails = true,
        enableVignette = true,
        vignetteRadius = 1,
        vignetteOpacity = 0.7,
        vignetteSoftness = 0.8,
        vignetteColor = {0, 0, 0},
        fullscreen = false,
        enableAnimation = true,
        curveOnTurns = true
    },
    audio = {
        enableMusic = true,
        enableSFX = true
    },
    gameplay = {
        boardSize = 4,
        boardHeight = 12,
        boardWidth = 17,
        gameSpeed = 0.15,
        responseTime = 500,
        humanResponseTime = 500,
        foodSpawnChance = 15,
        minimumFood = 1,
        maxHealth = 100,
        startSize = 3
    },
    royale = {
        shrinkEveryNTurns = 25,
        damagePerTurn = 15
    },
    squads = {
        allowBodyCollisions = true,
        sharedElimination = true,
        sharedHealth = true,
        sharedLength = true,
        squad1Color = {232/255, 9/255, 120/255},
        squad2Color = {62/255, 51/255, 143/255},
        squad3Color = {140/255, 198/255, 63/255},
        squad4Color = {251/255, 176/255, 59/255}
    },
    robosnake = {
        maxAggressionSnakes = 4,
        recursionDepth = 6,
        hungerThreshold = 40,
        lowFoodThreshold = 8
    }
}

-- Maps HTML color names to their corresponding hex codes.
-- Required to support the legacy Battlesnake API.
Utils.HTML_COLORS = {
    ['indianred'] = '#cd5c5c',
    ['lightcoral'] = '#f08080',
    ['salmon'] = '#fa8072',
    ['darksalmon'] = '#e9967a',
    ['lightsalmon'] = '#ffa07a',
    ['crimson'] = '#dc143c',
    ['red'] = '#ff0000',
    ['firebrick'] = '#b22222',
    ['darkred'] = '#8b0000',
    ['pink'] = '#ffc0cb',
    ['lightpink'] = '#ffb6c1',
    ['hotpink'] = '#ff69b4',
    ['deeppink'] = '#ff1493',
    ['mediumvioletred'] = '#c71585',
    ['palevioletred'] = '#db7093',
    ['lightsalmon'] = '#ffa07a',
    ['coral'] = '#ff7f50',
    ['tomato'] = '#ff6347',
    ['orangered'] = '#ff4500',
    ['darkorange'] = '#ff8c00',
    ['orange'] = '#ffa500',
    ['gold'] = '#ffd700',
    ['yellow'] = '#ffff00',
    ['lightyellow'] = '#ffffe0',
    ['lemonchiffon'] = '#fffacd',
    ['lightgoldenrodyellow'] = '#fafad2',
    ['papayawhip'] = '#ffefd5',
    ['moccasin'] = '#ffe4b5',
    ['peachpuff'] = '#ffdab9',
    ['palegoldenrod'] = '#eee8aa',
    ['khaki'] = '#f0e68c',
    ['darkkhaki'] = '#bdb76b',
    ['lavender'] = '#e6e6fa',
    ['thistle'] = '#d8bfd8',
    ['plum'] = '#dda0dd',
    ['violet'] = '#ee82ee',
    ['orchid'] = '#da70d6',
    ['fuchsia'] = '#ff00ff',
    ['magenta'] = '#ff00ff',
    ['mediumorchid'] = '#ba55d3',
    ['mediumpurple'] = '#9370db',
    ['amethyst'] = '#9966cc',
    ['blueviolet'] = '#8a2be2',
    ['darkviolet'] = '#9400d3',
    ['darkorchid'] = '#9932cc',
    ['darkmagenta'] = '#8b008b',
    ['purple'] = '#800080',
    ['indigo'] = '#4b0082',
    ['slateblue'] = '#6a5acd',
    ['darkslateblue'] = '#483d8b',
    ['mediumslateblue'] = '#7b68ee',
    ['greenyellow'] = '#adff2f',
    ['chartreuse'] = '#7fff00',
    ['lawngreen'] = '#7cfc00',
    ['lime'] = '#00ff00',
    ['limegreen'] = '#32cd32',
    ['palegreen'] = '#98fb98',
    ['lightgreen'] = '#90ee90',
    ['mediumspringgreen'] = '#00fa9a',
    ['springgreen'] = '#00ff7f',
    ['mediumseagreen'] = '#3cb371',
    ['seagreen'] = '#2e8b57',
    ['forestgreen'] = '#228b22',
    ['green'] = '#008000',
    ['darkgreen'] = '#006400',
    ['yellowgreen'] = '#9acd32',
    ['olivedrab'] = '#6b8e23',
    ['olive'] = '#808000',
    ['darkolivegreen'] = '#556b2f',
    ['mediumaquamarine'] = '#66cdaa',
    ['darkseagreen'] = '#8fbc8f',
    ['lightseagreen'] = '#20b2aa',
    ['darkcyan'] = '#008b8b',
    ['teal'] = '#008080',
    ['aqua'] = '#00ffff',
    ['cyan'] = '#00ffff',
    ['lightcyan'] = '#e0ffff',
    ['paleturquoise'] = '#afeeee',
    ['aquamarine'] = '#7fffd4',
    ['turquoise'] = '#40e0d0',
    ['mediumturquoise'] = '#48d1cc',
    ['darkturquoise'] = '#00ced1',
    ['cadetblue'] = '#5f9ea0',
    ['steelblue'] = '#4682b4',
    ['lightsteelblue'] = '#b0c4de',
    ['powderblue'] = '#b0e0e6',
    ['lightblue'] = '#add8e6',
    ['skyblue'] = '#87ceeb',
    ['lightskyblue'] = '#87cefa',
    ['deepskyblue'] = '#00bfff',
    ['dodgerblue'] = '#1e90ff',
    ['cornflowerblue'] = '#6495ed',
    ['mediumslateblue'] = '#7b68ee',
    ['royalblue'] = '#4169e1',
    ['blue'] = '#0000ff',
    ['mediumblue'] = '#0000cd',
    ['darkblue'] = '#00008b',
    ['navy'] = '#000080',
    ['midnightblue'] = '#191970',
    ['cornsilk'] = '#fff8dc',
    ['blanchedalmond'] = '#ffebcd',
    ['bisque'] = '#ffe4c4',
    ['navajowhite'] = '#ffdead',
    ['wheat'] = '#f5deb3',
    ['burlywood'] = '#deb887',
    ['tan'] = '#d2b48c',
    ['rosybrown'] = '#bc8f8f',
    ['sandybrown'] = '#f4a460',
    ['goldenrod'] = '#daa520',
    ['darkgoldenrod'] = '#b8860b',
    ['peru'] = '#cd853f',
    ['chocolate'] = '#d2691e',
    ['saddlebrown'] = '#8b4513',
    ['sienna'] = '#a0522d',
    ['brown'] = '#a52a2a',
    ['maroon'] = '#800000',
    ['white'] = '#ffffff',
    ['snow'] = '#fffafa',
    ['honeydew'] = '#f0fff0',
    ['mintcream'] = '#f5fffa',
    ['azure'] = '#f0ffff',
    ['aliceblue'] = '#f0f8ff',
    ['ghostwhite'] = '#f8f8ff',
    ['whitesmoke'] = '#f5f5f5',
    ['seashell'] = '#fff5ee',
    ['beige'] = '#f5f5dc',
    ['oldlace'] = '#fdf5e6',
    ['floralwhite'] = '#fffaf0',
    ['ivory'] = '#fffff0',
    ['antiquewhite'] = '#faebd7',
    ['linen'] = '#faf0e6',
    ['lavenderblush'] = '#fff0f5',
    ['mistyrose'] = '#ffe4e1',
    ['gainsboro'] = '#dcdcdc',
    ['lightgrey'] = '#d3d3d3',
    ['silver'] = '#c0c0c0',
    ['darkgray'] = '#a9a9a9',
    ['gray'] = '#808080',
    ['dimgray'] = '#696969',
    ['lightslategray'] = '#778899',
    ['slategray'] = '#708090',
    ['darkslategray'] = '#2f4f4f',
    ['black'] = '#000000'
}

-- For each shared library, check if it needs to be extracted from the fused app.
-- We need to extract the shared library if it is missing (first app run / appdata folder deleted)
-- or if it has been updated or corrupted in some way (hash mismatch)
function Utils.check_shared_library(name)
    local os = love.system.getOS()
    local libName = {
        ["OS X"] = string.format("%s.dylib", name),
        ["Windows"] = string.format("%s.dll", name),
        ["Linux"] = string.format("%s.so", name),
    }
    libName = libName[os]
    local contents, _ = love.filesystem.read( 'data', string.format( '%s', libName ) )
    if not contents then
        print( 'Missing shared library ' .. name .. ' will be extracted' )
        return false
    end
    local hash = love.data.encode( 'string', 'hex', love.data.hash( 'md5', contents ) )
    local expected_hash = Utils.SHARED_LIBRARY_MD5_HASHES[name][os]
    if hash ~= expected_hash then
        print( 'Modified shared library ' .. name .. ' will be extracted' )
        return false
    end
    return true
end

-- Turns a hex color (i.e. #FF00FF) into RGB
-- (normalized to 0..1)
function Utils.color_from_hex( value )
    -- convert the hex value to an RGB one
    -- @see https://gist.github.com/jasonbradley/4357406
    if type(value) == "table" then
        return value
    end
    value = value:gsub( "#", "" )
    return {
        tonumber( "0x" .. value:sub( 1, 2 ) )/255,
        tonumber( "0x" .. value:sub( 3, 4 ) )/255,
        tonumber( "0x" .. value:sub( 5, 6 ) )/255,
        1
    }
end

-- Clones a table recursively.
-- @param table t The source table
-- @return table The copy of the table
-- @see https://gist.github.com/MihailJP/3931841
function Utils.deepcopy(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = Utils.deepcopy(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

-- Extracts a shared library to the appdata directory.
-- This is necessary because shared (C) libraries require an absolute path to load. If the application
-- is fused, then we either have to place the library in the same directory as the application (yuck)
-- or in the appdata directory. So this function copies the given shared library from the fused app
-- into the appdata directory, where we will then be able to load it.
function Utils.extract_shared_library(name, folder_name)
    local libName = {
        ["OS X"] = string.format("%s.dylib", name),
        ["Windows"] = string.format("%s.dll", name),
        ["Linux"] = string.format("%s.so", name),
    }
    libName = libName[love.system.getOS()]
    local contents, size = love.filesystem.read( 'data', string.format( 'thirdparty/%s/%s', folder_name, libName ) )
    if not contents then
        error( string.format( 'Unable to read %s', libName )  )
    end
    local ok, err = love.filesystem.write( string.format( '%s', libName ), contents, size )
    if not ok then
        error( string.format( 'Unable to write %s: %s', libName, err ) )
    end
end

-- Generates a UUID used for game IDs, snake IDs, etc.
-- @return a random format UUID
-- @see https://gist.github.com/jrus/3197011
function Utils.generateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub( template, '[xy]', function (c)
        local v = (c == 'x') and love.math.random( 0, 0xf ) or love.math.random( 8, 0xb )
        return string.format( '%x', v )
    end )
end

-- Reads configuration from the config.json file
-- Creates the config.json file if it doesn't exist
-- Adds any new config options in this version to config.json
function Utils.get_or_create_config()

    -- Grab defaults
    local default_config = Utils.DEFAULT_CONFIG
    local json_config, read_err

    -- If no config.json file exists on disk, create one using the defaults
    -- Otherwise, read it from disk.
    if not love.filesystem.getInfo( 'config.json', 'file' ) then
        json_config = json.encode( default_config )
        local ok, err = love.filesystem.write( 'config.json', json_config )
        if not ok then
            error( string.format( 'Unable to write config.json: %s', err ) )
        end
    else
        json_config, read_err = love.filesystem.read( 'config.json' )
        if not json_config then
            error( string.format( 'Unable to read config.json: %s', read_err ) )
        end
    end

    -- Parse the JSON into a Lua table.
    local config, _, err = json.decode( json_config, 1, json.null )
    if not config then
        error( 'Error parsing config.json: ' .. err )
    end

    -- If this is an upgrade, there may be new options
    -- that do not exist in the local copy of config.json,
    -- so add anything missing.
    for k, v in pairs( default_config ) do
        if config[k] == nil then
            print( 'Missing config option ' .. k )
            config[k] = v
        end
        for subk, subv in pairs(default_config[k]) do
            if config[k][subk] == nil then
                print(string.format('Missing %s config option %s', k, subk))
                config[k][subk] = subv
            end
        end
    end
    local ok = love.filesystem.write( 'config.json', json.encode( config ) )
    if not ok then
        error( 'Unable to write config.json' )
    end

    return config
end

-- Reads snakes from the snakes.json file
-- Creates the snakes.json file if it doesn't exist
function Utils.get_or_create_snakes()
    local json_snakes, read_err

    -- If no snakes.json file exists on disk, create an empty one.
    -- Otherwise, read it from disk.
    if not love.filesystem.getInfo( 'snakes.json', 'file' ) then
        json_snakes = json.encode( {} )
        local ok, err = love.filesystem.write( 'snakes.json', json_snakes )
        if not ok then
            error( string.format( 'Unable to write snakes.json: %s', err ) )
        end
    else
        json_snakes, read_err = love.filesystem.read( 'snakes.json' )
        if not json_snakes then
            error( string.format( 'Unable to read snakes.json: %s', read_err ) )
        end
    end

    -- Parse the JSON into a Lua table of objects
    local snakes, _, err = json.decode( json_snakes, 1, json.null )
    if not snakes then
        error( 'Error parsing snakes.json: ' .. err )
    end
    for _, snake in pairs(snakes) do
        setmetatable(snake, Snake)
    end

    return snakes
end

-- Abstraction layer around libcurl so that I can write
-- http requests using less code
function Utils.http_request(url, postbody)
    local t = {}
    local options = {
        useragent = "Mojave/" .. Utils.MOJAVE_VERSION,
        url = url,
        timeout_ms = config.gameplay.responseTime,
        writefunction = function(data, size)
            if size == 0 then return end
            table.insert(t, ffi.string(data, size))
            return size
        end
    }
    if postbody then
        options.post = true
        options.postfields = postbody
        options.httpheader = {"Content-Type: application/json"}
    end
    local req = curl.easy(options)
    local ok, err = req:perform()
    local latency = req:info("total_time") * 1000
    req:close()
    if not ok then
        return false, latency, err
    end
    return table.concat(t), latency, nil
end

-- Another abstraction layer, this one around the libcurl multi interface
function Utils.http_request_multi(params)
    local m = curl.multi()
    local responses = {}
    for _, param in ipairs(params) do
        local t = {}
        local options = {
            useragent = "Mojave/" .. Utils.MOJAVE_VERSION,
            url = param.url,
            timeout_ms = config.gameplay.responseTime,
            writefunction = function(data, size)
                if size == 0 then return end
                table.insert(t, ffi.string(data, size))
                return size
            end
        }
        if param.postbody then
            options.post = true
            options.postfields = param.postbody
            options.httpheader = {"Content-Type: application/json"}
        end
        local req = curl.easy(options)
        responses[param.id] = {
            req = req,
            t = t
        }
        if param.postbody then
            responses[param.id].postbody = param.postbody
        end
        m:add(req)
    end
    while true do
        local n = m:perform()
        if n == 0 then break end
    end
    while true do
        local info = m:info_read()
        if not info then break end
        for _, response in pairs(responses) do
            if response.req == info.easy_handle then
                response.error = curl.easy.strerror(info.data.result)
            end
        end
    end
    m:close()
    for _, response in pairs(responses) do
        response.response = table.concat(response.t)
        response.latency = response.req:info("total_time") * 1000
        response.req:close()
        response.req = nil
    end
    return responses
end

-- Inverts the value of a pixel. Used to turn the head/tail PNGs from black-on-white to white-on-black
-- so that we can colorize them when rendering snakes.
function Utils.invert(x,y,r,g,b,a)
    r = 1 - r
    g = 1 - g
    b = 1 - b
    return r, g, b, a
end

-- Preloads the snake head and tail PNG images from disk and stores them in a lookup table by name. If we're in
-- the game thread, we only need to know if a head or tail image exists but we don't need to actually load it.
function Utils.load_heads_and_tails(in_thread)
    local heads = {}
    local tails = {}
    local head_pngs = love.filesystem.getDirectoryItems("images/heads")
    local tail_pngs = love.filesystem.getDirectoryItems("images/tails")

    for _, png in ipairs(head_pngs) do
        if Utils.string_ends_with(png, '.png') then
            local imgdata, img
            if in_thread then
                img = true
            else
                imgdata = love.image.newImageData(string.format("images/heads/%s", png))
                imgdata:mapPixel(Utils.invert)
                img = love.graphics.newImage(imgdata, {mipmaps = true})
                img:setMipmapFilter('linear', 100)
            end
            local name = png:sub(0, #png-4)
            heads[name] = img
            if Utils.string_starts_with(name, 'bfl-') or Utils.string_starts_with(name, 'bwc-') then
                name = name:sub(5, #name)
                heads[name] = img
            elseif Utils.string_starts_with(name, 'shac-') then
                name = name:sub(6, #name)
                heads[name] = img
            end
        end
    end

    for _, png in ipairs(tail_pngs) do
        if Utils.string_ends_with(png, '.png') then
            local imgdata, img
            if in_thread then
                img = true
            else
                imgdata = love.image.newImageData(string.format("images/tails/%s", png))
                imgdata:mapPixel(Utils.invert)
                img = love.graphics.newImage(imgdata, {mipmaps = true})
                img:setMipmapFilter('linear', 100)
            end
            local name = png:sub(0, #png-4)
            tails[name] = img
            if Utils.string_starts_with(name, 'bfl-') or Utils.string_starts_with(name, 'bwc-') then
                name = name:sub(5, #name)
                tails[name] = img
            elseif Utils.string_starts_with(name, 'shac-') then
                name = name:sub(6, #name)
                tails[name] = img
            end
        end
    end

    return heads, tails
end

-- Displays an error dialog and exits the app.
-- Used if we fail to load a shared library.
function Utils.shared_library_error(name)
    local os = love.system.getOS()
    local error_message = string.format("Mojave was unable to load the %s library. ", name)
    if os == "Windows" then
        error_message = error_message .. [[Please make sure that you are
running 64-bit Windows Vista or greater, and that you have downloaded and installed
the Visual C++ 2017 Redistributable package from Microsoft before launching the
game.]]
    elseif os == "OS X" then
        error_message = error_message .. [[Please make sure that you are
running Mac OS 10.14 or greater.]]
    else
        error_message = error_message .. [[Please make sure that you are
running a 64-bit operating system.]]
    end
    love.window.showMessageBox(
        string.format("Error loading %s", name),
        error_message,
        "error"
    )
    love.event.quit()
end

-- Shuffles a table using the fisher-yates algorithm
-- see: https://programming-idioms.org/idiom/10/shuffle-a-list/1313/lua
function Utils.shuffle(list)
    for i = #list, 2, -1 do
        local j = love.math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

-- Returns true if a string starts with another string
-- see: http://lua-users.org/wiki/StringRecipes
function Utils.string_starts_with(str, start)
   return str:sub(1, #start) == start
end

-- Returns true if a string ends with another string
-- see: http://lua-users.org/wiki/StringRecipes
function Utils.string_ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

return Utils
