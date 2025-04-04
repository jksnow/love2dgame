-- src/StateManager.lua

local StateManager = {}

StateManager.states = {} -- Store all state objects (e.g., MainMenu, Gameplay)
StateManager.currentState = nil

function StateManager:register(states)
    for name, state in pairs(states) do
        self.states[name] = state
        if state.load then
            state:load() -- Allow states to do initial setup
        end
        print("Registered state:", name)
    end
end

function StateManager:switch(stateName, ...)
    print("Switching state to:", stateName)
    local newState = self.states[stateName]
    if not newState then
        print("Error: Attempted to switch to unknown state: " .. stateName)
        return
    end

    if self.currentState and self.currentState.leave then
        self.currentState:leave()
    end

    self.currentState = newState

    if self.currentState.enter then
        self.currentState:enter(...)
    end
end

function StateManager:getCurrentState()
    return self.currentState
end

-- Delegate Love callbacks to the current state
function StateManager:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function StateManager:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

function StateManager:keypressed(key, scancode, isrepeat)
    if self.currentState and self.currentState.keypressed then
        self.currentState:keypressed(key, scancode, isrepeat)
    end
    -- Global keybinds (like escape) can also be checked here or in main.lua
end

function StateManager:mousepressed(x, y, button, istouch, presses)
    if self.currentState and self.currentState.mousepressed then
        self.currentState:mousepressed(x, y, button, istouch, presses)
    end
end

-- Add other relevant Love callbacks here (mousereleased, keyreleased, etc.)
-- function StateManager:mousereleased(...)
-- function StateManager:keyreleased(...)

return StateManager 