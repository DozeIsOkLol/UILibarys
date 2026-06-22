local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- System Configuration
local EXPECTED_KEY = "speed"
local SCRIPT_URL = "https://pastebin.com/raw/Xx6b6P8d"
local KEY_LINK = "https://link-target.net/1455175/lPfEzJDUTpGe"

-- Create GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyboardSpeedKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 235)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 42)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KEYBOARD SPEED KEY SYSTEM"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
TitleLabel.Parent = MainFrame

local KeyInputBox = Instance.new("TextBox")
KeyInputBox.Name = "KeyInputBox"
KeyInputBox.Size = UDim2.new(0.85, 0, 0, 38)
KeyInputBox.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyInputBox.PlaceholderText = "Enter Key"
KeyInputBox.ClearTextOnFocus = false
KeyInputBox.Font = Enum.Font.Gotham
KeyInputBox.TextSize = 16
KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyInputBox.BorderSizePixel = 0
KeyInputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 7)
InputCorner.Parent = KeyInputBox

local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Size = UDim2.new(0.4, 0, 0, 34)
GetKeyButton.Position = UDim2.new(0.075, 0, 0.56, 0)
GetKeyButton.Text = "Get Key"
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 14
GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
GetKeyButton.BorderSizePixel = 0
GetKeyButton.Parent = MainFrame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 7)
GetKeyCorner.Parent = GetKeyButton

local SubmitButton = Instance.new("TextButton")
SubmitButton.Name = "SubmitButton"
SubmitButton.Size = UDim2.new(0.4, 0, 0, 34)
SubmitButton.Position = UDim2.new(0.525, 0, 0.56, 0)
SubmitButton.Text = "Submit"
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.TextSize = 14
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SubmitButton.BorderSizePixel = 0
SubmitButton.Parent = MainFrame

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 7)
SubmitCorner.Parent = SubmitButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.Position = UDim2.new(0, 0, 0.84, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "by SARpastes"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Parent = MainFrame

-- Button Logic
SubmitButton.MouseButton1Click:Connect(function()
    -- Strip whitespace and formatting from the input
    local inputKey = string.gsub(KeyInputBox.Text, "%s+", "")
    
    if string.lower(inputKey) == EXPECTED_KEY then
        StatusLabel.Text = "✅ Key Accepted"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        task.wait(0.6)
        ScreenGui:Destroy()
        
        -- Load the actual script
        loadstring(game:HttpGet(SCRIPT_URL, true))()
    else
        StatusLabel.Text = "❌ Incorrect Key"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

GetKeyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KEY_LINK)
    end
    StatusLabel.Text = "🔗 Key link copied"
    StatusLabel.TextColor3 = Color3.fromRGB(160, 180, 255)
end)

-- Window Dragging Logic
local isDragging = false
local dragStartPos = nil
local frameStartPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
        frameStartPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        MainFrame.Position = UDim2.new(
            frameStartPos.X.Scale, 
            frameStartPos.X.Offset + delta.X, 
            frameStartPos.Y.Scale, 
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)
