-- conf.lua
-- TODO: get non-windowed mode working. 
-- (Current attempts usually make the game impossible to capture.)
function love.conf(t)
    t.window.title = "N / E / S"
    t.window.fullscreen = false
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    -- t.window.fullscreentype = "desktop"
    -- t.window.vsync = 1
end