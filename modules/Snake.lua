local Snake = {}
Snake.__index = Snake
setmetatable( Snake, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-- Constants
Snake.DIRECTION_NORTH = 1
Snake.DIRECTION_EAST = 2
Snake.DIRECTION_SOUTH = 3
Snake.DIRECTION_WEST = 4


--- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Snake
function Snake.new( opt )
    
    local self = setmetatable( {}, Snake )
    local opt = opt or {}
    
    -- Snake name and API endpoint
    self.id = opt.id or ''
    self.name = opt.name or 'snake'
    self.url = opt.url or ''
    self.taunt = opt.taunt or 'No one can stop me. -Justin Bieber'
    
    -- Starting position
    self.x = opt.x or 1
    self.y = opt.y or 1
    self.next_x = 1
    self.next_y = 1
    
    -- Default body color
    self.color = { 255, 0, 0, 255 }
    
    -- Starting direction
    self.direction = opt.direction or love.math.random(4)
    
    -- Starting length
    self.length = opt.length or 1
    
    -- Default head image
    self.head = nil
    
    -- Starting health
    self.health = 100
    
    -- Starting gold
    self.gold = 0
    
    -- Starting score
    self.score = 0
    
    -- Starting age
    self.age = 0
    
    -- Starting kills
    self.kills = 0
    
    -- History of movement
    self.history = {{self.x, self.y}}
    self.status = 'alive'
    
    return self
    
end

--- Executes a HTTP request to the BattleSnake server
--- (remember, the arena is a *client*, and the snakes are *servers*
--- contrary to what you might expect!)
-- @param endpoint The snake server's HTTP API endpoint
-- @param data The data to send to the endpoint
function Snake:api( endpoint, data )

    --[[
        FIXME? In the real battle snake game, requests must complete in 1s.
        But that's not realistic if you're running 5 or more snake servers
        on your development laptop, where they can't respond as fast as they
        would when running in the cloud. So we don't enforce that limit here.
    ]]

    if endpoint == '' then
        log.debug(string.format('snake "%s" api call to info endpoint', self.name))
    else
        log.debug(string.format('snake "%s" api call to "%s" endpoint', self.name, endpoint))
    end
    
    if self.url == '' then
        log.debug(string.format('snake "%s" is human controlled, ignoring api call', self.name))
        return
    else
    
        local request_url = self.url .. '/' .. endpoint
        log.trace('Request URL: ' .. request_url)
        
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
        local host = parsed['host']
        if parsed['port'] then host = host .. ':' .. parsed['port'] end
        
        local response_body = {}
        local res, code, response_headers, status
        if endpoint == '' then
            res, code, response_headers, status = http.request({
                url = request_url,
                method = "GET",
                headers =
                {
                  ["Content-Type"] = "application/json",
                  ["Host"] = host
                },
                sink = ltn12.sink.table(response_body)
            })
        else
            log.trace('POST data: ' .. data)
            res, code, response_headers, status = http.request({
                url = request_url,
                method = "POST",
                headers =
                {
                  ["Content-Type"] = "application/json",
                  ["Content-Length"] = data:len(),
                  ["Host"] = host
                },
                source = ltn12.source.string(data),
                sink = ltn12.sink.table(response_body)
            })
        end
        
        -- if the server responded
        if status then
            log.trace('Response Code: ' .. code)
            log.trace('Response Status: ' .. status)
            log.trace('Response Body: ' .. table.concat(response_body))
            local response_data = json.decode(table.concat(response_body))
            if response_data then
                if response_data['move'] ~= nil then
                    log.trace(string.format('move: %s', response_data['move']))
                    self:setDirection(response_data['move'])
                end
                if response_data['taunt'] ~= nil then
                    log.trace(string.format('taunt: %s', response_data['taunt']))
                    self:setTaunt(response_data['taunt'])
                end
                if response_data['head'] ~= nil then
                    log.trace(string.format('head: %s', response_data['head']))
                    self:setHead( response_data['head'] )
                end
                if response_data['color'] ~= nil then
                    log.trace(string.format('color: %s', response_data['color']))
                    self:setColor( response_data['color'], true )
                end
            end
        else
            log.debug(string.format('snake "%s" no response from api call', self.name))
        end
        
    end

end

--- Given the snake's direction, figure out the next tile on the game board
--- where that snake will be moving to.
function Snake:calculateNextPosition()

    if self.direction == Snake.DIRECTION_NORTH then
        self.next_x = self.x
        self.next_y = self.y - 1
    elseif self.direction == Snake.DIRECTION_EAST then
        self.next_x = self.x + 1
        self.next_y = self.y
    elseif self.direction == Snake.DIRECTION_SOUTH then
        self.next_x = self.x
        self.next_y = self.y + 1
    elseif self.direction == Snake.DIRECTION_WEST then
        self.next_x = self.x - 1
        self.next_y = self.y
    end
    log.debug( string.format( 'snake "%s" wants to move to (%s,%s)', self.name, self.next_x, self.next_y ) )

end

--- Clear the snake's history (called when the snake dies)
function Snake:clearHistory()
    self.history = {}
end

--- Decrements the snake's health by one
function Snake:decrementHealth()
    self.health = self.health - 1
end

--- Called when this snake is killed
function Snake:die()
    if PLAY_AUDIO then
        SFXSnakeDeath:stop()
        SFXSnakeDeath:play()
    end
    self.status = 'dead'
end

--- Called when this snake passes over a food tile
function Snake:eatFood()

    if PLAY_AUDIO then
        SFXSnakeFood:stop()
        SFXSnakeFood:play()
    end

    -- Restore HP
    self.health = self.health + 30
    if self.health >= 100 then
        self.health = 100
    end
    
    -- Grow
    self:grow()
    
    -- TODO: Increase score
    
end

--- Increments the snake's age by one
function Snake:incrAge()
    self.age = self.age + 1
end

--- Increments the snake's gold by one
function Snake:incrGold()
    if PLAY_AUDIO then
        SFXSnakeGold:stop()
        SFXSnakeGold:play()
    end
    self.gold = self.gold + 1
end

--- Getter function for the snake's age
-- @return The snake's age
function Snake:getAge()
    return self.age
end

--- Getter function for the snake's color
-- @return The snake's color as an RGBA table
function Snake:getColor()
    return self.color
end

--- Getter function for the snake's gold
-- @return The snake's gold
function Snake:getGold()
    return self.gold
end

--- Getter function for the snake's head image
-- @return The snake's head image
function Snake:getHead()
    return self.head
end

--- Getter function for the snake's head image scale factor
-- @return The X scale factor
-- @return The Y scale factor
function Snake:getHeadScaleFactor()
    local xScale = 20 / self.head:getWidth()
    local yScale = 20 / self.head:getHeight()
    return xScale, yScale
end

--- Getter function for the snake's health
-- @return The snake's health
function Snake:getHealth()
    return self.health
end

--- Getter function for the snake's history
-- @return The snake's history
function Snake:getHistory()
    return self.history
end

--- Getter function for the snake's id
-- @return The snake's id
function Snake:getId()
    return self.id
end

--- Getter function for the snake's kills
-- @return The snake's kills
function Snake:getKills()
    return self.kills
end

--- Getter function for the snake's length
-- @return The snake's length
function Snake:getLength()
    return self.length
end

--- Getter function for the snake's name
-- @return The snake's name
function Snake:getName()
    return self.name
end

--- Getter function for the snake's current position
-- @return The x and y coordinates of the snake's head
function Snake:getPosition()
    return self.x, self.y
end

--- Getter function for the snake's next position
-- @return The x and y coordinates of the snake's next planned move
function Snake:getNextPosition()
    return self.next_x, self.next_y
end

--- Getter function for the snake's current taunt
-- @return The snake's current taunt
function Snake:getTaunt()
    return self.taunt
end

--- Getter function for the snake's API endpoint
-- @return The snake's API endpoint URL
function Snake:getURL()
    return self.url
end

--- Increments this snake's length by one
function Snake:grow()
    self.length = self.length + 1
end

--- Helper function to get the snake's living status
-- @return true if the snake is alive, otherwise false
function Snake:isAlive()
    return self.status == 'alive'
end

--- Called when this snake kills another snake
-- @param othersnake The dead snake's instance (used to get its' length)
function Snake:kill(othersnake)
    -- If Snake A runs into Snake B's tail...
    -- Snake A dies
    -- Snake B is credited with a kill
    -- Snake B's life is reset to 100
    -- Snake B's length is increased by 50% of snake A's length (rounded down)    
    self.kills = self.kills + 1
    self.health = 100
    self.length = self.length + math.floor(othersnake:getLength() / 2)
