local Snake = {}
Snake.__index = Snake
setmetatable( Snake, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-- Constants
Snake.DIRECTION_NORTH = 'up'
Snake.DIRECTION_EAST = 'right'
Snake.DIRECTION_SOUTH = 'down'
Snake.DIRECTION_WEST = 'left'
Snake.DIRECTIONS = {
    Snake.DIRECTION_NORTH,
    Snake.DIRECTION_EAST,
    Snake.DIRECTION_SOUTH,
    Snake.DIRECTION_WEST
}


local SFXSnakeFood = love.audio.newSource( 'audio/sfx/PowerUp5.mp3', 'static' )
local SFXSnakeGold = love.audio.newSource( 'audio/sfx/Bells6.mp3', 'static' )
local SFXSnakeDeath = love.audio.newSource( 'audio/sfx/PowerDown1.mp3', 'static' )


--- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Snake
function Snake.new( opt, slot, game_id )
    
    local self = setmetatable( {}, Snake )
    local opt = opt or {}
    
    -- Snake name and API endpoint
    self.type = opt.type
    self.url = opt.url or ''
    if self.type == 2 then
        -- HUMAN
        self.id = Util.generateUUID()
        self.name = 'Human Player'
    elseif self.type == 3 then
        -- 2017 API
        self.id = Util.generateUUID()
        self.name = self.url
    elseif self.type == 4 then
        -- 2016 API
        self.id = opt.id
        self.name = opt.name
    elseif self.type == 5 then
        -- ROBOSNAKE
        self.id = Util.generateUUID()
        self.name = 'Redbrick Robosnake'
    elseif self.type == 6 then
        -- 2018 API
        self.id = Util.generateUUID()
        self.name = opt.name
    end
    self.taunt = opt.taunt or ''
    
    self.real_x = 0
    self.real_y = 0
    self.next_x = 0
    self.next_y = 0
    self.direction = self.DIRECTIONS[love.math.random(4)]
    self.position = {}
    self.slot = slot
    self.avatar = snakeHeads[slot]
    self.head = snakeHeads[slot]
    self.tail = snakeTails[slot]
    self.health = 100
    self.gold = 0
    self.age = 0
    self.kills = 0
    self.eating = false
    self.alive = true
    self.delayed_death = false
    self.color = { love.math.random(0, 255), love.math.random(0, 255), love.math.random(0, 255) }
    self.thread = false
    
    if self.type == 2 then
        -- human player, no initialization required
    elseif self.type == 3 or self.type == 6 then
        -- 2017/2018 API
        self:api( 'start', json.encode({
            game_id = game_id,
            height = config[ 'gameplay' ][ 'boardHeight' ],
            width = config[ 'gameplay' ][ 'boardWidth' ]
        }))
    elseif self.type == 4 then
        -- 2016 API
        self:api( '' )  -- root endpoint, get color and head url
    elseif self.type == 5 then
        -- ROBOSNAKE
        self.thread = coroutine.create( Robosnake.move )
        self.avatar = love.graphics.newImage( 'robosnake/robosnake-crop.jpg' )
        self.color = { 150, 0, 0 }
        self.head = snakeHeads[1]
        self.tail = snakeTails[7]
        self.taunt = Robosnake.util.bieberQuote()
    else
        error( 'Unsupported snake type' )
    end
    
    return self
    
end

--- Executes a HTTP request to the BattleSnake server
--- (remember, the game board is a *client*, and the snakes are *servers*
--- contrary to what you might expect!)
-- @param endpoint The snake server's HTTP API endpoint
-- @param data The data to send to the endpoint
function Snake:api( endpoint, data )

    local request_url = self.url .. '/' .. endpoint
    gameLog( string.format( 'Request URL: %s', request_url ), 'debug' )
    gameLog( string.format( 'POST body: %s', data ), 'debug' )
    
    --[[
        The version of LuaSocket bundled with LÖVE has a bug
        where the http port will not get added to the Host header,
        which is a violation of the HTTP spec. Most web servers don't
        care - however - this breaks Flask, which interprets the
        spec very strictly and is also used by a lot of snakes.
        
        We can work around this by manually parsing the URL,
        generating a Host header, and explicitly setting it on the request.
        
        See https://github.com/diegonehab/luasocket/pull/74 for more info.
    ]]
    local parsed = socket.url.parse( request_url )
    local host = parsed[ 'host' ]
    if parsed[ 'port' ] then host = host .. ':' .. parsed[ 'port' ] end

    -- make the request
    local response_body = {}
    local res, code, response_headers, status
    if endpoint == '' then
        res, code, response_headers, status = http.request({
            url = request_url,
            method = "GET",
            headers =
            {
              [ "Content-Type" ] = "application/json",
              [ "Host" ] = host
            },
            sink = ltn12.sink.table( response_body )
        })
    else
        res, code, response_headers, status = http.request({
            url = request_url,
            method = "POST",
            headers =
            {
              [ "Content-Type" ] = "application/json",
              [ "Content-Length" ] = data:len(),
              [ "Host" ] = host
            },
            source = ltn12.source.string( data ),
            sink = ltn12.sink.table( response_body )
        })
    end
    
    -- handle the response
    if status then
        gameLog( string.format( 'Response Code: %s', code ), 'debug' )
        gameLog( string.format( 'Response Status: %s', status ), 'debug' )
        gameLog( string.format( 'Response body: %s', table.concat( response_body ) ), 'debug' )
        local response_data = json.decode( table.concat( response_body ) )
        if response_data then
            if response_data[ 'name' ] ~= nil then
                if self.type == 3 then
                    self.name = response_data[ 'name' ]
                end
            end
            if response_data[ 'move' ] ~= nil then
                self:setDirection( response_data[ 'move' ] )
            end
            if response_data[ 'taunt' ] ~= nil then
                if response_data[ 'taunt' ] ~= self.taunt then
                    self.taunt = response_data[ 'taunt' ]
                    if config[ 'gameplay' ][ 'enableTaunts' ] then
                        gameLog( string.format( '%s says: %s', self.name, self.taunt ) )
                    end
                end
            end
            if response_data[ 'color' ] ~= nil then
                self:setColor( response_data[ 'color' ], true )
            end
            
            if response_data[ 'head_type' ] ~= nil then
                if response_data[ 'head_type' ] == 'bendr' then
                    self.head = snakeHeads[1]
                elseif response_data[ 'head_type' ] == 'dead' then
                    self.head = snakeHeads[2]
                elseif response_data[ 'head_type' ] == 'fang' then
                    self.head = snakeHeads[3]
                elseif response_data[ 'head_type' ] == 'pixel' then
                    self.head = snakeHeads[4]
                elseif response_data[ 'head_type' ] == 'regular' then
                    self.head = snakeHeads[5]
                elseif response_data[ 'head_type' ] == 'safe' then
                    self.head = snakeHeads[6]
                elseif response_data[ 'head_type' ] == 'sand-worm' then
                    self.head = snakeHeads[7]
                elseif response_data[ 'head_type' ] == 'shades' then
                    self.head = snakeHeads[8]
                elseif response_data[ 'head_type' ] == 'smile' then
                    self.head = snakeHeads[9]
                elseif response_data[ 'head_type' ] == 'tongue' then
                    self.head = snakeHeads[10]
                end
            end
            
            if response_data[ 'tail_type' ] ~= nil then
                if response_data[ 'tail_type' ] == 'small-rattle' then
                    self.tail = snakeTails[1]
                elseif response_data[ 'tail_type' ] == 'skinny-tail' then
                    self.tail = snakeTails[2]
                elseif response_data[ 'tail_type' ] == 'round-bum' then
                    self.tail = snakeTails[3]
                elseif response_data[ 'tail_type' ] == 'regular' then
                    self.tail = snakeTails[4]
                elseif response_data[ 'tail_type' ] == 'pixel' then
                    self.tail = snakeTails[5]
                elseif response_data[ 'tail_type' ] == 'freckled' then
                    self.tail = snakeTails[6]
                elseif response_data[ 'tail_type' ] == 'fat-rattle' then
                    self.tail = snakeTails[7]
                elseif response_data[ 'tail_type' ] == 'curled' then
                    self.tail = snakeTails[8]
                elseif response_data[ 'tail_type' ] == 'block-bum' then
                    self.tail = snakeTails[9]
                end
            end
            
            if response_data[ 'head_url' ] ~= nil then
                self:setAvatar( response_data[ 'head_url' ] )
            elseif response_data[ 'head' ] ~= nil then
                self:setAvatar( response_data[ 'head' ] )
            end
        end
    else
        -- no response from api call in allowed time
        gameLog( string.format( '%s: No response from API call in allowed time', self.name ), 'error' )
        
        -- choose a random move for the snake if a move request timed out
        if endpoint == 'move' and self.type ~= 4 then
            self.direction = self.DIRECTIONS[love.math.random(4)]
            gameLog( string.format( '"%s" direction changed to "%s"', self.name, self.direction ), 'debug' )
        end
    end
end

--- Given the snake's direction, figure out the next tile on the game board
--- where that snake will be moving to.
function Snake:calculateNextPosition()
    if self.direction == Snake.DIRECTION_NORTH then
        self.next_x = self.position[1][1]
        self.next_y = self.position[1][2] - 1
    elseif self.direction == Snake.DIRECTION_EAST then
        self.next_x = self.position[1][1] + 1
        self.next_y = self.position[1][2]
    elseif self.direction == Snake.DIRECTION_SOUTH then
        self.next_x = self.position[1][1]
        self.next_y = self.position[1][2] + 1
    elseif self.direction == Snake.DIRECTION_WEST then
        self.next_x = self.position[1][1] - 1
        self.next_y = self.position[1][2]
    end
end

--- Called when this snake is killed
function Snake:die()
    if self.alive == true and self.delayed_death == false then
        if config[ 'audio' ][ 'enableSFX' ] then
            SFXSnakeDeath:stop()
            SFXSnakeDeath:play()
        end
        self.delayed_death = true
    end
end

--- Called when this snake passes over a food tile
function Snake:eat()
    if config[ 'audio' ][ 'enableSFX' ] then
        SFXSnakeFood:stop()
        SFXSnakeFood:play()
    end
    self.health = self.health + config[ 'gameplay' ][ 'foodHealth' ]
    if self.health > 100 then self.health = 100 end
    self.eating = true
end

--- Increments the snake's gold by one
function Snake:incrGold()
    if config[ 'audio' ][ 'enableSFX' ] then
        SFXSnakeGold:stop()
        SFXSnakeGold:play()
    end
    self.gold = self.gold + 1
end

-- Setter function for the snake's avatar image
function Snake:setAvatar( url )
    
    gameLog( string.format( 'Request URL: %s', url ), 'debug' )
    
    --[[
        The version of LuaSocket bundled with LÖVE has a bug
        where the http port will not get added to the Host header,
        which is a violation of the HTTP spec. Most web servers don't
        care - however - this breaks Flask, which interprets the
        spec very strictly and is also used by a lot of snakes.
        
        We can work around this by manually parsing the URL,
        generating a Host header, and explicitly setting it on the request.
        
        See https://github.com/diegonehab/luasocket/pull/74 for more info.
    ]]
    local parsed = socket.url.parse( url )
    local host = parsed[ 'host' ]
    if parsed[ 'port' ] then host = host .. ':' .. parsed[ 'port' ] end

    -- make the request
    local response_body = {}
    local res, code, response_headers, status
    res, code, response_headers, status = http.request({
        url = url,
        method = "GET",
        headers =
        {
          [ "Host" ] = host
        },
        sink = ltn12.sink.table( response_body )
    })
    
    -- handle the response
    if status then
        gameLog( string.format( 'Response Code: %s', code ), 'debug' )
        gameLog( string.format( 'Response Status: %s', status ), 'debug' )
        local response_data = table.concat( response_body )
        if response_data then
            local gif = gifload()
            gif.err = function( self, msg ) error(msg) end
            local ok, err = pcall(function()
                gif:update( response_data )
                gif:done()
                local imagedata, x, y, delay, disposal = gif:frame(1)
                self.avatar = love.graphics.newImage( imagedata )
            end)
            if not ok then
                local filedata = love.filesystem.newFileData( response_data, 'avatar' )
                local ok, err = pcall(function()
                    local imagedata = love.image.newImageData( filedata )
                    self.avatar = love.graphics.newImage( imagedata )
                end)
                if not ok then
                    gameLog( string.format( 'Error loading avatar for snake "%s": %s', self.name, err ), 'error' )
                    self.avatar = self.head
                end
            end
        end
    else
        -- no response from avatar url call in allowed time
        gameLog( string.format( '%s: No response from avatar URL call in allowed time', self.name ), 'error' )
        self.avatar = self.head
    end
    
end

--- Sets the snake's body color
-- @param value The new color to set the snake's body to
function Snake:setColor( value )

    if type( value ) == 'table' then
        -- assume value is a table containing R, G, and B
        self.color = value
    elseif Util.htmlColors[ string.lower( value ) ] then
        -- if we have a name, map it to the hex value
        self:setColor( Util.htmlColors[ string.lower( value ) ] )
    else
        -- convert the hex value to an RGB one
        -- @see https://gist.github.com/jasonbradley/4357406
        value = value:gsub( "#", "" )
        length = string.len( value )
        
        if length == 3 then
            self.color = {
                tonumber( "0x" .. value:sub( 1, 1 ) ) * 17,
                tonumber( "0x" .. value:sub( 2, 2 ) ) * 17,
                tonumber( "0x" .. value:sub( 3, 3 ) ) * 17,
                255
            }
        elseif length == 6 then
            self.color = {
                tonumber( "0x" .. value:sub( 1, 2 ) ),
                tonumber( "0x" .. value:sub( 3, 4 ) ),
                tonumber( "0x" .. value:sub( 5, 6 ) ),
                255
            }
        end
    end

end

--- Sets this snake's direction
-- @param value The direction to move the snake in
function Snake:setDirection( value )

    if value == 'up' or value == 'north' then
        self.direction = Snake.DIRECTION_NORTH
        gameLog( string.format( '"%s" direction changed to "%s"', self.name, Snake.DIRECTION_NORTH ), 'debug' )
    elseif value == 'left' or value == 'west' then
        self.direction = Snake.DIRECTION_WEST
        gameLog( string.format( '"%s" direction changed to "%s"', self.name, Snake.DIRECTION_WEST ), 'debug' )
    elseif value == 'down' or value == 'south' then
        self.direction = Snake.DIRECTION_SOUTH
        gameLog( string.format( '"%s" direction changed to "%s"', self.name, Snake.DIRECTION_SOUTH ), 'debug' )
    elseif value == 'right' or value == 'east' then
        self.direction = Snake.DIRECTION_EAST
        gameLog( string.format( '"%s" direction changed to "%s"', self.name, Snake.DIRECTION_EAST ), 'debug' )
    else
        gameLog( string.format( '"%s" got invalid direction "%s"', self.name, value ), 'error' )
    end
    
end

return Snake