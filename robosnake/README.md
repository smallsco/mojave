## NOTICE

This isn't a _genuine_ copy of Robosnake. This version, which comes with Mojave, has been slightly modified to run inside of a Lua coroutine instead of inside OpenResty, and to wire up to Mojave's logging mechanism. There may be subtle bugs introduced by this.

If you want to try your hand against the real thing, you can grab a copy from http://github.com/rdbrck/bountysnake2017 .

Original README now follows :)
  

```
      ______  _____  ______   _____  _______ __   _ _______ _     _ _______
     |_____/ |     | |_____] |     | |______ | \  | |_____| |____/  |______
     |    \_ |_____| |_____] |_____| ______| |  \_| |     | |    \_ |______
                                                                           
```

## About
The Robosnake was [Redbrick](http://www.rdbrck.com)'s bounty snake entry for the 2017 [Battlesnake](http://www.battlesnake.io) AI programming competition. It is written using [Lua](https://www.lua.org/) and designed to be run under [OpenResty](http://openresty.org/).

Our win conditions to claim the bounty were the following:
* Game is played on a 17 x 17 board
* 10 food are present on the board, at any given time
* API timeout of 1 second
* One-versus-one, last snake slithering wins the bounty.

Under these conditions, we won forty-two games and lost three, for a total win record of 42/45 or 93%.


## Strategy
The Robosnake makes use of [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) in order to make predictions about the future state of the game. All possible moves by ourselves are evaluated, as well as all possible moves by the enemy. The Robosnake will always select for itself the move that results in the best possible state of the game board, and it will select for the enemy the move that results in the worst possible state of the game board (from the Robosnake's point of view, that is).

In order to evaluate a particular game board state, we look at the following metrics to produce a numeric score:

* How much health do I have?
* How much health does the enemy have?
* How many moves are available to me from my current position?
* How many moves are available to the enemy from its' current position?
* How many free squares can I see from my current position? (flood fill)
* How many free squares can the enemy see from its' current position? (another flood fill)
* How close am I to food right now?

In the event that we're playing in an arena containing more than one enemy snake, the closest snake to the Robosnake will be chosen as the "enemy" for the purposes of algorithmic computation.

In the event that we're playing in an empty arena, the Robosnake will choose *itself* as the "enemy". This will often lead to hilarity.

A blog post that talks about the strategy in depth is here: https://rdbrck.com/2017/03/building-bounty-snake-post-mortem/


## Configuration
Configuration is done in `/config/http.conf`. 

* `RULES_VERSION` - this can be set to `2016` or `2017`. 
* `MAX_RECURSION_DEPTH` - this affects how far the alpha-beta pruning algorithm will look ahead. Increasing this will make the Robosnake much smarter, but response times will be much longer.
* `SNAKE_ID` - when using `2016` rules, this needs to be set to the ID sent by the Battlesnake client.


