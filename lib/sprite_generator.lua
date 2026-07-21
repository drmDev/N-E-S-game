-- lib/sprite_generator.lua
local SpriteGenerator = {}

-- Shared Color Palette
SpriteGenerator.palette = {
    ["."] = {0, 0, 0, 0},           -- Transparent
    ["D"] = {0.15, 0.1, 0.08, 1},    -- Dark Frame Outline
    ["B"] = {0.4, 0.25, 0.15, 1},    -- Wood Brown
    ["M"] = {0.5, 0.5, 0.55, 1},     -- Iron Bars / Knobs
    ["G"] = {0.2, 0.35, 0.45, 0.9},  -- Glass / Sky Tint
    ["C"] = {0.25, 0.25, 0.28, 1},   -- CRT Body Grey
    ["S"] = {0.1, 0.8, 0.6, 1},      -- Static Screen Cyan Glow
    ["Y"] = {0.85, 0.7, 0.2, 1}      -- Brass Lock / Light Knob
}

--- Generates a LOVE Image object from a 2D grid array and a color palette.
-- @param grid table: 2D array of palette keys
-- @param colorPalette table (optional): Custom color lookup table
-- @return love.graphics.Image
function SpriteGenerator.fromGrid(grid, colorPalette)
    colorPalette = colorPalette or SpriteGenerator.palette
    local height = #grid
    local width = #grid[1]
    local imgData = love.image.newImageData(width, height)

    for y = 1, height do
        for x = 1, width do
            local key = grid[y][x]
            local c = colorPalette[key] or {0, 0, 0, 0}
            imgData:setPixel(x - 1, y - 1, c[1], c[2], c[3], c[4] or 1)
        end
    end

    local image = love.graphics.newImage(imgData)
    image:setFilter("nearest", "nearest")
    return image
end

return SpriteGenerator