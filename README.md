# Mojave

Mojave is a third-party, open-source arena / gameboard / client for [Battlesnake](https://www.battlesnake.io/). It supports both the [2016](http://web.archive.org/web/20160817172025/http://www.battlesnake.io/readme) and [2017](https://stembolthq.github.io/battle_snake/) rules/API.

The intent is to allow companies to get a head start on building their bounty snakes, and for competitors to try out strategies prior to the competition.

## Download

The latest binaries for Win32, Win64, and Mac OS X can be downloaded from [the Releases link](https://github.com/smallsco/mojave/releases) above.
Mojave is also compatible with Linux, however Linux users will have to manually run the game using [LÖVE](http://www.love2d.org) (see below).

## Building

Install [love-release](https://github.com/MisterDA/love-release), then run `love-release -W -M` from the `mojave` directory. This will create a new folder, `releases`, containing zipped binaries for Win32, Win64, and Mac OS X.

Or, you can run the game directly using [LÖVE](http://www.love2d.org). Download and install version 0.10.2, navigate to the `mojave` directory, and run `love --fused .`. The `--fused` parameter is important, without it the game's data directory path will not be set correctly.

## Usage

Launching the app for the first time will create a `snakes.json` file located in the game's data directory.

On Mac OS X, the data directory can be found at `/Users/<USER_NAME>/Library/Application Support/mojave/`

On Windows XP, the data directory can be found at `C:\Documents and Settings\<USER_NAME>\Application Data\mojave\`

On Windows Vista and above, the data directory can be found at `C:\Users\<USER_NAME>\AppData\Roaming\mojave\`

On Linux, the data directory can be found at `/home/<USER_NAME>/.local/share/mojave/`

The `snakes.json` file contains a list of snakes ([Battlesnake servers](https://github.com/sendwithus/battlesnake-python)) in the following format:

```
[
    {
        "id": "25a71b44-c96f-40c7-bfb9-3d624c07e76e",
        "name": "Human Player",
        "url": ""
    },
    {
        "id": "bfe74f40-bb7c-4445-a44f-592802a759d9",
        "name": "My Snake",
        "url": "http://localhost:5001"
    },
    {
        "id": "a4f9b15c-7370-488c-ad16-60db99b7a8cc",
        "name": "Enemy Snake",
        "url": "http://localhost:5002"
    }
]
```

Each snake has a `name` and `url` property associated with it, and may have an optional `id` property.

The `name` property is mandatory, and is printed on the game board during a match. It is also transmitted to snake servers while the match is in progress, and may be used in taunts!

The `url` property contains the URL to the snake server's API endpoint.

The `id` property is optional. If not explicitly specified, one will be randomly generated at the start of each match (it will remain the same for the duration of the match).

On the official 2016 game server, the ID is generated when a snake is registered with the server, and remains the same for all games. Most snakes hard-code this ID into their application code and use it to identify themselves in the list of snakes sent by the server on each request. For this reason, when using a 2016-API snake with Mojave, you will need to look through the snake's source code, find its' ID, and add it to `snakes.json`.

On the official 2017 game server, the ID is generated at the start of each match. On each request, the server will send a "you" property with the JSON that contains the ID of the snake receiving the request - so hardcoding IDs is not required. When using a 2017-API snake with Mojave, you will need to remove the `id` property from `snakes.json`.


## Human Player

The first snake listed in `snakes.json` may be controlled by the arena operator using the arrow keys. If the URL for this snake is also left blank, then the arena operator can test themselves against the snake AIs in the match!


## Rules

* All snakes execute their moves simultaneously.
* If a snake moves into the edge of the arena, it dies.
* Dead snakes are removed from the game board.
* The last snake alive is the winner of the game.
	* unless playing an advanced game and a snake reaches 5 gold, see below

### Food and Health
* Snakes start with 100 health. On each turn, snakes lose 1 health, unless they have eaten food that turn.
* If a snake's health reaches 0, it dies.
* Food will spawn on the game board...
	* In the 2016 API, at a random location every 3 turns.
	* In the 2017 API, when the game is started, and whenever a snake has consumed another piece of food on the board.
* If a snake lands on a food square, it "eats" the food, and its' health will be restored. It's tail will grow by one square.
	* In the 2016 API, each food will restore health by 30 (to a maximum of 100).
	* In the 2017 API, each food will restore health to exactly 100.

### Gold (advanced games only, 2016 API only)
* Snakes start with 0 gold.
* Gold will spawn on the game board at a random location every 100 turns.
* The first snake to collect 5 gold will instantly win the game, regardless of how many snakes are currently alive.

### Walls (advanced games only, 2016 API only)
* A wall will spawn on the game board every 5 turns, starting at turn 50.
* Walls will never spawn directly in front of a snake.
* If a snake moves into a wall, it dies.

### Battles
* If a snake moves into another snake's tail, it dies.
* If two snakes move into the same tile simultaneously, the shorter snake will die.
	* If both snakes are the same size, both snakes die.
* The winning snake's health will reset to 100.
* The winning snake's length will grow by half of the losing snake's length (rounded down).


## Differences from the official arena
* No support for scoring (2016 API only)
* No support for tiebreakers (2016 API only - the game can end in a draw if the last two snakes are the same length and have a head-on-head collision)
* No support for custom head/tail types (2017 API only)
* Snakes that use a GIF image as their head will have a generic head drawn on the game board instead
* Probably other inconsistencies...

## Known Bugs
* Snake tails occasionally spawn on the same square, leading to hilarity
* If there are no free tiles on the game board, the app will freeze when trying to place food/walls/gold
* When using the 2017 API, snakes seem to crash into themselves more frequently than on the official game board, not sure why...
* Probably other bugs...

## Credits

DKJson  
Copyright ©2010-2013 David Heiko Kolf  
http://dkolf.de/src/dkjson-lua.fsl/

Log.lua  
Copyright ©2014 rxi  
https://github.com/rxi/log.lua

LÖVE  
Copyright ©2006-2017 LÖVE Development Team  
https://love2d.org/

Music and Sound Effects by Eric Matyas  
http://www.soundimage.org

Simple User Interface Toolkit  
Copyright ©2016 Matthias Richter  
https://github.com/vrld/SUIT

And lots of love to [SendWithUs](http://www.sendwithus.com) and [Stembolt](http://www.stembolt.com) for creating the [Battlesnake](http://www.battlesnake.io) AI contest :)
