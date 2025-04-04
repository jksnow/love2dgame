-- src/states/Gameplay.lua

local Gameplay = {}
Gameplay.__index = Gameplay

-- Require Player entity (Moved inside :new)
-- local Player = require("src.entities.Player")

-- Define some colors (0-1 range)
local Colors = {
    black = {0.0, 0.0, 0.0},
    darkGrey = {0.2, 0.2, 0.2},
    grey = {0.5, 0.5, 0.5},
    lightGrey = {0.8, 0.8, 0.8},
    white = {1.0, 1.0, 1.0},
    
    darkBrown = {0.3, 0.2, 0.1},
    brown = {0.6, 0.4, 0.2},
    lightBrown = {0.8, 0.6, 0.4},
    
    darkGreen = {0.1, 0.3, 0.1},
    green = {0.2, 0.5, 0.2},
    lightGreen = {0.4, 0.8, 0.4},
    
    darkBlue = {0.1, 0.2, 0.4},
    blue = {0.2, 0.4, 0.8},
    lightBlue = {0.4, 0.6, 1.0},
    
    yellow = {1.0, 1.0, 0.0},
    red = {1.0, 0.2, 0.2}
}

-- Map object types and their z-stacks
local ObjectTypes = {
    floor = {
        char = ".", 
        fg = Colors.darkGrey,
        zLevels = 1,
        walkable = true,
        name = "floor"
    },
    ground = {
        char = "`", 
        fg = Colors.brown,
        zLevels = 1,
        walkable = true,
        name = "ground"
    },
    grass = {
        char = ",", 
        fg = Colors.green,
        zLevels = 1,
        walkable = true,
        name = "grass"
    },
    tallGrass = {
        zStack = {
            {char = ",", fg = Colors.green},
            {char = "\"", fg = Colors.lightGreen}
        },
        zLevels = 2,
        walkable = true,
        name = "tall grass"
    },
    water = {
        zStack = {
            {char = "~", fg = Colors.blue},
            {char = "~", fg = Colors.lightBlue}
        },
        zLevels = 2,
        walkable = false,
        name = "water"
    },
    tree = {
        zStack = {
            {char = ".", fg = Colors.brown},      -- Base/trunk
            {char = "|", fg = Colors.brown},
            {char = "|", fg = Colors.brown},
            {char = "|", fg = Colors.brown},
            {char = "*", fg = Colors.darkGreen},  -- Foliage
            {char = "*", fg = Colors.green},
            {char = "*", fg = Colors.lightGreen}, -- Top
        },
        zLevels = 7,
        walkable = false,
        name = "tree"
    },
    wall = {
        zStack = {
            {char = "#", fg = Colors.grey},       -- Base
            {char = "#", fg = Colors.grey},
            {char = "#", fg = Colors.lightGrey}   -- Top
        },
        zLevels = 3,
        walkable = false,
        name = "wall"
    },
    tallWall = {
        zStack = {
            {char = "#", fg = Colors.grey},       -- Base
            {char = "#", fg = Colors.grey},
            {char = "#", fg = Colors.grey},
            {char = "#", fg = Colors.grey},
            {char = "#", fg = Colors.lightGrey}   -- Top
        },
        zLevels = 5,
        walkable = false,
        name = "tall wall"
    },
    pillar = {
        zStack = {
            {char = "O", fg = Colors.grey},       -- Base
            {char = "H", fg = Colors.grey},
            {char = "H", fg = Colors.grey},
            {char = "H", fg = Colors.grey},
            {char = "H", fg = Colors.grey},
            {char = "H", fg = Colors.grey},
            {char = "H", fg = Colors.grey},
            {char = "H", fg = Colors.grey},
            {char = "O", fg = Colors.lightGrey}   -- Top
        },
        zLevels = 9,
        walkable = false,
        name = "pillar"
    },
    mountain = {
        zStack = {
            {char = "^", fg = Colors.grey},       -- Base
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.grey},
            {char = "^", fg = Colors.lightGrey},  -- Top
            {char = "^", fg = Colors.white}
        },
        zLevels = 12,
        walkable = false,
        name = "mountain"
    }
}

-- Z-offset constants
local Z_STEP_X = 5  -- X-offset per unit of z-height (perspective x-shift)
local Z_STEP_Y = 8  -- Y-offset per unit of z-height (perspective y-shift)

