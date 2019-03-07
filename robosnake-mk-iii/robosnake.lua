local RobosnakeMkIII = {}
RobosnakeMkIII.util = require( "robosnake-mk-iii.util" )
RobosnakeMkIII.algorithm = require( "robosnake-mk-iii.algorithm" )
function RobosnakeMkIII.move( gameState )

    while true do
        
        --[[
              ______  _____  ______   _____  _______ __   _ _______ _     _ _______
             |_____/ |     | |_____] |     | |______ | \  | |_____| |____/  |______
             |    \_ |_____| |_____] |_____| ______| |  \_| |     | |    \_ |______
                                                                                   
                            _______ _     _        _____ _____ _____               
                            |  |  | |____/           |     |     |                 
                            |  |  | |    \_ .      __|__ __|__ __|__               
                                                                                   
            -----------------------------------------------------------------------
            
            @author Scott Small <smallsco@gmail.com>
            @copyright 2017-2018 Redbrick Technologies, Inc.
            @copyright 2019 Scott Small
            @license MIT
        ]]
        
        -- Constants
        MAX_AGGRESSION_SNAKES = config[ 'robosnake2019' ][ 'maxAggressionSnakes' ]
        MAX_RECURSION_DEPTH = config[ 'robosnake2019' ][ 'recursionDepth' ]
        HUNGER_HEALTH = config[ 'robosnake2019' ][ 'hungerThreshold' ]
        LOW_FOOD = config[ 'robosnake2019' ][ 'lowFoodThreshold' ]
        
        local util = RobosnakeMkIII.util
        local algorithm = RobosnakeMkIII.algorithm
        
        -- Lua optimization: any functions from another module called more than once
        -- are faster if you create a local reference to that function.
        local DEBUG = 'trace'
        local log = function( level, str ) gameLog( 'ROBOSNAKE-MK-III: ' .. str, level ) end
        local mdist = util.mdist
        local neighbours = algorithm.neighbours
        
        
        --[[
            MAIN APP LOGIC
        ]]
        
        -- Seed Lua's PRNG
        bestMove = nil
        math.randomseed( os.time() )

        -- Convert to 1-based indexing
        log( DEBUG, string.format('---TURN %s---', gameState['turn'] ) )
        log( DEBUG, 'Converting Coordinates' )
        for i = 1, #gameState[ 'board' ][ 'food' ] do
            gameState[ 'board' ][ 'food' ][ i ][ 'x' ] = gameState[ 'board' ][ 'food' ][ i ][ 'x' ] + 1
            gameState[ 'board' ][ 'food' ][ i ][ 'y' ] = gameState[ 'board' ][ 'food' ][ i ][ 'y' ] + 1
        end
        for i = 1, #gameState[ 'board' ][ 'snakes' ] do
            for j = 1, #gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ] do
                gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ][ j ][ 'x' ] = gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ][ j ][ 'x' ] + 1
                gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ][ j ][ 'y' ] = gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ][ j ][ 'y' ] + 1
            end
        end
        for i = 1, #gameState[ 'you' ][ 'body' ] do
            gameState[ 'you' ][ 'body' ][ i ][ 'x' ] = gameState[ 'you' ][ 'body' ][ i ][ 'x' ] + 1
            gameState[ 'you' ][ 'body' ][ i ][ 'y' ] = gameState[ 'you' ][ 'body' ][ i ][ 'y' ] + 1
        end
        
        log( DEBUG, 'Building World Map' )
        local grid = util.buildWorldMap( gameState )
        util.printWorldMap( grid )
        
        
        -- This snake makes use of alpha-beta pruning to advance the gamestate
        -- and predict enemy behavior. However, it only works for a single
        -- enemy. While you can put it into a game with multiple snakes, it
        -- will only look at the closest enemy when deciding the next move
        -- to make.
        if #gameState[ 'board' ][ 'snakes' ] > 2 then
            log( DEBUG, "WARNING: Multiple enemies detected. Choosing the closest snake for behavior prediction." )
        end
        
        -- Convenience vars
        local me = gameState[ 'you' ]
        local possibleEnemies = {}
        local enemy = nil
        local shortestDistance = 99999
        for i = 1, #gameState[ 'board' ][ 'snakes' ] do
            if gameState[ 'board' ][ 'snakes' ][ i ][ 'id' ] ~= me[ 'id' ] then
                local d = mdist(
                    me[ 'body' ][1],
                    gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ][1]
                )
                if d == shortestDistance then
                    table.insert( possibleEnemies, gameState[ 'board' ][ 'snakes' ][ i ] )
                elseif d < shortestDistance then
                    shortestDistance = d
                    possibleEnemies = { gameState[ 'board' ][ 'snakes' ][ i ] }
                end
            end
        end
        
        if #possibleEnemies > 1 then
            
            -- only care if they're close
            if mdist( me[ 'body' ][1], possibleEnemies[1][ 'body' ][1] ) >= 4 then
                enemy = possibleEnemies[1]
            else
            
                -- There's more than one snake that's an equal distance from me!! So let's pick the shortest snake.
                log( DEBUG, "WARNING: Multiple enemies with an equal distance to me. Choosing shortest enemy for behavior prediction." )
                local shortestLength = 99999
                local newPossibleEnemies = {}
                log( DEBUG, string.format("%s %s", me[ 'name' ], #me[ 'body' ]) )
                for i = 1, #possibleEnemies do
                    log( DEBUG, string.format("%s %s", possibleEnemies[i][ 'name' ], #possibleEnemies[i][ 'body' ]) )
                    if #possibleEnemies[i][ 'body' ] == shortestLength then
                        table.insert( newPossibleEnemies, possibleEnemies[i] )
                    elseif #possibleEnemies[i][ 'body' ] < shortestLength then
                        shortestLength = #possibleEnemies[i][ 'body' ]
                        newPossibleEnemies = { possibleEnemies[i] }
                    end
                end
                if #newPossibleEnemies == 1 then
                    -- We've successfully reduced the number of targets to just one!
                    enemy = newPossibleEnemies[1]
                else
                    log( DEBUG, "CRITICAL: Multiple enemies with an equal distance to me and equal length. PICKING RANDOM ENEMY." )
                    enemy = newPossibleEnemies[1]
                end
            
            end
        elseif #possibleEnemies == 1 then
            -- There's just one snake on the board that's closer to me than any other snake
            enemy = possibleEnemies[1]
        else
            -- This is just to keep from crashing if we're testing in an arena by ourselves
            -- though I am curious to see what will happen when trying to predict my own behavior!
            log( DEBUG, "WARNING: I am the only snake in the game! Using MYSELF for behavior prediction." )
            enemy = me
        end
        
        
        -- Alpha-Beta Pruning algorithm
        -- This is significantly faster than minimax on a single processor, but very challenging to parallelize
        local bestMove = nil
        local bestScore = nil
        if enemy then
            
            log( DEBUG, 'Enemy Snake: ' .. enemy[ 'name' ] )
            local myState = {
                me = me,
                enemy = enemy,
                snakes = gameState[ 'board' ][ 'snakes' ]
            }
            local abgrid = util.buildWorldMap( gameState )
            
            -- update grid to block off any space that a larger snake other than me or enemy
            -- could possibly move into (assume equal sized snakes will try to avoid us)
            for i = 1, #gameState[ 'board' ][ 'snakes' ] do
                if gameState[ 'board' ][ 'snakes' ][ i ][ 'id' ] ~= me[ 'id' ]
                   and gameState[ 'board' ][ 'snakes' ][ i ][ 'id' ] ~= enemy[ 'id' ]
                then
                    if #gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ] > #me[ 'body' ] then
                        local moves = neighbours( gameState[ 'board' ][ 'snakes' ][ i ][ 'body' ][1], grid )
                        for j = 1, #moves do
                            abgrid[ moves[j][ 'y' ] ][ moves[j][ 'x' ] ] = '?'
                        end
                    end
                end
            end
            
            util.printWorldMap( abgrid, DEBUG )
            
            bestScore, bestMove = algorithm.alphabeta( abgrid, myState, 0, -math.huge, math.huge, nil, nil, true, {}, {} )
            log( DEBUG, string.format( 'Best score: %s', bestScore ) )
            if bestMove then
                log( DEBUG, string.format( 'Best move: [%s,%s]', bestMove[ 'x' ], bestMove[ 'y' ] ) )
            end
            
        end
        
        -- FAILSAFE #1
        -- This is reached if no move is returned by the alphabeta pruning algorithm.
        -- This can happen if the recursion depth is 0 or if searching up to the recursion depth
        -- results in all unwinnable scenarios. However this doesn't mean we are doomed, we may
        -- have moved into a space that appears to trap us, but at some move beyond the
        -- max recursion depth we are able to break free (i.e. trapped by the enemy's tail which
        -- later gets out of the way)
        if not bestMove then
            log( DEBUG, "WARNING: No move returned from alphabeta!" )
            bestMove = algorithm.failsafe( me, gameState[ 'board' ][ 'snakes' ], grid, #gameState[ 'board' ][ 'food' ] )
        end
        
        -- FAILSAFE #2
        -- If we reach this point, there isn't anywhere safe to move to and we're going to die.
        -- This only exists to ensure that we always return a valid JSON response to the game
        -- board. It always goes left.
        if not bestMove then
            log( DEBUG, "FATAL: No free neighbours. I'm going to die. Moving left!" )
            bestMove = { x = me[ 'body' ][1][ 'x' ] - 1, y = me[ 'body' ][1][ 'y' ] }
        end
        
        -- Move to the destination we decided on
        local dir = util.direction( me[ 'body' ][1], bestMove )
        log( DEBUG, string.format( 'Decision: Moving %s to [%s,%s]', dir, bestMove[ 'x' ], bestMove[ 'y' ] ) )
        
        
        -- Return response to the arena
        local response = { move = dir }
        gameState = coroutine.yield( response )


    end

end
return RobosnakeMkIII
