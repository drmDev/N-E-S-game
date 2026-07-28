-- entities/wendy.lua
local Entity = require("entities.entity")
local anim8 = require("lib.anim8")
local input = require("config")
local constants = require("constants")

local Wendy = Entity:extend()

local SCALE = 1.5
local COL_W = 16 * SCALE
local COL_H = 16 * SCALE

-- Single 64x112 spritesheet: 4 cols (down/up/left/right), 7 rows of frames.
-- Rows 1-4 = walk cycle.
function Wendy:new(x, y, world)
	Wendy.super.new(self, x, y, 100, SCALE)

	self.img = love.graphics.newImage("assets/sprites/characters/wendy/wendy.png")
	self.img:setFilter("nearest", "nearest")

	local grid = anim8.newGrid(16, 16, self.img:getWidth(), self.img:getHeight())
	self.anims = {
		idle_down = anim8.newAnimation(grid(1, 1), 0.2),
		idle_up = anim8.newAnimation(grid(2, 1), 0.2),
		idle_left = anim8.newAnimation(grid(3, 1), 0.2),
		idle_right = anim8.newAnimation(grid(4, 1), 0.2),
		run_down = anim8.newAnimation(grid(1, "1-4"), 0.15),
		run_up = anim8.newAnimation(grid(2, "1-4"), 0.15),
		run_left = anim8.newAnimation(grid(3, "1-4"), 0.15),
		run_right = anim8.newAnimation(grid(4, "1-4"), 0.15),
	}
	self.currentAnim = self.anims.run_right
	self:addToWorld(world, COL_W, COL_H)

	self.isJumping = false
	self.velocityY = 0
	self.jumpStartY = 0
	self.jumpSpeed = 250 -- negative = up in LOVE
	self.gravity = 1000 -- pixels per second
	self.moveSpeed = 200 -- free vertical movement speed
	self.jumpImg = love.graphics.newImage("assets/sprites/characters/wendy/wendy_jump.png")
	local jumpGrid = anim8.newGrid(16, 16, self.jumpImg:getWidth(), self.jumpImg:getHeight())
	self.jumpFrame = jumpGrid(4, 1) -- right-facing jump pose
end

function Wendy:update(dt)
	-- 1. Update animation
	if self.currentAnim then
		self.currentAnim:update(dt)
	end

	-- 2. Jump physics (if jumping)
	if self.isJumping then
		self.velocityY = self.velocityY + self.gravity * dt
		self.y = self.y + self.velocityY * dt

		-- Land when back at jump start Y
		if self.y >= self.jumpStartY then
			self.y = self.jumpStartY
			self.isJumping = false
			self.velocityY = 0
		end
	end

	-- 3. Free vertical movement (only when NOT jumping)
	if not self.isJumping then
		local _, dy = input:get("move") -- discard dx, only use dy
		self.y = self.y + dy * self.moveSpeed * dt
	end

	-- 4. Jump input via baton
	if input:pressed("jump") and not self.isJumping then
		self.velocityY = -self.jumpSpeed
		self.jumpStartY = self.y
		self.isJumping = true
	end

	-- 5. Clamp Y to screen bounds
	local halfH = 16 * self.scale / 2
	self.y = math.max(halfH, math.min(constants.VIRTUAL_HEIGHT - halfH, self.y))
end

function Wendy:draw()
	if self.isJumping then
		love.graphics.draw(
			self.jumpImg,
			self.jumpFrame[1],
			math.floor(self.x),
			math.floor(self.y),
			0,
			self.scale,
			self.scale
		)
	elseif self.currentAnim and self.img then
		self.currentAnim:draw(self.img, math.floor(self.x), math.floor(self.y), 0, self.scale, self.scale)
	end
end

return Wendy
