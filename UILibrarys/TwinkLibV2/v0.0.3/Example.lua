local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/TwinkLibV2/v0.0.3/Source.lua"))()

local UI = UILibrary.Load("Twink UI", "Demo Game", "v0.0.3", {
    Letter = nil,  
})

-- ================================================================
--  TAB 1 ─ Home
-- ================================================================
local Home = UI.AddPage("Home", false)   -- no search bar on home

Home.AddSection("Welcome")

Home.AddLabel("Twink UI  v4.0  —  Demo Script")

Home.AddButton("🔔  Fire Success Notification", function()
    UI.Notify("Success", "This is a success toast!", "success", 4)
end)

Home.AddButton("❌  Fire Error Notification", function()
    UI.Notify("Error", "Something went wrong!", "error", 4)
end)

Home.AddButton("ℹ  Fire Info Notification", function()
    UI.Notify("Info", "Here is some useful information.", "info", 4)
end)

Home.AddButton("⚠  Fire Warning Notification", function()
    UI.Notify("Warning", "Proceed with caution!", "warn", 4)
end)

-- ================================================================
--  TAB 2 ─ Combat
-- ================================================================
local Combat = UI.AddPage("Combat")

Combat.AddSection("Aimbot")

Combat.AddToggle("Enable Aimbot", false, function(state)
    UI.Notify("Aimbot", state and "Aimbot enabled" or "Aimbot disabled",
        state and "success" or "warn", 3)
end)

Combat.AddSlider("FOV", { Min = 10, Max = 360, Def = 90 }, function(value)
    -- e.g. set your FOV circle radius here
    print("FOV set to:", value)
end)

Combat.AddSlider("Smooth", { Min = 1, Max = 100, Def = 50 }, function(value)
    print("Smooth set to:", value)
end)

Combat.AddDropdown("Aim Part", {
    "Head",
    "HumanoidRootPart",
    "UpperTorso",
    "LowerTorso",
}, function(option)
    UI.Notify("Aimbot", "Aim part set to: " .. option, "info", 3)
end)

Combat.AddSection("Silent Aim")

Combat.AddToggle("Silent Aim", false, function(state)
    UI.Notify("Silent Aim", state and "Silent Aim on" or "Silent Aim off",
        state and "success" or "warn", 3)
end)

Combat.AddSlider("Hit Chance %", { Min = 1, Max = 100, Def = 75 }, function(value)
    print("Hit chance:", value)
end)

-- ================================================================
--  TAB 3 ─ ESP/Visuals
-- ================================================================
local ESP = UI.AddPage("ESP/Visuals")

ESP.AddSection("Player ESP")

ESP.AddToggle("Box ESP", false, function(state)
    print("Box ESP:", state)
end)

ESP.AddToggle("Name ESP", true, function(state)
    print("Name ESP:", state)
end)

ESP.AddToggle("Health Bar", false, function(state)
    print("Health Bar:", state)
end)

ESP.AddColourPicker("ESP Colour", Color3.fromRGB(255, 80, 80), function(colour)
    print("ESP colour changed:", colour)
end)

ESP.AddSection("World ESP")

ESP.AddToggle("Item ESP", false, function(state)
    print("Item ESP:", state)
end)

ESP.AddSlider("Render Distance", { Min = 50, Max = 2000, Def = 1000 }, function(value)
    print("Render distance:", value)
end)

-- ================================================================
--  TAB 4 ─ Settings
-- ================================================================
local Settings = UI.AddPage("Settings", false)   -- no search bar

Settings.AddSection("Keybinds")

Settings.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key)
    -- The callback fires both when rebound AND when the key is pressed
    -- You can use this to toggle visibility manually if needed
    print("Keybind fired / rebound to:", tostring(key))
end)

Settings.AddKeybind("Toggle Aimbot", Enum.KeyCode.CapsLock, function(key)
    print("Aimbot keybind fired / rebound to:", tostring(key))
end)

Settings.AddSection("Input")

Settings.AddInput("Webhook URL", "https://discord.com/api/webhooks/...", function(text, enterPressed)
    if enterPressed then
        UI.Notify("Webhook", "URL saved!", "success", 3)
        print("Webhook URL:", text)
    end
end)

Settings.AddInput("Target Player", "Enter username...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        UI.Notify("Target", "Target set to: " .. text, "info", 3)
        print("Target:", text)
    end
end)

Settings.AddSection("Status")

-- AddTextInfo returns an object with a .Set(text) method
local StatusInfo   = Settings.AddTextInfo("Status: Idle")
local KeybindInfo  = Settings.AddTextInfo("Last Keybind: None")
local VersionInfo  = Settings.AddTextInfo("Library Version: v4.0")

-- Demo: update StatusInfo every 5 seconds
task.spawn(function()
    local states = {
        "Status: Idle",
        "Status: Scanning...",
        "Status: Target Found",
        "Status: Running",
    }
    local idx = 1
    while task.wait(5) do
        idx = (idx % #states) + 1
        StatusInfo.Set(states[idx])
    end
end)

-- Update KeybindInfo whenever any keybind callback fires
-- (done manually here for demo purposes)
Settings.AddButton("Refresh Status", function()
    StatusInfo.Set("Status: Refreshed ✓")
    UI.Notify("Settings", "Status refreshed!", "info", 2)
end)

-- ================================================================
--  DONE — all features demonstrated!
-- ================================================================
print("[TwinkUI Demo] Loaded successfully")
