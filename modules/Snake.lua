local Snake = {}
Snake.__index = Snake
setmetatable( Snake, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

Snake.MAX_SUPPORTED_API_VERSION = 1

Snake.TYPES = {
    API = 1,
    API_OLD = 2,
    ROBOSNAKE = 3,
    HUMAN = 4
}

Snake.ELIMINATION_CAUSES = {
    NotEliminated = "",
    EliminatedByCollision = "snake-collision",
    EliminatedBySelfCollision = "snake-self-collision",
    EliminatedByOutOfHealth = "out-of-health",
    EliminatedByHeadToHeadCollision = "head-collision",
    EliminatedByOutOfBounds = "wall-collision",
    EliminatedBySquad = "squad-eliminated"
}

-- Updates the snakes.json file with the current state of snakes in the app.
function Snake.saveJson()
    local snake_fields_for_json = {}
    for _, snake in pairs(snakes) do
        snake_fields_for_json[snake.id] = snake:get_fields_for_json()
    end
    local json_snakes = json.encode(snake_fields_for_json)
    local ok, err = love.filesystem.write( 'snakes.json', json_snakes )
    if not ok then
        error( string.format( 'Unable to write snakes.json: %s', err ) )
    end
end

-- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Snake
function Snake.new(opt)
    local self = setmetatable( {}, Snake )
    opt = opt or {}

    if type(opt.type) ~= 'number' then
        error( 'Unsupported snake type' )
    elseif opt.type < 1 or opt.type > 4 then
        error( 'Unsupported snake type' )
    end

    self.id = Utils.generateUUID()
    self.type = opt.type
    self.name = opt.name
    self.url = opt.url or ""
    self.headSrc = opt.headSrc or ""
    self.tailSrc = opt.tailSrc or ""
    self.color = opt.color or ""
    self.apiversion = tonumber(opt.apiversion) or -1

    return self
end

-- Removes this snake from the app.
function Snake:delete()
    snakes[self.id] = nil
    Snake.saveJson()
end

-- Gets a table with fields that we want to save to snakes.json
-- @return table
function Snake:get_fields_for_json()
    return {
        id = self.id,
        type = self.type,
        name = self.name,
        url = self.url,
        headSrc = self.headSrc,
        tailSrc = self.tailSrc,
        color = self.color,
        apiversion = self.apiversion
    }
end

-- Refreshes this snake's head, tail, and color from the API.
function Snake:refresh()
    local warn

    -- Only do this if the modern Battlesnake API is used.
    -- Older APIs configured on the /start request
    if self.type == Snake.TYPES.API then

        -- Try the root endpoint, throw an error if there was an HTTP error
        local resp, latency, err = Utils.http_request(self.url)
        if not resp then
            return false, err
        end
        local data = json.decode(resp)

        -- If we got a response, but it was not JSON (or it was JSON but there was no API version),
        -- then check to see if there is a working /ping endpoint. If so, this is an API V0 snake.
        -- If not, throw an error because this isn't a snake at all.
        if (not data) or (not data.apiversion) then
            local presp, platency, perr = Utils.http_request(self.url .. '/ping')
            if not presp then
                return false, perr
            end
            self.apiversion = 0
        end

        -- If the api version is not 0, then grab their head/tail/color
        if self.apiversion ~= 0 then
            if (not data.color) or (data.color == '') then
                self.color = {
                    love.math.random(0, 255) / 255,
                    love.math.random(0, 255) / 255,
                    love.math.random(0, 255) / 255,
                    1
                }
            else
                self.color = data.color
            end
            if snakeHeads[data.head] then
                self.headSrc = data.head
            else
                self.headSrc = "default"
            end
            if snakeTails[data.tail] then
                self.tailSrc = data.tail
            else
                self.tailSrc = "default"
            end
            self.apiversion = tonumber(data.apiversion)
        end

        -- Pop a warning message if the snake uses a newer API version than what we currently support
        if self.apiversion > Snake.MAX_SUPPORTED_API_VERSION then
            warn = string.format(
                "This snake uses a newer API version (V%s) than what this version of Mojave supports (V%s).\n",
                self.apiversion,
                Snake.MAX_SUPPORTED_API_VERSION
            )
            warn = warn .. "You may proceed, but if the API is not backwards-compatible, then things may break."
        end
    end

    -- Update snakes.json with the newly added snake.
    snakes[self.id] = self
    Snake.saveJson()
    return true, warn
end

return Snake
