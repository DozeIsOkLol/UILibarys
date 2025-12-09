-- =================================================================================================
--  UILIB
--  A streamlined, stable, and polished UI library.
--  Version 6.2 - Corrected Notification Position
-- =================================================================================================

local UILIB = {}
local UILIB_Window = {
    NotifyContainer = nil
}

-- Creates a dedicated, persistent container for notifications to ensure stability and stacking.
local function getNotifyContainer()
    if not UILIB_Window.NotifyContainer or not UILIB_Window.NotifyContainer.Parent then
        local NotifyGui = Instance.new("ScreenGui")
        NotifyGui.Name = "UILIB_Notifications"
        NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        NotifyGui.ResetOnSpawn = false
        
        local Container = Instance.new("Frame", NotifyGui)
        Container.Name = "Container"
        Container.BackgroundTransparency = 1
        Container.Position = UDim2.new(1, -10, 1, -10)
        Container.AnchorPoint = Vector2.new(1, 1)
        Container.Size = UDim2.new(0, 250, 1, 0)
        
        local ListLayout = Instance.new("UIListLayout", Container)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        -- THE CRITICAL FIX: Align items to the bottom of the container so they stack upwards.
        ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        
        UILIB_Window.NotifyContainer = Container
        NotifyGui.Parent = game:GetService("CoreGui")
    end
    return UILIB_Window.NotifyContainer
end

