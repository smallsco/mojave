## CHANGELOG

### v2.0 (2018-01-13)

Mojave 2.0 is a nearly complete rewrite, with lots and lots of changes. The more notable ones are listed below:

* Appearance
	* Replaced SUIT with "dear imgui" for rendering GUI elements.
	* The game board colors can now be customized.
	* Snakes can be configured in the GUI, no more editing snakes.json by hand!
	* Snake head and tail type images are now fully supported (for 2017 API snakes). 2016 API snakes use heads and tails that are associated with their slot.
	* Snake avatars in GIF format are now supported (however they will not be animated)
	* Snake health and gold are rendered using progress bars.
	* Improved overall visual appearance of the game board with a (toggleable) bloom filter and vignette. These use a lot of GPU power, so turn them off for laptops or if the game runs too slowly.
* Gameplay
	* Fixed several inconsistencies related to tracking snake length and position on the game board, when compared to the official Battlesnake arena. This fixes a number of snakes that would crash at game start or run into their own body when playing under Mojave.
	* 2016 and 2017 API snakes can now play each other in the same game - Mojave will send the appropriate API calls to each snake rather than globally.
	* Rules changed in different versions of the API can be toggled on/off from the Options menu, allowing for fully hybrid games rather than strict "2016" or "2017" games.
	* The game speed can be customized (though it's still bound by the response time from snakes)
	* Matches can be paused and resumed, and the internal map state logged during the match.
	* The board size is no longer forced to have an odd height/width under any circumstances.
	* A human player can no longer control a computer snake, rather, a human player can have own snake to control if requested.
	* Reduced the maximum number of snakes allowed in the arena to 10 (for GUI purposes, might bump it back up to 12 in a future release)
	* Snakes will no longer be spawned on the edge of the game board.
* Other
	* New soundtrack, "Desert Mayhem" plays while a game is running.
	* New soundtrack, "Automation" plays while on the menu screen.
	* Moved logging to the game UI, and snake taunts to log messages.
	* Moved the appdata directory to "mojave2" so that we can run side-by-side with 1.0 and earlier versions.
	* Introduced debugging functionality that allows you to step through a match one turn at a time.

### v1.0 (2017-03-05)

* Public release!
* Merged 2017 API and food rules into a single menu option.
* Corrected documentation for food spawns in README.

### v0.6.1 (2017-02-29)

* Use a default image for snakes whos head could not be loaded
* Do not force board height and width to be odd if playing under the 2017 API

### v0.6 (2017-02-28)

* Implemented support for a global API call timeout, with a 200ms default
* Enable 2017 API and food rules by default
* Fix a crash that occurred when a snake's head was in an unsupported image format
* Generate UUIDs for snakes that have no ID explicitly defined in snakes.json

### v0.5.1 (2017-02-19)

* Fix /move response interpretation for 2017 API
* If only a single snake is present in snakes.json, allow that snake to play forever (just like we do with human-controlled snakes)

### v0.5 (2017-02-16)

* Support for the 2017 API (https://stembolthq.github.io/battle_snake/). This is a work in progress and will lag behind the official arena.
	* The 2017 rule changes (for food) can be toggled separately from the API changes, in order to test new rules / game mechanics using third-party snakes that do not support the latest API yet. When the competition has concluded, this will be replaced by a simple 2016/2017 toggle that will change both the API calls as well as the game rules.

### v0.4 (2017-02-12)

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

* Initial Internal Release.