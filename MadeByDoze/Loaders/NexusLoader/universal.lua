--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║              Nexus Hub - Universal Script                 ║
    ║        Example script loaded by Nexus Loader              ║
    ╚═══════════════════════════════════════════════════════════╝
]]

print("🚀 Nexus Hub loaded successfully!")

-- This is an EXAMPLE script to show what gets loaded
-- Replace this with your actual script hub/functionality

local NexusHub = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create a simple GUI as an example
local function CreateExampleHub()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusHub"
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    Title.BorderSizePixel = 0
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌟 NEXUS HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Feature List
    local FeatureList = Instance.new("Frame")
    FeatureList.Size = UDim2.new(1, -40, 1, -100)
    FeatureList.Position = UDim2.new(0, 20, 0, 70)
    FeatureList.BackgroundTransparency = 1
    FeatureList.Parent = MainFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = FeatureList
    
    -- Example Features
    local features = {
        {Name = "ESP", Description = "See players through walls", Color = Color3.fromRGB(0, 255, 136)},
        {Name = "Speed", Description = "Increase walkspeed", Color = Color3.fromRGB(255, 200, 0)},
        {Name = "Jump Power", Description = "Jump higher", Color = Color3.fromRGB(100, 200, 255)},
        {Name = "Fly", Description = "Fly around the map", Color = Color3.fromRGB(255, 100, 200)},
        {Name = "Noclip", Description = "Walk through walls", Color = Color3.fromRGB(200, 100, 255)}
    }
    
    for _, feature in ipairs(features) do
        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.Size = UDim2.new(1, 0, 0, 45)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Parent = FeatureList
        
        local FeatureCorner = Instance.new("UICorner")
        FeatureCorner.CornerRadius = UDim.new(0, 8)
        FeatureCorner.Parent = FeatureFrame
        
        local FeatureName = Instance.new("TextLabel")
        FeatureName.Size = UDim2.new(0.7, 0, 0, 20)
        FeatureName.Position = UDim2.new(0, 15, 0, 5)
        FeatureName.BackgroundTransparency = 1
        FeatureName.Font = Enum.Font.GothamBold
        FeatureName.Text = feature.Name
        FeatureName.TextColor3 = feature.Color
        FeatureName.TextSize = 16
        FeatureName.TextXAlignment = Enum.TextXAlignment.Left
        FeatureName.Parent = FeatureFrame
        
        local FeatureDesc = Instance.new("TextLabel")
        FeatureDesc.Size = UDim2.new(0.7, 0, 0, 20)
        FeatureDesc.Position = UDim2.new(0, 15, 0, 22)
        FeatureDesc.BackgroundTransparency = 1
        FeatureDesc.Font = Enum.Font.Gotham
        FeatureDesc.Text = feature.Description
        FeatureDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        FeatureDesc.TextSize = 12
        FeatureDesc.TextXAlignment = Enum.TextXAlignment.Left
        FeatureDesc.Parent = FeatureFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 80, 0, 30)
        ToggleButton.Position = UDim2.new(1, -90, 0.5, -15)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 80, 80)
        ToggleButton.TextSize = 14
        ToggleButton.Parent = FeatureFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = ToggleButton
        
        local isEnabled = false
        ToggleButton.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            if isEnabled then
                ToggleButton.Text = "ON"
                ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 136)
                ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 70)
                print("✅ Enabled:", feature.Name)
            else
                ToggleButton.Text = "OFF"
                ToggleButton.TextColor3 = Color3.fromRGB(255, 80, 80)
                ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                print("❌ Disabled:", feature.Name)
            end
        end)
    end
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -50, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 24
    CloseButton.Parent = Title
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        print("👋 Nexus Hub closed")
    end)
    
    -- Animate in
    MainFrame.Position = UDim2.new(0.5, -250, 1.5, 0)
    local tween = TweenService:Create(
        MainFrame,
        TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -250, 0.5, -175)}
    )
    tween:Play()
    
    return ScreenGui
end

-- Initialize the hub
NexusHub.GUI = CreateExampleHub()

print([[
╔═══════════════════════════════════════════════╗
║          NEXUS HUB LOADED                     ║
║  This is an example script demonstrating      ║
║  what gets loaded by Nexus Loader.            ║
║                                               ║
║  Replace this with your actual hub code!      ║
╚═══════════════════════════════════════════════╝
]])

print("📌 Game:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("👤 Player:", Player.Name)
print("🎮 Executor: Supported")
print("✅ All features loaded successfully!")

return NexusHub
