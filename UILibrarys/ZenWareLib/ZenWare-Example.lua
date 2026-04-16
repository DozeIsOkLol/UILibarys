local UILibrary = loadstring(game:HttpGet("YOUR_URL_HERE/ZenWare-Source.lua"))()

-- Initialize Zen-Ware UI with config options
local UI = UILibrary.Load("Zen-Ware", "Universal Script", "v1.0", {
    Letter = "Z",           -- Topbar button letter (or use Image = "rbxassetid://...")
    Theme = "Zen",          -- "Zen" (default), "Ocean", "Forest", "Sunset"
    SaveConfig = true,      -- Enable automatic config saving/loading
    ConfigName = "ZenWare_Universal",  -- Custom config file name
    GhostMode = false,      -- Enable anti-detection (randomizes GUI names)
})

-- ================================================================
--  TAB 1 ─ Home
-- ================================================================
local Home = UI.AddPage("Home", false)   -- no search bar on home

Home.AddSection("Welcome to Zen-Ware")

Home.AddParagraph("About", "Zen-Ware is a modern, feature-rich UI library designed for peace of mind and maximum functionality. Enjoy seamless configuration saving, multiple themes, and a clean, professional interface.")

Home.AddDivider()

Home.AddLabel("🎨 Try out the notification system:")

Home.AddButton("✓ Success Notification", function()
    UI.Notify("Success", "Operation completed successfully!", "success", 4)
end)

Home.AddButton("✗ Error Notification", function()
    UI.Notify("Error", "Something went wrong!", "error", 4)
end)

Home.AddButton("ℹ Info Notification", function()
    UI.Notify("Info", "Here is some useful information.", "info", 4)
end)

Home.AddButton("⚠ Warning Notification", function()
    UI.Notify("Warning", "Proceed with caution!", "warn", 4)
end)

Home.AddDivider()

Home.AddSection("Theme Switcher")

Home.AddButton("🌊 Ocean Theme", function()
    UI.SetTheme("Ocean")
end)

Home.AddButton("🌲 Forest Theme", function()
    UI.SetTheme("Forest")
end)

Home.AddButton("🌅 Sunset Theme", function()
    UI.SetTheme("Sunset")
end)

Home.AddButton("☯️ Zen Theme (Default)", function()
    UI.SetTheme("Zen")
end)

-- ================================================================
--  TAB 2 ─ Combat
-- ================================================================
local Combat = UI.AddPage("Combat")

Combat.AddSection("Aimbot Configuration")

Combat.AddParagraph("Info", "Configure your aimbot settings below. All settings are automatically saved.")

Combat.AddToggle("Enable Aimbot", false, function(state)
    UI.Notify("Aimbot", state and "Aimbot enabled" or "Aimbot disabled",
        state and "success" or "warn", 3)
end, "Combat_Aimbot")  -- Flag name for saving

Combat.AddSlider("FOV Radius", { Min = 10, Max = 360, Def = 90 }, function(value)
    print("FOV set to:", value)
end, nil, "Combat_FOV")

Combat.AddSlider("Smoothness", { Min = 1, Max = 100, Def = 50 }, function(value)
    print("Smoothness set to:", value)
end, nil, "Combat_Smooth")

Combat.AddDropdown("Target Part", {
    "Head",
    "HumanoidRootPart",
    "UpperTorso",
    "LowerTorso",
    "LeftArm",
    "RightArm",
}, function(option)
    UI.Notify("Aimbot", "Targeting: " .. option, "info", 3)
end, "Combat_TargetPart")

Combat.AddKeybind("Aimbot Toggle Key", Enum.KeyCode.CapsLock, function(key)
    print("Aimbot keybind:", tostring(key))
end, "Combat_AimbotKey")

Combat.AddDivider()

Combat.AddSection("Silent Aim")

Combat.AddToggle("Enable Silent Aim", false, function(state)
    UI.Notify("Silent Aim", state and "Silent Aim activated" or "Silent Aim deactivated",
        state and "success" or "warn", 3)
end, "Combat_SilentAim")

Combat.AddSlider("Hit Chance %", { Min = 1, Max = 100, Def = 75 }, function(value)
    print("Hit chance:", value)
end, nil, "Combat_HitChance")

Combat.AddToggle("Ignore Teammates", true, function(state)
    print("Ignore teammates:", state)
end, "Combat_IgnoreTeam")

