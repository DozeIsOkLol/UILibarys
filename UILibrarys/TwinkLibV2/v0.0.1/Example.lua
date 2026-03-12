local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/TwinkLibV2/v0.0.1/Source.lua"))()

local UI = UILibrary.Load("Twink UI", "Game Name", "v2.0")
local FirstPage = UI.AddPage("Home")

local FirstLabel = FirstPage.AddLabel("Section 1")
local FirstButton = FirstPage.AddButton("Hello", function()
print("Hello")
end)
local FirstToggle = FirstPage.AddToggle("Hello", false, function(Value)
print(Value)
end)
local FirstSlider = FirstPage.AddSlider("Hello", {Min = 0, Max = 255, Def = 50}, function(Value)
print(Value)
end)
local FirstPicker = FirstPage.AddColourPicker("Hello", "white", function(Value)
print(Value)
end)
local FirstDropdown = FirstPage.AddDropdown("Hello", {
"Hello",
"Goodbye"
}, function(Value)
print(Value)

end)
