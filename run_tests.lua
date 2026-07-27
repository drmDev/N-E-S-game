-- run_tests.lua
-- Fix package.path so requires find modules in the root directory
package.path = package.path .. ";./?.lua;./lib/?.lua;./entities/?.lua;./tests/?.lua"

local luaunit = require("lib.luaunit")

-- Load test suites (they register themselves globally)


-- Run all registered test suites
os.exit(luaunit.LuaUnit.run())