-- Create a map tile with support for z-stacking
local function createMapObject(objectType, x, y)
    local obj = {
        x = x,
        y = y,
        type = objectType.name,
        walkable = objectType.walkable,
        zLevels = objectType.zLevels,
        zStack = {}
    }
    
    -- If the object has a pre-defined z-stack, use it
    if objectType.zStack then
        obj.zStack = objectType.zStack
    else
        -- Otherwise create a single level with the object's char/color
        obj.zStack = {
            {char = objectType.char, fg = objectType.fg}
        }
    end
    
    return obj
end

-- Generate a much larger world map with z-stacked objects
local function generateWorld(width, height)
    local world = {}
    
    -- Initialize with ground tiles
    for y = 1, height do
        world[y] = {}
        for x = 1, width do
            world[y][x] = createMapObject(ObjectTypes.ground, x, y)
        end
    end
    
    -- Add some grass patches
    for i = 1, math.floor(width * height * 0.15) do
        local x = math.random(2, width-1)
        local y = math.random(2, height-1)
        world[y][x] = createMapObject(ObjectTypes.grass, x, y)
    end
    
    -- Add some tall grass patches
    for i = 1, math.floor(width * height * 0.05) do
        local x = math.random(2, width-1)
        local y = math.random(2, height-1)
        world[y][x] = createMapObject(ObjectTypes.tallGrass, x, y)
    end
    
    -- Add trees
    for i = 1, math.floor(width * height * 0.03) do
        local x = math.random(2, width-1)
        local y = math.random(2, height-1)
        world[y][x] = createMapObject(ObjectTypes.tree, x, y)
    end
    
    -- Add some water bodies
    local waterBodies = math.random(3, 5)
    for p = 1, waterBodies do
        local centerX = math.random(10, width-10)
        local centerY = math.random(10, height-10)
        local size = math.random(3, 7)
        
        for y = math.max(1, centerY - size), math.min(height, centerY + size) do
            for x = math.max(1, centerX - size), math.min(width, centerX + size) do
                if math.random() < 0.7 then -- Some randomness in water shape
                    world[y][x] = createMapObject(ObjectTypes.water, x, y)
                end
            end
        end
    end
    
    -- Add buildings/structures
    local structures = math.random(5, 10)
    for s = 1, structures do
        local bWidth = math.random(4, 8)
        local bHeight = math.random(4, 8)
        local bX = math.random(6, width - bWidth - 5)
        local bY = math.random(6, height - bHeight - 5)
        local useHighWalls = (math.random() > 0.5)
        local wallType = useHighWalls and ObjectTypes.tallWall or ObjectTypes.wall
        
        -- Create the building
        for y = bY, bY + bHeight do
            for x = bX, bX + bWidth do
                if x == bX or x == bX + bWidth or y == bY or y == bY + bHeight then
                    -- Wall
                    world[y][x] = createMapObject(wallType, x, y)
                else
                    -- Floor inside the building
                    world[y][x] = createMapObject(ObjectTypes.floor, x, y)
                end
            end
        end
        
        -- Add a door
        local doorSide = math.random(1, 4)
        if doorSide == 1 then -- North
            world[bY][bX + math.random(1, bWidth-1)] = createMapObject(ObjectTypes.floor, bX, bY)
        elseif doorSide == 2 then -- East
            world[bY + math.random(1, bHeight-1)][bX + bWidth] = createMapObject(ObjectTypes.floor, bX + bWidth, bY)
        elseif doorSide == 3 then -- South
            world[bY + bHeight][bX + math.random(1, bWidth-1)] = createMapObject(ObjectTypes.floor, bX, bY + bHeight)
        else -- West
            world[bY + math.random(1, bHeight-1)][bX] = createMapObject(ObjectTypes.floor, bX, bY)
        end
    end
    
    -- Add some pillars
    for i = 1, math.random(10, 20) do
        local x = math.random(5, width-5)
        local y = math.random(5, height-5)
        world[y][x] = createMapObject(ObjectTypes.pillar, x, y)
    end
    
    -- Add mountain range
    local mountains = math.random(15, 30)
    for i = 1, mountains do
        local x = math.random(5, width-5)
        local y = math.random(5, height-5)
        world[y][x] = createMapObject(ObjectTypes.mountain, x, y)
    end
    
    -- Find a suitable starting position
    local playerStartX, playerStartY
    for attempt = 1, 100 do
        local x = math.random(10, width-10)
        local y = math.random(10, height-10)
        local obj = world[y][x]
        
        if obj.walkable then
            playerStartX, playerStartY = x, y
            break
        end
    end
    
    -- Default position if no suitable spot found
    if not playerStartX then
        playerStartX, playerStartY = 10, 10
    end
    
    return world, playerStartX, playerStartY
