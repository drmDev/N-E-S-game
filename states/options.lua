-- states/options.lua
local Gamestate = require("lib.hump.gamestate")
local game      = require("game")
local constants = require("constants")
local input     = require("config")

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

function Options:enter()
    selection   = 1
    isRemapping = false

    -- Load assets once
    if not backBtn.img then
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
end

function Options:draw()
    -- Header
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local hw = game.font:getWidth("OPTIONS") * LAYOUT.HEADER_SCALE
    love.graphics.print("OPTIONS", (constants.VIRTUAL_WIDTH - hw) / 2, LAYOUT.HEADER_Y, 0, LAYOUT.HEADER_SCALE, LAYOUT.HEADER_SCALE)
    love.graphics.pop()

    local y = LAYOUT.START_Y
    for i, meta in ipairs(input.metadata) do
        love.graphics.push("all")

        if i == selection and isRemapping then
            love.graphics.setColor(1, 1, 0)
        elseif i == selection then
            love.graphics.setColor(1, 0.3, 0.3)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        if meta.type == "icon" and icons[i] then
            love.graphics.draw(icons[i], LAYOUT.ICON_X, y, 0, LAYOUT.ICON_SCALE, LAYOUT.ICON_SCALE)
        else
            love.graphics.print(meta.label, LAYOUT.ICON_X, y, 0, LAYOUT.LABEL_SCALE, LAYOUT.LABEL_SCALE)
        end

        local keyBind, padBind = "NONE", "NONE"
        local bindings = input.config.controls[meta.id]
        if bindings then
            for _, src in ipairs(bindings) do
                if src:match("^key:")    and keyBind == "NONE" then keyBind = src:sub(5):upper() end
                if src:match("^button:") and padBind == "NONE" then padBind = src:sub(8):upper() end
            end
        end

        local bindStr = ("Key: %s   |   Pad: %s"):format(keyBind, padBind)
        if isRemapping and i == selection then bindStr = "PRESS ANY INPUT TO REBIND..." end

        love.graphics.print(bindStr, LAYOUT.BINDING_X, y + 2, 0, LAYOUT.BIND_SCALE, LAYOUT.BIND_SCALE)
        love.graphics.pop()

        y = y + LAYOUT.ROW_SPACING
    end

    -- Back button
    love.graphics.push("all")
    local by = y + 5
    if selection == TOTAL_ITEMS then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.rectangle("line", backBtn.x - 4, by - 4, backBtn.w + 8, backBtn.h + 8)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end
    love.graphics.draw(backBtn.img, backBtn.x, by, 0, LAYOUT.REWIND_SCALE, LAYOUT.REWIND_SCALE)
    love.graphics.pop()
end

local function navigate(dir)
    if isRemapping then return end

    if dir == "up" or dir == "down" then
        game.audio.sfxNav:stop()
        game.audio.sfxNav:play()
        if dir == "up" then
            selection = selection - 1
            if selection < 1 then selection = TOTAL_ITEMS end
        else
            selection = selection + 1
            if selection > TOTAL_ITEMS then selection = 1 end
        end
    elseif dir == "confirm" then
        if selection == TOTAL_ITEMS then
            game.audio.sfxSelect:stop()
            game.audio.sfxSelect:play()
            Gamestate.switch(require("states.title"))
        else
            isRemapping = true
        end
    elseif dir == "back" then
        Gamestate.switch(require("states.title"))
    end
end

local function rebind(value, deviceType)
    local meta   = input.metadata[selection]
    if not meta then return end
    local prefix = (deviceType == "key") and "key:" or "button:"
    local current, updated = input.config.controls[meta.id], {}
    for _, src in ipairs(current) do
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
    if     key == "escape"                              then navigate("back")
    elseif key == "up"    or key == "w"                then navigate("up")
    elseif key == "down"  or key == "s"                then navigate("down")
    elseif key == "return" or key == "space" or key == "z" then navigate("confirm")
    end
end

function Options:gamepadpressed(_, btn)
    if isRemapping then rebind(btn, "pad"); return end
    if     btn == "back"                               then navigate("back")
    elseif btn == "dpup"                               then navigate("up")
    elseif btn == "dpdown"                             then navigate("down")
    elseif btn == "a" or btn == "start" or btn == "x" then navigate("confirm")
    end
end

return Options