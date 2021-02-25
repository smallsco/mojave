local RoyaleRules = {}
RoyaleRules.__index = RoyaleRules
setmetatable( RoyaleRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function RoyaleRules.new( opt )
    local self = setmetatable( StandardRules(), RoyaleRules )
    opt = opt or {}

    self.seed = opt.random_seed or os.time()
    self.ShrinkEveryNTurns = opt.shrink_every_n_turns or 25
    self.DamagePerTurn = opt.damage_per_turn or 15

    return self
end

function RoyaleRules:createNextBoardState(prevState, moves)
    if self.ShrinkEveryNTurns < 1 then
        error("Royale game must shrink at least every turn")
    end

    -- Slight difference to the official ruleset here...
    -- Mojave tracks the hazards in the state, so we can use that
    -- when calling damageOutOfBounds() without needing to call
    -- the populateOutOfBounds() function first to save performance.

    local nextBoardState = StandardRules.createNextBoardState(self, prevState, moves)
    self:damageOutOfBounds(nextBoardState)
    self:populateOutOfBounds(nextBoardState, nextBoardState.turn + 1)
    return nextBoardState
end

function RoyaleRules:populateOutOfBounds(state, turn)
    if self.ShrinkEveryNTurns < 1 then
        error("Royale game must shrink at least every turn")
    end

    if turn < self.ShrinkEveryNTurns then
        return
    end

    -- We use the pure Lua math.random() function instead of the love.math.random()
    -- function because we need to be able to control the seed.
    math.randomseed(self.seed)

    local numShrinks = math.floor(turn / self.ShrinkEveryNTurns)
    local minX, maxX = 0, state.width - 1
    local minY, maxY = 0, state.height - 1

    for i=1, numShrinks do
        local case = math.random(4)
        if case == 1 then
            minX = minX + 1
        elseif case == 2 then
            maxX = maxX - 1
        elseif case == 3 then
            minY = minY + 1
        elseif case == 4 then
            maxY = maxY - 1
        end
    end

    local OutOfBounds = {}
    for x=0, state.width-1 do
        for y=0, state.height-1 do
            if x < minX or x > maxX or y < minY or y > maxY then
                table.insert(OutOfBounds, {x=x, y=y})
            end
        end
    end
    state.hazards = OutOfBounds

end

function RoyaleRules:damageOutOfBounds(state)
    if self.DamagePerTurn < 1 then
        error("Royale damage per turn must be greater than zero")
    end

    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            local head = snake.body[1]
            for _, p in ipairs(state.hazards) do
                if head.x == p.x and head.y == p.y then
                    -- Snake is now out of bounds, reduce health
                    snake.health = snake.health - self.DamagePerTurn
                    if snake.health < 0 then
                        snake.health = 0
                    end
                    if self:snakeIsOutOfHealth(snake) then
                        snake.EliminatedCause = Snake.ELIMINATION_CAUSES.EliminatedByOutOfHealth
                    end
                end
            end
        end
    end
end

return RoyaleRules