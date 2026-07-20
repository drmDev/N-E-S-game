-- main.lua
State = {
    GameState = "title",
    DebugMessage = "DEBUG: Command?",
    CurrentOptionsSelection = 1,
    MyFont = nil
}

local rfFontPath = "assets/fonts/RasterForgeRegular-JpBgm.ttf"
local optionsScreen = require ("states.options")
local titleScreen = require("states.title")

-- init
function love.load()
    love.mouse.setVisible(false)
    love.window.setMode(0, 0, { fullscreen = true, fullscreentype = "desktop", vsync = true })

    -- Load Textures + Font Elements
    MyFont = love.graphics.newFont(rfFontPath, 100)
    MyFont:setFilter("nearest", "nearest")
    love.graphics.setFont(MyFont)
    love.graphics.setDefaultFilter("nearest", "nearest")

    titleScreen.load()
    optionsScreen.load()
end

-- rendering --
function love.draw()
    if State.GameState == "title" then
        titleScreen.draw()
    elseif State.GameState == "options" then
        optionsScreen.draw()
    end

    -- Draw the persistent footer status logger
    love.graphics.push("all")
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(State.DebugMessage, 400, love.graphics.getHeight() - 80, 0, 0.4, 0.4)
    love.graphics.pop()
end

-- hardware event interceptors --
function love.keypressed(key)
    if State.GameState == "title" then
        titleScreen.keypressed(key)
    elseif State.GameState == "options" then
        optionsScreen.keypressed(key)
    end
end

-- gamepad event interceptor --
function love.gamepadpressed(joystick, button)
    if State.GameState == "title" then
        titleScreen.gamepadpressed(joystick, button)
    elseif State.GameState == "options" then
        optionsScreen.gamepadpressed(joystick, button)
    end
end