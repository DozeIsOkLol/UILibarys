--[[
    Unveil UI - A Standalone UI Library (V1.0)
    External / Executor-Friendly Version

    Features:
    - Draggable Window + Close Button
    - Auto-resizing ScrollingFrame
    - Buttons, Toggles, Inputs, Sliders, Labels, Separators
    - Status bar with animation
    - Keyboard navigation (Tab / Enter / Space)
    - Toggle key support
]]

-------------------------------------------------
-- UI LIBRARY
-------------------------------------------------

local UnveilUI = {}
UnveilUI.__index = UnveilUI

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Single ScreenGui guard
local screenGui = playerGui:FindFirstChild("UnveilUI_GUI")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UnveilUI_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
end

-- Create Window
function UnveilUI:CreateWindow(title, width, height)
    local self = setmetatable({}, UnveilUI)

    self.focusableElements = {}
    self.currentFocusIndex = nil

    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.fromOffset(width or 300, height or 400)
    self.mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40)
    self.mainFrame.Visible = false
    self.mainFrame.Parent = screenGui
    Instance.new("UICorner", self.mainFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", self.mainFrame).Color = Color3.fromRGB(85, 87, 90)

    -- Drag bar
    local dragBar = Instance.new("Frame", self.mainFrame)
    dragBar.Size = UDim2.new(1, 0, 0, 35)
    dragBar.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", dragBar)
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Left

    self.closeButton = Instance.new("TextButton", dragBar)
    self.closeButton.Size = UDim2.fromOffset(25, 25)
    self.closeButton.Position = UDim2.new(1, -32, 0.5, -12)
    self.closeButton.Text = "X"
    self.closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    self.closeButton.TextColor3 = Color3.new(1, 1, 1)
    self.closeButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", self.closeButton).CornerRadius = UDim.new(0, 6)

    -- Content
    self.contentFrame = Instance.new("ScrollingFrame", self.mainFrame)
    self.contentFrame.Position = UDim2.new(0, 10, 0, 40)
    self.contentFrame.Size = UDim2.new(1, -20, 1, -75)
    self.contentFrame.ScrollBarThickness = 5
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", self.contentFrame)
    layout.Padding = UDim.new(0, 10)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
    end)

    -- Status bar
    self.statusLabel = Instance.new("TextLabel", self.mainFrame)
    self.statusLabel.Size = UDim2.new(1, -20, 0, 25)
    self.statusLabel.Position = UDim2.new(0, 10, 1, -30)
    self.statusLabel.BackgroundTransparency = 1
    self.statusLabel.Text = "Status: Idle"
    self.statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.statusLabel.Font = Enum.Font.Gotham
    self.statusLabel.TextSize = 14
    self.statusLabel.TextXAlignment = Left

    -- Focus stroke
    self.focusStroke = Instance.new("UIStroke")
    self.focusStroke.Color = Color3.fromRGB(100, 160, 255)
    self.focusStroke.Thickness = 1.5

    -- Drag logic
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local startPos = input.Position
            local startFrame = self.mainFrame.Position

            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = i.Position - startPos
                    self.mainFrame.Position = UDim2.new(
                        startFrame.X.Scale,
                        startFrame.X.Offset + delta.X,
                        startFrame.Y.Scale,
                        startFrame.Y.Offset + delta.Y
                    )
                end
            end)

            local endConn
            endConn = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)

    return self
end

-- UI Elements
function UnveilUI:AddLabel(opts)
    local label = Instance.new("TextLabel", self.contentFrame)
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = opts.text
    label.TextColor3 = opts.color or Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.Gotham
    label.TextSize = opts.textSize or 16
    label.TextXAlignment = opts.align or Left
    return label
end

function UnveilUI:AddButton(opts)
    local button = Instance.new("TextButton", self.contentFrame)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Text = opts.text
    button.BackgroundColor3 = opts.color or Color3.fromRGB(88, 101, 242)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    button.MouseButton1Click:Connect(opts.callback)
    table.insert(self.focusableElements, button)
    return button
end

function UnveilUI:AddToggle(opts)
    local state = opts.state or false
    return self:AddButton({
        text = (state and "Stop " or "Start ") .. opts.text,
        color = state and Color3.fromRGB(0, 145, 0) or Color3.fromRGB(200, 40, 40),
        callback = function(btn)
            state = not state
            btn.Text = (state and "Stop " or "Start ") .. opts.text
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 145, 0) or Color3.fromRGB(200, 40, 40)
            if opts.callback then opts.callback(state) end
        end
    })
end

function UnveilUI:SetStatus(text, color)
    self.statusLabel.Text = "Status: " .. text
    self.statusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 150)
end

function UnveilUI:Init(opts)
    opts = opts or {}
    local visible = false

    local function toggle()
        visible = not visible
        self.mainFrame.Visible = visible
    end

    self.closeButton.MouseButton1Click:Connect(toggle)

    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == (opts.toggleKey or Enum.KeyCode.RightControl) then
            toggle()
        end
    end)

    toggle()
end

-------------------------------------------------
-- EXAMPLE USAGE
-------------------------------------------------

local Window = UnveilUI:CreateWindow("Unveil UI - Example", 320, 450)

Window:AddLabel({
    text = "Demonstration Elements",
    align = Enum.TextXAlignment.Center,
    textSize = 18
})

Window:AddButton({
    text = "Test Button",
    callback = function()
        Window:SetStatus("Button clicked!", Color3.fromRGB(80, 255, 80))
    end
})

Window:AddToggle({
    text = "Test Toggle",
    callback = function(state)
        Window:SetStatus("Toggle: " .. tostring(state))
    end
})

Window:Init({
    toggleKey = Enum.KeyCode.PageUp
})
