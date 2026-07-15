-- RiotUI Library

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RiotUI = {}
RiotUI.__index = RiotUI

-- ==================== CONFIG & TUNING ====================

local Tuning = {
    PanelWidth = 145,
    PanelHeaderH = 24,
    ItemHeight = 20,
    FontSize = 13,
    SliderHeight = 38,
}

local Palette = {
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

-- ==================== MAIN LIBRARY ====================

function RiotUI.new()
    local self = setmetatable({}, RiotUI)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "RiotUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999
    self.ScreenGui.IgnoreGuiInset = true

    pcall(function() self.ScreenGui.Parent = game:GetService("CoreGui") end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.Connections = {}
    self.Panels = {}
    self.ActiveList = nil

    return self
end

-- Create a draggable panel
function RiotUI:CreatePanel(title, items, position)
    local totalHeight = Tuning.PanelHeaderH
    for _, item in ipairs(items) do
        totalHeight += (item.type == "slider" and Tuning.SliderHeight or Tuning.ItemHeight)
    end
    totalHeight += 6

    local panel = Instance.new("Frame")
    panel.Name = title
    panel.BackgroundColor3 = Palette.PanelBg
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Position = position or UDim2.new(0, 10, 0, 55)
    panel.Size = UDim2.new(0, Tuning.PanelWidth, 0, totalHeight)
    panel.Active = true
    panel.Draggable = true
    panel.Parent = self.ScreenGui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Palette.PanelBorder
    stroke.Thickness = 1
    stroke.Parent = panel

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = Palette.PanelHeader
    header.BackgroundTransparency = 0.05
    header.Size = UDim2.new(1, 0, 0, Tuning.PanelHeaderH)
    header.Parent = panel

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = Tuning.FontSize
    titleLabel.TextColor3 = Palette.Text
    titleLabel.Text = title
    titleLabel.Parent = header

    local yOffset = Tuning.PanelHeaderH + 3

    for _, item in ipairs(items) do
        if item.type == "toggle" then
            local btn = Instance.new("TextButton")
            btn.Name = item.key
            btn.BackgroundColor3 = Palette.ItemHover
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Position = UDim2.new(0, 0, 0, yOffset)
            btn.Size = UDim2.new(1, 0, 0, Tuning.ItemHeight)
            btn.Font = Enum.Font.RobotoMono
            btn.TextSize = Tuning.FontSize
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = false
            btn.Parent = panel

            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 10)
            pad.Parent = btn

            local function Update()
                btn.TextColor3 = (item.value or false) and Palette.ItemOn or Palette.ItemOff
                btn.Text = item.name
            end
            Update()

            btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.5 end)
            btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 1 end)

            btn.MouseButton1Click:Connect(function()
                item.value = not item.value
                Update()
                if item.callback then item.callback(item.value) end
            end)

            yOffset += Tuning.ItemHeight

        elseif item.type == "slider" then
            local container = Instance.new("Frame")
            container.BackgroundTransparency = 1
            container.Position = UDim2.new(0, 10, 0, yOffset)
            container.Size = UDim2.new(1, -20, 0, Tuning.SliderHeight - 4)
            container.Parent = panel

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 16)
            label.Font = Enum.Font.RobotoMono
            label.TextSize = 12
            label.TextColor3 = Palette.TextDim
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local track = Instance.new("Frame")
            track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            track.BorderSizePixel = 0
            track.Position = UDim2.new(0, 0, 0, 18)
            track.Size = UDim2.new(1, 0, 0, 8)
            track.Parent = container

            Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = Palette.Accent
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

            local function UpdateSlider()
                local pct = (item.value - item.min) / (item.max - item.min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                label.Text = item.name .. ": " .. tostring(math.floor(item.value * 10) / 10)
            end
            UpdateSlider()

            local dragging = false

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            self.Connections["slider_"..item.key] = RunService.RenderStepped:Connect(function()
                if dragging then
                    local mx = UserInputService:GetMouseLocation().X
                    local tx = track.AbsolutePosition.X
                    local tw = track.AbsoluteSize.X
                    local pct = math.clamp((mx - tx) / tw, 0, 1)
                    local val = item.min + pct * (item.max - item.min)
                    val = math.floor(val / item.step + 0.5) * item.step
                    item.value = math.clamp(val, item.min, item.max)
                    UpdateSlider()
                    if item.callback then item.callback(item.value) end
                end
            end)

            yOffset += Tuning.SliderHeight
        end
    end

    self.Panels[title] = panel
    return panel
end

-- Watermark
function RiotUI:CreateWatermark(text)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 10, 0, 10)
    container.Size = UDim2.new(0, 250, 0, 40)
    container.Parent = self.ScreenGui

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 14
    label.TextColor3 = Palette.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.6
    label.Text = text or "RiotUI"
    label.Parent = container

    return container
end

-- Active Features List
function RiotUI:CreateActiveList()
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -160, 0, 10)
    frame.Size = UDim2.new(0, 150, 0, 300)
    frame.Parent = self.ScreenGui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.SortOrder = Enum.SortOrder.Name
    layout.Padding = UDim.new(0, 1)
    layout.Parent = frame

    self.ActiveList = frame
    return frame
end

function RiotUI:RefreshActiveList(activeFeatures)
    if not self.ActiveList then return end
    for _, child in ipairs(self.ActiveList:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    for i, name in ipairs(activeFeatures) do
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.Font = Enum.Font.RobotoMono
        lbl.TextSize = 13
        lbl.TextColor3 = Palette.ItemOn
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.TextStrokeTransparency = 0.6
        lbl.Text = name
        lbl.Parent = self.ActiveList
    end
end

-- Destroy UI
function RiotUI:Destroy()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.ScreenGui:Destroy()
end

return RiotUI
