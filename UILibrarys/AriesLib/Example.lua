-- AriesLib Example / Demo Script
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/AriesLib/Source.lua"))()

-- Create a window using the only exposed public function
-- Properties table supports: Name, IntroText, IntroIcon, IntroBlur, IntroBlurIntensity, Theme
local window = Library:CreateWindow({
    Name = "Aries Demo Hub",               -- Main window title
    IntroText = "Welcome to AriesLib",      -- Shown during intro animation
    IntroIcon = "rbxassetid://10618644218", -- Optional icon (Roblox asset id)
    IntroBlur = true,                       -- Enable blur background on intro
    IntroBlurIntensity = 15,                -- Blur strength
    Theme = Library.Themes.Dark             -- Or Library.Themes.Light / custom table
    -- Theme can also be a custom table like: { BackgroundColor = Color3.new(...), ... }
})

-- IMPORTANT NOTES:
-- From source analysis, this library appears to only implement:
--   - Window creation with intro animation + basic sidebar/main frame structure
--   - Theme system (Dark default)
--   - Utility functions internally (Create/Destroy elements)
-- But NO public methods are defined for:
--   - Creating tabs
--   - Creating sections/groups
--   - Adding buttons, toggles, sliders, dropdowns, textboxes, etc.
--   - Notifications, keybinds, colorpickers, or any interactive elements

-- So this script will:
--   - Load the library
--   - Show the intro animation + main window frame/sidebar
--   - But you won't see tabs or controls yet (library seems incomplete or early-stage)

print("AriesLib window created!")
print("→ Check if a dark-themed GUI with sidebar appears")
print("→ Intro should show '" .. window.IntroText .. "' with icon")
print("→ If nothing interactive shows, the lib might need tabs/elements added in future updates")

-- Optional: If the library gets updated later to support tabs/sections like:
-- local tab = window:Tab("Main")
-- tab:Section("Controls"):Button("Click", function() ... end)
-- You can add them here when available.
