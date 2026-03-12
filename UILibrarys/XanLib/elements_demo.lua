local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

local Window = UI.New({
    Title = "All Elements",
    Subtitle = "Demo",
    Theme = "Default",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true
})

local Inputs = Window:AddTab("Inputs", UI.Icons.UI)

Inputs:AddSection("Basic")

Inputs:AddToggle("Toggle", { Default = false }, function(v) print("Toggle:", v) end)

Inputs:AddSlider("Slider", { Min = 0, Max = 100, Default = 50, Suffix = "%" }, function(v) print("Slider:", v) end)

Inputs:AddDropdown("Dropdown", {"Option 1", "Option 2", "Option 3"}, function(v) print("Dropdown:", v) end)

Inputs:AddInput("Text", { Placeholder = "Type here..." }, function(v) print("Input:", v) end)

Inputs:AddSection("Advanced")

Inputs:AddKeybind("Keybind", { Default = Enum.KeyCode.E }, function() print("Pressed!") end)

Inputs:AddColorPicker("Color", { Default = UI.RGB(255, 75, 85) }, function(c) print("Color:", c) end)

local Buttons = Window:AddTab("Buttons", UI.Icons.Buttons)

Buttons:AddSection("Styles")

Buttons:AddButton("Default", function() UI.Info("Clicked", "Default") end)
Buttons:AddPrimaryButton("Primary", function() UI.Success("Clicked", "Primary") end)
Buttons:AddDangerButton("Danger", function() UI.Warning("Clicked", "Danger") end)
Buttons:AddOutlineButton({ Name = "Outline", Callback = function() UI.Info("Clicked", "Outline") end })
Buttons:AddPillButton({ Name = "Pill", Callback = function() UI.Info("Clicked", "Pill") end })

local Themes = Window:AddTab("Themes", UI.Icons.Layouts)

Themes:AddSection("Select Theme")

for _, theme in ipairs(UI.GetThemes()) do
    Themes:AddButton(theme, function() UI.SetTheme(theme) end)
end

if UI.IsMobile then UI.MobileToggle({ Window = Window }) end

UI.Success("Demo Loaded!", "Explore all elements")

