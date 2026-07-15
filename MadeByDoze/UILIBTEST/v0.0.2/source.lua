local UILib = {}
UILib.__index = UILib

local Tuning = {
    PanelWidth = 145,
    PanelHeaderH = 24,
    ItemHeight = 20,
    FontSize = 13,
    SliderHeight = 38
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
    Accent = Color3.fromRGB(255, 65, 65)
}

function UILib.CreatePanel(title, pos, parent)
    local self = setmetatable({}, UILib)
    self.yOffset = Tuning.PanelHeaderH + 3
    
    self.Panel = Instance.new("Frame")
    self.Panel.Name = title
    self.Panel.BackgroundColor3 = Palette.PanelBg
    self.Panel.BackgroundTransparency = 0.08
    self.Panel.BorderSizePixel = 0
    self.Panel.Position = pos
    self.Panel.Size = UDim2.new(0, Tuning.PanelWidth, 0, Tuning.PanelHeaderH + 6)
    self.Panel.Active = true
    self.Panel.Draggable = true
    self.Panel.Parent = parent
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Palette.PanelBorder
    stroke.Thickness = 1
    stroke.Parent = self.Panel
    
    local header = Instance.new("Frame")
    header.BackgroundColor3 = Palette.PanelHeader
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, Tuning.PanelHeaderH)
    header.Parent = self.Panel
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = Tuning.FontSize
    titleLabel.TextColor3 = Palette.Text
    titleLabel.Text = title
    titleLabel.Parent = header
    
    return self
end

function UILib:AddToggle(name, key, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Palette.ItemHover
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 0, Tuning.ItemHeight)
    btn.Position = UDim2.new(0, 0, 0, self.yOffset)
    btn.Font = Enum.Font.RobotoMono
    btn.TextSize = Tuning.FontSize
    btn.TextColor3 = Palette.ItemOff
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = self.Panel
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = btn
    
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.5 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 1 end)
    btn.MouseButton1Click:Connect(function()
        callback()
    end)
    
    self.yOffset = self.yOffset + Tuning.ItemHeight
    self.Panel.Size = self.Panel.Size + UDim2.new(0, 0, 0, Tuning.ItemHeight)
end

function UILib:AddSlider(name, min, max, step, current, callback)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 10, 0, self.yOffset)
    container.Size = UDim2.new(1, -20, 0, Tuning.SliderHeight - 4)
    container.Parent = self.Panel
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 12
    label.TextColor3 = Palette.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name .. ": " .. tostring(current)
    label.Parent = container
    
    local track = Instance.new("Frame")
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 18)
    track.Parent = container
    
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Palette.Accent
    fill.Size = UDim2.new((current - min)/(max - min), 0, 1, 0)
    fill.Parent = track
    
    -- Add Corners
    local tc = Instance.new("UICorner", track); tc.CornerRadius = UDim.new(0,4)
    local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(0,4)

    local dragging = false
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    track.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mx = game:GetService("UserInputService"):GetMouseLocation().X
            local tx = track.AbsolutePosition.X
            local tw = track.AbsoluteSize.X
            local pct = math.clamp((mx - tx) / tw, 0, 1)
            local val = min + pct * (max - min)
            val = math.floor(val / step + 0.5) * step
            fill.Size = UDim2.new(math.clamp((val-min)/(max-min), 0, 1), 0, 1, 0)
            label.Text = name .. ": " .. tostring(val)
            callback(val)
        end
    end)
    
    self.yOffset = self.yOffset + Tuning.SliderHeight
    self.Panel.Size = self.Panel.Size + UDim2.new(0, 0, 0, Tuning.SliderHeight)
end

return UILib
