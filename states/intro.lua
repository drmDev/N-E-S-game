-- states/intro.lua
local intro = {}

-- Main Character Assets
local spriteSheet
local quads = {}
local currentFrame = 6
local frameTimer = 0
local frameDuration = 0.25
local isAnimationComplete = false

-- Programmatic Object Images
local imgDoor
local imgWindow
local imgTv

-- Color Palette for Generated Assets
local palette = {
    ["."] = {0, 0, 0, 0},           -- Transparent
    ["D"] = {0.15, 0.1, 0.08, 1},    -- Dark Frame Outline
    ["B"] = {0.4, 0.25, 0.15, 1},    -- Wood Brown
    ["M"] = {0.5, 0.5, 0.55, 1},     -- Iron Bars / Knobs
    ["G"] = {0.2, 0.35, 0.45, 0.9},  -- Glass / Sky Tint
    ["C"] = {0.25, 0.25, 0.28, 1},   -- CRT Body Grey
    ["S"] = {0.1, 0.8, 0.6, 1},      -- Static Screen Cyan Glow
    ["Y"] = {0.85, 0.7, 0.2, 1}     -- Brass Lock / Light Knob
}

-- Array Grid Definitions (16x16)
local doorGrid = {
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"},
    {"D","B","B","B","B","B","B","B","B","B","B","B","B","B","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","B","B","B","B","B","B","B","B","B","B","B","B","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","D","B","B","B","B","D","D","B","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","Y","Y","B","B","B","D","B","D"},
    {"D","B","D","B","B","B","B","D","Y","Y","B","B","B","D","B","D"},
    {"D","B","D","D","D","D","D","D","D","D","D","D","D","D","B","D"},
    {"D","B","B","B","B","B","B","B","B","B","B","B","B","B","B","D"},
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"},
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"}
}

local windowGrid = {
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","M","M","M","M","M","M","M","M","M","M","M","M","M","M","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","M","M","M","M","M","M","M","M","M","M","M","M","M","M","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","G","G","M","G","G","M","G","G","M","G","G","M","G","G","D"},
    {"D","D","D","D","D","D","D","D","D","D","D","D","D","D","D","D"}
}

local tvGrid = {
    {"C","C","C","C","C","C","C","C","C","C","C","C","C","C","C","C"},
    {"C","D","D","D","D","D","D","D","D","D","D","D","D","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","D","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","M","M","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","D","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","Y","D","D","C"},
    {"C","D","S","S","S","S","S","S","S","S","S","D","D","D","D","C"},
    {"C","D","D","D","D","D","D","D","D","D","D","D","D","D","D","C"},
    {"C","C","C","C","C","C","C","C","C","C","C","C","C","C","C","C"},
    {"C","D","D","D","D","D","D","D","D","D","D","D","D","D","D","C"},
    {"C","C","C","C","C","C","C","C","C","C","C","C","C","C","C","C"},
    {"C","D","D",".",".",".",".",".",".",".",".",".",".","D","D","C"},
    {"D","D",".",".",".",".",".",".",".",".",".",".",".",".","D","D"}
}

-- Array-to-Image Helper Function
local function generateSprite(grid, colorPalette)
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

function intro.load()
    -- Load character sheet and setup quads
    spriteSheet = love.graphics.newImage("assets/pngs/mainChar/lying_down.png")
    spriteSheet:setFilter("nearest", "nearest")

    local sw, sh = spriteSheet:getDimensions()
    quads[1] = love.graphics.newQuad(0, 0, 21, 16, sw, sh)
    quads[2] = love.graphics.newQuad(21, 0, 21, 16, sw, sh)
    quads[3] = love.graphics.newQuad(42, 0, 21, 16, sw, sh)
    quads[4] = love.graphics.newQuad(63, 0, 21, 16, sw, sh)
    quads[5] = love.graphics.newQuad(84, 0, 21, 16, sw, sh)
    quads[6] = love.graphics.newQuad(105, 0, 21, 16, sw, sh)

    -- Generate room objects from arrays
    imgDoor = generateSprite(doorGrid, palette)
    imgWindow = generateSprite(windowGrid, palette)
    imgTv = generateSprite(tvGrid, palette)
end

function intro.update(dt)
    if not isAnimationComplete then
        frameTimer = frameTimer + dt
        if frameTimer >= frameDuration then
            frameTimer = frameTimer - frameDuration
            currentFrame = currentFrame - 1

            if currentFrame <= 1 then
                currentFrame = 1
                isAnimationComplete = true
            end
        end
    end
end

function intro.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local scale = 5

    -- Center Player
    local charX = math.floor((screenWidth - (21 * scale)) / 2)
    local charY = math.floor((screenHeight - (16 * scale)) / 2)

    -- Object Positions relative to room diagram
    local doorX = math.floor((screenWidth - (16 * scale)) / 2)
    local doorY = charY + 260

    local windowX = math.floor((screenWidth - (16 * scale)) / 2)
    local windowY = charY - 260

    local tvX = charX + 300
    local tvY = math.floor((screenHeight - (16 * scale)) / 2)

    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1)

    -- 1. Draw Room Environment Props
    love.graphics.draw(imgDoor, doorX, doorY, 0, scale, scale)
    love.graphics.draw(imgWindow, windowX, windowY, 0, scale, scale)
    love.graphics.draw(imgTv, tvX, tvY, 0, scale, scale)

    -- 2. Draw Main Character
    love.graphics.draw(spriteSheet, quads[currentFrame], charX, charY, 0, scale, scale)
    love.graphics.pop()

    -- 3. Draw Dialogue Box
    local boxW, boxH = 310, 50
    local boxX = math.floor(charX + ((21 * scale) / 2) - (boxW / 2)) -- Centered over sprite
    local boxY = charY - boxH - 20                                    -- Hovering just above head

    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH)
    love.graphics.print("ow... my head... where am I?", boxX + 15, boxY + 15, 0, 0.16, 0.16)
    love.graphics.pop()
end

return intro