-- game.lua
local game = {
    font  = nil,  ---@type love.Font
    audio = {
        bgm       = nil,  ---@type love.Source
        sfxSelect = nil,  ---@type love.Source
        sfxNav    = nil,  ---@type love.Source
    },
}
return game
