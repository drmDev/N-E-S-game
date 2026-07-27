-- states/forest.lua
local sti   = require("lib.sti")
local bump  = require("lib.bump")
local Wendy = require("entities.wendy")
local GlitchMonster = require("entities.glitch_monster")
local moonshine = require("lib.moonshine")
local input = require("config")
local game  = require("game")
local constants = require("constants")

local Forest = {}

local map, world, wendy, glitchMonster
local camera
local glitchEffect

local function findObject(layer, propType)
    if not (layer and layer.objects) then return nil end
    for _, obj in ipairs(layer.objects) do
        if obj.type == propType or (obj.properties and obj.properties.type == propType) then
            return obj
        end
    end
end

local function changeTune()
    game.audio.bgm:stop()
    game.audio.bgm = love.audio.newSource("assets/audio/music/forest.ogg", "stream")
    game.audio.bgm:setLooping(true)
    game.audio.bgm:setVolume(0.3)
    game.audio.bgm:play()
end

function Forest:enter()
    world = bump.newWorld(16)
    map   = sti("assets/worlds/forest_glitch/forest.lua", { "bump" })
    map:bump_init(world)

    -- Initialize camera for auto-runner
    camera = {
        offsetX = 0,
        targetOffsetX = 0,
        smoothing = 0.1,
        screenWidth = constants.VIRTUAL_WIDTH,
        wendyScreenX = constants.VIRTUAL_WIDTH * 0.33  -- Wendy at 1/3 screen
    }

    -- Initialize Wendy in auto-runner mode
    local spawnX, spawnY = camera.wendyScreenX, 280
    local spawn = findObject(map.layers["Spawns"], "wendy_spawn")
    -- In auto-runner mode, we use fixed screen position, not spawn position
    
    wendy = Wendy(spawnX, spawnY, world, true)  -- true = auto-runner mode
    
    -- Initialize Glitch Monster at left edge
    local glitchSpawn = findObject(map.layers["Spawns"], "glitch_spawn")
    local glitchX = -30  -- Off-screen left
    local glitchY = 280
    if glitchSpawn then
        glitchY = glitchSpawn.y
    end
    
    glitchMonster = GlitchMonster(glitchX, glitchY)
    
    -- Initialize moonshine effects for Glitch Monster
    glitchEffect = moonshine(moonshine.effects.chromasep)
        .chain(moonshine.effects.pixelate)
        .chain(moonshine.effects.sketch)
        .chain(moonshine.effects.filmgrain)
    
    -- Configure effects
    glitchEffect.chromasep.radius = 3
    glitchEffect.chromasep.angle = 0
    glitchEffect.pixelate.size = {2, 2}
    glitchEffect.pixelate.feedback = 0.5
    glitchEffect.sketch.amp = 0.003
    glitchEffect.filmgrain.opacity = 0.4
    glitchEffect.filmgrain.size = 1
    
    changeTune()
    
    -- Debug output
    print("=== FOREST LEVEL LOADED ===")
    print("Wendy position:", wendy.x, wendy.y)
    print("Wendy virtualX:", wendy.virtualX)
    print("Glitch Monster position:", glitchMonster.x, glitchMonster.y)
    print("Camera wendyScreenX:", camera.wendyScreenX)
    print("Map loaded:", map ~= nil)
end

function Forest:update(dt)
    input:update()
    
    -- Update Wendy
    wendy:update(dt)
    
    -- Update camera to follow Wendy's virtual position
    camera.targetOffsetX = wendy.virtualX - camera.wendyScreenX
    camera.offsetX = camera.offsetX + (camera.targetOffsetX - camera.offsetX) * camera.smoothing
    
    -- Update Glitch Monster
    glitchMonster:update(dt)
    
    -- Animate glitch effect parameters
    glitchEffect.chromasep.angle = glitchMonster.effectTime * 2
end

function Forest:draw()
    -- Clear with background color for visibility
    love.graphics.clear(0.1, 0.1, 0.15, 1)
    
    -- Draw world with camera offset
    love.graphics.push()
    love.graphics.translate(-camera.offsetX, 0)
    
    -- Draw repeating map tiles
    -- Calculate map width in pixels (40 tiles * 16 pixels)
    local mapWidth = 40 * 16  -- 640 pixels
    local mapHeight = 23 * 16 -- 368 pixels
    
    -- Calculate how many times to repeat the map
    local startTile = math.floor(camera.offsetX / mapWidth)
    local endTile = math.ceil((camera.offsetX + camera.screenWidth) / mapWidth)
    
    -- Draw map multiple times to create seamless scrolling
    for i = startTile, endTile do
        love.graphics.push()
        love.graphics.translate(i * mapWidth, 0)
        map:draw()
        love.graphics.pop()
    end
    
    love.graphics.pop()
    
    -- Draw Wendy at fixed screen position (not affected by camera)
    wendy:draw()
    
    -- Draw Glitch Monster WITHOUT moonshine effects (temporarily disabled for debugging)
    -- glitchEffect(function()
        glitchMonster:draw()
    -- end)
    
    -- Enhanced debug info
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("=== PHASE 1: AUTO-RUNNER (DEBUG MODE) ===", 10, 10)
    love.graphics.print(string.format("VirtualX: %.0f", wendy.virtualX), 10, 30)
    love.graphics.print(string.format("Wendy Screen Pos: (%.0f, %.0f)", wendy.x, wendy.y), 10, 45)
    love.graphics.print(string.format("Jumping: %s | JumpTimer: %.2f", wendy.isJumping and "Yes" or "No", wendy.jumpTimer or 0), 10, 60)
    love.graphics.print(string.format("Camera Offset: %.0f", camera.offsetX), 10, 75)
    love.graphics.print(string.format("Glitch Monster: (%.0f, %.0f)", glitchMonster.x, glitchMonster.y), 10, 90)
    love.graphics.print(string.format("Glitch Visible: %s", glitchMonster.isVisible and "Yes" or "No"), 10, 105)
    love.graphics.print(string.format("Map Repeating: Yes"), 10, 120)
    
    -- Position markers for debugging
    love.graphics.setColor(1, 0, 0, 1) -- Red
    love.graphics.circle("fill", wendy.x, wendy.y, 5)
    love.graphics.print("Wendy", wendy.x + 10, wendy.y - 5)
    
    love.graphics.setColor(0, 1, 0, 1) -- Green
    love.graphics.circle("fill", glitchMonster.x + 50, glitchMonster.y, 5)
    love.graphics.print("Monster", glitchMonster.x + 60, glitchMonster.y - 5)
    
    love.graphics.setColor(1, 1, 0, 1) -- Yellow
    love.graphics.circle("fill", camera.wendyScreenX, 180, 5)
    love.graphics.print("Expected Wendy X", camera.wendyScreenX + 10, 175)
    
    -- Controls
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("UP/DOWN: Move | JUMP: Jump | CTRL+Q: Quit", 10, 340)
    love.graphics.print("Moonshine effects: DISABLED (for debugging)", 10, 320)
end

return Forest