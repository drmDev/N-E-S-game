-- main.lua
local Gamestate = require("lib.hump.gamestate")
local constants = require("constants")
local game      = require("game")

local Title = require("states.title")

-- 640x360 virtual canvas for pixel-perfect rendering
local canvas = love.graphics.newCanvas(constants.VIRTUAL_WIDTH, constants.VIRTUAL_HEIGHT)
canvas:setFilter("nearest", "nearest")

function love.load()
    love.mouse.setVisible(false)
    love.window.maximize()
    love.graphics.setDefaultFilter("nearest", "nearest")

    game.font = love.graphics.newFont("assets/fonts/KindlyRewind-BOon.ttf", 16)
    game.font:setFilter("nearest", "nearest")
    love.graphics.setFont(game.font)

    game.audio.bgm = love.audio.newSource("assets/audio/music/intro.ogg", "stream")
    game.audio.bgm:setLooping(true)
    game.audio.bgm:setVolume(0.5)
    game.audio.bgm:play()

    game.audio.sfxSelect = love.audio.newSource("assets/audio/sfx/select.wav", "static")
    game.audio.sfxSelect:setVolume(0.5)
    game.audio.sfxNav = love.audio.newSource("assets/audio/sfx/nav.ogg", "static")
    game.audio.sfxNav:setVolume(0.5)

    Gamestate.switch(Title)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0)
    Gamestate.draw()
    love.graphics.setCanvas()

    local ww, wh = love.graphics.getDimensions()
    local scale  = math.min(ww / constants.VIRTUAL_WIDTH, wh / constants.VIRTUAL_HEIGHT)
    local ox     = math.floor((ww - constants.VIRTUAL_WIDTH  * scale) / 2)
    local oy     = math.floor((wh - constants.VIRTUAL_HEIGHT * scale) / 2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, ox, oy, 0, scale, scale)
end

function love.keypressed(key, scancode)
    Gamestate.keypressed(key, scancode)
end

function love.gamepadpressed(js, btn)
    Gamestate.gamepadpressed(js, btn)
end