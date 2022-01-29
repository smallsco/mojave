local Board = {}
Board.__index = Board
setmetatable( Board, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-- Helper function that draws a rectangle at a specific rotation
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

-- Constructor function
function Board.new( opt, windowWidth, windowHeight )
    local self = setmetatable( {}, Board )
    opt = opt or {}

    -- How many tiles/squares to fit into boardWidth/boardHeight
    self.numTilesX = opt.width
    self.numTilesY = opt.height

    -- The size of the gap between tiles
    self.outlineSize = opt.outlineSize or 1

    self:resize(windowWidth, windowHeight)

    return self
end

-- Draws the game board
function Board:draw( state )
    if config.appearance.enableBloom then
        self:drawBloom(state)
    else
        self:drawRaw(state, true, true)
    end
end

-- Draws the game board using a bloom filter
function Board:drawBloom( state )

    -- clear canvases
    love.graphics.setCanvas( self.bloom, self.hblur, self.vblur )
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setCanvas( self.bloomscene, self.scene )
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setCanvas()
    love.graphics.clear(0, 0, 0, 1)

    -- base, quarter scale base without bg
    love.graphics.setCanvas( self.scene )
    self:drawRaw( state, true, true )
    love.graphics.setCanvas( self.bloomscene )
    self:drawRaw( state, false, true )
    love.graphics.setColor( 1, 1, 1, 1 )
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

-- Draws the tile grid
function Board:drawGrid()
    -- Draw the grid
    for i = 1, self.numTilesY do
        for j = 1, self.numTilesX do
            if i % 2 == 0 and j % 2 == 0 then
                love.graphics.setColor(config.appearance.tileSecondaryColor)
            else
                love.graphics.setColor(config.appearance.tilePrimaryColor)
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
end

-- Draws the game board without a bloom filter
function Board:drawRaw( state, draw_grid, draw_vignette )
    local time = love.timer.getTime()

    -- Grid
    if draw_grid then
        if config.appearance.enableVignette and draw_vignette then
            self.bgVignette( function() self:drawGrid() end )
        else
            self:drawGrid()
        end
    end

    -- Food
    love.graphics.setColor(config.appearance.foodColor)
    for i = 1, #state.food do
        if config.appearance.enableAnimation then
            rotatedRectangle(
                "fill",
                (self.cellWidth * 0.25) + 1 + (state.food[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
                (self.cellHeight * 0.25) + 1 + ((self.numTilesY - 1 - state.food[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
                self.cellWidth * 0.50,
                self.cellHeight * 0.50,
                nil,
                nil,
                nil,
                math.fmod(time, 2 * math.pi)
            )
        else
            love.graphics.rectangle(
                "fill",
                (self.cellWidth * 0.25) + 1 + (state.food[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
                (self.cellHeight * 0.25) + 1 + ((self.numTilesY - 1 - state.food[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
                self.cellWidth * 0.50,
                self.cellHeight * 0.50,
                nil,
                nil,
                nil
            )
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Hazards
    local ha = 0.75
    if config.appearance.enableAnimation then
        ha = math.fmod(time, 0.95)
    end
    local hr, hg, hb = unpack(config.appearance.hazardColor)
    love.graphics.setColor(hr, hg, hb, ha)
    for i = 1, #state.hazards do
        love.graphics.rectangle(
            "fill",
            1 + (state.hazards[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
            1 + ((self.numTilesY - 1 - state.hazards[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
            self.cellWidth,
            self.cellHeight
        )
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Snakes
    for _, snake in pairs(state.snakes) do

        -- Get color
        local sr, sg, sb, sa, headImg, tailImg
        if snake.squad then
            sr, sg, sb = unpack(config.squads["squad" .. snake.squad .. "Color"])
            sa = 1
            headImg = snake.squadHeadImg
            tailImg = snake.squadTailImg
        else
            sr, sg, sb, sa = unpack(Utils.color_from_hex(snake.color))
            headImg = snake.headImg
            tailImg = snake.tailImg
        end
        if snake.eliminatedCause ~= Snake.ELIMINATION_CAUSES.NotEliminated then
            sa = 32/255
        end

        -- Get head direction
        local headDir = 'right'
        if #snake.body > 1 then
            local dx = snake.body[1].x - snake.body[2].x
            local dy = snake.body[1].y - snake.body[2].y
            if dy > 1 then dy = -1 end
            if dy < -1 then dy = 1 end
            if dx > 1 then dx = -1 end
            if dx < -1 then dx = 1 end
            if dx == -1 and dy == 0 then
                headDir = 'left'
            elseif dx == 0 and dy == -1 then
                headDir = 'down'
            elseif dx == 0 and dy == 1 then
                headDir = 'up'
            else
                headDir = 'right'
            end
        end

        -- Get tail direction
        local tailDir = headDir
        if #snake.body > 2 then
            if snake.body[1].x ~= snake.body[#snake.body].x or snake.body[1].y ~= snake.body[#snake.body].y then
                local px, py
                for i=1, #snake.body do
                    px = snake.body[#snake.body + 1 - i].x
                    py = snake.body[#snake.body + 1 - i].y
                    if px ~= snake.body[#snake.body].x or py ~= snake.body[#snake.body].y then
                        break
                    end
                end
                local dx = px - snake.body[#snake.body].x
                local dy = py - snake.body[#snake.body].y
                if dy > 1 then dy = -1 end
                if dy < -1 then dy = 1 end
                if dx > 1 then dx = -1 end
                if dx < -1 then dx = 1 end
                if dx == -1 and dy == 0 then
                    tailDir = 'left'
                elseif dx == 0 and dy == -1 then
                    tailDir = 'down'
                elseif dx == 0 and dy == 1 then
                    tailDir = 'up'
                else
                    tailDir = 'right'
                end
            end
        end

        -- Head
        local headRot = 0
        local headScaleX = self.cellWidth / snakeHeads[snake.headSrc]:getWidth()
        local headScaleY = self.cellHeight / snakeHeads[snake.headSrc]:getHeight()
        if headDir == 'up' then
            headRot = math.rad(270)
            local tmp = headScaleY
            headScaleY = headScaleX
            headScaleX = tmp
        elseif headDir == 'down' then
            headRot = math.rad(90)
            local tmp = headScaleY
            headScaleY = headScaleX
            headScaleX = tmp
        elseif headDir == 'left' then
            headScaleX = -headScaleX
        end
        love.graphics.setColor(1, 1, 1, sa)
        love.graphics.draw(
            headImg,
            1 + (snake.body[1].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) + ( self.cellWidth / 2 ),
            1 + ((self.numTilesY - 1 - snake.body[1].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2) + ( self.cellHeight / 2 ),
            headRot,
            headScaleX,
            headScaleY,
            headImg:getWidth() / 2,
            headImg:getHeight() / 2
        )
        love.graphics.setColor(1, 1, 1, 1)

        -- Body
        -- Only render if nth body position is not equal to last body position
        for i=2, #snake.body - 1 do
            if not (snake.body[#snake.body].x == snake.body[i].x and snake.body[#snake.body].y == snake.body[i].y) then
                if config.appearance.fadeOutTails and snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                    sa = ( ( ( ( #snake.body - i ) * 150 ) / #snake.body ) + 105 ) / 255
                end
                love.graphics.setColor(sr, sg, sb, sa)

                --Locate the previous and next body position
                local px = snake.body[i-1].x - snake.body[i].x
                local py = snake.body[i-1].y - snake.body[i].y
                local ax = snake.body[i].x - snake.body[i+1].x
                local ay = snake.body[i].y - snake.body[i+1].y
                if py > 1 then py = -1 end
                if py < -1 then py = 1 end
                if px > 1 then px = -1 end
                if px < -1 then px = 1 end
                if ay > 1 then ay = -1 end
                if ay < -1 then ay = 1 end
                if ax > 1 then ax = -1 end
                if ax < -1 then ax = 1 end

                if (px == ax and py == ay) or (px + ax == 0) or (py + ay == 0) or (not config.appearance.curveOnTurns) then
                    -- Draw a rectangle if the snake body is straight
                    love.graphics.rectangle(
                        "fill",
                        1 + (snake.body[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
                        1 + ((self.numTilesY - 1 - snake.body[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
                        self.cellWidth,
                        self.cellHeight
                    )
                else
                    -- Draw a circle if the snake is turning.
                    -- We position the circle such that the correct arc appears within the current cell.
                    local centerx, centery

                    if (py < 0 and ax < 0) or (ay > 0 and px > 0) then
                        centerx = 1 + (snake.body[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) + self.cellWidth
                        centery = 1 + ((self.numTilesY - 1 - snake.body[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2)  + self.cellHeight
                    elseif (py > 0 and ax > 0) or (ay < 0 and px < 0) then
                        centerx = 1 + (snake.body[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) 
                        centery = 1 + ((self.numTilesY - 1 - snake.body[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2)  
                    elseif (py < 0 and ax > 0) or (ay > 0 and px < 0) then
                        centerx = 1 + (snake.body[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) 
                        centery = 1 + ((self.numTilesY - 1 - snake.body[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2)  + self.cellHeight
                    elseif (py > 0 and ax < 0)  or (ay < 0 and px > 0) then
                        centerx = 1 + (snake.body[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) + self.cellWidth
                        centery = 1 + ((self.numTilesY - 1 - snake.body[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2)
                    end

                    -- Clip the circle drawing to the current cell, so that only the arc will be drawn
                    love.graphics.setScissor(
                        1 + (snake.body[i].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2),
                        1 + ((self.numTilesY - 1 - snake.body[i].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2),
                        self.cellWidth+1,
                        self.cellHeight+1    
                    )
                    love.graphics.ellipse(
                        "fill",
                        centerx,
                        centery,
                        self.cellWidth,
                        self.cellHeight,
                        50
                    )
                    love.graphics.setScissor()
                end

                love.graphics.setColor(1, 1, 1, 1)
            end
        end

        -- Tail
        -- Only render if first body position is not equal to last body position
        local tailRot = 0
        local tailScaleX = self.cellWidth / snakeTails[snake.tailSrc]:getWidth()
        local tailScaleY = self.cellHeight / snakeTails[snake.tailSrc]:getHeight()
        if tailDir == 'up' then
            tailRot = math.rad(90)
            local tmp = tailScaleY
            tailScaleY = -tailScaleX
            tailScaleX = tmp
        elseif tailDir == 'down' then
            tailRot = math.rad(270)
            local tmp = tailScaleY
            tailScaleY = -tailScaleX
            tailScaleX = tmp
        elseif tailDir == 'right' then
            tailScaleX = -tailScaleX
        end
        if not (snake.body[#snake.body].x == snake.body[1].x and snake.body[#snake.body].y == snake.body[1].y) then
            if config.appearance.fadeOutTails and snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                sa = 105 / 255
            end
            love.graphics.setColor(1, 1, 1, sa)
            love.graphics.draw(
                tailImg,
                1 + (snake.body[#snake.body].x * self.tileWidth) + ((self.tileWidth - self.cellWidth) / 2) + ( self.cellWidth / 2 ),
                1 + ((self.numTilesY - 1 - snake.body[#snake.body].y) * self.tileHeight) + ((self.tileHeight - self.cellHeight) / 2) + ( self.cellHeight / 2 ),
                tailRot,
                tailScaleX,
                tailScaleY,
                tailImg:getWidth() / 2,
                tailImg:getHeight() / 2
            )
            love.graphics.setColor(1, 1, 1, 1)
        end

    end

end

-- Computes the size of the components that make up the game board.
-- This is run once when we init the board, and again whenever the
-- game window is resized.
function Board:resize(windowWidth, windowHeight)

    -- Size of the game board
    self.boardWidth = windowWidth
    self.boardHeight = windowHeight

    -- Compute the width and height of each tile
    self.tileWidth = self.boardWidth / self.numTilesX
    self.tileHeight = self.boardHeight / self.numTilesY

    -- The "cell" is the part of each tile that we will actually draw
    -- the rest of the tile is reserved to allow the background to show through
    self.cellWidth = self.tileWidth - self.outlineSize
    self.cellHeight = self.tileHeight - self.outlineSize

    -- Set up vignette, if enabled
    if config.appearance.enableVignette then
        -- in the future we could also enable other moonshine effects here, i.e. filmgrain
        self.bgVignette = moonshine( self.boardWidth, self.boardHeight, moonshine.effects.vignette )
        self.bgVignette.vignette.radius = config.appearance.vignetteRadius
        self.bgVignette.vignette.opacity = config.appearance.vignetteOpacity
        self.bgVignette.vignette.softness = config.appearance.vignetteSoftness
        local vr, vg, vb = unpack(config.appearance.vignetteColor)
        vr = vr * 255
        vg = vg * 255
        vb = vb * 255
        self.bgVignette.vignette.color = {vr, vg, vb}
    end

    -- Create canvases for the bloom filter, if enabled
    if config.appearance.enableBloom then
        self.bloom = love.graphics.newCanvas( self.boardWidth/4, self.boardHeight/4 )
        self.hblur = love.graphics.newCanvas( self.boardWidth/4, self.boardHeight/4 )
        self.vblur = love.graphics.newCanvas( self.boardWidth/4, self.boardHeight/4 )
        self.bloomscene = love.graphics.newCanvas( self.boardWidth, self.boardHeight )
        self.scene = love.graphics.newCanvas( self.boardWidth, self.boardHeight )
    end
end

return Board
