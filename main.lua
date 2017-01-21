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

-- Internal modules
Game = require 'modules.Game'
Map = require 'modules.Map'
Snake = require 'modules.Snake'

PLAY_AUDIO = true

-- Convert an x,y coordinate pair between 0 and 1 indexing
function convert_coordinates(tbl, direction)
    if next(tbl) == nil then
        return {}
    end
    local newtbl = {}
    if type(tbl[1]) == 'table' then
        for i = 1, #tbl do
            newtbl[i] = convert_coordinates(tbl[i], direction)
        end
    else
        if direction == 'topython' then
            newtbl = {
                tbl[1] - 1,     -- x coordinate
                tbl[2] - 1      -- y coordinate
            }
        elseif direction == 'tolua' then
            newtbl = {
                tbl[1] + 1,     -- x coordinate
                tbl[2] + 1      -- y coordinate
            }
        end
    end
    return newtbl
end

function love.load()

    love.window.setTitle('Mojave')

    -- Audio
    if PLAY_AUDIO then
        SFXSnakeFood = love.audio.newSource('PowerUp5.mp3', 'static')
        SFXSnakeGold = love.audio.newSource('Bells6.mp3', 'static')
        SFXSnakeDeath = love.audio.newSource('PowerDown1.mp3', 'static')
        BGM = love.audio.newSource("Trashy-Aliens.mp3")
        BGM:setLooping( true )
    end
    
    -- Debug logging
    -- set to 'debug' or 'trace' if you really like logspam (and lag)
    log.level = 'info'

    local options = {
        snakes = {
            --[[{
                id = '',
                name = 'human',
                url = ''
            },]]
            {
                id = '3d2f2b54-6c65-402f-b1ea-75b72d2ccbfb',
                name = 'moxuz/Python-Battlesnake-AI',
                url = 'http://localhost:5001'
            },
            --[[{
                id = 'ae68ef2a-2fc7-47a0-8b6b-cc7ae5b80d66',
                name = 'zevisert/battlesnake2016',
                url = 'http://localhost:5002'
            },]]
            --[[{
                id = '039b3cce-ce9e-4263-b568-9dadf9cf6ee5',
                name = 'The Mutaneers', -- omnistegan/battlesnake_advanced
                url = 'http://localhost:5003'
            },]]
            --[[{
                id = 'd1ed0f87-8a13-445f-a9ed-b7064f7858e0',
                name = 'mitchellri/snakes_on_a_biplane',
                url = 'http://localhost:5004'
            },]]
            --[[{
                id = '6a139a77-4cfd-4614-b11f-3e7c90f460b4',
                name = 'redbrickmedia/rbm-bountysnake',
                url = 'http://localhost:5000'
            },]]
            {
                id = 'robosnake',
                name = 'Redbrick Robosnake',
                url = 'http://35.166.230.246'
            }
        }
    }
    game = Game(options)
    game:start()
    
end

function love.update( dt )
    game:update( dt )    
end

function love.draw()
    game:draw()
end

-- For debugging - let the keyboard control snake #1
function love.keypressed( key )
    game:keypressed( key )
end