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
local constants = require("constants")

local states = {
    title = titleScreen,
    options = optionsScreen,
    intro = introScreen
}

function love.load()
    love.mouse.setVisible(false)

    push:setupScreen(constants.VIRTUAL_WIDTH, constants.VIRTUAL_HEIGHT, constants.WINDOW_WIDTH, constants.WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        pixelperfect = true
    })

    State.BGM = love.audio.newSource("assets/oggs/intro.ogg", "stream")
    State.BGM:setLooping(true)
    State.BGM:setVolume(0.5)
    State.BGM:play()

    State.SFX_Select = love.audio.newSource("assets/wavs/select.wav", "static")
    State.SFX_Select:setVolume(0.5)
    State.SFX_Nav = love.audio.newSource("assets/oggs/nav.ogg", "static")
    State.SFX_Nav:setVolume(0.5)

    State.RF_Font = love.graphics.newFont(rfFontPath, 100)
    State.RF_Font:setFilter("nearest", "nearest")
    love.graphics.setFont(State.RF_Font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    titleScreen.load()
    optionsScreen.load()
    introScreen.load()
end

local function dispatch(eventName, ...)
    local currentState = states[State.GameState]
    if currentState and currentState[eventName] then
        currentState[eventName](...)
    end
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    dispatch("update", dt)
end

function love.draw()
    push:start()
    dispatch("draw")
    push:finish()
end

-- TODO: consider Baton or similar library to deduplicate these
function love.keypressed(key)
    if key == "q" and State.GameState ~= "options" then
        love.event.quit()
        return
    end

    dispatch("keypressed", key)
end

function love.gamepadpressed(joystick, button)
    dispatch("gamepadpressed", joystick, button)
end