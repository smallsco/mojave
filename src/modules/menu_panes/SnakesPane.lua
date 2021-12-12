local SnakesPane = {}

-- Module Variables
local columnWidthIsSet = false
local newSnakeOK = true
local newSnakeError = ''
local newSnakeType = Snake.TYPES.API
local newSnakeName = ''
local newSnakeURL = ''
local newSnakeYear = 1
local newSnakeHead = 1
local newSnakeTail = 1
local snakeyears = {"2017", "2018"}
local newSnakeColor = {1, 1, 1}
local snakeHeadsSelect = {}
local snakeTailsSelect = {}

function SnakesPane.draw()

    -- Add New Snake form
    if imgui.CollapsingHeader( "Add New Snake", { "DefaultOpen" } ) then

        -- Grab head and tail names
        if #snakeHeadsSelect == 0 then
            for k, _ in pairs(snakeHeads) do
                if not (Utils.string_starts_with(k, "bwc-") or Utils.string_starts_with(k, "bfl-") or Utils.string_starts_with(k, "shac-")) then
                    table.insert(snakeHeadsSelect, k)
                    table.sort(snakeHeadsSelect)
                end
            end
        end
        if #snakeTailsSelect == 0 then
            for k, _ in pairs(snakeTails) do
                if not (Utils.string_starts_with(k, "bwc-") or Utils.string_starts_with(k, "bfl-") or Utils.string_starts_with(k, "shac-")) then
                    table.insert(snakeTailsSelect, k)
                    table.sort(snakeTailsSelect)
                end
            end
        end

        -- Snake Type
        imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.33)
        newSnakeType = imgui.RadioButton( "Battlesnake API", newSnakeType, Snake.TYPES.API )
        imgui.SameLine()
        newSnakeType = imgui.RadioButton( "Old Battlesnake API (2017-2018)", newSnakeType, Snake.TYPES.API_OLD )
        imgui.SameLine()
        newSnakeType = imgui.RadioButton( "Robosnake", newSnakeType, Snake.TYPES.ROBOSNAKE )
        imgui.SameLine()
        newSnakeType = imgui.RadioButton( "Human", newSnakeType, Snake.TYPES.HUMAN )
        imgui.PopItemWidth()

        -- Snake Name/URL
        if newSnakeType == Snake.TYPES.API_OLD then
            imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.25)
        else
            imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.33)
        end
        imgui.AlignTextToFramePadding()
        imgui.Text("Name")
        imgui.SameLine()
        newSnakeName = imgui.InputText( "##Name", newSnakeName, 256 )
        imgui.SameLine()
        if newSnakeType == Snake.TYPES.API or newSnakeType == Snake.TYPES.API_OLD then
            imgui.Text("URL")
            imgui.SameLine()
            newSnakeURL = imgui.InputText( "##URL", newSnakeURL, 256 )
        else
            imgui.Text("Color")
            imgui.SameLine()
            newSnakeColor = {imgui.ColorEdit3("##Color", unpack(newSnakeColor))}
            imgui.AlignTextToFramePadding()
            imgui.Text("Head")
            imgui.SameLine()
            newSnakeHead = imgui.Combo("##Head", newSnakeHead, snakeHeadsSelect, #snakeHeadsSelect)
            imgui.SameLine()
            imgui.Text("Tail")
            imgui.SameLine()
            newSnakeTail = imgui.Combo("##Tail", newSnakeTail, snakeTailsSelect, #snakeTailsSelect)
        end
        imgui.SameLine()
        imgui.PopItemWidth()
        if newSnakeType == Snake.TYPES.API_OLD then
            imgui.PushItemWidth(imgui.GetWindowContentRegionWidth() * 0.10)
            imgui.Text("Year")
            imgui.SameLine()
            newSnakeYear = imgui.Combo("##Year", newSnakeYear, snakeyears, #snakeyears)
            imgui.SameLine()
            imgui.PopItemWidth()
        end

        -- Error dialog
        if imgui.BeginPopupModal( "RefreshError", nil, { "NoResize", "AlwaysAutoResize" } ) then
            imgui.Text( string.format("Error adding new snake: %s\n\n", newSnakeError) )
            imgui.Separator()
            if imgui.Button( "OK" ) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end

        -- Add button
        if imgui.Button( "Add Snake", 90, 20 ) then
            local newSnakeOpts = {
                type = newSnakeType,
                name = newSnakeName
            }
            if newSnakeType == Snake.TYPES.API then
                newSnakeOpts.url = newSnakeURL
            elseif newSnakeType == Snake.TYPES.API_OLD then
                newSnakeOpts.url = newSnakeURL
                newSnakeOpts.apiversion = snakeyears[newSnakeYear]
            else
                newSnakeOpts.headSrc = snakeHeadsSelect[newSnakeHead]
                newSnakeOpts.tailSrc = snakeTailsSelect[newSnakeTail]
                newSnakeOpts.color = {newSnakeColor[1], newSnakeColor[2], newSnakeColor[3], 1}
            end
            local newSnake = Snake(newSnakeOpts)
            newSnakeOK, newSnakeError = newSnake:refresh()
            if newSnakeError then
                imgui.OpenPopup( "RefreshError" )
            end
        end
        imgui.Text( "\n" )
    end

    -- List all snakes loaded into the app
    if imgui.CollapsingHeader( "All Snakes", { "DefaultOpen" } ) then
        imgui.Columns( 4, "snakes_SnakesPane" )
        if not columnWidthIsSet then
            -- Imgui bug...
            -- Only set the column widths on the first frame, otherwise
            -- the user will be unable to manually resize the columns
            -- https://github.com/ocornut/imgui/issues/1655
            imgui.SetColumnWidth(0, 275)
            imgui.SetColumnWidth(1, 80)
            imgui.SetColumnWidth(2, 75)
            columnWidthIsSet = true
        end
        imgui.Separator()
        imgui.Text( "Name" )
        imgui.NextColumn()
        imgui.Text( "Type" )
        imgui.NextColumn()
        imgui.Text( "Preview" )
        imgui.NextColumn()
        imgui.Text( "Actions" )
        imgui.NextColumn()
        imgui.Separator()

        local count = 1
        for _, snake in pairs(snakes) do
            if count > 1 then
                imgui.Separator()
            end

            -- Snake Name / URL
            imgui.Text( snake.name )
            if snake.type == Snake.TYPES.API or snake.type == Snake.TYPES.API_OLD then
                imgui.Text( snake.url )
            end
            imgui.NextColumn()

            -- Snake Type
            if snake.type == Snake.TYPES.API then
                imgui.Text( "API v" .. snake.apiversion )
            elseif snake.type == Snake.TYPES.API_OLD then
                imgui.Text( "API " .. snake.apiversion )
            elseif snake.type == Snake.TYPES.ROBOSNAKE then
                imgui.Text( "Robosnake" )
            elseif snake.type == Snake.TYPES.HUMAN then
                imgui.Text( "Human" )
            end
            imgui.NextColumn()

            -- Body Preview
            if (snake.type == Snake.TYPES.API and snake.apiversion > 0) or snake.type == Snake.TYPES.ROBOSNAKE or snake.type == Snake.TYPES.HUMAN then
                local snakeHeight = imgui.GetTextLineHeight() * 2
                local head_scale_ratio = snake.headImg:getHeight() / snakeHeight
                local tail_scale_ratio = snake.tailImg:getHeight() / snakeHeight
                imgui.Image(
                        snake.tailImg,
                        snake.tailImg:getWidth() / tail_scale_ratio,
                        snakeHeight,
                        1, 0, 0, 1
                )
                imgui.SameLine(0,0)
                imgui.Image(
                        snake.headImg,
                        snake.headImg:getWidth() / head_scale_ratio,
                        snakeHeight,
                        0, 0, 1, 1
                )
            else
                imgui.Text("Not\navailable")
            end
            imgui.NextColumn()

            -- Refresh/Delete buttons
            if imgui.Button( string.format("Refresh##%s", snake.id) ) then
                snake:refresh()
            end
            imgui.SameLine()
            if imgui.Button( string.format("Remove##%s", snake.id) ) then
                snake:delete()
            end
            imgui.NextColumn()

            count = count + 1
        end

        imgui.Columns(1)
        imgui.Separator()
        imgui.Text( "\n" )
    end
end

return SnakesPane
