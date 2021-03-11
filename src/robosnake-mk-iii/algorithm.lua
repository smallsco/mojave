local algorithm = {}


-- Lua optimization: any functions from another module called more than once
-- are faster if you create a local reference to that function.
local util = require( "robosnake-mk-iii.util" )
local DEBUG = 'trace'
local log = function( level, str ) return end
local mdist = util.mdist
local n_complement = util.n_complement
local prettyCoords = util.prettyCoords
local printWorldMap = util.printWorldMap


--[[
    PRIVATE METHODS
]]


--- Clones a table recursively.
--- Modified to ignore metatables because we don't use them.
-- @param table t The source table
-- @return table The copy of the table
-- @see https://gist.github.com/MihailJP/3931841
local function deepcopy(t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = deepcopy(v)
        else
            target[k] = v
        end
    end
    return target
end


--- Returns true if a square is safe to move into, false otherwise
-- @param string v The value of a particular tile on the grid
-- @param boolean failsafe If true, don't consider if the neighbour is safe or not
-- @return boolean
local function isSafeSquare( v, failsafe )
    if failsafe then
        return true
    else
        return v == '.' or v == 'O' or v == '*'
    end
end


--- Returns true if a square is currently occupied, false otherwise
-- @param string v The value of a particular tile on the grid
-- @return boolean
local function isSafeSquareFloodfill( v )
    return v == '.' or v == 'O' or v == '*'
end


--- "Floods" the grid in order to find out how many squares are accessible to us
--- This ruins the grid, make sure you always work on a deepcopy of the grid!
-- @param table pos The starting position
-- @param table grid The game grid
-- @param int numSafe The number of free squares from the last iteration
-- @param int len The maximum depth of the flood fill
-- @return int The number of free squares on the grid
-- @see https://en.wikipedia.org/wiki/Flood_fill#Stack-based_recursive_implementation_.28four-way.29
local function floodfill( pos, grid, numSafe, len )
    if numSafe >= len then
        return numSafe
    end
    local y = pos[ 'y' ]
    local x = pos[ 'x' ]
    if isSafeSquareFloodfill( grid[y][x] ) then
        grid[y][x] = 1
        numSafe = numSafe + 1
        local n = algorithm.neighbours( pos, grid )
        for i = 1, #n do
            numSafe = floodfill( n[i], grid, numSafe, len )
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

    -- Default board score
    local score = 0

    -- Handle head-on-head collisions.
    if
        state[ 'me' ][ 'body' ][1][ 'x' ] == state[ 'enemy' ][ 'body' ][1][ 'x' ]
        and state[ 'me' ][ 'body' ][1][ 'y' ] == state[ 'enemy' ][ 'body' ][1][ 'y' ]
    then
        log( DEBUG, 'Head-on-head collision!' )
        if #state[ 'me' ][ 'body' ] > #state[ 'enemy' ][ 'body' ] then
            log( DEBUG, 'I am bigger and win!' )
            score = score + 2147483647
        elseif #state[ 'me' ][ 'body' ] < #state[ 'enemy' ][ 'body' ] then
            log( DEBUG, 'I am smaller and lose.' )
            score = score - 2147483648
        else
            -- do not use negative infinity here.
            -- draws are better than losing because the bounty cannot be claimed without a clear victor.
            log( DEBUG, "It's a draw." )
            score = score - 2147483647  -- one less than max int size
        end
    end

    -- My win/loss conditions
    if #my_moves == 0 then
        log( DEBUG, 'I am trapped.' )
        score = score - 2147483648
    end
    if state[ 'me' ][ 'health' ] <= 0 then
        log( DEBUG, 'I am out of health.' )
        score = score - 2147483648
    end
    
    -- get food from grid since it's a pain to update state every time we pass through minimax
    local food = {}
    for y = 1, #grid do
        for x = 1, #grid[y] do
            if grid[y][x] == 'O' then
                table.insert( food, { x = x, y = y } )
            end
        end
    end
    
    -- The floodfill heuristic should never be used alone as it will always avoid food!
    -- The reason for this is that food increases our length by one, causing one less
    -- square on the board to be available for movement.
    
    -- Run a floodfill from my current position, to find out:
    -- 1) How many squares can I reach from this position?
    -- 2) What percentage of the board does that represent?
    local floodfill_grid = deepcopy( grid )
    floodfill_grid[ state[ 'me' ][ 'body' ][1][ 'y' ] ][ state[ 'me' ][ 'body' ][1][ 'x' ] ] = '.'
    local floodfill_depth = ( 2 * #state[ 'me' ][ 'body' ] ) + #food
    local accessible_squares = floodfill( state[ 'me' ][ 'body' ][1], floodfill_grid, 0, floodfill_depth )
    
    -- try to work around the issue of not eating when using the floodfill heuristic
    if #state[ 'me' ][ 'body' ] > 1
       and state[ 'me' ][ 'body' ][ #state[ 'me' ][ 'body' ] ][ 'x' ] == state[ 'me' ][ 'body' ][ #state[ 'me' ][ 'body' ] - 1 ][ 'x' ]
       and state[ 'me' ][ 'body' ][ #state[ 'me' ][ 'body' ] ][ 'y' ] == state[ 'me' ][ 'body' ][ #state[ 'me' ][ 'body' ] - 1 ][ 'y' ]
    then
        accessible_squares = accessible_squares + 1    
    end
    
    local percent_accessible = accessible_squares / ( #grid * #grid[1] )
    
    -- If the number of squares I can see from my current position is less than my length
    -- then moving to this position *may* trap and kill us, and should be avoided if possible
    if accessible_squares <= #state[ 'me' ][ 'body' ] then
        log( DEBUG, 'I smell a trap!' )
        score = score - ( 9999999 * ( 1 / percent_accessible ) )
    end

    
    -- Enemy win/loss conditions
    if #enemy_moves == 0 then
        log( DEBUG, 'Enemy is trapped.' )
        score = score + 2147483647
    end
    if state[ 'enemy' ][ 'health' ] <= 0 then
        log( DEBUG, 'Enemy is out of health.' )
        score = score + 2147483647
    end
    
    -- Run a floodfill from the enemy's current position, to find out:
    -- 1) How many squares can the enemy reach from this position?
    -- 2) What percentage of the board does that represent?
    local enemy_floodfill_grid = deepcopy( grid )
    enemy_floodfill_grid[ state[ 'enemy' ][ 'body' ][1][ 'y' ] ][ state[ 'enemy' ][ 'body' ][1][ 'x' ] ] = '.'
    local enemy_floodfill_depth = ( 2 * #state[ 'enemy' ][ 'body' ] ) + #food
    local enemy_accessible_squares = floodfill( state[ 'enemy' ][ 'body' ][1], enemy_floodfill_grid, 0, enemy_floodfill_depth )
    
    -- try to work around the issue of not eating when using the floodfill heuristic
    if #state[ 'enemy' ][ 'body' ] > 1
       and state[ 'enemy' ][ 'body' ][ #state[ 'enemy' ][ 'body' ] ][ 'x' ] == state[ 'enemy' ][ 'body' ][ #state[ 'enemy' ][ 'body' ] - 1 ][ 'x' ]
       and state[ 'enemy' ][ 'body' ][ #state[ 'enemy' ][ 'body' ] ][ 'y' ] == state[ 'enemy' ][ 'body' ][ #state[ 'enemy' ][ 'body' ] - 1 ][ 'y' ]
    then
        enemy_accessible_squares = enemy_accessible_squares + 1    
    end
    
    local enemy_percent_accessible = enemy_accessible_squares / ( #grid * #grid[1] )
    
    -- If the number of squares the enemy can see from their current position is less than their length
    -- then moving to this position *may* trap and kill them, and should be avoided if possible
    if enemy_accessible_squares <= #state[ 'enemy' ][ 'body' ] then
        log( DEBUG, 'Enemy might be trapped!' )
        score = score + 9999999
    end
    
    -- Decide how aggressive and how hungry to be.
    local foodWeight = 0
    local aggressiveWeight = 100
    if #food <= LOW_FOOD then
        aggressiveWeight = state[ 'me' ][ 'health' ]
        foodWeight = 200 - ( 2 * state[ 'me' ][ 'health' ] )
    else
        if state[ 'me' ][ 'health' ] <= HUNGER_HEALTH or #state[ 'me' ][ 'body' ] < 4 then
            foodWeight = 100 - state[ 'me' ][ 'health' ]
        end
    end
    if #state[ 'snakes' ] > MAX_AGGRESSION_SNAKES then
        foodWeight = 1
        aggressiveWeight = 0
    end
    
    -- If there's food on the board, and I'm hungry, go for it
    -- If I'm not hungry, ignore it
    log( DEBUG, 'Food Weight: ' .. foodWeight )
    if foodWeight > 0 then
        for i = 1, #food do
            local dist = mdist( state[ 'me' ][ 'body' ][1], food[i] )
            -- "i" is used in the score so that two pieces of food that 
            -- are equal distance from me do not have identical weighting
            score = score - ( dist * foodWeight ) - i
            log( DEBUG, string.format( 'Food [%s,%s], distance %s, score %s', food[i][ 'x' ], food[i][ 'y' ], dist, ( dist * foodWeight ) - i ) )
        end
    end

    -- Hang out near the enemy's head
    local kill_squares = algorithm.neighbours( state[ 'enemy' ][ 'body' ][1], grid )
    local enemy_last_direction = nil
    if #state[ 'enemy' ][ 'body' ] > 1 then
        enemy_last_direction = util.direction( state[ 'enemy' ][ 'body' ][2], state[ 'enemy' ][ 'body' ][1] )
    end
    for i = 1, #kill_squares do
        local dist = mdist( state[ 'me' ][ 'body' ][1], kill_squares[i] )
        local direction = util.direction( state[ 'enemy' ][ 'body' ][1], kill_squares[i] )
        if direction == enemy_last_direction then
            score = score - ( dist * ( 2 * aggressiveWeight ) )
            log( DEBUG, string.format( 'Prime head target [%s,%s], distance %s, score %s', kill_squares[i][ 'x' ], kill_squares[i][ 'y' ], dist, dist * ( 2 * aggressiveWeight ) ) )
        else
            score = score - ( dist * aggressiveWeight )
            log( DEBUG, string.format( 'Head target [%s,%s], distance %s, score %s', kill_squares[i][ 'x' ], kill_squares[i][ 'y' ], dist, dist * aggressiveWeight ) )
        end
    end
    
    -- Avoid possible tunnels
    local my_neighbours = algorithm.neighbours( state[ 'me' ][ 'body' ][1], grid )
    if #my_neighbours == 1 then
        log( DEBUG, 'I am in a tunnel!' )
        score = score - 50000
    end
    
    -- Try to put the enemy into possible tunnels
    local enemy_neighbours = algorithm.neighbours( state[ 'enemy' ][ 'body' ][1], grid )
    if #enemy_neighbours == 1 then
        log( DEBUG, 'Enemy is in a tunnel!' )
        score = score + 50000
    end
    
    -- Avoid the edge of the game board
    if
        state[ 'me' ][ 'body' ][1][ 'x' ] == 1
        or state[ 'me' ][ 'body' ][1][ 'x' ] == #grid[1]
        or state[ 'me' ][ 'body' ][1][ 'y' ] == 1
        or state[ 'me' ][ 'body' ][1][ 'y' ] == #grid
    then
        score = score - 25000
    end
     
    -- Hang out near the center
    -- Unused, but keep it around in case they ever bring gold back.
    --[[local center_x = math.ceil( #grid[1] / 2 )
    local center_y = math.ceil( #grid / 2 )
    local dist = mdist( state[ 'me' ][ 'body' ][1], { x = center_x, y = center_y } )
    score = score - (dist * 100)
    log( DEBUG, string.format('Center distance %s, score %s', dist, dist*100 ) )]]
    
 
    log( DEBUG, 'Original score: ' .. score )
    log( DEBUG, 'Percent accessible: ' .. percent_accessible )
    if score < 0 then
        score = score * (1/percent_accessible)
    elseif score > 0 then
        score = score * percent_accessible
    end
    
    log( DEBUG, 'Score: ' .. score )

    return score
end


--[[
    PUBLIC METHODS
]]

--- Returns the set of all coordinate pairs on the board that are adjacent to the given position
-- @param table pos The source coordinate pair
-- @param table grid The game grid
-- @param boolean failsafe If true, don't consider if the neighbour is safe or not
-- @return table The neighbours of the source coordinate pair
function algorithm.neighbours( pos, grid, failsafe )
    local neighbours = {}
    local north = { x = pos[ 'x' ], y = pos[ 'y' ] - 1 }
    local south = { x = pos[ 'x' ], y = pos[ 'y' ] + 1 }
    local east = { x = pos[ 'x' ] + 1, y = pos[ 'y' ] }
    local west = { x = pos[ 'x' ] - 1, y = pos[ 'y' ] }
    
    local height = #grid
    local width = #grid[1]
    
    if north[ 'y' ] > 0 and north[ 'y' ] <= height and isSafeSquare( grid[ north[ 'y' ] ][ north[ 'x' ] ], failsafe ) then
        table.insert( neighbours, north )
    end
    if south[ 'y' ] > 0 and south[ 'y' ] <= height and isSafeSquare( grid[ south[ 'y' ] ][ south[ 'x' ] ], failsafe ) then
        table.insert( neighbours, south )
    end
    if east[ 'x' ] > 0 and east[ 'x' ] <= width and isSafeSquare( grid[ east[ 'y' ] ][ east[ 'x' ] ], failsafe ) then
        table.insert( neighbours, east )
    end
    if west[ 'x' ] > 0 and west[ 'x' ] <= width and isSafeSquare( grid[ west[ 'y' ] ][ west[ 'x' ] ], failsafe ) then
        table.insert( neighbours, west )
    end
    
    return neighbours
end


-- A failsafe algorithm to run when alphabeta doesn't return a move.
-- @param me My state
-- @param snakes The state of all other snakes in play
-- @param grid The game grid
-- @param food_count The number of food on the board
-- @return bestMove The optimal next move
function algorithm.failsafe( me, snakes, grid, food_count )
    local my_moves = algorithm.neighbours( me[ 'body' ][1], grid )
    local safe_moves = algorithm.neighbours( me[ 'body' ][1], grid )
    
    -- safe moves are squares where we can move into that a
    -- larger or equal sized enemy cannot move into
    for i = 1, #snakes do
        if snakes[ i ][ 'id' ] ~= me[ 'id' ] then
            if #snakes[ i ][ 'body' ] >= #me[ 'body' ] then
                local enemy_moves = algorithm.neighbours( snakes[ i ][ 'body' ][1], grid )
                safe_moves = n_complement( safe_moves, enemy_moves )
            end
        end
    end
    
    local bestMove = nil
    if #safe_moves > 0 then
        -- If a safe move is available, prefer it. If multiple safe moves are available,
        -- move to the safe neighbour with maximum space.
        bestMove = safe_moves[1]
        local most_accessible_squares = 0
        local floodfill_depth = ( 2 * #me[ 'body' ] ) + food_count
        for i = 1, #safe_moves do
            local floodfill_grid = deepcopy( grid )
            local accessible_squares = floodfill( safe_moves[i], floodfill_grid, 0, floodfill_depth )
            if accessible_squares > most_accessible_squares then
                bestMove = safe_moves[i]
                most_accessible_squares = accessible_squares
            end
        end
        log( DEBUG, "Moving to the safe neighbour with maximum space." )
    elseif #my_moves > 0 then
        -- We're _larger_ than the enemy, or we're smaller but there are no safe squares
        -- available - we may end up in a head-on-head collision. Prefer the free neighbour
        -- with maximum space.
        bestMove = my_moves[1]
        local most_accessible_squares = 0
        local floodfill_depth = ( 2 * #me[ 'body' ] ) + food_count
        for i = 1, #my_moves do
            local floodfill_grid = deepcopy( grid )
            local accessible_squares = floodfill( my_moves[i], floodfill_grid, 0, floodfill_depth )
            if accessible_squares > most_accessible_squares then
                bestMove = my_moves[i]    
                most_accessible_squares = accessible_squares
            end
        end
        log( DEBUG, "Moving to the free neighbour with maximum space." )
    end
    
    return bestMove
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
-- @param prev_grid The game grid from the previous depth
-- @param prev_enemy_moves The enemy move list from the previous depth
-- @return alpha/beta The alpha or beta board score
-- @return alphaMove/betaMove The alpha or beta next move
function algorithm.alphabeta( grid, state, depth, alpha, beta, alphaMove, betaMove, maximizingPlayer, prev_grid, prev_enemy_moves )

    log( DEBUG, 'Depth: ' .. depth )

    local moves = {}
    local my_moves = algorithm.neighbours( state[ 'me' ][ 'body' ][1], grid )
    local enemy_moves = {}
    if maximizingPlayer then
        enemy_moves = algorithm.neighbours( state[ 'enemy' ][ 'body' ][1], grid )
    else
        enemy_moves = prev_enemy_moves
    end
    
    if maximizingPlayer then
        moves = my_moves
        log( DEBUG, string.format( 'My Turn. Position: %s Possible moves: %s', prettyCoords( state[ 'me' ][ 'body' ] ), prettyCoords( moves ) ) )
    else
        moves = enemy_moves
        log( DEBUG, string.format( 'Enemy Turn. Position: %s Possible moves: %s', prettyCoords( state[ 'enemy' ][ 'body' ] ), prettyCoords( moves ) ) )
    end
    
    if
        depth == MAX_RECURSION_DEPTH or
        
        -- short circuit win/loss conditions
        #moves == 0 or
        state[ 'me' ][ 'health' ] <= 0 or
        state[ 'enemy' ][ 'health' ] <= 0 or
        (
            state[ 'me' ][ 'body' ][1][ 'x' ] == state[ 'enemy' ][ 'body' ][1][ 'x' ]
            and state[ 'me' ][ 'body' ][1][ 'y' ] == state[ 'enemy' ][ 'body' ][1][ 'y' ]
        )
    then
        if depth == MAX_RECURSION_DEPTH then
            log( DEBUG, 'Reached MAX_RECURSION_DEPTH.' )
        else
            log( DEBUG, 'Reached endgame state.' )
        end
        return heuristic( grid, state, my_moves, enemy_moves )
    end
    
    -- Remove last segment from all snakes on the board.
    -- This is a hack because we only predict a single enemy, so by deleting the tails
    -- of _all_ enemies from the grid as we traverse the game tree, the hope is that
    -- we will be at least smart enough to be able to move into the former tail space of
    -- any snake and not just the one that we are currently predicting.
    for i = 1, #state[ 'snakes' ] do
        if state[ 'snakes' ][ i ][ 'id' ] ~= state[ 'me' ][ 'id' ]
           and state[ 'snakes' ][ i ][ 'id' ] ~= state[ 'enemy' ][ 'id' ]
        then
            local length = #state[ 'snakes' ][ i ][ 'body' ]
            if length > 1
               and state[ 'snakes' ][i][ 'body' ][ length ][ 'x' ] == state[ 'snakes' ][i][ 'body' ][ length - 1 ][ 'x' ]
               and state[ 'snakes' ][i][ 'body' ][ length ][ 'y' ] == state[ 'snakes' ][i][ 'body' ][ length - 1 ][ 'y' ]
            then
                -- snake ate so the last segment is duplicated - change grid from # to *
                grid[ state[ 'snakes' ][i][ 'body' ][ length ][ 'y' ] ][ state[ 'snakes' ][i][ 'body' ][ length ][ 'x' ] ] = '*'
                table.remove( state[ 'snakes' ][i][ 'body' ] )
            elseif length == 0 then
                -- do nothing as this snake is completely removed from the grid
            elseif length == 1 then
                -- remove this snake from the grid completely
                grid[ state[ 'snakes' ][i][ 'body' ][ length ][ 'y' ] ][ state[ 'snakes' ][i][ 'body' ][ length ][ 'x' ] ] = '.'
                table.remove( state[ 'snakes' ][i][ 'body' ] )
            else
                -- remove last segment from the grid and turn the segment before that into the new tail
                grid[ state[ 'snakes' ][i][ 'body' ][ length ][ 'y' ] ][ state[ 'snakes' ][i][ 'body' ][ length ][ 'x' ] ] = '.'
                grid[ state[ 'snakes' ][i][ 'body' ][ length - 1 ][ 'y' ] ][ state[ 'snakes' ][i][ 'body' ][ length - 1 ][ 'x' ] ] = '*'
                table.remove( state[ 'snakes' ][i][ 'body' ] )
            end
        end
    end
  
    if maximizingPlayer then
        for i = 1, #moves do
                        
            -- Update grid and coords for this move
            log( DEBUG, string.format( 'My move: [%s,%s]', moves[i][ 'x' ], moves[i][ 'y' ] ) )
            local new_grid = deepcopy( grid )
            local new_state = deepcopy( state )
            local eating = false
            
            -- if next tile is food we are eating/healing, otherwise lose 1 health
            if new_grid[ moves[i][ 'y' ] ][ moves[i][ 'x' ] ] == 'O' then
                eating = true
                new_state[ 'me' ][ 'health' ] = 100
            else
                new_state[ 'me' ][ 'health' ] = new_state[ 'me' ][ 'health' ] - 1
            end
            
            -- remove tail from map ONLY if not growing
            local length = #new_state[ 'me' ][ 'body' ]
            if
              length > 1
              and
              (
                new_state[ 'me' ][ 'body' ][ length ][ 'x' ] == new_state[ 'me' ][ 'body' ][ length - 1 ][ 'x' ]
                and new_state[ 'me' ][ 'body' ][ length ][ 'y' ] == new_state[ 'me' ][ 'body' ][ length - 1 ][ 'y' ]
              )
            then
                -- do nothing
            else
                new_grid[ new_state[ 'me' ][ 'body' ][ length ][ 'y' ] ][ new_state[ 'me' ][ 'body' ][ length ][ 'x' ] ] = '.'
            end
            
            -- always remove tail from state
            table.remove( new_state[ 'me' ][ 'body' ] )
            
            -- move head in state and on grid
            if length > 1 then
                new_grid[ new_state[ 'me' ][ 'body' ][1][ 'y' ] ][ new_state[ 'me' ][ 'body' ][1][ 'x' ] ] = '#'
            end
            table.insert( new_state[ 'me' ][ 'body' ], 1, moves[i] )
            new_grid[ moves[i][ 'y' ] ][ moves[i][ 'x' ] ] = '@'
            
            -- if eating add to the snake's body
            if eating then
                table.insert(
                    new_state[ 'me' ][ 'body' ],
                    {
                        x = new_state[ 'me' ][ 'body' ][ length ][ 'x' ],
                        y = new_state[ 'me' ][ 'body' ][ length ][ 'y' ]
                    }
                )
                eating = false
            end
            
            -- mark if the tail is a safe square or not
            local length = #new_state[ 'me' ][ 'body' ]
            if
              length > 1
              and
              (
                new_state[ 'me' ][ 'body' ][ length ][ 'x' ] == new_state[ 'me' ][ 'body' ][ length - 1 ][ 'x' ]
                and new_state[ 'me' ][ 'body' ][ length ][ 'y' ] == new_state[ 'me' ][ 'body' ][ length - 1 ][ 'y' ]
              )
            then
                new_grid[ new_state[ 'me' ][ 'body' ][ length ][ 'y' ] ][ new_state[ 'me' ][ 'body' ][ length ][ 'x' ] ] = '#'
            else
                new_grid[ new_state[ 'me' ][ 'body' ][ length ][ 'y' ] ][ new_state[ 'me' ][ 'body' ][ length ][ 'x' ] ] = '*'
            end
            
            printWorldMap( new_grid )
            
            local newAlpha = algorithm.alphabeta( new_grid, new_state, depth + 1, alpha, beta, alphaMove, betaMove, false, grid, enemy_moves )
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
            log( DEBUG, string.format( 'Enemy move: [%s,%s]', moves[i][ 'x' ], moves[i][ 'y' ] ) )
            local new_grid = deepcopy( grid )
            local new_state = deepcopy( state )
            local eating = false
            
            -- if next tile is food we are eating/healing, otherwise lose 1 health
            if prev_grid[ moves[i][ 'y' ] ][ moves[i][ 'x' ] ] == 'O' then
                eating = true
                new_state[ 'enemy' ][ 'health' ] = 100
            else
                new_state[ 'enemy' ][ 'health' ] = new_state[ 'enemy' ][ 'health' ] - 1
            end
            
            -- remove tail from map ONLY if not growing
            local length = #new_state[ 'enemy' ][ 'body' ]
            if
              length > 1
              and
              (
                new_state[ 'enemy' ][ 'body' ][ length ][ 'x' ] == new_state[ 'enemy' ][ 'body' ][ length - 1 ][ 'x' ]
                and new_state[ 'enemy' ][ 'body' ][ length ][ 'y' ] == new_state[ 'enemy' ][ 'body' ][ length - 1 ][ 'y' ]
              )
            then
                -- do nothing
            else
                new_grid[ new_state[ 'enemy' ][ 'body' ][ length ][ 'y' ] ][ new_state[ 'enemy' ][ 'body' ][ length ][ 'x' ] ] = '.'
            end
            
            -- always remove tail from state
            table.remove( new_state[ 'enemy' ][ 'body' ] )
            
            -- move head in state and on grid
            if length > 1 then
                new_grid[ new_state[ 'enemy' ][ 'body' ][1][ 'y' ] ][ new_state[ 'enemy' ][ 'body' ][1][ 'x' ] ] = '#'
            end
            table.insert( new_state[ 'enemy' ][ 'body' ], 1, moves[i] )
            new_grid[ moves[i][ 'y' ] ][ moves[i][ 'x' ] ] = '@'
            
            -- if eating add to the snake's body
            if eating then
                table.insert(
                    new_state[ 'enemy' ][ 'body' ],
                    {
                        x = new_state[ 'enemy' ][ 'body' ][ length ][ 'x' ],
                        y = new_state[ 'enemy' ][ 'body' ][ length ][ 'y' ]
                    }
                )
                eating = false
            end
            
            -- mark if the tail is a safe square or not
            local length = #new_state[ 'enemy' ][ 'body' ]
            if
              length > 1
              and
              (
                new_state[ 'enemy' ][ 'body' ][ length ][ 'x' ] == new_state[ 'enemy' ][ 'body' ][ length - 1 ][ 'x' ]
                and new_state[ 'enemy' ][ 'body' ][ length ][ 'y' ] == new_state[ 'enemy' ][ 'body' ][ length - 1 ][ 'y' ]
              )
            then
                new_grid[ new_state[ 'enemy' ][ 'body' ][ length ][ 'y' ] ][ new_state[ 'enemy' ][ 'body' ][ length ][ 'x' ] ] = '#'
            else
                new_grid[ new_state[ 'enemy' ][ 'body' ][ length ][ 'y' ] ][ new_state[ 'enemy' ][ 'body' ][ length ][ 'x' ] ] = '*'
            end
            
            printWorldMap( new_grid )
            
            local newBeta = algorithm.alphabeta( new_grid, new_state, depth + 1, alpha, beta, alphaMove, betaMove, true, {}, {} )
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
