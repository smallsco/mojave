local ConstrictorRules = {}
ConstrictorRules.__index = ConstrictorRules
setmetatable( ConstrictorRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ConstrictorRules.new( opt )
    local self = setmetatable( StandardRules(opt), ConstrictorRules )
    opt = opt or {}

    return self
end

function ConstrictorRules:modifyInitialBoardState(initialBoardState)
    initialBoardState = StandardRules.modifyInitialBoardState(self, initialBoardState)
    local newBoardState = BoardState.clone(initialBoardState)
    self:applyConstrictorRules(newBoardState)
    return newBoardState
end

function ConstrictorRules:createNextBoardState(prevState, moves)
    local nextState = StandardRules.createNextBoardState(self, prevState, moves)
    self:applyConstrictorRules(nextState)
    return nextState
end

function ConstrictorRules:applyConstrictorRules(state)
    -- Remove all food from the board
    state.food = {}

    -- Set all snakes to max health and ensure they grow next turn
    for i=1, #state.snakes do
        local snake = state.snakes[i]
        snake.health = BoardState.SnakeMaxHealth

        local tail = snake.body[#snake.body]
        local subTail = snake.body[#snake.body - 1]
        if tail.x ~= subTail.x or tail.y ~= subTail.y then
            self:growSnake(snake)
        end
    end
end

return ConstrictorRules
