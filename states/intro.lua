-- states/intro.lua
local intro = {}
local anim8 = require("lib.anim8")
local constants = require("constants")
local Dialogue = require("ui.dialogue")
local sti = require("lib.sti")
local bump = require("lib.bump")
local player = require("entities.player")
local input = require("config")

local isDialogueActive = true
local isDemoActive = false -- Tracks if we are in the DEMO exit dialogue

local mainCharLyingDown
local charAnim
local map
local world

local uiSheet
local promptAnim
local tvObj = nil

local charX = 0
local charY = 0
local SCALE = 1.5

function intro.load()
    mainCharLyingDown = love.graphics.newImage("assets/pngs/mainChar/lying_down.png")
    mainCharLyingDown:setFilter("nearest", "nearest")

    local grid = anim8.newGrid(21, 16, mainCharLyingDown:getWidth(), mainCharLyingDown:getHeight())
    charAnim = anim8.newAnimation(grid('6-1', 1), 0.50, 'pauseAtEnd')

    world = bump.newWorld(16)
    map = sti("assets/worlds/intro/intro_room.lua", { "bump" })
    map:bump_init(world)

    if map.layers["Collidable"] then
        map.layers["Collidable"].visible = false
    end

    -- Find the TV object from the "Collidable" object layer
    if map.layers["Collidable"] and map.layers["Collidable"].objects then
        for _, obj in ipairs(map.layers["Collidable"].objects) do
            if obj.properties and obj.properties.type == "tv" then
                tvObj = obj
                break
            end
        end
    end

    -- Load UI sheet 
    uiSheet = love.graphics.newImage("assets/ui/greenBtns.png")
    uiSheet:setFilter("nearest", "nearest")

    -- Precise 16x16 Quads for Green Button (Unpressed & Pressed)
    uiSheet = love.graphics.newImage("assets/ui/greenBtns.png")
    uiSheet:setFilter("nearest", "nearest")

    local buttonGrid = anim8.newGrid(20, 16, uiSheet:getWidth(), uiSheet:getHeight())
    promptAnim = anim8.newAnimation(buttonGrid('1-2', 1), 0.4)

    charX = math.floor((constants.VIRTUAL_WIDTH - (21 * SCALE)) / 2)
    charY = math.floor((constants.VIRTUAL_HEIGHT - (16 * SCALE)) / 2)

    player.load(charX, charY, world)
    Dialogue.start("ow... my head... where am I?")
end

local function checkTvProximity()
    if not tvObj then return false end

    local pad = 12 -- Proximity trigger distance around TV
    return (player.x + 16 > tvObj.x - pad) and
           (player.x < tvObj.x + tvObj.width + pad) and
           (player.y + 16 > tvObj.y - pad) and
           (player.y < tvObj.y + tvObj.height + pad)
end

function intro.update(dt)
    input:update()

    if isDialogueActive then
        charAnim:update(dt)
        Dialogue.update(dt)

        if input:pressed("jump") or input:pressed("action") then
            local wasClosed = Dialogue.advance()
            if wasClosed then
                isDialogueActive = false

                if isDemoActive then
                    love.event.quit()
                end
            end
        end
    else
        player.update(dt)
        promptAnim:update(dt)

        if checkTvProximity() and input:pressed("action") then
            Dialogue.start("DEMO")
            isDialogueActive = true
            isDemoActive = true
        end
    end
end

function intro.draw()
    map:draw()

    if isDialogueActive and not isDemoActive then
        charAnim:draw(mainCharLyingDown, charX, charY, 0, SCALE, SCALE)
    else
        player.draw()

        -- TODO: clean up to not do all this math
        if checkTvProximity() and tvObj and not isDialogueActive then
            local floatY = math.sin(love.timer.getTime() * 5) * 2
            local promptX = tvObj.x + (tvObj.width / 2) - 10
            local promptY = tvObj.y - 20 + floatY

            promptAnim:draw(uiSheet, math.floor(promptX), math.floor(promptY))
        end
    end

    if isDialogueActive then
        Dialogue.drawBanner()
    end
end

return intro