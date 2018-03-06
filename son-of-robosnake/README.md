## NOTICE

This isn't a _genuine_ copy of Son of Robosnake. This version, which comes with Mojave, has been slightly modified to run inside of a Lua coroutine instead of inside OpenResty, and to wire up to Mojave's logging mechanism. There may be subtle bugs introduced by this.

If you want to try your hand against the real thing, you can grab a copy from http://github.com/rdbrck/bountysnake2018 .

Original README now follows :)
  

```
                _______  _____  __   _       _____  _______            
                |______ |     | | \  |      |     | |______            
                ______| |_____| |  \_|      |_____| |                  
                                                                       
  ______  _____  ______   _____  _______ __   _ _______ _     _ _______
 |_____/ |     | |_____] |     | |______ | \  | |_____| |____/  |______
 |    \_ |_____| |_____] |_____| ______| |  \_| |     | |    \_ |______
                                                                       
```

## About
Son of Robosnake (SoR) is [Redbrick](http://www.rdbrck.com)'s bounty snake entry for the 2018 [Battlesnake](http://www.battlesnake.io) AI programming competition. It is written using [Lua](https://www.lua.org/) and designed to be run under [OpenResty](http://openresty.org/).

Our win conditions to claim the bounty are the following:
* Game is played on a 17 x 17 board
* 10 food are present on the board, at any given time
* API timeout of 200 milliseconds
* One-versus-one, last snake slithering wins the bounty.

Under these conditions, we won seventy-one games and lost three, for a total win record of 71/74 or 96%.


## Strategy
Son of Robosnake makes use of [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) in order to make predictions about the future state of the game. All possible moves by ourselves are evaluated, as well as all possible moves by the enemy. SoR will always select for itself the move that results in the best possible state of the game board, and it will select for the enemy the move that results in the worst possible state of the game board (from SoR's point of view, that is).

In order to evaluate a particular game board state, we look at the following metrics to produce a numeric score:

* How much health do I have?
* How much health does the enemy have?
* How many moves are available to me from my current position?
* How many moves are available to the enemy from its' current position?
* How many free squares can I see from my current position? (flood fill)
* How many free squares can the enemy see from its' current position? (another flood fill)
* How hungry am I right now?
* How close am I to food?
* How close am I to the enemy's head?
* How close am I to the edge of the game board?

In the event that we're playing in an arena containing more than one enemy snake, the closest snake to SoR will be chosen as the "enemy" for the purposes of algorithmic computation.

In the event that we're playing in an empty arena, SoR will choose *itself* as the "enemy". This will often lead to hilarity.

A blog post that talks about the strategy in depth is here: *TBD*


## How to Run
1. Download and install [OpenResty](http://openresty.org/).
2. Using LuaRocks, install `cjson` which is a mandatory dependency: `/usr/share/luajit/bin/luarocks install cjson`
3. Symlink `config/http.conf` into the `/etc/nginx/conf.d` directory.
4. Symlink `config/server.dev.conf` into the `/etc/nginx/sites-enabled` directory (and remove anything else in that directory).
5. Restart the nginx process and give the snake a try!

Or if that sounds like too much work, you can use [Mojave](https://github.com/smallsco/mojave) which contains a built-in copy of Robosnake, no assembly required. (Mojave with Son of Robosnake will be released post-event).


## Configuration
Configuration is done in `/config/http.conf`. 

* `MAX_RECURSION_DEPTH` - this affects how far the alpha-beta pruning algorithm will look ahead. Increasing this will make SoR much smarter, but response times will be much longer.
* `HUNGER_HEALTH` - when SoR's health dips to this value (or below) it will start looking for food.
* `LOW_FOOD` - if the food on the game board is at this number or lower, SoR will use a less aggressive heuristic and prioritize food.
