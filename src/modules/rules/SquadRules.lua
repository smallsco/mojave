local SquadRules = {}
SquadRules.__index = SquadRules
setmetatable( SquadRules, {
  __index = StandardRules,
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function SquadRules.new( opt )
    local self = setmetatable( StandardRules(opt), SquadRules )
    opt = opt or {}

    self.SquadMap = opt.squad_map

    self.AllowBodyCollisions = opt.allow_body_collisions
    self.SharedElimination = opt.shared_elimination
    self.SharedHealth = opt.shared_health
    self.SharedLength = opt.shared_length

    return self
end

function SquadRules:createNextBoardState(prevState, moves)
    local nextBoardState = StandardRules.createNextBoardState(self, prevState, moves)
    self:resurrectSquadBodyCollisions(nextBoardState)
    self:shareSquadAttributes(nextBoardState)
    return nextBoardState
end

function SquadRules:areSnakesOnSameSquad(snake, other)
    return self:areSnakeIDsOnSameSquad(snake.id, other.id)
end

function SquadRules:areSnakeIDsOnSameSquad(snakeID, otherID)
    return self.SquadMap[snakeID] == self.SquadMap[otherID]
end

function SquadRules:resurrectSquadBodyCollisions(state)
    if not self.AllowBodyCollisions then
        return
    end

    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedByCollision then
            if snake.eliminatedBy == "" then
                error("Snake eliminated by collision and eliminatedby is not set")
            end
            if snake.id ~= snake.eliminatedBy and self:areSnakeIDsOnSameSquad(snake.id, snake.eliminatedBy) then
                snake.eliminatedCause = Snake.ELIMINATION_CAUSES.NotEliminated
                snake.eliminatedBy = ""
            end
        end
    end
end

function SquadRules:shareSquadAttributes(state)
    if not (self.SharedElimination or self.SharedLength or self.SharedHealth) then
        return
    end

    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            for _, other in pairs(state.snakes) do
                if self:areSnakesOnSameSquad(snake, other) then
                    if self.SharedHealth then
                        if snake.health < other.health then
                            snake.health = other.health
                        end
                    end
                    if self.SharedLength then
                        if #snake.body == 0 or #other.body == 0 then
                            error("Found snake of zero length")
                        end
                        while #snake.body < #other.body do
                            self:growSnake(snake)
                        end
                    end
                    if self.SharedElimination then
                        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated and other.eliminatedCause ~= Snake.ELIMINATION_CAUSES.NotEliminated then
                            snake.eliminatedCause = Snake.ELIMINATION_CAUSES.EliminatedBySquad

                            -- We intentionally do not set snake.EliminatedBy because there might be multiple culprits.
                            snake.eliminatedBy = ""
                        end
                    end
                end
            end
        end
    end
end

function SquadRules:isGameOver(state)
    local snakesRemaining = {}
    for _, snake in pairs(state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            table.insert(snakesRemaining, snake)
        end
    end

    for i=1, #snakesRemaining do
        if not self:areSnakesOnSameSquad(snakesRemaining[i], snakesRemaining[1]) then
            return false
        end
    end

    -- No snakes or single squad remaining
    return true
end

return SquadRules
