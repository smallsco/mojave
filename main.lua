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
MOJAVE_VERSION = '2.1.1'

-- FIRST RUN LOGIC
-- Extract the imgui shared library from the fused app and save it to appdata
-- This is because we can't load C libraries directly from fused apps
if not love.filesystem.exists( 'imgui' ) then
    if not love.filesystem.createDirectory( 'imgui/OS X' ) then
        error( 'Unable to create imgui OS X directory' )
    end
    if not love.filesystem.createDirectory( 'imgui/Windows' ) then
        error( 'Unable to create imgui Windows directory' )
    end
    if not love.filesystem.createDirectory( 'imgui/Linux' ) then
        error( 'Unable to create imgui Linux directory' )
    end
    file, size = love.filesystem.read( 'thirdparty/imgui/OS X/imgui.so' )
    if not file then
        error( 'Unable to read OSX/imgui.so' )
    end
    local ok, err = love.filesystem.write( '/imgui/OS X/imgui.so', file, size )
    if not ok then
        error( 'Unable to write OSX/imgui.so: ' .. err)
    end
    file, size = love.filesystem.read( 'thirdparty/imgui/Linux/imgui.so' )
    if not file then
        error( 'Unable to read Linux/imgui.so' )
    end
    local ok, err = love.filesystem.write( '/imgui/Linux/imgui.so', file, size )
    if not ok then
        error( 'Unable to write Linux/imgui.so: ' .. err)
    end
    file, size = love.filesystem.read( 'thirdparty/imgui/Windows/imgui.dll' )
    if not file then
        error( 'Unable to read Windows/imgui.dll' )
    end
    local ok, err = love.filesystem.write( '/imgui/Windows/imgui.dll', file, size )
    if not ok then
        error( 'Unable to write Windows/imgui.dll: ' .. err)
    end
end

-- Load imgui module
local cpath = love.filesystem.getSaveDirectory() .. "/imgui/" .. love.system.getOS()
package.cpath = package.cpath .. ";" .. cpath .. "/?.so" .. ";" .. cpath .. "/?.dll"
pcall(function() require "imgui" end)

-- Third-party modules
gifload = require 'thirdparty.gifload'
http = require 'socket.http'
inspect = require 'thirdparty.inspect'
json = require 'thirdparty.dkjson'
ltn12 = require 'ltn12'
o_ten_one = require "thirdparty.o-ten-one"

-- Internal modules
Game = require 'modules.Game'
Map = require 'modules.Map'
Menu = require 'modules.Menu'
Robosnake = require 'robosnake.robosnake'
Shaders = require 'modules.Shaders'
Snake = require 'modules.Snake'
Util = require 'modules.Util'

local SPLASH_DONE = false

function gameLog( msg, level )
    if activeGame then
        activeGame:log( msg, level )
    end
end

