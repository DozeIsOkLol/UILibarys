--[[
    WinXP UI Library — Example Script
    ──────────────────────────────────
    Replace the URL below with your raw GitHub source URL.
    Execute this in any Roblox executor (Synapse X, KRNL, Fluxus, etc.)
]]

local WinXP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_USERNAME/WinXP-UI/main/Source.lua"
))()

-- ════════════════════════════════════════════════════════════════
--  CREATE  WINDOW
-- ════════════════════════════════════════════════════════════════
local Window = WinXP:CreateWindow({
    Title     = "WinXP UI  —  Example",
    Size      = UDim2.new(0, 540, 0, 440),
    ToggleKey = Enum.KeyCode.RightControl,   -- press to show / hide
    -- Icon   = "rbxassetid://0",            -- optional 16x16 icon asset
})

-- ════════════════════════════════════════════════════════════════
--  SEND  A  NOTIFICATION  ON  LOAD
-- ════════════════════════════════════════════════════════════════
Window:Notify({
    Title    = "WinXP UI",
    Message  = "Library loaded successfully! Press RCtrl to toggle.",
    Duration = 4,
    Type     = "Success",
})

-- ════════════════════════════════════════════════════════════════
--  TAB 1 — Main
-- ════════════════════════════════════════════════════════════════
local MainTab = Window:AddTab("Main")

MainTab:AddSection("Player Options")

-- Toggle: god mode
local godMode = false
MainTab:AddToggle({
    Text     = "God Mode",
    Default  = false,
    Callback = function(state)
        godMode = state
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = state and math.huge or 100
                hum.Health    = state and math.huge or 100
            end
        end
        Window:Notify({
            Title   = "God Mode",
            Message = state and "God Mode enabled." or "God Mode disabled.",
            Type    = state and "Success" or "Info",
            Duration = 2,
        })
    end,
})

-- Slider: walk speed
local WalkSpeedSlider = MainTab:AddSlider({
    Text     = "Walk Speed",
    Min      = 8,
    Max      = 300,
    Default  = 16,
    Suffix   = " stud/s",
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end,
})

-- Slider: jump power
MainTab:AddSlider({
    Text     = "Jump Power",
    Min      = 0,
    Max      = 300,
    Default  = 50,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = value end
        end
    end,
})

MainTab:AddSeparator()
MainTab:AddSection("Teleport")

-- Dropdown: teleport presets
local TeleportDropdown = MainTab:AddDropdown({
    Text    = "Teleport To",
    Options = { "Spawn", "Team Base", "Center Map", "Custom Coords" },
    Default = "Spawn",
    Callback = function(value)
        print("[WinXP Example] Teleport selected:", value)
        -- Replace with real coordinates for your game
        local destinations = {
            ["Spawn"]        = Vector3.new(0, 5, 0),
            ["Team Base"]    = Vector3.new(100, 5, 100),
            ["Center Map"]   = Vector3.new(0, 5, 500),
            ["Custom Coords"]= Vector3.new(200, 5, 200),
        }
        local char = game.Players.LocalPlayer.Character
        if char and destinations[value] then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(destinations[value]) end
        end
    end,
})

-- Button: reset walk speed
MainTab:AddButton({
    Text     = "Reset Walk Speed",
    Callback = function()
        WalkSpeedSlider:Set(16)
    end,
})

-- ════════════════════════════════════════════════════════════════
--  TAB 2 — Visuals
-- ════════════════════════════════════════════════════════════════
local VisualTab = Window:AddTab("Visuals")

VisualTab:AddSection("Rendering")

-- Toggle: fullbright
VisualTab:AddToggle({
    Text     = "Fullbright",
    Default  = false,
    Callback = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.Brightness      = 2
            lighting.ClockTime       = 14
            lighting.FogEnd          = 10000
            lighting.GlobalShadows   = false
            lighting.Ambient         = Color3.fromRGB(255, 255, 255)
            lighting.OutdoorAmbient  = Color3.fromRGB(255, 255, 255)
        else
            lighting.Brightness    = 1
            lighting.ClockTime     = 14
            lighting.GlobalShadows = true
        end
    end,
})

-- Toggle: no fog
VisualTab:AddToggle({
    Text     = "Remove Fog",
    Default  = false,
    Callback = function(state)
        game:GetService("Lighting").FogEnd = state and 10000000 or 1000
    end,
})

VisualTab:AddSeparator()
VisualTab:AddSection("Camera")

-- Slider: FOV
VisualTab:AddSlider({
    Text     = "Field of View",
    Min      = 10,
    Max      = 120,
    Default  = 70,
    Suffix   = "°",
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end,
})

-- Color picker: ambient color
VisualTab:AddColorPicker({
    Text     = "Ambient Light Color",
    Default  = Color3.fromRGB(128, 128, 128),
    Callback = function(color)
        game:GetService("Lighting").Ambient = color
    end,
})

-- ════════════════════════════════════════════════════════════════
--  TAB 3 — Settings
-- ════════════════════════════════════════════════════════════════
local SettingsTab = Window:AddTab("Settings")

SettingsTab:AddSection("UI Settings")

-- Keybind: toggle UI
SettingsTab:AddKeybind({
    Text     = "Toggle UI Key",
    Default  = Enum.KeyCode.RightControl,
    Callback = function()
        Window:Toggle()
    end,
})

SettingsTab:AddSeparator()
SettingsTab:AddSection("Misc")

-- Textbox: custom player note
local NoteLabel = SettingsTab:AddLabel("Note: (none)")

SettingsTab:AddTextbox({
    Text        = "Player Note",
    Placeholder = "Type a note and press Enter…",
    EnterOnly   = true,
    Callback    = function(value)
        if value ~= "" then
            NoteLabel:Set("Note: " .. value)
            Window:Notify({
                Title    = "Note Saved",
                Message  = value,
                Type     = "Info",
                Duration = 3,
            })
        end
    end,
})

-- Notification type showcase buttons
SettingsTab:AddSeparator()
SettingsTab:AddSection("Notification Types")

local types = { "Info", "Success", "Warning", "Error" }
for _, t in ipairs(types) do
    SettingsTab:AddButton({
        Text     = t .. " Notification",
        Callback = function()
            Window:Notify({
                Title    = t .. " Notification",
                Message  = "This is a " .. t:lower() .. " notification example.",
                Type     = t,
                Duration = 3,
            })
        end,
    })
end

print("[WinXP Example] Script loaded. Window is ready.")
