-- Advanced Example Usage of Custom UI Library v2.0
-- This demonstrates all the new features

local Library = loadstring(game:HttpGet("path/to/CustomUILib.lua"))()

-- Send a welcome notification
Library:Notify("Welcome!", "Custom UI Library v2.0 loaded successfully", 3, "Success")

-- Create Main Window
local Window = Library:CreateWindow("Advanced Custom UI", Enum.KeyCode.RightShift)

-- =========================
-- COMBAT TAB
-- =========================
local CombatTab = Window:CreateDropdown("⚔️ Combat")

CombatTab:AddSection("Attack Settings")

CombatTab:AddButton("Kill All Enemies", function()
    Library:Notify("Combat", "Kill All activated!", 2, "Info")
    print("Kill All activated!")
end)

CombatTab:AddToggle("Auto Attack", false, function(state)
    Library.ConfigData["AutoAttack"] = state
    print("Auto Attack:", state)
    
    if state then
        Library:Notify("Combat", "Auto Attack enabled", 2, "Success")
    else
        Library:Notify("Combat", "Auto Attack disabled", 2, "Warning")
    end
end)

CombatTab:AddSlider("Attack Speed", 1, 100, 10, function(value)
    Library.ConfigData["AttackSpeed"] = value
    print("Attack Speed set to:", value)
end)

CombatTab:AddSection("Aura Settings")

CombatTab:AddSlider("Kill Aura Range", 10, 100, 20, function(value)
    Library.ConfigData["KillAuraRange"] = value
    print("Kill Aura Range:", value)
end)

CombatTab:AddKeybind("Toggle Kill Aura", Enum.KeyCode.F, function(key)
    Library:Notify("Keybind", "Kill Aura toggled with " .. key.Name, 2, "Info")
    print("Kill Aura activated with key:", key.Name)
end)

CombatTab:AddMultiToggle("Attack Mode", {"Single Target", "Multi Target", "AoE"}, "Single Target", function(mode)
    Library.ConfigData["AttackMode"] = mode
    Library:Notify("Combat", "Attack mode changed to " .. mode, 2, "Info")
    print("Attack Mode:", mode)
end)

-- =========================
-- PLAYER TAB
-- =========================
local PlayerTab = Window:CreateDropdown("👤 Player")

PlayerTab:AddSection("Movement")

PlayerTab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    Library.ConfigData["WalkSpeed"] = value
    print("Walk Speed set to:", value)
    -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

PlayerTab:AddSlider("Jump Power", 50, 200, 50, function(value)
    Library.ConfigData["JumpPower"] = value
    print("Jump Power set to:", value)
    -- game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

PlayerTab:AddToggle("Infinite Jump", false, function(state)
    Library.ConfigData["InfiniteJump"] = state
    print("Infinite Jump:", state)
end)

PlayerTab:AddToggle("No Clip", false, function(state)
    Library.ConfigData["NoClip"] = state
    print("No Clip:", state)
end)

PlayerTab:AddSection("Flight")

PlayerTab:AddToggle("Fly", false, function(state)
    Library.ConfigData["Fly"] = state
    if state then
        Library:Notify("Player", "Flight enabled", 2, "Success")
    else
        Library:Notify("Player", "Flight disabled", 2, "Warning")
    end
end)

PlayerTab:AddSlider("Flight Speed", 1, 10, 5, function(value)
    Library.ConfigData["FlightSpeed"] = value
    print("Flight Speed:", value)
end)

PlayerTab:AddKeybind("Toggle Fly", Enum.KeyCode.E, function(key)
    Library:Notify("Keybind", "Flight toggled", 2, "Info")
end)

-- =========================
-- VISUALS TAB
-- =========================
local VisualsTab = Window:CreateDropdown("👁️ Visuals")

VisualsTab:AddSection("ESP Settings")

VisualsTab:AddToggle("Player ESP", false, function(state)
    Library.ConfigData["PlayerESP"] = state
    print("Player ESP:", state)
end)

VisualsTab:AddToggle("Name ESP", false, function(state)
    Library.ConfigData["NameESP"] = state
    print("Name ESP:", state)
end)

VisualsTab:AddToggle("Distance ESP", false, function(state)
    Library.ConfigData["DistanceESP"] = state
    print("Distance ESP:", state)
end)

VisualsTab:AddColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    Library.ConfigData["ESPColor"] = color
    print("ESP Color:", color)
    Library:Notify("Visuals", "ESP color updated", 2, "Success")
end)