end

--- Moves this snake on the game board from its' current position
--- to its' next position
-- @return The tile which its' tail is vacating (if it didn't eat this turn)
function Snake:moveNextPosition()

    local trimTail = false
    if #self.history >= self.length then
        trimTail = true
    end

    self.x = self.next_x
    self.y = self.next_y
    table.insert(self.history, 1, {self.x, self.y})
    if trimTail then
        return table.remove(self.history)
    else
        return nil
    end
end

--- Sets the snake's body color
-- @param value The new color to set the snake's body to
-- @param fromWeb Boolean that indicates whether value is RGB or hex formatted
function Snake:setColor( value, fromWeb )

    if not fromWeb then
        -- assume value is a table containing R, G, and B
        self.color = value
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
    if value == 'north' then
        self.direction = Snake.DIRECTION_NORTH
    elseif value == 'west' then
        self.direction = Snake.DIRECTION_WEST
    elseif value == 'south' then
        self.direction = Snake.DIRECTION_SOUTH
    elseif value == 'east' then
        self.direction = Snake.DIRECTION_EAST
    end
    log.debug( string.format( 'snake "%s" direction changed to %s', self.name, value ) )
end

-- Setter function for the snake's head image
function Snake:setHead( url )
    
    log.debug(string.format('snake "%s" set head from url', self.name))
    
    if not url or url == '' then
        log.debug(string.format('snake "%s" head url is empty', self.name))
        return
    else
    
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
        local host = parsed['host']
        if parsed['port'] then host = host .. ':' .. parsed['port'] end
    
        log.trace('Request URL: ' .. url)
        local response_body = {}
        local res, code, response_headers, status = http.request({
            url = url,
            method = "GET",
            headers =
            {
              ["Host"] = host
            },
            sink = ltn12.sink.table(response_body)
        })
        
        -- if the server responded
        if status then
            log.trace('Response Code: ' .. code)
            log.trace('Response Status: ' .. status)
            local response_data = table.concat(response_body)
            if response_data then
                local filedata = love.filesystem.newFileData( response_data, 'head' )
                local imagedata = love.image.newImageData( filedata )
                self.head = love.graphics.newImage( imagedata )
                log.trace(self.head)
                
            end
        else
            log.debug(string.format('snake "%s" no response from head url call', self.name))
        end
        
    end
    
end

--- Setter function for the snake's taunt
-- @param taunt The new taunt
function Snake:setTaunt( taunt )
    self.taunt = taunt
end

return Snake