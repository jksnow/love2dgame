-- src/entities/Player.lua

local Player = {}
Player.__index = Player

function Player:new(x, y)
    print(string.format("Creating player at grid coordinates: %d, %d", x, y))
    local instance = setmetatable({}, Player)

    -- Player position on the map grid
    instance.x = x or 1
    instance.y = y or 1
    
    -- Destination coordinates for click-to-move functionality
    instance.destX = instance.x
    instance.destY = instance.y
    
    -- Movement tracking
    instance.isMoving = false
    instance.moveSpeed = 4 -- How many tiles per second to move
    instance.moveTimer = 0 -- For smooth movement

    -- Player appearance & properties
    instance.char = "@"
    instance.fg = {1, 1, 0} -- Yellow
    instance.bg = {0.1, 0.1, 0.1} -- Same as floor bg
    
    -- In the z-stacking system, the player has height/z-level
    instance.zHeight = 1 -- Player stands 1 level above ground
    
    -- For possible future animation states
    instance.state = "idle" -- idle, moving, attacking, etc.

    return instance
end

function Player:update(dt)
    -- Handle movement if we have a destination set
    if self.x ~= self.destX or self.y ~= self.destY then
        self.isMoving = true
        self.moveTimer = self.moveTimer + dt
        
        -- Simple instant movement for now
        -- In a future enhancement, we could implement pathfinding and smooth movement
        self.x = self.destX
        self.y = self.destY
        
        -- Print update at destination
        print(string.format("Player arrived at (%d, %d)", self.x, self.y))
        self.isMoving = false
    else
        self.isMoving = false
    end
end

-- Set a new destination for the player to move to
function Player:setDestination(x, y)
    self.destX = x
    self.destY = y
    print(string.format("Setting player destination to (%d, %d)", x, y))
end

-- Directly set player position (teleport)
function Player:setPosition(x, y)
    self.x = x
    self.y = y
    self.destX = x
    self.destY = y
    print(string.format("Player position set to (%d, %d)", x, y))
end

-- Note: The draw function in Player.lua is no longer used
-- as drawing is now handled by the render queue in Gameplay.lua
-- This function is kept for reference or for possible future use
function Player:draw(tileWidth, tileHeight, heightOffset, baseYOffset)
    print("Player:draw() called but is deprecated. Drawing now handled by Gameplay's render queue.")
end

return Player 