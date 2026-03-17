
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/TwinkLibV2/v0.0.4/Source.lua"))()

-- ================================================================
--  INIT
-- ================================================================
local UI = UILibrary.Load("Twink UI", "Testing", "v0.0.4", {
    Letter = "T",   -- Roblox topbar button showing "T"
    -- Image = "rbxassetid://YOUR_ID_HERE"  ← swap to use an image instead
})

-- QoL features
UI.SetAccentColor(Color3.fromRGB(110, 85, 210))  -- purple accent (default)
UI.SetWatermark(true)                             -- show FPS / ping bar

-- Welcome notification
task.delay(0.6, function()
    UI.Notify("Twink UI", "Loaded  ·  v5.0", "success", 5)
end)

-- ================================================================
--  TAB 1 — Home
-- ================================================================
local Home = UI.AddPage("Home", false)

Home.AddSection("Script Info")

Home.AddLabel("Twink UI  v5.0  —  Example Script")

local StatusBar = Home.AddProgressBar("Script Load", 0)
-- Animate the load bar up to 100 % over 2 seconds for visual effect
task.spawn(function()
    for i = 1, 100 do
        task.wait(0.02)
        StatusBar.Set(i)
    end
    StatusBar.SetColor(Color3.fromRGB(0, 210, 100))   -- turn green when done
    UI.Notify("Ready", "All systems loaded!", "success", 3)
end)

Home.AddSection("Notifications")

Home.AddButton("✓  Success Toast", function()
    UI.Notify("Success", "Operation completed successfully.", "success", 4)
end)

Home.AddButton("✕  Error Toast", function()
    UI.Notify("Error", "Something went wrong — check your settings.", "error", 4)
end)

Home.AddButton("ℹ  Info Toast", function()
    UI.Notify("Info", "Remember to read the docs before using.", "info", 4)
end)

Home.AddButton("⚠  Warning Toast", function()
    UI.Notify("Warning", "Server hop detected — slowing down.", "warn", 4)
end)

Home.AddButton("🔔  Spam Test (5 toasts)", function()
    -- Demonstrates the max-cap: oldest dismisses automatically
    local types = {"success","error","info","warn","success"}
    local msgs  = {
        "First notification",
        "Second notification",
        "Third notification",
        "Fourth notification",
        "Fifth — oldest should be gone",
    }
    for i = 1, 5 do
        task.delay((i-1) * 0.25, function()
            UI.Notify("Toast "..i, msgs[i], types[i], 6)
        end)
    end
end)

-- ================================================================
--  TAB 2 — Combat
-- ================================================================
local Combat = UI.AddPage("Combat")

Combat.AddSection("Aimbot")

local AimbotEnabled = false

Combat.AddToggle("Enable Aimbot", false, function(state)
    AimbotEnabled = state
    UI.Notify("Aimbot", state and "Aimbot enabled" or "Aimbot disabled",
        state and "success" or "warn", 3)
end)

Combat.AddSlider("FOV", { Min = 10, Max = 500, Def = 120 }, function(value)
    -- Update your FOV circle / cam FOV here
    print("[Aimbot] FOV:", value)
end)

Combat.AddSlider("Smoothness", { Min = 1, Max = 100, Def = 30 }, function(value)
    print("[Aimbot] Smooth:", value)
end)

Combat.AddStepper("Aim Part", {
    "Head",
    "HumanoidRootPart",
    "UpperTorso",
    "LowerTorso",
    "RightHand",
}, function(option, index)
    UI.Notify("Aimbot", "Now targeting: " .. option, "info", 2)
    print("[Aimbot] Part:", option, "| Index:", index)
end)

Combat.AddSection("Silent Aim")

Combat.AddToggle("Silent Aim", false, function(state)
    UI.Notify("Silent Aim", state and "Silent Aim ON" or "Silent Aim OFF",
        state and "success" or "warn", 3)
end)

Combat.AddSlider("Hit Chance %", { Min = 1, Max = 100, Def = 80 }, function(value)
    print("[Silent Aim] Hit chance:", value)
end)

Combat.AddSection("Misc")

Combat.AddMultiToggle("Extra Options", {
    { Text = "No Recoil",      Default = true  },
    { Text = "No Spread",      Default = false },
    { Text = "Rapid Fire",     Default = false },
    { Text = "Infinite Ammo",  Default = false },
}, function(states)
    for name, enabled in pairs(states) do
        print("[Combat]", name, "=", enabled)
    end
end)

-- ================================================================
--  TAB 3 — ESP / Visuals
-- ================================================================
local ESP = UI.AddPage("ESP/Visuals")

ESP.AddSection("Player ESP")

ESP.AddToggle("Box ESP", false, function(state)
    print("[ESP] Box:", state)
end)

ESP.AddToggle("Name ESP", true, function(state)
    print("[ESP] Name:", state)
end)

ESP.AddToggle("Health Bar", false, function(state)
    print("[ESP] Health bar:", state)
end)

ESP.AddToggle("Distance Tag", false, function(state)
    print("[ESP] Distance:", state)
end)

