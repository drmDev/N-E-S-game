-- config.lua
local baton = require("lib.baton")

local input = baton.new({
    controls = {
        up     = { "key:w", "key:up", "axis:lefty-", "button:dpup" },
        down   = { "key:s", "key:down", "axis:lefty+", "button:dpdown" },
        left   = { "key:a", "key:left", "axis:leftx-", "button:dpleft" },
        right  = { "key:d", "key:right", "axis:leftx+", "button:dpright" },
        action = { "key:z", "key:lshift", "button:x" },
        jump   = { "key:x", "key:space", "button:a" }
    },
    pairs = {
        move = { "left", "right", "up", "down" }
    },
    -- Safely bypasses joystick init if running in pure Lua unit tests
    joystick = (love and love.joystick) and love.joystick.getJoysticks()[1] or nil,
    deadzone = 0.3
})

input.metadata = {
    { id = "up",     label = "Up",      type = "icon", path = "assets/ui/icons/dpad_up.png" },
    { id = "down",   label = "Down",    type = "icon", path = "assets/ui/icons/dpad_down.png" },
    { id = "left",   label = "Left",    type = "icon", path = "assets/ui/icons/dpad_left.png" },
    { id = "right",  label = "Right",   type = "icon", path = "assets/ui/icons/dpad_right.png" },
    { id = "action", label = "[Action]",type = "text" },
    { id = "jump",   label = "[Jump]",  type = "text" }
}

return input