end

function Gameplay:new()
    -- Explicitly clear the package cache for this module before requiring
    package.loaded["src/entities/Player"] = nil
    print("[Gameplay:new] Cleared package cache for src/entities/Player")

    -- Require Player entity just before it's needed and assert it loaded
    print("[Gameplay:new] Attempting require('src/entities/Player') after cache clear...")
    local Player = require("src/entities/Player")
    print("[Gameplay:new] Result of require: ", Player) -- Add print right after require
    assert(Player, "Failed to load src/entities/Player after clearing cache. Check path (src/entities/Player.lua) and file for errors.")
    print("[Gameplay:new] Assert passed.")

    local instance = setmetatable({}, Gameplay)
    
    -- Generate a much larger world (100x100) with z-stacked objects
    local worldSize = 100
    local generatedWorld, playerStartX, playerStartY = generateWorld(worldSize, worldSize)
    
    -- World data
    instance.world = generatedWorld
    instance.worldHeight = #generatedWorld
    instance.worldWidth = instance.worldHeight > 0 and #generatedWorld[1] or 0
    
    -- Set viewport size based on desired cell density
    -- These values adjust how many tiles are visible in the viewport
    local vpWidth = 80   -- Horizontal tiles in view
    local vpHeight = 50  -- Vertical tiles in view
    
    -- 3D Camera parameters
    instance.camera = {
        x = 0,                     -- Camera position X in tiles
        y = 0,                     -- Camera position Y in tiles
        z = 30,                    -- Camera height above ground
        viewportWidth = vpWidth,   -- Tiles shown horizontally in viewport
        viewportHeight = vpHeight, -- Tiles shown vertically in viewport
        angle = 0.6,               -- Camera angle (0=top-down, 1=side view)
        scrollSpeed = 40,          -- Camera scroll speed
        scrollBorder = 50,         -- Border size for edge scrolling (pixels)
        maxViewDist = 100          -- Maximum viewing distance
    }
    
    -- Font and rendering
    instance.font = nil            -- Font object loaded in :load()
    instance.tileWidth = 8         -- Default/placeholder width of a character
    instance.tileHeight = 16       -- Default/placeholder height of a character
    
    -- Create player instance at the determined starting position
    print("[Gameplay:new] Attempting Player:new at", playerStartX, playerStartY)
    instance.player = Player:new(playerStartX, playerStartY)
    instance.player.zHeight = 1    -- Player is 1 unit tall (will stand on ground)
    print("[Gameplay:new] Player instance created successfully.")
    
    -- Center camera on player initially
    instance:centerCameraOnPlayer()

    return instance
end

function Gameplay:load()
    -- Load font
    local fontPath = "assets/fonts/VT323-Regular.ttf"
    local fontSize = 16 -- Smaller default font size

    -- Load font or fallback to default
    local success, fontOrError = pcall(love.graphics.newFont, fontPath, fontSize)
    if success then
        self.font = fontOrError
        print("Successfully loaded font: " .. fontPath)
    else
        print("Error loading font: " .. fontPath .. " - " .. tostring(fontOrError))
        print("Falling back to default font.")
        self.font = love.graphics.getFont()
    end

    -- Apply font and update tile dimensions
    love.graphics.setFont(self.font)
    self.tileWidth = self.font:getWidth(" ") -- Width of a space character
    self.tileHeight = self.font:getHeight() -- Height of a character
    
    print(string.format("Tile dimensions: %dx%d", self.tileWidth, self.tileHeight))
end

function Gameplay:enter()
    print("Entering Gameplay State")
    if self.font then
        love.graphics.setFont(self.font)
    end
end

function Gameplay:leave()
    print("Leaving Gameplay State")
end

function Gameplay:update(dt)
    -- Update player
    self.player:update(dt)
    
    -- Camera control via mouse position
    self:updateCamera(dt)
    
    -- If player is moving, center camera on them
    if self.player.isMoving then
        self:centerCameraOnPlayer()
    end
    
    -- [TODO] Update other entities