ESP.AddColourPicker("Box Colour", Color3.fromRGB(255, 80, 80), function(col)
    print("[ESP] Box colour:", col)
end)

local HealthBar = ESP.AddProgressBar("Target HP", 100)

-- Demo: cycle the health bar for visual effect
task.spawn(function()
    local hp = 100
    while task.wait(1.5) do
        hp = math.max(0, hp - math.random(5, 20))
        HealthBar.Set(hp)
        -- Colour shifts from green → orange → red as HP drops
        if hp > 60 then
            HealthBar.SetColor(Color3.fromRGB(0, 210, 100))
        elseif hp > 30 then
            HealthBar.SetColor(Color3.fromRGB(255, 165, 0))
        else
            HealthBar.SetColor(Color3.fromRGB(255, 60, 60))
        end
        if hp == 0 then hp = 100 end   -- loop back up
    end
end)

ESP.AddSection("Render")

ESP.AddSlider("Max Distance", { Min = 50, Max = 2000, Def = 800 }, function(value)
    print("[ESP] Render distance:", value)
end)

ESP.AddStepper("ESP Style", { "Corners", "Full Box", "Skeleton", "Dot" }, function(opt)
    UI.Notify("ESP", "Style: " .. opt, "info", 2)
end)

-- ================================================================
--  TAB 4 — Movement
-- ================================================================
local Movement = UI.AddPage("Movement")

Movement.AddSection("Speed")

Movement.AddToggle("Speed Hack", false, function(state)
    UI.Notify("Movement", state and "Speed ON" or "Speed OFF",
        state and "success" or "warn", 3)
end)

Movement.AddSlider("Walk Speed", { Min = 16, Max = 500, Def = 60 }, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

Movement.AddSection("Jump")

Movement.AddToggle("Infinite Jump", false, function(state)
    print("[Movement] Infinite jump:", state)
end)

Movement.AddSlider("Jump Power", { Min = 50, Max = 500, Def = 100 }, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

Movement.AddSection("Fly")

Movement.AddMultiToggle("Fly Options", {
    { Text = "Enable Fly",     Default = false },
    { Text = "Noclip",         Default = false },
    { Text = "Anti-Gravity",   Default = false },
}, function(states)
    for name, enabled in pairs(states) do
        print("[Movement]", name, "=", enabled)
    end
end)

-- ================================================================
--  TAB 5 — Settings
-- ================================================================
local Settings = UI.AddPage("Settings", false)

Settings.AddSection("Keybinds")

Settings.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key)
    print("[Settings] UI toggle / rebound to:", tostring(key))
end)

Settings.AddKeybind("Toggle Aimbot", Enum.KeyCode.CapsLock, function(key)
    print("[Settings] Aimbot toggle / rebound to:", tostring(key))
end)

Settings.AddKeybind("Teleport Key", Enum.KeyCode.G, function(key)
    print("[Settings] Teleport / rebound to:", tostring(key))
end)

Settings.AddSection("Webhook")

Settings.AddInput("Webhook URL", "https://discord.com/api/webhooks/...", function(text, entered)
    if entered and text ~= "" then
        UI.Notify("Webhook", "URL saved!", "success", 3)
        print("[Settings] Webhook:", text)
    end
end)

Settings.AddInput("Target Username", "Enter player name...", function(text, entered)
    if entered and text ~= "" then
        UI.Notify("Target", "Targeting: " .. text, "info", 3)
        print("[Settings] Target:", text)
    end
end)

Settings.AddSection("Accent Colour")

Settings.AddColourPicker("UI Accent", Color3.fromRGB(110, 85, 210), function(col)
    UI.SetAccentColor(col)   -- live-updates every accent element instantly
end)

Settings.AddSection("Display")

Settings.AddToggle("Show Watermark", true, function(state)
    UI.SetWatermark(state)
end)

Settings.AddSection("Status")

local ScriptStatus = Settings.AddTextInfo("Script Status: Running")
local GameInfo     = Settings.AddTextInfo("Game: 10 Player Flee")
local PlayerCount  = Settings.AddTextInfo("Players: loading...")

-- Update player count every 5 seconds
task.spawn(function()
    while task.wait(5) do
        local count = #game.Players:GetPlayers()
        PlayerCount.Set("Players in server: " .. count)
    end
end)

-- Simulate status changes
task.spawn(function()
    local statuses = {
        "Script Status: Idle",
        "Script Status: Scanning...",
        "Script Status: Target Found!",
        "Script Status: Running",
        "Script Status: Waiting...",
    }
    local i = 1
    while task.wait(6) do
        i = (i % #statuses) + 1
        ScriptStatus.Set(statuses[i])
    end
end)

Settings.AddSection("Config")

Settings.AddButton("💾  Save Config", function()
    UI.SaveConfig("default")
    UI.Notify("Config", "Settings saved!", "success", 3)
end)

Settings.AddButton("📂  Load Config", function()
    UI.LoadConfig("default")
    UI.Notify("Config", "Settings loaded!", "info", 3)
end)

-- ================================================================
--  DONE
-- ================================================================
print("[TwinkUI v5.0] Example script loaded successfully.")
