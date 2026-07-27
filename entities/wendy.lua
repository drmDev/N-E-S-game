-- entities/wendy.lua
local Entity = require("entities.entity")
local anim8  = require("lib.anim8")
local input  = require("config")

local Wendy = Entity:extend()

local SCALE = 1.5
local COL_W = 16 * SCALE
local COL_H = 16 * SCALE

-- Single 64x112 spritesheet: 4 cols (down/up/left/right), 7 rows of frames.
-- Row 1 = idle. Rows 1-4 = walk cycle.
function Wendy:new(x, y, world, isAutoRunner)
    Wendy.super.new(self, x, y, 100, SCALE)

    self.img = love.graphics.newImage("assets/sprites/characters/wendy/wendy.png")
    self.img:setFilter("nearest", "nearest")

    local grid = anim8.newGrid(16, 16, self.img:getWidth(), self.img:getHeight())
    self.anims = {
        idle_down  = anim8.newAnimation(grid(1, 1),     0.2),
        idle_up    = anim8.newAnimation(grid(2, 1),     0.2),
        idle_left  = anim8.newAnimation(grid(3, 1),     0.2),
        idle_right = anim8.newAnimation(grid(4, 1),     0.2),
        run_down   = anim8.newAnimation(grid(1, '1-4'), 0.15),
        run_up     = anim8.newAnimation(grid(2, '1-4'), 0.15),
        run_left   = anim8.newAnimation(grid(3, '1-4'), 0.15),
        run_right  = anim8.newAnimation(grid(4, '1-4'), 0.15),
    }
    self.currentAnim = self.anims.run_right
    
    -- Auto-runner properties
    self.isAutoRunner = isAutoRunner or false
    if self.isAutoRunner then
        self.virtualX = 0              -- Position in world space
        self.forwardSpeed = 100        -- Pixels per second forward
        self.verticalSpeed = 120       -- Up/down movement speed
        
        -- Simplified jump properties
        self.isJumping = false         -- Currently in jump animation
        self.jumpTimer = 0             -- Time in current jump
        self.jumpDuration = 0.4        -- Total jump duration (seconds)
        self.jumpHeight = 60           -- How high to jump (pixels)
        self.jumpStartY = 0            -- Y position when jump started
        
        -- Vertical bounds
        self.minY = 50                 -- Top boundary
        self.maxY = 300                -- Bottom boundary
        
        -- Set initial position (use provided x, y)
        self.x = x
        self.y = y
        self.direction = "right"
    else
        self:addToWorld(world, COL_W, COL_H)
    end
end

function Wendy:update(dt)
    if self.isAutoRunner then
        self:updateAutoRunner(dt)
    else
        self:updateNormal(dt)
    end
end

function Wendy:updateNormal(dt)
    local dx, dy = input:get("move")
    self:move(dx, dy, dt)

    local key = (self.isMoving and "run" or "idle") .. "_" .. self.direction
    self.currentAnim = self.anims[key]
    if self.currentAnim then self.currentAnim:update(dt) end
end

function Wendy:updateAutoRunner(dt)
    -- Auto-forward progression
    self.virtualX = self.virtualX + self.forwardSpeed * dt
    
    -- Vertical input (only when not jumping)
    if not self.isJumping then
        local _, dy = input:get("move")
        if dy ~= 0 then
            self.y = self.y + dy * self.verticalSpeed * dt
            -- Clamp to vertical bounds
            self.y = math.max(self.minY, math.min(self.maxY, self.y))
        end
        
        -- Jump input - start jump from current Y position
        if input:pressed("jump") then
            self.isJumping = true
            self.jumpTimer = 0
            self.jumpStartY = self.y  -- Remember where we started
        end
    else
        -- Update jump animation
        self.jumpTimer = self.jumpTimer + dt
        
        -- Calculate jump arc using sine wave (smooth up and down)
        local progress = self.jumpTimer / self.jumpDuration
        if progress >= 1.0 then
            -- Jump complete - return to start Y
            self.isJumping = false
            self.y = self.jumpStartY
        else
            -- Sine wave: 0 -> 1 -> 0 over the duration
            local jumpOffset = math.sin(progress * math.pi) * self.jumpHeight
            self.y = self.jumpStartY - jumpOffset  -- Negative because Y increases downward
        end
    end
    
    -- Clamp to vertical bounds
    self.y = math.max(self.minY, math.min(self.maxY, self.y))
    
    -- Update animation (always running right)
    self.currentAnim = self.anims.run_right
    if self.currentAnim then
        self.currentAnim:update(dt)
    end
end

return Wendy