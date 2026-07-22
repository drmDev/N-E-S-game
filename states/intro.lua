-- states/intro.lua
local intro = {}
local anim8 = require("lib.anim8")
local constants = require("constants")
local SpriteGen = require("lib.sprite_generator")
local Dialogue = require("ui.dialogue")
local sti = require("lib.sti")
local player = require("entities.player")
local controls = require("config")

local isDialogueActive = true

local spriteSheet
local charAnim
local map
local imgTv

local charX = 0
local charY = 0
local SCALE = 1.5

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

    charX = math.floor((constants.VIRTUAL_WIDTH - (21 * SCALE)) / 2)
    charY = math.floor((constants.VIRTUAL_HEIGHT - (16 * SCALE)) / 2)

    player.load(charX, charY)
    Dialogue.start("ow... my head... where am I?")
end

function intro.update(dt)
    if isDialogueActive then
        charAnim:update(dt)
        Dialogue.update(dt)
    else
        player.update(dt)
    end
end

function intro.draw()
    map:draw()

    local tvX = charX + 180
    local tvY = charY

    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgTv, tvX, tvY, 0, SCALE, SCALE)

    if isDialogueActive then
        charAnim:draw(spriteSheet, charX, charY, 0, SCALE, SCALE)
        Dialogue.drawBanner("ow... my head... where am I?")
    else
        player.draw()
    end

    love.graphics.pop()
end

local function isActionTriggered(actionId, inputVal, inputType)
    for _, ctrl in ipairs(controls) do
        if ctrl.id == actionId then
            if inputType == "key" and ctrl.key == inputVal then
                return true
            elseif inputType == "pad" and ctrl.pad == inputVal then
                return true
            end
        end
    end
    return false
end

function intro.keypressed(key)
if Dialogue.isActive() and isActionTriggered("action", key, "key") then
        local wasClosed = Dialogue.advance()
        if wasClosed then
            isDialogueActive = false
        end
    end
end

function intro.gamepadpressed(_, button)
    if Dialogue.isActive() and isActionTriggered("action", button, "pad") then
        local wasClosed = Dialogue.advance()
        if wasClosed then
            isDialogueActive = false
        end
    end
end

return intro