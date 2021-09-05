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
    self.HazardDamagePerTurn = opt.hazard_damage_per_turn or 14

    return self
end

function StandardRules:modifyInitialBoardState(initialState)
    return initialState
end

function StandardRules:createNextBoardState(prevState, moves)
    local nextState = BoardState.clone(prevState)
    self:moveSnakes(nextState, moves)
    self:reduceSnakeHealth(nextState)
    self:maybeDamageHazards(nextState)
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
                    if dy > 1 then dy = -1 end
                    if dy < -1 then dy = 1 end
                    if dx > 1 then dx = -1 end
                    if dx < -1 then dx = 1 end
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

function StandardRules:maybeDamageHazards(state)
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            local head = snake.body[1]
            for _, p in ipairs(state.hazards) do
                if head.x == p.x and head.y == p.y then

                    -- If there's a food in this square, don't reduce health
                    local foundFood = false
                    for _, food in ipairs(state.food) do
                        if food.x == p.x and food.y == p.y then
                            foundFood = true
                        end
                    end

                    -- Snake is in a hazard, reduce health
                    if not foundFood then
                        snake.health = snake.health - self.HazardDamagePerTurn
                        if snake.health < 0 then
                            snake.health = 0
                        end
                        if self:snakeIsOutOfHealth(snake) then
                            snake.eliminatedCause = Snake.ELIMINATION_CAUSES.EliminatedByOutOfHealth
                        end
                    end

                end
            end
        end
    end
end

function StandardRules:maybeEliminateSnakes(state)
    -- First order snake indices by length.
    -- In multi-collision scenarios we want to always attribute elimination to the longest snake.
    local snakeIDsByLength = {}
    for _, snake in pairs(state.snakes) do
        table.insert(snakeIDsByLength, snake.id)
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
        for _, snake in pairs(state.snakes) do
            if snake.id == elimination.id then
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
    snake.health = BoardState.SnakeMaxHealth
end

function StandardRules:growSnake(snake)
    if #snake.body > 0 then
        table.insert(snake.body, snake.body[#snake.body])
    end
end

function StandardRules:maybeSpawnFood(state)
    local numCurrentFood = #state.food
    if numCurrentFood < self.MinimumFood then
        BoardState.placeFoodRandomly(state, self.MinimumFood - numCurrentFood)
    elseif self.FoodSpawnChance > 0 and love.math.random(100) < self.FoodSpawnChance then
        BoardState.placeFoodRandomly(state, 1)
    end
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
