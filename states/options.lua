-- states/options.lua
local options = {}

local controls = require("config")
local isRemapping = false
local rewindBtn = { path = "assets/pngs/btnRewind.png", scale = 4 }

-- Handle navigation through the options menu
local function navigate(direction)
    if isRemapping then return end -- prevent navigation while remapping controls
    if direction == "up" then
        State.SFX_Nav:play()
        if State.CurrentOptionsSelection == 1 then -- wrap around to the last option when navigating up from the first option
            State.CurrentOptionsSelection = 7
        else
            State.CurrentOptionsSelection = State.CurrentOptionsSelection - 1
        end
    elseif direction == "down" then
        State.SFX_Nav:play()
        if State.CurrentOptionsSelection == 7 then -- wrap around to the first option when navigating down from the last option
            State.CurrentOptionsSelection = 1
        else
            State.CurrentOptionsSelection = State.CurrentOptionsSelection + 1
        end
    elseif direction == "confirm" then
        State.SFX_Select:play()

        if State.CurrentOptionsSelection == 7 then -- if the last option (rewind/back) is selected, go back to the title screen
            State.GameState = "title"
        else
            isRemapping = true
        end
    end
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

-- draw function --
function options.draw()
    local screenWidth = love.graphics.getWidth()

    love.graphics.push("all") -- save the current graphics state
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("OPTIONS", (screenWidth - love.graphics.getFont():getWidth("OPTIONS")) / 2, 100)
    love.graphics.pop() -- restore the previous graphics state

    local startY = 250

    -- Draw each control option in the menu
    for i, ctrl in ipairs(controls) do
        love.graphics.push("all")

        if i == State.CurrentOptionsSelection and not isRemapping then -- highlight the currently selected option in red
            love.graphics.setColor(1, 0.3, 0.3)
        elseif i == State.CurrentOptionsSelection and isRemapping then -- highlight the currently selected option in yellow while remapping
            love.graphics.setColor(1, 1, 0)
        else -- highlight the non-selected options in gray
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        -- Draw the control's icon or label based on its type
        if ctrl.type == "icon" then
            love.graphics.draw(ctrl.img, 300, startY, 0, 3, 3)
        else
            love.graphics.print(ctrl.label, 300, startY, 0, 0.4, 0.4)
        end

        -- Draw the key and pad bindings for the control
        local bindStr = string.format("Key: %s   |   Pad: %s", ctrl.key:upper(), ctrl.pad:upper())

        -- If the control is currently being remapped, show a prompt instead of the current bindings
        if isRemapping and i == State.CurrentOptionsSelection then
            bindStr = "PRESS ANY INPUT REBIND TARGET..."
        end

        -- Render the binding string for the control
        love.graphics.print(bindStr, 550, startY + 5, 0, 0.35, 0.35)
        love.graphics.pop() -- restore the previous graphics state for this control

        startY = startY + 70
    end

    love.graphics.push("all") -- save the current graphics state

    -- Draw the rewind button and highlight it if it is currently selected
    local rwX = (screenWidth - (rewindBtn.img:getWidth() * rewindBtn.scale)) / 2
    local rwY = startY + 30

    if State.CurrentOptionsSelection == 7 then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.rectangle("line", rwX - 6, rwY - 6, (rewindBtn.img:getWidth() * rewindBtn.scale) + 12, (rewindBtn.img:getHeight() * rewindBtn.scale) + 12)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end

    love.graphics.draw(rewindBtn.img, rwX, rwY, 0, rewindBtn.scale, rewindBtn.scale)
    love.graphics.pop() -- restore the previous graphics state for the rewind button
end

-- handle key press events for the options menu --
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

-- gamepad button press events for the options menu --
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