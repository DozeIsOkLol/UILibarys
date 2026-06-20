--[[
	EvolUI v2.0.0 — COMPREHENSIVE EXAMPLES
	Complete working examples for all widgets
	Copy and paste this to test the library
]]

local EVOLUI_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/EvolLib/Source.lua"
local EvolUI = loadstring(game:HttpGet(EVOLUI_URL))()

-- ════════════════════════════════════════════════════════════════════════════
-- WINDOW SETUP
-- ════════════════════════════════════════════════════════════════════════════

local UI = EvolUI.Load({
	Name        = "EvolUI Demo",
	Version     = "v2.0.0",
	Subtitle    = "All Widgets Showcase",
	Badges      = { "Dev", "Premium" },
	ToggleKey   = Enum.KeyCode.RightShift,
	TabSidebar  = true,
	Resizable   = true,
	Collapsible = true,
	Footer      = "EvolUI Demo | Made with ❤️",
	Width       = 350,
	Height      = 500,
})

-- ════════════════════════════════════════════════════════════════════════════
-- TAB 1: BASIC WIDGETS
-- ════════════════════════════════════════════════════════════════════════════

local BasicTab = UI:Tab("⚙️  Basics")

BasicTab:Label("Essential UI Controls", true)
BasicTab:Divider()

-- ──── BUTTONS ────
BasicTab:Button({
	Text = "Primary Button",
	Style = "Primary",
	Callback = function()
		UI:Notify({
			Title = "Primary",
			Text = "This is a primary button!",
			Type = "Info",
			Duration = 3
		})
	end
})

BasicTab:Button({
	Text = "Success Button",
	Style = "Success",
	Callback = function()
		UI:Notify({
			Title = "Success",
			Text = "Operation successful!",
			Type = "Success",
			Duration = 3
		})
	end
})

BasicTab:Button({
	Text = "Danger Button",
	Style = "Danger",
	Callback = function()
		UI:Notify({
			Title = "Warning",
			Text = "This is dangerous!",
			Type = "Warning",
			Duration = 3
		})
	end
})

BasicTab:Spacer(8)

-- ──── TOGGLES ────
local mainToggle = BasicTab:Toggle({
	Text = "Enable Feature",
	Sub = "Main feature switch",
	Default = false,
	Callback = function(value)
		print("Main Toggle: " .. tostring(value))
		UI:SetStatus(value and "Enabled" or "Disabled", value and Color3.fromRGB(68, 210, 148) or Color3.fromRGB(240, 90, 90))
	end
})

local subToggle = BasicTab:Toggle({
	Text = "Sub Feature",
	Sub = "Only works with main enabled",
	Default = false,
	Callback = function(value)
		print("Sub Toggle: " .. tostring(value))
	end
})

-- Make sub-feature depend on main
subToggle:Depends(mainToggle)

BasicTab:Spacer(8)

-- ──── SLIDERS ────
local fovSlider = BasicTab:Slider({
	Text = "FOV",
	Min = 10,
	Max = 120,
	Default = 60,
	Suffix = "°",
	Callback = function(value)
		print("FOV: " .. value .. "°")
	end
})

local speedSlider = BasicTab:Slider({
	Text = "Speed",
	Min = 0.5,
	Max = 3,
	Default = 1,
	Step = 0.1,
	Suffix = "x",
	Callback = function(value)
		print("Speed: " .. value .. "x")
	end
})

-- ════════════════════════════════════════════════════════════════════════════
-- TAB 2: ADVANCED WIDGETS
-- ════════════════════════════════════════════════════════════════════════════

local AdvancedTab = UI:Tab("🎯  Advanced")

AdvancedTab:Label("Complex Controls", true)
AdvancedTab:Divider()

-- ──── DROPDOWNS ────
local weaponDropdown = AdvancedTab:Dropdown({
	Text = "Weapon Type",
	Options = { "Assault Rifle", "Sniper", "SMG", "Shotgun", "Pistol" },
	Default = "Assault Rifle",
	Callback = function(selected)
		print("Weapon: " .. selected)
	end
})

AdvancedTab:Spacer(6)

-- ──── MULTI-DROPDOWN ────
local featuresMulti = AdvancedTab:MultiDropdown({
	Text = "Features",
	Options = { "NoClip", "God Mode", "Flight", "Speed Boost", "Infinite Jump" },
	Default = { "NoClip" },
	Callback = function(selected)
		local enabled = {}
		for name, state in pairs(selected) do
			if state then table.insert(enabled, name) end
		end
		print("Features: " .. table.concat(enabled, ", "))
	end
})

AdvancedTab:Spacer(6)

-- ──── KEYBIND ────
local toggleKeybind = AdvancedTab:Keybind({
	Text = "Toggle Key",
	Default = Enum.KeyCode.E,
	Callback = function(keycode)
		print("Keybind set to: " .. tostring(keycode))
	end
})

AdvancedTab:Spacer(6)

-- ──── COLOR PICKER ────
local espColor = AdvancedTab:ColorPicker({
	Text = "ESP Color",
	Default = Color3.fromRGB(130, 114, 245),
	DefaultAlpha = 1,
	Callback = function(color, alpha)
		print("Color picked: RGB(" .. math.floor(color.R*255) .. ", " .. math.floor(color.G*255) .. ", " .. math.floor(color.B*255) .. "), Alpha: " .. alpha)
	end
})

AdvancedTab:Spacer(6)

-- ──── INPUT ────
local usernameInput = AdvancedTab:Input({
	Placeholder = "Enter username...",
	Callback = function(text)
		print("Input: " .. text)
	end
})

