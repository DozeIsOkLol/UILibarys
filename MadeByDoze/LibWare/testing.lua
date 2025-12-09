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
        function ElementMethods:AddLabel(text) local Label = Instance.new("TextLabel", TabContent); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 0, 20); Label.Font = Enum.Font.GothamSemibold; Label.Text = text; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 16; Label.TextXAlignment = Enum.TextXAlignment.Left; return Label end
        function ElementMethods:AddParagraph(text) local Frame = Instance.new("Frame", TabContent); Frame.BackgroundTransparency = 1; local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, 0, 1, 0); Label.Font = Enum.Font.Gotham; Label.Text = text; Label.TextColor3 = Color3.fromRGB(200, 200, 200); Label.TextSize = 14; Label.TextWrapped = true; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextYAlignment = Enum.TextYAlignment.Top; local size = TextService:GetTextSize(text, 14, Enum.Font.Gotham, Vector2.new(ContentContainer.AbsoluteSize.X - 30, 1000)); Frame.Size = UDim2.new(1, 0, 0, size.Y + 5); return Frame end
        function ElementMethods:AddButton(config) local Button = Instance.new("TextButton", TabContent); Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Button.Size = UDim2.new(1, 0, 0, 35); Button.Font = Enum.Font.Gotham; Button.Text = config.Name; Button.TextColor3 = Color3.fromRGB(255, 255, 255); Button.TextSize = 14; Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6); Button.MouseButton1Click:Connect(function() pcall(config.Callback) end); return Button end
        function ElementMethods:AddToggle(config) local toggled = false; local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 40); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Switch = Instance.new("Frame", Frame); Switch.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Switch.Position = UDim2.new(1, -60, 0.5, 0); Switch.Size = UDim2.new(0, 50, 0, 24); Switch.AnchorPoint = Vector2.new(0, 0.5); Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0); local Circle = Instance.new("Frame", Switch); Circle.BackgroundColor3 = Color3.fromRGB(180, 180, 180); Circle.Position = UDim2.new(0, 4, 0.5, 0); Circle.Size = UDim2.new(0, 16, 0, 16); Circle.AnchorPoint = Vector2.new(0, 0.5); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0); local Button = Instance.new("TextButton", Frame); Button.BackgroundTransparency = 1; Button.Size = UDim2.new(1, 0, 1, 0); Button.Text = ""; Button.MouseButton1Click:Connect(function() toggled = not toggled; pcall(config.Callback, toggled); local pos = toggled and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 4, 0.5, 0); local cColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180); local sColor = toggled and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 30, 30); TweenService:Create(Circle, TweenInfo.new(0.2), {Position = pos, BackgroundColor3 = cColor}):Play(); TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = sColor}):Play() end); return Frame end
        function ElementMethods:AddSlider(config) local min, max = config.Min or 0, config.Max or 100; local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 60); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, -70, 0, 25); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Value = Instance.new("TextLabel", Frame); Value.BackgroundTransparency = 1; Value.Size = UDim2.new(0, 50, 0, 25); Value.Position = UDim2.new(1, -60, 0, 0); Value.Font = Enum.Font.GothamBold; Value.Text = tostring(min); Value.TextColor3 = Color3.fromRGB(255, 255, 255); Value.TextSize = 14; Value.TextXAlignment = Enum.TextXAlignment.Right; local Track = Instance.new("Frame", Frame); Track.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Track.Position = UDim2.new(0.5, 0, 1, -18); Track.Size = UDim2.new(1, -20, 0, 8); Track.AnchorPoint = Vector2.new(0.5, 0); Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0); local Progress = Instance.new("Frame", Track); Progress.BackgroundColor3 = Color3.fromRGB(0, 122, 255); Progress.Size = UDim2.new(0, 0, 1, 0); Instance.new("UICorner", Progress).CornerRadius = UDim.new(1, 0); local Button = Instance.new("TextButton", Track); Button.BackgroundTransparency = 1; Button.Size = UDim2.new(1, 0, 1, 0); Button.Text = ""; local function update(pos) local percent = math.clamp((pos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1); local val = math.floor(min + (max - min) * percent + 0.5); Progress.Size = UDim2.new(percent, 0, 1, 0); Value.Text = tostring(val); pcall(config.Callback, val) end; local dragging = false; Button.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i.Position) end end); Button.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end); Button.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and dragging then update(i.Position) end end); return Frame end
        function ElementMethods:AddTextbox(config) local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 40); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.5, -10, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Box = Instance.new("TextBox", Frame); Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Box.Position = UDim2.new(1, -160, 0.5, 0); Box.Size = UDim2.new(0, 150, 0, 28); Box.AnchorPoint = Vector2.new(0, 0.5); Box.Font = Enum.Font.Gotham; Box.PlaceholderText = config.Placeholder or "..."; Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150); Box.TextColor3 = Color3.fromRGB(255, 255, 255); Box.TextSize = 14; Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6); Box.FocusLost:Connect(function(enter) if enter then pcall(config.Callback, Box.Text) end end); return Frame end
        function ElementMethods:AddKeybind(config) local key, listening = config.Key or Enum.KeyCode.RightControl, false; local Frame = Instance.new("Frame", TabContent); Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Frame.Size = UDim2.new(1, 0, 0, 40); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6); local Label = Instance.new("TextLabel", Frame); Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; local Button = Instance.new("TextButton", Frame); Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Button.Position = UDim2.new(1, -100, 0.5, 0); Button.Size = UDim2.new(0, 90, 0, 25); Button.AnchorPoint = Vector2.new(0, 0.5); Button.Font = Enum.Font.GothamBold; Button.Text = key.Name; Button.TextColor3 = Color3.fromRGB(255, 255, 255); Button.TextSize = 12; Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6); Button.MouseButton1Click:Connect(function() listening = true; Button.Text = ". . ." end); UserInputService.InputBegan:Connect(function(i, p) if p then return end; if listening then key = i.KeyCode; Button.Text = key.Name; listening = false elseif i.KeyCode == key then pcall(config.Callback) end end); return Frame end
        
        -- ================================================================================= --
        -- ||                   START OF NEWLY ADDED UI ELEMENTS                          || --
        -- ================================================================================= --

        function ElementMethods:AddDivider()
            local Divider = Instance.new("Frame", TabContent)
            Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Divider.BorderSizePixel = 0
            Divider.Size = UDim2.new(1, 0, 0, 2)
            return Divider
        end

        function ElementMethods:AddSection(text)
            local Label = Instance.new("TextLabel", TabContent)
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 0, 24)
            Label.Font = Enum.Font.GothamBold -- Bolder font for sections
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 18 -- Larger text size
            Label.TextXAlignment = Enum.TextXAlignment.Left
            return Label
        end

        function ElementMethods:AddButtonRow(buttons)
            local RowFrame = Instance.new("Frame", TabContent)
            RowFrame.BackgroundTransparency = 1
            RowFrame.Size = UDim2.new(1, 0, 0, 35)

            local ListLayout = Instance.new("UIListLayout", RowFrame)
            ListLayout.FillDirection = Enum.FillDirection.Horizontal
            ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 10)

            local numButtons = #buttons
            for i, buttonInfo in ipairs(buttons) do
                local text, callback = buttonInfo[1], buttonInfo[2]
                local Button = Instance.new("TextButton", RowFrame)
                Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                -- Distribute width evenly, accounting for padding
                Button.Size = UDim2.new(1/numButtons, -((numButtons-1)*10)/numButtons, 1, 0)
                Button.Font = Enum.Font.Gotham
                Button.Text = text
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.TextSize = 14
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
                Button.MouseButton1Click:Connect(function() pcall(callback) end)
            end
            return RowFrame
        end

        function ElementMethods:AddStepper(config)
            local currentIndex = 1
            if config.Default then
                for i, v in ipairs(config.Options) do if v == config.Default then currentIndex = i break end end
            end

            local Frame = Instance.new("Frame", TabContent)
            Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Frame.Size = UDim2.new(1, 0, 0, 40)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel", Frame)
            Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.5, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.Gotham; Label.Text = config.Name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel", Frame)
            ValueLabel.BackgroundTransparency = 1; ValueLabel.Size = UDim2.new(0.5, -80, 1, 0); ValueLabel.Position = UDim2.new(0.5, -10, 0, 0); ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = config.Options[currentIndex]; ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255); ValueLabel.TextSize = 14; ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local BackButton = Instance.new("TextButton", Frame)
            BackButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); BackButton.Position = UDim2.new(1, -65, 0.5, 0); BackButton.Size = UDim2.new(0, 25, 0, 25)
            BackButton.AnchorPoint = Vector2.new(0, 0.5); BackButton.Font = Enum.Font.GothamBold; BackButton.Text = "<"; BackButton.TextColor3 = Color3.fromRGB(255, 255, 255); BackButton.TextSize = 14
            Instance.new("UICorner", BackButton).CornerRadius = UDim.new(0, 4)

            local ForwardButton = Instance.new("TextButton", Frame)
            ForwardButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ForwardButton.Position = UDim2.new(1, -35, 0.5, 0); ForwardButton.Size = UDim2.new(0, 25, 0, 25)
            ForwardButton.AnchorPoint = Vector2.new(0, 0.5); ForwardButton.Font = Enum.Font.GothamBold; ForwardButton.Text = ">"; ForwardButton.TextColor3 = Color3.fromRGB(255, 255, 255); ForwardButton.TextSize = 14
            Instance.new("UICorner", ForwardButton).CornerRadius = UDim.new(0, 4)

            local function updateValue()
                ValueLabel.Text = config.Options[currentIndex]
                pcall(config.Callback, config.Options[currentIndex])
            end

            BackButton.MouseButton1Click:Connect(function()
                currentIndex = currentIndex - 1
                if currentIndex < 1 then currentIndex = #config.Options end
                updateValue()
            end)

            ForwardButton.MouseButton1Click:Connect(function()
                currentIndex = currentIndex + 1
                if currentIndex > #config.Options then currentIndex = 1 end
                updateValue()
            end)

            return Frame
        end
        
        function ElementMethods:AddCheckbox(config)
            local list = config.List or {}
            local Frame = Instance.new("Frame", TabContent)
            Frame.BackgroundTransparency = 1
            Frame.Size = UDim2.new(1, 0, 0, 20 + (#list * 30)) -- Dynamic height based on list items

            local Title = Instance.new("TextLabel", Frame)
            Title.BackgroundTransparency = 1; Title.Size = UDim2.new(1, 0, 0, 20); Title.Font = Enum.Font.GothamSemibold; Title.Text = config.Name
            Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

            local ListContainer = Instance.new("Frame", Frame)
            ListContainer.BackgroundTransparency = 1
            ListContainer.Size = UDim2.new(1, 0, 1, -20)
            ListContainer.Position = UDim2.new(0, 0, 0, 20)
            local ListLayout = Instance.new("UIListLayout", ListContainer)
            ListLayout.Padding = UDim.new(0, 5)

            local selected = {}
            for _, optionName in ipairs(list) do
                selected[optionName] = false
                local toggled = false
                
                local ItemFrame = Instance.new("Frame", ListContainer)
                ItemFrame.BackgroundTransparency = 1
                ItemFrame.Size = UDim2.new(1, 0, 0, 25)

                local Checkbox = Instance.new("TextButton", ItemFrame)
                Checkbox.Size = UDim2.new(0, 20, 0, 20)
                Checkbox.Position = UDim2.new(0, 0, 0.5, 0)
                Checkbox.AnchorPoint = Vector2.new(0, 0.5)
                Checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Checkbox.Text = ""
                Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
                
                local Checkmark = Instance.new("Frame", Checkbox)
                Checkmark.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
                Checkmark.BorderSizePixel = 0
                Checkmark.Size = UDim2.new(1, -6, 1, -6)
                Checkmark.Position = UDim2.fromScale(0.5, 0.5)
                Checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
                Checkmark.Visible = false -- Initially unchecked
                Instance.new("UICorner", Checkmark).CornerRadius = UDim.new(0, 2)
                
                local Label = Instance.new("TextLabel", ItemFrame)
                Label.BackgroundTransparency = 1; Label.Size = UDim2.new(1, -30, 1, 0); Label.Position = UDim2.new(0, 30, 0, 0); Label.Font = Enum.Font.Gotham
                Label.Text = optionName; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left
                
                Checkbox.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    selected[optionName] = toggled
                    Checkmark.Visible = toggled
                    pcall(config.Callback, selected)
                end)
            end
            return Frame
        end
--new new
        function ElementMethods:AddDropdown(config)
            local isOpen = false
            local currentOption = config.Default or config.Options[1]

            -- This is the main button the user sees and interacts with. It sits in the normal layout.
            local MainButton = Instance.new("TextButton")
            MainButton.Name = "DropdownButton"
            MainButton.Parent = TabContent
            MainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            MainButton.Size = UDim2.new(1, 0, 0, 35)
            MainButton.Font = Enum.Font.Gotham
            MainButton.Text = config.Name .. ": " .. currentOption
            MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            MainButton.TextSize = 14
            Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 6)

            -- This is the container for the list of options. It will be parented to the main ScreenGui to overlay everything.
            local OptionsContainer = Instance.new("ScrollingFrame")
            OptionsContainer.Name = "DropdownOptions"
            OptionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            OptionsContainer.BorderColor3 = Color3.fromRGB(55, 55, 55)
            OptionsContainer.BorderSizePixel = 1
            OptionsContainer.Size = UDim2.new(0, 0, 0, 0) -- Starts with zero size
            OptionsContainer.ScrollBarThickness = 4
            OptionsContainer.ClipsDescendants = true
            OptionsContainer.ZIndex = 500 -- High ZIndex to ensure it's on top of all other UI
            Instance.new("UICorner", OptionsContainer).CornerRadius = UDim.new(0, 6)
            
            local ListLayout = Instance.new("UIListLayout", OptionsContainer)
            ListLayout.Padding = UDim.new(0, 4)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local ListPadding = Instance.new("UIPadding", OptionsContainer)
            ListPadding.PaddingTop = UDim.new(0, 4)
            ListPadding.PaddingBottom = UDim.new(0, 4)
            ListPadding.PaddingLeft = UDim.new(0, 4)
            ListPadding.PaddingRight = UDim.new(0, 4)

            -- Function to cleanly close and hide the dropdown list
            local function closeDropdown()
                if not isOpen then return end
                isOpen = false
                TweenService:Create(OptionsContainer, TweenInfo.new(0.2), { Size = UDim2.new(OptionsContainer.Size.X.Scale, OptionsContainer.AbsoluteSize.X, 0, 0) }):Play()
                task.wait(0.2)
                if OptionsContainer.Parent then OptionsContainer.Parent = nil end
            end
            
            -- Function to show and position the dropdown list
            local function openDropdown()
                if isOpen then return end
                isOpen = true
                
                -- Parent the list to the highest level GUI to take it out of the layout flow
                OptionsContainer.Parent = UILIB_Window.ScreenGui
                
                -- Position the list directly below the button using absolute pixel coordinates
                local buttonAbsPos = MainButton.AbsolutePosition
                local buttonAbsSize = MainButton.AbsoluteSize
                OptionsContainer.Position = UDim2.fromOffset(buttonAbsPos.X, buttonAbsPos.Y + buttonAbsSize.Y + 5)
                OptionsContainer.Size = UDim2.fromOffset(buttonAbsSize.X, 0)
                
                -- Clear any previously created option buttons
                for _, child in ipairs(OptionsContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                -- Create a new button for each option in the list
                for _, optionName in ipairs(config.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = optionName
                    OptionButton.Parent = OptionsContainer
                    OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    OptionButton.Size = UDim2.new(1, -8, 0, 28) -- Full width minus padding
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = optionName
                    OptionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                    OptionButton.TextSize = 14
                    Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        currentOption = optionName
                        MainButton.Text = config.Name .. ": " .. currentOption
                        pcall(config.Callback, currentOption)
                        closeDropdown()
                    end)

                    -- Add hover effects to match the library's style
                    OptionButton.MouseEnter:Connect(function() TweenService:Create(OptionButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(65, 65, 65) }):Play() end)
                    OptionButton.MouseLeave:Connect(function() TweenService:Create(OptionButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play() end)
                end
                
                -- Animate the list appearing
                local numOptions = #config.Options
                local dropdownHeight = math.min(numOptions * 32 + 8, 136) -- Calculate total height, with a max height of 136px
                TweenService:Create(OptionsContainer, TweenInfo.new(0.2), { Size = UDim2.fromOffset(buttonAbsSize.X, dropdownHeight) }):Play()
            end

            MainButton.MouseButton1Click:Connect(function()
                if isOpen then closeDropdown() else openDropdown() end
            end)

            return MainButton
        end

        -- ================================================================================= --
        -- ||                    END OF NEWLY ADDED UI ELEMENTS                           || --
        -- ================================================================================= --

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
