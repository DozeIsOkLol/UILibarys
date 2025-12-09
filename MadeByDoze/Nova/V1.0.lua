--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                     NovaUI v1.0                           ║
    ║        A feature-rich, modern Lua GUI framework.          ║
    ║      Combining the best of BloxHub and StarlightUI.       ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local NovaUI = { _windows = {} }
NovaUI.__index = NovaUI

-- Services & Utils
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function tween(inst, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    return TweenService:Create(inst, info, props)
end

function NovaUI.new(config)
    local self = setmetatable({}, NovaUI)
    self.windows = {}
    self.activeKeybind = nil

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NovaUI_Root"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

    self.Themes = {
        Dark = {
            Background = Color3.fromRGB(25, 25, 30),
            Primary = Color3.fromRGB(35, 35, 40),
            Secondary = Color3.fromRGB(50, 50, 55),
            Accent = Color3.fromRGB(0, 120, 255),
            Text = Color3.fromRGB(255, 255, 255),
            TextDim = Color3.fromRGB(170, 170, 170)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 240),
            Primary = Color3.fromRGB(255, 255, 255),
            Secondary = Color3.fromRGB(225, 225, 225),
            Accent = Color3.fromRGB(0, 120, 255),
            Text = Color3.fromRGB(20, 20, 20),
            TextDim = Color3.fromRGB(100, 100, 100)
        },
        Purple = {
            Background = Color3.fromRGB(20, 15, 30),
            Primary = Color3.fromRGB(30, 25, 45),
            Secondary = Color3.fromRGB(45, 35, 60),
            Accent = Color3.fromRGB(138, 43, 226),
            Text = Color3.fromRGB(255, 255, 255),
            TextDim = Color3.fromRGB(180, 170, 200)
        },
    }
    self.theme = self.Themes.Dark

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if self.activeKeybind then
            local keybind = self.activeKeybind
            self.activeKeybind = nil
            keybind:update(input.KeyCode.Name)
            if keybind.callback then
                pcall(keybind.callback, input.KeyCode.Name)
            end
        end
    end)

    return self
end

function NovaUI:setTheme(name)
    if not self.Themes[name] then return end
    self.theme = self.Themes[name]
    -- In a more complex scenario, you'd iterate through all created elements and update their colors.
    -- For simplicity, this example relies on recreating the UI or setting the theme at the start.
end