--- Application bootstrap function
function love.load()

    -- Global vars
    activeGame = nil
    bgVignette = love.graphics.newImage( 'images/vignette.png' )
    config, configJson = nil
    
    snakeHeads = {
        love.graphics.newImage( 'images/heads/bendr-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/dead-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/fang-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/pixel-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/regular-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/safe-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/sand-worm.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/shades-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/smile-snakehead.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/heads/tongue-snakehead.png', {mipmaps = true} )
    }
    for i = 1, #snakeHeads do
        snakeHeads[i]:setMipmapFilter( 'nearest', 100 )
    end
    snakeTails = {
        love.graphics.newImage( 'images/tails/small-rattle-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/skinny-tail-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/round-bum-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/pointed-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/pixel-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/freckled-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/fat-rattle-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/curled-snaketail.png', {mipmaps = true} ),
        love.graphics.newImage( 'images/tails/block-bum-snaketail.png', {mipmaps = true} )
    }
    snakeTails[10] = snakeTails[1]
    for i = 1, #snakeTails do
        snakeTails[i]:setMipmapFilter( 'nearest', 100 )
    end

    -- Create snakes file if one does not exist
    if not love.filesystem.exists( 'snakes.json' ) then
        local newSnakes = {
            {
                id = '',
                type = 2,  -- 1 = empty, 2 = human, 3 = api2017, 4 = api2016
                name = '',
                url = ''
            }
        }
        for i = 1, 9 do
            table.insert( newSnakes, {
                id = '',
                type = 1,
                name = '',
                url = ''
            })
        end
        local ok = love.filesystem.write( 'snakes.json', json.encode( newSnakes ) )
        if not ok then
            error( 'Unable to write snakes.json' )
        end
    end

    -- Create config file if one does not exist
    if not love.filesystem.exists( 'config.json' ) then
        local newConfig = {
            appearance = {
                tilePrimaryColor = { 0/255, 0/255, 255/255, 255/255 },
                tileSecondaryColor = { 0/255, 0/255, 235/255, 255/255 },
                foodColor = { 0/255, 255/255, 160/255, 234/255 },
                goldColor = { 209/255, 255/255, 123/255, 234/255 },
                wallColor = { 8/255, 16/255, 32/255, 204/255 },
                enableBloom = true,
                fadeOutTails = true,
                enableVignette = true,
                fullscreen = false
            },
            audio = {
                enableMusic = true,
                enableSFX = true
            },
            gameplay = {
                boardHeight = 15,
                boardWidth = 25,
                responseTime = 0.2,
                gameSpeed = 0.15,
                foodStrategy = 1,  -- 1 = fixed, 2 = growing
                totalFood = 4,
                addFoodTurns = 3,
                foodHealth = 100,
                enableGold = false,
                addGoldTurns = 100,
                goldToWin = 5,
                enableWalls = false,
                addWallTurns = 5,
                wallTurnStart = 50,
                enableTaunts = true
            },
            system = {
                logLevel = 3,
                enableSanityChecks = false,
                roboRecursionDepth = 4,
                pauseNewGames = false
            }
        }
        local ok = love.filesystem.write( 'config.json', json.encode( newConfig ) )
        if not ok then
            error( 'Unable to write config.json' )
        end
    end
    
    -- Read snakes file
    snakesJson = love.filesystem.read( 'snakes.json' )
    if not snakesJson then
        error( 'Unable to read snakes.json' )
    end
    snakes, pos, err = json.decode( snakesJson, 1, json.null )
    if not snakes then
        error( 'Error parsing snakes.json: ' .. err )
    end
    if #snakes > 10 then
        error( 'No more than 10 snakes can play in the arena!' )
    end
    if #snakes < 1 then
        error( 'snakes.json must contain at least one snake!' )
    end
    
    -- Read config file
    configJson = love.filesystem.read( 'config.json' )
    if not configJson then
        error( 'Unable to read config.json' )
    end
    config, pos, err = json.decode( configJson, 1, json.null )
    if not config then
        error( 'Error parsing config.json: ' .. err )
    end

    -- Set fullscreen state
    if config[ 'appearance' ][ 'fullscreen' ] ~= love.window.getFullscreen() then
        love.window.setFullscreen( config[ 'appearance' ][ 'fullscreen' ] )
    end
    screenWidth, screenHeight = love.graphics.getDimensions()
    vxScale = love.graphics.getWidth() / bgVignette:getWidth()
    vyScale = love.graphics.getHeight() / bgVignette:getHeight()

    -- Splash Screen
    splash = o_ten_one( { background={ 0, 0, 0 } }) 
    splash.onDone = function()
        SPLASH_DONE = true
    end
    
end

--- Update loop
-- @param dt Delta Time
function love.update( dt )
    if not SPLASH_DONE then
        splash:update( dt )
    else
        if activeGame then
            activeGame:update( dt )
        else
            Menu.update( dt )
        end
    end
    imgui.NewFrame()
end

--- Render loop
function love.draw()
    if not SPLASH_DONE then
        splash:draw()
    elseif activeGame then
        activeGame:draw()
    else
        Menu.draw()
    end
    
    imgui.Render()
    
end

--- Cleanly destroy imgui when the app exits
function love.quit()
    imgui.ShutDown()
end

--- Pass I/O from mouse and keyboard to imgui
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end
function love.keypressed(key)
    splash:skip()
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
        if activeGame then
            activeGame:keypressed( key )
        end
    end
end
function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end
function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end
function love.mousepressed(x, y, button)
    splash:skip()
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end
function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end
function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end