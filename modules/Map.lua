local Map = {}
Map.__index = Map
setmetatable( Map, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-- Tile Constants
Map.TILE_FREE = 1       -- Tile contains nothing
Map.TILE_WALL = 2       -- Tile is a wall / blocked
Map.TILE_FOOD = 3       -- Tile contains food
Map.TILE_GOLD = 4       -- Tile contains gold
Map.TILE_SNEK_1 = 11
Map.TILE_SNEK_2 = 12
Map.TILE_SNEK_3 = 13
Map.TILE_SNEK_4 = 14
Map.TILE_SNEK_5 = 15
Map.TILE_SNEK_6 = 16
Map.TILE_SNEK_7 = 17
Map.TILE_SNEK_8 = 18
Map.TILE_SNEK_9 = 19
Map.TILE_SNEK_10 = 20


local function rotatedRectangle( mode, x, y, w, h, rx, ry, segments, r, ox, oy )
	-- Check to see if you want the rectangle to be rounded or not:
	if not oy and rx then r, ox, oy = rx, ry, segments end
	-- Set defaults for rotation, offset x and y
	r = r or 0
	ox = ox or w / 2
	oy = oy or h / 2
	love.graphics.push()
    love.graphics.translate( x + ox, y + oy )
    love.graphics.rotate( -r )
    love.graphics.rectangle( mode, -ox, -oy, w, h, rx, ry, segments )
	love.graphics.pop()
end


--- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Map
function Map.new( opt )
    
    local self = setmetatable( {}, Map )
    local opt = opt or {}
    
    -- screenWidth and screenHeight: Size of the window
    -- pixelWidth and pixelHeight: Size of the board
    local screenWidth, screenHeight = love.graphics.getDimensions()
    self.pixelWidth = screenWidth * 0.8
    self.pixelHeight = screenHeight * 0.8
    
    self.bloom = love.graphics.newCanvas( self.pixelWidth/4, self.pixelHeight/4 )
    self.hblur = love.graphics.newCanvas( self.pixelWidth/4, self.pixelHeight/4 )
    self.vblur = love.graphics.newCanvas( self.pixelWidth/4, self.pixelHeight/4 )
    self.bloomscene = love.graphics.newCanvas( self.pixelWidth, self.pixelHeight )
    self.scene = love.graphics.newCanvas( self.pixelWidth, self.pixelHeight )
    
    self.vxScale = self.pixelWidth / bgVignette:getWidth()
    self.vyScale = self.pixelHeight / bgVignette:getHeight()
    
    -- How many tiles/squares to fit into pixelWidth/pixelHeight
    self.numTilesX = opt.width or 25
    self.numTilesY = opt.height or 15
    
    -- Compute the width and height of each tile
    self.tileWidth = self.pixelWidth / self.numTilesX
    self.tileHeight = self.pixelHeight / self.numTilesY
    
    -- The "cell" is the part of each tile that we will actually draw
    -- the rest of the tile is reserved to allow the background to show through
    local outlineSize = opt.outlineSize or 1
    self.cellWidth = self.tileWidth - outlineSize
    self.cellHeight = self.tileHeight - outlineSize
    
    -- Generate the tile grid
    self.tiles = {}
    self:clear()
    
    return self
    
end

function Map:clear()

    for i = 1, self.numTilesY do
        self.tiles[i] = {}
        for j = 1, self.numTilesX do
            self.tiles[i][j] = Map.TILE_FREE
        end
    end

end

function Map:print()
    
    local chr = ''
    local str = ''
    for y = 1, self.numTilesY do
        for x = 1, self.numTilesX do
            if self.tiles[y][x] == Map.TILE_FREE then
                chr = '.'
            elseif self.tiles[y][x] == Map.TILE_WALL then
                chr = 'X'
            elseif self.tiles[y][x] == Map.TILE_GOLD then
                chr = 'G'
            elseif self.tiles[y][x] == Map.TILE_FOOD then
                chr = 'F'
            elseif self.tiles[y][x] == Map.TILE_SNEK_1 then
                chr = '1'
            elseif self.tiles[y][x] == Map.TILE_SNEK_2 then
                chr = '2'
            elseif self.tiles[y][x] == Map.TILE_SNEK_3 then
                chr = '3'
            elseif self.tiles[y][x] == Map.TILE_SNEK_4 then
                chr = '4'
            elseif self.tiles[y][x] == Map.TILE_SNEK_5 then
                chr = '5'
            elseif self.tiles[y][x] == Map.TILE_SNEK_6 then
                chr = '6'
            elseif self.tiles[y][x] == Map.TILE_SNEK_7 then
                chr = '7'
            elseif self.tiles[y][x] == Map.TILE_SNEK_8 then
                chr = '8'
            elseif self.tiles[y][x] == Map.TILE_SNEK_9 then
                chr = '9'
            elseif self.tiles[y][x] == Map.TILE_SNEK_10 then
                chr = '0'
            end
            str = str .. '[' .. chr .. ']'
        end
        str = str .. "\n"
    end
    gameLog( str, 'info' )
    
end

function Map:draw( mySnakes, food, gold, walls )

    -- clear canvases
    love.graphics.setCanvas( self.bloom, self.hblur, self.vblur )
	love.graphics.clear()
	love.graphics.setCanvas( self.bloomscene, self.scene )
	love.graphics.clear()
	love.graphics.setCanvas()
    love.graphics.clear()
	
	-- base, quarter scale base without bg
	love.graphics.setCanvas( self.scene )
	self:draw2( true, mySnakes, food, gold, walls )
	love.graphics.setCanvas( self.bloomscene )
    self:draw2( false, mySnakes, food, gold, walls )
    love.graphics.setColor( 255, 255, 255, 255 )
    local blendmode, blendalphamode = love.graphics.getBlendMode()
    love.graphics.setBlendMode( "alpha", "premultiplied" )
    
    -- apply bloom effect
    love.graphics.push()
    love.graphics.scale( 0.25, 0.25 )
    love.graphics.setCanvas( self.bloom )
    love.graphics.setShader( Shaders.bloom )
    love.graphics.draw( self.bloomscene )
    love.graphics.pop()
    
    -- apply horizontal blur
    love.graphics.setCanvas( self.hblur )
    love.graphics.setShader( Shaders.horizontalblur )
    love.graphics.draw( self.bloom )
    
    -- apply vertical blur
    love.graphics.setCanvas( self.vblur )
    love.graphics.setShader( Shaders.verticalblur )
    love.graphics.draw( self.hblur )
    
    -- final scene
    love.graphics.setCanvas()
    Shaders.combine:send( "bloomtex", self.vblur )
    love.graphics.setShader( Shaders.combine )
    love.graphics.draw( self.scene )
    love.graphics.setShader()
    love.graphics.setBlendMode( blendmode, blendalphamode )

end

--- Draws the map to the screen.
function Map:draw2( drawgrid, mySnakes, food, gold, walls )
    
    if drawgrid then
        -- Draw the grid
        for i = 1, self.numTilesY do
            for j = 1, self.numTilesX do
                if i % 2 == 0 and j % 2 == 0 then
                    love.graphics.setColor(
                        Util.denormalizeRGBArray(
                            config[ 'appearance' ][ 'tileSecondaryColor' ]
                        )
                    )
                else
                    love.graphics.setColor(
                        Util.denormalizeRGBArray(
                            config[ 'appearance' ][ 'tilePrimaryColor' ]
                        )
                    )
                end
                love.graphics.rectangle(
                    "fill",
                    1 + ((j-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
                    1 + ((i-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
                    self.cellWidth,
                    self.cellHeight
                )
            end
        end
        
        -- vignette
        if config[ 'appearance' ][ 'enableVignette' ] then
            love.graphics.setColor( 255, 255, 255, 255 )
            love.graphics.draw( bgVignette, 0, 0, 0, self.vxScale, self.vyScale )
        end
    end
    
    -- Walls
    love.graphics.setColor(
        Util.denormalizeRGBArray(
            config[ 'appearance' ][ 'wallColor' ]
        )
    )
    for i = 1, #walls do
        love.graphics.rectangle(
            "fill",
            1 + ((walls[i][1]-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
            1 + ((walls[i][2]-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
            self.cellWidth,
            self.cellHeight
        )
    end
    
    -- Food
    love.graphics.setColor(
        Util.denormalizeRGBArray(
            config[ 'appearance' ][ 'foodColor' ]
        )
    )
    for i = 1, #food do
        rotatedRectangle(
            "fill",
            1 + ((food[i][1]-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
            1 + ((food[i][2]-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
            self.cellWidth,
            self.cellHeight,
            nil,
            nil,
            nil,
            math.fmod(love.timer.getTime(), 2 * math.pi)
        )
    end
    
    -- Gold
    love.graphics.setColor(
        Util.denormalizeRGBArray(
            config[ 'appearance' ][ 'goldColor' ]
        )
    )
    for i = 1, #gold do
        rotatedRectangle(
            "fill",
            1 + ((gold[i][1]-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
            1 + ((gold[i][2]-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
            self.cellWidth,
            self.cellHeight,
            nil,
            nil,
            nil,
            math.fmod(love.timer.getTime(), 2 * math.pi)
        )
    end
    
    -- Warps?
    -- Reverse?
    --[[love.graphics.setColor(255,96,222,234)
    rotatedRectangle(
        "fill",
        1 + ((9-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
        1 + ((5-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
        self.cellWidth,
        self.cellHeight,
        nil,
        nil,
        nil,
        math.fmod(love.timer.getTime(), 2 * math.pi)
    )]]
    
    -- Sneks
    for i = 1, #mySnakes do
        for j = 1, #mySnakes[i][ 'position' ] do
        
            -- dead snakes are completely translucent
            -- living snakes get slightly translucent from their head to their tail
            local alpha = 32
            if mySnakes[i][ 'alive' ] then
                if config[ 'appearance' ][ 'fadeOutTails' ] then
                    alpha = ( ( ( #mySnakes[i][ 'position' ] - j ) * 150 ) / #mySnakes[i][ 'position' ] ) + 105
                else
                    alpha = 255
                end
            end
            love.graphics.setColor( mySnakes[i][ 'color' ][1], mySnakes[i][ 'color' ][2], mySnakes[i][ 'color' ][3], alpha )
            
            if j ~= 1 and j ~= #mySnakes[i][ 'position' ] then
            
                if
                    mySnakes[i][ 'position' ][j][1] == mySnakes[i][ 'position' ][ #mySnakes[i][ 'position' ] ][1]
                    and mySnakes[i][ 'position' ][j][2] == mySnakes[i][ 'position' ][ #mySnakes[i][ 'position' ] ][2]
                then
                    -- noop
                else
                    -- body
                    love.graphics.rectangle(
                        "fill",
                        1 + ((mySnakes[i][ 'position' ][j][1]-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
                        1 + ((mySnakes[i][ 'position' ][j][2]-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
                        self.cellWidth,
                        self.cellHeight
                    )
                end
            
            elseif j == #mySnakes[i][ 'position' ] then
            
                if
                    mySnakes[i][ 'position' ][j][1] == mySnakes[i][ 'position' ][1][1]
                    and mySnakes[i][ 'position' ][j][2] == mySnakes[i][ 'position' ][1][2]
                then
                    -- noop
                else
                    -- tail
                    local r = 0
                    local xs = self.cellWidth / mySnakes[i][ 'tail' ]:getWidth()
                    local ys = self.cellHeight / mySnakes[i][ 'tail' ]:getHeight()
                    if mySnakes[i][ 'position' ][j][3] == Snake.DIRECTION_NORTH then
                        r = math.rad(270)
                        local xs2 = ys
                        ys = xs
                        xs = xs2
                    elseif mySnakes[i][ 'position' ][j][3] == Snake.DIRECTION_SOUTH then
                        r = math.rad(90)
                        local xs2 = ys
                        ys = xs
                        xs = xs2
                    elseif mySnakes[i][ 'position' ][j][3] == Snake.DIRECTION_WEST then
                        xs = -xs
                    end
                    love.graphics.draw(
                        mySnakes[i][ 'tail' ],
                        1 + ((mySnakes[i][ 'position' ][j][1]-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) + ( self.cellWidth / 2 ),
                        1 + ((mySnakes[i][ 'position' ][j][2]-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2) + ( self.cellHeight / 2 ),
                        r,
                        xs,
                        ys,
                        mySnakes[i][ 'tail' ]:getWidth() / 2,
                        mySnakes[i][ 'tail' ]:getHeight() / 2
                    )
                end
            
            elseif j == 1 then
            
                -- head
                if
                    mySnakes[i][ 'position' ][j][1] < 1 or
                    mySnakes[i][ 'position' ][j][2] < 1 or
                    mySnakes[i][ 'position' ][j][1] > config[ 'gameplay' ][ 'boardWidth' ] or
                    mySnakes[i][ 'position' ][j][2] > config[ 'gameplay' ][ 'boardHeight' ]
                then
                    -- This is a dead (or about to die) snake that went off the edge
                    -- of the world, so don't try and draw its' head.
                else
                    local r = 0
                    local xs = self.cellWidth / mySnakes[i][ 'head' ]:getWidth()
                    local ys = self.cellHeight / mySnakes[i][ 'head' ]:getHeight()
                    if mySnakes[i][ 'position' ][j][3] == Snake.DIRECTION_NORTH then
                        r = math.rad(270)
                        local xs2 = ys
                        ys = xs
                        xs = xs2
                    elseif mySnakes[i][ 'position' ][j][3] == Snake.DIRECTION_SOUTH then
                        r = math.rad(90)
                        local xs2 = ys
                        ys = xs
                        xs = xs2
                    elseif mySnakes[i][ 'position' ][j][3] == Snake.DIRECTION_WEST then
                        xs = -xs
                    end
                    love.graphics.draw(
                        mySnakes[i][ 'head' ],
                        1 + ((mySnakes[i][ 'position' ][j][1]-1) * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) + ( self.cellWidth / 2 ),
                        1 + ((mySnakes[i][ 'position' ][j][2]-1) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2) + ( self.cellHeight / 2 ),
                        r,
                        xs,
                        ys,
                        mySnakes[i][ 'head' ]:getWidth() / 2,
                        mySnakes[i][ 'head' ]:getHeight() / 2
                    )
                end

            end
        end
    end
	
	-- reset brush color
	love.graphics.setColor( 255, 255, 255, 255 )
    
end

--- Returns the value of a tile
-- @param x The X coordinate of the game board
-- @param y The Y coordinate of the game board
-- @return The value of the tile at the given X and Y coordinates
function Map:getTile( x, y )
    return self.tiles[y][x]
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
    local cx = math.ceil( self.numTilesX / 2 )
    local cy = math.ceil( self.numTilesY / 2 )
    local direction = 1
    local distance = 1
    
    if self.tiles[cy][cx] == Map.TILE_FREE then
        self.tiles[cy][cx] = value
        return cx, cy
    end
    
    while ( math.abs(cx) <= self.numTilesX or math.abs(cy) <= self.numTilesY ) do
    
        for i = 1, distance do
            cx = cx + direction
            if ( math.abs(cx) <= self.numTilesX and math.abs(cy) <= self.numTilesY ) then
                if self.tiles[cy][cx] == Map.TILE_FREE then
                    self.tiles[cy][cx] = value
                    return cx, cy
                end
            end
        end
        
        for i = 1, distance do
            cy = cy + direction
            if ( math.abs(cx) <= self.numTilesX and math.abs(cy) <= self.numTilesY ) then
                if self.tiles[cy][cx] == Map.TILE_FREE then
                    self.tiles[cy][cx] = value
                    return cx, cy
                end
            end
        end
        
        distance = distance + 1
        direction = direction * -1
    end
    
    error( 'No free spaces available on the game board' )
         
end

--- Sets a tile of a specific type at a random, free location
-- @param value The value to set the tile to
-- @param border A border of tiles around the edge of the map that cannot be selected
-- @return The x and y coordinates that were selected
function Map:setTileAtRandomFreeLocation( value, border )
    local x, y
    repeat
        if border then
            x = love.math.random( border, self.numTilesX - border + 1 )
            y = love.math.random( border, self.numTilesY - border + 1 )
        else
            x = love.math.random( self.numTilesX )
            y = love.math.random( self.numTilesY )
        end
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
        x = love.math.random( self.numTilesX )
        y = love.math.random( self.numTilesY )
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