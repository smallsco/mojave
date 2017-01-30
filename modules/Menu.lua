local Menu = {}

local bigFont = love.graphics.newFont(36)
local medFont = love.graphics.newFont(24)
local audioCheckbox = {
    checked = true,
    text = 'Play Audio'
}
local fullscreenCheckbox = {
    checked = false,
    text = 'Fullscreen'
}

--- Check if the game's fullscreen status is what was requested by the user
-- @param requestedState The requested state of fullscreen mode, true or false
local function checkfullscreen( requestedState )
    if requestedState ~= love.window.getFullscreen() then
        log.trace('set fullscreen to ' .. tostring(requestedState))
        love.window.setFullscreen( requestedState )
    end
end

--- Menu update loop
-- @param dt Delta Time (unused)
function Menu.update( dt )
    
    suit.layout:reset( 100, 50 )

    suit.Label( "Mojave", {font=bigFont}, suit.layout:row( 200, 30 ) )
    suit.Label( "a battle snake arena", suit.layout:row() )

    suit.layout:row()

    if suit.Button( "New Game (Classic)", suit.layout:row() ).hit then
        local gameOptions = {
            snakes = snakesJson,
            mode = 'classic'
        }
        activeGame = Game(gameOptions)
        activeGame:start()
    end
    
    suit.layout:row()
    
    if suit.Button( "New Game (Advanced)", suit.layout:row() ).hit then
        local gameOptions = {
            snakes = snakesJson,
            mode = 'advanced'
        }
        activeGame = Game( gameOptions )
        activeGame:start()
    end
    
    suit.layout:row()
    
    suit.Checkbox( audioCheckbox, suit.layout:row() )
    if audioCheckbox.checked then
        PLAY_AUDIO = true
    else
        PLAY_AUDIO = false
    end
    
    suit.Checkbox( fullscreenCheckbox, suit.layout:row() )
    checkfullscreen( fullscreenCheckbox.checked )
    
    suit.layout:row()

    if suit.Button( "Exit", suit.layout:row() ).hit then
        love.event.quit()
    end
    
    suit.layout:reset( 500, 50 )
    
    suit.Label( "Snakes in Match", {font=medFont}, suit.layout:row( 200, 30 ) )
    suit.layout:row()
    for i = 1, #snakesJson do
        suit.Label( snakesJson[i]['name'], suit.layout:row( 200, 20 ) )
        suit.Label( snakesJson[i]['url'], suit.layout:row() )
        suit.layout:row()
    end
    
    suit.layout:reset( 100, 525 )
    suit.Label( "©2017 Scott Small", suit.layout:row( 600, 20 ) )
    suit.Label( "Music and Sound Effects by Eric Matyas - www.soundimage.org", suit.layout:row() )
    suit.Label( "Made with LÖVE - www.love2d.org", suit.layout:row() )
    
    suit.layout:reset( 750, 575 )
    suit.Label( MOJAVE_VERSION, suit.layout:row( 50, 20 ) )
    
end

return Menu