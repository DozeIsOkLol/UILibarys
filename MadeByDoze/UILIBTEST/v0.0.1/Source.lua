local UILibrary = {}

local Tuning = {
    PanelWidth = 145,
    PanelHeaderH = 24,
    ItemHeight = 20,
    FontSize = 13,
    SliderHeight = 38,
    RadarDotSize = 6
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

function UILibrary:CreatePanel(parent, title, pos)
    local panel = Instance.new("Frame")
    panel.Name = title
    panel.BackgroundColor3 = Palette.PanelBg
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Position = pos
    panel.Size = UDim2.new(0, Tuning.PanelWidth, 0, Tuning.PanelHeaderH + 6)
    panel.Active = true
    panel.Draggable = true
    panel.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Palette.PanelBorder
    stroke.Thickness = 1
    stroke.Parent = panel

    local header = Instance.new("Frame")
    header.BackgroundColor3 = Palette.PanelHeader
    header.BackgroundTransparency = 0.05
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, Tuning.PanelHeaderH)
    header.Parent = panel

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = Tuning.FontSize
    titleLabel.TextColor3 = Palette.Text
    titleLabel.Text = title
    titleLabel.Parent = header

    local yOffset = Tuning.PanelHeaderH + 3
    
    local obj = {}
    
    function obj:AddToggle(name, callback, initialState)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Palette.ItemHover
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1, 0, 0, Tuning.ItemHeight)
        btn.Position = UDim2.new(0, 0, 0, yOffset)
        btn.Font = Enum.Font.RobotoMono
        btn.TextSize = Tuning.FontSize
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = panel
        
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.Parent = btn
        
        local state = initialState or false
        local function Update()
            btn.TextColor3 = state and Palette.ItemOn or Palette.ItemOff
            btn.Text = name
        end
        Update()
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            Update()
            callback(state)
        end)
        
        yOffset = yOffset + Tuning.ItemHeight
        panel.Size = panel.Size + UDim2.new(0, 0, 0, Tuning.ItemHeight)
    end

    function obj:AddSlider(name, min, max, step, default, callback)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Position = UDim2.new(0, 10, 0, yOffset)
        container.Size = UDim2.new(1, -20, 0, Tuning.SliderHeight - 4)
        container.Parent = panel
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 16)
        label.Font = Enum.Font.RobotoMono
        label.TextSize = 12
        label.TextColor3 = Palette.TextDim
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = name .. ": " .. tostring(default)
        label.Parent = container
        
        local track = Instance.new("Frame")
        track.BackgroundColor3 = Palette.PanelHeader
        track.Position = UDim2.new(0, 0, 0, 18)
        track.Size = UDim2.new(1, 0, 0, 8)
        track.Parent = container
        
        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Palette.Accent
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.Parent = track
        
        -- Logic for sliding
        local dragging = false
        track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        track.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if dragging then
                local mouseX = game:GetService("UserInputService"):GetMouseLocation().X
                local relX = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = min + relX * (max - min)
                val = math.floor(val / step + 0.5) * step
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                label.Text = name .. ": " .. tostring(val)
                callback(val)
            end
        end)
        
        yOffset = yOffset + Tuning.SliderHeight
        panel.Size = panel.Size + UDim2.new(0, 0, 0, Tuning.SliderHeight)
    end
    
    return obj
end

return UILibrary
