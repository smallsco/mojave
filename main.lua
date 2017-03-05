--[[
       __                  ___ 
 |\/| /  \    |  /\  \  / |__  
 |  | \__/ \__/ /~~\  \/  |___ 
                               
-------------------------------

a battle snake arena

@author Scott Small <smallsco@gmail.com>
@license MIT

]]

-- Version constant
MOJAVE_VERSION = '1.0'

-- Third-party modules
http = require 'socket.http'
json = require 'thirdparty.dkjson'
log = require 'thirdparty.log.log'
ltn12 = require 'ltn12'
suit = require 'thirdparty.SUIT'

-- Internal modules
Game = require 'modules.Game'
Map = require 'modules.Map'
Menu = require 'modules.Menu'
Snake = require 'modules.Snake'


--- Application bootstrap function
function love.load()

    -- Global vars
    PLAY_AUDIO = true
    snakesJson = nil
    activeGame = nil

    -- Audio
    SFXSnakeFood = love.audio.newSource('audio/PowerUp5.mp3', 'static')
    SFXSnakeGold = love.audio.newSource('audio/Bells6.mp3', 'static')
    SFXSnakeDeath = love.audio.newSource('audio/PowerDown1.mp3', 'static')
    BGM = love.audio.newSource("audio/Trashy-Aliens.mp3")
    BGM:setLooping( true )
    
    -- Debug logging
    -- set to 'debug' or 'trace' if you really like logspam (and lag)
    log.level = 'info'
    
    -- Load list of snakes from snakes.json
    local pos, err
    if not love.filesystem.exists( 'snakes.json' ) then
        log.warn( 'Unable to locate snakes.json, creating a new one' )
        local snakes = {
            {
                id = '',
                name = 'Human',
                url = ''
            }
        }
        local ok = love.filesystem.write( 'snakes.json', json.encode(snakes) )
        if not ok then
            error( 'Unable to write snakes.json' )
        end
    end
    snakesJson = love.filesystem.read( 'snakes.json' )
    if not snakesJson then
        error( 'Unable to read snakes.json' )
    end
    snakesJson, pos, err = json.decode( snakesJson )
    if not snakesJson then
        error('Error parsing snakes.json: ' .. err)
    end
    if #snakesJson > 12 then
        error('No more than 12 snakes can play in the arena!')
    end
    if #snakesJson < 1 then
        error('snakes.json must contain at least one snake!')
    end
    
end

--- Update loop
-- @param dt Delta Time
function love.update( dt )
    if activeGame then
        activeGame:update( dt )
    else
        Menu.update( dt )
    end
end

--- Render loop
function love.draw()
    if activeGame then
        activeGame:draw()
    end
    suit.draw()
end

--- Keypress Event Handler
function love.keypressed( key )
    if activeGame then
        activeGame:keypressed( key )
    end
    suit.keypressed( key )
end

--- Forward text input to SUIT
function love.textinput( t )
    suit.textinput( t )
end