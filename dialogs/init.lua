-- dialogs/init.lua
-- Centralized dialog management system
local Talkies = require("lib.talkies")

local DialogManager = {
    font = nil,
    initialized = false
}

-- Initialize dialog system (call once per state or globally)
function DialogManager.init()
    if DialogManager.initialized then return end
    
    -- Create dialog font
    DialogManager.font = love.graphics.newFont("assets/fonts/RasterForgeRegular-JpBgm.ttf", 16)
    DialogManager.font:setFilter("nearest", "nearest")
    
    -- Configure Talkies globally
    Talkies.font = DialogManager.font
    Talkies.textSpeed = "medium"
    Talkies.messageColor = {1, 1, 1}
    Talkies.messageBackgroundColor = {0, 0, 0, 0.8}
    Talkies.padding = 10
    
    DialogManager.initialized = true
end

-- Show a dialog by ID (format: "module.dialogKey")
function DialogManager.show(dialogId, context)
    local dialog = DialogManager.get(dialogId)
    if not dialog then
        print("Warning: Dialog not found: " .. dialogId)
        return
    end
    
    -- Support for dynamic text (context substitution)
    local text = dialog.text
    if type(text) == "function" then
        text = text(context)
    end
    
    -- Show the dialog
    Talkies.say(dialog.speaker, text, dialog.config or {})
end

-- Get dialog by ID
function DialogManager.get(dialogId)
    -- Parse ID format: "module.dialogKey" (e.g., "intro.wakeup")
    local module, key = dialogId:match("([^.]+)%.(.+)")
    if not module then 
        print("Warning: Invalid dialog ID format: " .. dialogId)
        return nil 
    end
    
    -- Load the dialog module
    local success, dialogModule = pcall(require, "dialogs." .. module)
    if not success then
        print("Warning: Could not load dialog module: dialogs." .. module)
        return nil
    end
    
    return dialogModule[key]
end

-- Update dialog system (call in state update)
function DialogManager.update(dt)
    Talkies.update(dt)
end

-- Draw dialog system (call in state draw)
function DialogManager.draw()
    Talkies.draw()
end

-- Check if dialog is currently open
function DialogManager.isOpen()
    return Talkies.isOpen()
end

-- Handle action button press (advance/close dialog)
function DialogManager.onAction()
    Talkies.onAction()
end

-- Clear all queued dialogs
function DialogManager.clear()
    Talkies.clearMessages()
end

return DialogManager
