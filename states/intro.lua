-- states/intro.lua
local Gamestate     = require("lib.hump.gamestate")
local anim8         = require("lib.anim8")
local sti           = require("lib.sti")
local bump          = require("lib.bump")
local Player        = require("entities.player")
local DialogManager = require("dialogs.init")
local input         = require("config")
local constants     = require("constants")

local Intro = {}

local SCALE          = 1.5
local TV_PAD         = 12
local PLAYER_WIDTH   = 21
local PLAYER_HEIGHT  = 16
local PROMPT_WIDTH   = 20
local PROMPT_HEIGHT  = 16

local lyingImg, promptSheet
local map, world, player
local lyingAnim, promptAnim
local tvObj, isLyingDown, dialogShown

local function findObject(layer, propType)
    if not (layer and layer.objects) then return nil end
    for _, obj in ipairs(layer.objects) do
        if obj.properties and obj.properties.type == propType then return obj end
    end
end

local function nearTv()
    if not tvObj then return false end
    return player.x + PLAYER_HEIGHT > tvObj.x - TV_PAD
       and player.x                 < tvObj.x + tvObj.width  + TV_PAD
       and player.y + PLAYER_HEIGHT > tvObj.y - TV_PAD
       and player.y                 < tvObj.y + tvObj.height + TV_PAD
end

local function setupWorld()
    world = bump.newWorld(16)
    map   = sti("assets/worlds/intro_room/intro_room.lua", { "bump" })
    map:bump_init(world)

    if map.layers["Collidable"] then
        map.layers["Collidable"].visible = false
    end

    tvObj = findObject(map.layers["Collidable"], "tv")
end

local function loadAssets()
    if not lyingImg then
        lyingImg = love.graphics.newImage("assets/sprites/characters/player/lying_down.png")
        lyingImg:setFilter("nearest", "nearest")
    end
    if not promptSheet then
        promptSheet = love.graphics.newImage("assets/ui/hud/action_prompt.png")
        promptSheet:setFilter("nearest", "nearest")
    end
    DialogManager.init()
end

local function setupAnimations()
    local lg = anim8.newGrid(PLAYER_WIDTH, PLAYER_HEIGHT, lyingImg:getWidth(), lyingImg:getHeight())
    lyingAnim = anim8.newAnimation(lg('6-1', 1), 0.50, 'pauseAtEnd')

    local pg = anim8.newGrid(PROMPT_WIDTH, PROMPT_HEIGHT, promptSheet:getWidth(), promptSheet:getHeight())
    promptAnim = anim8.newAnimation(pg('1-2', 1), 0.4)
end

local function createPlayer()
    local startX = math.floor((constants.VIRTUAL_WIDTH  - PLAYER_WIDTH  * SCALE) / 2)
    local startY = math.floor((constants.VIRTUAL_HEIGHT - PLAYER_HEIGHT * SCALE) / 2)
    player = Player(startX, startY, world)
end

function Intro:enter()
    isLyingDown = true
    dialogShown = false
    setupWorld()
    loadAssets()
    setupAnimations()
    createPlayer()
end

local function updateLyingDown(dt)
    lyingAnim:update(dt)
    if lyingAnim.status == "paused" then
        isLyingDown = false
        if not dialogShown then
            DialogManager.show("intro.wakeup")
            dialogShown = true
        end
    end
end

local function updateDialog()
    if input:pressed("action") or input:pressed("jump") then
        DialogManager.onAction()
    end
end

local function updateFreeRoam(dt)
    player:update(dt)
    promptAnim:update(dt)

    if nearTv() and (input:pressed("action") or input:pressed("jump")) then
        DialogManager.show("intro.tv_loading")
    end
end

function Intro:update(dt)
    input:update()
    DialogManager.update(dt)

    if isLyingDown then
        updateLyingDown(dt)
    elseif DialogManager.isOpen() then
        updateDialog()
    else
        updateFreeRoam(dt)
    end
end

local function drawLyingPlayer()
    local cx = math.floor((constants.VIRTUAL_WIDTH  - PLAYER_WIDTH  * SCALE) / 2)
    local cy = math.floor((constants.VIRTUAL_HEIGHT - PLAYER_HEIGHT * SCALE) / 2)
    lyingAnim:draw(lyingImg, cx, cy, 0, SCALE, SCALE)
end

local function drawPrompt()
    if not (nearTv() and tvObj) then return end

    local floatY = math.sin(love.timer.getTime() * 5) * 2
    local px = math.floor(tvObj.x + tvObj.width / 2 - 10)
    local py = math.floor(tvObj.y - 20 + floatY)
    promptAnim:draw(promptSheet, px, py)
end

function Intro:draw()
    map:draw()

    if isLyingDown then
        drawLyingPlayer()
    else
        player:draw()
        drawPrompt()
    end

    DialogManager.draw()
end

function Intro:leave()
    -- Clear any remaining dialogs when leaving the state
    DialogManager.clear()
end

return Intro