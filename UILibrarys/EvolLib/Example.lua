--[[
	EvolUI v1.3.0 — Example Usage
	Covers all widgets including new ones
]]

local EVOLUI_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/EvolLib/Source.lua"
local EvolUI = loadstring(game:HttpGet(EVOLUI_URL))()

local UI = EvolUI.Load({
	Name       = "EvolUI Demo",
	Subtitle   = "v1.3.0 Example",
	Version    = "v1.3.0",
	Badges     = { "Dev", "Beta" },
	Footer     = "RightShift to toggle",
	ToggleKey  = Enum.KeyCode.RightShift,
	GuiName    = "EvolUI_Demo",
})

-- ══════════════════════════════════════
-- NOTIFICATIONS
-- ══════════════════════════════════════
UI:Section("Notifications")

local notifyGrid = UI:Grid({ Columns = 2, CellW = 126, CellH = 30 })

notifyGrid:Button("✓ Success", function()
	UI:Notify({ Title = "Success", Text = "Action completed successfully.", Type = "Success", Duration = 3 })
end)

notifyGrid:Button("✕ Error", function()
	UI:Notify({ Title = "Error", Text = "Something went wrong.", Type = "Error", Duration = 3 })
end)

notifyGrid:Button("! Warning", function()
	UI:Notify({ Title = "Warning", Text = "Proceed with caution.", Type = "Warning", Duration = 3 })
end)

notifyGrid:Button("i Info", function()
	UI:Notify({ Title = "Info", Text = "Here is some information.", Type = "Info", Duration = 3 })
end)

-- ══════════════════════════════════════
-- TOGGLES
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Toggles")

local godMode = UI:Toggle({
	Text     = "God Mode",
	Default  = false,
	Callback = function(state)
		print("God Mode:", state)
		UI:Notify({
			Title = "God Mode",
			Text  = state and "God Mode enabled." or "God Mode disabled.",
			Type  = state and "Success" or "Warning",
			Duration = 2,
		})
	end,
})

UI:Toggle({
	Text     = "Infinite Jump",
	Default  = false,
	Callback = function(state)
		print("Infinite Jump:", state)
	end,
})

-- Programmatically toggle god mode on after 3 seconds
task.delay(3, function()
	godMode:Set(true)
	print("God mode force-enabled via :Set()")
end)

-- ══════════════════════════════════════
-- SLIDERS
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Sliders")

