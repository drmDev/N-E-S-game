-- states/intro.lua
local Gamestate = require("lib.hump.gamestate")
local anim8     = require("lib.anim8")
local sti       = require("lib.sti")
local bump      = require("lib.bump")
local Player    = require("entities.player")
local input     = require("config")
local constants = require("constants")

local Intro = {}

local SCALE          = 1.5
local TV_PAD         = 12   -- pixel padding around TV AABB for interaction trigger

-- Assets loaded once across state re-entries
local lyingImg, promptSheet

local map, world, player
local lyingAnim, promptAnim
local tvObj, isLyingDown

local function findObject(layer, propType)
    if not (layer and layer.objects) then return nil end
    for _, obj in ipairs(layer.objects) do
        if obj.properties and obj.properties.type == propType then return obj end
    end
end

local function nearTv()
    if not tvObj then return false end
    return player.x + 16 > tvObj.x - TV_PAD
       and player.x      < tvObj.x + tvObj.width  + TV_PAD
       and player.y + 16 > tvObj.y - TV_PAD
       and player.y      < tvObj.y + tvObj.height  + TV_PAD
end

function Intro:enter()
    isLyingDown = true
    world = bump.newWorld(16)
    map   = sti("assets/worlds/intro_room/intro_room.lua", { "bump" })
    map:bump_init(world)

    if map.layers["Collidable"] then
        map.layers["Collidable"].visible = false
    end

    tvObj = findObject(map.layers["Collidable"], "tv")

    -- Load sprite assets once
    if not lyingImg then
        lyingImg = love.graphics.newImage("assets/sprites/characters/player/lying_down.png")
        lyingImg:setFilter("nearest", "nearest")
    end
    if not promptSheet then
        promptSheet = love.graphics.newImage("assets/ui/hud/action_prompt.png")
        promptSheet:setFilter("nearest", "nearest")
    end

    -- Animations are re-created each entry so they start fresh
    local lg = anim8.newGrid(21, 16, lyingImg:getWidth(), lyingImg:getHeight())
    lyingAnim = anim8.newAnimation(lg('6-1', 1), 0.50, 'pauseAtEnd')

    local pg = anim8.newGrid(20, 16, promptSheet:getWidth(), promptSheet:getHeight())
    promptAnim = anim8.newAnimation(pg('1-2', 1), 0.4)

    local startX = math.floor((constants.VIRTUAL_WIDTH  - 21 * SCALE) / 2)
    local startY = math.floor((constants.VIRTUAL_HEIGHT - 16 * SCALE) / 2)
    player = Player(startX, startY, world)
end

function Intro:update(dt)
    input:update()

    if isLyingDown then
        lyingAnim:update(dt)
        if lyingAnim.status == "paused" then isLyingDown = false end
    else
        player:update(dt)
        promptAnim:update(dt)

        if nearTv() and (input:pressed("action") or input:pressed("jump")) then
            Gamestate.switch(require("states.forest"))
        end
    end
end

function Intro:draw()
    map:draw()

    if isLyingDown then
        local cx = math.floor((constants.VIRTUAL_WIDTH  - 21 * SCALE) / 2)
        local cy = math.floor((constants.VIRTUAL_HEIGHT - 16 * SCALE) / 2)
        lyingAnim:draw(lyingImg, cx, cy, 0, SCALE, SCALE)
    else
        player:draw()

        if nearTv() and tvObj then
            local floatY = math.sin(love.timer.getTime() * 5) * 2
            local px = math.floor(tvObj.x + tvObj.width / 2 - 10)
            local py = math.floor(tvObj.y - 20 + floatY)
            promptAnim:draw(promptSheet, px, py)
        end
    end
end

return Intro