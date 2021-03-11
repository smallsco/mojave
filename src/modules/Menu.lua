local Menu = {}

-- Module variables
local CreditsPane = require 'modules.menu_panes.CreditsPane'
local GamePane = require 'modules.menu_panes.GamePane'
local OptionsPane = require 'modules.menu_panes.OptionsPane'
local SnakesPane = require 'modules.menu_panes.SnakesPane'

local defaultFont = love.graphics.newFont( 12 )
local logoFont = love.graphics.newFont( 'fonts/monoton/Monoton-RXOM.ttf', 144 )
local bgVignette = moonshine( moonshine.effects.vignette )
bgVignette.vignette.radius = 1
bgVignette.vignette.opacity = .7
bgVignette.vignette.softness = .8
local BGM = love.audio.newSource( 'audio/music/Synthwave_C.mp3', 'stream' )
BGM:setLooping( true )

-- This exists solely for the GamePane to stop the BGM upon starting a new game
-- without making the BGM a global variable.
function Menu.stopBGM()
    if BGM:isPlaying() then
        BGM:stop()
    end
end

-- Menu update loop
-- @param dt Delta Time (unused)
function Menu.update( dt )

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

    -- Check fullscreen state
    if config.appearance.fullscreen ~= love.window.getFullscreen() then
        love.window.setFullscreen( config.appearance.fullscreen )
        screenWidth, screenHeight = love.graphics.getDimensions()
        bgVignette.resize(screenWidth, screenHeight)
    end

end

-- Menu render loop
function Menu.draw()

    -- Navy blue BG
    if config.appearance.enableVignette then
        bgVignette( function() love.graphics.clear( 0, 0, 111/255, 1 ) end )
    else
        love.graphics.clear( 0, 0, 111/255, 1 )
    end

    -- Logo text
    love.graphics.setColor( 1, 96/255, 222/255, 204/255 )
    love.graphics.setFont( logoFont )
    love.graphics.printf( "Mojave", 0, 0, screenWidth, "center" )
    love.graphics.setColor( 1, 1, 1, 1 )

    -- Footer text
    love.graphics.setFont( defaultFont )
    love.graphics.printf( "©2017-2021 Scott Small and contributors", 0, screenHeight*0.95, screenWidth, "center" )
    love.graphics.print( Utils.MOJAVE_VERSION, screenWidth*0.970, screenHeight*0.970 )
    
    -- Render Main Menu
    imgui.SetNextWindowSize(
        screenWidth - ( screenWidth * 0.1 ),    -- 90% of screen width
        screenHeight - ( screenHeight * 0.4 )   -- 60% of screen height
    )
    imgui.SetNextWindowPos(
        screenWidth - ( screenWidth * 0.95 ),
        screenHeight - ( screenHeight * 0.675 )
    )
    if imgui.Begin( "Menu", nil, { "NoResize", "NoCollapse", "NoTitleBar" } ) then

        -- Left Pane
        imgui.BeginChild( "Sub1", imgui.GetWindowContentRegionWidth() * 0.5, 0 )

            imgui.PushStyleVar( "ItemSpacing", 8, 24 )
            local buttonWidth = 200
            local buttonHeight = 50
            local buttonX = ( imgui.GetWindowWidth() * 0.5 ) - ( buttonWidth / 2 )
            imgui.Text( "" )
            imgui.Text( "" )
            imgui.SameLine( buttonX )
            if imgui.Button( "Create Game", buttonWidth, buttonHeight ) then
                rightPane = "game"
            end
            imgui.Text( "" )
            imgui.SameLine( buttonX )
            if imgui.Button( "Manage Snakes", buttonWidth, buttonHeight ) then
                rightPane = "snakes"
            end
            imgui.Text( "" )
            imgui.SameLine( buttonX )
            if imgui.Button( "Options", buttonWidth, buttonHeight ) then
                rightPane = "options"
            end
            imgui.Text( "" )
            imgui.SameLine( buttonX )
            if imgui.Button( "Rules / Credits", buttonWidth, buttonHeight ) then
                rightPane = "credits"
            end
            imgui.Text( "" )
            imgui.SameLine( buttonX )
            if imgui.Button( "Exit", buttonWidth, buttonHeight ) then
                imgui.OpenPopup( "Exit" )
            end
            imgui.PopStyleVar()

            -- Exit Confirmation Dialog
            if imgui.BeginPopupModal( "Exit", nil, { "NoResize" } ) then
                imgui.Text( "Are you sure you want to exit the game?\n\n" )
                imgui.Separator()
                imgui.PushStyleVar( "ItemSpacing", 8, 24 )
                if imgui.Button( "OK", 150, 20 ) then
                    love.event.quit()
                end
                imgui.SameLine()
                if imgui.Button( "Cancel", 150, 20 ) then
                    imgui.CloseCurrentPopup()
                end
                imgui.PopStyleVar()
                imgui.EndPopup()
            end

        imgui.EndChild()
        
        -- Right Pane
        imgui.SameLine()
        imgui.BeginChild( "Sub2", imgui.GetWindowContentRegionWidth() * 0.5, 0)

            -- New Game Setup
            if rightPane == 'game' then
                GamePane.draw()

            -- Options
            elseif rightPane == 'options' then
                OptionsPane.draw()

            -- Add/Edit Snakes
            elseif rightPane == 'snakes' then
                SnakesPane.draw()

            -- Credits
            elseif rightPane == 'credits' then
                CreditsPane.draw()

            end

        imgui.EndChild()
        imgui.End()
    end

end

return Menu
