local ConstrictorRules = {}
ConstrictorRules.__index = ConstrictorRules
setmetatable( ConstrictorRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ConstrictorRules.new( opt )
    local self = setmetatable( StandardRules(), ConstrictorRules )
    opt = opt or {}

    return self
end

function ConstrictorRules:createInitialBoardState(width, height, snakes)
    local initialBoardState = StandardRules.createInitialBoardState(self, width, height, snakes)
    self:applyConstrictorRules(initialBoardState)
    return initialBoardState
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
    for _, snake in pairs(state.snakes) do
        snake.health = self.SnakeMaxHealth

        local tail = snake.body[#snake.body]
        local subTail = snake.body[#snake.body - 1]
        if tail.x ~= subTail.x or tail.y ~= subTail.y then
            self:growSnake(snake)
        end
    end
end

return ConstrictorRules
