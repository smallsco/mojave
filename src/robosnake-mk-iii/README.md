## NOTICE

This isn't a _genuine_ copy of Robosnake. This version, which comes with Mojave, has been slightly modified to run inside of a Lua coroutine instead of inside OpenResty, and to wire up to Mojave's logging mechanism. There may be subtle bugs introduced by this.

If you want to try your hand against the real thing, you can grab a copy from http://github.com/smallsco/robosnake .

Original README now follows :)
  

```
  ______  _____  ______   _____  _______ __   _ _______ _     _ _______
 |_____/ |     | |_____] |     | |______ | \  | |_____| |____/  |______
 |    \_ |_____| |_____] |_____| ______| |  \_| |     | |    \_ |______
                                                                       
                _______ _     _        _____ _____ _____               
                |  |  | |____/           |     |     |                 
                |  |  | |    \_ .      __|__ __|__ __|__               
                                                                       
```

## About
The Robosnake (Robo) is a snake for the 2019 [Battlesnake](http://www.battlesnake.io) AI programming competition. It is written using [Lua](https://www.lua.org/) and designed to be run under [OpenResty](http://openresty.org/).

In previous years it was [Redbrick](http://www.rdbrck.com)'s bounty snake. You can see those versions here:

* 2017: https://github.com/rdbrck/bountysnake2017
* 2018: https://github.com/rdbrck/bountysnake2018

The Mk. III is the final, canonical release of the Robosnake. It's been a great three-year run, but it's also time for something new.


## 2019 Tournament and Bounty Snake Results
Being an iteration on a former Bounty Snake, Robo did not compete in the 2019 tournament. However it did challenge a number of fellow Bounty Snakes:

* **Defeated:** Pixel Union, Schneider Electric, Workday, Semaphore, Bambora, Rooof, FreshWorks, Sendwithus (Level 7)
* **Lost To:** Giftbit, Checkfront

During the week preceeding the tournament, up to the day of the tournament itself, Robo had a high of position #7 and a low of position #29 (averaging somewhere around #13) on the [play.battlesnake.io](http://play.battlesnake.io) leaderboard.

Robo did reach as high as #2 on tournament day but that was because the top snakes removed themselves from the leaderboard in order to maximize their computation time for the tournament. A good strategy ;)


## Strategy
Robo makes use of [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) (a variant on the [minimax](https://en.wikipedia.org/wiki/Minimax) algorithm) in order to make predictions about the future state of the game. All possible moves by ourself are evaluated, as well as all possible moves by the enemy. Robo will always select for itself the move that results in the best possible state of the game board, and it will select for the enemy the move that results in the worst possible state of the game board (from Robo's point of view, that is).

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

In the event that we're playing in an arena containing more than one enemy snake, the closest snake to Robo will be chosen as the "enemy" for the purposes of algorithmic computation. If two snakes are equally close to Robo, the shorter of the two will be selected.

In the event that we're playing in an empty arena, Robo will choose *itself* as the "enemy". This will often lead to hilarity!


## Changes from 2018
* Dockerized so that Robo can be deployed to Heroku (which doesn't natively support Lua/OpenResty)
* Updated to 2019 API
* Paths that lead to death are fully evaluated instead of short-circuited
* Try to work around the infamous "ignore food when floodfilling" bug by adding an extra square to the floodfill result. Did it work? Who knows!
* If there are more than 4 living snakes on the board don't be aggressive at all and just go for food, this helps Robo survive in the early game by staying away from other snakes.
* Try to avoid tunnels, and try to put the enemy into a tunnel.
* Update the failsafe algorithm (run if alpha-beta returned no move) to floodfill all neighbouring squares and move to the one with the most free space (rather than picking a random "safe" neighbouring square). Do this even when there are no "safe" squares (i.e. squares an enemy can move into)
* When running alpha-beta, remove the tails of ALL snakes from the grid as we recurse the game tree, not just the current enemy. This makes Robo more vulnerable to tail-chasers, but helps with more accurate prediction for all other snakes by increasing our movement possibilities.
* If there is more than one enemy, be smarter about which one is selected for alpha-beta: try the closest enemy first, and then the shortest if multiple enemies are the same distance from Robo. If multiple enemies are the same distance and length only then do we pick one of them at random.
* Block off squares on the grid that enemies other than the targeted enemy for alpha-beta can move into. This is also something of a failsafe to address the fact that we can only run alpha-beta against a single enemy.


## How to Run (Docker)
1. Download and install [Docker](http://docker.com/).
2. Navigate to the directory where you checked out this repository and run `docker-compose up`
3. That's it! Robo will be listening on port `5000`.


## How to Run (Classic)
1. Download and install [OpenResty](http://openresty.org/).
2. Using LuaRocks, install `cjson` which is a mandatory dependency: `/usr/share/luajit/bin/luarocks install cjson`
3. Symlink `config/server.dev.conf` into the `/etc/nginx/conf.d` directory, renaming it to `default.conf` (and remove anything else in that directory).
4. Restart the `nginx` process.
5. That's it! Robo will be listening on port `5000`.


## Configuration
Configuration is done in `/config/server.ENV.conf` (where `ENV` is one of `dev` or `prod`). 

* `MAX_AGGRESSION_SNAKES` - the maximum number of snakes that can be on the board for Robo to be aggressive. If there are more than this many living snakes in play, Robo will become passive and only target food.
* `MAX_RECURSION_DEPTH` - this affects how far the alpha-beta pruning algorithm will look ahead. Increasing this will make Robo much smarter, but response times will be much longer.
* `HUNGER_HEALTH` - when Robo's health dips to this value (or below) it will start looking for food.
* `LOW_FOOD` - if the food on the game board is at this number or lower, Robo will use a less aggressive heuristic and prioritize food.
