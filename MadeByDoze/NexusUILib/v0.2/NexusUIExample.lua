--[[
    NexusLib v0.2 - Full Example
    Replace RAW_URL with your hosted NexusLib.lua raw link
]]

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/NexusUILib/v0.2/NexusLib.lua"))()

local Win = Nexus:CreateWindow({
    Title      = "My Script",
    Subtitle   = "v0.2",
    Size       = UDim2.new(0, 560, 0, 400),
    ToggleKey  = Enum.KeyCode.RightShift,
    ConfigDir  = "MyScript",          -- folder name for saved configs
    Watermark  = "My Script",         -- shows live clock watermark (remove line to disable)
})

-- ──────────────────────────────────────────────────────────────────────────────
-- TAB: Combat (with Sub-Tabs)
-- ──────────────────────────────────────────────────────────────────────────────
local Combat = Win:AddTab({ Name = "Combat", Icon = "⚔" })

-- Sub-Tab: Aimbot
local Aimbot = Combat:AddSubTab({ Name = "Aimbot" })

Aimbot:AddSection("Settings")

local aimbotToggle = Aimbot:AddToggle({
    Id       = "aimbot_enabled",   -- Id is used for config save/load
    Name     = "Enable Aimbot",
    Default  = false,
    Tooltip  = "Locks aim to nearest target",
    Callback = function(state)
        print("Aimbot:", state)
    end,
})

local fovSlider = Aimbot:AddSlider({
    Id       = "aimbot_fov",
    Name     = "FOV",
    Min      = 10, Max = 300, Default = 90, Step = 5,
    Tooltip  = "Field of view radius for target detection",
    Callback = function(v) print("FOV:", v) end,
})

local smoothSlider = Aimbot:AddSlider({
    Id       = "aimbot_smooth",
    Name     = "Smoothness",
    Min      = 0, Max = 100, Default = 50,
    Tooltip  = "Higher = slower, more human-like",
    Callback = function(v) print("Smooth:", v) end,
})

local targetPart = Aimbot:AddDropdown({
    Id       = "aimbot_part",
    Name     = "Target Part",
    Items    = { "Head", "Torso", "HumanoidRootPart" },
    Default  = "Head",
    Tooltip  = "Which body part to aim at",
    Callback = function(v) print("Target:", v) end,
})

-- Sub-Tab: Triggerbot
local Trigger = Combat:AddSubTab({ Name = "Triggerbot" })

Trigger:AddSection("Triggerbot")

Trigger:AddToggle({
    Id       = "trigger_enabled",
    Name     = "Enable Triggerbot",
    Default  = false,
    Callback = function(v) print("Trigger:", v) end,
})

Trigger:AddSlider({
    Id       = "trigger_delay",
    Name     = "Shoot Delay (ms)",
    Min      = 0, Max = 500, Default = 50, Step = 10,
    Callback = function(v) print("Delay:", v) end,
})

-- ──────────────────────────────────────────────────────────────────────────────
-- TAB: Visual
-- ──────────────────────────────────────────────────────────────────────────────
local Visual = Win:AddTab({ Name = "Visual", Icon = "👁" })

Visual:AddSection("ESP")

Visual:AddToggle({
    Id       = "esp_enabled",
    Name     = "Player ESP",
    Default  = false,
    Tooltip  = "Draws boxes around all players",
    Callback = function(v) print("ESP:", v) end,
})

Visual:AddColorPicker({
    Id       = "esp_color",
    Name     = "ESP Color",
    Default  = Color3.fromRGB(99, 157, 255),
    Callback = function(c) print("ESP color:", c) end,
})

Visual:AddMultiDropdown({
    Id       = "esp_elements",
    Name     = "ESP Elements",
    Items    = { "Box", "Name", "Health Bar", "Distance", "Skeleton" },
    Default  = { "Box", "Name" },
    Tooltip  = "Choose which ESP elements to show",
    Callback = function(arr) print("Elements:", table.concat(arr, ", ")) end,
})

Visual:AddSection("Chams")

Visual:AddToggle({
    Id       = "chams_enabled",
    Name     = "Enable Chams",
    Default  = false,
    Callback = function(v) print("Chams:", v) end,
})

Visual:AddColorPicker({
    Id       = "chams_color",
    Name     = "Chams Color",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(c) print("Chams:", c) end,
})

-- ──────────────────────────────────────────────────────────────────────────────
-- TAB: Player
-- ──────────────────────────────────────────────────────────────────────────────
local Player = Win:AddTab({ Name = "Player", Icon = "🏃" })

Player:AddSection("Movement")

local speedSlider = Player:AddSlider({
    Id       = "player_speed",
    Name     = "Walk Speed",
    Min      = 16, Max = 300, Default = 16, Step = 1,
    Tooltip  = "Default is 16",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end,
})

Player:AddSlider({
    Id       = "player_jump",
    Name     = "Jump Power",
    Min      = 50, Max = 500, Default = 50, Step = 10,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = v
        end
    end,
})

Player:AddSection("Keybinds")

Player:AddKeybind({
    Id       = "fly_key",
    Name     = "Fly Toggle",
    Default  = Enum.KeyCode.F,
    Tooltip  = "Press to toggle fly mode",
    OnPress  = function() print("Fly toggled!") end,
    Callback = function(k) print("Fly key:", k.Name) end,
})

Player:AddSection("Misc")

Player:AddButton({
    Name       = "Reset Character",
    ButtonText = "Reset",
    Tooltip    = "Kills your character",
    Callback   = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = 0
        end
    end,
})

-- ──────────────────────────────────────────────────────────────────────────────
-- TAB: Settings (Config + Misc)
-- ──────────────────────────────────────────────────────────────────────────────
local Settings = Win:AddTab({ Name = "Settings", Icon = "⚙" })

Settings:AddSection("Appearance")

Settings:AddDropdown({
    Name     = "Toggle Key",
    Items    = { "RightShift", "End", "Delete", "Home" },
    Default  = "RightShift",
    Callback = function(v) print("Toggle key set:", v) end,
})

Settings:AddTextInput({
    Name        = "Script Tag",
    Placeholder = "e.g. [NEXUS]",
    Tooltip     = "Custom tag shown in watermark",
    Callback    = function(text) print("Tag:", text) end,
})

Settings:AddSection("Notifications")

Settings:AddButton({
    Name       = "Test: Info",
    ButtonText = "Send",
    Callback   = function()
        Nexus:Notify({ Title = "Info", Message = "This is an info notification.", Type = "Info", Duration = 4 })
    end,
})
Settings:AddButton({
    Name       = "Test: Success",
    ButtonText = "Send",
    Callback   = function()
        Nexus:Notify({ Title = "Success", Message = "Operation completed!", Type = "Success", Duration = 4 })
    end,
})
Settings:AddButton({
    Name       = "Test: Warning",
    ButtonText = "Send",
    Callback   = function()
        Nexus:Notify({ Title = "Warning", Message = "Be careful with this setting.", Type = "Warning", Duration = 4 })
    end,
})
Settings:AddButton({
    Name       = "Test: Error",
    ButtonText = "Send",
    Callback   = function()
        Nexus:Notify({ Title = "Error", Message = "Something went wrong.", Type = "Error", Duration = 4 })
    end,
})

-- ── Config Panel (at the bottom of Settings) ─────────────────────────────────
Settings:AddConfigPanel()

-- ── Welcome notification ──────────────────────────────────────────────────────
Nexus:Notify({
    Title    = "Welcome",
    Message  = "NexusLib v2.0 loaded successfully.",
    Type     = "Success",
    Duration = 5,
})
