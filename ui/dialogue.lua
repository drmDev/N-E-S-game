local Dialogue = {}
local constants = require("constants")

local boxImg = love.graphics.newImage("assets/pngs/dialog1.png")
boxImg:setFilter("nearest", "nearest")

local font = love.graphics.newFont("assets/fonts/KindlyRewind-BOon.ttf", 12)
font:setFilter("nearest", "nearest")

-- Config constants scoped locally to the module
local BOX_SCALE = 0.6
local TEXT_COLOR = {0.1, 0.1, 0.1, 1}
local PADDING_X = 10 * BOX_SCALE
local PADDING_Y = 8 * BOX_SCALE

function Dialogue.drawBanner(text)
    love.graphics.push("all")

    local boxW = boxImg:getWidth() * BOX_SCALE
    local boxX = math.floor((constants.VIRTUAL_WIDTH - boxW) / 2)
    local boxY = 10

    -- Draw box
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(boxImg, boxX, boxY, 0, BOX_SCALE, BOX_SCALE)

    -- Draw text
    love.graphics.setFont(font)
    love.graphics.setColor(TEXT_COLOR)

    local textX = boxX + PADDING_X
    local textY = boxY + PADDING_Y
    local maxTextWidth = boxW - (PADDING_X * 2)

    love.graphics.printf(text, textX, textY, maxTextWidth, "center")

    love.graphics.pop()
end

return Dialogue