## CHANGELOG

### v0.2 (2017-01-29)

* Snake heads and colors are now read and used when displaying stats and taunts. They're not used on the game board itself yet, though.
* Added the ability to run the game in fullscreen.
* Worked around a bug in LuaSocket that could cause some HTTP requests to fail.
* Increased the time between gold drops to 100 turns - with the previous value of 75, drops were happening frequently enough that a lot of victories would happen due to gold collection (no matter what snakes were playing). This is probably because we play with a larger board size (by default) than the official Battlesnake arena.

### v0.1 (2017-01-21)

* Initial Release.