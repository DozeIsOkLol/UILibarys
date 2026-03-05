-- Custom Roblox UI Library v1.0
-- Features: Dropdown Tabs, Modern Design, Smooth Animations

local Library = {}
local Services = setmetatable({}, {
    __index = function(self, key)
        return game:GetService(key)
    end
})

local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local RunService = Services.RunService
local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Config
local Config = {
    MainColor = Color3.fromRGB(35, 35, 35),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(120, 120, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(14, 255, 110),
    ToggleOff = Color3.fromRGB(255, 44, 44),
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function Tween(object, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Sine
    direction = direction or Enum.EasingDirection.InOut
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function CreateDrag(frame, dragFrame)
    dragFrame = dragFrame or frame
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Tween(frame, {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function CreateRipple(button)
    spawn(function()
        if not button.ClipsDescendants then
            button.ClipsDescendants = true
        end
        
        local ripple = CreateInstance("ImageLabel", {
            Name = "Ripple",
            Parent = button,
            BackgroundTransparency = 1,
            ZIndex = 10,
            Image = "rbxassetid://2708891598",
            ImageTransparency = 0.7,
            ImageColor3 = Config.AccentColor,
            ScaleType = Enum.ScaleType.Fit,
            Position = UDim2.new(
                (Mouse.X - button.AbsolutePosition.X) / button.AbsoluteSize.X,
                0,
                (Mouse.Y - button.AbsolutePosition.Y) / button.AbsoluteSize.Y,
                0
            )
        })
        
        Tween(ripple, {
            Position = UDim2.new(-5.5, 0, -5.5, 0),
            Size = UDim2.new(12, 0, 12, 0)
        }, 0.8)
        
        wait(0.3)
        Tween(ripple, {ImageTransparency = 1}, 0.4)
        wait(0.4)
        ripple:Destroy()
    end)
end

-- Main Library Functions
function Library:CreateWindow(windowName, toggleKey)
    windowName = windowName or "Custom UI"
    toggleKey = toggleKey or Enum.KeyCode.RightShift
    
    -- Create ScreenGui
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "CustomUI_" .. tostring(math.random(10000, 99999)),
        Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or Services.CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Config.MainColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.1, 0, 0.1, 0),
        Size = UDim2.new(0, 500, 0, 40),
        ClipsDescendants = true
    })
    
    CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Title Bar
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    CreateInstance("UICorner", {
        Parent = TitleBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Accent Line
    local AccentLine = CreateInstance("Frame", {
        Name = "AccentLine",
        Parent = TitleBar,
        BackgroundColor3 = Config.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2)
    })
    
    CreateInstance("UIGradient", {
        Parent = AccentLine,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Config.SecondaryColor),
            ColorSequenceKeypoint.new(0.3, Config.AccentColor),
            ColorSequenceKeypoint.new(0.7, Config.AccentColor),
            ColorSequenceKeypoint.new(1, Config.SecondaryColor)
        })
    })
    
    -- Title Label
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "TitleLabel",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = Config.TextColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Toggle Button
    local ToggleButton = CreateInstance("TextButton", {
        Name = "ToggleButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Config.TextColor,
        TextSize = 20
    })
    
    -- Content Container
    local ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        ClipsDescendants = true
    })
    
    local ContentLayout = CreateInstance("UIListLayout", {
        Parent = ContentContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    CreateInstance("UIPadding", {
        Parent = ContentContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    -- Drag Functionality
    CreateDrag(MainFrame, TitleBar)
    
    -- Toggle Functionality
    local isOpen = true
    local targetHeight = 40
    
    local function UpdateSize()
        local contentSize = ContentLayout.AbsoluteContentSize.Y + 60
        targetHeight = contentSize
        if isOpen then
            Tween(MainFrame, {Size = UDim2.new(0, 500, 0, contentSize)}, 0.3)
        end
    end
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
    
    ToggleButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ToggleButton.Text = isOpen and "-" or "+"
        
        if isOpen then
            Tween(MainFrame, {Size = UDim2.new(0, 500, 0, targetHeight)}, 0.3)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 500, 0, 40)}, 0.3)
        end
    end)
    
    -- Toggle Visibility Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    -- Window Object
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentContainer = ContentContainer,
        UpdateSize = UpdateSize
    }
    
    -- Create Dropdown/Tab
    function Window:CreateDropdown(dropdownName)
        local Dropdown = {}
        
        -- Dropdown Frame
        local DropdownFrame = CreateInstance("Frame", {
            Name = "Dropdown_" .. dropdownName,
            Parent = ContentContainer,
            BackgroundColor3 = Config.SecondaryColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 35),
            ClipsDescendants = false
        })
        
        CreateInstance("UICorner", {
            Parent = DropdownFrame,
            CornerRadius = UDim.new(0, 4)
        })
        
        -- Dropdown Header
        local DropdownHeader = CreateInstance("TextButton", {
            Name = "Header",
            Parent = DropdownFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Enum.Font.GothamSemibold,
            Text = "  " .. dropdownName,
            TextColor3 = Config.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Dropdown Arrow
        local DropdownArrow = CreateInstance("TextLabel", {
            Name = "Arrow",
            Parent = DropdownHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 0),
            Size = UDim2.new(0, 30, 0, 35),
            Font = Enum.Font.GothamBold,
            Text = "+",
            TextColor3 = Config.AccentColor,
            TextSize = 18
        })
        
        -- Dropdown Content
        local DropdownContent = CreateInstance("Frame", {
            Name = "Content",
            Parent = DropdownFrame,
            BackgroundColor3 = Config.MainColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 35),
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true
        })
        
        CreateInstance("UICorner", {
            Parent = DropdownContent,
            CornerRadius = UDim.new(0, 4)
        })
        
        local DropdownLayout = CreateInstance("UIListLayout", {
            Parent = DropdownContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
        
        CreateInstance("UIPadding", {
            Parent = DropdownContent,
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        })
        
        -- Toggle Dropdown
        local isDropdownOpen = false
        local contentHeight = 0
        
        local function UpdateDropdownSize()
            contentHeight = DropdownLayout.AbsoluteContentSize.Y + 10
            if isDropdownOpen then
                Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.25)
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35 + contentHeight + 5)}, 0.25)
            end
            Window.UpdateSize()
        end
        
        DropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateDropdownSize)
        
        DropdownHeader.MouseButton1Click:Connect(function()
            isDropdownOpen = not isDropdownOpen
            DropdownArrow.Text = isDropdownOpen and "-" or "+"
            Tween(DropdownArrow, {Rotation = isDropdownOpen and 180 or 0}, 0.25)
            
            if isDropdownOpen then
                Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.25)
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35 + contentHeight + 5)}, 0.25)
            else
                Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.25)
            end
            
            delay(0.3, function()
                Window.UpdateSize()
            end)
        end)
        
        DropdownHeader.MouseEnter:Connect(function()
            Tween(DropdownHeader, {BackgroundTransparency = 0.9}, 0.2)
        end)
        
        DropdownHeader.MouseLeave:Connect(function()
            Tween(DropdownHeader, {BackgroundTransparency = 1}, 0.2)
        end)
        
        Dropdown.Frame = DropdownFrame
        Dropdown.Content = DropdownContent
        Dropdown.UpdateSize = UpdateDropdownSize
        
        -- Add Button
        function Dropdown:AddButton(buttonName, callback)
            callback = callback or function() end
            
            local Button = CreateInstance("TextButton", {
                Name = "Button",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = "  " .. buttonName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClipsDescendants = true
            })
            
            CreateInstance("UICorner", {
                Parent = Button,
                CornerRadius = UDim.new(0, 4)
            })
            
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}, 0.2)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = Config.SecondaryColor}, 0.2)
            end)
            
            Button.MouseButton1Click:Connect(function()
                CreateRipple(Button)
                callback()
            end)
            
            UpdateDropdownSize()
            return Button
        end
        
        -- Add Toggle
        function Dropdown:AddToggle(toggleName, default, callback)
            default = default or false
            callback = callback or function() end
            
            local ToggleFrame = CreateInstance("Frame", {
                Name = "Toggle",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ToggleLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = toggleName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ToggleButton = CreateInstance("TextButton", {
                Name = "Button",
                Parent = ToggleFrame,
                BackgroundColor3 = default and Config.ToggleOn or Config.ToggleOff,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -35, 0.5, -12),
                Size = UDim2.new(0, 24, 0, 24),
                Text = ""
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleButton,
                CornerRadius = UDim.new(0, 4)
            })
            
            local toggled = default
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                Tween(ToggleButton, {
                    BackgroundColor3 = toggled and Config.ToggleOn or Config.ToggleOff
                }, 0.2)
                callback(toggled)
            end)
            
            UpdateDropdownSize()
            return ToggleButton
        end
        
        -- Add Slider
        function Dropdown:AddSlider(sliderName, min, max, default, callback)
            min = min or 0
            max = max or 100
            default = default or min
            callback = callback or function() end
            
            local SliderFrame = CreateInstance("Frame", {
                Name = "Slider",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 45)
            })
            
            CreateInstance("UICorner", {
                Parent = SliderFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local SliderLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 15),
                Font = Enum.Font.Gotham,
                Text = sliderName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SliderValue = CreateInstance("TextLabel", {
                Name = "Value",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 15),
                Font = Enum.Font.GothamBold,
                Text = tostring(default),
                TextColor3 = Config.AccentColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local SliderBack = CreateInstance("Frame", {
                Name = "Back",
                Parent = SliderFrame,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 1, -15),
                Size = UDim2.new(1, -20, 0, 6)
            })
            
            CreateInstance("UICorner", {
                Parent = SliderBack,
                CornerRadius = UDim.new(0, 3)
            })
            
            local SliderFill = CreateInstance("Frame", {
                Name = "Fill",
                Parent = SliderBack,
                BackgroundColor3 = Config.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            })
            
            CreateInstance("UICorner", {
                Parent = SliderFill,
                CornerRadius = UDim.new(0, 3)
            })
            
            local dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                SliderValue.Text = tostring(value)
                Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                callback(value)
            end
            
            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            SliderBack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            UpdateDropdownSize()
            return SliderFrame
        end
        
        -- Add Label
        function Dropdown:AddLabel(text)
            local Label = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.GothamSemibold,
                Text = text,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center
            })
            
            CreateInstance("UICorner", {
                Parent = Label,
                CornerRadius = UDim.new(0, 4)
            })
            
            UpdateDropdownSize()
            return Label
        end
        
        -- Add Textbox
        function Dropdown:AddTextbox(placeholder, callback)
            callback = callback or function() end
            
            local Textbox = CreateInstance("TextBox", {
                Name = "Textbox",
                Parent = DropdownContent,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                PlaceholderText = placeholder,
                Text = "",
                TextColor3 = Config.TextColor,
                TextSize = 13,
                ClearTextOnFocus = false
            })
            
            CreateInstance("UICorner", {
                Parent = Textbox,
                CornerRadius = UDim.new(0, 4)
            })
            
            CreateInstance("UIPadding", {
                Parent = Textbox,
                PaddingLeft = UDim.new(0, 10)
            })
            
            Textbox.FocusLost:Connect(function(enter)
                if enter then
                    callback(Textbox.Text)
                end
            end)
            
            UpdateDropdownSize()
            return Textbox
        end
        
        -- Add Keybind
        function Dropdown:AddKeybind(keybindName, defaultKey, callback)
            defaultKey = defaultKey or Enum.KeyCode.E
            callback = callback or function() end
            
            local KeybindFrame = CreateInstance("Frame", {
                Name = "Keybind",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            CreateInstance("UICorner", {
                Parent = KeybindFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local KeybindLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = KeybindFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -80, 1, 0),
                Font = Enum.Font.Gotham,
                Text = keybindName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local KeybindButton = CreateInstance("TextButton", {
                Name = "Button",
                Parent = KeybindFrame,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -65, 0.5, -12),
                Size = UDim2.new(0, 55, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = defaultKey.Name,
                TextColor3 = Config.TextColor,
                TextSize = 11
            })
            
            CreateInstance("UICorner", {
                Parent = KeybindButton,
                CornerRadius = UDim.new(0, 4)
            })
            
            local currentKey = defaultKey
            local selecting = false
            
            KeybindButton.MouseButton1Click:Connect(function()
                selecting = true
                KeybindButton.Text = "..."
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeybindButton.Text = currentKey.Name
                        selecting = false
                        connection:Disconnect()
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or selecting then return end
                if input.KeyCode == currentKey then
                    callback(currentKey)
                end
            end)
            
            UpdateDropdownSize()
            return KeybindButton
        end
        
        return Dropdown
    end
    
    return Window
end

return Library