-- ================================================================
--  TAB 3 ─ Visuals
-- ================================================================
local Visuals = UI.AddPage("Visuals")

Visuals.AddSection("Player ESP")

Visuals.AddToggle("Box ESP", false, function(state)
    print("Box ESP:", state)
end, "Visual_BoxESP")

Visuals.AddToggle("Name Tags", true, function(state)
    print("Name ESP:", state)
end, "Visual_NameESP")

Visuals.AddToggle("Health Bar", false, function(state)
    print("Health Bar:", state)
end, "Visual_HealthBar")

Visuals.AddToggle("Distance Display", false, function(state)
    print("Distance:", state)
end, "Visual_Distance")

Visuals.AddColourPicker("ESP Color", Color3.fromRGB(85, 190, 165), function(colour)
    print("ESP colour changed:", colour)
end, "Visual_ESPColor")

Visuals.AddDivider()

Visuals.AddSection("World ESP")

Visuals.AddToggle("Item ESP", false, function(state)
    print("Item ESP:", state)
end, "Visual_ItemESP")

Visuals.AddToggle("Chest ESP", false, function(state)
    print("Chest ESP:", state)
end, "Visual_ChestESP")

Visuals.AddSlider("Render Distance", { Min = 50, Max = 2000, Def = 1000 }, function(value)
    print("Render distance:", value)
end, nil, "Visual_RenderDist")

Visuals.AddDivider()

Visuals.AddSection("UI Tweaks")

Visuals.AddToggle("Rainbow Theme", false, function(state)
    print("Rainbow mode:", state)
    -- Could implement color cycling here
end, "Visual_Rainbow")

Visuals.AddSlider("UI Transparency", { Min = 0, Max = 100, Def = 0 }, function(value)
    print("UI Transparency:", value)
    -- Could adjust UI transparency here
end, nil, "Visual_Transparency")

-- ================================================================
--  TAB 4 ─ Misc
-- ================================================================
local Misc = UI.AddPage("Misc")

Misc.AddSection("Movement")

Misc.AddToggle("Speed Boost", false, function(state)
    print("Speed boost:", state)
end, "Misc_Speed")

Misc.AddSlider("Speed Multiplier", { Min = 1, Max = 5, Def = 2 }, function(value)
    print("Speed multiplier:", value)
end, nil, "Misc_SpeedMult")

Misc.AddToggle("Infinite Jump", false, function(state)
    print("Infinite jump:", state)
end, "Misc_InfJump")

Misc.AddToggle("No Clip", false, function(state)
    print("No clip:", state)
end, "Misc_NoClip")

Misc.AddKeybind("No Clip Toggle", Enum.KeyCode.N, function(key)
    print("No clip key:", tostring(key))
end, "Misc_NoClipKey")

Misc.AddDivider()

Misc.AddSection("Automation")

Misc.AddToggle("Auto Farm", false, function(state)
    UI.Notify("Auto Farm", state and "Started farming" or "Stopped farming",
        state and "success" or "warn", 3)
end, "Misc_AutoFarm")

Misc.AddToggle("Auto Collect", false, function(state)
    print("Auto collect:", state)
end, "Misc_AutoCollect")

Misc.AddInput("Farm Target", "Enter target name...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        UI.Notify("Target", "Farm target set to: " .. text, "info", 3)
        print("Farm target:", text)
    end
end, "Misc_FarmTarget")

Misc.AddDivider()

Misc.AddSection("Teleportation")

Misc.AddButton("Teleport to Spawn", function()
    UI.Notify("Teleport", "Teleporting to spawn...", "info", 2)
    -- Teleport logic here
end)

Misc.AddInput("Teleport to Player", "Username", function(text, enterPressed)
    if enterPressed and text ~= "" then
        UI.Notify("Teleport", "Teleporting to: " .. text, "info", 3)
        print("Teleporting to:", text)
    end
end, "Misc_TPTarget")

-- ================================================================
--  TAB 5 ─ Settings
-- ================================================================
local Settings = UI.AddPage("Settings", false)   -- no search bar

Settings.AddSection("Keybinds")

Settings.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key)
    print("UI toggle key:", tostring(key))
end, "Settings_ToggleUI")

Settings.AddKeybind("Panic Key", Enum.KeyCode.End, function(key)
    UI.Notify("Panic", "Panic key pressed! Hiding UI...", "warn", 2)
    -- Could hide UI or disable all features
end, "Settings_PanicKey")

