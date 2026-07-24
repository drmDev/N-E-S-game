-- states/forest.lua
local forest = {}

local sti = require("lib.sti")
local bump = require("lib.bump")
local wendy = require("entities.wendy")
local input = require("config")

local map
local world

function forest.load()
    world = bump.newWorld(16)
    map = sti("assets/worlds/forest_glitch/forest.lua", { "bump" })
    map:bump_init(world)

    local spawnX, spawnY = 100, 100

    if map.layers["Spawns"] and map.layers["Spawns"].objects then
        for _, obj in ipairs(map.layers["Spawns"].objects) do
            if obj.type == "wendy_spawn" or (obj.properties and obj.properties.type == "wendy_spawn") then
                spawnX = obj.x
                spawnY = obj.y
                break
            end
        end
    end

    wendy.load(spawnX, spawnY, world)
end

function forest.update(dt)
    input:update()
    wendy.update(dt)
end

function forest.draw()
    map:draw()
    wendy.draw()
end

return forest