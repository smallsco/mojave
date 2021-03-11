local GamePane = {}

-- Module Variables
local columnWidthIsSet = false
local newGameType = 1
local selectedSnake = 1
local selectedSquad = 1
local snakesForGame = {}
local squadsForGame = {}
local createGameOK = true
local createGameError = ''

function GamePane.draw()

    -- If no snakes have been added then don't draw this pane at all
    if not next(snakes) then
        imgui.TextWrapped('Yo! You need to add a snake before you can create a new game. Get started by clicking on "Manage Snakes" over on the left side of the screen!')
    else

        -- Game Mode
        if imgui.CollapsingHeader( "Game Mode", { "DefaultOpen" } ) then
            newGameType = imgui.RadioButton( "Standard", newGameType, GameThread.RULES_STANDARD )
            imgui.SameLine()
            newGameType = imgui.RadioButton( "Royale", newGameType, GameThread.RULES_ROYALE )
            imgui.SameLine()
            newGameType = imgui.RadioButton( "Squads", newGameType, GameThread.RULES_SQUADS )
            imgui.SameLine()
            newGameType = imgui.RadioButton( "Constrictor", newGameType, GameThread.RULES_CONSTRICTOR )
            imgui.Text( "\n" )
        end

        -- Board Size
        if imgui.CollapsingHeader( "Board Size", { "DefaultOpen" } ) then
            config.gameplay.boardSize = imgui.RadioButton( "Small (7x7)", config.gameplay.boardSize, 1 )
            imgui.SameLine()
            config.gameplay.boardSize = imgui.RadioButton( "Medium (11x11)", config.gameplay.boardSize, 2 )
            imgui.SameLine()
            config.gameplay.boardSize = imgui.RadioButton( "Large (19x19)", config.gameplay.boardSize, 3 )
            imgui.SameLine()
            config.gameplay.boardSize = imgui.RadioButton( "Custom Board Size", config.gameplay.boardSize, 4 )
            if config.gameplay.boardSize == 1 then
                config.gameplay.boardWidth = 7
                config.gameplay.boardHeight = 7
            elseif config.gameplay.boardSize == 2 then
                config.gameplay.boardWidth = 11
                config.gameplay.boardHeight = 11
            elseif config.gameplay.boardSize == 3 then
                config.gameplay.boardWidth = 19
                config.gameplay.boardHeight = 19
            else
                imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.33)
                config.gameplay.boardWidth = imgui.InputInt( "Board Width", config.gameplay.boardWidth )
                imgui.SameLine()
                config.gameplay.boardHeight = imgui.InputInt( "Board Height", config.gameplay.boardHeight )
                imgui.PopItemWidth()
            end
            imgui.Text( "\n" )
        end

        -- Available Squads
        -- If switching between squads and another game mode, reset selected snakes
        -- This is so that when starting a squads game all snakes will have a squad
        local available_squads = {"Squad 1", "Squad 2", "Squad 3", "Squad 4"}
        if newGameType ~= GameThread.RULES_SQUADS then
            squadsForGame = {}
        else
            for id, _ in pairs(snakesForGame) do
                if not squadsForGame[id] then
                    snakesForGame[id] = nil
                end
            end
        end

        -- Old API snakes can only play under standard rules
        if newGameType ~= GameThread.RULES_STANDARD then
            for id, snake in pairs(snakesForGame) do
                if snake.apiversion == 0 or snakesForGame[id].type == Snake.TYPES.API_OLD or snakesForGame[id].type == Snake.TYPES.ROBOSNAKE then
                    imgui.OpenPopup( "SnakeNotSupportedForRules" )
                    snakesForGame[id] = nil
                    squadsForGame[id] = nil
                end
            end
        end

        -- SnakeNotSupportedForRules dialog
        if imgui.BeginPopupModal( "SnakeNotSupportedForRules", nil, { "NoResize", "AlwaysAutoResize" } ) then
            imgui.Text("One or more snakes have been removed because they are not supported by the selected rules.\n\n")
            imgui.Separator()
            if imgui.Button( "OK" ) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end

        -- Available Snakes
        local available_snakes = {}
        for id, snake in pairs(snakes) do
            if snakesForGame[id] == nil then
                table.insert(available_snakes, snake.name)
            end
        end
        if #available_snakes > 0 then
            if imgui.CollapsingHeader( "Select Snakes for Game", { "DefaultOpen" } ) then
                selectedSnake = imgui.Combo( "##gpSnakeSelect", selectedSnake, available_snakes, #available_snakes )
                imgui.SameLine()
                if newGameType == GameThread.RULES_SQUADS then
                    imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.25)
                    selectedSquad = imgui.Combo( "##gpSquadSelect", selectedSquad, available_squads, 4)
                    imgui.PopItemWidth()
                    imgui.SameLine()
                end
                if imgui.Button("Add") then
                    for id, snake in pairs(snakes) do
                        if snake.name == available_snakes[selectedSnake] then
                            snakesForGame[id] = snake
                            if newGameType == GameThread.RULES_SQUADS then
                                squadsForGame[id] = selectedSquad
                            end
                        end
                    end
                end
                imgui.Text( "\n" )
            end
        end

        -- If a snake has been added to the game but is then removed from the snakes pane
        -- then we also need to remove it from the game pane
        for id, snake in pairs(snakesForGame) do
            if not snakes[id] then
                snakesForGame[id] = nil
                squadsForGame[id] = nil
            end
        end

        -- Snakes In Game
        if next(snakesForGame) then
            local count = 1
            if imgui.CollapsingHeader( "Snakes in Game", { "DefaultOpen" } ) then
                imgui.Columns( 3, "snakes_GamePane" )
                if not columnWidthIsSet then
                    -- Imgui bug...
                    -- Only set the column widths on the first frame, otherwise
                    -- the user will be unable to manually resize the columns
                    -- https://github.com/ocornut/imgui/issues/1655
                    imgui.SetColumnOffset(1, 310)
                    imgui.SetColumnWidth(1, 75)
                    columnWidthIsSet = true
                end
                imgui.Separator()
                imgui.Text( "Name" )
                imgui.NextColumn()
                imgui.Text( "Preview" )
                imgui.NextColumn()
                imgui.Text( "Actions" )
                imgui.NextColumn()
                imgui.Separator()

                for id, snake in pairs(snakesForGame) do
                    if count > 1 then
                        imgui.Separator()
                    end

                    -- Snake and Squad Name
                    imgui.Text( snake.name )
                    if newGameType == GameThread.RULES_SQUADS then
                        local sr, sg, sb = unpack(config.squads["squad" .. squadsForGame[id] .. "Color"])
                        imgui.TextColored(sr, sg, sb, 1, "Squad " .. squadsForGame[id])
                    end
                    imgui.NextColumn()

                    -- Body Preview
                    if (snake.type == Snake.TYPES.API and snake.apiversion > 0) or snake.type == Snake.TYPES.ROBOSNAKE or snake.type == Snake.TYPES.HUMAN then
                        local snakeHeight = imgui.GetTextLineHeight() * 2
                        local headImg = snakeHeads[snake.headSrc]
                        local tailImg = snakeTails[snake.tailSrc]
                        local head_scale_ratio = headImg:getHeight() / snakeHeight
                        local tail_scale_ratio = tailImg:getHeight() / snakeHeight
                        local sr, sg, sb, sa = unpack(Utils.color_from_hex(snake.color))
                        imgui.Image(
                            tailImg,
                            tailImg:getWidth() / tail_scale_ratio,
                            snakeHeight,
                            1, 0, 0, 1,
                            sr, sg, sb, sa
                        )
                        imgui.SameLine(0,0)
                        imgui.Image(
                            headImg,
                            headImg:getWidth() / head_scale_ratio,
                            snakeHeight,
                            0, 0, 1, 1,
                            sr, sg, sb, sa
                        )
                    else
                        imgui.Text("Not\navailable")
                    end
                    imgui.NextColumn()

                    -- Remove button
                    if imgui.Button( string.format("Remove##%s", id) ) then
                        snakesForGame[id] = nil
                        squadsForGame[id] = nil
                    end
                    imgui.NextColumn()

                    count = count + 1
                end

                imgui.Columns(1)
                imgui.Separator()
                imgui.Text( "\n" )
            end

            -- Count distinct squads
            local distinctSquads = {}
            local distinctSquadCount = 0
            for _, squad in pairs(squadsForGame) do
                distinctSquads[squad] = true
            end
            for _, squad in pairs(distinctSquads) do
                distinctSquadCount = distinctSquadCount + 1
            end

            -- Count humans
            local humansForGame = 0
            for _, snake in pairs(snakesForGame) do
                if snake.type == Snake.TYPES.HUMAN then
                    humansForGame = humansForGame + 1
                end
            end

            -- Start Game Button
            if humansForGame > 1 then
                imgui.TextColored(1,0,0,1, "Only one human player is permitted in a game.")
            elseif newGameType == GameThread.RULES_SQUADS and distinctSquadCount < 2 then
                imgui.TextColored(1,0,0,1, "A minimum of 2 squads are required to play in this game mode.")
            elseif newGameType ~= GameThread.RULES_STANDARD and (count - 1) < 2 then
                imgui.TextColored(1,0,0,1, "A minimum of 2 snakes are required to play in this game mode.")
            else
                if imgui.Button("Start Game", imgui.GetWindowContentRegionWidth() * 0.2, 50) then
                    collectgarbage()
                    Menu.stopBGM()
                    createGameOK, createGameError = pcall(function()
                        activeGame = Game({
                            width = config[ 'gameplay' ][ 'boardWidth' ],
                            height = config[ 'gameplay' ][ 'boardHeight' ],
                            snakes = snakesForGame,
                            rules = newGameType,
                            squad_map = squadsForGame
                        })
                    end)
                    if not createGameOK then
                        imgui.OpenPopup( "CreateGameError" )
                    end
                end
            end

            -- Error dialog
            if imgui.BeginPopupModal( "CreateGameError", nil, { "NoResize", "AlwaysAutoResize" } ) then
                imgui.Text( string.format("%s\n\n", createGameError) )
                imgui.Separator()
                if imgui.Button( "OK" ) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end

        end

    end
end

return GamePane
