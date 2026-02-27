--[[
    NexusLib - Example Usage Script
    Paste this into your executor after hosting NexusLib.lua on a raw URL
]]

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/NexusLib"))()

-- Create the window
local Window = Nexus:CreateWindow({
    Title     = "NexusUI",
    Subtitle  = "v0.1",
    Size      = UDim2.new(0, 520, 0, 380),
    ToggleKey = Enum.KeyCode.RightShift, -- press to show/hide
})

-- ── Tab 1: Combat ────────────────────────────────────────────────────────────
local Combat = Window:AddTab({ Name = "Combat", Icon = "⚔" })

Combat:AddSection("Aimbot")

local aimbotToggle = Combat:AddToggle({
    Name     = "Enable Aimbot",
    Default  = false,
    Callback = function(state)
        print("Aimbot:", state)
    end
})

local fovSlider = Combat:AddSlider({
    Name     = "FOV",
    Min      = 10,
    Max      = 300,
    Default  = 90,
    Callback = function(val)
        print("FOV:", val)
    end
})

Combat:AddSection("Misc")

local smoothSlider = Combat:AddSlider({
    Name     = "Smoothness",
    Min      = 0,
    Max      = 100,
    Default  = 50,
    Callback = function(val)
        print("Smooth:", val)
    end
})

Combat:AddButton({
    Name       = "Hit All Players",
    ButtonText = "Execute",
    Callback   = function()
        print("Hit!")
        Nexus:Notify({ Title = "Combat", Message = "All players hit!", Type = "Success", Duration = 3 })
    end
})

-- ── Tab 2: Visual ────────────────────────────────────────────────────────────
local Visual = Window:AddTab({ Name = "Visual", Icon = "👁" })

Visual:AddSection("ESP")

local espToggle = Visual:AddToggle({
    Name     = "Player ESP",
    Default  = false,
    Callback = function(state)
        print("ESP:", state)
    end
})

local espColor = Visual:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(100, 160, 255),
    Callback = function(color)
        print("ESP Color:", color)
    end
})

Visual:AddSection("Chams")

local chamsColor = Visual:AddColorPicker({
    Name     = "Chams Color",
    Default  = Color3.fromRGB(255, 100, 100),
    Callback = function(color)
        print("Chams:", color)
    end
})

-- ── Tab 3: Player ────────────────────────────────────────────────────────────
local Player = Window:AddTab({ Name = "Player", Icon = "🏃" })

Player:AddSection("Movement")

local speedSlider = Player:AddSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

local jumpSlider = Player:AddSlider({
    Name     = "Jump Power",
    Min      = 50,
    Max      = 500,
    Default  = 50,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
    end
})

Player:AddSection("Keybinds")

local flyKey = Player:AddKeybind({
    Name     = "Fly Toggle",
    Default  = Enum.KeyCode.F,
    OnPress  = function()
        print("Fly toggled!")
    end,
    Callback = function(key)
        print("Fly key changed to:", key.Name)
    end
})

-- ── Tab 4: Settings ──────────────────────────────────────────────────────────
local Settings = Window:AddTab({ Name = "Settings", Icon = "⚙" })

Settings:AddSection("UI")

local themeDropdown = Settings:AddDropdown({
    Name     = "Accent Color",
    Items    = { "Blue", "Purple", "Red", "Green", "Orange" },
    Default  = "Blue",
    Callback = function(val)
        print("Theme:", val)
    end
})

local notifPos = Settings:AddDropdown({
    Name     = "Notif Position",
    Items    = { "Bottom Right", "Top Right", "Bottom Left" },
    Default  = "Bottom Right",
    Callback = function(val)
        print("Notif position:", val)
    end
})

Settings:AddSection("Info")

Settings:AddButton({
    Name       = "Test Notification",
    ButtonText = "Test",
    Callback   = function()
        Nexus:Notify({
            Title    = "NexusLib",
            Message  = "This is a test notification!",
            Type     = "Info",
            Duration = 4
        })
    end
})

Settings:AddButton({
    Name       = "Discord Server",
    ButtonText = "Copy",
    Callback   = function()
        setclipboard("discord.gg/YOURLINK")
        Nexus:Notify({ Title = "Copied!", Message = "Discord invite copied.", Type = "Success" })
    end
})

-- Initial welcome notification
Nexus:Notify({
    Title    = "Welcome",
    Message  = "My Script loaded successfully.",
    Type     = "Success",
    Duration = 5,
})