function UILIB:CreateWindow(config)
    local UserInputService = game:GetService("UserInputService"); local TweenService = game:GetService("TweenService"); local TextService = game:GetService("TextService")
    UILIB_Window.Title = config.Title or "My Hub"; UILIB_Window.Version = config.Version or "v1.0"; UILIB_Window.Tabs = {}
    
    local ScreenGui = Instance.new("ScreenGui"); UILIB_Window.ScreenGui = ScreenGui; ScreenGui.Name = "UILIB_Window_" .. math.random(1, 1000); ScreenGui.Parent = game:GetService("CoreGui"); ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global; ScreenGui.ResetOnSpawn = false
    local Main = Instance.new("Frame"); Main.Name = "MainFrame"; Main.Parent = ScreenGui; Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Main.BorderColor3 = Color3.fromRGB(45, 45, 45); Main.BorderSizePixel = 1; Main.Position = UDim2.new(0.5, -275, 0.5, -200); Main.Size = UDim2.new(0, 550, 0, 400); local MainCorner = Instance.new("UICorner", Main); MainCorner.CornerRadius = UDim.new(0, 8)
    
    do -- Header and Draggable Logic
        local Header = Instance.new("Frame", Main); Header.Name = "Header"; Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Header.Size = UDim2.new(1, 0, 0, 40); local HeaderCorner = Instance.new("UICorner", Header); HeaderCorner.CornerRadius = UDim.new(0, 8); local HeaderBottomBorder = Instance.new("Frame", Header); HeaderBottomBorder.BackgroundColor3 = Color3.fromRGB(45, 45, 45); HeaderBottomBorder.BorderSizePixel = 0; HeaderBottomBorder.Size = UDim2.new(1, 0, 0, 1); HeaderBottomBorder.Position = UDim2.new(0, 0, 1, -1); local TitleLabel = Instance.new("TextLabel", Header); TitleLabel.BackgroundTransparency = 1; TitleLabel.Size = UDim2.new(0, 200, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0); TitleLabel.Font = Enum.Font.GothamSemibold; TitleLabel.Text = UILIB_Window.Title; TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLabel.TextSize = 18; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; local VersionLabel = Instance.new("TextLabel", Header); VersionLabel.BackgroundTransparency = 1; VersionLabel.Size = UDim2.new(0, 100, 1, 0); VersionLabel.Position = UDim2.new(1, -115, 0, 0); VersionLabel.Font = Enum.Font.Gotham; VersionLabel.Text = UILIB_Window.Version; VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150); VersionLabel.TextSize = 14; VersionLabel.TextXAlignment = Enum.TextXAlignment.Right; local dragging, dragInput, dragStart, startPos; local function update(input) local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end; Header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end); Header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end); UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
    end

    local TabContainer = Instance.new("ScrollingFrame", Main); TabContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28); TabContainer.BorderSizePixel = 0; TabContainer.Position = UDim2.new(0, 0, 0, 40); TabContainer.Size = UDim2.new(0, 130, 1, -40); TabContainer.ScrollBarThickness = 4; local TabListLayout = Instance.new("UIListLayout", TabContainer); TabListLayout.Padding = UDim.new(0, 5); TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local ContentContainer = Instance.new("Frame", Main); ContentContainer.BackgroundTransparency = 1; ContentContainer.Position = UDim2.new(0, 130, 0, 40); ContentContainer.Size = UDim2.new(1, -130, 1, -40)

    local WindowMethods = {}
    function WindowMethods:CreateTab(name)
        local Tab = { Name = name }
        local TabButton = Instance.new("TextButton", TabContainer); TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40); TabButton.Size = UDim2.new(1, -10, 0, 35); TabButton.Position = UDim2.new(0.5, 0, 0, 0); TabButton.AnchorPoint = Vector2.new(0.5, 0); TabButton.Font = Enum.Font.GothamSemibold; TabButton.Text = name; TabButton.TextColor3 = Color3.fromRGB(200, 200, 200); TabButton.TextSize = 15; Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
        local TabContent = Instance.new("ScrollingFrame", ContentContainer); Tab.ContentFrame = TabContent; TabContent.BackgroundTransparency = 1; TabContent.Size = UDim2.new(1, 0, 1, 0); TabContent.Visible = false; TabContent.ScrollBarThickness = 4; local ContentLayout = Instance.new("UIListLayout", TabContent); ContentLayout.Padding = UDim.new(0, 10); ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder; local ContentPadding = Instance.new("UIPadding", TabContent); ContentPadding.PaddingTop = UDim.new(0, 15); ContentPadding.PaddingLeft = UDim.new(0, 15); ContentPadding.PaddingRight = UDim.new(0, 15)
        
        local function SwitchToTab() for _, v in pairs(UILIB_Window.Tabs) do v.ContentFrame.Visible = false; TweenService:Create(v.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end; TabContent.Visible = true; TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 122, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end
        TabButton.MouseButton1Click:Connect(SwitchToTab); Tab.Button = TabButton; table.insert(UILIB_Window.Tabs, Tab); if #UILIB_Window.Tabs == 1 then SwitchToTab() end
        
        local ElementMethods = {}
        function ElementMethods:AddLabel(text) local Label = Instance.new("TextLabel", TabContent); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 0, 20); Label.Font = Enum.Font.GothamSemibold; Label.Text = text; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 16; Label.TextXAlignment = Enum.TextXAlignment.Left; return {} end
        function ElementMethods:AddParagraph(text) local Frame = Instance.new("Frame", TabContent); Frame.BackgroundTransparency = 1; local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 1, 0); Label.Font = Enum.Font.Gotham; Label.Text = text; Label.TextColor3 = Color3.fromRGB(200, 200, 200); Label.TextSize = 14; Label.TextWrapped = true; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextYAlignment = Enum.TextYAlignment.Top; local size = TextService:GetTextSize(text, 14, Enum.Font.Gotham, Vector2.new(ContentContainer.AbsoluteSize.X - 30, 1000)); Frame.Size = UDim2.new(1, 0, 0, size.Y + 5); return {} end
        function ElementMethods:AddButton(config) local Button = Instance.new("TextButton", TabContent); Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Button.Size = UDim2.new(1, 0, 0, 35); Button.Font = Enum.Font.Gotham; Button.Text = config.Name; Button.TextColor3 = Color3.fromRGB(255, 255, 255); Button.TextSize = 14; Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6); Button.MouseButton1Click:Connect(function() pcall(config.Callback) end); return {} end
        function ElementMethods:AddToggle(config) local toggled = false; local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 40); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Switch = Instance.new("Frame", Frame); Switch.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Switch.Position = UDim2.new(1, -60, 0.5, 0); Switch.Size = UDim2.new(0, 50, 0, 24); Switch.AnchorPoint = Vector2.new(0, 0.5); Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0); local Circle = Instance.new("Frame", Switch); Circle.BackgroundColor3 = Color3.fromRGB(180, 180, 180); Circle.Position = UDim2.new(0, 4, 0.5, 0); Circle.Size = UDim2.new(0, 16, 0, 16); Circle.AnchorPoint = Vector2.new(0, 0.5); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0); local Button = Instance.new("TextButton", Frame); Button.BackgroundTransparency = 1; Button.Size = UDim2.new(1, 0, 1, 0); Button.Text = ""; Button.MouseButton1Click:Connect(function() toggled = not toggled; pcall(config.Callback, toggled); local pos = toggled and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 4, 0.5, 0); local cColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180); local sColor = toggled and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 30, 30); TweenService:Create(Circle, TweenInfo.new(0.2), {Position = pos, BackgroundColor3 = cColor}):Play(); TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = sColor}):Play() end); return {} end
        function ElementMethods:AddSlider(config) local min, max = config.Min or 0, config.Max or 100; local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 60); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, -70, 0, 25); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Value = Instance.new("TextLabel", Frame); Value.BackgroundTransparency = 1; Value.Size = UDim2.new(0, 50, 0, 25); Value.Position = UDim2.new(1, -60, 0, 0); Value.Font = Enum.Font.GothamBold; Value.Text = tostring(min); Value.TextColor3 = Color3.fromRGB(255, 255, 255); Value.TextSize = 14; Value.TextXAlignment = Enum.TextXAlignment.Right; local Track = Instance.new("Frame", Frame); Track.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Track.Position = UDim2.new(0.5, 0, 1, -18); Track.Size = UDim2.new(1, -20, 0, 8); Track.AnchorPoint = Vector2.new(0.5, 0); Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0); local Progress = Instance.new("Frame", Track); Progress.BackgroundColor3 = Color3.fromRGB(0, 122, 255); Progress.Size = UDim2.new(0, 0, 1, 0); Instance.new("UICorner", Progress).CornerRadius = UDim.new(1, 0); local Button = Instance.new("TextButton", Track); Button.BackgroundTransparency = 1; Button.Size = UDim2.new(1, 0, 1, 0); Button.Text = ""; local function update(pos) local percent = math.clamp((pos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1); local val = math.floor(min + (max - min) * percent + 0.5); Progress.Size = UDim2.new(percent, 0, 1, 0); Value.Text = tostring(val); pcall(config.Callback, val) end; local dragging = false; Button.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i.Position) end end); Button.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end); Button.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and dragging then update(i.Position) end end); return {} end
        function ElementMethods:AddTextbox(config) local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 40); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.5, -10, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Box = Instance.new("TextBox", Frame); Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Box.Position = UDim2.new(1, -160, 0.5, 0); Box.Size = UDim2.new(0, 150, 0, 28); Box.AnchorPoint = Vector2.new(0, 0.5); Box.Font = Enum.Font.Gotham; Box.PlaceholderText = config.Placeholder or "..."; Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150); Box.TextColor3 = Color3.fromRGB(255, 255, 255); Box.TextSize = 14; Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6); Box.FocusLost:Connect(function(enter) if enter then pcall(config.Callback, Box.Text) end end); return {} end
        function ElementMethods:AddKeybind(config) local key, listening = config.Key or Enum.KeyCode.RightControl, false; local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 40); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Button = Instance.new("TextButton", Frame); Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Button.Position = UDim2.new(1, -100, 0.5, 0); Button.Size = UDim2.new(0, 90, 0, 25); Button.AnchorPoint = Vector2.new(0, 0.5); Button.Font = Enum.Font.GothamBold; Button.Text = key.Name; Button.TextColor3 = Color3.fromRGB(255, 255, 255); Button.TextSize = 12; Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6); Button.MouseButton1Click:Connect(function() listening = true; Button.Text = ". . ." end); UserInputService.InputBegan:Connect(function(i, p) if p then return end; if listening then key = i.KeyCode; Button.Text = key.Name; listening = false elseif i.KeyCode == key then pcall(config.Callback) end end); return {} end
        
        return ElementMethods
    end
    
    return WindowMethods
