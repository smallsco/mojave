local Menu = {}

local defaultFont = love.graphics.newFont( 12 )
local logoFont = love.graphics.newFont( 'fonts/monoton/Monoton-Regular.ttf', 144 )
local BGM = love.audio.newSource( 'audio/music/Automation.mp3' )
BGM:setLooping( true )
local rightPane = 'snakes'
local showTestWindow = false

--- Menu update loop
-- @param dt Delta Time (unused)
function Menu.update( dt )

    -- Background music
    if config[ 'audio' ][ 'enableMusic' ] then
        if BGM:isStopped() then
            BGM:play()
        end
    else
        if BGM:isPlaying() then
            BGM:stop()
        end
    end
    
    -- Check fullscreen state
    if config[ 'appearance' ][ 'fullscreen' ] ~= love.window.getFullscreen() then
        love.window.setFullscreen( config[ 'appearance' ][ 'fullscreen' ] )
        screenWidth, screenHeight = love.graphics.getDimensions()
        vxScale = love.graphics.getWidth() / bgVignette:getWidth()
        vyScale = love.graphics.getHeight() / bgVignette:getHeight()
    end

end

--- Menu render loop
function Menu.draw()

    -- Required by a quirk of the lua-imgui integration...
    local unused

    -- Navy blue BG
    love.graphics.clear( 0, 0, 111, 255 )
    if config[ 'appearance' ][ 'enableVignette' ] then
        love.graphics.draw( bgVignette, 0, 0, 0, vxScale, vyScale )
    end

    -- Logo text
    love.graphics.setColor( 255, 96, 222, 204 )
    love.graphics.setFont( logoFont )
    love.graphics.printf( "Mojave", 0, 0, screenWidth, "center" )
    love.graphics.setColor( 255, 255, 255, 255 )
    
    -- Footer text
    love.graphics.setFont( defaultFont )
    love.graphics.printf( "©2017-2019 Scott Small", 0, screenHeight*0.95, screenWidth, "center" )
    love.graphics.print( MOJAVE_VERSION, screenWidth*0.975, screenHeight*0.975 )
    
    -- Render UI
    imgui.SetNextWindowSize(
        screenWidth - ( screenWidth * 0.1 ),
        screenHeight - ( screenHeight * 0.4 )
    )
    imgui.SetNextWindowPos(
        screenWidth - ( screenWidth * 0.95 ),
        screenHeight - ( screenHeight * 0.675 )
    )
    if imgui.Begin( "Menu", nil, { "NoResize", "NoCollapse", "NoTitleBar" } ) then
        
        imgui.BeginChild( "Sub1", imgui.GetWindowContentRegionWidth() * 0.5, 0 )
        imgui.PushStyleVar( "ItemSpacing", 8, 24 )
        
        -- Menu Buttons
        local buttonWidth = 200
        local buttonX = ( imgui.GetWindowWidth() * 0.5 ) - ( buttonWidth / 2 )
        imgui.Text( "" )
        imgui.Text( "" )
        imgui.SameLine( buttonX )
        if imgui.Button( "New Game", 200, 50 ) then
            if BGM:isPlaying() then
                BGM:stop()
            end
            activeGame = Game()
            if not config[ 'system' ][ 'pauseNewGames' ] then
                activeGame:start()
            end
        end
        imgui.Text( "" )
        imgui.SameLine( buttonX )
        if imgui.Button( "Add/Change Snakes", 200, 50 ) then
            rightPane = 'snakes'
        end
        imgui.Text( "" )
        imgui.SameLine( buttonX )
        if imgui.Button( "Options", 200, 50 ) then
            rightPane = 'options'
        end
        imgui.Text( "" )
        imgui.SameLine( buttonX )
        if imgui.Button( "Rules / Credits", 200, 50 ) then
            rightPane = 'credits'
            -- showTestWindow = not showTestWindow
        end
        imgui.Text( "" )
        imgui.SameLine( buttonX )
        if imgui.Button( "Exit", 200, 50 ) then
            imgui.OpenPopup( "Exit" )
        end
        
        imgui.PopStyleVar()
        
        -- Exit Confirmation Dialog
        if imgui.BeginPopupModal( "Exit", nil, { "NoResize" } ) then
            imgui.Text( "Are you sure you want to exit the game?\n\n" )
            imgui.Separator()
            if imgui.Button( "OK" ) then
                love.event.quit()
            end
            imgui.SameLine()
            if imgui.Button( "Cancel" ) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        
        if showTestWindow then
            showTestWindow = imgui.ShowTestWindow( true )
        end
        
        -- Options
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild( "Sub2", imgui.GetWindowContentRegionWidth() * 0.5, 0)
        if rightPane == 'options' then
        
            -- Appearance Options
            if imgui.CollapsingHeader( "Appearance", { "DefaultOpen" } ) then
                unused,
                config[ 'appearance' ][ 'tilePrimaryColor' ][1],
                config[ 'appearance' ][ 'tilePrimaryColor' ][2],
                config[ 'appearance' ][ 'tilePrimaryColor' ][3],
                config[ 'appearance' ][ 'tilePrimaryColor' ][4] = imgui.ColorEdit4(
                    "Tile Primary Color",
                    config[ 'appearance' ][ 'tilePrimaryColor' ][1],
                    config[ 'appearance' ][ 'tilePrimaryColor' ][2],
                    config[ 'appearance' ][ 'tilePrimaryColor' ][3],
                    config[ 'appearance' ][ 'tilePrimaryColor' ][4]
                )
                unused,
                config[ 'appearance' ][ 'tileSecondaryColor' ][1],
                config[ 'appearance' ][ 'tileSecondaryColor' ][2],
                config[ 'appearance' ][ 'tileSecondaryColor' ][3],
                config[ 'appearance' ][ 'tileSecondaryColor' ][4] = imgui.ColorEdit4(
                    "Tile Secondary Color",
                    config[ 'appearance' ][ 'tileSecondaryColor' ][1],
                    config[ 'appearance' ][ 'tileSecondaryColor' ][2],
                    config[ 'appearance' ][ 'tileSecondaryColor' ][3],
                    config[ 'appearance' ][ 'tileSecondaryColor' ][4]
                )
                unused,
                config[ 'appearance' ][ 'foodColor' ][1],
                config[ 'appearance' ][ 'foodColor' ][2],
                config[ 'appearance' ][ 'foodColor' ][3],
                config[ 'appearance' ][ 'foodColor' ][4] = imgui.ColorEdit4(
                    "Food Color",
                    config[ 'appearance' ][ 'foodColor' ][1],
                    config[ 'appearance' ][ 'foodColor' ][2],
                    config[ 'appearance' ][ 'foodColor' ][3],
                    config[ 'appearance' ][ 'foodColor' ][4]
                )
                unused,
                config[ 'appearance' ][ 'goldColor' ][1],
                config[ 'appearance' ][ 'goldColor' ][2],
                config[ 'appearance' ][ 'goldColor' ][3],
                config[ 'appearance' ][ 'goldColor' ][4] = imgui.ColorEdit4(
                    "Gold Color",
                    config[ 'appearance' ][ 'goldColor' ][1],
                    config[ 'appearance' ][ 'goldColor' ][2],
                    config[ 'appearance' ][ 'goldColor' ][3],
                    config[ 'appearance' ][ 'goldColor' ][4]
                )
                unused,
                config[ 'appearance' ][ 'wallColor' ][1],
                config[ 'appearance' ][ 'wallColor' ][2],
                config[ 'appearance' ][ 'wallColor' ][3],
                config[ 'appearance' ][ 'wallColor' ][4] = imgui.ColorEdit4(
                    "Wall Color",
                    config[ 'appearance' ][ 'wallColor' ][1],
                    config[ 'appearance' ][ 'wallColor' ][2],
                    config[ 'appearance' ][ 'wallColor' ][3],
                    config[ 'appearance' ][ 'wallColor' ][4]
                )
                unused, config[ 'appearance' ][ 'fullscreen' ] = imgui.Checkbox( "Fullscreen", config[ 'appearance' ][ 'fullscreen' ] )
                unused, config[ 'appearance' ][ 'enableBloom' ] = imgui.Checkbox( "Bloom Filter", config[ 'appearance' ][ 'enableBloom' ] )
                unused, config[ 'appearance' ][ 'enableVignette' ] = imgui.Checkbox( "Vignette", config[ 'appearance' ][ 'enableVignette' ] )
                unused, config[ 'appearance' ][ 'fadeOutTails' ] = imgui.Checkbox( "Fade Out Tails", config[ 'appearance' ][ 'fadeOutTails' ] )
                imgui.Text( "\n" )
            end
            
            -- Audio Options
            if imgui.CollapsingHeader( "Audio", { "DefaultOpen" } ) then
                unused, config[ 'audio' ][ 'enableMusic' ] = imgui.Checkbox( "Music", config[ 'audio' ][ 'enableMusic' ] )
                imgui.SameLine()
                unused, config[ 'audio' ][ 'enableSFX' ] = imgui.Checkbox( "Sound Effects", config[ 'audio' ][ 'enableSFX' ] )
                imgui.Text( "\n" )
            end
            
            -- Gameplay Options
            if imgui.CollapsingHeader( "Gameplay", { "DefaultOpen" } ) then
                unused, config[ 'gameplay' ][ 'boardSize' ] = imgui.RadioButton( "Small (7x7)", config[ 'gameplay' ][ 'boardSize' ], 1 )
                imgui.SameLine()
                unused, config[ 'gameplay' ][ 'boardSize' ] = imgui.RadioButton( "Medium (11x11)", config[ 'gameplay' ][ 'boardSize' ], 2 )
                imgui.SameLine()
                unused, config[ 'gameplay' ][ 'boardSize' ] = imgui.RadioButton( "Large (19x19)", config[ 'gameplay' ][ 'boardSize' ], 3 )
                imgui.SameLine()
                unused, config[ 'gameplay' ][ 'boardSize' ] = imgui.RadioButton( "Custom Board Size", config[ 'gameplay' ][ 'boardSize' ], 4 )
                if config[ 'gameplay' ][ 'boardSize' ] == 1 then
                    config[ 'gameplay' ][ 'boardWidth' ] = 7
                    config[ 'gameplay' ][ 'boardHeight' ] = 7
                elseif config[ 'gameplay' ][ 'boardSize' ] == 2 then
                    config[ 'gameplay' ][ 'boardWidth' ] = 11
                    config[ 'gameplay' ][ 'boardHeight' ] = 11
                elseif config[ 'gameplay' ][ 'boardSize' ] == 3 then
                    config[ 'gameplay' ][ 'boardWidth' ] = 19
                    config[ 'gameplay' ][ 'boardHeight' ] = 19
                else
                    unused, config[ 'gameplay' ][ 'boardWidth' ] = imgui.InputInt( "Board Width", config[ 'gameplay' ][ 'boardWidth' ] )
                    unused, config[ 'gameplay' ][ 'boardHeight' ] = imgui.InputInt( "Board Height", config[ 'gameplay' ][ 'boardHeight' ] )
                end
                unused, config[ 'gameplay' ][ 'responseTime' ] = imgui.InputFloat( "API Timeout (seconds)", config[ 'gameplay' ][ 'responseTime' ], 0.1, 0, 1 )
                unused, config[ 'gameplay' ][ 'gameSpeed' ] = imgui.InputFloat( "Game Speed (low = fast)", config[ 'gameplay' ][ 'gameSpeed' ], 0.01, 0, 2 )
                unused, config[ 'gameplay' ][ 'startingPosition' ] = imgui.Combo( "Snake Starting Position", config[ 'gameplay' ][ 'startingPosition' ], { "fixed", "random" }, 2 )
                unused, config[ 'gameplay' ][ 'startingLength' ] = imgui.InputInt( "Snake Starting Length", config[ 'gameplay' ][ 'startingLength' ] )
                unused, config[ 'gameplay' ][ 'healthPerTurn' ] = imgui.InputInt( "Health Lost Per Turn", config[ 'gameplay' ][ 'healthPerTurn' ] )
                unused, config[ 'gameplay' ][ 'foodStrategy' ] = imgui.Combo( "Food Placement Method", config[ 'gameplay' ][ 'foodStrategy' ], { "fixed", "growing_uniform", "growing_dynamic" }, 3 )
                if config[ 'gameplay' ][ 'foodStrategy' ] == 1 then
                    unused, config[ 'gameplay' ][ 'totalFood' ] = imgui.InputInt( "Total Food on Board", config[ 'gameplay' ][ 'totalFood' ] )
                elseif config[ 'gameplay' ][ 'foodStrategy' ] == 2 then
                    unused, config[ 'gameplay' ][ 'addFoodTurns' ] = imgui.InputInt( "Add Food every X turns", config[ 'gameplay' ][ 'addFoodTurns' ] )
                elseif config[ 'gameplay' ][ 'foodStrategy' ] == 3 then
                    unused, config[ 'gameplay' ][ 'addFoodTurns' ] = imgui.InputInt( "Add Food at most X turns", config[ 'gameplay' ][ 'addFoodTurns' ] )
                end
                unused, config[ 'gameplay' ][ 'foodHealth' ] = imgui.InputInt( "Health Restored by Food", config[ 'gameplay' ][ 'foodHealth' ] )
                unused, config[ 'gameplay' ][ 'enableGold' ] = imgui.Checkbox( "Enable Gold", config[ 'gameplay' ][ 'enableGold' ] )
                if config[ 'gameplay' ][ 'enableGold' ] then
                    unused, config[ 'gameplay' ][ 'addGoldTurns' ] = imgui.InputInt( "Add Gold every X turns", config[ 'gameplay' ][ 'addGoldTurns' ] )
                    unused, config[ 'gameplay' ][ 'goldToWin' ] = imgui.InputInt( "Gold to Win", config[ 'gameplay' ][ 'goldToWin' ] )
                end
                unused, config[ 'gameplay' ][ 'enableWalls' ] = imgui.Checkbox( "Enable Walls", config[ 'gameplay' ][ 'enableWalls' ] )
                if config[ 'gameplay' ][ 'enableWalls' ] then
                    unused, config[ 'gameplay' ][ 'addWallTurns' ] = imgui.InputInt( "Add Wall every X turns", config[ 'gameplay' ][ 'addWallTurns' ] )
                    unused, config[ 'gameplay' ][ 'wallTurnStart' ] = imgui.InputInt( "Start Walls at turn X", config[ 'gameplay' ][ 'wallTurnStart' ] )
                end
                unused, config[ 'gameplay' ][ 'enableTaunts' ] = imgui.Checkbox( "Enable Taunts", config[ 'gameplay' ][ 'enableTaunts' ] )
                unused, config[ 'gameplay' ][ 'pinTails' ] = imgui.Checkbox( "Pin Tails", config[ 'gameplay' ][ 'pinTails' ] )
                imgui.Text( "\n" )
            end
            
            -- Robosnake Options
            if imgui.CollapsingHeader( "Redbrick Robosnake (2017)", { "DefaultOpen" } ) then
                unused, config[ 'system' ][ 'roboRecursionDepth' ] = imgui.InputInt( "Recursion Depth", config[ 'system' ][ 'roboRecursionDepth' ] )
                imgui.Text( "\n" )
            end
            
            -- Robosnake 2018 Options
            if imgui.CollapsingHeader( "Son of Robosnake (2018)", { "DefaultOpen" } ) then
                unused, config[ 'robosnake2018' ][ 'recursionDepth' ] = imgui.InputInt( "Recursion Depth ", config[ 'robosnake2018' ][ 'recursionDepth' ] )
                unused, config[ 'robosnake2018' ][ 'hungerThreshold' ] = imgui.InputInt( "Hunger Threshold", config[ 'robosnake2018' ][ 'hungerThreshold' ] )
                unused, config[ 'robosnake2018' ][ 'lowFoodThreshold' ] = imgui.InputInt( "Low Food Threshold", config[ 'robosnake2018' ][ 'lowFoodThreshold' ] )
                imgui.Text( "\n" )
            end
            
            -- System Options
            if imgui.CollapsingHeader( "System", { "DefaultOpen" } ) then
                unused, config[ 'system' ][ 'logLevel' ] = imgui.Combo( "Log Level", config[ 'system' ][ 'logLevel' ], { "trace", "debug", "info", "warn", "error", "fatal" }, 6 )
                unused, config[ 'system' ][ 'enableSanityChecks' ] = imgui.Checkbox( "Enable Sanity Checks", config[ 'system' ][ 'enableSanityChecks' ] )
                unused, config[ 'system' ][ 'pauseNewGames' ] = imgui.Checkbox( "Start New Games Paused", config[ 'system' ][ 'pauseNewGames' ] )
                imgui.Text( "\n" )
            end
            
            -- Save Options button and dialog
            if imgui.Button( "Save Changes" ) then
                local ok = love.filesystem.write( 'config.json', json.encode( config ) )
                if not ok then
                    error( 'Unable to write config.json' )
                end
                configJson = love.filesystem.read( 'config.json' )
                if not configJson then
                    error( 'Unable to read config.json' )
                end
                imgui.OpenPopup( "SaveOptions" )
            end
            if imgui.BeginPopupModal( "SaveOptions", nil, { "NoResize" } ) then
                imgui.Text( "Configuration changes have been saved.\n\n" )
                imgui.Separator()
                if imgui.Button( "OK" ) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
            
            -- Revert Options button and dialog
            imgui.SameLine()
            if imgui.Button( "Revert Changes" ) then
                imgui.OpenPopup( "RevertOptions" )
            end
            if imgui.BeginPopupModal( "RevertOptions", nil, { "NoResize" } ) then
                imgui.Text( "Are you sure you want to revert your changes?\n\n" )
                imgui.Separator()
                if imgui.Button( "OK" ) then
                    config, pos, err = json.decode( configJson, 1, json.null )
                    if not config then
                        error( 'Error parsing config.json: ' .. err )
                    end
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button( "Cancel" ) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
        
        -- Snakes    
        elseif rightPane == 'snakes' then
            
            imgui.Columns( 2, 'snakesInner', false )
            imgui.PushStyleVar( "ItemSpacing", 8, 24 )
            imgui.Text( "" )
            for i = 1, 5 do
                imgui.Image(
                    snakeHeads[i],                                          -- image
                    snakeHeads[i]:getHeight() / snakeHeads[i]:getWidth() * 50,  -- width
                    snakeHeads[i]:getWidth() / snakeHeads[i]:getHeight() * 50   -- height  
                )
                imgui.SameLine()
                local buttonText = "Slot " .. i .. "\n"
                if snakes[i]['type'] == 2 then
                    buttonText = buttonText .. 'human'
                elseif snakes[i]['type'] == 3 then
                    buttonText = buttonText .. "api2017\n" .. snakes[i]['url']
                elseif snakes[i]['type'] == 4 then
                    buttonText = buttonText .. "api2016\n" .. snakes[i]['url']
                elseif snakes[i]['type'] == 5 then
                    buttonText = buttonText .. 'robosnake2017'
                elseif snakes[i]['type'] == 6 then
                    buttonText = buttonText .. "api2018\n" .. snakes[i]['url']
                elseif snakes[i]['type'] == 7 then
                    buttonText = buttonText .. 'robosnake2018'
                elseif snakes[i]['type'] == 8 then
                    buttonText = buttonText .. "api2019\n" .. snakes[i]['url']
                else
                    buttonText = buttonText .. 'empty'
                end
                if imgui.Button( buttonText, 200, 50 ) then
                    imgui.OpenPopup( "EditSnake" .. i )
                end
            end
            imgui.PopStyleVar()
            imgui.NextColumn()
            imgui.PushStyleVar( "ItemSpacing", 8, 24 )
            imgui.Text( "" )
            for i = 6, 10 do
                imgui.Image(
                    snakeHeads[i],                                          -- image
                    snakeHeads[i]:getHeight() / snakeHeads[i]:getWidth() * 50,  -- width
                    snakeHeads[i]:getWidth() / snakeHeads[i]:getHeight() * 50   -- height  
                )
                imgui.SameLine()
                local buttonText = "Slot " .. i .. "\n"
                if snakes[i]['type'] == 2 then
                    buttonText = buttonText .. 'human'
                elseif snakes[i]['type'] == 3 then
                    buttonText = buttonText .. "api2017\n" .. snakes[i]['url']
                elseif snakes[i]['type'] == 4 then
                    buttonText = buttonText .. "api2016\n" .. snakes[i]['url']
                elseif snakes[i]['type'] == 5 then
                    buttonText = buttonText .. 'robosnake2017'
                elseif snakes[i]['type'] == 6 then
                    buttonText = buttonText .. "api2018\n" .. snakes[i]['url']
                elseif snakes[i]['type'] == 7 then
                    buttonText = buttonText .. 'robosnake2018'
                elseif snakes[i]['type'] == 8 then
                    buttonText = buttonText .. "api2019\n" .. snakes[i]['url']
                else
                    buttonText = buttonText .. 'empty'
                end
                if imgui.Button( buttonText, 200, 50 ) then
                    imgui.OpenPopup( "EditSnake" .. i )
                end
            end
            imgui.PopStyleVar()
            imgui.Columns(1)
            
            -- Edit snake trigger
            -- is there a better way to implement this?!?
            -- gui programming is hard
            for i = 1, 10 do
                imgui.SetNextWindowSize(250, 150)
                if imgui.BeginPopupModal( "EditSnake" .. i, nil, { "NoResize" } ) then
                    Menu.EditSnakeDialog(i)
                end
            end

        elseif rightPane == 'credits' then
            if imgui.CollapsingHeader( "About", { "DefaultOpen" } ) then
                imgui.TextWrapped([[
Mojave is a third-party, open-source arena / gameboard for Battlesnake. It supports snakes that use the 2016, 2017, 2018, or 2019 API versions.

Battlesnake is an artificial intelligence programming competition hosted yearly in Victoria, BC, Canada. The tournament is a twist on the classic Snake arcade game, with teams building their own snake AIs to collect food and attack (or avoid) other snakes on the board. The lasts snake slithering wins! More information is available at http://www.battlesnake.io .

As for the name... since rattlesnakes are known to roam the real Mojave desert, it makes sense for battlesnakes to roam the virtual one, no? :)
                ]])
            end
            if imgui.CollapsingHeader( "Rules", { "DefaultOpen" } ) then
                imgui.Text( "General" )
                imgui.BulletText( "All snakes execute their moves simultaneously." )
                imgui.BulletText( "If a snake moves beyond the edge of the arena, it dies." )
                imgui.BulletText( "Dead snakes are removed from the arena." )
                imgui.BulletText( "The last snake alive is the winner of the game..." )
                imgui.BulletText( "...unless playing with gold enabled, see below" )
                imgui.Text( "\nFood and Health" )
                imgui.BulletText( "Snakes start with 100 health." )
                imgui.BulletText( "On each turn, snakes lose 1 health, unless they have eaten food that turn." )
                imgui.BulletText( "If a snake's health reaches 0, it dies." )
                imgui.BulletText([[
If the food placement method is set to "fixed", then food will appear on
the game board at the start of the game, and whenever another piece of
food is consumed.]])
                imgui.BulletText([[
If the food placement method is set to "growing_uniform", then food will
appear on the game board at a random location every X turns.]])
                imgui.BulletText([[
If the food placement method is set to "growing_dynamic", then food will
appear on the game board at a random location at most every X turns.]])
                imgui.BulletText([[
If a snake lands on a food square, it "eats" the food, and its' health will
be restored to 100. It's tail will grow by one square.]])
                imgui.Text( "\nGold" )
                imgui.BulletText( "Snakes start with 0 gold." )
                imgui.BulletText( "Gold will spawn near the center of the game board every X turns." )
                imgui.BulletText([[
The first snake to collect X gold will instantly win the game, regardless
of how many snakes are currently alive.]])
                imgui.Text( "\nWalls" )
                imgui.BulletText( "A wall will spawn on the game board every X turns, starting at turn Y." )
                imgui.BulletText( "Walls will never spawn directly in front of a snake." )
                imgui.BulletText( "If a snake moves into a wall, it dies." )
                imgui.Text( "\nBattles" )
                imgui.BulletText( "If a snake moves into another snake's body, it dies." )
                imgui.BulletText([[
If two snakes move into the same tile simultaneously, the shorter snake
will die. If both snakes are the same size, both snakes die.]])
                imgui.Text( "\n" )
            end
            if imgui.CollapsingHeader( "Credits", { "DefaultOpen" } ) then
                imgui.TextWrapped([[
Battlesnake
Copyright ©2015-2018 Techdrop Labs, Inc. (d/b/a Sendwithus)
Copyright ©2018-2019 Battlesnake Inc.
http://www.battlesnake.io

Bloom Shader
Copyright ©2011 slime
https://love2d.org/forums/viewtopic.php?f=4&t=3733&start=20#p38666

Dear ImGui
Copyright ©2014-2018 Omar Cornut and ImGui contributors
https://github.com/ocornut/imgui

DKJson
Copyright ©2010-2013 David Heiko Kolf
http://dkolf.de/src/dkjson-lua.fsl

Gifload
Copyright ©2016 Pedro Gimeno Fortea
https://github.com/pgimeno/gifload

inspect.lua  
Copyright ©2013 Enrique García Cota  
https://github.com/kikito/inspect.lua

LÖVE
Copyright ©2006-2018 LÖVE Development Team
https://love2d.org

LÖVE-ImGui
Copyright ©2016 slages
https://github.com/slages/love-imgui

Monoton Font
Copyright ©2011 Vernon Adams
http://www.fontspace.com/new-typography/monoton

Music and Sound Effects by Eric Matyas
http://www.soundimage.org

Robosnake  
Copyright ©2017 Redbrick Technologies, Inc.  
https://github.com/rdbrck/bountysnake2017

Son of Robosnake  
Copyright ©2017-2018 Redbrick Technologies, Inc.  
https://github.com/rdbrck/bountysnake2018

Vignette Image
Public Domain
http://hitokageproduction.com/files/stockTextures/vignette2.png
                ]])
            end

        end
        imgui.EndChild()
    end
    imgui.End()

end

function Menu.EditSnakeDialog( snakeNum )
    imgui.Text( "Editing snake in slot " .. snakeNum .. "\n\n" )
    unused, snakes[ snakeNum ][ 'type' ] = imgui.Combo( "Type", snakes[ snakeNum ][ 'type' ], { "empty", "human", "api2017", "api2016", "robosnake2017", "api2018", "robosnake2018", "api2019" }, 8 )
    if snakeNum ~= 1 and snakes[ snakeNum ][ 'type' ] == 2 then
        snakes[ snakeNum ][ 'type' ] = 1
        imgui.OpenPopup( "NoHumanInThisSlot" )
    end
    if imgui.BeginPopupModal( "NoHumanInThisSlot", nil, { "NoResize" } ) then
        imgui.Text( "Only the snake in slot 1 can be controlled by a human player.\n\n" )
        imgui.Separator()
        if imgui.Button( "OK" ) then
            imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
    end
    if snakes[ snakeNum ][ 'type' ] == 3 then
        unused, snakes[ snakeNum ][ 'url' ] = imgui.InputText( "URL", snakes[ snakeNum ][ 'url' ], 256 )
    end
    if snakes[ snakeNum ][ 'type' ] == 4 then
        unused, snakes[ snakeNum ][ 'id' ] = imgui.InputText( "ID", snakes[ snakeNum ][ 'id' ], 37 )
        unused, snakes[ snakeNum ][ 'name' ] = imgui.InputText( "Name", snakes[ snakeNum ][ 'name' ], 256 )
        unused, snakes[ snakeNum ][ 'url' ] = imgui.InputText( "URL", snakes[ snakeNum ][ 'url' ], 256 )
    end
    if snakes[ snakeNum ][ 'type' ] == 6 or snakes[ snakeNum ][ 'type' ] == 8 then
        unused, snakes[ snakeNum ][ 'name' ] = imgui.InputText( "Name", snakes[ snakeNum ][ 'name' ], 256 )
        unused, snakes[ snakeNum ][ 'url' ] = imgui.InputText( "URL", snakes[ snakeNum ][ 'url' ], 256 )
    end
    imgui.Separator()
    if imgui.Button( "Save" ) then
        local ok = love.filesystem.write( 'snakes.json', json.encode( snakes ) )
        if not ok then
            error( 'Unable to write snakes.json' )
        end
        snakesJson = love.filesystem.read( 'snakes.json' )
        if not snakesJson then
            error( 'Unable to read snakes.json' )
        end
        imgui.CloseCurrentPopup()
    end
    imgui.SameLine()
    if imgui.Button( "Cancel" ) then
        snakes, pos, err = json.decode( snakesJson, 1, json.null )
        if not snakes then
            error( 'Error parsing snakes.json: ' .. err )
        end
        imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
end

return Menu