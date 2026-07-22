-- states/intro.lua
local intro = {}
local anim8 = require("lib.anim8")
local constants = require("constants")
local SpriteGen = require("lib.sprite_generator")
local Dialogue = require("ui.dialogue")
local sti = require("lib.sti")

local spriteSheet
local charAnim
local map

local imgTv

-- TODO: replace these with actual assets
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

    imgTv = SpriteGen.fromGrid(tvGrid)

    map = sti("assets/maps/intro_room.lua")
end

function intro.update(dt)
    charAnim:update(dt)
end

function intro.draw()
    map:draw()
    local scale = 2

    local charX = math.floor((constants.VIRTUAL_WIDTH - (21 * scale)) / 2)
    local charY = math.floor((constants.VIRTUAL_HEIGHT - (16 * scale)) / 2)

    local tvX = charX + 180
    local tvY = charY

    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgTv, tvX, tvY, 0, scale, scale)

    charAnim:draw(spriteSheet, charX, charY, 0, scale, scale)
    love.graphics.pop()

    Dialogue.drawBanner("ow... my head... where am I?")
end

return intro