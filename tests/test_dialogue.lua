-- tests/test_dialogue.lua
local luaunit = require("lib.luaunit")
local Dialogue = require("ui.dialogue")

TestDialogue = {}

function TestDialogue:setUp()
    Dialogue.start("Hello World")
end

function TestDialogue:testStartInitialState()
    luaunit.assertEquals(Dialogue.state, "typing")
    luaunit.assertEquals(Dialogue.visibleChars, 0)
    luaunit.assertTrue(Dialogue.isActive())
end

function TestDialogue:testAdvanceWhileTypingSkipsAnimation()
    Dialogue.advance() -- First press
    luaunit.assertEquals(Dialogue.state, "finished")
    luaunit.assertEquals(Dialogue.visibleChars, 11)
    luaunit.assertTrue(Dialogue.isActive()) -- Still open!
end

function TestDialogue:testAdvanceWhileFinishedClosesDialogue()
    Dialogue.advance() -- Skip typing
    local wasClosed = Dialogue.advance() -- Second press to dismiss

    luaunit.assertTrue(wasClosed)
    luaunit.assertEquals(Dialogue.state, "inactive")
    luaunit.assertFalse(Dialogue.isActive())
end

function TestDialogue:testUpdateAdvancesCharacters()
    Dialogue.update(0.03) -- Advance 1 frame time
    luaunit.assertEquals(Dialogue.visibleChars, 1)
end