VisualsTab:AddSection("Tracers & FOV")

VisualsTab:AddToggle("Tracers", false, function(state)
    Library.ConfigData["Tracers"] = state
    print("Tracers:", state)
end)

VisualsTab:AddColorPicker("Tracer Color", Color3.fromRGB(0, 255, 0), function(color)
    Library.ConfigData["TracerColor"] = color
    print("Tracer Color:", color)
end)

VisualsTab:AddSlider("Field of View", 70, 120, 70, function(value)
    Library.ConfigData["FOV"] = value
    print("FOV set to:", value)
    -- workspace.CurrentCamera.FieldOfView = value
end)

VisualsTab:AddSection("Lighting")

VisualsTab:AddToggle("Full Bright", false, function(state)
    Library.ConfigData["FullBright"] = state
    print("Full Bright:", state)
end)

VisualsTab:AddSlider("Ambient Brightness", 0, 10, 1, function(value)
    Library.ConfigData["AmbientBrightness"] = value
    print("Ambient Brightness:", value)
end)

-- =========================
-- FARMING TAB
-- =========================
local FarmTab = Window:CreateDropdown("🌾 Auto Farm")

FarmTab:AddInfoBox("Configure your auto-farming settings below. Make sure to select the correct farm mode for optimal results.")

FarmTab:AddToggle("Enable Auto Farm", false, function(state)
    Library.ConfigData["AutoFarm"] = state
    
    if state then
        Library:Notify("Farm", "Auto Farm started!", 2, "Success")
    else
        Library:Notify("Farm", "Auto Farm stopped", 2, "Warning")
    end
end)

FarmTab:AddDropdownSelector("Farm Mode", {"Coins", "Items", "XP", "Boss"}, "Coins", function(mode)
    Library.ConfigData["FarmMode"] = mode
    Library:Notify("Farm", "Farm mode: " .. mode, 2, "Info")
    print("Farm Mode:", mode)
end)

FarmTab:AddSlider("Farm Distance", 10, 100, 30, function(value)
    Library.ConfigData["FarmDistance"] = value
    print("Farm Distance:", value)
end)

FarmTab:AddSection("Farm Progress")

local FarmProgress = FarmTab:AddProgressBar("Farming Progress", 100)

-- Simulate progress (in real usage, you'd update this based on actual farm progress)
spawn(function()
    for i = 0, 100, 10 do
        wait(1)
        FarmProgress:SetValue(i)
    end
end)

FarmTab:AddToggle("Auto Sell", false, function(state)
    Library.ConfigData["AutoSell"] = state
    print("Auto Sell:", state)
end)

-- =========================
-- TELEPORT TAB
-- =========================
local TeleportTab = Window:CreateDropdown("📍 Teleports")

TeleportTab:AddSection("Quick Teleports")

TeleportTab:AddButton("Teleport to Spawn", function()
    Library:Notify("Teleport", "Teleporting to spawn...", 2, "Info")
    print("Teleporting to spawn")
end)

TeleportTab:AddButton("Teleport to Shop", function()
    Library:Notify("Teleport", "Teleporting to shop...", 2, "Info")
    print("Teleporting to shop")
end)

TeleportTab:AddButton("Teleport to Boss", function()
    Library:Notify("Teleport", "Teleporting to boss...", 2, "Info")
    print("Teleporting to boss")
end)

TeleportTab:AddSection("Custom Teleport")

TeleportTab:AddTextbox("Enter Position (X,Y,Z)", function(text)
    Library:Notify("Teleport", "Teleporting to: " .. text, 2, "Info")
    print("Custom teleport to:", text)
end)

TeleportTab:AddButton("Save Current Position", function()
    Library:Notify("Teleport", "Position saved!", 2, "Success")
    print("Position saved")
end)

-- =========================
-- MISC TAB
-- =========================
local MiscTab = Window:CreateDropdown("⚙️ Miscellaneous")

MiscTab:AddSection("Server")

MiscTab:AddButton("Rejoin Server", function()
    Library:Notify("Server", "Rejoining server...", 2, "Info")
    print("Rejoining server...")
end)

MiscTab:AddButton("Server Hop", function()
    Library:Notify("Server", "Finding new server...", 2, "Info")
    print("Server hopping...")
end)

MiscTab:AddButton("Copy Server JobId", function()
    Library:Notify("Server", "JobId copied to clipboard", 2, "Success")
    print("JobId copied")
end)

MiscTab:AddSection("Player Tools")

MiscTab:AddTextbox("Target Player Name", function(text)
    Library:Notify("Misc", "Target set to: " .. text, 2, "Info")
    print("Player name entered:", text)
end)

MiscTab:AddButton("Spectate Target", function()
    Library:Notify("Misc", "Spectating target player", 2, "Info")
    print("Spectating")
end)

MiscTab:AddSection("Utility")

MiscTab:AddToggle("Anti AFK", false, function(state)
    Library.ConfigData["AntiAFK"] = state
    print("Anti AFK:", state)
end)

MiscTab:AddToggle("Auto Rejoin on Kick", false, function(state)
    Library.ConfigData["AutoRejoin"] = state
    print("Auto Rejoin:", state)
end)

MiscTab:AddMultiToggle("Chat Mode", {"Normal", "Spam", "Silent"}, "Normal", function(mode)
    Library:Notify("Misc", "Chat mode: " .. mode, 2, "Info")
    print("Chat Mode:", mode)
end)

-- =========================
-- SETTINGS TAB
-- =========================
local SettingsTab = Window:CreateDropdown("⚙️ Settings")

SettingsTab:AddSection("UI Configuration")

SettingsTab:AddDropdownSelector("Theme", {"Dark", "Light", "Ocean", "Forest", "Sunset"}, "Dark", function(theme)
    Library:SetTheme(theme)
    Library.ConfigData["Theme"] = theme
    print("Theme changed to:", theme)
end)

SettingsTab:AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key)
    Library:Notify("Settings", "UI toggle key: " .. key.Name, 2, "Info")
    print("UI toggle key changed to:", key.Name)
