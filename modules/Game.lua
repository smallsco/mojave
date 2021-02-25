local Game = {}
Game.__index = Game
setmetatable( Game, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-- Music / SFX
local SFXSnakeFood = love.audio.newSource( 'audio/sfx/anchor_action.wav', 'static' )
local SFXSnakeDeath = love.audio.newSource( 'audio/sfx/space_laser.wav', 'static' )
local BGM = love.audio.newSource( 'audio/music/Nebula_Boss_Fight.mp3', 'stream' )
BGM:setLooping( true )

-- Fonts
local logoFont = love.graphics.newFont( 'fonts/monoton/Monoton-RXOM.ttf', 48 )

-- Control Images
local imgCross = love.graphics.newImage('images/controls/cross.png')
local imgFastForward = love.graphics.newImage('images/controls/fastForward.png')
local imgForward = love.graphics.newImage('images/controls/forward.png')
local imgNext = love.graphics.newImage('images/controls/next.png')
local imgPause = love.graphics.newImage('images/controls/pause.png')
local imgPrevious = love.graphics.newImage('images/controls/previous.png')
local imgReturn = love.graphics.newImage('images/controls/return.png')
local imgRewind = love.graphics.newImage('images/controls/rewind.png')

-- Constructor / Factory Function
-- @param table opt A table containing initialization options
-- @return Game
function Game.new( opt )
    local self = setmetatable( {}, Game )
    self.opt = opt or {}

    -- Create game thread
    self.thread = love.thread.newThread("thread.lua")
    self.channel = love.thread.getChannel("game")
    self.cmdChannel = love.thread.getChannel("commands")
    self.humanChannel = love.thread.getChannel("human")

    -- not the actual game rules, just an int
    self.rules = self.opt.rules

    self.thread:start({
        rules = self.opt.rules,
        snakes = self.opt.snakes,
        width = self.opt.width,
        height = self.opt.height,
        squad_map = self.opt.squad_map or {}
    })

    -- Create an empty board
    self.board = Board({
        width = self.opt.width,
        height = self.opt.height
    })
    self.timer = 0
    self.latencyHistory = {}
    self.history = {}

    -- Deal with race conditions...
    -- Game will initialize much quicker than GameThread, and wait for
    -- GameThread to return a start state. But if GameThread fails to
    -- initialize, and the main thread is already waiting, then we deadlock :(
    -- So have the main thread sleep for 1 second, this way if GameThread fails
    -- it will happen before the main thread starts waiting.
    love.timer.sleep(1)
    local err = self.thread:getError()
    if err then
        error(err)
    end

    -- Wait for starting state from game thread
    self.state = self.channel:demand()
    for _, snake in pairs(self.state.snakes) do
        setmetatable(snake, Snake)
        self.latencyHistory[snake.id] = {}
        table.insert(self.latencyHistory[snake.id], snake.latency)
    end

    -- Put starting state into the history
    table.insert(self.history, self.state)

    -- Start GUI
    self.running = true

    return self
end

-- Check if we need to play a sound. The gameplay is happening in a thread
-- ahead of real time, but we want sounds to play when the user sees an event
-- happen.
function Game:checkNeedPlaySound(index)
    if not config.audio.enableSFX then
        return
    end
    local current_state = self.history[index]
    local prev_state = self.history[index - 1]
    if not prev_state then
        return
    end

    -- Snake Death
    for id, snake in pairs(current_state.snakes) do
        if snake.eliminatedCause ~= prev_state.snakes[id].eliminatedCause then
            SFXSnakeDeath:stop()
            SFXSnakeDeath:play()
            break
        end
    end

    -- Snake Eat
    -- Note: We intentionally don't check against length here - we don't want
    -- to play a sound in game modes where snakes can grow without eating :)
    for _, snake in pairs(current_state.snakes) do
        if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
            local head = snake.body[1]
            for _, food in ipairs(prev_state.food) do
                if head.x == food.x and head.y == food.y then
                    SFXSnakeFood:stop()
                    SFXSnakeFood:play()
                    break
                end
            end
        end
    end
end

-- Game Renderer
function Game:draw()

    -- Draw game board.
    self.board:draw(self.state)

    -- Draw logo top right.
    love.graphics.setColor( 1, 96/255, 222/255, 204/255 )
    love.graphics.setFont( logoFont )
    love.graphics.printf("Mojave", screenWidth-256, -10, 256, "center")

    -- Imgui: Render right-side column.
    love.graphics.setColor( 1, 1, 1, 1 )
    imgui.PushStyleVar( "WindowRounding", 0 )
    imgui.SetNextWindowSize(256, screenHeight-60)
    imgui.SetNextWindowPos(screenWidth-256, 60)
    if imgui.Begin( "Snakes", nil, { "NoResize", "NoCollapse", "NoTitleBar" } ) then
        imgui.PushStyleVar( "ItemSpacing", 7, 4 )

        -- Current Turn
        imgui.Text( "Turn\n" .. self.state.turn )
        imgui.SameLine()

        -- Playback, rematch, and return-to-menu controls
        if imgui.ImageButton( imgPrevious, 16, 16 ) then
            self.state = self.history[1]
        end
        imgui.SameLine()
        if imgui.ImageButton( imgRewind, 16, 16 ) then
            local index = self.state.turn
            if index < 1 then
                index = 1
            end
            self.state = self.history[index]
        end
        imgui.SameLine()
        if self.running then
            if imgui.ImageButton( imgPause, 16, 16 ) then
                self.running = false
            end
        else
            if imgui.ImageButton( imgForward, 16, 16 ) then
                local index = self.state.turn + 2
                if index > #self.history then
                    self.state = self.history[1]
                end
                self.running = true
            end
        end
        imgui.SameLine()
        if imgui.ImageButton( imgFastForward, 16, 16 ) then
            local index = self.state.turn + 2
            if index > #self.history then
                index = #self.history
            end
            self.state = self.history[index]
        end
        imgui.SameLine()
        if imgui.ImageButton( imgNext, 16, 16 ) then
            self.state = self.history[#self.history]
        end
        imgui.SameLine()
        if imgui.ImageButton( imgReturn, 16, 16 ) then
            self:shutdownThread()
            activeGame = Game(self.opt)
        end
        imgui.SameLine()
        if imgui.ImageButton( imgCross, 16, 16 ) then
            imgui.OpenPopup( "ReturnMenu" )
        end
        imgui.PopStyleVar()

        -- Return to Menu dialog
        if imgui.BeginPopupModal( "ReturnMenu", nil, { "NoResize" } ) then
            imgui.Text( "Are you sure you want to return to the menu?\n\n" )
            imgui.Separator()
            if imgui.Button( "OK" ) then
                self:shutdownThread()
                BGM:stop()
                activeGame = nil
            end
            imgui.SameLine()
            if imgui.Button( "Cancel" ) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        imgui.Separator()
        imgui.Text( "\n" )

        -- Snake List
        imgui.Columns( 2, "snakeList", false )
        local snakeIDsByName = {}
        for id, _ in pairs(self.state.snakes) do
            table.insert(snakeIDsByName, id)
        end
        table.sort(snakeIDsByName, function(i, j)
            local name_i = self.state.snakes[i].name
            local name_j = self.state.snakes[j].name
            return name_i:lower() < name_j:lower()
        end)
        for _, id in ipairs(snakeIDsByName) do
            local snake = self.state.snakes[id]

            -- Head/Tail Preview, Debug Button, and Latency Graph
            imgui.PushStyleVar( "FramePadding", 4, 0 )
            if imgui.Button(string.format("DEBUG##%s", snake.id), 50, imgui.GetTextLineHeight()) then
                imgui.LogToClipboard()
                imgui.LogText("** REQUEST **\n")
                imgui.LogText(snake.request .. "\n\n")
                imgui.LogText("** RESPONSE **\n")
                imgui.LogText(snake.response .. "\n\n")
                imgui.LogFinish()
            end
            imgui.PopStyleVar()
            local snakeHeight = imgui.GetTextLineHeight() * 2
            local headImg = snakeHeads[snake.headSrc]
            local tailImg = snakeTails[snake.tailSrc]
            local sr, sg, sb, sa
            if snake.squad then
                sr, sg, sb = unpack(config.squads["squad" .. snake.squad .. "Color"])
                sa = 1
            else
                sr, sg, sb, sa = unpack(Utils.color_from_hex(snake.color))
            end
            local head_scale_ratio = headImg:getHeight() / snakeHeight
            local tail_scale_ratio = tailImg:getHeight() / snakeHeight
            imgui.Image(
                tailImg,
                tailImg:getWidth() / tail_scale_ratio,
                snakeHeight,
                1,0,0,1,
                sr, sg, sb, sa
            )
            if imgui.IsItemHovered() then
                self:drawLatency(snake)
            end
            imgui.SameLine(0,0)
            imgui.Image(
                headImg,
                headImg:getWidth() / head_scale_ratio,
                snakeHeight,
                0, 0, 1, 1,
                sr, sg, sb, sa
            )
            if imgui.IsItemHovered() then
                self:drawLatency(snake)
            end
            imgui.NextColumn()

            -- Name / Health Bar / Length / Kills
            imgui.SetColumnWidth( 0, 60 )
            imgui.TextWrapped(snake.name)
            local xpos, ypos = imgui.GetCursorPos()
            if snake.eliminatedCause == Snake.ELIMINATION_CAUSES.NotEliminated then
                local snakeColor
                if snake.squad then
                    snakeColor = config.squads["squad" .. snake.squad .. "Color"]
                else
                    snakeColor = Utils.color_from_hex(snake.color)
                end
                imgui.PushStyleColor(
                    "PlotHistogram",
                    snakeColor[1],
                    snakeColor[2],
                    snakeColor[3],
                    1.0
                )
                imgui.ProgressBar(
                    snake.health / 100,
                    imgui.GetColumnWidth()*0.9,
                    15
                )
                imgui.PopStyleColor()
                imgui.Text( "Length:" )
                imgui.SameLine()
                imgui.Text( #snake.body )
                imgui.SameLine()
                imgui.Text( "\tKills: " .. snake.kills )
            elseif snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedByOutOfHealth then
                imgui.PushTextWrapPos(xpos + imgui.GetColumnWidth()*0.9)
                imgui.TextColored( 1, 0, 0, 1, "Ran out of health" )
                imgui.PopTextWrapPos()
            elseif snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedByHeadToHeadCollision then
                imgui.PushTextWrapPos(xpos + imgui.GetColumnWidth()*0.9)
                imgui.TextColored( 1, 0, 0, 1, string.format(
                    "Lost head to head with %s",
                    self.state.snakes[snake.eliminatedBy].name
                ))
                imgui.PopTextWrapPos()
            elseif snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedByCollision then
                imgui.PushTextWrapPos(xpos + imgui.GetColumnWidth()*0.9)
                imgui.TextColored( 1, 0, 0, 1, string.format(
                    "Ran into %s's body",
                    self.state.snakes[snake.eliminatedBy].name
                ))
                imgui.PopTextWrapPos()
            elseif snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedBySelfCollision then
                imgui.PushTextWrapPos(xpos + imgui.GetColumnWidth()*0.9)
                imgui.TextColored( 1, 0, 0, 1, "Ran into own body" )
                imgui.PopTextWrapPos()
            elseif snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedByOutOfBounds then
                imgui.PushTextWrapPos(xpos + imgui.GetColumnWidth()*0.9)
                imgui.TextColored( 1, 0, 0, 1, "Ran into a wall" )
                imgui.PopTextWrapPos()
            elseif snake.eliminatedCause == Snake.ELIMINATION_CAUSES.EliminatedBySquad then
                imgui.PushTextWrapPos(xpos + imgui.GetColumnWidth()*0.9)
                imgui.TextColored( 1, 0, 0, 1, "Squad was eliminated" )
                imgui.PopTextWrapPos()
            end
            imgui.Text( "\n" )
            imgui.NextColumn()
        end
        imgui.Columns(1)

    end
    imgui.End()
    imgui.PopStyleVar()
end

-- Render the latency tooltip when hovering over snake preview
function Game:drawLatency(snake)
    imgui.BeginTooltip()
    imgui.Text(string.format("Current Latency: %sms", snake.latency))
    imgui.PlotLines("", self.latencyHistory[snake.id], #self.latencyHistory[snake.id])
    imgui.EndTooltip()
end

-- Keypress handler - allows a human player to control a snake
-- @param key The key that was pressed
function Game:keypressed(key)
    if self.running then
        self.humanChannel:push(key)
    end
end

-- Cleanly shut down the game thread and clear the message queues
function Game:shutdownThread()
    if self.thread:isRunning() then
        self.cmdChannel:push('exit')
        self.thread:wait()
        self.channel:clear()
        self.humanChannel:clear()
    end
end

-- Update Loop
-- @param dt Delta Time
function Game:update( dt )

    -- Background music
    if config.audio.enableMusic then
        if not BGM:isPlaying() then
            BGM:play()
        end
    else
        if BGM:isPlaying() then
            BGM:stop()
        end
    end

    -- As the game thread runs and generates future states, add them to history
    -- as they become available.
    local nextState = self.channel:pop()
    if nextState then
        for _, snake in pairs(nextState.snakes) do
            setmetatable(snake, Snake)
            table.insert(self.latencyHistory[snake.id], snake.latency)
        end
        table.insert(self.history, nextState)
    end

    -- "Running" in this case simply means "has the user paused the GUI or not"
    if self.running then
        self.timer = self.timer + dt
        if self.timer < config.gameplay.gameSpeed then
            return
        else
            self.timer = 0
            local index = self.state.turn + 2
            if index <= #self.history then
                self.state = self.history[index]
                self:checkNeedPlaySound(index)
            end

        end
    end

    -- If the game has ended (the thread has exited) and we're on the last turn, pause the GUI
    if not self.thread:isRunning() then
        if self.state.turn + 1 == #self.history then
            self.running = false
        end
    end
end

return Game