Settings.AddDivider()

Settings.AddSection("Configuration")

Settings.AddParagraph("Config Info", "Your settings are automatically saved. You can also manually save/load configurations using the buttons below.")

Settings.AddButton("💾 Force Save Config", function()
    UI.Notify("Config", "Configuration saved!", "success", 3)
end)

Settings.AddButton("🔄 Reload Config", function()
    UI.Notify("Config", "Configuration reloaded!", "info", 3)
end)

Settings.AddButton("🗑️ Reset to Defaults", function()
    UI.Notify("Config", "Settings reset to defaults!", "warn", 3)
end)

Settings.AddDivider()

Settings.AddSection("Advanced")

Settings.AddInput("Webhook URL", "https://discord.com/api/webhooks/...", function(text, enterPressed)
    if enterPressed then
        UI.Notify("Webhook", "Webhook URL saved!", "success", 3)
        print("Webhook URL:", text)
    end
end, "Settings_Webhook")

Settings.AddTextArea("Custom Script", 80, function(text)
    print("Custom script updated")
end, "Settings_CustomScript")

Settings.AddDivider()

Settings.AddSection("Status Information")

-- Live-updating status labels
local StatusInfo = Settings.AddTextInfo("Status: Idle")
local VersionInfo = Settings.AddTextInfo("Library Version: Zen-Ware v1.0")
local PlayerInfo = Settings.AddTextInfo("Player: " .. game.Players.LocalPlayer.Name)

-- Demo: update status every 5 seconds
task.spawn(function()
    local states = {
        "Status: Idle",
        "Status: Monitoring...",
        "Status: Processing",
        "Status: Active",
    }
    local idx = 1
    while task.wait(5) do
        idx = (idx % #states) + 1
        StatusInfo.Set(states[idx])
    end
end)

Settings.AddButton("Refresh Status", function()
    StatusInfo.Set("Status: Refreshed ✓")
    UI.Notify("Settings", "Status refreshed!", "info", 2)
end)

-- ================================================================
--  TAB 6 ─ Credits
-- ================================================================
local Credits = UI.AddPage("Credits", false)

Credits.AddSection("Zen-Ware Information")

Credits.AddParagraph("Developer", "Created with ❤️ for the Roblox exploiting community.")

Credits.AddLabel("Version: 1.0.0")
Credits.AddLabel("Built on: Enhanced UI Framework")

Credits.AddDivider()

Credits.AddSection("Features")

Credits.AddLabel("✓ Multi-theme support (4 themes)")
Credits.AddLabel("✓ Automatic config saving/loading")
Credits.AddLabel("✓ Smooth animations & transitions")
Credits.AddLabel("✓ Notification system")
Credits.AddLabel("✓ Search functionality")
Credits.AddLabel("✓ Ghost mode (anti-detection)")
Credits.AddLabel("✓ Draggable interface")
Credits.AddLabel("✓ Mobile-friendly keybinds")

Credits.AddDivider()

Credits.AddSection("Support")

Credits.AddButton("💬 Join Discord", function()
    UI.Notify("Discord", "Discord link copied! (not implemented)", "info", 3)
end)

Credits.AddButton("⭐ Star on GitHub", function()
    UI.Notify("GitHub", "GitHub link copied! (not implemented)", "info", 3)
end)

Credits.AddButton("📝 Report Bug", function()
    UI.Notify("Bug Report", "Bug report opened! (not implemented)", "info", 3)
end)

-- ================================================================
--  INITIALIZATION COMPLETE
-- ================================================================
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("  ███████╗███████╗███╗   ██╗")
print("  ╚══███╔╝██╔════╝████╗  ██║")
print("    ███╔╝ █████╗  ██╔██╗ ██║")
print("   ███╔╝  ██╔══╝  ██║╚██╗██║")
print("  ███████╗███████╗██║ ╚████║")
print("  ╚══════╝╚══════╝╚═╝  ╚═══╝")
print("  WARE UI Library v1.0")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✓ Zen-Ware loaded successfully!")
print("✓ Config saving:", "enabled")
print("✓ Theme:", "Zen")
print("✓ Toggle key: RightShift")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Initial notification
UI.Notify("Zen-Ware", "UI loaded successfully! Press RightShift to toggle.", "success", 5)
