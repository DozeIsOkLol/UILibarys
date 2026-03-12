local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/WetLib/Source.lua"))()

local MainUI = UILibrary.Load("WetLib")
local FirstPage = MainUI.AddPage("Home")

local FirstLabel = FirstPage.AddLabel("Section 1")

local FirstButton = FirstPage.AddButton("Hello", function()
print("Hello")
end)

local FirstToggle = FirstPage.AddToggle("Hello", false, function(Value)
print(Value)
end)

-- Use Decimal allows the slider to use decimal numbers in an integer of 0.1, 0.2, 0.3, if disabled it will be forced to use whole numbers, 1, 2, 3
local FirstSlider = FirstPage.AddSlider("Fill Transparency", {Min = 0, Max = 1, Def = 0.5, UseDecimal = true}, function(Value)
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

local FirstValueButton = FirstPage.AddValueButton("Example", false, { button = true, refresh = 1}, function(current)
    print("Example button clicked")
end,

function()
    return true
end)
