local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/LuaLandUILib/Source.lua"))()

local Window = lib:CreateWindow({
	Title     = "Lua Land Ui Library",
	Subtitle  = "Developed By LLH Lua Land",
	TitleIcon = "house", -- Find available icons here: Dictions-Icons.md
	Theme     = "Default", -- Find available themes here: Dictions-Themes.md

    Intro = {
		Title    = "Lua Land Ui Library",
		Subtitle = "Developed By LLH Lua Land",
		Icon     = "home",
	},
})

local HomeTab = Window:CreateTab({
	Name      = "Home",
	Icon      = "house",
	SearchBar = false, -- Set to true if you want this tab with Search Bar
})

HomeTab:CreateSection("Welcome to Lua Land Ui Library!")

HomeTab:CreateLabel("Developed By LLH Lua Land")

HomeTab:CreateButton("Join Discord", function()
   print("Link: https://discord.gg/EmxDAmasj6")
end)

HomeTab:CreateSlider("", 0, 500, function(Value)
     print("Slide it!")
end)

HomeTab:CreateToggle("Fly", function(Value)
    print("Logic Here!")
end)

HomeTab:CreateCheckbox("Enable Floating", function(Value)
   print("Logic Here!")
end)

HomeTab:CreateDropdown({
	Label   = "Choose type",
	Options = {"Team Color", "Health Color", "Static Color", "Rainbow"},
	Default = "Team Color",
}, function(Value)
	print("ESP Color Mode:", Value)
end)
