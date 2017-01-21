--[[
       __                  ___ 
 |\/| /  \    |  /\  \  / |__  
 |  | \__/ \__/ /~~\  \/  |___ 
                               
-------------------------------

a battle snake arena

@author Scott Small <smallsco@gmail.com>
@license MIT

]]


-- Third-party modules
http = require 'socket.http'
json = require 'thirdparty.dkjson'
log = require 'thirdparty.log.log'
ltn12 = require 'ltn12'
suit = require 'thirdparty.suit'

-- Internal modules
Game = require 'modules.Game'
Map = require 'modules.Map'
Menu = require 'modules.Menu'
Snake = require 'modules.Snake'


function love.load()

    love.window.setTitle('Mojave')

    -- Global vars
    PLAY_AUDIO = true
    snakesJson = nil
    activeGame = nil

    -- Audio
    SFXSnakeFood = love.audio.newSource('PowerUp5.mp3', 'static')
    SFXSnakeGold = love.audio.newSource('Bells6.mp3', 'static')
    SFXSnakeDeath = love.audio.newSource('PowerDown1.mp3', 'static')
    BGM = love.audio.newSource("Trashy-Aliens.mp3")
    BGM:setLooping( true )
    
    -- Debug logging
    -- set to 'debug' or 'trace' if you really like logspam (and lag)
    log.level = 'info'
    
    local pos, err
    snakesJson = love.filesystem.read( 'snakes.json' )
    snakesJson, pos, err = json.decode( snakesJson )
    if not snakesJson then
        log.error(err)
        error(err)
    end
    
end

function love.update( dt )
    if activeGame then
        activeGame:update( dt )
    else
        Menu.update( dt )
    end
end

function love.draw()
    if activeGame then
        activeGame:draw()
    end
    suit.draw()
end

-- For debugging - let the keyboard control snake #1
function love.keypressed( key )
    if activeGame then
        activeGame:keypressed( key )
    end
end