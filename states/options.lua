-- states/options.lua
local Gamestate = require("lib.hump.gamestate")
local game      = require("game")
local constants = require("constants")
local input     = require("config")

-- assets\fonts\RasterForgeRegular-JpBgm.ttf
local optionsFont = love.graphics.newFont("assets/fonts/RasterForgeRegular-JpBgm.ttf", 75)
optionsFont:setFilter("nearest", "nearest")

local Options = {}

local TOTAL_ITEMS = #input.metadata + 1  -- bindings + back button

local LAYOUT = {
    HEADER_Y     = 20,
    HEADER_SCALE = 0.45,
    START_Y      = 75,
    ROW_SPACING  = 32,
    ICON_X       = 80,
    BINDING_X    = 240,
    LABEL_SCALE  = 0.20,
    BIND_SCALE   = 0.17,
    ICON_SCALE   = 1.2,
    REWIND_SCALE = 1.5,
}

local selection, isRemapping
local icons     = {}
local backBtn   = {}

function Options:init()
    for i, meta in ipairs(input.metadata) do
        if meta.type == "icon" then
            icons[i] = love.graphics.newImage(meta.path)
        end
    end
    local img    = love.graphics.newImage("assets/ui/menu/btn_rewind.png")
    backBtn.img  = img
    backBtn.w    = img:getWidth()  * LAYOUT.REWIND_SCALE
    backBtn.h    = img:getHeight() * LAYOUT.REWIND_SCALE
    backBtn.x    = (constants.VIRTUAL_WIDTH - backBtn.w) / 2
end

function Options:enter()
    selection   = 1
    isRemapping = false
end

local function resolveBindings(actionId)
    local key, pad = "NONE", "NONE"
    local bindings = input.config.controls[actionId]
    if not bindings then return key, pad end

    local KEY_PREFIX    = "key:"
    local BUTTON_PREFIX = "button:"

    for _, src in ipairs(bindings) do
        if key == "NONE" and src:sub(1, #KEY_PREFIX) == KEY_PREFIX then
            key = src:sub(#KEY_PREFIX + 1):upper()
        elseif pad == "NONE" and src:sub(1, #BUTTON_PREFIX) == BUTTON_PREFIX then
            pad = src:sub(#BUTTON_PREFIX + 1):upper()
        end
    end
    return key, pad
end

local function rowColor(i)
    if i == selection and isRemapping  then return 1, 1, 0      end
    if i == selection                  then return 1, 0.3, 0.3 end
    return 0.5, 0.5, 0.5
end

local function drawHeader()
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(optionsFont)
    local w = optionsFont:getWidth("OPTIONS") * LAYOUT.HEADER_SCALE
    love.graphics.print("OPTIONS", (constants.VIRTUAL_WIDTH - w) / 2, LAYOUT.HEADER_Y, 0, LAYOUT.HEADER_SCALE, LAYOUT.HEADER_SCALE)
    love.graphics.pop()
end

local function drawRow(i, meta, y)
    love.graphics.push("all")
    love.graphics.setColor(rowColor(i))

    if meta.type == "icon" and icons[i] then
        love.graphics.draw(icons[i], LAYOUT.ICON_X, y, 0, LAYOUT.ICON_SCALE, LAYOUT.ICON_SCALE)
    else
        love.graphics.setFont(optionsFont)
        love.graphics.print(meta.label, LAYOUT.ICON_X, y, 0, LAYOUT.LABEL_SCALE, LAYOUT.LABEL_SCALE)
    end

    local keyBind, padBind = resolveBindings(meta.id)
    local bindStr = ("Key: %s   |   Pad: %s"):format(keyBind, padBind)
    if isRemapping and i == selection then
        bindStr = "PRESS ANY INPUT TO REBIND..."
    end

    love.graphics.setFont(optionsFont)
    love.graphics.print(bindStr, LAYOUT.BINDING_X, y + 2, 0, LAYOUT.BIND_SCALE, LAYOUT.BIND_SCALE)
    love.graphics.pop()
end

local function drawRows()
    local y = LAYOUT.START_Y
    for i, meta in ipairs(input.metadata) do
        drawRow(i, meta, y)
        y = y + LAYOUT.ROW_SPACING
    end
    return y
end

local function drawBackButton(y)
    local by = y + 5
    love.graphics.push("all")
    love.graphics.setColor(rowColor(TOTAL_ITEMS))
    if selection == TOTAL_ITEMS then
        love.graphics.rectangle("line", backBtn.x - 4, by - 4, backBtn.w + 8, backBtn.h + 8)
    end
    love.graphics.draw(backBtn.img, backBtn.x, by, 0, LAYOUT.REWIND_SCALE, LAYOUT.REWIND_SCALE)
    love.graphics.pop()
end

function Options:draw()
    drawHeader()
    local y = drawRows()
    drawBackButton(y)
end

local function moveSelection(dir)
    game.audio.sfxNav:stop()
    game.audio.sfxNav:play()
    if dir == "up" then
        selection = selection - 1
        if selection < 1 then selection = TOTAL_ITEMS end
    else
        selection = selection + 1
        if selection > TOTAL_ITEMS then selection = 1 end
    end
end

local function startRemapping()
    isRemapping = true
end

local function goBackToTitle()
    game.audio.sfxSelect:stop()
    game.audio.sfxSelect:play()
    Gamestate.switch(require("states.title"))
end

local navigateActions = {
    up      = moveSelection,
    down    = moveSelection,
    confirm = function()
        if selection == TOTAL_ITEMS then
            goBackToTitle()
        else
            startRemapping()
        end
    end,
    back    = function() Gamestate.switch(require("states.title")) end,
}

local function navigate(dir)
    if isRemapping then return end
    local action = navigateActions[dir]
    if action then action(dir) end
end

local function rebind(value, deviceType)
    local meta = input.metadata[selection]
    if not meta then return end

    local prefix = (deviceType == "key") and "key:" or "button:"
    local updated = {}

    for _, src in ipairs(input.config.controls[meta.id]) do
        if not src:match("^" .. prefix) then
            table.insert(updated, src)
        end
    end

    table.insert(updated, prefix .. value)
    input.config.controls[meta.id] = updated
    isRemapping = false
end

function Options:keypressed(key)
    if isRemapping then rebind(key, "key"); return end
    if     key == "escape"                                  then navigate("back")
    elseif key == "up"    or key == "w"                     then navigate("up")
    elseif key == "down"  or key == "s"                     then navigate("down")
    elseif key == "return" or key == "space" or key == "z"  then navigate("confirm")
    end
end

function Options:gamepadpressed(_, btn)
    if isRemapping then rebind(btn, "pad"); return end
    if     btn == "back"                               then navigate("back")
    elseif btn == "dpup"                               then navigate("up")
    elseif btn == "dpdown"                             then navigate("down")
    elseif btn == "a" or btn == "start" or btn == "x"  then navigate("confirm")
    end
end

return Options