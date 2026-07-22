-- entities/player.lua
local anim8 = require("lib.anim8")
local controls = require("config")

local player = {
    x = 300,
    y = 180,
    speed = 100,
    direction = "down",
    isMoving = false,
    scale = 1.5,
    anims = {},
    imgs = {},
    currentAnim = nil,
    currentImg = nil
}

function player.load(startX, startY)
    player.x = startX or player.x
    player.y = startY or player.y

    local function loadAnim(path, frameW, frameH, speed)
        local img = love.graphics.newImage(path)
        img:setFilter("nearest", "nearest")
        local grid = anim8.newGrid(frameW, frameH, img:getWidth(), img:getHeight())
        return anim8.newAnimation(grid('1-6', 1), speed), img
    end

    player.anims.idle_down,  player.imgs.idle_down  = loadAnim("assets/pngs/mainChar/idle_down.png", 13, 16, 0.2)
    player.anims.idle_up,    player.imgs.idle_up    = loadAnim("assets/pngs/mainChar/idle_up.png", 11, 16, 0.2)
    player.anims.idle_right, player.imgs.idle_right = loadAnim("assets/pngs/mainChar/idle_right.png", 12, 16, 0.2)
    player.anims.idle_left,  player.imgs.idle_left  = loadAnim("assets/pngs/mainChar/idle_left.png", 12, 16, 0.2)

    player.anims.run_down,  player.imgs.run_down  = loadAnim("assets/pngs/mainChar/run_down.png", 13, 17, 0.1)
    player.anims.run_up,    player.imgs.run_up    = loadAnim("assets/pngs/mainChar/run_up.png", 13, 17, 0.1)
    player.anims.run_right, player.imgs.run_right = loadAnim("assets/pngs/mainChar/run_right.png", 14, 17, 0.1)
    player.anims.run_left,  player.imgs.run_left  = loadAnim("assets/pngs/mainChar/run_left.png", 14, 17, 0.1)

    player.currentAnim = player.anims.idle_down
    player.currentImg = player.imgs.idle_down
end

local function isActionActive(action)
    local joysticks = love.joystick.getJoysticks()
    for _, control in ipairs(controls) do
        if control.id == action then
            if control.key and love.keyboard.isDown(control.key) then
                return true
            end
            if joysticks[1] and joysticks[1]:isGamepad() and control.pad and joysticks[1]:isGamepadDown(control.pad) then
                return true
            end
        end
    end
    return false
end

function player.update(dt)
    local dx, dy = 0, 0

    if isActionActive("up")    then dy = dy - 1 end
    if isActionActive("down")  then dy = dy + 1 end
    if isActionActive("left")  then dx = dx - 1 end
    if isActionActive("right") then dx = dx + 1 end

    -- Fix diagonal speed calculations
    local isHoldingBothSideVert = (dx ~= 0 and dy ~= 0)
    if isHoldingBothSideVert then
        local norm = 1 / math.sqrt(2)
        dx = dx * norm
        dy = dy * norm
    end

    local newlyCalculatedX = player.x + dx * player.speed * dt
    local newlyCalculatedY = player.y + dy * player.speed * dt
    player.x = newlyCalculatedX
    player.y = newlyCalculatedY

    player.isMoving = (dx ~= 0 or dy ~= 0)

    if dx > 0 then
        player.direction = "right"
    elseif dx < 0 then
        player.direction = "left"
    elseif dy > 0 then
        player.direction = "down"
    elseif dy < 0 then
        player.direction = "up"
    end

    local state
    if player.isMoving then
        state = "run"
    else
        state = "idle"
    end

    local animKey = state .. "_" .. player.direction
    player.currentAnim = player.anims[animKey]
    player.currentImg = player.imgs[animKey]

    if player.currentAnim then
        player.currentAnim:update(dt)
    end
end

function player.draw()
    love.graphics.push("all")

    love.graphics.setColor(1, 1, 1, 1)

    if player.currentAnim and player.currentImg then
        player.currentAnim:draw(
            player.currentImg,
            math.floor(player.x),
            math.floor(player.y),
            0,
            player.scale,
            player.scale
        )
    end

    love.graphics.pop()
end

return player