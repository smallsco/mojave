-- Third-party modules
http = require 'socket.http'
json = require 'thirdparty.dkjson'
log = require 'thirdparty.log.log'
ltn12 = require 'ltn12'

-- Internal modules
Game = require 'modules.Game'
Map = require 'modules.Map'
Snake = require 'modules.Snake'

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
    SFXSnakeFood = love.audio.newSource('PowerUp5.mp3', 'static')
    SFXSnakeGold = love.audio.newSource('Bells6.mp3', 'static')
    SFXSnakeDeath = love.audio.newSource('PowerDown1.mp3', 'static')
    BGM = love.audio.newSource("Trashy-Aliens.mp3")
    BGM:setLooping( true )

    local options = {
        snakes = {
            --[[{
                id = '',
                name = 'human',
                url = ''
            },]]
            {
                id = '97d0f99f-8bff-4d53-9e65-9f4d25cc6527',
                name = 'snake1',
                url = 'http://localhost:5000'
            },
            {
                id = 'f729b53e-3477-447d-b07e-c79d7e326c82',
                name = 'snake2',
                url = 'http://localhost:5001'
            },
            {
                id = 'ae68ef2a-2fc7-47a0-8b6b-cc7ae5b80d66',
                name = 'snake3',
                url = 'http://localhost:5002'
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