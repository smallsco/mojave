local BoardState = {}

BoardState.SnakeMaxHealth = config.gameplay.maxHealth
BoardState.SnakeStartSize = config.gameplay.startSize

-- Generates an empty, but fully initialized board state
function BoardState.newBoardState(width, height)
    return {
        id = "",
        food = {},
        hazards = {},
        snakes = {},
        turn = 0,
        width = width,
        height = height
    }
end

-- Returns a deep copy of prevState that can be safely modified inside createNextBoardState
function BoardState.clone(prevState)
    return Utils.deepcopy(prevState)
end

-- Convenience function for fully initializing a "default" board state with snakes and food.
-- In a real game, the engine may generate the board without calling this
-- function, or customize the results based on game-specific settings.
function BoardState.createDefaultBoardState(width, height, snakes)
    local initialBoardState = BoardState.newBoardState(width, height)

    BoardState.placeSnakesAutomatically(initialBoardState, snakes)
    BoardState.placeFoodAutomatically(initialBoardState)

    return initialBoardState
end

-- Takes the provided table of snakes and places them on the game board.
function BoardState.placeSnakesAutomatically(state, snakes)
    if BoardState.isKnownBoardSize(state) then
        BoardState.placeSnakesFixed(state, snakes)
    else
        BoardState.placeSnakesRandomly(state, snakes)
    end
end

function BoardState.placeSnakesFixed(state, snakes)
    -- Add snakes to state
    state.snakes = Utils.deepcopy(snakes)
    for _, snake in pairs(state.snakes) do
        snake.health = BoardState.SnakeMaxHealth
    end

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
        for j=1, BoardState.SnakeStartSize do
            table.insert(snake.body, start_points[i])
        end
        i = i + 1
    end
end

function BoardState.placeSnakesRandomly(state, snakes)
    -- Add snakes to state
    state.snakes = Utils.deepcopy(snakes)
    for _, snake in pairs(state.snakes) do
        snake.health = BoardState.SnakeMaxHealth
    end

    local i = 1
    for _, snake in pairs(state.snakes) do

        local unoccupiedPoints = BoardState.getEvenUnoccupiedPoints(state)
        if #unoccupiedPoints <= 0 then
            error("Sorry, there is not enough room on the board to place snakes.")
        end

        local point = unoccupiedPoints[love.math.random(#unoccupiedPoints)]

        for j=1, BoardState.SnakeStartSize do
            table.insert(snake.body, point)
        end
        i = i + 1
    end
end

-- Adds a single snake to the board with the given body coordinates
function BoardState.placeSnake(state, snake, body)
    state.snakes[snake.id] = Utils.deepcopy(snake)
    state.snakes[snake.id].health = BoardState.SnakeMaxHealth
    state.snakes[snake.id].body = body
end

-- Initializes the array of food based on the size of the board and the number of snakes.
function BoardState.placeFoodAutomatically(state)
    if BoardState.isKnownBoardSize(state) then
        BoardState.placeFoodFixed(state)
    else
        local numSnakes = 0
        for _, _ in pairs(state.snakes) do
            numSnakes = numSnakes + 1
        end
        BoardState.placeFoodRandomly(state, numSnakes)
    end
end

function BoardState.placeFoodFixed(state)
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

        -- Select randomly from available locations
        local placedFood = availableFoodLocations[love.math.random(#availableFoodLocations)]
        table.insert(state.food, placedFood)
    end

    -- Finally, always place 1 food in center of board for dramatic purposes
    local isCenterOccupied = true
    local centerCoord = {x=(state.width - 1)/2, y=(state.height - 1)/2}
    local unoccupiedPoints = BoardState.getUnoccupiedPoints(state, true)
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

-- Adds up to num new food to the board in random unoccupied squares
function BoardState.placeFoodRandomly(state, num)
    for i = 1, num do
        local unoccupiedPoints = BoardState.getUnoccupiedPoints(state, false)
        if #unoccupiedPoints > 0 then
            local newFood = unoccupiedPoints[love.math.random(#unoccupiedPoints)]
            table.insert(state.food, newFood)
        end
    end
end

function BoardState.isKnownBoardSize(state)
    if state.width == 7 and state.height == 7 then
        return true
    elseif state.width == 11 and state.height == 11 then
        return true
    elseif state.width == 19 and state.height == 19 then
        return true
    end
    return false
end

function BoardState.getUnoccupiedPoints(state, includePossibleMoves)
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

function BoardState.getEvenUnoccupiedPoints(state)

    -- Start by getting unoccupied points
    local unoccupiedPoints = BoardState.getUnoccupiedPoints(state, true)

    -- Create a new array to hold points that are even
    local evenUnoccupiedPoints = {}

    for _, point in ipairs(unoccupiedPoints) do
        if (point.x + point.y) % 2 == 0 then
            table.insert(evenUnoccupiedPoints, point)
        end
    end
    return evenUnoccupiedPoints

end

return BoardState
