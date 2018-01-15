local algorithm = {}


-- Lua optimization: any functions from another module called more than once
-- are faster if you create a local reference to that function.
local util = require( "robosnake.util" )
local DEBUG = 'trace'
local log = function( level, str ) gameLog( 'ROBOSNAKE: ' .. str, level ) end
local mdist = util.mdist
local n_complement = util.n_complement
local printWorldMap = util.printWorldMap


--[[
    PRIVATE METHODS
]]


--- Clones a table.
-- @param table orig The source table
-- @return table The copy of the table
-- @see http://lua-users.org/wiki/CopyTable
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


--- Returns true if a square is safe to pass over, false otherwise
-- @param v The value of a particular tile on the grid
-- @return boolean
local function isSafeSquare(v)
    return v == '.' or v == '$' or v == 'O' 
end


-- "Floods" the grid in order to find out how many squares are accessible to us
-- This ruins the grid, make sure you always work on a deepcopy of the grid!
-- @see https://en.wikipedia.org/wiki/Flood_fill#Stack-based_recursive_implementation_.28four-way.29
local function floodfill( pos, grid, numSafe )

    local y = pos[2]
    local x = pos[1]
    if isSafeSquare(grid[y][x]) then
        grid[y][x] = 1
        numSafe = numSafe + 1
        local n = algorithm.neighbours(pos, grid)
        for i = 1, #n do
            numSafe = floodfill(n[i], grid, numSafe)
        end
    end
    return numSafe
end


