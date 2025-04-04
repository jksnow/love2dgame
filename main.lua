-- main.lua
-- Entry point for the ASCII Survival Horror game

-- Require the StateManager first
local StateManager = require("src/StateManager")

function love.load()
    print("Game Loading...")

    -- Set default filter for pixel art scaling if needed
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Register all states
    local states = {
        MainMenu = require("src/states/MainMenu"),
        Gameplay = require("src/states/Gameplay")
        -- Add other states here as they are created
    }
    StateManager:register(states)

    -- Set the initial state
    StateManager:switch("MainMenu")

    print("Game Loaded!")
end

function love.update(dt)
    -- Delegate update to the current state
    StateManager:update(dt)
end

function love.draw()
    -- Delegate draw to the current state
    StateManager:draw()
end

function love.keypressed(key, scancode, isrepeat)
    -- Global keybinds can go here
    if key == "escape" then
        love.event.quit()
        return -- Prevent state from also handling escape if needed
    end

    -- Delegate keypressed to the current state
    StateManager:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Delegate mousepressed to the current state
    StateManager:mousepressed(x, y, button, istouch, presses)
end

-- Delegate other relevant Love callbacks as needed
-- function love.mousereleased(...)
--     StateManager:mousereleased(...)
-- end
-- function love.keyreleased(...)
--     StateManager:keyreleased(...)
-- end 