local WrappedRules = {}
WrappedRules.__index = WrappedRules
setmetatable( WrappedRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function WrappedRules.new( opt )
    local self = setmetatable( StandardRules(opt), WrappedRules )
    opt = opt or {}

    return self
end

local function replace(value, min, max)
    if value < min then
        return max
    end
    if value > max then
        return min
    end
    return value
end

function WrappedRules:createNextBoardState(prevState, moves)
    local nextState = BoardState.clone(prevState)
    self:moveSnakes(nextState, moves)
    self:reduceSnakeHealth(nextState)
    self:maybeDamageHazards(nextState)
    self:maybeFeedSnakes(nextState)
    self:maybeSpawnFood(nextState)
    self:maybeEliminateSnakes(nextState)
    return nextState
end

function WrappedRules:moveSnakes(state, moves)
    StandardRules.moveSnakes(self, state, moves)

    for _, snake in pairs(state.snakes) do
        snake.body[1].x = replace(snake.body[1].x, 0, state.width - 1)
        snake.body[1].y = replace(snake.body[1].y, 0, state.height - 1)
    end
end

return WrappedRules
