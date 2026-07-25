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
function Wendy:new(x, y, world)
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
    self.currentAnim = self.anims.idle_down
    self:addToWorld(world, COL_W, COL_H)
end

function Wendy:update(dt)
    local dx, dy = input:get("move")
    self:move(dx, dy, dt)

    local key = (self.isMoving and "run" or "idle") .. "_" .. self.direction
    self.currentAnim = self.anims[key]
    if self.currentAnim then self.currentAnim:update(dt) end
end

return Wendy