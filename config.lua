-- config.lua
local controls = {
    { id = "up",     label = "Up",      key = "w", pad = "dpup",    type = "icon", path = "assets/pngs/dpadUp.png" },
    { id = "down",   label = "Down",    key = "s", pad = "dpdown",  type = "icon", path = "assets/pngs/dpadDown.png" },
    { id = "left",   label = "Left",    key = "a", pad = "dpleft",  type = "icon", path = "assets/pngs/dpadLeft.png" },
    { id = "right",  label = "Right",   key = "d", pad = "dpright", type = "icon", path = "assets/pngs/dpadRight.png" },
    { id = "action", label = "[Action]",key = "z", pad = "x",       type = "text" },
    { id = "jump",   label = "[Jump]",  key = "x", pad = "a",       type = "text" }
}

return controls