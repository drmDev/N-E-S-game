-- title.lua
local title = {}

-- Title-specific UI states insulated to this module
local titleButtons = {
    { name = "play",  path = "assets/pngs/playBtn.png",  scale = 5 },
    { name = "gear",  path = "assets/pngs/gearBtn.png",  scale = 5 },
    { name = "eject", path = "assets/pngs/ejectBtn.png", scale = 5 }
}
local currentTitleSelection = 1

-- navigation with wrapping handling
local function navigate(direction)
    if direction == "left" then
        currentTitleSelection = currentTitleSelection - 1
        -- Wrap around to the far right button if we drop below the first index
        if currentTitleSelection < 1 then
            currentTitleSelection = #titleButtons
        end

    elseif direction == "right" then
        currentTitleSelection = currentTitleSelection + 1
        -- Wrap around to the first button if we exceed the total button count
        if currentTitleSelection > #titleButtons then
            currentTitleSelection = 1
        end

    elseif direction == "confirm" then
        titleButtons[currentTitleSelection].action()
    end
end

-- Load the title screen assets and compute button positions
function title.load()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

    -- Map menu item confirmations to actions
    titleButtons[1].action = function() State.DebugMessage = "Debug: Start Game Triggered!" end
    titleButtons[2].action = function() State.GameState = "options"; State.CurrentOptionsSelection = 1 end
    titleButtons[3].action = function() love.event.quit() end

    -- Phase 1: Measure raw button dimensions
    local totalTitleWidth = 0
    local padding = 40

    for _, btn in ipairs(titleButtons) do
        btn.img = love.graphics.newImage(btn.path)
        btn.width = btn.img:getWidth() * btn.scale
        btn.height = btn.img:getHeight() * btn.scale

        -- Sum up just the button widths without worrying about padding gaps yet
        totalTitleWidth = totalTitleWidth + btn.width
    end

    -- Phase 2: Add all the inner padding gaps between the buttons at once
    totalTitleWidth = totalTitleWidth + (padding * (#titleButtons - 1))

    -- Phase 3: Compute screen coordinates and position elements
    local startX = (screenWidth - totalTitleWidth) / 2
    for _, btn in ipairs(titleButtons) do
        btn.x = startX
        btn.y = (screenHeight / 2)
        startX = startX + btn.width + padding -- keep moving the starting x-coordinate for the next button
    end
end

-- Draw the title screen, including the game title and menu buttons
function title.draw()
    local screenWidth = love.graphics.getWidth()

    love.graphics.push("all") -- Save the current graphics state
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("N / E / S", (screenWidth - MyFont:getWidth("N / E / S")) / 2, 200) -- Center the game title horizontally
    love.graphics.pop()

    -- Draw the menu buttons and highlight with a square
    for i, btn in ipairs(titleButtons) do
        love.graphics.push("all")

        if i == currentTitleSelection then
            love.graphics.setColor(1, 0.3, 0.3)
            love.graphics.rectangle("line", btn.x - 6, btn.y - 6, btn.width + 12, btn.height + 12) -- place a rectangle around the currently selected button
        else
            love.graphics.setColor(0.4, 0.4, 0.4) -- dims the color of the inactive buttons
        end

        -- Draw the button image at its computed position
        love.graphics.draw(btn.img, btn.x, btn.y, 0, btn.scale, btn.scale)
        love.graphics.pop() -- Restore the previous graphics state for the next button
    end
end

-- handle key press events for the title screen --
function title.keypressed(key)
    if key == "left" or key == "a" then navigate("left")
    elseif key == "right" or key == "d" then navigate("right")
    elseif key == "return" or key == "kpenter" or key == "space" or key == "z" then navigate("confirm")
    end
end

-- gamepad press events for the title screen --
function title.gamepadpressed(_, button)
    if button == "dpleft" then navigate("left")
    elseif button == "dpright" then navigate("right")
    elseif button == "a" or button == "start" or button == "x" then navigate("confirm")
    end
end

return title