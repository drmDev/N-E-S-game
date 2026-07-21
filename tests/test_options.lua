-- tests/test_options.lua
local options = require("states.options")
local luaunit = require("lib.luaunit")

TestOptionsLogic = {}

function TestOptionsLogic:testUpWrapAround()
    -- Moving up from item 1 out of 7 total should wrap to 7
    local newIndex = options.getNewSelection(1, 7, "up")
    luaunit.assertEquals(newIndex, 7)
end

function TestOptionsLogic:testDownWrapAround()
    -- Moving down from item 7 out of 7 total should wrap to 1
    local newIndex = options.getNewSelection(7, 7, "down")
    luaunit.assertEquals(newIndex, 1)
end

function TestOptionsLogic:testNormalUp()
    local newIndex = options.getNewSelection(4, 7, "up")
    luaunit.assertEquals(newIndex, 3)
end

function TestOptionsLogic:testNormalDown()
    local newIndex = options.getNewSelection(4, 7, "down")
    luaunit.assertEquals(newIndex, 5)
end

function TestOptionsLogic:testInvalidDirection()
    -- Providing an invalid direction should return the current index unchanged
    local newIndex = options.getNewSelection(4, 7, "left")
    luaunit.assertEquals(newIndex, 4)
end