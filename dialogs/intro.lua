-- dialogs/intro.lua
-- Dialog content for the intro stage

return {
    -- Dialog shown after character wakes up from lying down animation
    wakeup = {
        speaker = "",  -- No speaker name for internal monologue
        text = "Ow... my head... Where am I?"
    },

    -- Dialog shown when interacting with the TV
    tv_loading = {
        speaker = "TV",
        text = "Loading level - Forest",
        config = {
            oncomplete = function()
                -- Transition to forest after dialog closes
                local Gamestate = require("lib.hump.gamestate")
                Gamestate.switch(require("states.forest"))
            end
        }
    }
}
