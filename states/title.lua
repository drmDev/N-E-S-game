-- states/title.lua
local Gamestate = require("lib.hump.gamestate")
local game      = require("game")
local constants = require("constants")

local Title = {}

local SCALE   = 2
local PADDING = 24

local buttons = {
    { path = "assets/ui/menu/play_btn.png"  },
    { path = "assets/ui/menu/gear_btn.png"  },
    { path = "assets/ui/menu/eject_btn.png" },
}
local selection = 1

function Title:enter()
    selection = 1

    -- Load images once; positions depend on loaded sizes so always recompute.
    local totalW = 0
    for _, btn in ipairs(buttons) do
        if not btn.img then
            btn.img = love.graphics.newImage(btn.path)
        end
        btn.w    = btn.img:getWidth()  * SCALE
        btn.h    = btn.img:getHeight() * SCALE
        totalW   = totalW + btn.w
    end
    totalW = totalW + PADDING * (#buttons - 1)

    local x = (constants.VIRTUAL_WIDTH - totalW) / 2
    local y = constants.VIRTUAL_HEIGHT * 0.55
    for _, btn in ipairs(buttons) do
        btn.x = x
        btn.y = y
        x = x + btn.w + PADDING
    end
end

function Title:draw()
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local text = "N / E / S"
    local fw = game.font:getWidth(text) * 0.45
    love.graphics.print(text, (constants.VIRTUAL_WIDTH - fw) / 2, 80, 0, 0.45, 0.45)
    love.graphics.pop()

    for i, btn in ipairs(buttons) do
        love.graphics.push("all")
        if i == selection then
            love.graphics.setColor(1, 0.3, 0.3)
            love.graphics.rectangle("line", btn.x - 4, btn.y - 4, btn.w + 8, btn.h + 8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end
        love.graphics.draw(btn.img, btn.x, btn.y, 0, SCALE, SCALE)
        love.graphics.pop()
    end
end

local function navigate(dir)
    if dir == "left" or dir == "right" then
        game.audio.sfxNav:stop()
        game.audio.sfxNav:play()
        if dir == "left" then
            selection = selection - 1
            if selection < 1 then selection = #buttons end
        else
            selection = selection + 1
            if selection > #buttons then selection = 1 end
        end
    elseif dir == "confirm" then
        game.audio.sfxSelect:stop()
        game.audio.sfxSelect:play()
        if selection == 1 then
            Gamestate.switch(require("states.intro"))
        elseif selection == 2 then
            Gamestate.switch(require("states.options"))
        elseif selection == 3 then
            love.event.quit()
        end
    end
end

function Title:keypressed(key)
    if     key == "left"  or key == "a"                        then navigate("left")
    elseif key == "right" or key == "d"                        then navigate("right")
    elseif key == "return" or key == "space" or key == "z"     then navigate("confirm")
    end
end

function Title:gamepadpressed(_, btn)
    if     btn == "dpleft"                                     then navigate("left")
    elseif btn == "dpright"                                    then navigate("right")
    elseif btn == "a" or btn == "start" or btn == "x"         then navigate("confirm")
    end
end

return Title