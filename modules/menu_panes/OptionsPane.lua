local OptionsPane = {}

function OptionsPane.draw()

    -- Save Options top button
    if imgui.Button( "Save Changes##top", imgui.GetWindowContentRegionWidth() * 0.2, 50 ) then
        local ok = love.filesystem.write( 'config.json', json.encode( config ) )
        if not ok then
            error( 'Unable to write config.json' )
        end
        imgui.OpenPopup( "SaveOptions" )
    end

    -- Revert Options top button
    imgui.SameLine()
    if imgui.Button( "Revert Changes##top", imgui.GetWindowContentRegionWidth() * 0.2, 50 ) then
        imgui.OpenPopup( "RevertOptions" )
    end
    imgui.Text("\n")

    -- Appearance Options
    if imgui.CollapsingHeader( "Appearance", { "DefaultOpen" } ) then
        config.appearance.tilePrimaryColor = {imgui.ColorEdit4(
            "Tile Primary Color",
            unpack( config.appearance.tilePrimaryColor )
        )}
        config.appearance.tileSecondaryColor = {imgui.ColorEdit4(
            "Tile Secondary Color",
            unpack( config.appearance.tileSecondaryColor )
        )}
        config.appearance.foodColor = {imgui.ColorEdit4("Food Color", unpack(config.appearance.foodColor))}
        config.appearance.hazardColor = {imgui.ColorEdit3("Hazard Color", unpack(config.appearance.hazardColor))}
        config.appearance.fullscreen = imgui.Checkbox( "Fullscreen", config.appearance.fullscreen )

        config.appearance.enableVignette = imgui.Checkbox( "Vignette", config.appearance.enableVignette )
        if config.appearance.enableVignette then
            imgui.SameLine()
            imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.15)
            config.appearance.vignetteRadius = imgui.InputFloat( "Radius", config.appearance.vignetteRadius, 0.1, 0, 1 )
            imgui.SameLine()
            config.appearance.vignetteOpacity = imgui.InputFloat( "Opacity", config.appearance.vignetteOpacity, 0.1, 0, 1 )
            imgui.SameLine()
            config.appearance.vignetteSoftness = imgui.InputFloat( "Softness", config.appearance.vignetteSoftness, 0.1, 0, 1 )
            imgui.PopItemWidth()
            config.appearance.vignetteColor = {imgui.ColorEdit3("Vignette Color", unpack(config.appearance.vignetteColor))}
        end

        config.appearance.enableBloom = imgui.Checkbox( "Bloom Filter", config.appearance.enableBloom )
        imgui.SameLine()
        config.appearance.enableAnimation = imgui.Checkbox( "Animations", config.appearance.enableAnimation )

        config.appearance.fadeOutTails = imgui.Checkbox( "Fade Tails", config.appearance.fadeOutTails )
        imgui.SameLine()
        config.appearance.curveOnTurns = imgui.Checkbox( "Curve on Turns", config.appearance.curveOnTurns )

        imgui.Text( "\n" )
    end

    -- Audio Options
    if imgui.CollapsingHeader( "Audio", { "DefaultOpen" } ) then
        config.audio.enableMusic = imgui.Checkbox( "Music", config.audio.enableMusic )
        imgui.SameLine()
        config.audio.enableSFX = imgui.Checkbox( "Sound Effects", config.audio.enableSFX )
        imgui.Text( "\n" )
    end

    -- Standard Gameplay Options
    if imgui.CollapsingHeader( "Gameplay", { "DefaultOpen" } ) then
        imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.15)
        config.gameplay.responseTime = imgui.InputInt( "API Timeout (ms)       ", config.gameplay.responseTime)
        imgui.SameLine()
        config.gameplay.humanResponseTime = imgui.InputInt( "Human Timeout (ms)", config.gameplay.humanResponseTime)
        config.gameplay.gameSpeed = imgui.InputFloat( "Game Speed (low = fast)", config.gameplay.gameSpeed, 0.01, 0, 2)
        imgui.SameLine()
        config.gameplay.foodSpawnChance = imgui.InputInt( "Food Spawn Chance", config.gameplay.foodSpawnChance)
        config.gameplay.minimumFood = imgui.InputInt( "Minimum Food           ", config.gameplay.minimumFood)
        imgui.SameLine()
        config.gameplay.maxHealth = imgui.InputInt( "Maximum Health", config.gameplay.maxHealth)
        config.gameplay.startSize = imgui.InputInt( "Start Size             ", config.gameplay.startSize)
        imgui.PopItemWidth()
        imgui.Text( "\n" )
    end

    -- Royale Gameplay Options
    if imgui.CollapsingHeader( "Royale", { "DefaultOpen" } ) then
        imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.15)
        config.royale.shrinkEveryNTurns = imgui.InputInt( "Shrink every N Turns", config.royale.shrinkEveryNTurns)
        imgui.SameLine()
        config.royale.damagePerTurn = imgui.InputInt( "Damage Per Turn", config.royale.damagePerTurn)
        imgui.PopItemWidth()
        imgui.Text( "\n" )
    end

    -- Squads Gameplay Options
    if imgui.CollapsingHeader( "Squads", { "DefaultOpen" } ) then
        config.squads.allowBodyCollisions = imgui.Checkbox( "Allow Body Collisions", config.squads.allowBodyCollisions)
        config.squads.sharedElimination = imgui.Checkbox( "Shared Elimination", config.squads.sharedElimination)
        imgui.SameLine()
        config.squads.sharedHealth = imgui.Checkbox( "Shared Health", config.squads.sharedHealth)
        imgui.SameLine()
        config.squads.sharedLength = imgui.Checkbox( "Shared Length", config.squads.sharedLength)
        config.squads.squad1Color = {imgui.ColorEdit3("Squad 1 Color", unpack(config.squads.squad1Color))}
        config.squads.squad2Color = {imgui.ColorEdit3("Squad 2 Color", unpack(config.squads.squad2Color))}
        config.squads.squad3Color = {imgui.ColorEdit3("Squad 3 Color", unpack(config.squads.squad3Color))}
        config.squads.squad4Color = {imgui.ColorEdit3("Squad 4 Color", unpack(config.squads.squad4Color))}
        imgui.Text( "\n" )
    end

    -- Robosnake Options
    if imgui.CollapsingHeader( "Robosnake", { "DefaultOpen" } ) then
        imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.15)
        config.robosnake.maxAggressionSnakes = imgui.InputInt( "Max Aggression Snakes", config.robosnake.maxAggressionSnakes)
        imgui.SameLine()
        config.robosnake.recursionDepth = imgui.InputInt( "Recursion Depth", config.robosnake.recursionDepth)
        config.robosnake.hungerThreshold = imgui.InputInt( "Hunger Threshold     ", config.robosnake.hungerThreshold)
        imgui.SameLine()
        config.robosnake.lowFoodThreshold = imgui.InputInt( "Low Food Threshold", config.robosnake.lowFoodThreshold)
        imgui.PopItemWidth()
        imgui.Text( "\n" )
    end

    -- Save Options button and dialog
    if imgui.Button( "Save Changes##bottom", imgui.GetWindowContentRegionWidth() * 0.2, 50 ) then
        local ok = love.filesystem.write( 'config.json', json.encode( config ) )
        if not ok then
            error( 'Unable to write config.json' )
        end
        imgui.OpenPopup( "SaveOptions" )
    end
    if imgui.BeginPopupModal( "SaveOptions", nil, { "NoResize" } ) then
        imgui.Text( "Configuration changes have been saved.\n\n" )
        imgui.Separator()
        if imgui.Button( "OK" ) then
            imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
    end

    -- Revert Options button and dialog
    imgui.SameLine()
    if imgui.Button( "Revert Changes##bottom", imgui.GetWindowContentRegionWidth() * 0.2, 50 ) then
        imgui.OpenPopup( "RevertOptions" )
    end
    if imgui.BeginPopupModal( "RevertOptions", nil, { "NoResize" } ) then
        imgui.Text( "Are you sure you want to revert your changes?\n\n" )
        imgui.Separator()
        if imgui.Button( "OK" ) then
            config = Utils.get_or_create_config()
            imgui.CloseCurrentPopup()
        end
        imgui.SameLine()
        if imgui.Button( "Cancel" ) then
            imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
    end

end

return OptionsPane