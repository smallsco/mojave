local SoloRules = {}
SoloRules.__index = SoloRules
setmetatable( SoloRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function SoloRules.new( opt )
    local self = setmetatable( StandardRules(), SoloRules )
    opt = opt or {}

    return self
end

function SoloRules:isGameOver(state)
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            return false
        end
    end
    return true
end

return SoloRules
