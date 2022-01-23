local StandardRules = {}
StandardRules.__index = StandardRules
setmetatable( StandardRules, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local format = string.format
local insert = table.insert
local sort = table.sort

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
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if #snake.body == 0 then
                error(format("Snake '%s' has a body length of 0", snake.name))
            end
            local move = moves[snake.id]
            if not move then
                error(format("Snake '%s' does not have a move", snake.name))
            end
        end
    end

    for i=1, #state.snakes do
        local snake = state.snakes[i]
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            local appliedMove = moves[snake.id]
            if appliedMove ~= "up" and appliedMove ~= "down" and appliedMove ~= "left" and appliedMove ~= "right" then
                appliedMove = self:getDefaultMove(snake.body)
            end

            local newHead = {}
            -- Guaranteed to be one of these options given the clause above
            if appliedMove == "up" then
                newHead.x = snake.body[1].x
                newHead.y = snake.body[1].y + 1
            elseif appliedMove == "down" then
                newHead.x = snake.body[1].x
                newHead.y = snake.body[1].y - 1
            elseif appliedMove == "left" then
                newHead.x = snake.body[1].x - 1
                newHead.y = snake.body[1].y
            elseif appliedMove == "right" then
                newHead.x = snake.body[1].x + 1
                newHead.y = snake.body[1].y
            end

            -- Append new head, pop old tail
            insert(snake.body, 1, newHead)
            snake.body[#snake.body] = nil
        end
    end
end

function StandardRules:getDefaultMove(snakeBody)
    if #snakeBody >= 2 then
        -- Use neck to determine last move made
        local head = snakeBody[1]
        local neck = snakeBody[2]

        -- Situations where neck is next to head
        if head.x == neck.x + 1 then
            return "right"
        elseif head.x == neck.x - 1 then
            return "left"
        elseif head.y == neck.y + 1 then
            return "up"
        elseif head.y == neck.y - 1 then
            return "down"
        end

        -- Consider the wrapped case using zero azis to anchor
        if head.x == 0 and neck.x > 0 then
            return "right"
        elseif neck.x == 0 and head.x > 0 then
            return "left"
        elseif head.y == 0 and neck.y > 0 then
            return "up"
        elseif neck.y == 0 and head.y > 0 then
            return "down"
        end
    end
    return "up"
end

function StandardRules:reduceSnakeHealth(state)
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            snake.health = snake.health - 1
        end
    end
end

function StandardRules:maybeDamageHazards(state)
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            local head = snake.body[1]
            for j=1, #state.hazards do
                if head.x == state.hazards[j].x and head.y == state.hazards[j].y then

                    -- If there's a food in this square, don't reduce health
                    local foundFood = false
                    for k=1, #state.food do
                        if state.food[k].x == state.hazards[j].x and state.food[k].y == state.hazards[j].y then
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
    local snakesByLength = {}
    for i=1, #state.snakes do
        insert(snakesByLength, state.snakes[i])
    end
    sort(snakesByLength, function(i, j)
        return #i.body > #j.body
    end)

    -- Iterate over all non-eliminated snakes and eliminate the ones
    -- that are out of health or have moved out of bounds.
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if #snake.body <= 0 then
                error(format("Snake '%s' has a body length of 0", snake.name))
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
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            if #snake.body <= 0 then
                error(format("Snake '%s' has a body length of 0", snake.name))
            end

            -- Check for self-collisions first
            if self:snakeHasBodyCollided(snake, snake) then
                collisionEliminations[#collisionEliminations + 1] = {
                    id = snake.id,
                    cause = Snake.ELIMINATION_CAUSES.EliminatedBySelfCollision,
                    by = snake.id
                }

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
            for j=1, #snakesByLength do
                local other = snakesByLength[j]
                if other.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                    if snake.id ~= other.id and self:snakeHasBodyCollided(snake, other) then
                        collisionEliminations[#collisionEliminations + 1] = {
                            id = snake.id,
                            cause = Snake.ELIMINATION_CAUSES.EliminatedByCollision,
                            by = other.id
                        }
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
            for j=1, #snakesByLength do
                local other = snakesByLength[j]
                if other.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                    if snake.id ~= other.id and self:snakeHasLostHeadToHead(snake, other) then
                        collisionEliminations[#collisionEliminations + 1] = {
                            id = snake.id,
                            cause = Snake.ELIMINATION_CAUSES.EliminatedByHeadToHeadCollision,
                            by = other.id
                        }
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
    for i=1, #collisionEliminations do
        for j=1, #state.snakes do
            local snake = state.snakes[j]
            if snake.id == collisionEliminations[i].id then
                snake.eliminatedCause = collisionEliminations[i].cause
                snake.eliminatedBy = collisionEliminations[i].by
            end
        end
    end

end

function StandardRules:snakeIsOutOfHealth(snake)
    return snake.health <= 0
end

function StandardRules:snakeIsOutOfBounds(snake, width, height)
    for i=1, #snake.body do
        if snake.body[i].x < 0 or snake.body[i].x >= width then
            return true
        end
        if snake.body[i].y < 0 or snake.body[i].y >= height then
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
    for i=1, #state.food do
        local foodHasBeenEaten = false
        for j=1, #state.snakes do
            local snake = state.snakes[j]
            if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated and #snake.body ~= 0 then
                if snake.body[1].x == state.food[i].x and snake.body[1].y == state.food[i].y then
                    self:feedSnake(snake)
                    foodHasBeenEaten = true
                end
            end
        end
        if not foodHasBeenEaten then
            newFood[#newFood + 1] = state.food[i]
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
        snake.body[#snake.body + 1] = snake.body[#snake.body]
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
    for i=1, #state.snakes do
        if state.snakes[i].eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            numSnakesRemaining = numSnakesRemaining + 1
        end
    end
    return numSnakesRemaining <= 1
end

return StandardRules
