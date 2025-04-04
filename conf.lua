function love.conf(t)
    t.window.title = "ASCII Survival Horror (Working Title)" -- Set the window title
    t.window.width = 1024 -- Set the window width
    t.window.height = 768 -- Set the window height

    -- Optional: Enable vsync for smoother rendering (can impact performance)
    t.window.vsync = 1

    -- Optional: Define modules to load (can optimize startup slightly if some aren't needed)
    -- t.modules.audio = true
    -- t.modules.event = true
    -- t.modules.graphics = true
    -- t.modules.image = true
    -- t.modules.joystick = false -- Disable if not using joysticks
    -- t.modules.keyboard = true
    -- t.modules.math = true
    -- t.modules.mouse = true
    -- t.modules.physics = false -- Disable if not using physics module initially
    -- t.modules.sound = true
    -- t.modules.system = true
    -- t.modules.timer = true
    -- t.modules.touch = false -- Disable if not targeting touch devices
    -- t.modules.video = false -- Disable if not playing videos
    -- t.modules.window = true
    -- t.modules.thread = false -- Disable if not using threading
end 