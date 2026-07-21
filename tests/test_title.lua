-- tests/test_title.lua
local luaunit = require("lib.luaunit")
local title = require("states.title")

TestTitleLogic = {}

function TestTitleLogic:testLeftWrapAround()
    -- Moving left from index 1 in a list of 3 items should wrap to 3
    local newIndex = title.getNewSelection(1, 3, "left")
    luaunit.assertEquals(newIndex, 3)
end

function TestTitleLogic:testRightWrapAround()
    -- Moving right from index 3 in a list of 3 items should wrap to 1
    local newIndex = title.getNewSelection(3, 3, "right")
    luaunit.assertEquals(newIndex, 1)
end

function TestTitleLogic:testNormalIncrement()
    -- Moving right from index 1 should go to 2
    local newIndex = title.getNewSelection(1, 3, "right")
    luaunit.assertEquals(newIndex, 2)
end

function TestTitleLogic:testNormalDecrement()
    -- Moving left from index 3 should go to 2
    local newIndex = title.getNewSelection(3, 3, "left")
    luaunit.assertEquals(newIndex, 2)
end