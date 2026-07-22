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
    if isDialogueActive then
        charAnim:update(dt)
        Dialogue.update(dt)
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

local function isActionTriggered(actionIds, inputVal, inputType)
    if type(actionIds) == "string" then
        actionIds = { actionIds }
    end

    for _, ctrl in ipairs(controls) do
        for _, id in ipairs(actionIds) do
            if ctrl.id == id then
                if inputType == "key" and ctrl.key == inputVal then
                    return true
                elseif inputType == "pad" and ctrl.pad == inputVal then
                    return true
                end
            end
        end
    end
    return false
end

local ADVANCE_ACTIONS = { "jump", "action" }
function intro.keypressed(key)
    if Dialogue.isActive() and isActionTriggered(ADVANCE_ACTIONS, key, "key") then
        local wasClosed = Dialogue.advance()
        if wasClosed then
            isDialogueActive = false
        end
    end
end

function intro.gamepadpressed(_, button)
    if Dialogue.isActive() and isActionTriggered(ADVANCE_ACTIONS, button, "pad") then
        local wasClosed = Dialogue.advance()
        if wasClosed then
            isDialogueActive = false
        end
    end
end

return intro