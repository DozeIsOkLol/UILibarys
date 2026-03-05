
-- This demonstrates how to create a UI with multiple dropdown tabs

local Library = loadstring(game:HttpGet("path/to/CustomUILib.lua"))()

-- Create Main Window
local Window = Library:CreateWindow("My Custom UI", Enum.KeyCode.RightShift)

-- Create Combat Tab/Dropdown
local CombatTab = Window:CreateDropdown("Combat")

CombatTab:AddButton("Kill All", function()
    print("Kill All activated!")
end)

CombatTab:AddToggle("Auto Attack", false, function(state)
    print("Auto Attack:", state)
end)

CombatTab:AddSlider("Damage Multiplier", 1, 100, 10, function(value)
    print("Damage Multiplier set to:", value)
end)

CombatTab:AddKeybind("Kill Aura", Enum.KeyCode.F, function(key)
    print("Kill Aura activated with key:", key.Name)
end)

-- Create Player Tab/Dropdown
local PlayerTab = Window:CreateDropdown("Player")

PlayerTab:AddLabel("--- Movement Settings ---")

PlayerTab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    print("Walk Speed set to:", value)
    -- Example: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

PlayerTab:AddSlider("Jump Power", 50, 200, 50, function(value)
    print("Jump Power set to:", value)
    -- Example: game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

PlayerTab:AddToggle("Infinite Jump", false, function(state)
    print("Infinite Jump:", state)
end)

PlayerTab:AddToggle("No Clip", false, function(state)
    print("No Clip:", state)
end)

-- Create Visuals Tab/Dropdown
local VisualsTab = Window:CreateDropdown("Visuals")

VisualsTab:AddToggle("ESP", false, function(state)
    print("ESP:", state)
end)

VisualsTab:AddToggle("Tracers", false, function(state)
    print("Tracers:", state)
end)

VisualsTab:AddToggle("Full Bright", false, function(state)
    print("Full Bright:", state)
end)

VisualsTab:AddSlider("FOV", 70, 120, 70, function(value)
    print("FOV set to:", value)
    -- Example: workspace.CurrentCamera.FieldOfView = value
end)

-- Create Misc Tab/Dropdown
local MiscTab = Window:CreateDropdown("Miscellaneous")

MiscTab:AddButton("Rejoin Server", function()
    print("Rejoining server...")
end)

MiscTab:AddButton("Server Hop", function()
    print("Server hopping...")
end)

MiscTab:AddTextbox("Enter Player Name", function(text)
    print("Player name entered:", text)
end)

MiscTab:AddToggle("Anti AFK", false, function(state)
    print("Anti AFK:", state)
end)

-- Create Settings Tab/Dropdown
local SettingsTab = Window:CreateDropdown("Settings")

SettingsTab:AddLabel("--- UI Configuration ---")

SettingsTab:AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key)
    print("UI toggle key changed to:", key.Name)
end)

SettingsTab:AddButton("Save Config", function()
    print("Configuration saved!")
end)

SettingsTab:AddButton("Load Config", function()
    print("Configuration loaded!")
end)

SettingsTab:AddButton("Reset UI", function()
    print("UI reset to default!")
end)

print("Custom UI Library loaded successfully!")
print("Press RightShift to toggle the UI")
