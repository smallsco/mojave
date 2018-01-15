local Robosnake = {}
Robosnake.util = require( "robosnake.util" )
Robosnake.algorithm = require( "robosnake.algorithm" )
function Robosnake.move( gameState )

    while true do

        --[[
              ______  _____  ______   _____  _______ __   _ _______ _     _ _______
             |_____/ |     | |_____] |     | |______ | \  | |_____| |____/  |______
             |    \_ |_____| |_____] |_____| ______| |  \_| |     | |    \_ |______
                                                                                   
            -----------------------------------------------------------------------
            
            @author Scott Small <scott.small@rdbrck.com>
            @copyright 2017 Redbrick Technologies, Inc.
            @license MIT
        ]]
        
        -- Constants
        MAX_RECURSION_DEPTH = config[ 'system' ][ 'roboRecursionDepth' ]
        SNAKE_ID = 'robosnake'
        RULES_VERSION = 2017
        
        local util = Robosnake.util
        local algorithm = Robosnake.algorithm
        
        -- Lua optimization: any functions from another module called more than once
        -- are faster if you create a local reference to that function.
        local DEBUG = 'trace'
        local log = function( level, str ) gameLog( 'ROBOSNAKE: ' .. str, level ) end
        local mdist = util.mdist
        local neighbours = algorithm.neighbours
        
        
        --[[
            MAIN APP LOGIC
        ]]
        
        -- Seed Lua's PRNG
        bestMove = nil
        math.randomseed( os.time() )
        
        log( DEBUG, 'Converting Coordinates' )
        gameState = util.convert_gamestate( gameState )
        
        log( DEBUG, 'Building World Map' )
        local grid = util.buildWorldMap( gameState )
        util.printWorldMap( grid )
        
        
        -- This snake makes use of alpha-beta pruning to advance the gamestate
        -- and predict enemy behavior. However, it only works for a single
        -- enemy. While you can put it into a game with multiple snakes, it
        -- will only look at the closest enemy when deciding the next move
        -- to make.
        if #gameState['snakes'] > 2 then
            log( DEBUG, "WARNING: Multiple enemies detected. Choosing the closest snake for behavior prediction." )
        end
        
        -- Who am I?
        local id = gameState['you']
        if not id then
            id = SNAKE_ID
        end
        
        -- Convenience vars
        local me, enemy
        local distance = 99999
        for i = 1, #gameState['snakes'] do
            if gameState['snakes'][i]['id'] == id then
                me = gameState['snakes'][i]
            end
        end
        if not me then
            log( DEBUG, "FATAL: Can't find myself on the game board." )
            ngx.exit( ngx.HTTP_INTERNAL_SERVER_ERROR )
        end
        for i = 1, #gameState['snakes'] do
            if gameState['snakes'][i]['id'] ~= id then
                if RULES_VERSION == 2016 then
                    if gameState['snakes'][i]['status'] == 'alive' then
                        local d = mdist( me['coords'][1], gameState['snakes'][i]['coords'][1] )
                        if d < distance then
                            distance = d
                            enemy = gameState['snakes'][i]
                        end
                    end
                elseif RULES_VERSION == 2017 then
                    local d = mdist( me['coords'][1], gameState['snakes'][i]['coords'][1] )
                    if d < distance then
                        distance = d
                        enemy = gameState['snakes'][i]
                    end
                end
            end
        end
        
        -- This is just to keep from crashing if we're testing in an arena by ourselves
        -- though I am curious to see what will happen when trying to predict my own behavior!
        if not enemy then
            log( DEBUG, "WARNING: I am the only snake in the game! Using MYSELF for behavior prediction." )
            enemy = me
        end
        
        log( DEBUG, 'Enemy Snake: ' .. enemy['name'] )
        local myState = {
            me = me,
            enemy = enemy
        }
        
        -- Alpha-Beta Pruning algorithm
        -- This is significantly faster than minimax on a single processor, but very challenging to parallelize
        local bestScore, bestMove = algorithm.alphabeta(grid, myState, 0, -math.huge, math.huge, nil, nil, true)
        log( DEBUG, string.format('Best score: %s', bestScore) )
        log( DEBUG, string.format('Best move: %s', inspect(bestMove)) )
        
        -- FAILSAFE #1
        -- Prediction thinks we're going to die soon, however, predictions can be wrong.
        -- Pick a random safe neighbour and move there.
        if not bestMove then
            log( DEBUG, "WARNING: Trying to cheat death." )
            local my_moves = neighbours( myState['me']['coords'][1], grid )
            local enemy_moves = neighbours( myState['enemy']['coords'][1], grid )
            local safe_moves = util.n_complement(my_moves, enemy_moves)
            
            if #myState['me']['coords'] <= #myState['enemy']['coords'] and #safe_moves > 0 then
                my_moves = safe_moves
            end
            
            if #my_moves > 0 then
                bestMove = my_moves[math.random(#my_moves)]
            end
        end
        
        -- FAILSAFE #2
        -- should only be reached if there is literally nowhere we can move
        -- this really only exists to ensure we always return a valid http response
        if not bestMove then
            log( DEBUG, "WARNING: Using failsafe move. I'm probably trapped and about to die." )
            bestMove = {me['coords'][1][1]-1,me['coords'][1][2]}
        end
        
        -- Move to the destination we decided on
        local dir = util.direction( me['coords'][1], bestMove )
        log( DEBUG, string.format( 'Decision: Moving %s to [%s,%s]', dir, bestMove[1], bestMove[2] ) )
        
        
        -- Return response to the arena
        local response = { move = dir, taunt = util.bieberQuote() }
        gameState = coroutine.yield( response )
    
    end

end
return Robosnake