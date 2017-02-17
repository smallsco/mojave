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
local api2017Checkbox = {
    checked = false,
    text = 'Use 2017 API Calls'
}
local food2017Checkbox = {
    checked = false,
    text = 'Use 2017 Food Behavior'
}
local height = {text = "21"}
local width = {text = "31"}
local maxFood = {text = "4"}

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
            mode = 'classic',
            height = tonumber(height.text),
            width = tonumber(width.text),
            api = 2016,
            foodRules = 2016,
            food_max = tonumber(maxFood.text)
        }
        if api2017Checkbox.checked then
            gameOptions['api'] = 2017
        end
        if food2017Checkbox.checked then
            gameOptions['foodRules'] = 2017
        end
        activeGame = Game(gameOptions)
        activeGame:start()
    end
    
    suit.layout:row()
    
    if not api2017Checkbox.checked then
        if suit.Button( "New Game (Advanced)", suit.layout:row() ).hit then
            local gameOptions = {
                snakes = snakesJson,
                mode = 'advanced',
                height = tonumber(height.text),
                width = tonumber(width.text),
                api = 2016,
                foodRules = 2016,
                food_max = tonumber(maxFood.text)
            }
            if api2017Checkbox.checked then
                gameOptions['api'] = 2017
            end
            if food2017Checkbox.checked then
                gameOptions['foodRules'] = 2017
            end
            activeGame = Game( gameOptions )
            activeGame:start()
        end
    end
    
    suit.layout:reset( 100, 230 )
    suit.layout:row( 200, 30 )
    
    suit.Label("Height", suit.layout:row(50,30))
    suit.Input(height, suit.layout:col())
    suit.Label("Width", suit.layout:col())
    suit.Input(width, suit.layout:col())
    
    suit.layout:reset( 100, 280 )
    suit.layout:row( 200, 30 )
    
    suit.Checkbox( audioCheckbox, suit.layout:row() )
    if audioCheckbox.checked then
        PLAY_AUDIO = true
    else
        PLAY_AUDIO = false
    end
    
    suit.Checkbox( fullscreenCheckbox, suit.layout:row() )
    checkfullscreen( fullscreenCheckbox.checked )
    
    suit.Checkbox( api2017Checkbox, suit.layout:row() )
    suit.Checkbox( food2017Checkbox, suit.layout:row() )
    
    if food2017Checkbox.checked then
        suit.Label("Food Limit", suit.layout:row(70,30))
        suit.Input(maxFood, suit.layout:col(50,30))
    end
    
    suit.layout:reset( 100, 450 )
    suit.layout:row( 200, 30 )

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