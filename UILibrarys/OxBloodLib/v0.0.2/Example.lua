--[[
	OxBlood v0.0.2 — example harness

	Load Source.lua first (ModuleScript require, or loadstring + HttpGet in an executor).
	Update LOAD_URL if you host Source.lua online.
--]]

local LOAD_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/OxBloodLib/v0.0.2/Source.lua" -- or use a local file path in your workflow

local OxBlood
if game:GetService("RunService"):IsStudio() and script:FindFirstChild("Source") then
	OxBlood = require(script.Source)
else
	OxBlood = loadstring(game:HttpGet(LOAD_URL, true))()
end

-- ── Modern API (recommended): CreateWindow → CreateTab → CreateSection ──
local Window = OxBlood:CreateWindow({
	Title = "OxBlood",
	Subtitle = "Demo",
	Version = "v0.2.0",
	Name = "OxBloodDemo",
	Size = UDim2.fromOffset(560, 420),
	ToggleKey = Enum.KeyCode.RightShift,
	SoundEnabled = true,
	Theme = "OxBlood",
	TopBarButton = { Letter = "O" },
	Blur = 0,
	Acrylic = false,
	WindowSearch = true,
})

local Home = Window:CreateTab({ Name = "Home", Icon = "⌂" })

do
	local S = Home:CreateSection("Notifications", { Collapsed = false })
	S:CreateButton("Toast: success", function()
		Window:Notify({
			Title = "Saved",
			Description = "Settings were applied successfully.",
			Type = "success",
			Duration = 4,
		})
	end, "Shows a success-style toast.")
	S:CreateButton("Toast: error", function()
		Window:Notify({ Title = "Error", Description = "Something failed.", Type = "error", Duration = 5 })
	end)
	S:CreateButton("Toast: persistent (click to dismiss)", function()
		Window:Notify({
			Title = "Pinned",
			Description = "This toast stays until you click it.",
			Type = "info",
			Persistent = true,
			OnClick = function()
				print("Notification clicked")
			end,
		})
	end)
	S:CreateButton("Toast: custom accent + icon", function()
		Window:Notify({
			Title = "Custom",
			Description = "Custom accent color and unicode icon.",
			Type = "custom",
			CustomAccent = Color3.fromRGB(255, 120, 200),
			Icon = "★",
			Duration = 3,
		})
	end)
end

do
	local S = Home:CreateSection("Controls demo")
	local t = S:CreateToggle("Demo toggle", false, function(on)
		print("Toggle:", on)
	end, "demoToggle")
	S:CreateSlider("Demo slider", { Min = 0, Max = 100, Def = 50, Step = 1 }, function(v)
		print("Slider:", v)
	end, "demoSlider")
	S:CreateDropdown("Single select", { "A", "B", "C" }, function(choice)
		print("Dropdown:", choice)
	end, { Searchable = true })
	S:CreateDropdown("Multi select", { "One", "Two", "Three" }, function() end, { Multi = true, Searchable = true })
	S:CreateTextbox("Webhook", { Placeholder = "https://…", ClearButton = true }, function(text, enter)
		if enter then
			print("Submitted:", text)
		end
	end)
	S:CreateKeybind("Hotkey", Enum.KeyCode.X, function()
		Window:Notify({ Title = "Keybind", Description = "X was pressed or re-bound.", Type = "info", Duration = 2 })
	end)
	local prog = S:CreateProgress("Load", 0.35)
	task.spawn(function()
		for i = 35, 100, 5 do
			task.wait(0.15)
			prog:Set(i / 100)
		end
	end)
	S:CreateColorPicker("Accent pick", Color3.fromRGB(160, 40, 55), function(c)
		print("Color:", c)
	end)
	S:CreateImage("rbxassetid://120220852", 96)
	S:CreateSeparator()
	local L = S:CreateLabel("Rich text label", true)
	L:Set('<font color="#FF5555"><b>OxBlood</b></font> supports RichText on labels.')
	S:CreateParagraph("Paragraph / multi-line text can wrap naturally when you use CreateLabel/CreateParagraph with long strings.")
end

do
	local S = Home:CreateSection("Config & theme")
	S:CreateButton("Export JSON (clipboard / file)", function()
		local ok = Window:SaveConfig("OxBlood_demo_config.json")
		Window:Notify({
			Title = "Config",
			Description = ok and "Saved or copied JSON." or "Could not write file; JSON may be on clipboard.",
			Type = ok and "success" or "warning",
			Duration = 3,
		})
	end)
	S:CreateButton("Import JSON from disk (executor)", function()
		local ok = Window:LoadConfig("OxBlood_demo_config.json")
		Window:Notify({
			Title = "Import",
			Description = ok and "Loaded values into registered keys." or "No file / invalid JSON.",
			Type = ok and "success" or "error",
			Duration = 3,
		})
	end)
	S:CreateButton("Switch theme → OxBloodLight", function()
		Window:SetTheme("OxBloodLight")
		Window:Notify({ Title = "Theme", Description = "Switched to OxBloodLight", Type = "info", Duration = 2 })
	end)
end

local Combat = Window:CreateTab("Combat")
do
	local S = Combat:CreateSection("Legacy-style content", { Collapsed = true })
	S:CreateToggle("Enable", false, function(s)
		print("Combat:", s)
	end)
	S:CreateSlider("FOV", { Min = 10, Max = 360, Def = 90, Step = 1 }, function(v)
		print("FOV", v)
	end)
end

-- ── Legacy v0.0.1 API (still supported) ──
local UILib = OxBlood.UILibrary
local Legacy = UILib.Load("OxBlood Legacy", "Compat Demo", "v0.2", { Letter = "L" })
local LHome = Legacy.AddPage("Legacy Home", false)
LHome.AddSection("Bridge")
LHome.AddButton("Legacy notify", function()
	Legacy.Notify("Legacy", "Notify via UILibrary.Load", "success", 3)
end)

print("[OxBlood Example] Loaded", OxBlood.VERSION)
