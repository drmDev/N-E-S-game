local anim8 = require("lib.anim8")
local input = require("config")

local wendy = {
    x = 0,
    y = 0,
    speed = 100,
    direction = "down",
    isMoving = false,
    scale = 1.5,
    anims = {},
    currentAnim = nil,
    img = nil
}

function wendy.load(startX, startY, world)
    wendy.x = startX or wendy.x
    wendy.y = startY or wendy.y
    wendy.world = world

    if wendy.world then
        wendy.world:add(wendy, wendy.x, wendy.y, 16 * wendy.scale, 16 * wendy.scale)
    end

    wendy.img = love.graphics.newImage("assets/sprites/characters/wendy/wendy.png")
    wendy.img:setFilter("nearest", "nearest")

    -- 64x112 image means 16x16 frames
    local grid = anim8.newGrid(16, 16, wendy.img:getWidth(), wendy.img:getHeight())

    -- Columns: 1=Down, 2=Up, 3=Left, 4=Right.
    -- Row 1 is used for Idle. Rows 1-4 are the Walking cycles.
    wendy.anims.idle_down  = anim8.newAnimation(grid(1, 1), 0.2)
    wendy.anims.idle_up    = anim8.newAnimation(grid(2, 1), 0.2)
    wendy.anims.idle_left  = anim8.newAnimation(grid(3, 1), 0.2)
    wendy.anims.idle_right = anim8.newAnimation(grid(4, 1), 0.2)

    wendy.anims.run_down  = anim8.newAnimation(grid(1, '1-4'), 0.15)
    wendy.anims.run_up    = anim8.newAnimation(grid(2, '1-4'), 0.15)
    wendy.anims.run_left  = anim8.newAnimation(grid(3, '1-4'), 0.15)
    wendy.anims.run_right = anim8.newAnimation(grid(4, '1-4'), 0.15)

    wendy.currentAnim = wendy.anims.idle_down
end

function wendy.update(dt)
    local dx, dy = input:get("move")

    local targetX = wendy.x + dx * wendy.speed * dt
    local targetY = wendy.y + dy * wendy.speed * dt

    if wendy.world then
        local actualX, actualY, cols, len = wendy.world:move(wendy, targetX, targetY)
        wendy.x = actualX
        wendy.y = actualY
    else
        wendy.x = targetX
        wendy.y = targetY
    end

    wendy.isMoving = (dx ~= 0 or dy ~= 0)

    if dx > 0 then
        wendy.direction = "right"
    elseif dx < 0 then
        wendy.direction = "left"
    elseif dy > 0 then
        wendy.direction = "down"
    elseif dy < 0 then
        wendy.direction = "up"
    end

    local state = wendy.isMoving and "run" or "idle"
    local animKey = state .. "_" .. wendy.direction

    wendy.currentAnim = wendy.anims[animKey]

    if wendy.currentAnim then
        wendy.currentAnim:update(dt)
    end
end

function wendy.draw()
    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1, 1)

    if wendy.currentAnim and wendy.img then
        wendy.currentAnim:draw(
            wendy.img,
            math.floor(wendy.x),
            math.floor(wendy.y),
            0,
            wendy.scale,
            wendy.scale
        )
    end

    love.graphics.pop()
end

return wendy