end)

SettingsTab:AddInfoBox("Press your selected keybind to show/hide the UI. All settings are automatically saved when you configure them.")

SettingsTab:AddSection("Config Management")

local ConfigName = ""

SettingsTab:AddTextbox("Config Name", function(text)
    ConfigName = text
    print("Config name set to:", text)
end)

SettingsTab:AddButton("Save Config", function()
    if ConfigName ~= "" then
        Library:SaveConfig(ConfigName)
    else
        Library:Notify("Config", "Please enter a config name first", 2, "Error")
    end
end)

SettingsTab:AddButton("Load Config", function()
    if ConfigName ~= "" then
        Library:LoadConfig(ConfigName)
    else
        Library:Notify("Config", "Please enter a config name first", 2, "Error")
    end
end)

SettingsTab:AddSection("UI Actions")

SettingsTab:AddButton("Reset All Settings", function()
    Library:Notify("Settings", "All settings reset to default", 2, "Warning")
    print("UI reset to default!")
end)

SettingsTab:AddButton("Destroy UI", function()
    Window:Destroy()
end)

SettingsTab:AddSection("About")

SettingsTab:AddInfoBox("Custom UI Library v2.0 - A modern, feature-rich Roblox UI library with advanced customization options. Created with love for the scripting community!")

-- =========================
-- CREDITS TAB
-- =========================
local CreditsTab = Window:CreateDropdown("ℹ️ Credits")

CreditsTab:AddLabel("--- UI Library Credits ---")
CreditsTab:AddInfoBox("This UI library was created to provide scripters with a modern, easy-to-use interface system. Special thanks to the Roblox scripting community!")

CreditsTab:AddSection("Features")
CreditsTab:AddLabel("✓ Multiple Dropdown Tabs")
CreditsTab:AddLabel("✓ Color Picker System")
CreditsTab:AddLabel("✓ Notification System")
CreditsTab:AddLabel("✓ Config Save/Load")
CreditsTab:AddLabel("✓ Multiple Themes")
CreditsTab:AddLabel("✓ Progress Bars")
CreditsTab:AddLabel("✓ And Much More!")

print("=================================")
print("Custom UI Library v2.0 Loaded!")
print("Press RightShift to toggle UI")
print("=================================")

-- Test all notification types
wait(1)
Library:Notify("Info", "This is an info notification", 3, "Info")
wait(1)
Library:Notify("Success", "This is a success notification", 3, "Success")
wait(1)
Library:Notify("Warning", "This is a warning notification", 3, "Warning")
wait(1)
Library:Notify("Error", "This is an error notification", 3, "Error")