end

function UILIB:Toggle() if UILIB_Window.ScreenGui then UILIB_Window.ScreenGui.Enabled = not UILIB_Window.ScreenGui.Enabled end end

function UILIB:Notify(config)
    task.spawn(function()
        local TweenService = game:GetService("TweenService")
        local container = getNotifyContainer()

        local title = config.Title or "Notification"
        local message = config.Text or ""
        local duration = config.Duration or 5
        
        local notifyFrame = Instance.new("Frame")
        notifyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        notifyFrame.Size = UDim2.fromOffset(0, 60)
        notifyFrame.Parent = container
        
        local corner = Instance.new("UICorner", notifyFrame); corner.CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", notifyFrame); stroke.Color = Color3.fromRGB(50,50,50)

        local brandLabel = Instance.new("TextLabel", notifyFrame)
        brandLabel.Name = "BrandLabel"; brandLabel.BackgroundTransparency = 1; brandLabel.Font = Enum.Font.Gotham
        brandLabel.Text = "UILib"; brandLabel.TextColor3 = Color3.fromRGB(150, 150, 150); brandLabel.TextSize = 12
        brandLabel.TextXAlignment = Enum.TextXAlignment.Right; brandLabel.Position = UDim2.new(1, -10, 0, 5)
        brandLabel.Size = UDim2.new(0, 50, 0, 15); brandLabel.AnchorPoint = Vector2.new(1, 0)
        
        local titleLabel = Instance.new("TextLabel", notifyFrame)
        titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.GothamSemibold; titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.Size = UDim2.new(1, -70, 0, 24)

        local messageLabel = Instance.new("TextLabel", notifyFrame)
        messageLabel.BackgroundTransparency = 1; messageLabel.Font = Enum.Font.Gotham; messageLabel.Text = message
        messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200); messageLabel.TextSize = 14; messageLabel.TextWrapped = true
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left; messageLabel.Position = UDim2.new(0, 10, 0, 28)
        messageLabel.Size = UDim2.new(1, -15, 0, 24)

        local bar = Instance.new("Frame", notifyFrame)
        bar.BackgroundColor3 = Color3.fromRGB(0, 122, 255); bar.BorderSizePixel = 0
        bar.Position = UDim2.new(0, 0, 1, -3); bar.Size = UDim2.new(1, 0, 0, 3)

        local tweenInfoIn = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local tweenInfoOut = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local slideIn = TweenService:Create(notifyFrame, tweenInfoIn, { Size = UDim2.fromOffset(250, 60) })
        local slideOut = TweenService:Create(notifyFrame, tweenInfoOut, { Size = UDim2.fromOffset(0, 60) })
        local barDecay = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })
        
        slideIn:Play(); barDecay:Play(); task.wait(duration); slideOut:Play(); task.wait(0.4); notifyFrame:Destroy()
    end)
end

return UILIB
