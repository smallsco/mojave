## CHANGELOG

### v3.1.1 (2021-02-27)

* Added additional head and tail images.
* Fixed a crash when adding a snake that does not specify a color customization. Snakes without a color customization will now be assigned a random color.

### v3.1 (2021-02-24)

* Snakes are now drawn with curves when turning. This is configurable via a new appearance option. Thank you to [Nettogrof](https://github.com/nettogrof/) for contributing this feature!
* Added a rematch button to the in-game controls that when pressed starts a new game with the same options as the current game.

### v3.0 (2021-02-22)

Mojave 3.0 is a significant rewrite, much like 2.0 was. There are many changes, the notable ones are listed below:

* Appearance
    * Added application icon (but only when the app is running).
    * Updated to a more recent version of _dear imgui_ and tweaked UI colors.
    * Replaced static vignette image with a shader powered by _Moonshine_. Vignette properties can be configured.
  		* This lays the groundwork for adding other moonshine effects in the future, i.e. filmgrain.
    * The renderer is now capped at 60 FPS, significantly reducing CPU usage.
	* Snakes built on API V1, plus human and robo snakes will have preview images rendered in menus.
    * All snakes will have a preview rendered during the game.
	* Control buttons for advancing, pausing, rewinding the game now use image labels.
	* When running in fullscreen mode, the game board will be scaled and the snake stats pane will retain a fixed width.
	* Shrunk food size so that it stays within its tile when rotating.
	* Added a tile fade effect for hazards.
	* All animations can now be disabled via the options menu for improved performance on older computers.
* Gameplay
    * The [official Battlesnake rules](https://github.com/BattlesnakeOfficial/rules) have been open-sourced, so I have ported them to Lua for use in Mojave. This means that Mojave should now fully exhibit the same behavior (and bugs) as the official game board, at least when it comes to gameplay.
    * Dropped support for the 2016 Battlesnake API.
    * Renamed the 2019 API version to V0 and implemented support for the V1 API.
    * Dropped support for deprecated game features (gold, walls, avatars, and taunts).
  		* Shouts will be used as taunts for the 2017/2018 API requests.
    * Added support for Royale, Squads, and Constrictor game modes.
    * Added support for hazards.
    * Added support for post-2018 head and tail types.
	* Added support for stepping back through games.
	* Stepping forward through games will no longer generate API calls if the turn has already been played.
	* Hover over a snake in the stats pane during an active game to view that snake's latency.
	* Press the "Debug" button above a snake in the stats pane during an active game to copy the request/response JSON for that turn to the clipboard.
* Bug Fixes
    * You can no longer start a game without any snakes.
* Other
    * Relicensed Mojave under GPL 3.0. This was required in order to bundle the latest Battlesnake head and tail images, and port the rules, which are AGPL-licensed.
    * Replaced all music and sound effects (this was a side effect of relicensing).
    * Mojave now runs the game in a separate thread from the GUI. This makes the GUI significantly more responsive when a game is in progress.    
	* Incorporated _libcurl_ in order to support snakes over HTTPS and simultaneous requests.
    * Moved the appdata directory to "mojave3" so that we can run side-by-side with 2.x and earlier versions.
    * Updated game engine to LÖVE 11.3, which has changed system requirements.
        * Windows:
		    * Dropped support for Windows XP. The minimum OS requirement is now Windows Vista.
			* The Microsoft Visual C++ 2017 Redistributable package is now required to run the game.
    	* Mac:
		    * The minimum OS requirement is now Mac OS 10.14 (also called Mojave...)
		    * Added support for macOS 11 (Big Sur).
		    * Apple Silicon (ARM) based machines are not natively supported at this time. They should be able to run the game under emulation, though this hasn't been tested.
	    * All: A 64-bit operating system is now required. 

### v2.9 (2019-03-06)

* Added the Robosnake Mk. III as another built-in snake! This version of Robo is the toughest yet, especially when many snakes are in play.

### v2.8.1 (2019-02-26)

* When using fixed snake starting positions, those positions are now randomly assigned to the first eight snakes in play, rather than hardcoding a position to each snake slot.
* Support 2017/2018 head and tail images on 2019 snakes.

### v2.8 (2019-02-22)

* Added a new option to specify the amount of food that is placed on the game board when one of the growing food placement strategies is used.
* Added a new option to place an amount of food equal to half the number of living snakes in play on the game board when using a growing food placement strategy (rather than a fixed value)
* Updated the Readme to explain why new head and tail images added in 2019 will not be supported.

### v2.7.1 (2019-02-12)

* Update default API timeout to 250ms
* When using a growing food placement strategy, start the game with one food on the board for each snake in the game.

### v2.7 (2019-02-06)

* Added a "dynamic growing" food placement strategy which is used by the official 2019 game board.
* Ensure that snakes are always placed on even-numbered tiles to ensure that they are capable of killing each other with a head-on collision.
* Tweaked the default configuration values for people who are running the app for the first time.

### v2.6 (2018-12-24)

* Support the draft 2019 API (subject to change).
* Support the ability to fix snake starting positions according to 2019 tournament rules.
* Added presets for tournament board sizes.
* Fixed the winning snake ID in /end endpoint for 2018 API snakes that win by collecting all gold.

### v2.5.3 (2018-06-16)

* Clicking "Play" on the game board when a match has completed will now re-start the match using the same settings without requiring you to make a trip back to the menu.
* Added a note to the readme re: incompatibility with LÖVE 11.x

### v2.5.2 (2018-03-16)

* Fixed a bug that prevented changing Son of Robosnake's recursion depth setting from the default.

### v2.5.1 (2018-03-15)

* Changed default board height/width/food for better compatibility with Robosnakes
* Minor documentation tweaks.

### v2.5 (2018-03-05)

* It is now possible to play _Son of Robosnake_, [Redbrick](http://www.rdbrck.com)'s 2018 Bounty Snake directly from Mojave without requiring you to set up your own server.
* The /end endpoint call has been implemented for both the 2016 and 2018 APIs (it was not used in 2017)
* Snakes now die of starvation when their health _reaches_ zero, rather than when it _drops below_ zero (revert change from v2.3.5)
* Fixed a bug where playing Robosnake could cause the game state to corrupt.
* Fixed an additional crash caused by missing values in config.json when upgrading.
* Fixed a bug that allowed you to step past the end of the game.
* Reorganized the options menu a bit.
* Removed some unused code.

### v2.4 (2018-02-24)

* Added the ability to pin snake tails so that snakes grow on every turn (like a Tron game).
* Matches now start at turn 0 instead of turn 1.
* Game ID is now an integer in the 2018 API instead of a UUID.
* Restored move taunt support for 2018 API snakes (the official board supports this even though the API says it doesn't).
* Restored sending height/width on start to 2018 API snakes (the official board does this even though the API says it doesn't).

### v2.3.6 (2018-02-14)

* 2018 API snakes now need to have their name specified when they are added, the "name" property in API calls is no longer used (this is the same behavior as 2016 API snakes).

### v2.3.5 (2018-02-09)

* Snakes now die of starvation when their health drops _below_ zero, rather than _at_ zero.

### v2.3.4 (2018-02-06)

* Do not send dead snakes at all in 2018 API.
* Leave snake health stat alone on death (reverts change from v2.3).
* 2017/2018 API snakes will now be assigned a random color and have their endpoint URL as their name, in the event that their start endpoint call fails.

### v2.3.3 (2018-02-04)

* Taunts are only set when calling the start endpoint in 2018 API.
* Fixed a bug that caused start endpoint taunts not to show when using snakes under the 2017 or 2018 API (or robosnake).

### v2.3.2 (2018-02-03)

* Added missing "length" parameter to snakes in 2018 API.

### v2.3.1 (2018-01-23)

* Start endpoint for 2018 API snakes no longer sends board height/width
* Updated imgui so that Mojave should run correctly under Linux now (thanks @eburdon). If you previously tried to run Mojave under Linux and got an error you will need to remove the application data directory first (see "Troubleshooting" in the readme for instructions).

### v2.3 (2018-01-20)

* Support the draft 2018 API (subject to change).
* When a snake dies, its' health is now set to 0.
* Fixed Robosnake's head and tail type.

### v2.2 (2018-01-19)

* Fix for crashes caused by missing values in config.json (i.e. when upgrading to a new version with new config options that won't be present in the existing config.json on disk).
* The starting length of snakes can now be customized from the default of 3. Lots of low-level tweaks to ensure that snakes with a length of 1 or 2 behave and render correctly.
* The amount of health lost per turn can now be customized from the default of 1.
* Kill counts are no longer double-awarded for head-on-head collisions between three or four snakes.
* The snake death sound effect is no longer played when trying to kill a snake that is already marked for death on the current turn.

### v2.1.1 (2018-01-18)

* Fixed a visual bug that caused snake tails to appear in the wrong direction on the first turn of the game.
* Added an option to start new games paused (useful for debugging).
* Shrunk default board size to 25x15.
* 2017 API Snakes whos requests time out will now have their direction randomly selected.

### v2.1 (2018-01-14)

* You can now play the infamous Redbrick Robosnake directly within Mojave, without having to set up your own server.
* Snake kills are now incremented when running into the body of another snake, not just the head.
* Walls are now drawn underneath food instead of on top.
* Decreased the opacity of dead snakes slightly.
* Corrected the debug output of game ticks.
* Corrected a bug that could cause the 'Enable Sanity Checks' option not to have any effect.

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