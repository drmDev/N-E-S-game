-- entities/player.lua
local Entity = require("entities.entity")
local anim8  = require("lib.anim8")
local input  = require("config")

local Player = Entity:extend()

local SCALE = 1.5
local COL_W = 13 * SCALE
local COL_H = 16 * SCALE

-- Each animation lives in its own PNG; frame dimensions vary per direction.
local SPRITE_CONFIG = {
    idle_down  = { path = "assets/sprites/characters/player/idle_down.png",  fw = 13, fh = 16, speed = 0.2 },
    idle_up    = { path = "assets/sprites/characters/player/idle_up.png",    fw = 11, fh = 16, speed = 0.2 },
    idle_right = { path = "assets/sprites/characters/player/idle_right.png", fw = 12, fh = 16, speed = 0.2 },
    idle_left  = { path = "assets/sprites/characters/player/idle_left.png",  fw = 12, fh = 16, speed = 0.2 },
    run_down   = { path = "assets/sprites/characters/player/run_down.png",   fw = 13, fh = 17, speed = 0.1 },
    run_up     = { path = "assets/sprites/characters/player/run_up.png",     fw = 13, fh = 17, speed = 0.1 },
    run_right  = { path = "assets/sprites/characters/player/run_right.png",  fw = 14, fh = 17, speed = 0.1 },
    run_left   = { path = "assets/sprites/characters/player/run_left.png",   fw = 14, fh = 17, speed = 0.1 },
}

function Player:new(x, y, world)
    Player.super.new(self, x, y, 100, SCALE)
    self.anims = {}
    self.imgs  = {}

    for key, cfg in pairs(SPRITE_CONFIG) do
        local img = love.graphics.newImage(cfg.path)
        img:setFilter("nearest", "nearest")
        local grid = anim8.newGrid(cfg.fw, cfg.fh, img:getWidth(), img:getHeight())
        self.anims[key] = anim8.newAnimation(grid('1-6', 1), cfg.speed)
        self.imgs[key]  = img
    end

    self.currentAnim = self.anims.idle_down
    self.currentImg  = self.imgs.idle_down
    self:addToWorld(world, COL_W, COL_H)
end

function Player:update(dt)
    local dx, dy = input:get("move")
    self:move(dx, dy, dt)

    local key = (self.isMoving and "run" or "idle") .. "_" .. self.direction
    self.currentAnim = self.anims[key]
    self.currentImg  = self.imgs[key]
    if self.currentAnim then self.currentAnim:update(dt) end
end

return Player