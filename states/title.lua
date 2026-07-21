local title = {}

-- Fixed virtual target dimensions (must match main.lua / push setup)
local VIRTUAL_WIDTH = 640
local VIRTUAL_HEIGHT = 360

-- Title-specific UI states insulated to this module
-- Button scales adjusted down from 5 to 2 to fit 640x360 virtual resolution
local titleButtons = {
    { name = "play",  path = "assets/pngs/playBtn.png",  scale = 2 },
    { name = "gear",  path = "assets/pngs/gearBtn.png",  scale = 2 },
    { name = "eject", path = "assets/pngs/ejectBtn.png", scale = 2 }
}
local currentTitleSelection = 1

-- Navigation with wrapping handling
local function navigate(direction)
    if direction == "left" then
        State.SFX_Nav:play()
        currentTitleSelection = currentTitleSelection - 1
        if currentTitleSelection < 1 then
            currentTitleSelection = #titleButtons
        end

    elseif direction == "right" then
        State.SFX_Nav:play()
        currentTitleSelection = currentTitleSelection + 1
        if currentTitleSelection > #titleButtons then
            currentTitleSelection = 1
        end

    elseif direction == "confirm" then
        State.SFX_Select:play()
        titleButtons[currentTitleSelection].action()
    end
end

-- Load assets and calculate positions ONCE using fixed virtual coordinates
function title.load()
    -- Map menu item confirmations to actions
    titleButtons[1].action = function() 
        State.GameState = "intro"
    end
    titleButtons[2].action = function() 
        State.GameState = "options"
        State.CurrentOptionsSelection = 1 
    end
    titleButtons[3].action = function() 
        love.event.quit() 
    end

    -- Phase 1: Measure button dimensions in virtual resolution space
    local totalTitleWidth = 0
    local padding = 24

    for _, btn in ipairs(titleButtons) do
        btn.img = love.graphics.newImage(btn.path)
        btn.width = btn.img:getWidth() * btn.scale
        btn.height = btn.img:getHeight() * btn.scale

        totalTitleWidth = totalTitleWidth + btn.width
    end

    -- Phase 2: Add padding gaps
    totalTitleWidth = totalTitleWidth + (padding * (#titleButtons - 1))

    -- Phase 3: Compute fixed virtual coordinates (640x360 grid)
    local startX = (VIRTUAL_WIDTH - totalTitleWidth) / 2
    local startY = VIRTUAL_HEIGHT * 0.55 -- Positioned slightly below mid-screen

    for _, btn in ipairs(titleButtons) do
        btn.x = startX
        btn.y = startY
        startX = startX + btn.width + padding
    end
end

-- Draw elements directly onto the virtual canvas
function title.draw()
    -- 1. Draw Title Text centered in virtual space
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0)
    local titleText = "N / E / S"
    local fontWidth = State.RF_Font:getWidth(titleText)
    love.graphics.print(titleText, (VIRTUAL_WIDTH - fontWidth) / 2, 80)
    love.graphics.pop()

    -- 2. Draw Menu Buttons and Selection Boxes
    for i, btn in ipairs(titleButtons) do
        love.graphics.push("all")

        if i == currentTitleSelection then
            love.graphics.setColor(1, 0.3, 0.3)
            love.graphics.rectangle("line", btn.x - 4, btn.y - 4, btn.width + 8, btn.height + 8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end

        love.graphics.draw(btn.img, btn.x, btn.y, 0, btn.scale, btn.scale)
        love.graphics.pop()
    end
end

-- Handle key press events for the title screen
function title.keypressed(key)
    if key == "left" or key == "a" then navigate("left")
    elseif key == "right" or key == "d" then navigate("right")
    elseif key == "return" or key == "kpenter" or key == "space" or key == "z" then navigate("confirm")
    end
end

-- Gamepad press events for the title screen
function title.gamepadpressed(_, button)
    if button == "dpleft" then navigate("left")
    elseif button == "dpright" then navigate("right")
    elseif button == "a" or button == "start" or button == "x" then navigate("confirm")
    end
end

return title