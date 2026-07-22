-- states/intro.lua
local intro = {}
local anim8 = require("lib.anim8")
local constants = require("constants")
local SpriteGen = require("lib.sprite_generator")
local Dialogue = require("ui.dialogue")
local sti = require("lib.sti")
local player = require("entities.player")
local input = require("config")

local isDialogueActive = true

local mainCharLyingDown
local charAnim
local map
local imgTv

local charX = 0
local charY = 0
local SCALE = 1.5

function intro.load()
    mainCharLyingDown = love.graphics.newImage("assets/pngs/mainChar/lying_down.png")
    mainCharLyingDown:setFilter("nearest", "nearest")

    local grid = anim8.newGrid(21, 16, mainCharLyingDown:getWidth(), mainCharLyingDown:getHeight())
    charAnim = anim8.newAnimation(grid('6-1', 1), 0.50, 'pauseAtEnd')

    map = sti("assets/maps/intro_room.lua")

    charX = math.floor((constants.VIRTUAL_WIDTH - (21 * SCALE)) / 2)
    charY = math.floor((constants.VIRTUAL_HEIGHT - (16 * SCALE)) / 2)

    player.load(charX, charY)
    Dialogue.start("ow... my head... where am I?")
end

function intro.update(dt)
    -- Baton must be updated every frame to track 'pressed' and 'released' states
    input:update()

    if isDialogueActive then
        charAnim:update(dt)
        Dialogue.update(dt)

        -- Discrete press checks using Baton
        if input:pressed("jump") or input:pressed("action") then
            local wasClosed = Dialogue.advance()
            if wasClosed then
                isDialogueActive = false
            end
        end
    else
        player.update(dt)
    end
end

function intro.draw()
    map:draw()

    if isDialogueActive then
        charAnim:draw(mainCharLyingDown, charX, charY, 0, SCALE, SCALE)
        Dialogue.drawBanner("ow... my head... where am I?")
    else
        player.draw()
    end
end

return intro