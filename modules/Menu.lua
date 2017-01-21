local Menu = {}

local bigFont = love.graphics.newFont(36)
local medFont = love.graphics.newFont(24)
local audioCheckbox = {
    checked = true,
    text = 'Play Audio'
}

--- Menu update loop
-- @param dt Delta Time (unused)
function Menu.update( dt )
    
    suit.layout:reset(100,50)

    suit.Label("Mojave", {font=bigFont}, suit.layout:row(200,30))
    suit.Label("a battle snake arena", suit.layout:row())

    suit.layout:row()

    if suit.Button("New Game (Classic)", suit.layout:row()).hit then
        local gameOptions = {
            snakes = snakesJson,
            mode = 'classic'
        }
        activeGame = Game(gameOptions)
        activeGame:start()
    end
    
    suit.layout:row()
    
    if suit.Button("New Game (Advanced)", suit.layout:row()).hit then
        local gameOptions = {
            snakes = snakesJson,
            mode = 'advanced'
        }
        activeGame = Game(gameOptions)
        activeGame:start()
    end
    
    suit.layout:row()
    
    suit.Checkbox(audioCheckbox, suit.layout:row())
    if audioCheckbox.checked then
        PLAY_AUDIO = true
    else
        PLAY_AUDIO = false
    end
    
    suit.layout:row()

    if suit.Button("Exit", suit.layout:row()).hit then
        love.event.quit()
    end
    
    suit.layout:reset(400,50)
    
    suit.Label("Battle Snakes", {font=medFont}, suit.layout:row(200,30))
    suit.layout:row()
    for i = 1, #snakesJson do
        suit.Label(snakesJson[i]['name'], suit.layout:row())
        suit.Label(snakesJson[i]['url'], suit.layout:row())
        suit.layout:row()
    end
    
end

return Menu