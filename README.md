# Mojave

Mojave is a third-party, open-source arena / gameboard for [Battlesnake](https://www.battlesnake.io/). It supports snakes that use the [2016](http://web.archive.org/web/20160817172025/http://www.battlesnake.io/readme), [2017](https://stembolthq.github.io/battle_snake/), [2018](https://github.com/sendwithus/battlesnake-server#api-webhooks) or [2019](http://docs.battlesnake.io/snake-api.html) API versions.

Battlesnake is an artificial intelligence programming competition hosted yearly in Victoria, BC, Canada. The tournament is a twist on the classic Snake arcade game, with teams building their own snake AIs to collect food and attack (or avoid) other snakes on the board. The lasts snake slithering wins! More information is available at http://www.battlesnake.io .

As for the name... since rattlesnakes are known to roam the real Mojave desert, it makes sense for battlesnakes to roam the virtual one, no? :)

![Gameplay Screenshot](mojave.png?raw=true)

## Download

The latest binaries for Windows and Mac OS X can be downloaded from [the Releases link](https://github.com/smallsco/mojave/releases) above.

Linux is officially untested and unsupported, however Linux users may be able to run the game using [LÖVE](http://www.love2d.org) (see below).

## Building

Install [love-release](https://github.com/MisterDA/love-release), then run `love-release -W32 -M` from the `mojave` directory. This will create a new folder, `releases`, containing zipped binaries for Windows and Mac OS X.

Or, you can run the game directly using [LÖVE](http://www.love2d.org). Download and install **version 0.10.2 (Mojave is not compatible with version 11 or greater at this time)**, navigate to the `mojave` directory, and run `love --fused .`. The `--fused` parameter is important, without it the game's data directory path will not be set correctly.

## Adding/Removing Snakes

When launching the application you will be presented with a menu screen, showing ten slots in which a snake can be loaded. Clicking on one of the slots will bring up a dialog box that allows you to load a snake.

Setting the snake type to `human` (slot #1 only) will let the arena operator (you) control a snake directly. This snake will appear white on the game board and it can be controlled using the arrow keys.

Setting the snake type to `api2019` will use the 2019 API for communicating with the snake in this slot. You will need to specify the snake's name and endpoint URL.

Setting the snake type to `api2018` will use the 2018 API for communicating with the snake in this slot. You will need to specify the snake's name and endpoint URL.

Setting the snake type to `api2017` will use the 2017 API for communicating with the snake in this slot. Only the snake's endpoint URL is required, as Mojave will load the snake's name from an endpoint call at the start of a new game.

Setting the sname type to `api2016` will use the 2016 API for communicating with the snake in this slot. In addition to the snake's URL, you will have to manually specify the name and ID of the snake.

(On the official 2016 game server, the ID is generated when a snake is registered with the server, and remains the same for all games. Most snakes hard-code this ID into their application code and use it to identify themselves in the list of snakes sent by the server on each request. For this reason, when using a 2016-API snake with Mojave, you will need to look through the snake's source code, find its' ID, and specify it when adding the snake.)

Finally, setting the snake type to `robosnake2017`, `robosnake2018`, or `robosnake2019` will place a built-in copy of Robosnake [2017](http://github.com/rdbrck/bountysnake2017), [2018](http://github.com/rdbrck/bountysnake2018), or [2019](http://github.com/smallsco/robosnake) into that slot, without requiring you to set up your own server or even have an internet connection. But be warned - these snakes are very difficult!


## Configuration

### Appearance
* Tile Primary Color / Tile Secondary Color
	* This changes the color of background tiles on the game board.
* Food Color
	* This changes the color of food tiles on the game board.
* Gold Color
	* This changes the color of gold tiles on the game board.
* Wall Color
	* This changes the color of wall tiles on the game board.
* Fullscreen
	* This toggles full-screen mode.
* Bloom Filter
	* This enables a [bloom filter](https://en.wikipedia.org/wiki/Bloom_(shader_effect)), which brightens and blurs snakes at the cost of performance.
* Vignette
	* This enables a [vignette](https://en.wikipedia.org/wiki/Vignette_(graphic_design)), which shades the background at the cost of performance.
* Fade Out Tails
	* This fades out snake tails rather than have every square of the snake be opaque. Looks nice and doesn't affect performance, but can make it hard to tell living and dead snakes apart.

### Audio
* Enable Music
	* When enabled, plays background music on the menu and during the game.
* Enable SFX
	* When enabled, plays sound effects when snakes collect food/gold or die.

### Gameplay
* Board Size
	* Select from a small (7x7), medium (11x11), large (19x19), or custom-sized game board.
* Board Width / Board Height
	* If using a custom-sized game board, allows you to customize the dimensions.
* Response Time
	* How long in seconds to wait for each snake's API to respond to the move request.
* Game Speed
	* How long in seconds to wait between each tick of the game loop.
* Snake Starting Position
	* If "random", all snakes are placed on the board randomly. If "fixed", the first 8 snakes will be placed around the edge of the board in the slots defined in the 2019 tournament rules.
* Snake Starting Length
	* How long snakes will grow to at the start of the game.
* Health Lost Per Turn
	* How much health snakes will lose on each turn (if they don't eat that turn).
* Food Placement Strategy
	* If "fixed", the amount of food in play is fixed to a specific number.
	* If "growing_uniform", food will be placed at **specific** time intervals irregardless of how much food is already in play.
	* If "growing_dynamic", food will be placed at **variable** time intervals irregardless of how much food is already in play.
* Total Food on Board
	* For the "fixed" food placement strategy, the amount of food to keep in play at all times.
* Add food every X turns
	* For the "growing_uniform" food placement strategy, after how many turns **exactly** to place one or more new food squares.
* Add food at most X turns
	* For the "growing_dynamic" food placement strategy, after how many turns **at most** to place one or more new food squares.
* Add fixed food amount
    * For growing food placement strategies, if selected, a fixed amount of food will be placed after the requisite amount of turns.
* Number of Food to add
    * For growing food placement strategies when "Add fixed food amount" is selected - this is the amount of food that will be placed on the board.
* Add food equal to half the snakes left in play
    * For growing food placement strategies, if selected, the amount of food that will be placed after the requisite amount of turns will be equal to half the number of living snakes on the board (rounded up).
* Health Restored by Food
	* How much health will be given to a snake that collects food. The official 2017/2018/2019 game boards use 100 for this value and the official 2016 game board uses 30.
* Enable Gold
	* Causes gold to be in play.
* Add gold every X turns
	* After how many turns to place a new gold square (if one does not already exist on the board).
* Gold to Win
	* How much gold a snake has to collect in order to win the game.
* Enable Walls
	* Causes walls to be in play.
* Add wall every X turns
	* After how many turns to place a new wall square.
* Start Walls at turn X
	* Walls will not be placed in the game until the turn specified here.
* Enable Taunts
	* Will print snake taunts to the log.
* Pin Tails
   * Makes snakes grow on every turn (like a Tron game).

### Robosnake (2017)
* Recursion Depth
	* How many turns Robo is allowed to predict ahead. Higher numbers make for a much tougher opponent, but will slow the game down.

### Son of Robosnake (2018)
* Recursion Depth
	* How many turns Robo is allowed to predict ahead. Higher numbers make for a much tougher opponent, but will slow the game down.
* Hunger Threshold
   * When Robo's health dips to this value (or below) it will start looking for food.
* Low Food Threshold
   * If the food on the game board is at this number or lower, Robo will use a less aggressive heuristic and prioritize food.

### Robosnake Mk. III (2019)
* Max Aggression Snakes
	* The maximum number of snakes that can be on the board for Robo to be aggressive. If there are more than this many living snakes in play, Robo will become passive and only target food.
* Recursion Depth
	* How many turns Robo is allowed to predict ahead. Higher numbers make for a much tougher opponent, but will slow the game down.
* Hunger Threshold
   * When Robo's health dips to this value (or below) it will start looking for food.
* Low Food Threshold
   * If the food on the game board is at this number or lower, Robo will use a less aggressive heuristic and prioritize food.

### System
* Log Level
	* How much in-game logging to use. Increasing this will significantly reduce performance.
* Enable Sanity Checks
	* Adds additional checks during each tick of the game loop to verify that the game state is consistent. Enabling this will significantly reduce performance, and should only be used when troubleshooting bugs in Mojave itself.
* Start New Games Paused
	* When enabled, new games will be started in a paused state, which can be useful for debugging.

## Rules

* All snakes execute their moves simultaneously.
* If a snake moves beyond the edge of the arena, it dies.
* Dead snakes are removed from the arena.
* The last snake alive is the winner of the game...
	* ...unless playing with gold enabled, see below

### Food and Health
* Snakes start with 100 health.
* On each turn, snakes lose 1 health, unless they have eaten food that turn.
* If a snake's health reaches 0, it dies.
* If the food placement method is set to "fixed", then food will appear on the game board at the start of the game, and whenever another piece of food is consumed. If the food placement method is set to "growing_uniform", then food will appear on the game board at a random location every 3 turns. If the food placement method is set to "growing_dynamic", then food will appear on the game board at a random location _at most_ every 15 turns.
* If a snake lands on a food square, it "eats" the food, and its' health will be restored to 100. It's tail will grow by one square.

### Gold (supported by 2016 API snakes only)
* Snakes start with 0 gold.
* Gold will spawn on the game board at a random location every 100 turns.
* The first snake to collect 5 gold will instantly win the game, regardless of how many snakes are currently alive.

### Walls (supported by 2016 API snakes only)
* A wall will spawn on the game board every 5 turns, starting at turn 50.
* Walls will never spawn directly in front of a snake.
* If a snake moves into a wall, it dies.

### Battles
* If a snake moves into another snake's body, it dies.
* If two snakes move into the same tile simultaneously, the shorter snake will die.
	* If both snakes are the same size, both snakes die.


## Gameplay Differences from the official arena
* Only 10 snakes are supported at a time (the 2016 official arena supports up to 12 and the 2017/2018/2019 arenas support an unlimited number).
* Ping endpoint support is not fully implemented (2019 arena only)
* No support for scoring (2016 arena only)
* No support for tiebreakers (2016 arena only - the game can end in a draw if the last two snakes are the same length and have a head-on-head collision, or if they starve or hit a wall on the same turn)
* No rewind functionality.
* 2019 (and beyond) head and tail types are not supported and probably never will be as those images are AGPL-licensed. Sorry.
* Probably other inconsistencies...

## Known Issues
* Windows 10 users may need to run the game in Windows 7 compatibility mode.
* If there are no free tiles on the game board, the app will freeze when trying to place food/walls/gold.
* Robosnakes don't respect the API timeout (but they're pretty fast if the recursion level is low).
* HTTPS URLs don't work at all for snakes or snake avatar.
* The full CSS syntax is not supported for snake colors.
* Probably other bugs...

## Troubleshooting
In the event the application experiences errors, you can reset the configuration and snakes by removing the data directory. This directory will be recreated the next time the application is launched.

On Mac OS X, the data directory can be found at `/Users/<USER_NAME>/Library/Application Support/mojave2/`

On Windows XP, the data directory can be found at `C:\Documents and Settings\<USER_NAME>\Application Data\mojave2\`

On Windows Vista and above, the data directory can be found at `C:\Users\<USER_NAME>\AppData\Roaming\mojave2\`

On Linux, the data directory can be found at `/home/<USER_NAME>/.local/share/mojave2/`

## Credits

Battlesnake  
Copyright ©2015-2018 Techdrop Labs, Inc. (d/b/a SendWithUs)  
Copyright ©2018-2019 Battlesnake Inc.  
http://www.battlesnake.io

Bloom Shader  
Copyright ©2011 slime  
https://love2d.org/forums/viewtopic.php?f=4&t=3733&start=20#p38666

Dear ImGui  
Copyright ©2014-2018 Omar Cornut and ImGui contributors  
https://github.com/ocornut/imgui

DKJson  
Copyright ©2010-2013 David Heiko Kolf  
http://dkolf.de/src/dkjson-lua.fsl

Gifload  
Copyright ©2016 Pedro Gimeno Fortea  
https://github.com/pgimeno/gifload

inspect.lua  
Copyright ©2013 Enrique García Cota  
https://github.com/kikito/inspect.lua

LÖVE  
Copyright ©2006-2018 LÖVE Development Team  
https://love2d.org

LÖVE-ImGui  
Copyright ©2016 slages  
https://github.com/slages/love-imgui

Monoton Font  
Copyright ©2011 Vernon Adams  
http://www.fontspace.com/new-typography/monoton

Music and Sound Effects by Eric Matyas  
http://www.soundimage.org

Robosnake  
Copyright ©2017 Redbrick Technologies, Inc.  
https://github.com/rdbrck/bountysnake2017

Son of Robosnake  
Copyright ©2017-2018 Redbrick Technologies, Inc.  
https://github.com/rdbrck/bountysnake2018

Robosnake Mk. III  
Copyright ©2017-2018 Redbrick Technologies, Inc.  
Copyright ©2019 Scott Small  
https://github.com/smallsco/robosnake

Vignette Image  
Public Domain  
http://hitokageproduction.com/files/stockTextures/vignette2.png

And lots of love to [Sendwithus](http://www.sendwithus.com) for creating the [Battlesnake](http://www.battlesnake.io) AI contest :)
