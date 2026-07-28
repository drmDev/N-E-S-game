-- states/forest.lua
local sti = require("lib.sti")
local bump = require("lib.bump")
local Wendy = require("entities.wendy")
local input = require("config")
local game = require("game")
local constants = require("constants")

local Forest = {}

local map, world, wendy

local function findObject(layer, propType)
	if not (layer and layer.objects) then
		return nil
	end
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
	game.audio.bgm:setVolume(0.5)
	game.audio.bgm:play()
end

function Forest:enter()
	self.bombImg = love.graphics.newImage("assets/worlds/forest_glitch/bomb.png")
	self.bombImg:setFilter("nearest", "nearest")
	self.obstacles = {}
	self.spawnTimer = 0
	self.spawnInterval = 0.3 -- lower = more
	self.obstacleSpeed = 450 -- pixels/sec the obstacles scroll left
	self.hitDisplayTimer = 0 -- for showing HIT text
	self.hitFont = love.graphics.newFont(24) -- cache font for HIT text
	world = bump.newWorld(16)
	map = sti("assets/worlds/forest_glitch/forest.lua", { "bump" })
	map:bump_init(world)
	-- Force nearest filtering on all map tilesets
	for _, tileset in ipairs(map.tilesets) do
		tileset.image:setFilter("nearest", "nearest")
	end

	local spawnX, spawnY = 100, 100
	local spawn = findObject(map.layers["Spawns"], "wendy_spawn")
	if spawn then
		spawnX, spawnY = spawn.x, spawn.y
	end

	wendy = Wendy(spawnX, spawnY, world)
	changeTune()
end

function Forest:update(dt)
	input:update()
	wendy:update(dt)

	-- 1. Spawn obstacles
	self.spawnTimer = self.spawnTimer + dt
	if self.spawnTimer >= self.spawnInterval then
		self.spawnTimer = 0
		local x = constants.VIRTUAL_WIDTH
		local minY = 30
		local maxY = constants.VIRTUAL_HEIGHT - 30
		local y = love.math.random(minY, maxY)
		table.insert(self.obstacles, { x = x, y = y })
	end

	-- 2. Move obstacles left & remove off-screen
	for i = #self.obstacles, 1, -1 do
		local obs = self.obstacles[i]
		obs.x = obs.x - self.obstacleSpeed * dt
		if obs.x < -20 then
			table.remove(self.obstacles, i)
		end

		-- 3. Collision check (only when NOT jumping)
		if not wendy.isJumping then
			local wendyW = 16 * wendy.scale
			local wendyH = 16 * wendy.scale
			local bombW = self.bombImg:getWidth() * wendy.scale
			local bombH = self.bombImg:getHeight() * wendy.scale

			if
				wendy.x < obs.x + bombW
				and wendy.x + wendyW > obs.x
				and wendy.y < obs.y + bombH
				and wendy.y + wendyH > obs.y
			then
				-- HIT!
				self.hitDisplayTimer = 1.5 -- show for 1.5 seconds
				table.remove(self.obstacles, i)
			end
		end
	end

	-- 4. Countdown hit display timer
	if self.hitDisplayTimer > 0 then
		self.hitDisplayTimer = self.hitDisplayTimer - dt
	end
end

function Forest:draw()
	map:draw()
	wendy:draw()

	-- Draw obstacles
	for _, obs in ipairs(self.obstacles) do
		love.graphics.draw(self.bombImg, math.floor(obs.x), math.floor(obs.y), 0, wendy.scale, wendy.scale)
	end

	-- Draw HIT! text
	if self.hitDisplayTimer > 0 then
		love.graphics.push("all")
		love.graphics.setColor(1, 0, 0)
		love.graphics.setFont(self.hitFont)
		local text = "HIT!"
		local fw = self.hitFont:getWidth(text)
		love.graphics.print(text, (constants.VIRTUAL_WIDTH - fw) / 2, constants.VIRTUAL_HEIGHT / 2 - 20)
		love.graphics.pop()
	end
end

return Forest
