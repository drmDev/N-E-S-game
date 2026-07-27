-- entities/glitch_monster.lua
local Entity = require("entities.entity")
local anim8  = require("lib.anim8")

local GlitchMonster = Entity:extend()

-- State constants
GlitchMonster.STATES = {
    HIDDEN = "HIDDEN",
    LURKING = "LURKING",
    CHASING = "CHASING",
    ATTACKING = "ATTACKING",
    RETREATING = "RETREATING"
}

local SCALE = 1.5

function GlitchMonster:new(x, y)
    GlitchMonster.super.new(self, x, y, 0, SCALE)
    
    -- Position (fixed to screen, not world)
    self.baseX = x
    self.baseY = y
    
    -- Jitter effect
    self.jitterTimer = 0
    self.jitterInterval = 0.1
    self.jitterOffsetX = 0
    self.jitterOffsetY = 0
    self.jitterAmount = 3
    
    -- State management
    self.state = GlitchMonster.STATES.LURKING
    
    -- Appearance timing (for semi-random appearances)
    self.appearTimer = 0
    self.appearInterval = math.random(3, 8)
    self.isVisible = true
    
    -- Effect animation
    self.effectTime = 0
    
    -- Load sprite
    self.img = love.graphics.newImage("assets/sprites/enemies/glitch_monster.png")
    self.img:setFilter("nearest", "nearest")
    
    -- Create animations (same layout as Wendy)
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
    self.currentAnim = self.anims.idle_right
end

function GlitchMonster:setState(newState)
    self.state = newState
    
    if newState == GlitchMonster.STATES.LURKING then
        self.isVisible = true
        self.currentAnim = self.anims.idle_right
    elseif newState == GlitchMonster.STATES.HIDDEN then
        self.isVisible = false
    end
end

function GlitchMonster:update(dt)
    -- Update effect animation time
    self.effectTime = self.effectTime + dt
    
    -- Update jitter
    self.jitterTimer = self.jitterTimer + dt
    if self.jitterTimer >= self.jitterInterval then
        self.jitterTimer = 0
        self.jitterInterval = math.random(5, 15) / 100 -- 0.05 to 0.15 seconds
        self.jitterOffsetX = math.random(-self.jitterAmount, self.jitterAmount)
        self.jitterOffsetY = math.random(-self.jitterAmount, self.jitterAmount)
    end
    
    -- Update appearance timer (for semi-random appearances in LURKING state)
    if self.state == GlitchMonster.STATES.LURKING then
        self.appearTimer = self.appearTimer + dt
        if self.appearTimer >= self.appearInterval then
            self.appearTimer = 0
            self.appearInterval = math.random(3, 8)
            -- Could toggle visibility here for Phase 4
        end
    end
    
    -- Update animation
    if self.currentAnim then
        self.currentAnim:update(dt)
    end
    
    -- Update position with jitter
    self.x = self.baseX + self.jitterOffsetX
    self.y = self.baseY + self.jitterOffsetY
end

function GlitchMonster:draw()
    if not self.isVisible then return end
    
    -- DEBUG: Draw a visible rectangle first to confirm position
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 1, 0.5) -- Semi-transparent magenta
    love.graphics.rectangle("fill", self.x, self.y, 32, 32)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, 32, 32)
    love.graphics.pop()
    
    -- Draw with current animation
    if self.currentAnim and self.img then
        love.graphics.push("all")
        love.graphics.setColor(1, 1, 1, 1)
        self.currentAnim:draw(self.img, math.floor(self.x), math.floor(self.y), 0, self.scale, self.scale)
        love.graphics.pop()
    end
end

return GlitchMonster
