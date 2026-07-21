local intro = {}
local anim8 = require("lib.anim8")
local constants = require("constants")
local SpriteGen = require("lib.sprite_generator")

-- Main Character Assets
local spriteSheet
local charAnim

-- Programmatic Object Images
local imgDoor
local imgWindow
local imgTv

-- Array Grid Definitions (16x16)
local doorGrid = {
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"},
    {"D","B","B","B","B","B","B","B","B","B","B","B","B","B","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","B","B","B","B","B","B","B","B","B","B","B","B","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","Y","Y","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","Y","Y","B","B","B","D","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","B","B","B","B","B","B","B","B","B","B","B","B","B","D"},
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"},
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"}
}

local windowGrid = {
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","M","M","M","M","M","M","M","M","M","M","M","M","M","M","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","M","M","M","M","M","M","M","M","M","M","M","M","M","M","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"}
}

local tvGrid = {
    {"C","C","C","C","C","C","C","C","C","C","C","C","C","C","C","C"},
    {"C","D","D","D","D","D","D","D","D","D","D","D","D","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","D","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","D","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","Y","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","D","D","D","C"},
    {"C","D","D","D","D","D","D","D","D","D","D","D","D","D","D","C"},
    {"C","C","C","C","C","C","C","C","C","C","C","C","C","C","C","C"},
    {"C","D","D","D","D","D","D","D","D","D","D","D","D","D","D","C"},
    {"C","C","C","C","C","C","C","C","C","C","C","C","C","C","C","C"},
    {"C","D","D",".",".",".",".",".",".",".",".",".",".","D","D","C"},
    {"D","D",".",".",".",".",".",".",".",".",".",".",".",".","D","D"}
}


function intro.load()
    spriteSheet = love.graphics.newImage("assets/pngs/mainChar/lying_down.png")
    spriteSheet:setFilter("nearest", "nearest")

    local grid = anim8.newGrid(21, 16, spriteSheet:getWidth(), spriteSheet:getHeight())
    charAnim = anim8.newAnimation(grid('6-1', 1), 0.50, 'pauseAtEnd')

    -- Generate room objects from arrays
    imgDoor   = SpriteGen.fromGrid(doorGrid)
    imgWindow = SpriteGen.fromGrid(windowGrid)
    imgTv     = SpriteGen.fromGrid(tvGrid)
end

function intro.update(dt)
    charAnim:update(dt)
end

function intro.draw()
    -- Scale reduced to 3 to comfortably fit the 640x360 canvas space
    local scale = 3

    -- Center Player within the virtual grid
    local charX = math.floor((constants.VIRTUAL_WIDTH - (21 * scale)) / 2)
    local charY = math.floor((constants.VIRTUAL_HEIGHT - (16 * scale)) / 2)

    -- Object offsets tightened to keep elements on screen
    local doorX = math.floor((constants.VIRTUAL_WIDTH - (16 * scale)) / 2)
    local doorY = charY + 110

    local windowX = math.floor((constants.VIRTUAL_WIDTH - (16 * scale)) / 2)
    local windowY = charY - 110

    local tvX = charX + 160
    local tvY = charY

    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1)

    -- 1. Draw Room Environment Props
    love.graphics.draw(imgDoor, doorX, doorY, 0, scale, scale)
    love.graphics.draw(imgWindow, windowX, windowY, 0, scale, scale)
    love.graphics.draw(imgTv, tvX, tvY, 0, scale, scale)

    -- 2. Draw Main Character
    charAnim:draw(spriteSheet, charX, charY, 0, scale, scale)
    love.graphics.pop()

    -- 3. Draw Dialogue Box (scaled and positioned for 640x360 space)
    local boxW, boxH = 220, 30
    local boxX = math.floor(charX + ((21 * scale) / 2) - (boxW / 2)) -- Centered over sprite
    local boxY = charY - boxH - 12                                    -- Hovering just above head

    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH)
    
    -- Text placement slightly nudged to center within the resized dialogue box
    love.graphics.print("ow... my head... where am I?", boxX + 10, boxY + 10, 0, 0.11, 0.11)
    love.graphics.pop()
end

return intro