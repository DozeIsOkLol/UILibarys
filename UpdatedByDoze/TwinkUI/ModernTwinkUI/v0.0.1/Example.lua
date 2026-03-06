--[[
	ModernTwinkUI Example
	This example demonstrates all available UI elements and features
]]

-- Load the library (replace with your actual loadstring URL)
local UILibrary = loadstring(game:HttpGet("URL_HERE"))()

-- Create main UI with options
local MainUI = UILibrary.Load("Twink Hub / DOZE", {
	Size = {Width = 600, Height = 450},
	Theme = "Dark"
})

-- Create pages with icons
local HomePage = MainUI.AddPage("Home", "🏠")
local SettingsPage = MainUI.AddPage("Settings", "⚙️")
local AboutPage = MainUI.AddPage("About", "ℹ️")

-- ============================================
-- HOME PAGE - Main Features
-- ============================================

HomePage.AddLabel("Main Controls", {Size = 16, Color = Color3.fromRGB(99, 102, 241)})

HomePage.AddButton("Click Me!", function()
	MainUI.Notify("Success", "Button was clicked!", "Success", 3)
end, {Color = Color3.fromRGB(99, 102, 241)})

HomePage.AddButton("Danger Action", function()
	MainUI.Notify("Warning", "This is a dangerous action!", "Warning", 4)
end, {Color = Color3.fromRGB(239, 68, 68)})

HomePage.AddDivider()

HomePage.AddLabel("Toggle Options")

local AutoFarm = HomePage.AddToggle("Auto Farm", false, function(Value)
	print("Auto Farm:", Value)
	if Value then
		MainUI.Notify("Enabled", "Auto Farm is now active", "Success")
	else
		MainUI.Notify("Disabled", "Auto Farm is now inactive", "Info")
	end
end)

HomePage.AddToggle("ESP", true, function(Value)
	print("ESP:", Value)
end)

HomePage.AddToggle("No Clip", false, function(Value)
	print("No Clip:", Value)
end)

HomePage.AddDivider()

HomePage.AddLabel("Slider Controls")

HomePage.AddSlider("Walk Speed", {
	Min = 16,
	Max = 200,
	Def = 16,
	Increment = 1
}, function(Value)
	print("Walk Speed:", Value)
	-- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

HomePage.AddSlider("Jump Power", {
	Min = 50,
	Max = 300,
	Def = 50,
	Increment = 5
}, function(Value)
	print("Jump Power:", Value)
end)

HomePage.AddSlider("FOV", {
	Min = 70,
	Max = 120,
	Def = 90
}, function(Value)
	print("FOV:", Value)
	-- workspace.Camera.FieldOfView = Value
end)

-- ============================================
-- SETTINGS PAGE - Configuration
-- ============================================

SettingsPage.AddLabel("Input Fields", {Size = 16, Color = Color3.fromRGB(99, 102, 241)})

SettingsPage.AddInput("Player Name", "Enter name...", function(Value)
	print("Player Name:", Value)
	MainUI.Notify("Name Set", "Player name: " .. Value, "Info")
end)

SettingsPage.AddInput("Teleport Position", "X, Y, Z", function(Value)
	print("Position:", Value)
end)

SettingsPage.AddInput("Amount", "0", function(Value)
	print("Amount:", Value)
end, {Numeric = true})

SettingsPage.AddDivider()

SettingsPage.AddLabel("Dropdown Menus")

SettingsPage.AddDropdown("Select Weapon", {
	"Sword",
	"Bow",
	"Staff",
	"Axe",
	"Dagger"
}, function(Value)
	print("Selected Weapon:", Value)
	MainUI.Notify("Weapon Selected", Value, "Info")
end, {Default = "Sword"})

SettingsPage.AddDropdown("Game Mode", {
	"Solo",
	"Duo",
	"Squad",
	"Custom"
}, function(Value)
	print("Game Mode:", Value)
end)

SettingsPage.AddDivider()

SettingsPage.AddLabel("Color Pickers")

SettingsPage.AddColorPicker("Character Color", Color3.fromRGB(99, 102, 241), function(Color)
	print("Character Color:", Color)
end)

SettingsPage.AddColorPicker("ESP Color", "red", function(Color)
	print("ESP Color:", Color)
end)

SettingsPage.AddColorPicker("UI Accent", Color3.fromRGB(34, 197, 94), function(Color)
	print("UI Accent:", Color)
end)

SettingsPage.AddDivider()

SettingsPage.AddLabel("Keybinds")

SettingsPage.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function()
	print("UI Toggle keybind pressed!")
	MainUI.Notify("Keybind", "UI Toggle activated", "Info")
end)

SettingsPage.AddKeybind("Auto Farm", Enum.KeyCode.F, function()
	print("Auto Farm keybind pressed!")
	-- Toggle the auto farm
	AutoFarm:SetValue(not AutoFarm)
end)

SettingsPage.AddKeybind("Emergency Stop", Enum.KeyCode.X, function()
	print("Emergency Stop!")
	MainUI.Notify("Emergency", "All features disabled", "Warning")
end)

-- ============================================
-- ABOUT PAGE - Information
-- ============================================

AboutPage.AddLabel("ModernTwinkUI", {Size = 18, Color = Color3.fromRGB(99, 102, 241)})

AboutPage.AddLabel("Version 2.0.0", {Size = 12, Color = Color3.fromRGB(156, 163, 175)})

AboutPage.AddDivider()

AboutPage.AddLabel("Features")
AboutPage.AddLabel("✓ Modern design with smooth animations", {Size = 12})
AboutPage.AddLabel("✓ Customizable themes and colors", {Size = 12})
AboutPage.AddLabel("✓ Rich UI components", {Size = 12})
AboutPage.AddLabel("✓ Notification system", {Size = 12})
AboutPage.AddLabel("✓ Keybind support", {Size = 12})
AboutPage.AddLabel("✓ Draggable and minimizable", {Size = 12})

AboutPage.AddDivider()

AboutPage.AddButton("Test Notifications", function()
	MainUI.Notify("Success", "This is a success notification!", "Success", 3)
	task.wait(0.5)
	MainUI.Notify("Info", "This is an info notification!", "Info", 3)
	task.wait(0.5)
	MainUI.Notify("Warning", "This is a warning notification!", "Warning", 3)
	task.wait(0.5)
	MainUI.Notify("Error", "This is an error notification!", "Error", 3)
end)

AboutPage.AddButton("Show Credits", function()
	MainUI.Notify("Credits", "Created with ModernTwinkUI v2.0", "Info", 5)
end)

-- ============================================
-- Example: Programmatically control elements
-- ============================================

-- You can store references to UI elements and control them later
-- For example, toggle the auto farm from code:
-- AutoFarm:SetValue(true)

-- Example: Create a notification on startup
MainUI.Notify("Welcome", "ModernTwinkUI loaded successfully!", "Success", 4)