-- ════════════════════════════════════════════════════════════════════════════
-- TAB 3: DISPLAY WIDGETS
-- ════════════════════════════════════════════════════════════════════════════

local DisplayTab = UI:Tab("📊  Display")

DisplayTab:Label("Information Display", true)
DisplayTab:Divider()

-- ──── STAT ROWS ────
local killStat = DisplayTab:StatRow({
	Text = "Kills",
	Value = 0,
	Color = Color3.fromRGB(68, 210, 148)
})

local deathStat = DisplayTab:StatRow({
	Text = "Deaths",
	Value = 0,
	Color = Color3.fromRGB(240, 90, 90)
})

local kdrStat = DisplayTab:StatRow({
	Text = "K/D Ratio",
	Value = "0.0",
	Color = Color3.fromRGB(96, 165, 250)
})

-- Simulate stat updates
task.spawn(function()
	local kills, deaths = 0, 0
	while task.wait(2) do
		if math.random() > 0.4 then
			kills = kills + math.random(1, 3)
			killStat.Set(kills)
		end
		if math.random() > 0.5 then
			deaths = deaths + 1
			deathStat.Set(deaths)
		end
		local kdr = deaths == 0 and kills or kills / deaths
		kdrStat.Set(string.format("%.2f", kdr))
	end
end)

DisplayTab:Spacer(8)

-- ──── PROGRESS BAR ────
local loadingProgress = DisplayTab:Progress({
	Text = "Loading",
	Value = 0.3
})

DisplayTab:Spacer(6)

-- ──── PARAGRAPH ────
local infoPara = DisplayTab:Paragraph({
	Title = "Status",
	Content = "All systems operational and ready for use. Press RightShift to toggle the UI."
})

DisplayTab:Spacer(6)

-- ──── CONSOLE ────
local console = DisplayTab:Console({
	Title = "Activity Log",
	Height = 120,
	MaxLines = 50
})

console:Print("Console initialized")
console:Success("Ready for use")

-- Simulate console messages
task.spawn(function()
	while task.wait(3) do
		local messages = {
			{ console.Print, "Task started" },
			{ console.Success, "Operation completed" },
			{ console.Info, "Scanning..." },
			{ console.Warn, "Performance: 45ms" }
		}
		local msg = messages[math.random(1, #messages)]
		msg[1](msg[2])
	end
end)

DisplayTab:Spacer(6)

-- ──── VALUE ROW ────
local clickCounter = DisplayTab:ValueRow({
	Title = "Click Counter",
	Hint = "Click to increment",
	Value = 0,
	OnClick = function(current)
		return current + 1
	end
})

-- ════════════════════════════════════════════════════════════════════════════
-- TAB 4: UTILITIES
-- ════════════════════════════════════════════════════════════════════════════

local UtilTab = UI:Tab("🔧  Utils")

UtilTab:Label("Utility Controls", true)
UtilTab:Divider()

-- ──── SECTION WITH GRID ────
UtilTab:Section("Quick Actions")

local grid = UtilTab:Grid({
	Columns = 2,
	CellW = 150,
	CellH = 28,
	Padding = 6
})

grid:Button("Action 1", function()
	UI:Notify({ Title = "Action 1", Text = "Executed!", Type = "Info" })
end)

grid:Button("Action 2", function()
	UI:Notify({ Title = "Action 2", Text = "Executed!", Type = "Success" })
end)

grid:Button("Action 3", function()
	UI:Notify({ Title = "Action 3", Text = "Executed!", Type = "Warning" })
end)

grid:Button("Action 4", function()
	UI:Notify({ Title = "Action 4", Text = "Executed!", Type = "Error" })
end)

UtilTab:Spacer(8)

-- ──── CONFIG SECTION ----
UtilTab:Section("Configuration")

UtilTab:Button({
	Text = "Save Config",
	Style = "Success",
	Callback = function()
		local config = UI:Config()
		config:Save("example_config")
		UI:Notify({ Title = "Saved", Text = "Config saved!", Type = "Success" })
	end
})

UtilTab:Button({
	Text = "Load Config",
	Style = "Primary",
	Callback = function()
		local config = UI:Config()
		if config:Load("example_config") then
			UI:Notify({ Title = "Loaded", Text = "Config loaded!", Type = "Success" })
		else
			UI:Notify({ Title = "Error", Text = "Config not found!", Type = "Error" })
		end
	end
})

UtilTab:Button({
	Text = "Delete Config",
	Style = "Danger",
	Callback = function()
		local config = UI:Config()
		config:Delete("example_config")
		UI:Notify({ Title = "Deleted", Text = "Config removed!", Type = "Warning" })
	end
})

-- ════════════════════════════════════════════════════════════════════════════
-- FINAL TOUCHES
-- ════════════════════════════════════════════════════════════════════════════

-- Add watermark
UI:Watermark({ Text = "EvolUI v2.0.0 Demo" })

-- Initial notification
UI:Notify({
	Title = "Welcome",
	Text = "EvolUI Demo Loaded! Press RightShift to toggle.",
	Type = "Success",
	Duration = 5
})

-- Live status updates
task.spawn(function()
	while task.wait(5) do
		local statuses = {
			{ "Active", Color3.fromRGB(68, 210, 148) },
			{ "Processing", Color3.fromRGB(248, 178, 60) },
			{ "Ready", Color3.fromRGB(96, 165, 250) }
		}
		local status = statuses[math.random(1, #statuses)]
		UI:SetStatus(status[1], status[2])
	end
end)

print("\n" .. string.rep("=", 50))
print("EvolUI v2.0.0 Demo - Loaded Successfully")
print("Press RightShift to toggle the UI")
print(string.rep("=", 50) .. "\n")
