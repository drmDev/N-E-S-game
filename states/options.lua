local options = {}
local constants = require("constants")
local controls = require("config")
local isRemapping = false
local TOTAL_ITEMS = #controls + 1 -- 6 control bindings + 1 back button
local BACK_BUTTON_INDEX = TOTAL_ITEMS

-- Scaled down rewind button for 640x360 space
local rewindBtn = { path = "assets/pngs/btnRewind.png", scale = 1.5 }

-- Handle navigation through the options menu
local function navigate(direction)
    if isRemapping then return end

    if direction == "up" or direction == "down" then
        State.SFX_Nav:play()
        State.CurrentOptionsSelection = options.getNewSelection(
            State.CurrentOptionsSelection,
            TOTAL_ITEMS,
            direction
        )
    elseif direction == "confirm" then
        State.SFX_Select:play()
        if State.CurrentOptionsSelection == BACK_BUTTON_INDEX then
            State.GameState = "title"
        else
            isRemapping = true
        end
    end
end

function options.getNewSelection(current, totalItems, direction)
    if direction == "up" then
        current = current - 1
        if current < 1 then
            return totalItems
        end
        return current
    elseif direction == "down" then
        current = current + 1
        if current > totalItems then
            return 1
        end
        return current
    end
    return current
end

-- Load images for controls and the rewind button
function options.load()
    for _, ctrl in ipairs(controls) do
        if ctrl.type == "icon" then
            ctrl.img = love.graphics.newImage(ctrl.path)
        end
    end

    rewindBtn.img = love.graphics.newImage(rewindBtn.path)
end

-- Draw function anchored and scaled to virtual resolution
function options.draw()
    local font = State.RF_Font or love.graphics.getFont()

    -- 1. Draw Title Header
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local headerText = "OPTIONS"
    local headerScale = 0.45
    local fontWidth = font:getWidth(headerText) * headerScale
    love.graphics.print(headerText, (constants.VIRTUAL_WIDTH - fontWidth) / 2, 20, 0, headerScale, headerScale)
    love.graphics.pop()

    -- 2. Draw Control Mapping List
    local startY = 75
    local rowSpacing = 32
    local iconX = 80
    local bindingX = 240
    local labelScale = 0.20
    local bindScale = 0.17

    for i, ctrl in ipairs(controls) do
        love.graphics.push("all")

        if i == State.CurrentOptionsSelection and not isRemapping then
            love.graphics.setColor(1, 0.3, 0.3)
        elseif i == State.CurrentOptionsSelection and isRemapping then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        -- Draw icon or text label
        if ctrl.type == "icon" then
            love.graphics.draw(ctrl.img, iconX, startY, 0, 1.2, 1.2)
        else
            love.graphics.print(ctrl.label, iconX, startY, 0, labelScale, labelScale)
        end

        -- Prepare binding string
        local bindStr = string.format("Key: %s   |   Pad: %s", ctrl.key:upper(), ctrl.pad:upper())
        if isRemapping and i == State.CurrentOptionsSelection then
            bindStr = "PRESS ANY INPUT REBIND TARGET..."
        end

        -- Render binding string with scaled dimensions
        love.graphics.print(bindStr, bindingX, startY + 2, 0, bindScale, bindScale)
        love.graphics.pop()

        startY = startY + rowSpacing
    end

    -- 3. Draw Rewind / Back Button
    love.graphics.push("all")

    local rwWidth = rewindBtn.img:getWidth() * rewindBtn.scale
    local rwHeight = rewindBtn.img:getHeight() * rewindBtn.scale
    local rwX = (constants.VIRTUAL_WIDTH - rwWidth) / 2
    local rwY = startY + 5

    if State.CurrentOptionsSelection == BACK_BUTTON_INDEX then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.rectangle("line", rwX - 4, rwY - 4, rwWidth + 8, rwHeight + 8)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end

    love.graphics.draw(rewindBtn.img, rwX, rwY, 0, rewindBtn.scale, rewindBtn.scale)
    love.graphics.pop()
end

-- Handle key press events for the options menu
function options.keypressed(key)
    if isRemapping then
        controls[State.CurrentOptionsSelection].key = key
        isRemapping = false
        return
    end

    if key == "escape" then
        State.GameState = "title"
    elseif key == "left" or key == "a" then navigate("left")
    elseif key == "right" or key == "d" then navigate("right")
    elseif key == "up" or key == "w" then navigate("up")
    elseif key == "down" or key == "s" then navigate("down")
    elseif key == "return" or key == "kpenter" or key == "space" or key == "z" then navigate("confirm")
    end
end

-- Gamepad button press events for the options menu
function options.gamepadpressed(_, button)
    if isRemapping then
        controls[State.CurrentOptionsSelection].pad = button
        isRemapping = false
        return
    end

    if button == "back" then
        State.GameState = "title"
    elseif button == "dpleft" then navigate("left")
    elseif button == "dpright" then navigate("right")
    elseif button == "dpup" then navigate("up")
    elseif button == "dpdown" then navigate("down")
    elseif button == "a" or button == "start" or button == "x" then navigate("confirm")
    end
end

return options