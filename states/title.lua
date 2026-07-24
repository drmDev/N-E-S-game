-- states/title.lua
local title = {}
local constants = require("constants")
local currentTitleSelection = 1

local titleButtons = {
    { name = "play",  path = "assets/ui/menu/play_btn.png",  scale = 2 },
    { name = "gear",  path = "assets/ui/menu/gear_btn.png",  scale = 2 },
    { name = "eject", path = "assets/ui/menu/eject_btn.png", scale = 2 }
}

function title.load()
    titleButtons[1].action = function() -- play
        State.GameState = "intro"
    end

    titleButtons[2].action = function() -- gear/options
        State.GameState = "options"
        State.CurrentOptionsSelection = 1
    end

    titleButtons[3].action = function() -- eject/quit
        love.event.quit()
    end

    local totalTitleWidth = 0
    local padding = 24

    for _, btn in ipairs(titleButtons) do
        btn.img = love.graphics.newImage(btn.path)
        btn.width = btn.img:getWidth() * btn.scale
        btn.height = btn.img:getHeight() * btn.scale

        totalTitleWidth = totalTitleWidth + btn.width
    end

    totalTitleWidth = totalTitleWidth + (padding * (#titleButtons - 1))

    local startX = (constants.VIRTUAL_WIDTH - totalTitleWidth) / 2
    local startY = constants.VIRTUAL_HEIGHT * 0.55

    for _, btn in ipairs(titleButtons) do
        btn.x = startX
        btn.y = startY
        startX = startX + btn.width + padding
    end
end

function title.draw()
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local titleText = "N / E / S"
    local fontWidth = State.RF_Font:getWidth(titleText)
    love.graphics.print(titleText, (constants.VIRTUAL_WIDTH - fontWidth) / 2, 80)
    love.graphics.pop()

    -- TODO: refine colors used
    for i, btn in ipairs(titleButtons) do
        love.graphics.push("all")

        if i == currentTitleSelection then
            love.graphics.setColor(1, 0.3, 0.3) -- highlight selected button as reddish-pink
            love.graphics.rectangle("line", btn.x - 4, btn.y - 4, btn.width + 8, btn.height + 8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4) -- dim non-selected buttons
        end

        love.graphics.draw(btn.img, btn.x, btn.y, 0, btn.scale, btn.scale)
        love.graphics.pop()
    end
end

local function navigate(direction)
    if direction == "left" or direction == "right" then
        State.SFX_Nav:play()
        currentTitleSelection = title.getNewSelection(currentTitleSelection, #titleButtons, direction)

    elseif direction == "confirm" then
        State.SFX_Select:play()
        titleButtons[currentTitleSelection].action()
    end
end

function title.getNewSelection(current, totalItems, direction)
    if direction == "left" then
        current = current - 1
        if current < 1 then
            return totalItems
        end
        return current

    elseif direction == "right" then
        current = current + 1
        if current > totalItems then
            return 1
        end
        return current
    end

    return current
end

function title.keypressed(key)
    if key == "left" or key == "a" then navigate("left")
    elseif key == "right" or key == "d" then navigate("right")
    elseif key == "return" or key == "kpenter" or key == "space" or key == "z" then navigate("confirm")
    end
end

function title.gamepadpressed(_, button)
    if button == "dpleft" then navigate("left")
    elseif button == "dpright" then navigate("right")
    elseif button == "a" or button == "start" or button == "x" then navigate("confirm")
    end
end

return title