-- RiotUI Library [Pro Version]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local RiotUI = {}
RiotUI.__index = RiotUI

local Tuning = {
    PanelWidth = 145, PanelHeaderH = 24, ItemHeight = 20, SliderHeight = 38
}

local DefaultPalette = {
    PanelBg = Color3.fromRGB(18, 18, 20),
    PanelHeader = Color3.fromRGB(25, 25, 28),
    PanelBorder = Color3.fromRGB(45, 45, 50),
    ItemOn = Color3.fromRGB(255, 65, 65),
    ItemOff = Color3.fromRGB(180, 180, 185),
    ItemHover = Color3.fromRGB(35, 35, 40),
    Text = Color3.fromRGB(230, 230, 235),
    TextDim = Color3.fromRGB(130, 130, 140),
    Accent = Color3.fromRGB(255, 65, 65),
}

function RiotUI.new(customPalette)
    local self = setmetatable({}, RiotUI)
    self.Palette = customPalette or DefaultPalette
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "RiotUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

    self.Connections = {}
    return self
end

-- Smooth Dragging Logic
local function MakeDraggable(frame)
    local dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragInput = nil end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function RiotUI:SetToggleKey(keyCode)
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == keyCode and not gp then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)
end

function RiotUI:CreatePanel(title, items, position)
    local totalHeight = Tuning.PanelHeaderH + 6
    for _, i in ipairs(items) do totalHeight += (i.type == "slider" and Tuning.SliderHeight or Tuning.ItemHeight) end

    local panel = Instance.new("Frame", self.ScreenGui)
    panel.BackgroundColor3 = self.Palette.PanelBg
    panel.BorderSizePixel = 0
    panel.Position = position or UDim2.new(0, 10, 0, 55)
    panel.Size = UDim2.new(0, Tuning.PanelWidth, 0, totalHeight)
    MakeDraggable(panel)

    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = self.Palette.PanelBorder

    local header = Instance.new("Frame", panel)
    header.BackgroundColor3 = self.Palette.PanelHeader
    header.Size = UDim2.new(1, 0, 0, Tuning.PanelHeaderH)

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Palette.Text

    local yOffset = Tuning.PanelHeaderH + 3
    for _, item in ipairs(items) do
        if item.type == "toggle" then
            local btn = Instance.new("TextButton", panel)
            btn.BackgroundTransparency = 1
            btn.Position = UDim2.new(0, 0, 0, yOffset)
            btn.Size = UDim2.new(1, 0, 0, Tuning.ItemHeight)
            btn.Font = Enum.Font.RobotoMono
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = "  " .. item.name
            
            local function Update()
                btn.TextColor3 = (item.value) and self.Palette.ItemOn or self.Palette.ItemOff
            end
            Update()
            btn.MouseButton1Click:Connect(function()
                item.value = not item.value
                Update()
                if item.callback then item.callback(item.value) end
            end)
            yOffset += Tuning.ItemHeight
        elseif item.type == "slider" then
            local container = Instance.new("Frame", panel)
            container.BackgroundTransparency = 1
            container.Position = UDim2.new(0, 10, 0, yOffset)
            container.Size = UDim2.new(1, -20, 0, Tuning.SliderHeight - 4)
            
            local label = Instance.new("TextLabel", container)
            label.Size = UDim2.new(1, 0, 0, 16)
            label.Font = Enum.Font.RobotoMono
            label.Text = item.name .. ": " .. item.value
            label.TextColor3 = self.Palette.TextDim
            
            local track = Instance.new("Frame", container)
            track.BackgroundColor3 = self.Palette.PanelBorder
            track.Size = UDim2.new(1, 0, 0, 8)
            track.Position = UDim2.new(0, 0, 0, 18)
            Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)
            
            local fill = Instance.new("Frame", track)
            fill.BackgroundColor3 = self.Palette.Accent
            fill.Size = UDim2.new((item.value - item.min)/(item.max - item.min), 0, 1, 0)
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
            
            local dragging = false
            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            track.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mx = UserInputService:GetMouseLocation().X
                    local pct = math.clamp((mx - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    item.value = math.floor((item.min + pct * (item.max - item.min)) / item.step + 0.5) * item.step
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    label.Text = item.name .. ": " .. item.value
                    if item.callback then item.callback(item.value) end
                end
            end)
            yOffset += Tuning.SliderHeight
        end
    end
end

return RiotUI
