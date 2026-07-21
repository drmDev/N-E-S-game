-- main.lua
State = {
    GameState = "title",
    CurrentOptionsSelection = 1,
    RF_Font = nil,
    BGM = nil,
    SFX_Select = nil,
    SFX_Nav = nil
}

local rfFontPath = "assets/fonts/RasterForgeRegular-JpBgm.ttf"
local optionsScreen = require ("states.options")
local titleScreen = require("states.title")
local introScreen = require("states.intro")
local push = require("lib.push")

-- Virtual dimensions your game logic targets
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 640, 360
-- Default window startup dimensions
local WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720

-- init
function love.load()
    love.mouse.setVisible(false)

    -- Configure push canvas
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        pixelperfect = true -- Keeps pixels crisp during integer scaling
    })

    State.BGM = love.audio.newSource("assets/oggs/intro.ogg", "stream")
    State.BGM:setLooping(true)
    State.BGM:setVolume(0.5) -- Adjust volume between 0.0 and 1.0
    State.BGM:play()

    State.SFX_Select = love.audio.newSource("assets/wavs/select.wav", "static")
    State.SFX_Select:setVolume(0.5) -- Adjust volume between 0.0 and 1.0
    State.SFX_Nav = love.audio.newSource("assets/oggs/nav.ogg", "static")
    State.SFX_Nav:setVolume(0.5) -- Adjust volume between 0.0 and 1.0

    -- Load Textures + Font Elements
    State.RF_Font = love.graphics.newFont(rfFontPath, 100)
    State.RF_Font:setFilter("nearest", "nearest")
    love.graphics.setFont(State.RF_Font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    titleScreen.load()
    optionsScreen.load()
    introScreen.load()
end

-- Pass window resize events to push
function love.resize(w, h)
    push:resize(w, h)
end

-- update loop for the game states --
function love.update(dt)
    -- Pass delta time to active screen for animations
    if State.GameState == "intro" then
        introScreen.update(dt)
    end
end

-- rendering --
function love.draw()
    push:start()

    if State.GameState == "title" then
        titleScreen.draw()
    elseif State.GameState == "options" then
        optionsScreen.draw()
    elseif State.GameState == "intro" then
        introScreen.draw()
    end
    
    push:finish()
end

-- hardware event interceptors --
function love.keypressed(key)
    if State.GameState == "title" then
        titleScreen.keypressed(key)
    elseif State.GameState == "options" then
        optionsScreen.keypressed(key)
    else
        if key == "q" then
            love.event.quit()
        end
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