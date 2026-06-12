# 🏝️ Lua-Land-Ui-Library

🏝️ Lua Land Ui Library - A roblox ui library that help you to build an script immediately and easier. it was build since April 21, 2026 developed By LLH Lua Land.

# ❓ Why use Lua Land Ui Library

Using Lua Land Ui Library is better because it is the faster ui library that you can build your own scripts without building your custom gui. It also has an icon dictions and Themes dictions that you can use without rbxassetid only name of the icon.

# ✨ What are the ui elements

Lua Land Ui Library has a complete and good ui elements, the following are:

- TextButton
- TextLabel
- Slider
- Toogles
- Checkbox
- Dropdown
- Search Bar

Those are the list of ui elements in Lua Land Ui Library that you can create

# ⚡ Installation

**Booting Up The Library:**

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Angelo-Gitland/Lua-Land-Ui-Library/refs/heads/main/Lua%20Land%20Ui"))()
```

**Setting-Up the windows:**

```lua
local Window = lib:CreateWindow({
	Title     = "Lua Land Ui Library",
	Subtitle  = "Developed By LLH Lua Land",
	TitleIcon = "house", -- Find available icons here: Dictions-Icons.md
	Theme     = "Default", -- Find available themes here: Dictions-Themes.md
```

**Setting-Up Intro:**

```lua
Intro = {
		Title    = "Lua Land Ui Library",
		Subtitle = "Developed By LLH Lua Land",
		Icon     = "home",
	},
})
```

**Creating a Tab:**

```lua
local HomeTab = Window:CreateTab({
	Name      = "Home",
	Icon      = "house",
	SearchBar = false, -- Set to true if you want this tab with Search Bar
})
```

**Creating a Section:**

```lua
HomeTab:CreateSection("Welcome to Lua Land Ui Library!")
```

**Creating a TextLabel:**

```lua
HomeTab:CreateLabel("Developed By LLH Lua Land")
```

**Creating a TextButton:**

```lua
HomeTab:CreateButton("Join Discord", function()
   print("Link: https://discord.gg/EmxDAmasj6")
end)
```

**Creating a Slider:**

```lua
HomeTab:CreateSlider", 0, 500, function(Value)
     print("Slide it!")
end)
```

**Creating a Toogle:**

```lua
HomeTab:CreateToogle("Fly", function(Value)
    print("Logic Here!")
end)
```

**Creating a CheckBox:**

```lua
HomeTab:CreateCheckbox("Enable Floating", function(Value)
   print("Logic Here!")
end)
```

**Creating a Dropdown:**

```lua
HomeTab:CreateDropdown({
	Label   = "Choose type",
	Options = {"Team Color", "Health Color", "Static Color", "Rainbow"},
	Default = "Team Color",
}, function(Value)
	print("ESP Color Mode:", Value)
end)
```

📜 NOTE: This is just an example!

# 🎭 Icons Dictions List

**Open This File to see the full icons list [HERE](Dictions-Icons.md)**

In this file you can see the available icons in Lua Land Ui Library.

# 🤩 Themes Dictions List

**Open This File to see the full themes list [HERE](Dictions-Themes.md)**

In this file you can see the available themes that you can display and design for your script in Lua Land Ui Library.
