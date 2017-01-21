# Mojave

Mojave is a third-party, open-source arena / gameboard / client for [Battlesnake](https://www.battlesnake.io/), using the [2016 rules/API](http://web.archive.org/web/20160817172025/http://www.battlesnake.io/readme).

The intent is to allow companies to get a head start on building their bounty snakes, and for competitors to try out strategies prior to the competition.


## Building
Install [love-release](https://github.com/MisterDA/love-release), then run `love-release -W -M` from the `mojave` directory. This will create a new folder, `releases`, containing zipped binaries for Win32, Win64, and Mac OS X.

Or, you can run the game directly using [LÖVE](http://www.love2d.org). Download and install version 0.10.2, navigate to the `mojave` directory, and run `love --fused .`. The `--fused` parameter is important, without it the game's data directory path will not be set correctly.

## Usage

Launching the app for the first time will create a `snakes.json` file located in the game's data directory.

On Mac OS X, the data directory can be found at `/Users/<USER_NAME>/Library/Application Support/mojave/`

On Windows XP, the data directory can be found at `C:\Documents and Settings\<USER_NAME>\Application Data\mojave\`

On Windows Vista and above, the data directory can be found at `C:\Users\<USER_NAME>\AppData\Roaming\mojave\`

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

Each snake has a `id`, `name`, and `url` property associated with it.

The `id` property can, in theory, be whatever you want. This is what the snake server will use to identify itself in the list of snakes sent by the client during a match. However, if you are testing with a snake that you found online, you will need to look through its' code for the correct id to place in this property.

The `name` property is mandatory, and is printed on the game board during a match. It is also transmitted to snake servers while the match is in progress, and may be used in taunts!

The `url` property contains the URL to the snake server's API endpoint.


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
* Food will spawn on the game board at a random location every 3 turns.
* If a snake lands on a food square, it "eats" the food, and its' health will be restored by 30 (to a maximum of 100). It's tail will grow by one square.

### Gold (advanced games only)
* Snakes start with 0 gold.
* Gold will spawn on the game board at a random location every 75 turns.
* The first snake to collect 5 gold will instantly win the game, regardless of how many snakes are currently alive.

### Walls (advanced games only)
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
* No support for scoring
* No support for tiebreakers (the game can end in a draw if the last two snakes are the same length and have a head-on-head collision)
* No support for custom snake colors
* No support for custom snake head images
* Snake server API response time is not restricted
* Gold can spawn anywhere on the board
* Gold can spawn when there's already gold on the board
* Probably other bugs and inconsistencies...


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

And lots of love to [SendWithUs](http://www.sendwithus.com) for creating the [Battlesnake](http://www.battlesnake.io) AI contest :)