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
    
    -- Starting direction
    self.direction = opt.direction or love.math.random(4)
    
    -- Starting length
    self.length = opt.length or 1
    
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

function Snake:api( endpoint, data )

    -- FIXME? In the real battle snake game, requests must complete in 1s.
    -- But that's not realistic if you're running 5 or more snake servers
    -- on your development laptop, where they can't respond as fast as they
    -- would when running in the cloud. So we don't enforce that limit here.

    log.debug(string.format('snake "%s" api call to "%s" endpoint', self.name, endpoint))
    log.trace('POST data: ' .. data)
    if self.url == '' then
        log.debug(string.format('snake "%s" is human controlled, ignoring api call', self.name))
        return
    else
        local request_url = self.url .. '/' .. endpoint
        log.trace('Request URL: ' .. request_url)
        local response_body = {}
        local res, code, response_headers, status = http.request({
            url = request_url,
            method = "POST",
            headers =
            {
              ["Content-Type"] = "application/json",
              ["Content-Length"] = data:len()
            },
            source = ltn12.source.string(data),
            sink = ltn12.sink.table(response_body)
        })
        log.trace('Response Code: ' .. code)
        
        -- if the server responded
        if status then
            log.trace('Response Status: ' .. status)
            log.trace('Response Body: ' .. table.concat(response_body))
            local response_data = json.decode(table.concat(response_body))
            if response_data then
                if response_data['move'] ~= nil then
                    log.trace('move to ' .. response_data['move'])
                    self:setDirection(response_data['move'])
                end
                if response_data['taunt'] ~= nil then
                    self:setTaunt(response_data['taunt'])
                end
            end
        else
            log.debug(string.format('snake "%s" no response from api call', self.name))
        end
        
    end

end

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

function Snake:clearHistory()
    self.history = {}
end

function Snake:decrementHealth()
    self.health = self.health - 1
end

function Snake:incrAge()
    self.age = self.age + 1
end

function Snake:incrGold()
    if PLAY_AUDIO then
        SFXSnakeGold:stop()
        SFXSnakeGold:play()
    end
    self.gold = self.gold + 1
end

function Snake:getAge()
    return self.age
end

function Snake:getGold()
    return self.gold
end

function Snake:getHealth()
    return self.health
end

function Snake:getHistory()
    return self.history
end

function Snake:getId()
    return self.id
end

function Snake:getKills()
    return self.kills
end

function Snake:getLength()
    return self.length
end

function Snake:getName()
    return self.name
end

function Snake:getPosition()
    return self.x, self.y
end

function Snake:getNextPosition()
    return self.next_x, self.next_y
end

function Snake:getTaunt()
    return self.taunt
end

function Snake:getURL()
    return self.url
end

function Snake:setTaunt( taunt )
    self.taunt = taunt
end

function Snake:isAlive()
    return self.status == 'alive'
end

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

function Snake:die()
    if PLAY_AUDIO then
        SFXSnakeDeath:stop()
        SFXSnakeDeath:play()
    end
    self.status = 'dead'
end

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

function Snake:grow()
    self.length = self.length + 1
end

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


return Snake