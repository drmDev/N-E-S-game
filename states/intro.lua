-- states/intro.lua
local intro = {}
local anim8 = require("lib.anim8")
local constants = require("constants")
local SpriteGen = require("lib.sprite_generator")
local Dialogue = require("ui.dialogue")

local spriteSheet
local charAnim

local imgDoor
local imgWindow
local imgTv

-- TODO: replace these with actual assets
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

    imgDoor = SpriteGen.fromGrid(doorGrid)
    imgWindow = SpriteGen.fromGrid(windowGrid)
    imgTv = SpriteGen.fromGrid(tvGrid)
end

function intro.update(dt)
    charAnim:update(dt)
end

function intro.draw()
    local scale = 3

    local charX = math.floor((constants.VIRTUAL_WIDTH - (21 * scale)) / 2)
    local charY = math.floor((constants.VIRTUAL_HEIGHT - (16 * scale)) / 2)

    local doorX = math.floor((constants.VIRTUAL_WIDTH - (16 * scale)) / 2)
    local doorY = charY + 110

    local windowX = math.floor((constants.VIRTUAL_WIDTH - (16 * scale)) / 2)
    local windowY = charY - 110

    local tvX = charX + 160
    local tvY = charY

    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(imgDoor, doorX, doorY, 0, scale, scale)
    love.graphics.draw(imgWindow, windowX, windowY, 0, scale, scale)
    love.graphics.draw(imgTv, tvX, tvY, 0, scale, scale)

    charAnim:draw(spriteSheet, charX, charY, 0, scale, scale)
    love.graphics.pop()

    local headX = charX + ((21 * scale) / 2)
    Dialogue.drawOver("ow... my head... where am I?", headX, charY, scale)
end

return intro