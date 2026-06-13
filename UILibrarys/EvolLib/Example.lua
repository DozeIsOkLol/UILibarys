--[[
	EvolUI Example
	By EvolEzod
]]

local EVOLUI_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/EvolLib/Source.lua"
local EvolUI = loadstring(game:HttpGet(EVOLUI_URL))()

local UI = EvolUI.Load({
	Name = "Demo",
	Subtitle = "EvolUI Library",
	Version = "v1.2.2",
	Badges = { "Dev"}, --  "Beta", "Tester", "Stable", "Premium"
	Footer = "Right Shift to toggle",
	ToggleKey = Enum.KeyCode.RightShift,
})

UI:Section("Actions")
UI:Button({
	Text = "Show Notification",
	Style = "Primary",
	Callback = function()
		UI:Notify({
			Title = "EvolUI",
			Text = "Notifications now have titles, icons, and a timer bar.",
			Type = "Success",
			Duration = 4,
		})
	end,
})

UI:Spacer(10)
UI:Section("Settings")

local godMode = UI:Toggle({
	Text = "God Mode",
	Callback = function(state)
		print("God Mode:", state)
	end,
})

UI:Slider({
	Text = "Walk Speed",
	Min = 16,
	Max = 200,
	Default = 16,
	Step = 1,
	Callback = function(value)
		print("Speed:", value)
	end,
})

UI:Input({
	Placeholder = "Enter username...",
	Callback = function(text)
		print("Input:", text)
	end,
})

UI:Dropdown({
	Text = "Weapon",
	Options = { "Sword", "Gun", "Bow" },
	Callback = function(choice)
		print("Selected:", choice)
	end,
})

UI:ValueRow({
	Title = "Cycle Value",
	Hint = "Tap to increment",
	Value = 1,
	OnClick = function(current)
		return current + 1
	end,
})

UI:Progress({ Text = "Loading", Value = 0.4 })

UI:Label("Built with EvolUI — minimal & reusable.", true)
