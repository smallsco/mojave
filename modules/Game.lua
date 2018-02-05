local Game = {}
Game.__index = Game
setmetatable( Game, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local BGM = love.audio.newSource( 'audio/music/Desert-Mayhem.mp3' )
BGM:setLooping( true )
local logoFont = love.graphics.newFont( 'fonts/monoton/Monoton-Regular.ttf', 48 )

--- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Game
function Game.new( opt )
    
    local self = setmetatable( {}, Game )
    local opt = opt or {}

    http.TIMEOUT = config[ 'gameplay' ][ 'responseTime' ]
    
    self.console_history = {}
    self.id = Util.generateUUID()
    self.map = Map({
        width = config[ 'gameplay' ][ 'boardWidth' ],
        height = config[ 'gameplay' ][ 'boardHeight' ]
    })
    self.timer = 0
    self.turn = 0
    self.walls = {}
    self.food = {}
    self.gold = {}
    
    -- If we're playing with gold, place one now
    if config[ 'gameplay' ][ 'enableGold' ] then
        local gold_x, gold_y = self.map:setTileAtFreeLocationNearCenter( Map.TILE_GOLD )
        table.insert( self.gold, { gold_x, gold_y } )
        self:log( string.format( 'Placed gold at [%s, %s]', gold_x, gold_y ), 'debug' )
    end
    
    -- If we're playing with a fixed amount of food, place it now
    if config[ 'gameplay' ][ 'foodStrategy' ] == 1 then
        for i = 1, config[ 'gameplay' ][ 'totalFood' ] do
            local food_x, food_y = self.map:setTileAtRandomFreeLocation( Map.TILE_FOOD )
            table.insert( self.food, { food_x, food_y } )
            self:log( string.format( 'Placed food at [%s, %s]', food_x, food_y ), 'debug' )
        end
    end
    
    -- add non-empty snakes to this game
    self.snakes = {}
    for i = 1, #snakes do
        if snakes[i][ 'type' ] ~= 1 then
            local x, y = self.map:setTileAtRandomFreeLocation( Map[ 'TILE_SNEK_' .. i ], 3 )
            local newSnake = Snake( snakes[i], i, self.id )
            for i = 1, config[ 'gameplay' ][ 'startingLength' ] do
                table.insert( newSnake[ 'position' ], { x, y, newSnake[ 'direction' ] } )
            end
            table.insert( self.snakes, newSnake )
            self:log( string.format( 'Placed snake "%s" at [%s, %s] with starting direction "%s"', newSnake[ 'name' ], x, y, newSnake[ 'direction' ] ), 'debug' )
            
            -- starting taunt
            -- HACK, because gameLog() won't work in the Snake() constructor
            if
                newSnake[ 'type' ] ~= 1 and
                newSnake[ 'type' ] ~= 2 and
                newSnake[ 'type' ] ~= 4 and
                newSnake[ 'taunt' ] ~= '' and
                config[ 'gameplay' ][ 'enableTaunts' ]
            then
                self:log( string.format( '%s says: %s', newSnake[ 'name' ], newSnake[ 'taunt' ] ) )
            end
        end
    end

    self.running = false

    return self
    
end

--- Game render loop
function Game:draw()

        -- Render the game board.
        if config[ 'appearance' ][ 'enableBloom' ] then
            self.map:draw( self.snakes, self.food, self.gold, self.walls )
        else
            self.map:draw2( 'true', self.snakes, self.food, self.gold, self.walls )
        end
        
        -- Draw logo top right.
        love.graphics.setColor( 255, 96, 222, 204 )
        love.graphics.setFont( logoFont )
        love.graphics.printf(
            "Mojave",
            screenWidth*0.8,
            -10,
            screenWidth - screenWidth*0.8,
            "center"
        )
        
        -- Imgui: Render right-side snake stats.
        love.graphics.setColor( 255, 255, 255, 255 )
        imgui.PushStyleVar( "WindowRounding", 0 )
        imgui.SetNextWindowSize(
            screenWidth - ( screenWidth * 0.8 ),
            screenHeight - 60
        )
        imgui.SetNextWindowPos(
            screenWidth - ( screenWidth * 0.2 ),
            60
        )
        if imgui.Begin( "Snakes", nil, { "NoResize", "NoCollapse", "NoTitleBar" } ) then
            imgui.Columns( 2, "gameStats", false )
            imgui.Text( "Turn " .. self.turn )
            imgui.NextColumn()
            imgui.SetColumnOffset( -1, 75 )
            if imgui.Button( "Map" ) then
                self.map:print()
            end
            imgui.SameLine()
            if imgui.Button( "Step" ) then
                self:tick()
            end
            imgui.SameLine()
            if self.running then
                if imgui.Button( "Stop" ) then
                    self:stop()
                end
            else
                if imgui.Button( "Play" ) then
                    self:start()
                end
            end
            imgui.SameLine()
            if imgui.Button( "Menu" ) then
                imgui.OpenPopup( "ReturnMenu" )
            end
            if imgui.BeginPopupModal( "ReturnMenu", nil, { "NoResize" } ) then
                imgui.Text( "Are you sure you want to return to the menu?\n\n" )
                imgui.Separator()
                if imgui.Button( "OK" ) then
                    self:stop()
                    BGM:stop()
                    activeGame = nil
                end
                imgui.SameLine()
                if imgui.Button( "Cancel" ) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
            imgui.Columns(1)
            imgui.Separator()
            imgui.Text( "\n" )
            imgui.Columns( 2, "snakeList", false )
            for i = 1, #self.snakes do
                imgui.Image(
                    self.snakes[i][ 'avatar' ],
                    self.snakes[i][ 'avatar' ]:getHeight() / self.snakes[i][ 'avatar' ]:getWidth() * 50,
                    self.snakes[i][ 'avatar' ]:getWidth() / self.snakes[i][ 'avatar' ]:getHeight() * 50
                )
                imgui.NextColumn()
                imgui.SetColumnOffset( -1, 60 );
                imgui.TextWrapped( self.snakes[i].name )
                if config[ 'gameplay' ][ 'enableGold' ] then
                    imgui.PushStyleColor(
                        "PlotHistogram",
                        self.snakes[i].color[1] / 255,
                        self.snakes[i].color[2] / 255,
                        self.snakes[i].color[3] / 255,
                        1.0
                    )
                    imgui.ProgressBar(
                        self.snakes[i].health / 100,
                        imgui.GetColumnWidth()*0.5,
                        15
                    )
                    imgui.PopStyleColor()
                    imgui.SameLine()
                    imgui.Text( "Age:" )
                    imgui.SameLine()
                    if self.snakes[i].alive then
                        imgui.Text( self.snakes[i].age )
                    else
                        imgui.TextColored( 1, 0, 0, 1, self.snakes[i].age )
                    end
                    imgui.ProgressBar(
                        self.snakes[i].gold / config[ 'gameplay' ][ 'goldToWin' ],
                        imgui.GetColumnWidth()*0.5,
                        15,
                        self.snakes[i].gold .. '/' .. config[ 'gameplay' ][ 'goldToWin' ] 
                    )
                    imgui.SameLine()
                    imgui.Text( "Kills: " .. self.snakes[i].kills )
                else
                    imgui.PushStyleColor(
                        "PlotHistogram",
                        self.snakes[i].color[1] / 255,
                        self.snakes[i].color[2] / 255,
                        self.snakes[i].color[3] / 255,
                        1.0
                    )
                    imgui.ProgressBar(
                        self.snakes[i].health / 100,
                        imgui.GetColumnWidth()*0.9,
                        15
                    )
                    imgui.PopStyleColor()
                    imgui.Text( "Age:" )
                    imgui.SameLine()
                    if self.snakes[i].alive then
                        imgui.Text( self.snakes[i].age )
                    else
                        imgui.TextColored( 1, 0, 0, 1, self.snakes[i].age )
                    end
                    imgui.SameLine()
                    imgui.Text( "\tKills: " .. self.snakes[i].kills )
                end
                imgui.Text( "\n" )
                imgui.NextColumn()
            end
            imgui.Columns(1)
            
        end
        imgui.End()
        
        -- Imgui: Render bottom game log.
        imgui.SetNextWindowSize(
            screenWidth - ( screenWidth * 0.2 ),
            screenHeight - ( screenHeight * 0.8 )
        )
        imgui.SetNextWindowPos(
            0,
            screenHeight - ( screenHeight * 0.2 )
        )
        if imgui.Begin( "Console", nil, { "NoResize", "NoCollapse", "NoTitleBar" } ) then
            for _, v in ipairs( self.console_history ) do
                local level, ts, msg = v[1], v[2], v[3]
                local prefix = '[' .. level .. ' ' .. ts .. ']'
                local color = { 1, 1, 1, 1 }
                if level == 'TRACE' then
                    color = Util.normalizeRGBArray({ 0, 0, 255, 255 })
                elseif level == 'DEBUG' then
                    color = Util.normalizeRGBArray({ 0, 255, 255, 255 })
                elseif level == 'INFO' then
                    color = Util.normalizeRGBArray({ 0, 255, 0, 255 })
                elseif level == 'WARN' then
                    color = Util.normalizeRGBArray({ 255, 255, 0, 255 })
                elseif level == 'ERROR' then
                    color = Util.normalizeRGBArray({ 255, 135, 0, 255 })
                elseif level == 'FATAL' then
                    color = Util.normalizeRGBArray({ 255, 0, 0, 255 })
                end
                imgui.TextColored( color[1], color[2], color[3], color[4], prefix )
                imgui.SameLine(135)
                imgui.TextWrapped( msg )
            end
            if self.running then
                imgui.SetScrollHere()
            end
        end
        imgui.End()
        imgui.PopStyleVar()
end

--- Gets the current state of the game, used in API calls to snakes
-- @param slot Which snake is requesting the current state
-- @return A table containing the game state
function Game:getState2018( slot )

    local mySnakes = {}
    local you = {}
    
    for i = 1, #self.snakes do
        local positionZeroBasedCoords = {}
        for j = 1, #self.snakes[i].position do
            table.insert( positionZeroBasedCoords, {
                object = 'point',
                x = self.snakes[i][ 'position' ][j][1] - 1,
                y = self.snakes[i][ 'position' ][j][2] - 1
            })
        end
        local snakeObj = {
            body = {
                object = 'list',
                data = positionZeroBasedCoords
            },
            health = self.snakes[i].health,
            id = self.snakes[i].id,
            length = #positionZeroBasedCoords,
            name = self.snakes[i].name,
            object = 'snake',
            taunt = self.snakes[i].taunt
        }
        if self.snakes[i][ 'slot' ] == slot then
            you = snakeObj
        end
        table.insert( mySnakes, snakeObj )
    end
    
    local foodZeroBasedCoords = {}
    for i = 1, #self.food do
        table.insert( foodZeroBasedCoords, {
            object = 'point',
            x = self.food[i][1] - 1,
            y = self.food[i][2] - 1
        })
    end
    
    return {
        object = 'world',
        id = self.id,
        you = you,
        snakes = {
            object = 'list',
            data = mySnakes
        },
        height = config[ 'gameplay' ][ 'boardHeight' ],
        width = config[ 'gameplay' ][ 'boardWidth' ],
        turn = self.turn,
        food = {
            object = 'list',
            data = foodZeroBasedCoords
        }
    }

end

--- Gets the current state of the game, used in API calls to snakes
-- @param slot Which snake is requesting the current state
-- @return A table containing the game state
function Game:getState2017( slot )

    local alive_snakes = {}
    local dead_snakes = {}
    local your_id = ''
    
    for i = 1, #self.snakes do
        if self.snakes[i][ 'slot' ] == slot then
            your_id = self.snakes[i][ 'id' ]
        end
        local positionZeroBasedCoords = {}
        for j = 1, #self.snakes[i].position do
            table.insert( positionZeroBasedCoords, {
                self.snakes[i][ 'position' ][j][1] - 1,
                self.snakes[i][ 'position' ][j][2] - 1
            })
        end
        local snakeObj = {
            coords = positionZeroBasedCoords,
            health_points = self.snakes[i].health,
            id = self.snakes[i].id,
            name = self.snakes[i].name,
            taunt = self.snakes[i].taunt
        }
        if self.snakes[i].alive then
            table.insert( alive_snakes, snakeObj )
        else
            table.insert( dead_snakes, snakeObj )
        end
    end
    
    local foodZeroBasedCoords = {}
    for i = 1, #self.food do
        table.insert( foodZeroBasedCoords, { self.food[i][1]-1, self.food[i][2]-1 } )
    end
    
    return {
        food = foodZeroBasedCoords,
        game_id = self.id,
        height = config[ 'gameplay' ][ 'boardHeight' ],
        snakes = alive_snakes,
        dead_snakes = dead_snakes,
        turn = self.turn,
        width = config[ 'gameplay' ][ 'boardWidth' ],
        you = your_id
    }

end

--- Gets the current state of the game, used in API calls to snakes
-- @return A table containing the game state
function Game:getState2016()

    local mySnakes = {}
    
    for i = 1, #self.snakes do
        local positionZeroBasedCoords = {}
        for j = 1, #self.snakes[i].position do
            table.insert( positionZeroBasedCoords, {
                self.snakes[i][ 'position' ][j][1] - 1,
                self.snakes[i][ 'position' ][j][2] - 1
            })
        end
        local status = 'alive'
        if not self.snakes[i].alive then
            status = 'dead'
        end
        table.insert( mySnakes, {
            id = self.snakes[i].id,
            name = self.snakes[i].name,
            status = status,
            message = '',
            taunt = self.snakes[i].taunt,
            age = self.snakes[i].age,
            health = self.snakes[i].health,
            coords = positionZeroBasedCoords,
            kills = self.snakes[i].kills,
            food = #positionZeroBasedCoords,  -- FIXME: length != food, due to kills
            gold = self.snakes[i].gold
        })
    end
    
    local foodZeroBasedCoords = {}
    for i = 1, #self.food do
        table.insert( foodZeroBasedCoords, { self.food[i][1]-1, self.food[i][2]-1 } )
    end
    
    local goldZeroBasedCoords = {}
    for i = 1, #self.gold do
        table.insert( goldZeroBasedCoords, { self.gold[i][1]-1, self.gold[i][2]-1 } )
    end
    
    local wallsZeroBasedCoords = {}
    for i = 1, #self.walls do
        table.insert( wallsZeroBasedCoords, { self.walls[i][1]-1, self.walls[i][2]-1 } )
    end
    
    local mode = 'classic'
    if config[ 'gameplay' ][ 'enableWalls' ] or config[ 'gameplay' ][ 'enableGold' ] then
        mode = 'advanced'
    end
    
    local gameState = {
        game = self.id,
        mode = mode,
        turn = self.turn,
        height = config[ 'gameplay' ][ 'boardHeight' ],
        width = config[ 'gameplay' ][ 'boardWidth' ],
        snakes = mySnakes,
        food = foodZeroBasedCoords
    }
    if mode == 'advanced' then
        gameState[ 'walls' ] = wallsZeroBasedCoords
        gameState[ 'gold' ] = goldZeroBasedCoords
    end
    
    return gameState

end

--- Keypress handler - allows a human player to control the snake in slot 1
-- @param key The key that was pressed
function Game:keypressed( key )
    if self.running and self.snakes[1][ 'type' ] == 2 then
        self.snakes[1]:setDirection( key )
    end
end

--- Logger
-- @param msg The message to log
-- @param level The log level
function Game:log( msg, level )
    local levels = {
        ['trace'] = 1,
        ['debug'] = 2,
        ['info'] = 3,
        ['warn'] = 4,
        ['error'] = 5,
        ['fatal'] = 6
    }
    if ( not level ) or ( not levels[ level ] ) then
        level = 'info'
    end
    if levels[level] >= config[ 'system' ][ 'logLevel' ] then 
        level = string.upper( level )
        table.insert( self.console_history, { level, os.date( "%H:%M:%S" ), msg } )
    end
end

--- Starts the game's update loop
function Game:start()
    self:log( 'Game started.' )
    self.running = true
end

--- Stops the game's update loop
function Game:stop()
    self.running = false
    self:log( 'Game stopped.' )
end


function Game:tick()

    -- DEBUGGING - CHECK FOR THE IMPOSSIBLE
    if config[ 'system' ][ 'enableSanityChecks' ] then
    
        -- MAKE SURE THE MAP STATE IS CORRECT FOR ALL SNAKES
        for i = 1, #self.snakes do
            if self.snakes[i][ 'alive' ] then
                for j = 1, #self.snakes[i][ 'position' ] do
                    if self.map.tiles[ self.snakes[i][ 'position' ][j][2] ][ self.snakes[i][ 'position' ][j][1] ] ~= self.map[ 'TILE_SNEK_' .. self.snakes[i][ 'slot' ] ] then
                        self:log( 'MAP STATE OUT OF SYNC - BREAKPOINT', 'error' )
                        self:log( string.format( 'Missing snake "%s" at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'position' ][j][1], self.snakes[i][ 'position' ][j][2] ), 'error' )
                        self.running = false
                        return
                    end
                end
            end
        end
        for i = 1, #self.food do
        
            -- a food is in the game but not on the map
            if self.map.tiles[ self.food[i][2] ][ self.food[i][1] ] ~= self.map.TILE_FOOD then
                self:log( 'MAP STATE OUT OF SYNC - BREAKPOINT', 'error' )
                self:log( string.format( 'Missing food at [%s, %s]', self.food[i][1], self.food[i][2] ), 'error' )
                self.running = false
                return
            end
            
            -- a snake and a food are occupying the same tile
            for j = 1, #self.snakes do
                if self.snakes[j][ 'alive' ] then
                    for k = 1, #self.snakes[j][ 'position' ] do
                        if
                            self.snakes[j][ 'position' ][k][1] == self.food[i][1]
                            and self.snakes[j][ 'position' ][k][2] == self.food[i][2]
                        then
                            self:log( 'GAME STATE INVALID - BREAKPOINT', 'error' )
                            self:log( string.format( 'Food at [%s, %s] also occupied by snake "%s"', self.food[i][1], self.food[i][2], self.snakes[j]['name'] ), 'error' )
                            self.running = false
                            return
                        end
                    end
                end
            end
        end
        for i = 1, #self.gold do
        
            -- a gold is in the game but not on the map
            if self.map.tiles[ self.gold[i][2] ][ self.gold[i][1] ] ~= self.map.TILE_GOLD then
                self:log( 'MAP STATE OUT OF SYNC - BREAKPOINT', 'error' )
                self:log( string.format( 'Missing gold at [%s, %s]', self.gold[i][1], self.gold[i][2] ), 'error' )
                self.running = false
                return
            end
            
            -- a snake and a gold are occupying the same tile
            for j = 1, #self.snakes do
                if self.snakes[j][ 'alive' ] then
                    for k = 1, #self.snakes[j][ 'position' ] do
                        if
                            self.snakes[j][ 'position' ][k][1] == self.gold[i][1]
                            and self.snakes[j][ 'position' ][k][2] == self.gold[i][2]
                        then
                            self:log( 'GAME STATE INVALID - BREAKPOINT', 'error' )
                            self:log( string.format( 'Gold at [%s, %s] also occupied by snake "%s"', self.gold[i][1], self.gold[i][2], self.snakes[j]['name'] ), 'error' )
                            self.running = false
                            return
                        end
                    end
                end
            end
        end
        for i = 1, #self.walls do
        
            -- a wall is in the game but not on the map
            if self.map.tiles[ self.walls[i][2] ][ self.walls[i][1] ] ~= self.map.TILE_WALL then
                self:log( 'MAP STATE OUT OF SYNC - BREAKPOINT', 'error' )
                self:log( string.format( 'Missing wall at [%s, %s]', self.walls[i][1], self.walls[i][2] ), 'error' )
                self.running = false
                return
            end
            
            -- a snake and a wall are occupying the same tile
            for j = 1, #self.snakes do
                if self.snakes[j][ 'alive' ] then
                    for k = 1, #self.snakes[j][ 'position' ] do
                        if
                            self.snakes[j][ 'position' ][k][1] == self.walls[i][1]
                            and self.snakes[j][ 'position' ][k][2] == self.walls[i][2]
                        then
                            self:log( 'GAME STATE INVALID - BREAKPOINT', 'error' )
                            self:log( string.format( 'Wall at [%s, %s] also occupied by snake "%s"', self.walls[i][1], self.walls[i][2], self.snakes[j]['name'] ), 'error' )
                            self.running = false
                            return
                        end
                    end
                end
            end
        end
    
    end

    -- TICK TOCK (goes the game clock)    
    self.timer = 0
    self.turn = self.turn + 1
    self:log( string.format( 'TICK TOCK - TURN %s', self.turn ), 'trace' )
    
    -- Make API requests to each snake and get their next direction.
    for i = 1, #self.snakes do
        if self.snakes[i][ 'alive' ] then
        
            if self.snakes[i][ 'type' ] == 3 then
                -- 2017 API
                self.snakes[i]:api( 'move', json.encode( self:getState2017( self.snakes[i][ 'slot' ] ) ) )
            elseif self.snakes[i][ 'type' ] == 6 then
                -- 2018 API
                self.snakes[i]:api( 'move', json.encode( self:getState2018( self.snakes[i][ 'slot' ] ) ) )
            elseif self.snakes[i][ 'type' ] == 4 then
                -- 2016 API
                local endpoint = 'move'
                if self.turn == 1 then
                    endpoint = 'start'
                end
                self.snakes[i]:api( endpoint, json.encode( self:getState2016( self.snakes[i][ 'slot' ] ) ) )
            elseif self.snakes[i][ 'type' ] == 5 then
                local success, response_data = coroutine.resume(
                    self.snakes[i].thread,
                    self:getState2017( self.snakes[i][ 'slot' ] )
                )
                if not success then
                    self:log( string.format( 'ROBOSNAKE: %s', response_data ), 'fatal' )
                else
                    if response_data[ 'move' ] ~= nil then
                        self.snakes[i]:setDirection( response_data[ 'move' ] )
                    end
                    if response_data[ 'taunt' ] ~= nil then
                        if response_data[ 'taunt' ] ~= self.snakes[i].taunt then
                            self.snakes[i].taunt = response_data[ 'taunt' ]
                            if config[ 'gameplay' ][ 'enableTaunts' ] then
                                gameLog( string.format( '%s says: %s', self.snakes[i].name, self.snakes[i].taunt ) )
                            end
                        end
                    end
                    
                end
            end
        end
    end
    
    -- Using their next direction, calculate their next position.
    for i = 1, #self.snakes do
        if self.snakes[i][ 'alive' ] then
            -- update age
            self.snakes[i].age = self.snakes[i].age + 1
            
            self.snakes[i]:calculateNextPosition()
        end
    end
    
    -- Check for a head-on-head collision.
    -- This is a bit trickier because we can't just look at the state of the
    -- tile (it will be free as neither snake is there yet). We have to manually
    -- compare each snake's next_x and next_y to each other.
    for i = 1, #self.snakes do
        for j = i+1, #self.snakes do
            if
                self.snakes[i][ 'alive' ] and
                self.snakes[j][ 'alive' ] and
                self.snakes[i][ 'next_x' ] == self.snakes[j][ 'next_x' ] and
                self.snakes[i][ 'next_y' ] == self.snakes[j][ 'next_y' ]
            then
                -- Snakes i and j are moving into the same square.
                self:log( string.format( '"%s" and "%s" have a head-to-head collision at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[j][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ) )
                
                -- Which snake is longer?
                local len_i = #self.snakes[i][ 'position' ]
                local len_j = #self.snakes[j][ 'position' ]
                
                if len_i > len_j then
                    self:log( string.format( '"%s" is the smaller snake and dies.', self.snakes[j]['name'] ) )
                    if not self.snakes[j][ 'delayed_death' ] then
                        self.snakes[i].kills = self.snakes[i].kills + 1
                    end
                    self.snakes[j]:die()
                elseif len_j > len_i then
                    self:log( string.format( '"%s" is the smaller snake and dies.', self.snakes[i]['name'] ) )
                    if not self.snakes[i][ 'delayed_death' ] then
                        self.snakes[j].kills = self.snakes[j].kills + 1
                    end
                    self.snakes[i]:die()
                else
                    self:log( 'They are the same size and both die.' )
                    self.snakes[i]:die()
                    self.snakes[j]:die()
                end
            end
        end
    end
    
    -- For each snake, look at the tile at their next position.
    for i = 1, #self.snakes do
        if self.snakes[i][ 'alive' ] and not self.snakes[i][ 'delayed_death' ] then
            -- Off the edge of the game board? Kill the snake.
            if
                self.snakes[i][ 'next_x' ] < 1 or
                self.snakes[i][ 'next_y' ] < 1 or
                self.snakes[i][ 'next_x' ] > config[ 'gameplay' ][ 'boardWidth' ] or
                self.snakes[i][ 'next_y' ] > config[ 'gameplay' ][ 'boardHeight' ]
            then
                self.snakes[i]:die()
                self:log( string.format( '"%s" moves beyond the edge of the world [%s, %s] and dies.', self.snakes[i][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ) )
            else
                -- Get the tile
                local tile = self.map:getTile(
                    self.snakes[i][ 'next_x' ],
                    self.snakes[i][ 'next_y' ]
                )
                
                -- Wall? Kill the snake.
                if tile == Map.TILE_WALL then
                    self:log( string.format( '"%s" next tile is WALL', self.snakes[i][ 'name' ] ), 'trace' )
                    self.snakes[i]:die()
                    self:log( string.format( '"%s" runs into a wall [%s, %s] and dies.', self.snakes[i][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ) )
                
                -- Food? Grow the snake.
                elseif tile == Map.TILE_FOOD then
                    self:log( string.format( '"%s" next tile is FOOD', self.snakes[i][ 'name' ] ), 'trace' )
                    self.snakes[i]:eat()
                    self:log( string.format( '"%s" eats the food at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ), 'debug' )
                    for j = 1, #self.food do
                        if
                            self.food[j][1] == self.snakes[i][ 'next_x' ] and
                            self.food[j][2] == self.snakes[i][ 'next_y' ]
                        then
                            self:log( string.format( 'Removed food at [%s, %s] from the world.', self.food[j][1], self.food[j][2] ), 'debug' )
                            table.remove( self.food, j )
                            break
                        end
                    end
                
                -- Gold? Snake gets richer.
                elseif tile == Map.TILE_GOLD then
                    self:log( string.format( '"%s" next tile is GOLD', self.snakes[i][ 'name' ] ), 'trace' )
                    self.snakes[i]:incrGold()
                    self:log( string.format( '"%s" collects the gold at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ), 'debug' )
                    for j = 1, #self.gold do
                        if
                            self.gold[j][1] == self.snakes[i][ 'next_x' ] and
                            self.gold[j][2] == self.snakes[i][ 'next_y' ]
                        then
                            self:log( string.format( 'Removed gold at [%s, %s] from the world.', self.gold[j][1], self.gold[j][2] ), 'debug' )
                            table.remove( self.gold, j )
                            break
                        end
                    end
                
                -- Another snake's body or tail?
                elseif
                    tile >= Map[ 'TILE_SNEK_1' ] and
                    tile <= Map[ 'TILE_SNEK_10' ]
                then
                    self:log( string.format( '"%s" next tile is SNEK_%s', self.snakes[i][ 'name' ], tile - 10 ), 'trace' )
                    local otherSnakeGrowing = false
                    local otherSnakeIndex = 0
                    local otherSnakeTailX = 0
                    local otherSnakeTailY = 0
                    local otherSnakeSlot = tile - 10
                    local otherSnakeName = ''
                    for j = 1, #self.snakes do
                        if self.snakes[j][ 'slot' ] == otherSnakeSlot then
                            otherSnakeIndex = j
                            otherSnakeName = self.snakes[j][ 'name' ]
                            otherSnakeTailX = self.snakes[j][ 'position' ][ #self.snakes[j][ 'position' ] ][1]
                            otherSnakeTailY = self.snakes[j][ 'position' ][ #self.snakes[j][ 'position' ] ][2]
                            if
                                #self.snakes[j][ 'position' ] > 1
                                and otherSnakeTailX == self.snakes[j][ 'position' ][ #self.snakes[j][ 'position' ] - 1 ][1]
                                and otherSnakeTailY == self.snakes[j][ 'position' ][ #self.snakes[j][ 'position' ] - 1 ][2]
                            then
                                otherSnakeGrowing = true
                            end
                            break
                        end
                    end
                
                    if
                        self.snakes[i][ 'next_x' ] == otherSnakeTailX and
                        self.snakes[i][ 'next_y' ] == otherSnakeTailY
                    then
                        -- Another snake's tail?
                        -- Kill the snake only if the second snake is not growing.
                        if otherSnakeGrowing then
                            self.snakes[i]:die()
                            if otherSnakeIndex ~= i then
                                self.snakes[otherSnakeIndex].kills = self.snakes[otherSnakeIndex].kills + 1
                            end
                            self:log( string.format( '"%s" runs into the tail of "%s" at [%s, %s] and dies.', self.snakes[i][ 'name' ], otherSnakeName, self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ) )
                        else
                            -- other snake is moving out of this tile
                            -- so treat it like a free tile (health drops)
                            self.snakes[i].health = self.snakes[i].health - config[ 'gameplay' ][ 'healthPerTurn' ]
                        end
                    else
                        -- Another snake's body? Kill the snake.
                        self.snakes[i]:die()
                        if otherSnakeIndex ~= i then
                            self.snakes[otherSnakeIndex].kills = self.snakes[otherSnakeIndex].kills + 1
                        end
                        self:log( string.format( '"%s" runs into the body of "%s" at [%s, %s] and dies.', self.snakes[i][ 'name' ], otherSnakeName, self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ) )
                    end
                    
                -- Free? Snake's health drops.
                else
                    self:log( string.format( '"%s" next tile is FREE', self.snakes[i][ 'name' ] ), 'trace' )
                    self.snakes[i].health = self.snakes[i].health - config[ 'gameplay' ][ 'healthPerTurn' ]
                    
                end
            end
            
            -- If a snake's health is 0, that snake dies.
            if self.snakes[i].health == 0 then
                self.snakes[i]:die()
                self:log( string.format( '"%s" dies of starvation.', self.snakes[i][ 'name' ] ) )
            end
            
        end
    end
    
    -- Remove dead snakes from the map.
    for i = 1, #self.snakes do
        if self.snakes[i][ 'delayed_death' ] then
            for _, v in ipairs( self.snakes[i][ 'position' ] ) do
                if
                    v[1] < 1 or
                    v[2] < 1 or
                    v[1] > config[ 'gameplay' ][ 'boardWidth' ] or
                    v[2] > config[ 'gameplay' ][ 'boardHeight' ]
                then
                    -- no op
                else
                    self.map:setTile( v[1], v[2], Map.TILE_FREE )
                end
            end
        end
    end
    
    -- Move all living snakes to their next position.
    -- Dead snakes can have their position updated (but not the map) so that the
    -- ghost will show where they died correctly.
    for i = 1, #self.snakes do
        if self.snakes[i][ 'alive' ] then
            if self.snakes[i][ 'delayed_death' ] then
                self:log( string.format( '"%s" remove old tail from game at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2] ), 'trace' )
                table.remove( self.snakes[i][ 'position' ] )
            else
            
                -- Remove last tail tile
                if
                    #self.snakes[i][ 'position' ] > 1
                    and
                    (
                        self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1] == self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] - 1 ][1]
                        and self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2] == self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] - 1 ][2]
                    )
                then
                    -- noop
                else
                    self:log( string.format( '"%s" remove old tail from map at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2] ), 'trace' )
                    self.map:setTile(
                        self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1],
                        self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2],
                        Map.TILE_FREE
                    )
                end
                self:log( string.format( '"%s" remove old tail from game at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2] ), 'trace' )
                table.remove( self.snakes[i][ 'position' ] )
            end
            
            -- Update new tail position to share direction with the body piece in front of it
            if #self.snakes[i][ 'position' ] > 0 then
                if self.turn == 1 then
                    for j = 1, config[ 'gameplay' ][ 'startingLength' ] - 1 do
                        self.snakes[i][ 'position' ][j][3] = self.snakes[i][ 'direction' ]
                    end
                end
                if #self.snakes[i][ 'position' ] > 1 then
                    self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][3] = self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] - 1 ][3]
                else
                    self.snakes[i][ 'position' ][1][3] = self.snakes[i][ 'direction' ]
                end
            end
            
            
            
        end
    end
    for i = 1, #self.snakes do
        if self.snakes[i][ 'alive' ] then
            if self.snakes[i][ 'delayed_death' ] then
                self:log( string.format( '"%s" add new head to game at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ), 'trace' )
                table.insert( self.snakes[i][ 'position' ], 1, {
                    self.snakes[i][ 'next_x' ],
                    self.snakes[i][ 'next_y' ],
                    self.snakes[i][ 'direction' ]
                })
            else            
                -- Move snake head to next position
                self:log( string.format( '"%s" add new head to game and map at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'next_x' ], self.snakes[i][ 'next_y' ] ), 'trace' )
                table.insert( self.snakes[i][ 'position' ], 1, {
                    self.snakes[i][ 'next_x' ],
                    self.snakes[i][ 'next_y' ],
                    self.snakes[i][ 'direction' ]
                })
                self.map:setTile(
                    self.snakes[i][ 'next_x' ],
                    self.snakes[i][ 'next_y' ],
                    Map[ 'TILE_SNEK_' .. self.snakes[i][ 'slot' ] ]
                )
            end
            
            -- If snake ate this turn, grow it
            if self.snakes[i][ 'eating' ] then
                self:log( string.format( '"%s" duplicate tail in game at [%s, %s]', self.snakes[i][ 'name' ], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1], self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2] ), 'trace' )
                table.insert( self.snakes[i][ 'position' ], {
                    self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][1],
                    self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][2],
                    self.snakes[i][ 'position' ][ #self.snakes[i][ 'position' ] ][3]
                })
                self.snakes[i][ 'eating' ] = false
            end
            
        end
    end
    
    -- Kill dead snakes for realzies.
    for i = 1, #self.snakes do
        if self.snakes[i][ 'delayed_death' ] then
            self.snakes[i][ 'delayed_death' ] = false
            self.snakes[i][ 'alive' ] = false
            
            -- might be necessary for 2018 api? since it doesn't appear to
            -- differentiate between living and dead snakes...
            self.snakes[i][ 'health' ] = 0
        end
    end
    
    -- If food strategy is fixed, and food was taken this turn, add more food.
    if config[ 'gameplay' ][ 'foodStrategy' ] == 1 then
        for i = 1, config[ 'gameplay' ][ 'totalFood' ] - #self.food do
            local food_x, food_y = self.map:setTileAtRandomFreeLocation( Map.TILE_FOOD )
            table.insert( self.food, { food_x, food_y } )
            self:log( string.format( 'Placed food at [%s, %s]', food_x, food_y ), 'debug' )
        end
    end
    
    -- If food strategy is growing, add more food if we pass the requisite number of ticks.
    if config[ 'gameplay' ][ 'foodStrategy' ] == 2 then
        if self.turn % config[ 'gameplay' ][ 'addFoodTurns' ] == 0 then
            local food_x, food_y = self.map:setTileAtRandomFreeLocation( Map.TILE_FOOD )
            table.insert( self.food, { food_x, food_y } )
            self:log( string.format( 'Placed food at [%s, %s]', food_x, food_y ), 'debug' )
        end
    end
    
    -- If walls are enabled, add a wall if we pass the requisite number of ticks.
    if
        config[ 'gameplay' ][ 'enableWalls' ]
        and self.turn % config[ 'gameplay' ][ 'addWallTurns' ] == 0
        and self.turn >= config[ 'gameplay' ][ 'wallTurnStart' ]
    then
        local badCoords = {}
        for i = 1, #self.snakes do
            if self.snakes[i][ 'alive' ] then
                local x = self.snakes[i][ 'position' ][1][1]
                local y = self.snakes[i][ 'position' ][1][2]
                table.insert( badCoords, { x+1, y } )
                table.insert( badCoords, { x-1, y } )
                table.insert( badCoords, { x, y+1 } )
                table.insert( badCoords, { x, y-1 } )
            end
        end
        local wall_x, wall_y = self.map:setTileAtRandomSafeLocation( Map.TILE_WALL, badCoords )
        table.insert( self.walls, { wall_x, wall_y } )
        self:log( string.format( 'Placed wall at [%s, %s]', wall_x, wall_y ), 'debug' )
    end
    
    -- If gold is enabled, and we pass the requisite number of ticks, and there is no gold on the game board right now, then add a gold.
    if
        config[ 'gameplay' ][ 'enableGold' ]
        and self.turn % config[ 'gameplay' ][ 'addGoldTurns' ] == 0
    then
        if next( self.gold ) == nil then
            local gold_x, gold_y = self.map:setTileAtFreeLocationNearCenter( Map.TILE_GOLD )
            table.insert( self.gold, { gold_x, gold_y } )
            self:log( string.format( 'Placed gold at [%s, %s]', gold_x, gold_y ), 'debug' )
        end
    end
    
    -- Count how many snakes are still alive.
    local livingSnakes = 0
    local winner = ''
    for i = 1, #self.snakes do
        if self.snakes[i].alive then
            livingSnakes = livingSnakes + 1
            winner = self.snakes[i].name
        end
    end
    if livingSnakes == 0 then
        -- All snakes are dead, so end the game
        self:log( 'Game Over. All snakes are dead.' )
        self:stop()
        return
    end
    if livingSnakes == 1 then
        if self.snakes[1][ 'type' ] == 2 and self.snakes[1][ 'alive' ] then
            -- The last snake alive is a human, let it play until it dies
        elseif #self.snakes == 1 then
            -- There's only one snake in the game, let it play until it dies
        else
            self:log( string.format( 'Game Over. The winner is "%s" for being the last snake alive!', winner ) )
            self:stop()
            return
        end
    end
    
    -- If gold is enabled, and any snake has reached the maximum gold, end the game.
    for i = 1, #self.snakes do
        if self.snakes[i].gold >= config[ 'gameplay' ][ 'goldToWin' ] then
            self:log( string.format( 'Game Over. The winner is "%s" for collecting all the gold!', self.snakes[i].name ) )
            self:stop()
            return
        end
    end

end


--- Update Loop
-- @param dt Delta Time
function Game:update( dt )

    -- Background music
    if config[ 'audio' ][ 'enableMusic' ] then
        if BGM:isStopped() then
            BGM:play()
        end
    else
        if BGM:isPlaying() then
            BGM:stop()
        end
    end
    
    if self.running then
        self.timer = self.timer + dt
        if self.timer < config[ 'gameplay' ][ 'gameSpeed' ] then
            return
        else
            self:tick()
        end
    end

end

return Game