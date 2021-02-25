local CreditsPane = {}

function CreditsPane.draw()

    -- About Mojave and Battlesnake
    if imgui.CollapsingHeader( "About Mojave and Battlesnake", { "DefaultOpen" } ) then
        imgui.TextWrapped([[
Mojave is a desktop game board and development / debugging tool for Battlesnake (see https://play.battlesnake.com). It aims to bring an immersive "arcade" style experience to the game, with crisp neon visuals, an electrifying soundtrack, and a high amount of customizability.

Don't know Battlesnake? It's an online programming game played by developers from all over the world! Build a snake "bot" and be the last one slithering on the game board to win. You can use any language or technology that implements a web server. For more information on how to write your snake, and on the rules of the game, take a look at the Battlesnake docs (see https://docs.battlesnake.com/).

Battlesnake's mission is to make programming fun and accessible for everyone! With Mojave, we hope to make your Battlesnake experience even better!
        ]])
        imgui.Text("\n")
    end

    -- Battlesnake Rules
    if imgui.CollapsingHeader( "Battlesnake Rules", { "DefaultOpen" } ) then
        imgui.TextWrapped([[
For full game rules, see the official Battlesnake Rules at https://docs.battlesnake.com/references/rules , the following is an abridged version:

Standard
Under Standard rules, snakes may freely roam the game board, and lose some health on each turn. Food will spawn periodically on the game board. Eating food will restore a snake to full health, but will cause it to grow by one tile. A snake will die if it runs out of health, runs into a wall, or into the body of itself or another snake. If two snakes have a head-on-head collision, the smaller snake will be killed (and both will be killed if they are the same size).

Royale
Under Royale rules, the edges of the board will slowly fill with hazards. If the head of a snake enters a hazard, that snake will take damage at an increased rate.

Squads
Under Squads rules, all snakes are assigned to one of up to four squads. Snakes that belong to the same squad will share health and length, and may pass through each other's bodies without dying. However, if a snake dies, all other snakes on that squad will die as well.

Constrictor
Under Constrictor rules, there is no food on the board. Instead, snakes will grow on every turn, with their tail locked to their starting position. This is also known as a Tron game.
        ]])
        imgui.Text("\n")
    end

    -- Mojave Credits
    if imgui.CollapsingHeader( "Mojave Credits", { "DefaultOpen" } ) then
        imgui.TextWrapped([[
Mojave
Copyright ©2017-2021 Scott Small and contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.


Special thanks to the following third-party software, for whom without
Mojave would not be possible:


Battlesnake concept, assets, and rules
Copyright ©2015-2018 Techdrop Labs, Inc. (d/b/a Dyspatch)
Copyright ©2018-2021 Battlesnake Inc.
License: AGPL 3.0
https://www.battlesnake.com
https://github.com/BattlesnakeOfficial/exporter/tree/master/render/assets
https://github.com/BattlesnakeOfficial/rules

Atmospheric Interaction Sound Pack
License: Public Domain
https://opengameart.org/content/atmospheric-interaction-sound-pack

Bloom Shader
Copyright ©2011 slime
License: Public Domain
https://love2d.org/forums/viewtopic.php?f=4&t=3733&start=20#p38666

Dear ImGui
Copyright ©2014-2021 Omar Cornut
License: MIT
https://github.com/ocornut/imgui

DKJson
Copyright ©2010-2013 David Heiko Kolf
License: MIT
http://dkolf.de/src/dkjson-lua.fsl

Kenney Game Icons
License: Public Domain
https://opengameart.org/content/game-icons

libcurl
Copyright ©1996-2021 Daniel Stenberg
License: MIT
https://curl.se/libcurl/

libcurl Lua Bindings
Copyright ©2020 Cosmin Apreutesei
License: Public Domain
https://luapower.com/libcurl

LÖVE
Copyright ©2006-2021 LÖVE Development Team
License: ZLIB
https://love2d.org

LÖVE-ImGui
Copyright ©2016 slages
License: MIT
https://github.com/MikuAuahDark/love-imgui

Monoton Font
Copyright ©2011 Vernon Adams
License: OFL
https://www.fontspace.com/monoton-font-f11955

Moonshine
Copyright ©2017 Matthias Richter
License: MIT
https://github.com/vrld/moonshine

"Nebula Boss Fight"
Copyright ©2017 TeknoAXE
License: CC BY 4.0
https://www.youtube.com/watch?v=vRRhVNwM6sc

Robosnake Mk. III
Copyright ©2017-2018 Redbrick Technologies, Inc.
Copyright ©2019 Scott Small
License: MIT
https://github.com/smallsco/robosnake

Space Laser
License: Public Domain
https://opengameart.org/content/space-laser

Splashes
Copyright ©2016 love-community members
License: ZLIB
https://github.com/love2d-community/splashes

"Synthwave C"
Copyright ©2017 TeknoAXE
License: CC BY 4.0
https://www.youtube.com/watch?v=-WYJ1Jh2kuI

Extra special thanks to:
Erika Wiedemann - for her assistance in getting imgui working on Linux
Tyler Sebastian - for his early work on multithreading
        ]])
        imgui.Text("\n")
    end
end

return CreditsPane
