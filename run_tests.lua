-- run_tests.lua
-- 1. Ensure LÖVE graphics/audio modules aren't invoked during pure Lua runs
package.path = package.path .. ";./?.lua;./tests/?.lua"

local luaunit = require("lib.luaunit")

-- 2. Scan the tests/ directory and dynamically require every test file
local p = io.popen('dir "tests\\test_*.lua" /b') -- Works on Windows PowerShell / CMD

if p then
    for filename in p:lines() do
        -- Strip extension to require the module (e.g. "test_title.lua" -> "test_title")
        local moduleName = filename:gsub("%.lua$", "")
        require("tests." .. moduleName)
    end
    p:close()
end

-- 3. Execute all loaded test suites with verbose output
os.exit(luaunit.LuaUnit.run("-v"))