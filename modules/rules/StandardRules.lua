local StandardRules = {}
StandardRules.__index = StandardRules
setmetatable( StandardRules, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function StandardRules.new( opt )
    local self = setmetatable( {}, StandardRules )
    opt = opt or {}

    self.FoodSpawnChance = opt.food_spawn_chance or 15
    self.MinimumFood = opt.minimum_food or 1
    self.SnakeMaxHealth = opt.max_health or 100
    self.SnakeStartSize = opt.start_size or 3

    return self
end

function StandardRules:createInitialBoardState(width, height, snakes)
    local state = Utils.deepcopy(GameThread.DEFAULT_STATE)
    state.height = height
    state.width = width

    -- Set defaults for snakes
    state.snakes = snakes
    for _, snake in pairs(state.snakes) do
        snake.health = self.SnakeMaxHealth
    end

    -- Place snakes
    self:placeSnakes(state)

    -- Place food
    self:placeFood(state)

    return state
end

function StandardRules:placeSnakes(state)
    if self:isKnownBoardSize(state) then
        self:placeSnakesFixed(state)
    else
        self:placeSnakesRandomly(state)
    end
end

function StandardRules:placeSnakesFixed(state)
    -- Create eight start points
    local mn, md, mx = 1, (state.width - 1)/2, state.width - 2
    local start_points = {
        {x = mn, y = mn},
        {x = mn, y = md},
        {x = mn, y = mx},
        {x = md, y = mn},
        {x = md, y = mx},
        {x = mx, y = mn},
        {x = mx, y = md},
        {x = mx, y = mx},
    }

    -- Sanity check
    local numSnakes = 0
    for _, _ in pairs(state.snakes) do
        numSnakes = numSnakes + 1
    end
    if numSnakes > #start_points then
        local err = 'Sorry, a maximum of %s snakes are supported for this board configuration.'
        error(string.format(err, #start_points), 0)
    end

    -- Randomly order them
    Utils.shuffle(start_points)

    -- Assign to snakes in order given
    local i = 1
    for _, snake in pairs(state.snakes) do
        for j=1, self.SnakeStartSize do
            table.insert(snake.body, start_points[i])
        end
        i = i + 1
    end
end

function StandardRules:placeSnakesRandomly(state)
    local i = 1
    for _, snake in pairs(state.snakes) do

        local unoccupiedPoints = self:getEvenUnoccupiedPoints(state)
        if #unoccupiedPoints <= 0 then
            error("Sorry, there is not enough room on the board to place snakes.")
        end

        local point = unoccupiedPoints[love.math.random(#unoccupiedPoints)]

        for j=1, self.SnakeStartSize do
            table.insert(snake.body, point)
        end
        i = i + 1
    end
end

function StandardRules:placeFood(state)
    if self:isKnownBoardSize(state) then
        self:placeFoodFixed(state)
    else
        self:placeFoodRandomly(state)
    end
end

function StandardRules:placeFoodFixed(state)
    -- Place 1 food within exactly 2 moves of each snake
    for _, snake in pairs(state.snakes) do
        local snakeHead = snake.body[1]
        local possibleFoodLocations = {
            {x=snakeHead.x - 1, y=snakeHead.y - 1},
            {x=snakeHead.x - 1, y=snakeHead.y + 1},
            {x=snakeHead.x + 1, y=snakeHead.y - 1},
            {x=snakeHead.x + 1, y=snakeHead.y + 1},
        }
        local availableFoodLocations = {}

        for i, point in ipairs(possibleFoodLocations) do
            local isOccupiedAlready = false
            for _, food in ipairs(state.food) do
                if food.x == point.x and food.y == point.y then
                    isOccupiedAlready = true
                    break
                end
            end
            if not isOccupiedAlready then
                table.insert(availableFoodLocations, point)
            end
        end

        if #availableFoodLocations <= 0 then
            error("Sorry, there is not enough room on the board to place food.")
        end

        local placedFood = availableFoodLocations[love.math.random(#availableFoodLocations)]
        table.insert(state.food, placedFood)
    end

    -- Finally, always place 1 food in center of board for dramatic purposes
    local isCenterOccupied = true
    local centerCoord = {x=(state.width - 1)/2, y=(state.height - 1)/2}
    local unoccupiedPoints = self:getUnoccupiedPoints(state, true)
    for _, point in ipairs(unoccupiedPoints) do
        if point.x == centerCoord.x and point.y == centerCoord.y then
            isCenterOccupied = false
            break
        end
    end
    if isCenterOccupied then
        error("Sorry, there is not enough room on the board to place food.")
    end
    table.insert(state.food, centerCoord)
end

function StandardRules:placeFoodRandomly(state)
    local numSnakes = 0
    for _, _ in pairs(state.snakes) do
        numSnakes = numSnakes + 1
    end
    self:spawnFood(state, numSnakes)
end

function StandardRules:isKnownBoardSize(state)
    if state.width == 7 and state.height == 7 then
        return true
    elseif state.width == 11 and state.height == 11 then
        return true
    elseif state.width == 19 and state.height == 19 then
        return true
    end
    return false
end

function StandardRules:createNextBoardState(prevState, moves)
    local nextState = Utils.deepcopy(prevState)
    self:moveSnakes(nextState, moves)
    self:reduceSnakeHealth(nextState)
    self:maybeFeedSnakes(nextState)
    self:maybeSpawnFood(nextState)
    self:maybeEliminateSnakes(nextState)
    return nextState
end

function StandardRules:moveSnakes(state, moves)
    -- Sanity check that all non-eliminated snakes have moves and bodies.
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if #snake.body == 0 then
                error(string.format("Snake '%s' has a body length of 0", snake.name))
            end
            local move = moves[snake.id]
            if not move then
                error(string.format("Snake '%s' does not have a move", snake.name))
            end
        end
    end

    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            local move = moves[snake.id]
            local newHead = {}
            if move == "down" then
                newHead.x = snake.body[1].x
                newHead.y = snake.body[1].y - 1
            elseif move == "left" then
                newHead.x = snake.body[1].x - 1
                newHead.y = snake['body'][1].y
            elseif move == "right" then
                newHead.x = snake.body[1].x + 1
                newHead.y = snake.body[1].y
            elseif move == "up" then
                newHead.x = snake.body[1].x
                newHead.y = snake.body[1].y + 1
            else
                -- Default to up
                local dx = 0
                local dy = 1

                -- If neck is available, use neck to determine last direction
                if #snake.body >= 2 then
                    dx = snake.body[1].x - snake.body[2].x
                    dy = snake.body[1].y - snake.body[2].y
                    if dx == 0 and dy == 0 then
                        dy = 1  -- Move up if no last move was made
                    end
                end

                -- Apply
                newHead.x = snake.body[1].x + dx
                newHead.y = snake.body[1].y + dy
            end

            -- Append new head, pop old tail
            table.insert(snake.body, 1, newHead)
            table.remove(snake.body)
        end
    end
end

function StandardRules:reduceSnakeHealth(state)
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            snake.health = snake.health - 1
        end
    end
end

function StandardRules:maybeEliminateSnakes(state)
    -- First order snake indices by length.
    -- In multi-collision scenarios we want to always attribute elimination to the longest snake.
    local snakeIDsByLength = {}
    for id, _ in pairs(state.snakes) do
        table.insert(snakeIDsByLength, id)
    end
    table.sort(snakeIDsByLength, function(i, j)
        local len_i = #state.snakes[i].body
        local len_j = #state.snakes[j].body
        return len_i > len_j
    end)

    -- Iterate over all non-eliminated snakes and eliminate the ones
    -- that are out of health or have moved out of bounds.
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if #snake.body <= 0 then
                error(string.format("Snake '%s' has a body length of 0", snake.name))
            end
            if self:snakeIsOutOfHealth(snake) then
                snake.eliminatedCause = Snake.ELIMINATION_CAUSES.EliminatedByOutOfHealth
            elseif self:snakeIsOutOfBounds(snake, state.width, state.height) then
                snake.eliminatedCause = Snake.ELIMINATION_CAUSES.EliminatedByOutOfBounds
            end
        end
    end

    -- Next, look for any collisions. Note we apply collision eliminations
    -- after this check so that snakes can collide with each other and be properly eliminated.
    local collisionEliminations = {}
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if #snake.body <= 0 then
                error(string.format("Snake '%s' has a body length of 0", snake.name))
            end

            -- Check for self-collisions first
            if self:snakeHasBodyCollided(snake, snake) then
                table.insert(collisionEliminations, {
                    id = snake.id,
                    cause = Snake.ELIMINATION_CAUSES.EliminatedBySelfCollision,
                    by = snake.id
                })

                -- I'm so, so sorry.
                -- Lua doesn't have a continue statment, so the options here were:
                -- 1) Refactor the function to not require continue, making it appear quite different than the official
                --    rules do, or
                -- 2) Use a goto statement to simulate a continue, but keep the look of the function as close as
                --    possible to the original.
                goto continue_collisionEliminations
            end

            -- Check for body collisions with other snakes second
            local hasBodyCollided = false
            for i=1, #snakeIDsByLength do
                local other = state.snakes[snakeIDsByLength[i]]
                if other.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                    if snake.id ~= other.id and self:snakeHasBodyCollided(snake, other) then
                        table.insert(collisionEliminations, {
                            id = snake.id,
                            cause = Snake.ELIMINATION_CAUSES.EliminatedByCollision,
                            by = other.id
                        })
                        hasBodyCollided = true
                        break
                    end
                end
            end
            if hasBodyCollided then

                -- Will you forgive me?
                goto continue_collisionEliminations
            end

            -- Check for head-to-heads last
            local hasHeadCollided = false
            for i=1, #snakeIDsByLength do
                local other = state.snakes[snakeIDsByLength[i]]
                if other.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                    if snake.id ~= other.id and self:snakeHasLostHeadToHead(snake, other) then
                        table.insert(collisionEliminations, {
                            id = snake.id,
                            cause = Snake.ELIMINATION_CAUSES.EliminatedByHeadToHeadCollision,
                            by = other.id
                        })
                        hasHeadCollided = true
                        break
                    end
                end
            end
            if hasHeadCollided then

                -- Pretty please?
                goto continue_collisionEliminations
            end

        end
        ::continue_collisionEliminations::
    end

    -- Apply collision elimimations
    for _, elimination in ipairs(collisionEliminations) do
        for id, snake in pairs(state.snakes) do
            if id == elimination.id then
                snake.eliminatedCause = elimination.cause
                snake.eliminatedBy = elimination.by
            end
        end
    end

end

function StandardRules:snakeIsOutOfHealth(snake)
    return snake.health <= 0
end

function StandardRules:snakeIsOutOfBounds(snake, width, height)
    for _, point in ipairs(snake.body) do
        if point.x < 0 or point.x >= width then
            return true
        end
        if point.y < 0 or point.y >= height then
            return true
        end
    end
    return false
end

function StandardRules:snakeHasBodyCollided(snake, other)
    local head = snake.body[1]
    for i=2, #other.body do
        if head.x == other.body[i].x and head.y == other.body[i].y then
            return true
        end
    end
    return false
end

function StandardRules:snakeHasLostHeadToHead(snake, other)
    if snake.body[1].x == other.body[1].x and snake.body[1].y == other.body[1].y then
        return #snake.body <= #other.body
    end
    return false
end

function StandardRules:maybeFeedSnakes(state)
    local newFood = {}
    for _, food in ipairs(state.food) do
        local foodHasBeenEaten = false
        for _, snake in pairs(state.snakes) do
            if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated and #snake.body ~= 0 then
                if snake.body[1].x == food.x and snake.body[1].y == food.y then
                    self:feedSnake(snake)
                    foodHasBeenEaten = true
                end
            end
        end
        if not foodHasBeenEaten then
            table.insert(newFood, food)
        end
    end

    state.food = newFood
end

function StandardRules:feedSnake(snake)
    self:growSnake(snake)
    snake.health = self.SnakeMaxHealth
end

function StandardRules:growSnake(snake)
    if #snake.body > 0 then
        table.insert(snake.body, snake.body[#snake.body])
    end
end

function StandardRules:maybeSpawnFood(state)
    local numCurrentFood = #state.food
    if numCurrentFood < self.MinimumFood then
        self:spawnFood(state, self.MinimumFood - numCurrentFood)
    elseif self.FoodSpawnChance > 0 and love.math.random(100) < self.FoodSpawnChance then
        self:spawnFood(state, 1)
    end
end

function StandardRules:spawnFood(state, num)
    for i = 1, num do
        local unoccupiedPoints = self:getUnoccupiedPoints(state, false)
        if #unoccupiedPoints > 0 then
            local newFood = unoccupiedPoints[love.math.random(#unoccupiedPoints)]
            table.insert(state.food, newFood)
        end
    end
end

function StandardRules:getUnoccupiedPoints(state, includePossibleMoves)
    -- N.B. Recall that Lua indexes tables starting at 1, so we need to add
    -- 1 to the values for pointIsOccupied.

    -- Create an empty grid
    local pointIsOccupied = {}
    for x = 1, state.width do
        pointIsOccupied[x] = {}
        for y = 1, state.height do
            pointIsOccupied[x][y] = false
        end
    end

    -- add food
    for _, food in ipairs(state.food) do
        pointIsOccupied[food.x + 1][food.y + 1] = true
    end

    -- add snakes
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            for i, body_point in ipairs(snake.body) do

                -- There's a crash that can occur here because adding food takes place in between moving snakes
                -- and eliminating them. So if a snake is out-of-bounds but not yet eliminated, that body part
                -- will fall outside the bounds of the pointIsOccupied table. To work around this, double-check
                -- that all body parts fall within the bounds of the game board, and skip over any that do not.
                --
                -- It doesn't seem like the official rules check for this? But the game works, so maybe it's just
                -- something I don't understand about go array syntax  *shrug*
                if body_point.x >= 0 and body_point.y >= 0 and body_point.x < state.width and body_point.y < state.height then

                    pointIsOccupied[body_point.x + 1][body_point.y + 1] = true
                    if i == 1 and not includePossibleMoves then
                        local nextMovePoints = {
                            {x = body_point.x - 1, y = body_point.y},
                            {x = body_point.x + 1, y = body_point.y},
                            {x = body_point.x, y = body_point.y - 1},
                            {x = body_point.x, y = body_point.y + 1}
                        }
                        for _, next_point in ipairs(nextMovePoints) do
                            if next_point.x > 0 and next_point.x < state.width then
                                if next_point.y > 0 and next_point.y < state.height then
                                    pointIsOccupied[next_point.x + 1][next_point.y + 1] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- generate unoccupied points table
    local unoccupiedPoints = {}
    for x = 1, state.width do
        for y = 1, state.height do
            if not pointIsOccupied[x][y] then
                table.insert(unoccupiedPoints, {x=x-1, y=y-1})
            end
        end
    end

    return unoccupiedPoints
end

function StandardRules:getEvenUnoccupiedPoints(state)

    -- Start by getting unoccupied points
    local unoccupiedPoints = self:getUnoccupiedPoints(state, true)

    -- Create a new array to hold points that are even
    local evenUnoccupiedPoints = {}

    for _, point in ipairs(unoccupiedPoints) do
        if (point.x + point.y) % 2 == 0 then
            table.insert(evenUnoccupiedPoints, point)
        end
    end
    return evenUnoccupiedPoints

end

function StandardRules:isGameOver(state)
    local numSnakesRemaining = 0
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            numSnakesRemaining = numSnakesRemaining + 1
        end
    end
    return numSnakesRemaining <= 1
end

return StandardRules
