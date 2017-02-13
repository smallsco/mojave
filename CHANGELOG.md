## CHANGELOG

### v0.4 (2017-02-XX)

* Custom snake head images and body colors are now used on the game board.
* Gold is now spawned in the closest free square to the center of the game board.
* Gold will not be spawned on the game board if gold is already present on the board.
* Restrict the maximum number of snakes in the arena to 12.
* Disallow play if there are no snakes defined in snakes.json.
* Force board height and width to be odd numbers (so that there is always a center square for gold spawns)

### v0.3 (2017-02-08)

* Fixed broken logging caused by a missing submodule.
* Fixed a crash when trying to start a game containing a snake without a head image.
* Added the ability to customize the game board size from the menu.

### v0.2 (2017-01-29)

* Snake heads and colors are now read and used when displaying stats and taunts. They're not used on the game board itself yet, though.
* Added the ability to run the game in fullscreen.
* Worked around a bug in LuaSocket that could cause some HTTP requests to fail.
* Increased the time between gold drops to 100 turns - with the previous value of 75, drops were happening frequently enough that a lot of victories would happen due to gold collection (no matter what snakes were playing). This is probably because we play with a larger board size (by default) than the official Battlesnake arena.

### v0.1 (2017-01-21)

* Initial Release.