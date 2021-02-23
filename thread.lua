-- LOVE Modules
require 'love.math'
require 'love.system'
require 'love.timer'

-- Third-Party Modules
json = require 'thirdparty.dkjson'
curl = require "thirdparty.libcurl.libcurl"

-- Internal Modules
Utils = require 'modules.Utils'
Snake = require 'modules.Snake'
StandardRules = require 'modules.rules.StandardRules'
RoyaleRules = require 'modules.rules.RoyaleRules'
SoloRules = require 'modules.rules.SoloRules'
SquadRules = require 'modules.rules.SquadRules'
ConstrictorRules = require 'modules.rules.ConstrictorRules'
RobosnakeMkIII = require 'robosnake-mk-iii.robosnake'
GameThread = require 'modules.GameThread'

-- Init Config
config = Utils.get_or_create_config()
snakeHeads, snakeTails = Utils.load_heads_and_tails(true)

-- Instantiate GameThread
local opt = ...
local game_thread = GameThread(opt)

-- Play the game until it's time to exit
while true do
    local isExit = game_thread:handleCommand()
    if isExit then
        return
    end
    game_thread:tick()
end
