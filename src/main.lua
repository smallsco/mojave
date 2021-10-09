--[[
       __                  ___ 
 |\/| /  \    |  /\  \  / |__  
 |  | \__/ \__/ /~~\  \/  |___ 
                               
-------------------------------

a pretty battlesnake board

@author Scott Small <smallsco@gmail.com>
@license GPL

]]

-- Global Variables
activeGame = nil
config = nil
snakes = nil
screenWidth, screenHeight = nil
snakeHeads, snakeTails = nil
rightPane = nil
Utils = nil
Board = nil
Game = nil
Menu = nil
Shaders = nil
Snake = nil
curl = nil
json = nil
moonshine = nil

-- Module Variables
local min_dt = 0
local next_time = 0
local splash
local splash_done = false

-- Application bootstrap function
function love.load()

    -- FPS Limiter
    min_dt = 1/60
    next_time = love.timer.getTime()

    -- Internal Modules Pt. 1
    Utils = require 'modules.Utils'

    -- Third-party shared libraries
    if love.system.getOS() ~= "Linux" then
        if not Utils.check_shared_library("libcurl") then
            Utils.extract_shared_library("libcurl", "libcurl")
        end
    end
    local curl_loaded, _ = pcall(function() curl = require "thirdparty.libcurl.libcurl" end)
    if not curl_loaded then
        Utils.shared_library_error("libcurl")
    end
    if not Utils.check_shared_library("imgui") then
        -- for windows: https://go.microsoft.com/fwlink/?LinkId=746572
        Utils.extract_shared_library("imgui", "imgui")
    end
    local imgui_loaded, _ = pcall(function() require "imgui" end)  -- injects an "imgui" global var
    if not imgui_loaded then
        Utils.shared_library_error("ImGui")
    end

    -- Third-party Lua modules
    json = require 'thirdparty.dkjson'
    moonshine = require 'thirdparty.moonshine'
    local o_ten_one = require "thirdparty.o-ten-one"

    -- Internal Modules Pt.2
    Board = require 'modules.Board'
    Game = require 'modules.Game'
    GameThread = require 'modules.GameThread'
    Shaders = require 'modules.Shaders'
    Snake = require 'modules.Snake'
    Menu = require 'modules.Menu'

    -- Init config
    config = Utils.get_or_create_config()
    snakes = Utils.get_or_create_snakes()

    -- Set default menu pane
    rightPane = 'game'
    if not next(snakes) then
        rightPane = 'snakes'
    end

    -- Enter fullscreen if requested to
    if config.appearance.fullscreen ~= love.window.getFullscreen() then
        love.window.setFullscreen( config.appearance.fullscreen )
    end
    screenWidth, screenHeight = love.graphics.getDimensions()

    -- Load snake head and tail images
    snakeHeads, snakeTails = Utils.load_heads_and_tails()

    -- Display Splash Screen
    splash = o_ten_one({ background={ 0, 0, 0 } }) 
    splash.onDone = function()
        splash_done = true
        splash = nil
        collectgarbage()
    end

end

-- Update loop
-- @param dt Delta Time
function love.update( dt )

    -- FPS limiter timer
    next_time = next_time + min_dt

    if not splash_done then
        splash:update( dt )
    elseif activeGame then
        activeGame:update( dt )
    else
        Menu.update( dt )
    end
    imgui.NewFrame()
end

-- Render loop
function love.draw()
    if not splash_done then
        splash:draw()
    else
        if activeGame then
            activeGame:draw()
        else
            Menu.draw()
        end

        love.graphics.setColor( 1, 1, 1, 1 )
    end

    -- Render imgui
    imgui.Render()
    
    -- FPS limiter logic
    -- https://love2d.org/forums/viewtopic.php?t=82831#p203027
    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep( next_time - cur_time )
end

function love.resize(width, height)
    screenWidth = width
    screenHeight = height
    if activeGame then
        activeGame:resize(width, height)
    end
    Menu.resize(width, height)
end

function love.quit()
    -- Cleanly destroy imgui when the app exits
    if imgui then
        imgui.ShutDown()
    end
end

-- Pass I/O from mouse and keyboard to imgui
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end
function love.keypressed(key)
    if not splash_done then
        splash:skip()
    end
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then

        -- Keys used during both the menu and the game
        if key == 'f4' then
            if config.audio.enableMusic or config.audio.enableSFX then
                config.audio.enableMusic = false
                config.audio.enableSFX = false
            else
                config.audio.enableMusic = true
                config.audio.enableSFX = true
            end
        elseif key == 'f5' then
            local fullscreen = not love.window.getFullscreen()
            config.appearance.fullscreen = fullscreen
            love.window.setFullscreen( fullscreen )
            love.resize(love.graphics.getDimensions())
        end

        -- Keys used in-game only (i.e. human player controls)
        if activeGame then
            activeGame:keypressed(key)
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
    if not splash_done then
        splash:skip()
    end
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
