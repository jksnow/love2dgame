-- src/StateManager.lua

local StateManager = {}

StateManager.states = {} -- Store state *instances*
StateManager.currentState = nil

function StateManager:register(stateDefinitions)
    print("Registering state definitions...")
    for name, stateDefinition in pairs(stateDefinitions) do
        print("  Registering and instantiating:", name)
        if type(stateDefinition) == 'table' and stateDefinition.new then
            -- Create an instance of the state
            local stateInstance = stateDefinition:new()
            self.states[name] = stateInstance
            -- Call load on the instance if it exists
            if stateInstance.load then
                stateInstance:load()
            end
            print("    -> Registered state instance:", name)
        else
            print("Warning: Invalid state definition for", name, ". Expected table with :new() method.")
        end
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