--- The heuristic function used to determine board/gamestate score
-- @param grid The game grid
-- @param state The game state
-- @param my_moves Table containing my possible moves
-- @param enemy_moves Table containing enemy's possible moves
local function heuristic( grid, state, my_moves, enemy_moves )

    -- My win/loss conditions
    if #my_moves == 0 then
        log( DEBUG, 'I am trapped.' )
        return -2147483648
    end
    if state['me']['health'] <= 0 then
        log( DEBUG, 'I am out of health.' )
        return -2147483648
    end
    if state['me']['gold'] >= 5 then
        log( DEBUG, 'I got all the gold.' )
        return 2147483647
    end
    
    -- The floodfill heuristic should never be used alone as it will always avoid food!
    -- The reason for this is that food increases our length by one, causing one less
    -- square on the board to be available for movement.
    
    -- Run a floodfill from my current position, to find out:
    -- 1) How many squares can I reach from this position?
    -- 2) What percentage of the board does that represent?
    local floodfill_grid = deepcopy(grid)
    floodfill_grid[state['me']['coords'][1][2]][state['me']['coords'][1][1]] = '.'
    local accessible_squares = floodfill( state['me']['coords'][1], floodfill_grid, 0 )
    local percent_accessible = accessible_squares / ( #grid * #grid[1] )
    
    -- If the number of squares I can see from my current position is less than my length
    -- then moving to this position *may* trap and kill us, and should be avoided if possible
    if accessible_squares <= #state['me']['coords'] then
        log( DEBUG, 'I smell a trap!' )
        return -9999999 * (1/percent_accessible)
    end
    
    
    -- Enemy win/loss conditions
    if #enemy_moves == 0 then
        log( DEBUG, 'Enemy is trapped.' )
        return 2147483647
    end
    if state['enemy']['health'] <= 0 then
        log( DEBUG, 'Enemy is out of health.' )
        return 2147483647
    end
    if state['enemy']['gold'] >= 5 then
        log( DEBUG, 'Enemy got all the gold.' )
        return -2147483648
    end
    
    -- Run a floodfill from the enemy's current position, to find out:
    -- 1) How many squares can the enemy reach from this position?
    -- 2) What percentage of the board does that represent?
    local enemy_floodfill_grid = deepcopy(grid)
    enemy_floodfill_grid[state['enemy']['coords'][1][2]][state['enemy']['coords'][1][1]] = '.'
    local enemy_accessible_squares = floodfill( state['enemy']['coords'][1], enemy_floodfill_grid, 0 )
    local enemy_percent_accessible = enemy_accessible_squares / ( #grid * #grid[1] )
    
    -- If the number of squares the enemy can see from their current position is less than their length
    -- then moving to this position *may* trap and kill them, and should be avoided if possible
    if enemy_accessible_squares <= #state['enemy']['coords'] then
        log( DEBUG, 'Enemy might be trapped!' )
        return 9999999 * percent_accessible
    end
    
    
    -- get food/gold from grid since it's a pain to update state every time we pass through minimax
    local food = {}
    local gold = {}
    for y = 1, #grid do
        for x = 1, #grid[y] do
            if grid[y][x] == 'O' then
                table.insert(food, {x, y})
            elseif grid[y][x] == '$' then
                table.insert(gold, {x, y})
            end
        end
    end
    
    -- Default board score: 100% of squares accessible
    local score = 100
    
    local center_x = math.ceil( #grid[1] / 2 )
    local center_y = math.ceil( #grid / 2 )
    
    -- If there's food on the board, and I'm hungry, go for it
    -- If I'm not hungry, ignore it
    local foodWeight = 100 - state['me']['health']
    log( DEBUG, 'Food Weight: ' .. foodWeight )
    for i = 1, #food do
        local dist = mdist( state['me']['coords'][1], food[i] )
        --local dist = mdist( {center_x, center_y}, food[i] )
        score = score - ( dist * foodWeight )
        log( DEBUG, string.format('Food %s, distance %s, score %s', inspect(food[i]), dist, (dist*foodWeight) ) )
    end
    
    -- If there's gold on the board, weight it highly... go for it unless I'm REALLY hungry
    for i = 1, #gold do
        local dist = mdist( state['me']['coords'][1], gold[i] )
        score = score - (dist * 5000)
        log( DEBUG, string.format('Gold %s, distance %s, score %s', inspect(gold[i]), dist, (dist * 5000) ) )
    end

    -- Hang out near the center
    local dist = mdist( state['me']['coords'][1], {center_x, center_y} )
    score = score - (dist * 100)
    log( DEBUG, string.format('Center distance %s, score %s', dist, dist*100 ) )
   
 
    log( DEBUG, 'Original score: ' .. score )
    log( DEBUG, 'Percent accessible: ' .. percent_accessible )
    if score < 0 then
        score = score * (1/percent_accessible)
    elseif score > 0 then
        score = score * percent_accessible
    end
    
    log( DEBUG, 'Score: ' .. score )
    printWorldMap( grid )

    return score
end


--[[
    PUBLIC METHODS
]]

--- Returns the set of all coordinate pairs on the board that are adjacent to the given position
-- @param table pos The source coordinate pair
-- @return table The neighbours of the source coordinate pair
function algorithm.neighbours( pos, grid )
    local neighbours = {}
    local north = {pos[1], pos[2]-1}
    local south = {pos[1], pos[2]+1}
    local east = {pos[1]+1, pos[2]}
    local west = {pos[1]-1, pos[2]}
    
    local height = #grid
    local width = #grid[1]
    
    if north[2] > 0 and north[2] <= height and isSafeSquare(grid[north[2]][north[1]]) then
        table.insert( neighbours, north )
    end
    if south[2] > 0 and south[2] <= height and isSafeSquare(grid[south[2]][south[1]]) then
        table.insert( neighbours, south )
    end
    if east[1] > 0 and east[1] <= width and isSafeSquare(grid[east[2]][east[1]]) then
        table.insert( neighbours, east )
    end
    if west[1] > 0 and west[1] <= width and isSafeSquare(grid[west[2]][west[1]]) then
        table.insert( neighbours, west )
    end
    
    return neighbours
end


--- The Alpha-Beta pruning algorithm.
--- When we reach maximum depth, calculate a "score" (heuristic) based on the game/board state.
--- As we come back up through the call stack, at each depth we toggle between selecting the move
--- that generates the maximum score, and the move that generates the minimum score. The idea is
--- that we want to maximize the score (pick the move that puts us in the best position), and that
--- our opponent wants to minimize the score (pick the move that puts us in the worst position).
-- @param grid The game grid
-- @param state The game state
-- @param depth The current recursion depth
-- @param alpha The highest-ranked board score at the current depth, from my PoV
-- @param beta The lowest-ranked board score at the current depth, from my PoV
-- @param alphaMove The best move at the current depth
-- @param betaMove The worst move at the current depth
-- @param maximizingPlayer True if calculating alpha at this depth, false if calculating beta
function algorithm.alphabeta(grid, state, depth, alpha, beta, alphaMove, betaMove, maximizingPlayer)

    log( DEBUG, 'Depth: ' .. depth )

    local moves = {}
    local my_moves = algorithm.neighbours( state['me']['coords'][1], grid )
    local enemy_moves = algorithm.neighbours( state['enemy']['coords'][1], grid )
    
    -- if i'm smaller than the enemy, never move to a square that the enemy can also move to
    if state['me'] ~= state['enemy'] then
        if #state['me']['coords'] <= #state['enemy']['coords'] then
            my_moves = n_complement(my_moves, enemy_moves)
        end
    end
    
    if maximizingPlayer then
        moves = my_moves
        log( DEBUG, string.format( 'My Turn. Possible moves: %s', inspect(moves) ) )
    else
        moves = enemy_moves
        log( DEBUG, string.format( 'Enemy Turn. Possible moves: %s', inspect(moves) ) )
    end
    
    if
        depth == MAX_RECURSION_DEPTH or
        
        -- short circuit win/loss conditions
        #moves == 0 or
        state['me']['health'] <= 0 or
        state['enemy']['health'] <= 0 or
        state['me']['gold'] >= 5 or
        state['enemy']['gold'] >= 5
    then
        return heuristic( grid, state, my_moves, enemy_moves )
    end
  
    if maximizingPlayer then
        for i = 1, #moves do
                        
            -- Update grid and coords for this move
            log( DEBUG, string.format( 'My move: %s', inspect(moves[i]) ) )
            local new_grid = deepcopy( grid )
            local new_state = deepcopy( state )
            table.insert( new_state['me']['coords'], 1, moves[i] )
            local length = #new_state['me']['coords']
            if new_grid[new_state['me']['coords'][1][2]][new_state['me']['coords'][1][1]] ~= 'O' then
                new_grid[new_state['me']['coords'][length][2]][new_state['me']['coords'][length][1]] = '.'
                table.remove( new_state['me']['coords'] )
                new_state['me']['health'] = new_state['me']['health'] - 1
            else
                if RULES_VERSION == 2017 then
                    new_state['me']['health'] = 100
                else
                    if new_state['me']['health'] < 70 then
                        new_state['me']['health'] = new_state['me']['health'] + 30
                    else
                        new_state['me']['health'] = 100
                    end
                end
            end
            if new_grid[new_state['me']['coords'][1][2]][new_state['me']['coords'][1][1]] == '$' then
                new_state['me']['gold'] = new_state['me']['gold'] + 1
            end
            new_grid[new_state['me']['coords'][1][2]][new_state['me']['coords'][1][1]] = '@'
            if #new_state['me']['coords'] > 1 then
                new_grid[new_state['me']['coords'][2][2]][new_state['me']['coords'][2][1]] = '#'
            end
            
            
            local newAlpha = algorithm.alphabeta(new_grid, new_state, depth + 1, alpha, beta, alphaMove, betaMove, false)
            if newAlpha > alpha then
                alpha = newAlpha
                alphaMove = moves[i]
            end
            if beta <= alpha then break end
        end
        return alpha, alphaMove
    else
        for i = 1, #moves do
            
            -- Update grid and coords for this move
            log( DEBUG, string.format( 'Enemy move: %s', inspect(moves[i]) ) )
            local new_grid = deepcopy( grid )
            local new_state = deepcopy( state )
            table.insert( new_state['enemy']['coords'], 1, moves[i] )
            local length = #new_state['enemy']['coords']
            if new_grid[new_state['enemy']['coords'][1][2]][new_state['enemy']['coords'][1][1]] ~= 'O' then
                new_grid[new_state['enemy']['coords'][length][2]][new_state['enemy']['coords'][length][1]] = '.'
                table.remove( new_state['enemy']['coords'] )
                new_state['enemy']['health'] = new_state['enemy']['health'] - 1
            else
                if RULES_VERSION == 2017 then
                    new_state['enemy']['health'] = 100
                else
                    if new_state['enemy']['health'] < 70 then
                        new_state['enemy']['health'] = new_state['enemy']['health'] + 30
                    else
                        new_state['enemy']['health'] = 100
                    end
                end
            end
            if new_grid[new_state['enemy']['coords'][1][2]][new_state['enemy']['coords'][1][1]] == '$' then
                new_state['enemy']['gold'] = new_state['enemy']['gold'] + 1
            end
            new_grid[new_state['enemy']['coords'][1][2]][new_state['enemy']['coords'][1][1]] = '@'
            if #new_state['enemy']['coords'] > 1 then
                new_grid[new_state['enemy']['coords'][2][2]][new_state['enemy']['coords'][2][1]] = '#'
            end
            
            
            local newBeta = algorithm.alphabeta(new_grid, new_state, depth + 1, alpha, beta, alphaMove, betaMove, true)
            if newBeta < beta then
                beta = newBeta
                betaMove = moves[i]
            end
            if beta <= alpha then break end
        end
        return beta, betaMove
    end
  
end


return algorithm
