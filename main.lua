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
local titleScreen = require("states.title")
local optionsScreen = require ("states.options")
local introScreen = require("states.intro")
local forestScreen = require("states.forest")
local constants = require("constants")

-- Create virtual low-res canvas (640x360)
local gameCanvas = love.graphics.newCanvas(constants.VIRTUAL_WIDTH, constants.VIRTUAL_HEIGHT)
gameCanvas:setFilter("nearest", "nearest")

local states = {
    title = titleScreen,
    options = optionsScreen,
    intro = introScreen,
    forest = forestScreen
}

-- TODO: confirm is this is needed. No mouse events. No mobile version. No touch screen.
-- Utility: Translates physical window mouse/touch coords to virtual 640x360 canvas space
--function State.toVirtualCoords(screenX, screenY)
  --  local windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()
    --local scale = math.min(windowW / constants.VIRTUAL_WIDTH, windowH / constants.VIRTUAL_HEIGHT)
    --local offsetX = math.floor((windowW - (constants.VIRTUAL_WIDTH * scale)) / 2)
    --local offsetY = math.floor((windowH - (constants.VIRTUAL_HEIGHT * scale)) / 2)

    --local vx = (screenX - offsetX) / scale
    --local vy = (screenY - offsetY) / scale
    --return vx, vy
--end

function love.load()
    love.mouse.setVisible(false)
    love.window.maximize()

    State.BGM = love.audio.newSource("assets/audio/music/intro.ogg", "stream")
    State.BGM:setLooping(true)
    State.BGM:setVolume(0.5)
    State.BGM:play() -- disable while I'm frequently debugging

    State.SFX_Select = love.audio.newSource("assets/audio/sfx/select.wav", "static")
    State.SFX_Select:setVolume(0.5)
    State.SFX_Nav = love.audio.newSource("assets/audio/sfx/nav.ogg", "static")
    State.SFX_Nav:setVolume(0.5)

    State.RF_Font = love.graphics.newFont(rfFontPath, 100)
    State.RF_Font:setFilter("nearest", "nearest")
    love.graphics.setFont(State.RF_Font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    titleScreen.load()
    optionsScreen.load()
    introScreen.load()
    forestScreen.load()
end

local function dispatch(eventName, ...)
    local currentState = states[State.GameState]
    if currentState and currentState[eventName] then
        currentState[eventName](...)
    end
end

function love.update(dt)
    dispatch("update", dt)
end

function love.draw()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0)
    dispatch("draw")
    love.graphics.setCanvas() -- Reset target back to main screen

    -- 2. Scale and letterbox gameCanvas to physical window
    local windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()
    local scale = math.min(windowW / constants.VIRTUAL_WIDTH, windowH / constants.VIRTUAL_HEIGHT)

    local offsetX = math.floor((windowW - (constants.VIRTUAL_WIDTH * scale)) / 2)
    local offsetY = math.floor((windowH - (constants.VIRTUAL_HEIGHT * scale)) / 2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, offsetX, offsetY, 0, scale, scale)
end

-- TODO: refactor to use Baron
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