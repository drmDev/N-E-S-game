-- entities/entity.lua
-- Base class for all game entities (classic OOP).
local Object = require("lib.classic")

local Entity = Object:extend()

function Entity:new(x, y, speed, scale)
    self.x         = x     or 0
    self.y         = y     or 0
    self.speed     = speed or 100
    self.scale     = scale or 1.5
    self.direction = "down"
    self.isMoving  = false
    self.world     = nil
    self.colW      = 0
    self.colH      = 0
    self.currentAnim = nil
    self.currentImg  = nil  -- per-animation image (Player uses this)
    self.img         = nil  -- single shared spritesheet (Wendy uses this)
end

function Entity:addToWorld(world, colW, colH)
    self.world = world
    self.colW  = colW
    self.colH  = colH
    world:add(self, self.x, self.y, colW, colH)
end

function Entity:move(dx, dy, dt)
    local tx = self.x + dx * self.speed * dt
    local ty = self.y + dy * self.speed * dt

    if self.world then
        self.x, self.y = self.world:move(self, tx, ty)
    else
        self.x = tx
        self.y = ty
    end

    self.isMoving = (dx ~= 0 or dy ~= 0)

    if     dx > 0 then self.direction = "right"
    elseif dx < 0 then self.direction = "left"
    elseif dy > 0 then self.direction = "down"
    elseif dy < 0 then self.direction = "up"
    end
end

function Entity:draw()
    local img = self.currentImg or self.img
    if self.currentAnim and img then
        love.graphics.push("all")
        love.graphics.setColor(1, 1, 1, 1)
        self.currentAnim:draw(img, math.floor(self.x), math.floor(self.y), 0, self.scale, self.scale)
        love.graphics.pop()
    end
end

return Entity
