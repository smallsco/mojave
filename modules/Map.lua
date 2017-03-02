local Map = {}
Map.__index = Map
setmetatable( Map, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-- Constants
Map.TILE_FREE = 1   -- Tile contains nothing
Map.TILE_WALL = 2   -- Tile is a wall / blocked
Map.TILE_FOOD = 3   -- Tile contains food
Map.TILE_GOLD = 4   -- Tile contains gold

-- Head Tile Constants
Map.TILE_HEAD_1 = 10
Map.TILE_HEAD_2 = 20
Map.TILE_HEAD_3 = 30
Map.TILE_HEAD_4 = 40
Map.TILE_HEAD_5 = 50
Map.TILE_HEAD_6 = 60
Map.TILE_HEAD_7 = 70
Map.TILE_HEAD_8 = 80
Map.TILE_HEAD_9 = 90
Map.TILE_HEAD_10 = 100
Map.TILE_HEAD_11 = 110
Map.TILE_HEAD_12 = 120

-- Tail Tile Constants
Map.TILE_TAIL_1 = 11
Map.TILE_TAIL_2 = 21
Map.TILE_TAIL_3 = 31
Map.TILE_TAIL_4 = 41
Map.TILE_TAIL_5 = 51
Map.TILE_TAIL_6 = 61
Map.TILE_TAIL_7 = 71
Map.TILE_TAIL_8 = 81
Map.TILE_TAIL_9 = 91
Map.TILE_TAIL_10 = 101
Map.TILE_TAIL_11 = 111
Map.TILE_TAIL_12 = 121


--- Constructor / Factory Function
-- @param number api_version The API version
-- @param table opt A table containing initialization options
-- @return Map
function Map.new( api_version, opt )
    
    local self = setmetatable( {}, Map )
    local opt = opt or {}
    
    self.height = opt.height or 20
    self.width = opt.width or 30
    
    -- Height and width must be odd so that we always have a "center" square
    if api_version == 2016 then
        if self.height % 2 == 0 then
            log.warn('Board height is even, increasing by 1')
            self.height = self.height + 1
        end
        if self.width % 2 == 0 then
            log.warn('Board width is even, increasing by 1')
            self.width = self.width + 1
        end
    end
    self.center_x = math.ceil( self.width / 2 )
    self.center_y = math.ceil( self.height / 2 )
    
    -- The map will take up 80% of the game's resolution
    -- and be located in the top left corner.
    local pixelWidth, pixelHeight = love.graphics.getDimensions()
    self.tile_size_x = (pixelWidth * 0.8) / self.width
    self.tile_size_y = (pixelHeight * 0.8) / self.height
    
    -- Generate the tile grid
    self.tiles = {}
    for i = 1, self.height do
        self.tiles[i] = {}
        for j = 1, self.width do
            self.tiles[i][j] = Map.TILE_FREE
        end
    end
    log.debug( string.format( 'generated a grid of size %sx%s', self.width, self.height ) )
    
    return self
    
end


--- Draws the map to the screen.
function Map:draw( snakes )
    for i = 1, self.height do
        for j = 1, self.width do
            local x = (j-1) * self.tile_size_x
            local y = (i-1) * self.tile_size_y
            local tile = self.tiles[i][j]
            local radius, mode
            
            if tile >= Map.TILE_HEAD_1 and tile % Map.TILE_HEAD_1 == 0 then
                -- HEAD
                love.graphics.setColor(255,255,255,255)
                if snakes[tile/Map.TILE_HEAD_1]:getURL() ~= '' then
                    -- only render head image if non-human
                    local xscale, yscale = snakes[tile/Map.TILE_HEAD_1]:getHeadScaleFactor(self.tile_size_x, self.tile_size_y)
                    love.graphics.draw(
                        snakes[tile/Map.TILE_HEAD_1]:getHead(),
                        x,
                        y,
                        0,
                        xscale,
                        yscale
                    )
                else
                    love.graphics.rectangle(
                        'fill',
                        x,
                        y,
                        self.tile_size_x,
                        self.tile_size_y,
                        0,
                        0
                    )
                end
            else
                if tile == Map.TILE_FREE then
                    love.graphics.setColor(0,0,0,255)
                    radius = 0
                    mode = 'fill'
                elseif tile == Map.TILE_WALL then
                    love.graphics.setColor(0,0,255,255)
                    radius = 0
                    mode = 'fill'
                elseif tile == Map.TILE_FOOD then
                    love.graphics.setColor(0,255,0,255)
                    radius = 50
                    mode = 'fill'
                elseif tile == Map.TILE_GOLD then
                    love.graphics.setColor(255,255,0,255)
                    radius = 50
                    mode = 'fill'
                elseif tile >= Map.TILE_HEAD_1 and tile % Map.TILE_HEAD_1 == 1 then
                    -- TAIL
                    love.graphics.setColor(snakes[(tile-1)/Map.TILE_HEAD_1]:getColor())
                    radius = 0
                    mode = 'fill'
                end
                love.graphics.rectangle(
                    mode,
                    x,
                    y,
                    self.tile_size_x,
                    self.tile_size_y,
                    radius,
                    radius
                )
            end
                      
            
        end
    end

end

--- Getter function for the game board height
-- @return The height of the game board
function Map:getHeight()
    return self.height
end

--- Returns the value of a tile
-- @param x The X coordinate of the game board
-- @param y The Y coordinate of the game board
-- @return The value of the tile at the given X and Y coordinates
function Map:getTile( x, y )
    return self.tiles[y][x]
end

--- Getter function for the game board width
-- @return The width of the game board
function Map:getWidth()
    return self.width
end

--- Sets the value of a tile
-- @param x The X coordinate of the game board
-- @param y The Y coordinate of the game board
-- @param value The value to set the tile to
function Map:setTile( x, y, value )
    self.tiles[y][x] = value
end

--- Sets a tile of a specific type at a free location near the center of the map
-- @param value The value to set the tile to
-- @return The x and y coordinates that were selected
-- @see http://stackoverflow.com/a/398532/2578262
function Map:setTileAtFreeLocationNearCenter( value )    
    local cx = self.center_x
    local cy = self.center_y
    local direction = 1
    local distance = 1
    
    if self.tiles[cy][cx] == Map.TILE_FREE then
        self.tiles[cy][cx] = value
        return cx, cy
    end
    
    while ( math.abs(cx) <= self.width or math.abs(cy) <= self.height ) do
    
        for i = 1, distance do
            cx = cx + direction
            if ( math.abs(cx) <= self.width and math.abs(cy) <= self.height ) then
                if self.tiles[cy][cx] == Map.TILE_FREE then
                    self.tiles[cy][cx] = value
                    return cx, cy
                end
            end
        end
        
        for i = 1, distance do
            cy = cy + direction
            if ( math.abs(cx) <= self.width and math.abs(cy) <= self.height ) then
                if self.tiles[cy][cx] == Map.TILE_FREE then
                    self.tiles[cy][cx] = value
                    return cx, cy
                end
            end
        end
        
        distance = distance + 1
        direction = direction * -1
    end
    
    log.error('No free spaces available on the game board')
    error('No free spaces available on the game board')
         
end

--- Sets a tile of a specific type at a random, free location
-- @param value The value to set the tile to
-- @return The x and y coordinates that were selected
function Map:setTileAtRandomFreeLocation( value )
    local x, y
    repeat
        x = love.math.random(self.width)
        y = love.math.random(self.height)
    until self.tiles[y][x] == Map.TILE_FREE
    
    self.tiles[y][x] = value
    return x, y
end

--- Sets a tile of a specific type at a random, safe location
-- @param value The value to set the tile to
-- @oaram badCoords A table of coordinates where this tile cannot be placed
-- @return The x and y coordinates that were selected
function Map:setTileAtRandomSafeLocation( value, badCoords )
    
    local x, y, not_bad_coord, tile_is_free
    repeat
        not_bad_coord = true
        tile_is_free = true
        x = love.math.random(self.width)
        y = love.math.random(self.height)
        for i = 1, #badCoords do
            if badCoords[i][1] == x and badCoords[i][2] == y then
                not_bad_coord = false
            end
        end
        if self.tiles[y][x] ~= Map.TILE_FREE then
            tile_is_free = false
        end
    until not_bad_coord == true and tile_is_free == true
    
    self.tiles[y][x] = value
    return x, y
end


return Map