local BoardState = {}

BoardState.SnakeMaxHealth = config.gameplay.maxHealth
BoardState.SnakeStartSize = config.gameplay.startSize

local format = string.format

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
    for i=1, #state.snakes do
        state.snakes[i].health = BoardState.SnakeMaxHealth
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
    if #state.snakes > #start_points then
        local err = 'Sorry, a maximum of %s snakes are supported for this board configuration.'
        error(format(err, #start_points), 0)
    end

    -- Randomly order them
    Utils.shuffle(start_points)

    -- Assign to snakes in order given
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        for j=1, BoardState.SnakeStartSize do
            snake.body[#snake.body + 1] = start_points[i]
        end
    end
end

function BoardState.placeSnakesRandomly(state, snakes)
    -- Add snakes to state
    state.snakes = Utils.deepcopy(snakes)
    for i=1, #state.snakes do
        state.snakes[i].health = BoardState.SnakeMaxHealth
    end

    for i=1, #state.snakes do
        local snake = state.snakes[i]
        local unoccupiedPoints = BoardState.getEvenUnoccupiedPoints(state)
        if #unoccupiedPoints <= 0 then
            error("Sorry, there is not enough room on the board to place snakes.")
        end

        local point = unoccupiedPoints[love.math.random(#unoccupiedPoints)]

        for j=1, BoardState.SnakeStartSize do
            snake.body[#snake.body + 1] = point
        end
    end
end

-- Adds a single snake to the board with the given body coordinates
function BoardState.placeSnake(state, snake, body)
    local idx = #state.snakes + 1
    state.snakes[idx] = Utils.deepcopy(snake)
    state.snakes[idx].health = BoardState.SnakeMaxHealth
    state.snakes[idx].body = body
end

-- Initializes the array of food based on the size of the board and the number of snakes.
function BoardState.placeFoodAutomatically(state)
    if BoardState.isKnownBoardSize(state) then
        BoardState.placeFoodFixed(state)
    else
        BoardState.placeFoodRandomly(state, #state.snakes)
    end
end

function BoardState.placeFoodFixed(state)
    -- Place 1 food within exactly 2 moves of each snake
    for i=1, #state.snakes do
        local snakeHead = state.snakes[i].body[1]
        local possibleFoodLocations = {
            {x=snakeHead.x - 1, y=snakeHead.y - 1},
            {x=snakeHead.x - 1, y=snakeHead.y + 1},
            {x=snakeHead.x + 1, y=snakeHead.y - 1},
            {x=snakeHead.x + 1, y=snakeHead.y + 1},
        }
        local availableFoodLocations = {}

        for j=1, #possibleFoodLocations do
            local point = possibleFoodLocations[j]
            local isOccupiedAlready = false
            for k=1, #state.food do
                if state.food[k].x == point.x and state.food[k].y == point.y then
                    isOccupiedAlready = true
                    break
                end
            end
            if not isOccupiedAlready then
                availableFoodLocations[#availableFoodLocations + 1] = point
            end
        end

        if #availableFoodLocations <= 0 then
            error("Sorry, there is not enough room on the board to place food.")
        end

        -- Select randomly from available locations
        local placedFood = availableFoodLocations[love.math.random(#availableFoodLocations)]
        state.food[#state.food + 1] = placedFood
    end

    -- Finally, always place 1 food in center of board for dramatic purposes
    local isCenterOccupied = true
    local centerCoord = {x=(state.width - 1)/2, y=(state.height - 1)/2}
    local unoccupiedPoints = BoardState.getUnoccupiedPoints(state, true)
    for i=1, #unoccupiedPoints do
        local point = unoccupiedPoints[i]
        if point.x == centerCoord.x and point.y == centerCoord.y then
            isCenterOccupied = false
            break
        end
    end
    if isCenterOccupied then
        error("Sorry, there is not enough room on the board to place food.")
    end
    state.food[#state.food + 1] = centerCoord
end

-- Adds up to num new food to the board in random unoccupied squares
function BoardState.placeFoodRandomly(state, num)
    for i = 1, num do
        local unoccupiedPoints = BoardState.getUnoccupiedPoints(state, false)
        if #unoccupiedPoints > 0 then
            local newFood = unoccupiedPoints[love.math.random(#unoccupiedPoints)]
            state.food[#state.food + 1] = newFood
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
    for i=1, #state.food do
        local food = state.food[i]
        pointIsOccupied[food.x + 1][food.y + 1] = true
    end

    -- add snakes
    for i=1, #state.snakes do
        if state.snakes[i].eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            for j=1, #state.snakes[i].body do
                local body_point = state.snakes[i].body[j]

                -- There's a crash that can occur here because adding food takes place in between moving snakes
                -- and eliminating them. So if a snake is out-of-bounds but not yet eliminated, that body part
                -- will fall outside the bounds of the pointIsOccupied table. To work around this, double-check
                -- that all body parts fall within the bounds of the game board, and skip over any that do not.
                --
                -- It doesn't seem like the official rules check for this? But the game works, so maybe it's just
                -- something I don't understand about go array syntax  *shrug*
                if body_point.x >= 0 and body_point.y >= 0 and body_point.x < state.width and body_point.y < state.height then

                    pointIsOccupied[body_point.x + 1][body_point.y + 1] = true
                    if j == 1 and not includePossibleMoves then
                        local nextMovePoints = {
                            {x = body_point.x - 1, y = body_point.y},
                            {x = body_point.x + 1, y = body_point.y},
                            {x = body_point.x, y = body_point.y - 1},
                            {x = body_point.x, y = body_point.y + 1}
                        }
                        for k=1, #nextMovePoints do
                            local next_point = nextMovePoints[k]
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
                unoccupiedPoints[#unoccupiedPoints + 1] = {x=x-1, y=y-1}
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

    for i=1, #unoccupiedPoints do
        local point = unoccupiedPoints[i]
        if (point.x + point.y) % 2 == 0 then
            evenUnoccupiedPoints[#evenUnoccupiedPoints + 1] = point
        end
    end
    return evenUnoccupiedPoints

end

return BoardState
