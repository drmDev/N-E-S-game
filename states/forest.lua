-- states/forest.lua
local sti   = require("lib.sti")
local bump  = require("lib.bump")
local Wendy = require("entities.wendy")
local input = require("config")

local Forest = {}

local map, world, wendy

local function findObject(layer, propType)
    if not (layer and layer.objects) then return nil end
    for _, obj in ipairs(layer.objects) do
        if obj.type == propType or (obj.properties and obj.properties.type == propType) then
            return obj
        end
    end
end

function Forest:enter()
    world = bump.newWorld(16)
    map   = sti("assets/worlds/forest_glitch/forest.lua", { "bump" })
    map:bump_init(world)

    local spawnX, spawnY = 100, 100
    local spawn = findObject(map.layers["Spawns"], "wendy_spawn")
    if spawn then spawnX, spawnY = spawn.x, spawn.y end

    wendy = Wendy(spawnX, spawnY, world)
end

function Forest:update(dt)
    input:update()
    wendy:update(dt)
end

function Forest:draw()
    map:draw()
    wendy:draw()
end

return Forest