function NovaUI:createWindow(config)
    local novaInstance = self
    local window = { tabs = {}, activeTab = nil, elements = {} }
    table.insert(novaInstance.windows, window)

    local main = Instance.new("Frame")
    main.Name = config.title or "NovaWindow"
    main.Size = config.size or UDim2.new(0, 540, 0, 400)
    main.Position = config.position or UDim2.new(0.5, -270, 0.5, -200)
    main.BackgroundColor3 = novaInstance.theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = novaInstance.screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = novaInstance.theme.Primary
    header.Parent = main
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = config.title
    title.TextColor3 = novaInstance.theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = 16

    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(0, 140, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = novaInstance.theme.Primary
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 0
    tabContainer.Parent = main
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", tabContainer).PaddingTop = UDim.new(0, 10)

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -140, 1, -40)
    contentContainer.Position = UDim2.new(0, 140, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = main

    -- Dragging Logic
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragStart = input.Position
            local startPos = main.Position
            local moveConn, upConn
            moveConn = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (i.Position.X - dragStart.X),
                                              startPos.Y.Scale, startPos.Y.Offset + (i.Position.Y - dragStart.Y))
                end
            end)
            upConn = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConn:Disconnect()
                    upConn:Disconnect()
                end
            end)
        end
    end)
    
    function window:createTab(name)
        local tab = { elements = {} }
        
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, -20, 0, 35)
        button.Position = UDim2.new(0.5, 0, 0, 0)
        button.AnchorPoint = Vector2.new(0.5, 0)
        button.BackgroundColor3 = novaInstance.theme.Secondary
        button.Text = name
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 14
        button.TextColor3 = novaInstance.theme.Text
        button.Parent = tabContainer
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -20, 1, -10)
        content.Position = UDim2.new(0, 10, 0, 5)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = novaInstance.theme.Accent
        content.Visible = false
        content.Parent = contentContainer
        local list = Instance.new("UIListLayout", content)
        list.Padding = UDim.new(0, 8)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        local function activate()
            for _, t in pairs(window.tabs) do
                t.content.Visible = false
                tween(t.button, { BackgroundColor3 = novaInstance.theme.Secondary }, 0.15):Play()
            end
            content.Visible = true
            tween(button, { BackgroundColor3 = novaInstance.theme.Accent }, 0.15):Play()
            window.activeTab = tab
        end
        button.MouseButton1Click:Connect(activate)

        tab.button = button
        tab.content = content
        table.insert(window.tabs, tab)

        if not window.activeTab then activate() end
        
        -- COMPONENT FACTORY
        function tab:addLabel(text, props)
            props = props or {}
            local label = Instance.new("TextLabel", content)
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = props.bold and Enum.Font.GothamBold or Enum.Font.Gotham
            label.TextSize = props.size or 16
            label.TextColor3 = novaInstance.theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end

        function tab:addButton(text, callback)
            local btn = Instance.new("TextButton", content)
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundColor3 = novaInstance.theme.Primary
            btn.Text, btn.Font, btn.TextSize, btn.TextColor3 = text, Enum.Font.Gotham, 14, novaInstance.theme.Text
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = novaInstance.theme.Accent }):Play() end)
            btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = novaInstance.theme.Primary }):Play() end)
            if callback then btn.MouseButton1Click:Connect(callback) end
            return btn
        end

        function tab:addToggle(text, default, callback)
            local toggled = default or false
            local container = Instance.new("Frame", content)
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = novaInstance.theme.Primary
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
            
            Instance.new("TextLabel", container)._ref = {
                Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, Text = text, TextSize = 14, TextColor3 = novaInstance.theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            }

            local switch = Instance.new("Frame", container)
            switch.Size, switch.Position = UDim2.new(0, 40, 0, 20), UDim2.new(1, -55, 0.5, -10)
            switch.BackgroundColor3 = toggled and novaInstance.theme.Accent or novaInstance.theme.Secondary
            Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 10)

            local knob = Instance.new("Frame", switch)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 8)
            
            local btn = Instance.new("TextButton", container)
            btn.Size, btn.BackgroundTransparency = UDim2.new(1,0,1,0), 1
            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                tween(switch, { BackgroundColor3 = toggled and novaInstance.theme.Accent or novaInstance.theme.Secondary }):Play()
                tween(knob, { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }):Play()
                if callback then pcall(callback, toggled) end
            end)
            return { get = function() return toggled end, set = function(v) toggled = v; -- update visuals end }
        end
        
        function tab:addSlider(text, min, max, default, callback)
            local value = default or min
            local container = Instance.new("Frame", content)
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundColor3 = novaInstance.theme.Primary
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

            Instance.new("TextLabel", container)._ref = {
                Size = UDim2.new(0.7, 0, 0, 20), Position = UDim2.new(0, 15, 0, 5), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, Text = text, TextSize = 14, TextColor3 = novaInstance.theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            }
            local valueLabel = Instance.new("TextLabel", container)
            valueLabel.Size, valueLabel.Position, valueLabel.BackgroundTransparency = UDim2.new(0.3, -15, 0, 20), UDim2.new(0.7, 0, 0, 5), 1
            valueLabel.Font, valueLabel.TextSize, valueLabel.TextColor3 = Enum.Font.GothamBold, 14, novaInstance.theme.TextDim
            valueLabel.TextXAlignment, valueLabel.Text = Enum.TextXAlignment.Right, tostring(math.floor(value))

            local track = Instance.new("Frame", container)
            track.Size, track.Position = UDim2.new(1, -30, 0, 4), UDim2.new(0.5, 0, 1, -15)
            track.AnchorPoint, track.BackgroundColor3 = Vector2.new(0.5, 0.5), novaInstance.theme.Secondary
            Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)
            
            local fill = Instance.new("Frame", track)
            fill.Size, fill.BackgroundColor3 = UDim2.new((value-min)/(max-min), 0, 1, 0), novaInstance.theme.Accent
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
            
            local dragger = Instance.new("TextButton", track)
            dragger.Size, dragger.BackgroundTransparency = UDim2.new(1,0,3,0), 1
            dragger.Position, dragger.AnchorPoint = UDim2.new(0,0,0.5,0), Vector2.new(0, 0.5)

            local function update(inputX)
                local percent = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                valueLabel.Text = tostring(math.floor(value))
                if callback then pcall(callback, math.floor(value)) end
            end
            dragger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    update(input.Position.X)
                    local move, up
                    move = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
                    up = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() up:Disconnect() end end)
                end
            end)
            return { get = function() return value end }
        end
        
        function tab:addKeybind(text, default, callback)
            local key = default or "..."
            local container = Instance.new("Frame", content)
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = novaInstance.theme.Primary
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
            
            Instance.new("TextLabel", container)._ref = {
                Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, Text = text, TextSize = 14, TextColor3 = novaInstance.theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            }

            local keyButton = Instance.new("TextButton", container)
            keyButton.Size, keyButton.Position = UDim2.new(0.4, -15, 1, -10), UDim2.new(0.6, 0, 0.5, 0)
            keyButton.AnchorPoint = Vector2.new(0, 0.5)
            keyButton.BackgroundColor3 = novaInstance.theme.Secondary
            keyButton.Text, keyButton.Font, keyButton.TextColor3 = key, Enum.Font.GothamSemibold, novaInstance.theme.TextDim
            Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0, 4)

            local keybind = { button = keyButton, callback = callback, key = key }
            function keybind:update(newKey)
                self.key = newKey
                self.button.Text = newKey
            end

            keyButton.MouseButton1Click:Connect(function()
                keyButton.Text = "..."
                novaInstance.activeKeybind = keybind
            end)
            return keybind
        end
        
        function tab:addTextBox(text, placeholder, callback)
            local container = Instance.new("Frame", content)
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = novaInstance.theme.Primary
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
            
            Instance.new("TextLabel", container)._ref = {
                Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, Text = text, TextSize = 14, TextColor3 = novaInstance.theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            }

            local box = Instance.new("TextBox", container)
            box.Size, box.Position = UDim2.new(0.65, -15, 1, -10), UDim2.new(0.35, 0, 0.5, 0)
            box.AnchorPoint = Vector2.new(0, 0.5)
            box.BackgroundColor3 = novaInstance.theme.Secondary
            box.Font, box.TextColor3 = Enum.Font.Gotham, novaInstance.theme.Text
            box.PlaceholderText = placeholder or ""
            box.PlaceholderColor3 = novaInstance.theme.TextDim
            box.ClearTextOnFocus = false
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            Instance.new("UIPadding", box).PaddingLeft = UDim.new(0, 10)

            if callback then
                box.FocusLost:Connect(function(enterPressed)
                    pcall(callback, box.Text, enterPressed)
                end)
            end
            return { get = function() return box.Text end, set = function(t) box.Text = t end }
        end
        
        function tab:addDropdown(text, options, callback)
            local expanded = false
            local selected = options[1]
            
            local container = Instance.new("Frame", content)
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = novaInstance.theme.Primary
            container.ZIndex = 2
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
            
            Instance.new("TextLabel", container)._ref = {
                Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, Text = text, TextSize = 14, TextColor3 = novaInstance.theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            }
            
            local dropdown = Instance.new("TextButton", container)
            dropdown.Size, dropdown.Position = UDim2.new(0.5, -15, 1, -10), UDim2.new(0.5, 0, 0.5, 0)
            dropdown.AnchorPoint = Vector2.new(0, 0.5)
            dropdown.BackgroundColor3 = novaInstance.theme.Secondary
            dropdown.Font, dropdown.TextColor3 = Enum.Font.GothamSemibold, novaInstance.theme.Text
            dropdown.Text = selected .. " ▼"
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 4)

            local optionsHolder = Instance.new("Frame", novaInstance.screenGui)
            optionsHolder.Size = UDim2.fromOffset(dropdown.AbsoluteSize.X, #options * 28 + 10)
            optionsHolder.BackgroundColor3 = novaInstance.theme.Primary
            optionsHolder.BorderSizePixel = 0
            optionsHolder.Visible = false
            optionsHolder.ZIndex = 10
            Instance.new("UICorner", optionsHolder).CornerRadius = UDim.new(0, 6)
            Instance.new("UIListLayout", optionsHolder).Padding = UDim.new(0, 5)
            Instance.new("UIPadding", optionsHolder).PaddingLeft = UDim.new(0,5)
            Instance.new("UIPadding", optionsHolder).PaddingRight = UDim.new(0,5)
            Instance.new("UIPadding", optionsHolder).PaddingTop = UDim.new(0,5)

            for _, opt in pairs(options) do
                local btn = Instance.new("TextButton", optionsHolder)
                btn.Size = UDim2.new(1, 0, 0, 28)
                btn.BackgroundColor3 = novaInstance.theme.Secondary
                btn.Text, btn.Font, btn.TextColor3 = opt, Enum.Font.Gotham, novaInstance.theme.Text
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function()
                    selected = opt
                    dropdown.Text = selected .. " ▼"
                    optionsHolder.Visible = false
                    expanded = false
                    if callback then pcall(callback, opt) end
                end)
            end

            dropdown.MouseButton1Click:Connect(function()
                expanded = not expanded
                optionsHolder.Visible = expanded
                optionsHolder.Position = UDim2.fromOffset(dropdown.AbsolutePosition.X, dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y)
                dropdown.Text = selected .. (expanded and " ▲" or " ▼")
            end)
            return { get = function() return selected end }
        end
        
        return tab
    end

    return window
end

return NovaUI
