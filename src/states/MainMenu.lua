-- src/states/MainMenu.lua

local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu:new()
    local instance = setmetatable({}, MainMenu)
    instance.title = "ASCII Survival Horror"
    instance.options = {"Start Game", "Options (TODO)", "Quit"}
    instance.selectedOption = 1
    return instance
end

function MainMenu:load()
    -- Load menu assets if needed
end

function MainMenu:enter()
    print("Entering MainMenu State")
    self.selectedOption = 1
end

function MainMenu:leave()
    print("Leaving MainMenu State")
end

function MainMenu:update(dt)
    -- Update menu logic (e.g., handle selection changes)
end

function MainMenu:draw()
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    -- Draw Title
    love.graphics.printf(self.title, 0, height / 4, width, "center")

    -- Draw Options
    for i, option in ipairs(self.options) do
        local y = height / 2 + (i - 1) * lineHeight * 1.5
        if i == self.selectedOption then
            love.graphics.setColor(1, 1, 0) -- Yellow for selected
        else
            love.graphics.setColor(1, 1, 1) -- White for others
        end
        love.graphics.printf(option, 0, y, width, "center")
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function MainMenu:keypressed(key, scancode, isrepeat)
    if key == "up" then
        self.selectedOption = self.selectedOption - 1
        if self.selectedOption < 1 then self.selectedOption = #self.options end
    elseif key == "down" then
        self.selectedOption = self.selectedOption + 1
        if self.selectedOption > #self.options then self.selectedOption = 1 end
    elseif key == "return" or key == "kpenter" then
        self:handleSelection()
    end
end

function MainMenu:handleSelection()
    local selected = self.options[self.selectedOption]
    if selected == "Start Game" then
        -- This requires access to the StateManager. We'll handle this in main.lua for now.
        print("Start Game selected (implement state switching)")
        -- Example: SM:switch("Gameplay") -- Need a reference to StateManager
        require("src/StateManager"):switch("Gameplay")
    elseif selected == "Quit" then
        love.event.quit()
    else
        print(selected .. " selected (TODO)")
    end
end

-- Add mouse support for menu selection
function MainMenu:mousepressed(x, y, button, istouch, presses)
    -- Only handle left mouse button clicks
    if button ~= 1 then return end
    
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Check if click was on any menu option
    for i, option in ipairs(self.options) do
        local optionY = height / 2 + (i - 1) * lineHeight * 1.5
        -- Calculate rough boundaries of the menu option text
        local textWidth = font:getWidth(option)
        local textX = width/2 - textWidth/2
        
        -- Simple hit test - expand clickable area slightly for better UX
        local hitPadding = 10
        if y >= optionY - hitPadding and y <= optionY + lineHeight + hitPadding and
           x >= textX - hitPadding and x <= textX + textWidth + hitPadding then
            -- Update selection and handle it
            self.selectedOption = i
            self:handleSelection()
            return
        end
    end
end

-- Add other needed Love callbacks if necessary

-- Return the MainMenu table definition, not an instance
return MainMenu 