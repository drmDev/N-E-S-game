-- Shared game context. Required by states for audio/font access.
-- Populated in love.load() before first state switch.
local game = {
    font  = nil,
    audio = {
        bgm       = nil,
        sfxSelect = nil,
        sfxNav    = nil,
    },
}
return game