UI:Slider({
	Text     = "Walk Speed",
	Min      = 16,
	Max      = 200,
	Default  = 16,
	Step     = 1,
	Callback = function(value)
		print("Walk Speed:", value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end,
})

UI:Slider({
	Text     = "Jump Power",
	Min      = 50,
	Max      = 500,
	Default  = 50,
	Step     = 10,
	Callback = function(value)
		print("Jump Power:", value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = value
		end
	end,
})

-- ══════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Input")

local nameInput = UI:Input({
	Title       = "Player Name",
	Placeholder = "Enter a username...",
	Callback    = function(text)
		print("Input submitted:", text)
	end,
})

UI:Button({
	Text     = "Read Input Value",
	Style    = "Primary",
	Callback = function()
		local val = nameInput:GetValue()
		UI:Notify({
			Title    = "Input Value",
			Text     = val ~= "" and val or "(empty)",
			Type     = "Info",
			Duration = 2,
		})
	end,
})

UI:Button({
	Text     = "Clear Input",
	Style    = "Secondary",
	Callback = function()
		nameInput:Clear()
	end,
})

-- ══════════════════════════════════════
-- DROPDOWN
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Dropdown")

local weaponDrop = UI:Dropdown({
	Text     = "Weapon",
	Options  = { "Sword", "Gun", "Bow", "Staff" },
	Default  = "Sword",
	Callback = function(choice)
		print("Selected weapon:", choice)
		UI:Notify({ Title = "Weapon", Text = "Equipped: " .. choice, Type = "Success", Duration = 2 })
	end,
})

UI:Button({
	Text     = "Set Options Dynamically",
	Style    = "Secondary",
	Callback = function()
		weaponDrop:SetOptions({ "Spear", "Dagger", "Axe", "Wand" })
		UI:Notify({ Title = "Dropdown", Text = "Options replaced!", Type = "Info", Duration = 2 })
	end,
})

-- ══════════════════════════════════════
-- KEYBIND  (new in v1.3.0)
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Keybind")

UI:Keybind({
	Text     = "Toggle Fly",
	Default  = Enum.KeyCode.F,
	Callback = function(key)
		print("Fly key rebound to:", tostring(key))
		UI:Notify({ Title = "Keybind", Text = "Fly key set to: " .. tostring(key):gsub("Enum.KeyCode.", ""), Type = "Success", Duration = 2 })
	end,
})

-- ══════════════════════════════════════
-- INFO ROWS  (new in v1.3.0)
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Info Rows")

local statusRow = UI:InfoRow("Status",  "Idle")
local pingRow   = UI:InfoRow("Ping",    "-- ms")
local fpsRow    = UI:InfoRow("FPS",     "-- fps")

-- Live ping + FPS update
task.spawn(function()
	local RunService = game:GetService("RunService")
	local Stats      = game:GetService("Stats")
	while task.wait(1) do
		local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		pingRow.SetValue(tostring(ping) .. " ms")

		local fps = math.floor(1 / RunService.Heartbeat:Wait())
		fpsRow.SetValue(tostring(fps) .. " fps")
	end
end)

-- Update status row when god mode changes
task.spawn(function()
	while task.wait(0.5) do
		statusRow.SetValue(godMode:Get() and "God Mode" or "Idle")
	end
end)

-- ══════════════════════════════════════
-- COLOR ROW  (new in v1.3.0)
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Color Row")

local colorRow = UI:ColorRow({
	Text  = "Accent Color",
	Color = Color3.fromRGB(130, 114, 245),
})

local colorGrid = UI:Grid({ Columns = 3, CellW = 80, CellH = 28 })

local colorPresets = {
	{ "Purple",  Color3.fromRGB(130, 114, 245) },
	{ "Teal",    Color3.fromRGB(68,  210, 148) },
	{ "Red",     Color3.fromRGB(240, 90,  90)  },
	{ "Blue",    Color3.fromRGB(96,  165, 250) },
	{ "Gold",    Color3.fromRGB(248, 178, 60)  },
	{ "Pink",    Color3.fromRGB(236, 130, 180) },
}

for _, preset in ipairs(colorPresets) do
	colorGrid:Button(preset[1], function()
		colorRow.SetColor(preset[2])
	end)
end

-- ══════════════════════════════════════
-- SEPARATOR  (new in v1.3.0)
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Separator("Miscellaneous")

-- ══════════════════════════════════════
-- VALUE ROW + PROGRESS
-- ══════════════════════════════════════
local cycleRow = UI:ValueRow({
	Title   = "Lives",
	Hint    = "Tap to add a life",
	Value   = 3,
	OnClick = function(current)
		local next = current + 1
		if next > 10 then next = 1 end
		return next
	end,
})

local bar = UI:Progress({ Text = "Health", Value = 0.8 })

UI:Button({
	Text     = "Take Damage  −10%",
	Style    = "Danger",
	Callback = function()
		local current = bar:Get and bar:Get() or 0.8
		bar.Set(math.max(0, current - 0.1))
	end,
})

UI:Button({
	Text     = "Heal  +10%",
	Style    = "Secondary",
	Callback = function()
		local current = bar:Get and bar:Get() or 0.8
		bar.Set(math.min(1, current + 0.1))
	end,
})

-- ══════════════════════════════════════
-- RUNTIME HEADER UPDATE
-- ══════════════════════════════════════
UI:Spacer(6)
UI:Section("Runtime Updates")

UI:Button({
	Text     = "Update Subtitle",
	Style    = "Primary",
	Callback = function()
		UI:SetSubtitle("Updated at " .. os.date("%H:%M:%S"))
		UI:Notify({ Title = "Header", Text = "Subtitle updated!", Type = "Info", Duration = 2 })
	end,
})

UI:Button({
	Text     = "Update Footer",
	Style    = "Secondary",
	Callback = function()
		UI:SetFooter("Last action: " .. os.date("%H:%M:%S"))
	end,
})

-- ══════════════════════════════════════
-- LABEL
-- ══════════════════════════════════════
UI:Spacer(4)
UI:Label("EvolUI v1.3.0 — all widgets shown above.", true)
