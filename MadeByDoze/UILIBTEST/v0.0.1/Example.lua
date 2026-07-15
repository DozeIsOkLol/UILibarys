local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/UILIBTEST/v0.0.1/Source.lua"))() -- Or require if in same file

-- Create the UI parent
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- Create a panel
local ESPPanel = UILibrary:CreatePanel(ScreenGui, "ESP", UDim2.new(0, 10, 0, 55))

-- Add items to the panel
ESPPanel:AddToggle("Enabled", function(val) 
    Config.ESP_Enabled = val 
end, Config.ESP_Enabled)

ESPPanel:AddToggle("Box", function(val) 
    Config.ESP_Box = val 
end, Config.ESP_Box)

-- Example Slider
local AimbotPanel = UILibrary:CreatePanel(ScreenGui, "Aimbot", UDim2.new(0, 165, 0, 55))

AimbotPanel:AddSlider("Smooth", 1, 15, 0.5, Config.AIM_Smooth, function(val)
    Config.AIM_Smooth = val
end)
