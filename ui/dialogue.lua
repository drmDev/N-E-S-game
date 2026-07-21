-- ui/dialogue.lua
local Dialogue = {}

--- Draws a standardized dialogue box anchored over a target point
-- @param text string: The string message to display
-- @param anchorX number: Center X coordinate to position above
-- @param anchorY number: Top Y coordinate (e.g. character top)
-- @param scale number: Pixel scale factor
function Dialogue.drawOver(text, anchorX, anchorY, scale)
    scale = scale or 1
    local font = love.graphics.getFont()

    -- Design Metrics
    local textScale = 0.11
    local paddingX, paddingY = 10, 8

    -- Calculate Dynamic Size from Text Length
    local textWidth = font:getWidth(text) * textScale
    local textHeight = font:getHeight() * textScale
    local boxW = textWidth + (paddingX * 2)
    local boxH = textHeight + (paddingY * 2)

    -- Position Centered Above Target
    local boxX = math.floor(anchorX - (boxW / 2))
    local boxY = math.floor(anchorY - boxH - 8)

    -- TODO: replace with asset when ready    
    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH)
    love.graphics.print(text, boxX + paddingX, boxY + paddingY, 0, textScale, textScale)
    love.graphics.pop()
end

return Dialogue