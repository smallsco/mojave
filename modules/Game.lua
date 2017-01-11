local Game = {}
Game.__index = Game
setmetatable( Game, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


--- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Game
function Game.new( opt )
    
    local self = setmetatable( {}, Game )
    local opt = opt or {}
    
    self.name = opt.name or 'test'
    self.speed = opt.speed or 0.15
    self.snakes = opt.snakes or {
        {
            id = '',
            name = 'snake',
            url = ''
        }
    }
    self.mode = opt.mode or 'advanced'  -- "classic" or "advanced"
    self.food_turn_start = opt.food_turn_start or 3
    self.food_turns = opt.food_turns or 3
    
    self.wall_turn_start = opt.wall_turn_start or 50
    self.wall_turns = opt.wall_turns or 5
    
    self.gold_turns = opt.gold_turns or 75
    self.gold_to_win = opt.gold_to_win or 5
    
    self.map = Map()
    self.timer = 0
    self.turn = 0
    self.walls = {}
    self.food = {}
    self.gold = {}
    
    -- Add a gold to the map randomly
    if self.mode == 'advanced' then
        local gold_x, gold_y = self.map:setTileAtRandomFreeLocation( Map.TILE_GOLD )
        table.insert(self.gold, {gold_x, gold_y})
        log.debug( string.format( 'added gold at (%s, %s)', self.gold_x, self.gold_y ) )
    end
    
    -- Add walls to the map randomly
    -- Battlesnake doesn't do this at the start of the game, so leave it commented out...
    --[[self.num_walls = opt.num_walls or 10
    for i = 1, self.num_walls do
        local x, y = self.map:setTileAtRandomFreeLocation( Map.TILE_WALL )
        table.insert(self.walls, {x,y})
        log.debug( string.format( 'added wall at (%s, %s)', x, y ) )
    end]]
    
    -- Add snakes to the map
    local snakes = {}
    for i = 1, #self.snakes do
        local x, y = self.map:setTileAtRandomFreeLocation( Map.TILE_HEAD )
        
        local snake = Snake({
            id = self.snakes[i]['id'],
            name = self.snakes[i]['name'],
            url = self.snakes[i]['url'],
            x = x,
            y = y
        })
        table.insert(snakes, snake)
        log.debug( string.format(
            'added snake "%s" at (%s, %s)',
            snakes[i]['name'],
            snakes[i]['x'],
            snakes[i]['y']
        ))
    end
    self.snakes = snakes
    
    self.running = false
    
    return self
    
end

function Game:draw()

    local pixelWidth, pixelHeight = love.graphics.getDimensions()

    -- Draw the map
    self.map:draw()
    
    -- Draw a border
    love.graphics.setColor(128,128,128,255)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line', -3, -3, (pixelWidth*0.8)+8, (pixelHeight*0.8)+8)
    love.graphics.setLineWidth(1)
    
    -- Draw the snake stats
    local x = pixelWidth - (pixelWidth * 0.2) + 15
    local wrap = pixelWidth - (pixelWidth * 0.8) - 30
    local str = ""
    for i = 1, #self.snakes do
        str = str .. self.snakes[i]:getName() .. "\n"
        str = str .. "\tAlive: " .. tostring(self.snakes[i]:isAlive()) .. "\n"
        str = str .. "\tAge: " .. self.snakes[i]:getAge() .. "\n"
        str = str .. "\tGold: " .. self.snakes[i]:getGold() .. "\n"
        str = str .. "\tHealth: " .. self.snakes[i]:getHealth() .. "\n"
        str = str .. "\tKills: " .. self.snakes[i]:getKills() .. "\n"
        str = str .. "\tLength: " .. self.snakes[i]:getLength() .. "\n"
        str = str .. "\n"
    end
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.printf(str, x, 10, wrap)
    
    -- Draw the taunts
    local x = 10
    local y = pixelHeight - (pixelHeight * 0.2) + 15
    local wrap = pixelWidth - 30
    local str = ""
    for i = 1, #self.snakes do
        str = str .. self.snakes[i]:getName() .. ": "
        str = str .. self.snakes[i]:getTaunt() .. "\n"
    end
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.printf(str, x, y, wrap)
    
end

function Game:getState()
    local snakes = {}
    
    for i = 1, #self.snakes do
        table.insert(snakes, {
            id = self.snakes[i]:getId(),
            name = self.snakes[i]:getName(),
            status = self.snakes[i]:isAlive() and 'alive' or 'dead',
            message = '',
            taunt = self.snakes[i]:getTaunt(),
            age = self.snakes[i]:getAge(),
            health = self.snakes[i]:getHealth(),
            coords = convert_coordinates(self.snakes[i]:getHistory(), 'topython'),
            kills = self.snakes[i]:getKills(),
            food = self.snakes[i]:getLength(),
            gold = self.snakes[i]:getGold()
        })
    end
    
    return {
        game = self.name,
        mode = self.mode,
        turn = self.turn,
        height = self.map:getHeight(),
        width = self.map:getWidth(),
        snakes = snakes,
        food = convert_coordinates(self.food, 'topython'),
        walls = convert_coordinates(self.walls, 'topython'),
        gold = convert_coordinates(self.gold, 'topython')
    }
end

function Game:keypressed( key )
    if self.running then
        if key == 'up' then
            self.snakes[1]:setDirection( 'north' )
        elseif key == 'left' then
            self.snakes[1]:setDirection( 'west' )
        elseif key == 'down' then
            self.snakes[1]:setDirection( 'south' )
        elseif key == 'right' then
            self.snakes[1]:setDirection( 'east' )
        end
    end
end

function Game:start()
    for i = 1, #self.snakes do
        self.snakes[i]:api('start', json.encode(self:getState()))
    end
    BGM:play()
    self.running = true
    log.info('game started')
end

function Game:stop()
    for i = 1, #self.snakes do
        self.snakes[i]:api('end', json.encode(self:getState()))
    end
    self.running = false
    BGM:stop()
    log.info('game stopped')
end

function Game:update( dt )
    if self.running then
    
        -- Is it time to update the game state yet?
        self.timer = self.timer + dt
        if self.timer < self.speed then
            return
        end
        
        -- Yes, update the game state
        self.timer = 0
        self.turn = self.turn + 1
        log.trace( 'tick' )
        
        -- Get each snake's next position (but don't move them yet)
        for i = 1, #self.snakes do
            log.debug(string.format('snake "%s" health: %s', self.snakes[i]:getName(), self.snakes[i]:getHealth()))
            if self.snakes[i]:isAlive() then
                self.snakes[i]:api('move', json.encode(self:getState()))
                self.snakes[i]:calculateNextPosition()
            end
        end
        
        -- Handle head-to-head collisions
        for i = 1, #self.snakes do
            if self.snakes[i]:isAlive() then
                for j = i+1, #self.snakes do
                    if self.snakes[j]:isAlive() then
                        local i_x, i_y = self.snakes[i]:getNextPosition()
                        local j_x, j_y = self.snakes[j]:getNextPosition()
                        if i_x == j_x and i_y == j_y then
                            log.debug(string.format('head to head collision between "%s" and "%s"', self.snakes[i]:getName(), self.snakes[j]:getName()))
                            local len_i = self.snakes[i]:getLength()
                            local len_j = self.snakes[j]:getLength()
                            if len_i > len_j then
                                log.debug(string.format('snake "%s" is shorter and dies', self.snakes[j]:getName()))
                                self.snakes[i]:kill(self.snakes[j])
                                self.snakes[j]:die()
                            elseif len_i < len_j then
                                log.debug(string.format('snake "%s" is shorter and dies', self.snakes[i]:getName()))
                                self.snakes[j]:kill(self.snakes[i])
                                self.snakes[i]:die()
                            else
                                log.debug(string.format('snakes "%s" and "%s" are the same length and both die', self.snakes[i]:getName(), self.snakes[j]:getName()))
                                self.snakes[i]:die()
                                self.snakes[j]:die()
                            end
                        end
                    end
                end
            end
        end
        
        -- Inspect the tile at each snake's next position
        for i = 1, #self.snakes do
        
            if self.snakes[i]:isAlive() then
                local x, y = self.snakes[i]:getNextPosition()
                if x < 1 or y < 1 or x > self.map:getWidth() or y > self.map:getHeight() then
                    -- If the next coordinate is off the game board, there's no tile
                    -- to inspect. Kill the snake.
                    self.snakes[i]:die()
                    log.debug(string.format('snake "%s" hits the edge of the world and dies', self.snakes[i]:getName()))
                else
                    -- Get the tile
                    local tile = self.map:getTile( x, y )
                    
                    if tile == Map.TILE_TAIL then
                        -- find the snake we ran into and KILL IT
                        local killed = false
                        for j = 1, #self.snakes do
                            if i ~= j then
                                local history = self.snakes[j]:getHistory()
                                for k = 1, #history do
                                    if history[k][1] == x and history[k][2] == y then
                                        self.snakes[j]:kill(self.snakes[i])
                                        killed = true
                                        break
                                    end
                                end
                                log.debug(string.format('snake "%s" hits another snake tail and dies', self.snakes[i]:getName()))
                            else
                                log.debug(string.format('snake "%s" hits itself and dies', self.snakes[i]:getName()))
                            end
                            if killed then
                                break
                            end
                        end
                        self.snakes[i]:die()
                    elseif tile == Map.TILE_WALL then
                        -- If it's a wall, the snake dies.
                        self.snakes[i]:die()
                        log.debug(string.format('snake "%s" hits a wall and dies', self.snakes[i]:getName()))
                    elseif tile == Map.TILE_FOOD then
                        -- If the tile contains food, the snake eats.
                        self.snakes[i]:eatFood()
                        for j = 1, #self.food do
                            if self.food[j][1] == x and self.food[j][2] == y then
                                table.remove(self.food, j)
                                log.debug( string.format( 'removed food at (%s, %s)', x, y ) )
                                break
                            end
                        end
                        log.debug(string.format('snake "%s" finds food and grows', self.snakes[i]:getName()))
                    elseif tile == Map.TILE_GOLD then
                        -- If the tile contains gold, the snake gets richer.
                        self.snakes[i]:incrGold()
                        for j = 1, #self.gold do
                            if self.gold[j][1] == x and self.gold[j][2] == y then
                                table.remove(self.gold, j)
                                log.debug( string.format( 'removed gold at (%s, %s)', x, y ) )
                                break
                            end
                        end
                        log.debug(string.format('snake "%s" finds gold and gets richer', self.snakes[i]:getName()))
                    else
                        -- Free tile, decrement the snake's health by 1
                        self.snakes[i]:decrementHealth()
                        log.debug(string.format('snake "%s" moves to a free square', self.snakes[i]:getName()))
                    end
                end
                
                -- If a snake's health is 0, that snake dies.
                if self.snakes[i]:getHealth() == 0 then
                    self.snakes[i]:die()
                    log.debug(string.format('snake "%s" runs out of health and dies', self.snakes[i]:getName()))
                end
            end
            
        end -- inspect tile
        
        -- Remove snakes that died this turn from the map
        for i = 1, #self.snakes do
            if not self.snakes[i]:isAlive() then
                local history = self.snakes[i]:getHistory()
                for _, v in ipairs(history) do
                    self.map:setTile(v[1], v[2], Map.TILE_FREE)
                end
                self.snakes[i]:clearHistory()
            end
        end
        
        -- Move all living snakes to the next position
        for i = 1, #self.snakes do
            if self.snakes[i]:isAlive() then
                local x, y = self.snakes[i]:getPosition()
                local next_x, next_y = self.snakes[i]:getNextPosition()
                local tailEnd = self.snakes[i]:moveNextPosition()
                
                -- move head to next position
                self.map:setTile(next_x, next_y, Map.TILE_HEAD)
                
                -- set the previous position of the head to a tail square...
                -- ... as long as the snake is bigger than 1 square
                if self.snakes[i]:getLength() > 1 then
                    self.map:setTile(x, y, Map.TILE_TAIL)
                end
                
                -- clear the tile containing the end of the snake
                if tailEnd ~= nil then
                    self.map:setTile(tailEnd[1], tailEnd[2], Map.TILE_FREE)
                end
                
                self.snakes[i]:incrAge()
            end
        end
        
        -- Add a food to the map at a random location if it's time
        if self.turn >= self.food_turn_start and self.turn % self.food_turns == 0 then
            local food_x, food_y = self.map:setTileAtRandomFreeLocation( Map.TILE_FOOD )
            table.insert(self.food, {food_x, food_y})
            log.debug( string.format( 'added food at (%s, %s)', food_x, food_y ) )
        end
        
        -- Add a wall to the map at a random location if it's time
        if self.mode == 'advanced' and self.turn >= self.wall_turn_start and self.turn % self.wall_turns == 0 then
            local wall_x, wall_y = self.map:setTileAtRandomFreeLocation( Map.TILE_WALL )
            table.insert(self.walls, {wall_x, wall_y})
            log.debug( string.format( 'added wall at (%s, %s)', wall_x, wall_y ) )
        end
        
        -- Add a gold to the map at a random location if it's time
        if self.mode == 'advanced' and self.turn % self.gold_turns == 0 then
            local gold_x, gold_y = self.map:setTileAtRandomFreeLocation( Map.TILE_GOLD )
            table.insert(self.gold, {gold_x, gold_y})
            log.debug( string.format( 'added gold at (%s, %s)', self.gold_x, self.gold_y ) )
        end
        
        -- If one or less snakes are alive, then end the game.
        local humanPlayer = false
        local livingSnakes = {}
        for i = 1, #self.snakes do
            if self.snakes[i]:isAlive() then
                table.insert(livingSnakes, i)
            end
            if self.snakes[i]:getURL() == '' then
                humanPlayer = true
            end
        end
        if #livingSnakes == 0 then
            log.info('Game Over, all snakes are dead')
            self:stop()
        elseif #livingSnakes == 1 and not humanPlayer then
            log.info(string.format('Game over, last snake remaining is "%s"', self.snakes[livingSnakes[1]]:getName()))
            self:stop()
        end
        
        -- If any snake has 5 gold, that snake wins!
        for i = 1, #self.snakes do
            if self.snakes[i]:getGold() >= self.gold_to_win then
                log.info(string.format('Game over, "%s" took home all the gold!', self.snakes[livingSnakes[1]]:getName()))
                self:stop()
            end
        end
        
    end -- if self.running
end -- function

return Game