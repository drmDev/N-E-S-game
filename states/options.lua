-- states/options.lua
local options = {}
local constants = require("constants")
local input = require("config")

local isRemapping = false
local TOTAL_ITEMS = #input.metadata + 1
local BACK_BUTTON_INDEX = TOTAL_ITEMS

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

local KEY_MAP = {
    escape    = "back",
    left      = "left",    a = "left",
    right     = "right",   d = "right",
    up        = "up",      w = "up",
    down      = "down",    s = "down",
    ["return"]= "confirm", kpenter = "confirm", space = "confirm", z = "confirm"
}

local PAD_MAP = {
    back    = "back",
    dpleft  = "left",
    dpright = "right",
    dpup    = "up",
    dpdown  = "down",
    a       = "confirm", start = "confirm", x = "confirm"
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
        if State.SFX_Nav then State.SFX_Nav:play() end
        State.CurrentOptionsSelection = options.getNewSelection(
            State.CurrentOptionsSelection,
            TOTAL_ITEMS,
            direction
        )
    elseif direction == "confirm" then
        if State.SFX_Select then State.SFX_Select:play() end
        if State.CurrentOptionsSelection == BACK_BUTTON_INDEX then
            State.GameState = "title"
        else
            isRemapping = true
        end
    end
end

function options.load()
    if not love or not love.graphics then return end -- Safety for unit tests
    
    for _, meta in ipairs(input.metadata) do
        if meta.type == "icon" then
            meta.img = love.graphics.newImage(meta.path)
        end
    end

    rewindBtn.img = love.graphics.newImage(rewindBtn.path)
    rewindBtn.width = rewindBtn.img:getWidth() * rewindBtn.scale
    rewindBtn.height = rewindBtn.img:getHeight() * rewindBtn.scale
    rewindBtn.x = (constants.VIRTUAL_WIDTH - rewindBtn.width) / 2
end

function options.draw()
    local font = State.RF_Font or love.graphics.getFont()

    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local headerText = "OPTIONS"
    local fontWidth = font:getWidth(headerText) * LAYOUT.HEADER_SCALE
    love.graphics.print(headerText, (constants.VIRTUAL_WIDTH - fontWidth) / 2, LAYOUT.HEADER_Y, 0, LAYOUT.HEADER_SCALE, LAYOUT.HEADER_SCALE)
    love.graphics.pop()

    local currentY = LAYOUT.START_Y

    for i, meta in ipairs(input.metadata) do
        love.graphics.push("all")

        if i == State.CurrentOptionsSelection and not isRemapping then
            love.graphics.setColor(1, 0.3, 0.3)
        elseif i == State.CurrentOptionsSelection and isRemapping then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        if meta.type == "icon" and meta.img then
            love.graphics.draw(meta.img, LAYOUT.ICON_X, currentY, 0, LAYOUT.ICON_SCALE, LAYOUT.ICON_SCALE)
        else
            love.graphics.print(meta.label, LAYOUT.ICON_X, currentY, 0, LAYOUT.LABEL_SCALE, LAYOUT.LABEL_SCALE)
        end

        -- Parse Baton's internal config to find the current Key and Pad bindings
        local keyBind, padBind = "NONE", "NONE"
        local bindings = input.config.controls[meta.id]
        
        if bindings then
            for _, source in ipairs(bindings) do
                if source:match("^key:") and keyBind == "NONE" then
                    keyBind = source:sub(5):upper()
                elseif source:match("^button:") and padBind == "NONE" then
                    padBind = source:sub(8):upper()
                end
            end
        end

        local bindStr = string.format("Key: %s   |   Pad: %s", keyBind, padBind)
        if isRemapping and i == State.CurrentOptionsSelection then
            bindStr = "PRESS ANY INPUT REBIND TARGET..."
        end

        love.graphics.print(bindStr, LAYOUT.BINDING_X, currentY + 2, 0, LAYOUT.BIND_SCALE, LAYOUT.BIND_SCALE)
        love.graphics.pop()

        currentY = currentY + LAYOUT.ROW_SPACING
    end

    love.graphics.push("all")
    local rewindAdjustedY = currentY + 5

    if State.CurrentOptionsSelection == BACK_BUTTON_INDEX then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.rectangle("line", rewindBtn.x - 4, rewindAdjustedY - 4, rewindBtn.width + 8, rewindBtn.height + 8)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end

    if rewindBtn.img then
        love.graphics.draw(rewindBtn.img, rewindBtn.x, rewindAdjustedY, 0, rewindBtn.scale, rewindBtn.scale)
    end
    love.graphics.pop()
end

local function handleInput(value, deviceType)
    if isRemapping then
        local actionId = input.metadata[State.CurrentOptionsSelection].id
        local prefix = (deviceType == "key") and "key:" or "button:"
        local newBindStr = prefix .. value

        local currentBinds = input.config.controls[actionId]
        local updatedBinds = {}

        -- Filter out old bindings of this specific device type, keep axes/others intact
        for _, source in ipairs(currentBinds) do
            if not source:match("^" .. prefix) then
                table.insert(updatedBinds, source)
            end
        end
        -- Append the new remapped input
        table.insert(updatedBinds, newBindStr)

        input.config.controls[actionId] = updatedBinds
        isRemapping = false
        return
    end

    local map = (deviceType == "key") and KEY_MAP or PAD_MAP
    local action = map[value]

    if action == "back" then
        State.GameState = "title"
    elseif action then
        navigate(action)
    end
end

function options.keypressed(key)
    handleInput(key, "key")
end

function options.gamepadpressed(_, button)
    handleInput(button, "pad")
end

return options