--[[
	================================================================================
	 SmallDarkOneLib — example.lua                                        v0.0.3
	================================================================================

	A full, runnable tour of every element in SmallDarkOneLib. Drop this into
	a LocalScript (or an executor) after replacing the raw GitHub URL below
	with your own repo's raw link to source.lua.

	HOW TO HOST source.lua ON GITHUB
	--------------------------------------------------------------------------
	1. Create a public GitHub repo (e.g. "SmallDarkOneLib").
	2. Upload source.lua to it.
	3. Open the file on GitHub and click "Raw" — copy that URL. It looks like:
		 https://raw.githubusercontent.com/<user>/<repo>/main/source.lua
	4. Paste that URL into the loadstring below.

	Executors cache HttpGet results by default; if you edit source.lua and
	don't see the change, use game:HttpGetAsync(url, true) or your
	executor's "no cache" option while testing.
]]

--// 1. LOAD THE LIBRARY -------------------------------------------------------

local REPO_RAW_URL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/SmallDarkOneLib/v0.0.3/Source.lua"

local SmallDarkOneLib = loadstring(game:HttpGet(REPO_RAW_URL))()

--// 2. CREATE THE WINDOW ------------------------------------------------------

local Window = SmallDarkOneLib:CreateWindow({
	Title         = "SMALL DARK ONE",
	Subtitle      = "SmallDarkOneLib v0.0.3",
	Theme         = "Bloodmoon",              -- try "Voidspider" for the violet alt-theme
	Size          = UDim2.new(0, 580, 0, 400),
	ToggleKey     = Enum.KeyCode.RightShift,   -- shows/hides the whole UI
	Watermark     = true,
	WatermarkText = "SmallDarkOneLib",
})

--// 3. MAIN TAB — one of every element ---------------------------------------

local MainTab = Window:CreateTab("Main")
local ActionsSection = MainTab:CreateSection("Actions")

ActionsSection:CreateButton({
	Name = "Say Hello",
	Callback = function()
		print("[SmallDarkOneLib] Hello from the Button!")
		Window:Notify({
			Title = "Button Pressed",
			Content = "The Say Hello button was clicked.",
			Type = "Info",
			Duration = 3,
		})
	end,
})

ActionsSection:CreateButtonGroup({
	Buttons = {
		{
			Text = "Save Config",
			Callback = function()
				SmallDarkOneLib:SaveConfig("SmallDarkOneExample")
				Window:Notify({ Title = "Saved", Content = "Config saved.", Type = "Success" })
			end,
		},
		{
			Text = "Load Config",
			Callback = function()
				SmallDarkOneLib:LoadConfig("SmallDarkOneExample")
				Window:Notify({ Title = "Loaded", Content = "Config loaded.", Type = "Success" })
			end,
		},
	},
})

ActionsSection:CreateDivider({ Text = "TOGGLES & VALUES" })

ActionsSection:CreateToggle({
	Name = "Auto Farm",
	Default = false,
	Flag = "AutoFarm",
	Callback = function(value)
		print("[SmallDarkOneLib] Auto Farm:", value)
	end,
})

ActionsSection:CreateCheckbox({
	Name = "Enable Sound",
	Default = true,
	Flag = "SoundEnabled",
	Callback = function(value)
		print("[SmallDarkOneLib] Sound Enabled:", value)
	end,
})

ActionsSection:CreateSlider({
	Name = "Walk Speed",
	Min = 16,
	Max = 200,
	Decimals = 0,
	Default = 16,
	Flag = "WalkSpeed",
	Callback = function(value)
		print("[SmallDarkOneLib] Walk Speed:", value)
	end,
})

local InputSection = MainTab:CreateSection("Input & Choices")

InputSection:CreateDropdown({
	Name = "Weapon",
	Options = { "Knife", "Pistol", "Rifle", "Shotgun", "Sniper" },
	Default = "Knife",
	Searchable = true,
	Flag = "Weapon",
	Callback = function(value)
		print("[SmallDarkOneLib] Weapon selected:", value)
	end,
})

InputSection:CreateDropdown({
	Name = "Perks",
	Options = { "Speed", "Strength", "Stealth", "Regen" },
	Multi = true,
	Default = { "Speed" },
	Flag = "Perks",
	Callback = function(values)
		print("[SmallDarkOneLib] Perks selected — Speed:", values.Speed and true or false)
	end,
})

InputSection:CreateTextbox({
	Name = "Username",
	Placeholder = "Enter a username...",
	Flag = "Username",
	Callback = function(text, enterPressed)
		print("[SmallDarkOneLib] Username set to:", text, "| Enter pressed:", enterPressed)
	end,
})

InputSection:CreateRadioGroup({
	Name = "Difficulty",
	Options = { "Easy", "Normal", "Hard", "Nightmare" },
	Default = "Normal",
	Flag = "Difficulty",
	Callback = function(value)
		print("[SmallDarkOneLib] Difficulty:", value)
	end,
})

--// 4. VISUAL TAB — keybind, color picker, progress, labels -------------------

local VisualTab = Window:CreateTab("Visual")
local DisplaySection = VisualTab:CreateSection("Display")

DisplaySection:CreateLabel({ Text = "These elements are more about display than input." })

DisplaySection:CreateParagraph({
	Title = "About SmallDarkOneLib",
	Content = "A dark, horrorcore-inspired UI library with zero external image "
		.. "dependencies. Every element you're looking at right now was drawn "
		.. "with UICorner, UIStroke, and UIGradient.",
})

DisplaySection:CreateProgressBar({
	Name = "XP Progress",
	Min = 0,
	Max = 100,
	Default = 35,
})

local ColorSection = VisualTab:CreateSection("Color & Keybinds")

ColorSection:CreateColorPicker({
	Name = "ESP Color",
	Default = Color3.fromRGB(196, 24, 38),
	Flag = "ESPColor",
	Callback = function(color)
		print("[SmallDarkOneLib] ESP Color set to:", color)
	end,
})

ColorSection:CreateKeybind({
	Name = "Toggle ESP",
	Default = Enum.KeyCode.E,
	Mode = "Toggle",
	Flag = "ESPKey",
	Callback = function(state)
		print("[SmallDarkOneLib] ESP is now:", state)
	end,
})

ColorSection:CreateKeybind({
	Name = "Sprint",
	Default = Enum.KeyCode.LeftShift,
	Mode = "Hold",
	Flag = "SprintKey",
	Callback = function(state)
		print("[SmallDarkOneLib] Sprint held:", state)
	end,
})

--// 5. CREDITS TAB -------------------------------------------------------------

local CreditsTab = Window:CreateTab("Credits")
local CreditsSection = CreditsTab:CreateSection("SmallDarkOneLib")

CreditsSection:CreateParagraph({
	Title = "Credits",
	Content = "SmallDarkOneLib v" .. SmallDarkOneLib.Version .. " — built for DOZE. "
		.. "Theme aesthetic inspired by horrorcore album art.",
})

CreditsSection:CreateButton({
	Name = "Close UI",
	Callback = function()
		Window:Destroy()
	end,
})

--// 6. WELCOME NOTIFICATION ---------------------------------------------------

Window:Notify({
	Title = "SmallDarkOneLib Loaded",
	Content = "Press RightShift to show/hide the UI.",
	Type = "Success",
	Duration = 5,
})
