
local RiotUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/UILIBTEST/v0.0.3/Source.lua"))() -- Replace with your library link

local UI = RiotUI.new()

-- Watermark
UI:CreateWatermark("My Cool Script v1.0")

-- Active List
UI:CreateActiveList()

-- Example Panel
local config = {
    ESP_Enabled = true,
    AIM_FOV = 120,
    AIM_Smooth = 3.5,
}

UI:CreatePanel("ESP", {
    {type = "toggle", name = "Enabled",   key = "ESP_Enabled", value = config.ESP_Enabled, callback = function(v) config.ESP_Enabled = v end},
    {type = "toggle", name = "Box",       key = "ESP_Box",     value = true},
    {type = "toggle", name = "Names",     key = "ESP_Name",    value = true},
}, UDim2.new(0, 10, 0, 55))

UI:CreatePanel("Aimbot", {
    {type = "toggle", name = "Enabled", key = "AIM_Enabled", value = false},
    {type = "slider", name = "FOV",     key = "AIM_FOV", min = 30, max = 400, step = 5, value = config.AIM_FOV},
    {type = "slider", name = "Smooth",  key = "AIM_Smooth", min = 1, max = 15, step = 0.5, value = config.AIM_Smooth},
}, UDim2.new(0, 165, 0, 55))
