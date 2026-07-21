local options = {}
local constants = require("constants")
local controls = require("config")

local isRemapping = false
local TOTAL_ITEMS = #controls + 1
local BACK_BUTTON_INDEX = TOTAL_ITEMS

-- UI Layout Constants
local LAYOUT = {
    HEADER_Y = 20,
    HEADER_SCALE = 0.45,
    START_Y = 75,
    ROW_SPACING = 32,
    ICON_X = 80,
    BINDING_X = 240,
    LABEL_SCALE = 0.20,
    BIND_SCALE = 0.17,
    ICON_SCALE = 1.2,
    REWIND_SCALE = 1.5
}

local rewindBtn = { path = "assets/pngs/btnRewind.png", scale = LAYOUT.REWIND_SCALE }

function options.getNewSelection(current, totalItems, direction)
    if direction == "up" then
        current = current - 1
        if current < 1 then return totalItems end
        return current
    elseif direction == "down" then
        current = current + 1
        if current > totalItems then return 1 end
        return current
    end
    return current
end

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

function options.load()
    for _, ctrl in ipairs(controls) do
        if ctrl.type == "icon" then
            ctrl.img = love.graphics.newImage(ctrl.path)
        end
    end

    rewindBtn.img = love.graphics.newImage(rewindBtn.path)
    -- Precalculate image dimensions once on load
    rewindBtn.width = rewindBtn.img:getWidth() * rewindBtn.scale
    rewindBtn.height = rewindBtn.img:getHeight() * rewindBtn.scale
    rewindBtn.x = (constants.VIRTUAL_WIDTH - rewindBtn.width) / 2
end

function options.draw()
    local font = State.RF_Font or love.graphics.getFont()

    -- 1. Header
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local headerText = "OPTIONS"
    local fontWidth = font:getWidth(headerText) * LAYOUT.HEADER_SCALE
    love.graphics.print(headerText, (constants.VIRTUAL_WIDTH - fontWidth) / 2, LAYOUT.HEADER_Y, 0, LAYOUT.HEADER_SCALE, LAYOUT.HEADER_SCALE)
    love.graphics.pop()

    -- 2. Control Mapping List
    local currentY = LAYOUT.START_Y

    for i, ctrl in ipairs(controls) do
        love.graphics.push("all")

        if i == State.CurrentOptionsSelection and not isRemapping then
            love.graphics.setColor(1, 0.3, 0.3)
        elseif i == State.CurrentOptionsSelection and isRemapping then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        if ctrl.type == "icon" then
            love.graphics.draw(ctrl.img, LAYOUT.ICON_X, currentY, 0, LAYOUT.ICON_SCALE, LAYOUT.ICON_SCALE)
        else
            love.graphics.print(ctrl.label, LAYOUT.ICON_X, currentY, 0, LAYOUT.LABEL_SCALE, LAYOUT.LABEL_SCALE)
        end

        local bindStr = string.format("Key: %s   |   Pad: %s", ctrl.key:upper(), ctrl.pad:upper())
        if isRemapping and i == State.CurrentOptionsSelection then
            bindStr = "PRESS ANY INPUT REBIND TARGET..."
        end

        love.graphics.print(bindStr, LAYOUT.BINDING_X, currentY + 2, 0, LAYOUT.BIND_SCALE, LAYOUT.BIND_SCALE)
        love.graphics.pop()

        currentY = currentY + LAYOUT.ROW_SPACING
    end

    -- 3. Rewind / Back Button
    love.graphics.push("all")
    local rwY = currentY + 5

    if State.CurrentOptionsSelection == BACK_BUTTON_INDEX then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.rectangle("line", rewindBtn.x - 4, rwY - 4, rewindBtn.width + 8, rewindBtn.height + 8)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end

    love.graphics.draw(rewindBtn.img, rewindBtn.x, rwY, 0, rewindBtn.scale, rewindBtn.scale)
    love.graphics.pop()
end

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