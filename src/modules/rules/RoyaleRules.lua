local RoyaleRules = {}
RoyaleRules.__index = RoyaleRules
setmetatable( RoyaleRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local floor = math.floor
local time = os.time
local random = math.random
local randomseed = math.randomseed

function RoyaleRules.new( opt )
    local self = setmetatable( StandardRules(opt), RoyaleRules )
    opt = opt or {}

    self.seed = opt.random_seed or time()
    self.ShrinkEveryNTurns = opt.shrink_every_n_turns or 25

    return self
end

function RoyaleRules:createNextBoardState(prevState, moves)
    if self.HazardDamagePerTurn < 1 then
        error("Royale damage per turn must be greater than zero")
    end

    local nextBoardState = StandardRules.createNextBoardState(self, prevState, moves)

    -- Royale's only job is now to populate the hazards for next turn - StandardRules takes care of applying hazard damage.
    self:populateHazards(nextBoardState, nextBoardState.turn + 1)
    return nextBoardState
end

function RoyaleRules:populateHazards(state, turn)
    if self.ShrinkEveryNTurns < 1 then
        error("Royale game can't shrink more frequently than every turn")
    end

    if turn < self.ShrinkEveryNTurns then
        return
    end

    -- We use the pure Lua math.random() function instead of the love.math.random()
    -- function because we need to be able to control the seed.
    randomseed(self.seed)

    local numShrinks = floor(turn / self.ShrinkEveryNTurns)
    local minX, maxX = 0, state.width - 1
    local minY, maxY = 0, state.height - 1

    for i=1, numShrinks do
        local case = random(4)
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

    local hazards = {}
    for x=0, state.width-1 do
        for y=0, state.height-1 do
            if x < minX or x > maxX or y < minY or y > maxY then
                hazards[#hazards + 1] = {x=x, y=y}
            end
        end
    end
    state.hazards = hazards

end

return RoyaleRules