end

-- Update camera position based on mouse position (edge scrolling)
function Gameplay:updateCamera(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scrollSpeed = self.camera.scrollSpeed * dt
    local moved = false
    
    -- Calculate border size based on window dimensions
    local borderX = math.max(30, windowWidth * 0.1)  -- 10% of width or at least 30px
    local borderY = math.max(30, windowHeight * 0.1) -- 10% of height or at least 30px
    
    -- DEBUG PRINT for troubleshooting camera movement
    if love.keyboard.isDown("lctrl") then
        print(string.format("Mouse: %.1f, %.1f | Border: %.1f, %.1f | Window: %d, %d", 
            mouseX, mouseY, borderX, borderY, windowWidth, windowHeight))
    end
    
    -- Left edge - ensure camera moves left when mouse is at left edge
    if mouseX < borderX then
        self.camera.x = self.camera.x - scrollSpeed
        moved = true
        print("Moving camera LEFT")
    end
    
    -- Right edge - ensure camera moves right when mouse is at right edge
    if mouseX > windowWidth - borderX then
        self.camera.x = self.camera.x + scrollSpeed
        moved = true
        print("Moving camera RIGHT")
    end
    
    -- Top edge
    if mouseY < borderY then
        self.camera.y = self.camera.y - scrollSpeed
        moved = true
        print("Moving camera UP")
    end
    
    -- Bottom edge
    if mouseY > windowHeight - borderY then
        self.camera.y = self.camera.y + scrollSpeed
        moved = true
        print("Moving camera DOWN")
    end
    
    -- Add keyboard camera controls as backup
    if love.keyboard.isDown("left") then
        self.camera.x = self.camera.x - scrollSpeed
        moved = true
    end
    
    if love.keyboard.isDown("right") then
        self.camera.x = self.camera.x + scrollSpeed
        moved = true
    end
    
    if love.keyboard.isDown("up") then
        self.camera.y = self.camera.y - scrollSpeed
        moved = true
    end
    
    if love.keyboard.isDown("down") then
        self.camera.y = self.camera.y + scrollSpeed
        moved = true
    end
    
    -- Constrain camera to world bounds if it moved
    if moved then
        self:constrainCamera()
    end
end

-- Draw method implementing 3D perspective rendering
function Gameplay:draw()
    -- Ensure font is set
    if self.font then love.graphics.setFont(self.font) end

    -- Clear screen with dark color
    love.graphics.clear(0.05, 0.05, 0.05)
    
    -- Camera settings
    local cam = self.camera
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Calculate visibility bounds with a wider margin based on window size
    local margin = 10 -- Extra tiles to load for tall objects and perspective shifts
    local startX = math.floor(cam.x - margin)
    local endX = math.min(math.ceil(cam.x + cam.viewportWidth + margin), self.worldWidth)
    local startY = math.floor(cam.y - margin)
    local endY = math.min(math.ceil(cam.y + cam.viewportHeight + margin), self.worldHeight)
    
    -- Rendering queue
    local renderQueue = {}
    
    -- Camera center for distance calculations
    local camCenterX = cam.x + cam.viewportWidth / 2
    local camCenterY = cam.y + cam.viewportHeight / 2
    
    -- Map objects into render queue
    for y = startY, endY do
        for x = startX, endX do
            -- Skip if outside world bounds
            if x >= 1 and y >= 1 and x <= self.worldWidth and y <= self.worldHeight then
                local obj = self.world[y][x]
                if obj then
                    -- Calculate distance from camera center
                    local distToCam = math.sqrt((x - camCenterX)^2 + (y - camCenterY)^2)
                    
                    -- Skip if too far from camera
                    if distToCam <= cam.maxViewDist then
                        -- Add each z-level of the object to render queue
                        for z = 1, #obj.zStack do
                            table.insert(renderQueue, {
                                x = x,
                                y = y,
                                z = z,
                                char = obj.zStack[z].char,
                                fg = obj.zStack[z].fg,
                                isPlayer = false,
                                dist = distToCam
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Add player to render queue if in reasonable distance
    -- Calculate player distance from camera center
    local distPlayerToCam = math.sqrt((self.player.x - camCenterX)^2 + (self.player.y - camCenterY)^2)
    
    if distPlayerToCam <= cam.maxViewDist then
        table.insert(renderQueue, {
            x = self.player.x,
            y = self.player.y,
            z = self.player.zHeight,
            char = self.player.char,
            fg = self.player.fg,
            isPlayer = true,
            dist = distPlayerToCam
        })
    end
    
    -- Sort render queue for proper z-order drawing
    -- First by Y position (further Y drawn first), then by Z-height for each position
    table.sort(renderQueue, function(a, b)
        if a.y == b.y then
            return a.z < b.z -- Lower z-levels drawn first for same y
        end
        return a.y > b.y -- Higher y (lower on screen) drawn first
    end)
    
    -- Draw all objects with full perspective
    for _, item in ipairs(renderQueue) do
        -- Calculate perspective projection with the improved worldToScreen
        local viewX, viewY = self:worldToScreen(item.x, item.y, item.z, cam)
        
        -- Only draw if the calculated position is on screen
        if viewX >= -self.tileWidth and viewX <= windowWidth + self.tileWidth and
           viewY >= -self.tileHeight and viewY <= windowHeight + self.tileHeight then
            
            -- Calculate fog factor based on distance
            local fogFactor = 1.0 - (item.dist / cam.maxViewDist)
            fogFactor = math.max(0.3, fogFactor) -- Don't make it too dark
            
            -- Apply fog to foreground color (distance attenuation)
            local fgColor = {
                item.fg[1] * fogFactor,
                item.fg[2] * fogFactor,
                item.fg[3] * fogFactor
            }
            
            -- Draw character
            love.graphics.setColor(fgColor)
            love.graphics.print(item.char, viewX, viewY)
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Draw debug info
    love.graphics.print(string.format("Player: (%d,%d) | Camera: (%.1f,%.1f,%.1f)", 
                      self.player.x, self.player.y, 
                      cam.x, cam.y, cam.z), 10, 10)
    love.graphics.print("Move: right-click | Camera: arrow keys or mouse edges | +/- : height | A/S : angle | Z/X: cell size", 10, 30)
    love.graphics.print(string.format("Window: %dx%d | Viewport: %dx%d tiles", 
                      windowWidth, windowHeight, cam.viewportWidth, cam.viewportHeight), 10, 50)
end

-- Convert world coordinates (x,y,z) to screen coordinates
function Gameplay:worldToScreen(worldX, worldY, worldZ, cam)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Calculate camera center in world space
    local camCenterX = cam.x + cam.viewportWidth / 2
    local camCenterY = cam.y + cam.viewportHeight / 2
    
    -- Calculate relative position from camera center
    local relX = worldX - camCenterX
    local relY = worldY - camCenterY
    
    -- Calculate scale factors based on window dimensions to fill screen
    -- Use the entire available window width and height
    local scaleX = windowWidth / (cam.viewportWidth * self.tileWidth)
    local scaleY = windowHeight / (cam.viewportHeight * self.tileHeight)
    
    -- Use the smaller scale to ensure aspect ratio is maintained and the entire view fits
    local scale = math.min(scaleX, scaleY) * 0.9 -- Slight reduction to avoid edge clipping
    
    -- Convert to screen coordinates, ensuring we're centered in the window
    local screenX = (relX * self.tileWidth * scale) + (windowWidth / 2)
    local screenY = (relY * self.tileHeight * scale) + (windowHeight / 2)
    
    -- Apply perspective for z-height in all directions
    if worldZ > 0 then
        -- Calculate direction vector from camera center to object
        local dirX = relX
        local dirY = relY
        local dirLength = math.sqrt(dirX * dirX + dirY * dirY)
        
        -- Normalize direction (avoid division by zero)
        if dirLength > 0.001 then
            dirX = dirX / dirLength
            dirY = dirY / dirLength
        else
            -- Default direction if at center
            dirX, dirY = 0, -1
        end
        
        -- Calculate z-height impact based on camera angle and height
        local zFactor = worldZ * (cam.z / 20) * scale -- Scale by camera height and display scale
        local angleImpact = cam.angle * zFactor
        
        -- Apply perspective shift along the direction vector
        screenX = screenX + (dirX * angleImpact * 1.5)
        screenY = screenY + (dirY * angleImpact * 2)
    end
    
    return screenX, screenY
end

-- Center the camera on the player
function Gameplay:centerCameraOnPlayer()
    self.camera.x = self.player.x - self.camera.viewportWidth / 2
    self.camera.y = self.player.y - self.camera.viewportHeight / 2
    self:constrainCamera()
end

-- Keep camera within world bounds
function Gameplay:constrainCamera()
    self.camera.x = math.max(0, math.min(self.camera.x, self.worldWidth - self.camera.viewportWidth))
    self.camera.y = math.max(0, math.min(self.camera.y, self.worldHeight - self.camera.viewportHeight))
end

-- Handle mouse right-click for movement
function Gameplay:mousepressed(x, y, button, istouch, presses)
    if button == 2 then -- Right mouse button
        -- Convert screen position to world coordinates
        local worldX, worldY = self:screenToWorld(x, y)
        
        -- Check if position is valid and target is walkable
        if worldX >= 1 and worldX <= self.worldWidth and 
           worldY >= 1 and worldY <= self.worldHeight then
            
            local obj = self.world[worldY][worldX]
            if obj and obj.walkable then
                self.player:setDestination(worldX, worldY)
                print("Player moving to", worldX, worldY)
            else
                print("Cannot move to", worldX, worldY, "- not walkable")
            end
        end
    end
end

-- Convert screen coordinates to world coordinates
function Gameplay:screenToWorld(screenX, screenY)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Calculate scale factors (should match worldToScreen)
    local scaleX = windowWidth / (self.camera.viewportWidth * self.tileWidth)
    local scaleY = windowHeight / (self.camera.viewportHeight * self.tileHeight)
    local scale = math.min(scaleX, scaleY) * 0.9
    
    -- Convert from screen position to relative position from center
    local relScreenX = screenX - (windowWidth / 2)
    local relScreenY = screenY - (windowHeight / 2)
    
    -- Convert to world coordinates relative to camera center
    local relWorldX = relScreenX / (self.tileWidth * scale)
    local relWorldY = relScreenY / (self.tileHeight * scale)
    
    -- Convert to absolute world coordinates
    local camCenterX = self.camera.x + self.camera.viewportWidth / 2
    local camCenterY = self.camera.y + self.camera.viewportHeight / 2
    
    local worldX = math.floor(camCenterX + relWorldX) + 1
    local worldY = math.floor(camCenterY + relWorldY) + 1
    
    return worldX, worldY
end

function Gameplay:keypressed(key, scancode, isrepeat)
    if key == "m" then -- Return to MainMenu
        require("src/StateManager"):switch("MainMenu")
    elseif key == "r" then -- Regenerate the world
        local newWorld, startX, startY = generateWorld(self.worldWidth, self.worldHeight)
        self.world = newWorld
        self.worldHeight = #newWorld
        self.worldWidth = self.worldHeight > 0 and #newWorld[1] or 0
        self.player:setPosition(startX, startY)
        self:centerCameraOnPlayer()
        print("World regenerated with player at", startX, startY)
    elseif key == "+" or key == "=" then -- Increase camera height
        self.camera.z = math.min(100, self.camera.z + 5)
        print("Camera height:", self.camera.z)
    elseif key == "-" then -- Decrease camera height
        self.camera.z = math.max(10, self.camera.z - 5)
        print("Camera height:", self.camera.z)
    elseif key == "a" then -- Increase camera angle
        self.camera.angle = math.min(1.0, self.camera.angle + 0.1)
        print("Camera angle:", self.camera.angle)
    elseif key == "s" then -- Decrease camera angle
        self.camera.angle = math.max(0.1, self.camera.angle - 0.1)
        print("Camera angle:", self.camera.angle)
    elseif key == "z" then -- Decrease cell size further
        local vpWidth = self.camera.viewportWidth * 1.2
        local vpHeight = self.camera.viewportHeight * 1.2
        self.camera.viewportWidth = vpWidth
        self.camera.viewportHeight = vpHeight
        print(string.format("Viewport size increased to %.1fx%.1f", vpWidth, vpHeight))
    elseif key == "x" then -- Increase cell size
        local vpWidth = self.camera.viewportWidth * 0.8
        local vpHeight = self.camera.viewportHeight * 0.8
        self.camera.viewportWidth = vpWidth
        self.camera.viewportHeight = vpHeight
        print(string.format("Viewport size decreased to %.1fx%.1f", vpWidth, vpHeight))
    end
end

-- Return the Gameplay table definition
return Gameplay 