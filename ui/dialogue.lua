-- ui/dialogue.lua
local Dialogue = {}

Dialogue.state = "inactive" -- "inactive", "typing", "finished"
Dialogue.currentText = ""
Dialogue.visibleChars = 0
Dialogue.typeTimer = 0
Dialogue.TEXT_SPEED = 0.03

local BOX_SCALE = 0.6
local TEXT_COLOR = {0.1, 0.1, 0.1, 1}
local PADDING_X = 10 * BOX_SCALE
local PADDING_Y = 8 * BOX_SCALE

local boxImg = nil
local font = nil
local arrowImg = nil

local constants = require("constants")

local function ensureAssetsLoaded()
    if not love or not love.graphics then return end
    if not boxImg then
        boxImg = love.graphics.newImage("assets/pngs/dialog1.png")
        boxImg:setFilter("nearest", "nearest")
    end
    if not font then
        font = love.graphics.newFont("assets/fonts/KindlyRewind-BOon.ttf", 12)
        font:setFilter("nearest", "nearest")
    end
    if not arrowImg then
        arrowImg = love.graphics.newImage("assets/pngs/triangle.png")
        arrowImg:setFilter("nearest", "nearest")
    end
end

function Dialogue.start(text)
    Dialogue.currentText = text or ""
    Dialogue.visibleChars = 0
    Dialogue.typeTimer = 0

    if #Dialogue.currentText > 0 then
        Dialogue.state = "typing"
    else
        Dialogue.state = "inactive"
    end
end

function Dialogue.update(dt)
    if Dialogue.state ~= "typing" then return end

    Dialogue.typeTimer = Dialogue.typeTimer + dt

    if Dialogue.typeTimer >= Dialogue.TEXT_SPEED then
        Dialogue.typeTimer = Dialogue.typeTimer - Dialogue.TEXT_SPEED
        Dialogue.visibleChars = Dialogue.visibleChars + 1

        if Dialogue.visibleChars >= #Dialogue.currentText then
            Dialogue.visibleChars = #Dialogue.currentText
            Dialogue.state = "finished"
        end
    end
end

function Dialogue.advance()
    if Dialogue.state == "typing" then
        Dialogue.visibleChars = #Dialogue.currentText
        Dialogue.state = "finished"
        return false
    elseif Dialogue.state == "finished" then
        Dialogue.state = "inactive"
        Dialogue.currentText = ""
        Dialogue.visibleChars = 0
        return true
    end
    return false
end

function Dialogue.isActive()
    return Dialogue.state ~= "inactive"
end

function Dialogue.drawBanner(_)
    if not love or not love.graphics then return end
    ensureAssetsLoaded()

    if not boxImg or not font or not arrowImg then return end

    love.graphics.push("all")

    local boxW = boxImg:getWidth() * BOX_SCALE
    local boxH = boxImg:getHeight() * BOX_SCALE
    local boxX = math.floor((constants.VIRTUAL_WIDTH - boxW) / 2)
    local boxY = 10

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(boxImg, boxX, boxY, 0, BOX_SCALE, BOX_SCALE)

    love.graphics.setFont(font)
    love.graphics.setColor(TEXT_COLOR)

    local textX = boxX + PADDING_X
    local textY = boxY + PADDING_Y
    local maxTextWidth = boxW - (PADDING_X * 2)

    local displayedText = string.sub(Dialogue.currentText, 1, Dialogue.visibleChars)
    love.graphics.printf(displayedText, textX, textY, maxTextWidth, "center")

    if Dialogue.state == "finished" then
        local scale = BOX_SCALE + 0.5
        local promptX = boxX + boxW - (arrowImg:getWidth() * scale) - PADDING_X
        local promptY = boxY + boxH - (arrowImg:getHeight() * scale) - PADDING_Y

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(arrowImg, math.floor(promptX), math.floor(promptY), 0, scale, scale)
    end

    love.graphics.pop()
end

return Dialogue