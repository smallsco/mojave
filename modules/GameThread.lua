local GameThread = {}
GameThread.__index = GameThread
setmetatable( GameThread, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

GameThread.DEFAULT_STATE = {
    id = "",
    food = {},
    hazards = {},
    snakes = {},
    turn = 0,
    width = 0,
    height = 0
}
GameThread.RULES_STANDARD = 1
GameThread.RULES_ROYALE = 2
GameThread.RULES_SQUADS = 3
GameThread.RULES_CONSTRICTOR = 4

-- Constructor
function GameThread.new(opt)
    local self = setmetatable( {}, GameThread )
    opt = opt or {}

    -- Set up communication channels to the main thread
    self.channel = love.thread.getChannel("game")
    self.cmdChannel = love.thread.getChannel("commands")
    self.humanChannel = love.thread.getChannel("human")

    -- Table to hold robosnake coroutines
    -- We can't put these in snake b/c they can't be passed between threads
    self.coroutines = {}

    -- Set some default snake properties that aren't rule-based
    local numSnakes = 0
    for _, snake in pairs(opt.snakes) do
        snake.body = {}
        snake.eliminatedCause = Snake.ELIMINATION_CAUSES.NotEliminated
        snake.eliminatedBy = ""
        snake.age = 0
        snake.kills = 0
        snake.latency = 0
        snake.shout = ""
        snake.squad = opt.squad_map[snake.id]
        snake.request = ""
        snake.response = ""
        numSnakes = numSnakes + 1

        if snake.type == Snake.TYPES.ROBOSNAKE then
            self.coroutines[snake.id] = coroutine.create(RobosnakeMkIII.move)
        end
    end

    -- Select rules to be used for this match
    local rules_options = {
        squad_map = opt.squad_map,
        food_spawn_chance = config.gameplay.foodSpawnChance,
        minimum_food = config.gameplay.minimumFood,
        max_health = config.gameplay.maxHealth,
        start_size = config.gameplay.startSize,
        shrink_every_n_turns = config.royale.shrinkEveryNTurns,
        damage_per_turn = config.royale.damagePerTurn,
        allow_body_collisions = config.squads.allowBodyCollisions,
        shared_elimination = config.squads.sharedElimination,
        shared_health = config.squads.sharedHealth,
        shared_length = config.squads.sharedLength
    }
    if opt.rules == GameThread.RULES_STANDARD then
        if numSnakes <= 1 then
            self.ruleset = "solo"
            self.rules = SoloRules(rules_options)
        else
            self.ruleset = "standard"
            self.rules = StandardRules(rules_options)
        end
    elseif opt.rules == GameThread.RULES_ROYALE then
        self.ruleset = "royale"
        self.rules = RoyaleRules(rules_options)
    elseif opt.rules == GameThread.RULES_SQUADS then
        self.ruleset = "squads"
        self.rules = SquadRules(rules_options)
    elseif opt.rules == GameThread.RULES_CONSTRICTOR then
        self.ruleset = "constrictor"
        self.rules = ConstrictorRules(rules_options)
    end

    -- Create turn 0 (initial board state)
    -- Note: Lua arrays start at 1, so turn 0 is at index 1, turn 1 is at index 2, etc.
    self.state = self.rules:createInitialBoardState(opt.width, opt.height, opt.snakes)
    self.state.id = Utils.generateUUID()

    -- Query each snake for the game start
    for _, snake in pairs(self.state.snakes) do
        local latency = self:requestStart(snake)
        snake.latency = latency
    end

    -- Send starting state back to main thread
    self.channel:supply(self.state)

    return self
end

-- Construct the JSON for an end request to a 2018 API snake
function GameThread:buildOldEndJson()
    local end_json = {}

    end_json.game_id = self.state.id
    end_json.winners = {}
    end_json.dead_snakes = {
        data = {}
    }
    for _, snake in pairs(self.state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            table.insert(end_json.winners, snake.id)
        else
            table.insert(end_json.dead_snakes.data, {
                id=snake.id,
                length=#snake.body,
                death={
                    turn=snake.age,
                    causes={snake.eliminatedCause}
                }
            })
        end
    end

    return json.encode(end_json)
end

-- Construct the JSON for a start request to a 2017 or 2018 API snake
function GameThread:buildOldStartJson()
    return json.encode({
        width = self.state.width,
        height = self.state.height,
        game_id = self.state.id
    })
end

-- Construct the JSON for a move request to a 2017 API snake
function GameThread:buildMoveJson2017(snake)
    local move_json = {}

    move_json.you = snake.id
    move_json.width = self.state.width
    move_json.turn = self.state.turn
    move_json.snakes = {}
    move_json.dead_snakes = {}
    move_json.height = self.state.height
    move_json.game_id = self.state.id
    move_json.food = {}

    for _, food in ipairs(self.state.food) do
        table.insert(move_json.food, {food.x, food.y})
    end
    for _, other_snake in pairs(self.state.snakes) do
        local snake_json = {
            taunt=other_snake.shout,
            name=other_snake.name,
            id=other_snake.id,
            health_points=other_snake.health,
            coords={}
        }
        for i=1, #other_snake.body do
            table.insert(snake_json.coords, {other_snake.body[i].x, other_snake.body[i].y})
        end
        if other_snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            table.insert(move_json.snakes, snake_json)
        else
            table.insert(move_json.dead_snakes, snake_json)
        end
    end

    return json.encode(move_json)
end

-- Construct the JSON for a move request to a 2018 API snake
function GameThread:buildMoveJson2018(snake)
    local move_json = {}

    move_json.food = {
        data = self.state.food
    }
    move_json.height = self.state.height
    move_json.id = self.state.id
    move_json.turn = self.state.turn
    move_json.width = self.state.width
    move_json.snakes = {
        data = {}
    }
    for _, other_snake in pairs(self.state.snakes) do
        local snake_json = {
            id=other_snake.id,
            name=other_snake.name,
            length=#other_snake.body,
            body={
                data=other_snake.body
            },
            health=other_snake.health,
            taunt=other_snake.shout
        }
        if other_snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            table.insert(move_json.snakes.data, snake_json)
        end
    end

    move_json.you = {
        id=snake.id,
        name=snake.name,
        length=#snake.body,
        body={
            data=snake.body
        },
        health=snake.health,
        taunt=snake.shout
    }

    return json.encode(move_json)
end

-- Construct the JSON for a move request to a modern API snake
function GameThread:buildMoveJson(snake)
    local move_json = {}

    move_json.game = {
        id=self.state.id,
        ruleset={
            name=self.ruleset,
            version=string.format("Mojave/%s", Utils.MOJAVE_VERSION)
        },
        timeout=config.gameplay.responseTime
    }

    move_json.turn = self.state.turn

    move_json.board = {
        width=self.state.width,
        height=self.state.height,
        snakes={},
        food=self.state.food,
        hazards=self.state.hazards
    }
    for _, other_snake in pairs(self.state.snakes) do
        local snake_json = {
            id=other_snake.id,
            name=other_snake.name,
            length=#other_snake.body,
            head=other_snake.body[1],
            body=other_snake.body,
            health=other_snake.health,
            shout=other_snake.shout,
            latency=tostring(other_snake.latency)
        }
        if self.ruleset == "squads" then
            snake_json.squad = tostring(other_snake.squad)
        end
        if other_snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            table.insert(move_json.board.snakes, snake_json)
        end
    end

    move_json.you = {
        id=snake.id,
        name=snake.name,
        length=#snake.body,
        head=snake.body[1],
        body=snake.body,
        health=snake.health,
        shout=snake.shout,
        latency=tostring(snake.latency)
    }
    if self.ruleset == "squads" then
        move_json.you.squad = tostring(snake.squad)
    end

    return json.encode(move_json)
end

-- Mechanism to handle arbitrary commands sent by the main thread.
-- Currently, only handles graceful exits.
function GameThread:handleCommand()
    local cmd = self.cmdChannel:pop()
    if cmd == 'exit' then
        return true
    end
    return false
end

-- Make HTTP requests to snakes for the end of the game
function GameThread:requestEnds()
    local apisnakes = {}
    local robosnakes = {}
    local requests = {}

    for _, snake in pairs(self.state.snakes) do
        if snake.type == Snake.TYPES.API or (snake.type == Snake.TYPES.API_OLD and snake.apiversion == 2018) then
            table.insert(apisnakes, snake)
        elseif snake.type == Snake.TYPES.ROBOSNAKE then
            table.insert(robosnakes, snake)
        end
    end

    for _, snake in ipairs(apisnakes) do
        local request_json
        if snake.type == Snake.TYPES.API then
            request_json = self:buildMoveJson(snake)
        elseif snake.type == Snake.TYPES.API_OLD then
            request_json = self:buildOldEndJson()
        end
        table.insert(requests, {
            id = snake.id,
            url = snake.url .. '/end',
            postbody = request_json
        })
    end

    Utils.http_request_multi(requests)
end

-- Make a HTTP request to a snake for the start of the game
function GameThread:requestStart(snake)
    if snake.type == Snake.TYPES.API or snake.type == Snake.TYPES.API_OLD then
        local request_json
        if snake.type == Snake.TYPES.API then
            request_json = self:buildMoveJson(snake)
        elseif snake.type == Snake.TYPES.API_OLD then
            request_json = self:buildOldStartJson()
        end
        snake.request = request_json

        local resp, latency, err = Utils.http_request(snake.url .. '/start', request_json)
        if snake.apiversion == 0 or snake.type == Snake.TYPES.API_OLD then
            snake.color = {
                love.math.random(0, 255) / 255,
                love.math.random(0, 255) / 255,
                love.math.random(0, 255) / 255,
                1
            }
            snake.headSrc = "default"
            snake.tailSrc = "default"
            if not resp then
                snake.response = ""
                return latency
            end
            local data = json.decode(resp)
            if not data then
                snake.response = ""
                return latency
            end

            if data.color and data.color ~= '' then
                if Utils.HTML_COLORS[string.lower(data.color)] then
                    snake.color = Utils.HTML_COLORS[string.lower(data.color)]
                else
                    snake.color = data.color
                end
            end

            snake.headSrc = data.headType or data.head_type or "default"
            snake.tailSrc = data.tailType or data.tail_type or "default"
            if not snakeHeads[snake.headSrc] then
                snake.headSrc = "default"
            end
            if not snakeTails[snake.tailSrc] then
                snake.tailSrc = "default"
            end
        end

        if not resp then
            snake.response = ""
        else
            snake.response = resp
        end

        return latency
    else
        return 0
    end
end

-- Make requests to all snakes to collect their next move
function GameThread:requestMoves()
    local shouts = {}
    local moves = {}
    local latencies = {}
    local apisnakes = {}
    local robosnakes = {}
    local humans = {}
    local requests = {}

    -- Split snakes into api/robo/human
    for _, snake in pairs(self.state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if snake.type == Snake.TYPES.API or snake.type == Snake.TYPES.API_OLD then
                table.insert(apisnakes, snake)
            elseif snake.type == Snake.TYPES.ROBOSNAKE then
                table.insert(robosnakes, snake)
            elseif snake.type == Snake.TYPES.HUMAN then
                table.insert(humans, snake)
            end
        else
            snake.request = ""
            snake.response = ""
        end
    end

    -- For API snakes we first the move JSON for the appropriate API version
    for _, snake in ipairs(apisnakes) do
        local move_json
        if snake.apiversion == 2017 then
            move_json = self:buildMoveJson2017(snake)
        elseif snake.apiversion == 2018 then
            move_json = self:buildMoveJson2018(snake)
        else
            move_json = self:buildMoveJson(snake)
        end
        table.insert(requests, {
            id = snake.id,
            url = snake.url .. '/move',
            postbody = move_json
        })
        snake.request = move_json
    end

    -- For API snakes, once we have the move JSON, we fire off an HTTP request to the snake server and grab
    -- the response from the server.
    local responses = Utils.http_request_multi(requests)
    for id, response in pairs(responses) do
        latencies[id] = response.latency
        if not response.response then
            moves[id] = "default"
            shouts[id] = ""
            self.state.snakes[id].response = ""
        else
            self.state.snakes[id].response = response.response
            local data = json.decode(response.response)
            if not data then
                moves[id] = "default"
                shouts[id] = ""
            else
                local move = data.move
                if not move then
                    moves[id] = "default"
                    shouts[id] = ""
                else
                    -- The Y axis is inverted for all API versions prior to API V1, so those snakes will see a flipped
                    -- version of the board and move accordingly. So we need to invert their response if they make a
                    -- move along the Y axis.
                    if self.state.snakes[id].apiversion == 0 or self.state.snakes[id].type == Snake.TYPES.API_OLD then
                        if move == "down" then
                            move = "up"
                        elseif move == "up" then
                            move = "down"
                        end
                    end

                    moves[id] = move
                    shouts[id] = data.shout or ""
                end
            end
        end
    end

    -- For Robosnakes, the Lua code runs inside a coroutine that loops forever and yields after
    -- generating a response. When we want to request a move, we resume the coroutine and pass in
    -- the JSON (actually, not JSON, we use the real data structure) which then yields again when the
    -- response is generated.
    for _, snake in ipairs(robosnakes) do
        snake.request = self:buildMoveJson(snake)
        local start_time = love.timer.getTime()
        local ok, response = coroutine.resume(self.coroutines[snake.id], json.decode(snake.request))
        local end_time = love.timer.getTime()
        if not ok then
            error('robosnake: ' .. response)
        end
        local move = response.move
        if move == "down" then
            move = "up"
        elseif move == "up" then
            move = "down"
        end
        snake.response = move
        moves[snake.id] = move
        latencies[snake.id] = end_time - start_time
    end

    -- For Humans, when the user presses an arrow key, we put that event into a dedicated channel
    -- that the game thread listens on. The thread blocks for humanResponseTime ms and if there is
    -- no event in the channel after that time has elapsed, we return the default move. Otherwise
    -- we grab the event from the channel and use it as the move.
    for _, snake in ipairs(humans) do
        local start_time = love.timer.getTime()
        local move = self.humanChannel:demand(config.gameplay.humanResponseTime / 1000)
        local end_time = love.timer.getTime()
        if move then
            moves[snake.id] = move
            snake.response = move
            latencies[snake.id] = end_time - start_time
        else
            moves[snake.id] = "default"
            snake.response = ""
            latencies[snake.id] = 0
        end
    end

    return moves, shouts, latencies
end

-- Plays a new turn of the game
function GameThread:tick()

    -- Check for game over
    if self.rules:isGameOver(self.state) then
        self:requestEnds()
        self.cmdChannel:push('exit')
        return
    end

    -- Get moves for each (living) snake
    local moves, shouts, latencies = self:requestMoves()

    -- Generate the next board state
    local new_state = self.rules:createNextBoardState(self.state, moves)
    for id, snake in pairs(new_state.snakes) do
        snake.latency = latencies[id]
        snake.shout = shouts[id]
        snake.age = snake.age + 1

        -- Track kills here - it should be done in rules but I want to keep
        -- the rules as close to official battlesnake as possible :)
        if snake.eliminatedBy ~= "" and self.state.snakes[id].eliminatedBy == "" then
            new_state.snakes[snake.eliminatedBy].kills = new_state.snakes[snake.eliminatedBy].kills + 1
        end

    end
    self.state = new_state
    self.state.turn = self.state.turn + 1

    -- Send it to the main thread
    self.channel:push(new_state)
end

return GameThread
