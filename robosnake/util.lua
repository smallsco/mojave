local util = {}


-- Lua optimization: any functions from another module called more than once
-- are faster if you create a local reference to that function.
local DEBUG = 'trace'
local log = function( level, str ) gameLog( 'ROBOSNAKE: ' .. str, level ) end
local random = math.random


--[[
    PRIVATE METHODS
]]


-- @see https://github.com/vadi2/mudlet-lua/blob/2630cbeefc3faef3079556cb06459d1f53b8f842/lua/Other.lua#L467
local function _comp(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) == 'table' then
        for k, v in pairs(a) do
            if not b[k] then return false end
            if not _comp(v, b[k]) then return false end
        end
    else
        if a ~= b then return false end
    end
    return true
end


--- Converts coordinates from 0-based indexing to 1-based indexing
-- @param table coords The source coordinate pair
-- @return table The converted coordinate pair
local function convert_coordinates( coords )
    return { coords[1]+1, coords[2]+1 }
end



--[[
    PUBLIC METHODS
]]


--- I'M A BELIEBER
-- @return a random quote from Justin Bieber
function util.bieberQuote()
    local bieberquotes = {
        "I make mistakes growing up. I'm not perfect; I'm not a robot. -Justin Bieber",
        "I'm crazy, I'm nuts. Just the way my brain works. I'm not normal. I think differently. -Justin Bieber",
        "Friends are the best to turn to when you're having a rough day. -Justin Bieber",
        "I leave the hip thrusts to Michael Jackson. -Justin Bieber",
        "It's cool when fans spend so much time making things for me. It means a lot. -Justin Bieber",
        "No one can stop me. -Justin Bieber"
    }
    return bieberquotes[random(#bieberquotes)]
end


--- Take the BattleSnake arena's state JSON and use it to create our own grid
-- @param gameState The arena's game state JSON
-- @return A 2D table with each cell mapped to food, walls, snakes, etc.
function util.buildWorldMap( gameState )
    
    -- Generate the tile grid
    log( DEBUG, 'Generating tile grid' )
    local grid = {}
    for y = 1, gameState['height'] do
        grid[y] = {}
        for x = 1, gameState['width'] do
            grid[y][x] = '.'
        end
    end
    
    -- Place walls
    for i = 1, #gameState['walls'] do
        local wall = gameState['walls'][i]
        grid[wall[2]][wall[1]] = 'X'
        log( DEBUG, string.format('Placed wall at [%s, %s]', wall[1], wall[2]) )
    end
    
    -- Place gold
    for i = 1, #gameState['gold'] do
        local gold = gameState['gold'][i]
        grid[gold[2]][gold[1]] = '$'
        log( DEBUG, string.format('Placed gold at [%s, %s]', gold[1], gold[2]) )
    end
    
    -- Place food
    for i = 1, #gameState['food'] do
        local food = gameState['food'][i]
        grid[food[2]][food[1]] = 'O'
        log( DEBUG, string.format('Placed food at [%s, %s]', food[1], food[2]) )
    end
    
    -- Place snakes
    for i = 1, #gameState['snakes'] do
        for j = 1, #gameState['snakes'][i]['coords'] do
            local snake = gameState['snakes'][i]['coords'][j]
            if j == 1 then
                grid[snake[2]][snake[1]] = '@'
                log( DEBUG, string.format('Placed snake head at [%s, %s]', snake[1], snake[2]) )
            else
                grid[snake[2]][snake[1]] = '#'
                log( DEBUG, string.format('Placed snake tail at [%s, %s]', snake[1], snake[2]) )
            end
        end
    end
    
    return grid
end


--- Converts an entire gamestate from 0-based indexing to 1-based indexing
-- @param table gameState The source game state
-- @return table The converted game state
function util.convert_gamestate( gameState )
    
    local newState = {
        you = gameState['you'],
        game = gameState['game'] or gameState['game_id'],
        mode = gameState['mode'],
        turn = gameState['turn'],
        height = gameState['height'],
        width = gameState['width'],
        snakes = {},
        food = {},
        walls = {},
        gold = {}
    }
    
    for i = 1, #gameState['food'] do
        table.insert( newState['food'], convert_coordinates( gameState['food'][i] ) )
    end
    
    if gameState['walls'] then
        for i = 1, #gameState['walls'] do
            table.insert( newState['walls'], convert_coordinates( gameState['walls'][i] ) )
        end
    end
    
    if gameState['gold'] then
        for i = 1, #gameState['gold'] do
            table.insert( newState['gold'], convert_coordinates( gameState['gold'][i] ) )
        end
    end
    
    for i = 1, #gameState['snakes'] do
        local newSnake = {
            id = gameState['snakes'][i]['id'],
            name = gameState['snakes'][i]['name'],
            status = gameState['snakes'][i]['status'],
            message = gameState['snakes'][i]['message'],
            taunt = gameState['snakes'][i]['taunt'],
            age = gameState['snakes'][i]['age'],
            health = gameState['snakes'][i]['health'] or gameState['snakes'][i]['health_points'],
            coords = {},
            kills = gameState['snakes'][i]['kills'],
            food = gameState['snakes'][i]['food'],
            gold = gameState['snakes'][i]['gold'] or 0
        }
        for j = 1, #gameState['snakes'][i]['coords'] do
            table.insert( newSnake['coords'], convert_coordinates( gameState['snakes'][i]['coords'][j] ) )
        end
        table.insert( newState['snakes'], newSnake )
    end
    
    return newState
end


--- Calculates the direction, given a source and destination coordinate pair
-- @param table src The source coordinate pair
-- @param table dst The destination coordinate pair
-- @return string The name of the direction
function util.direction( src, dst )
    if dst[1] == src[1]+1 and dst[2] == src[2] then
        if RULES_VERSION == 2016 then
            return 'east'
        elseif RULES_VERSION == 2017 then
            return 'right'
        end
    elseif dst[1] == src[1]-1 and dst[2] == src[2] then
        if RULES_VERSION == 2016 then
            return 'west'
        elseif RULES_VERSION == 2017 then
            return 'left'
        end
    elseif dst[1] == src[1] and dst[2] == src[2]+1 then
        if RULES_VERSION == 2016 then
            return 'south'
        elseif RULES_VERSION == 2017 then
            return 'down'
        end
    elseif dst[1] == src[1] and dst[2] == src[2]-1 then
        if RULES_VERSION == 2016 then
            return 'north'
        elseif RULES_VERSION == 2017 then
            return 'up'
        end
    end
end


--- Calculates the manhattan distance between two coordinate pairs
-- @param table src The source coordinate pair
-- @param table dst The destination coordinate pair
-- @return int The distance between the pairs
function util.mdist( src, dst )
    local dx = math.abs( src[1] - dst[1] )
    local dy = math.abs( src[2] - dst[2] )
    return ( dx + dy )
end


-- @see https://github.com/vadi2/mudlet-lua/blob/2630cbeefc3faef3079556cb06459d1f53b8f842/lua/TableUtils.lua#L332
function util.n_complement(set1, set2)
    if not set1 and set2 then return false end

    local complement = {}

    for _, val1 in pairs(set1) do
        local insert = true
        for _, val2 in pairs(set2) do
            if _comp(val1, val2) then
                    insert = false
            end
        end
        if insert then table.insert(complement, val1) end
    end

    return complement
end


--- Prints the grid as an ASCII representation of the world map
-- @param grid The game grid
function util.printWorldMap( grid )
    local str = "\n"
    for y = 1, #grid do
        for x = 1, #grid[y] do
            str = str .. grid[y][x]
        end
        if y < #grid then
            str = str .. "\n"
        end
    end
    log( DEBUG, str )
end


return util