-- Custom Roblox UI Library v2.0
-- Features: Dropdown Tabs, Modern Design, Smooth Animations, Color Picker, Notifications, Config System, Themes

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
local HttpService = Services.HttpService

-- Config
local Config = {
    MainColor = Color3.fromRGB(35, 35, 35),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(120, 120, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(14, 255, 110),
    ToggleOff = Color3.fromRGB(255, 44, 44),
}

-- Themes
Library.Themes = {
    Dark = {
        MainColor = Color3.fromRGB(35, 35, 35),
        SecondaryColor = Color3.fromRGB(45, 45, 45),
        AccentColor = Color3.fromRGB(120, 120, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(14, 255, 110),
        ToggleOff = Color3.fromRGB(255, 44, 44),
    },
    Light = {
        MainColor = Color3.fromRGB(240, 240, 240),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(100, 100, 200),
        TextColor = Color3.fromRGB(30, 30, 30),
        ToggleOn = Color3.fromRGB(14, 200, 90),
        ToggleOff = Color3.fromRGB(220, 44, 44),
    },
    Ocean = {
        MainColor = Color3.fromRGB(20, 30, 50),
        SecondaryColor = Color3.fromRGB(30, 40, 60),
        AccentColor = Color3.fromRGB(50, 150, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(50, 255, 150),
        ToggleOff = Color3.fromRGB(255, 80, 80),
    },
    Forest = {
        MainColor = Color3.fromRGB(25, 35, 25),
        SecondaryColor = Color3.fromRGB(35, 45, 35),
        AccentColor = Color3.fromRGB(100, 200, 100),
        TextColor = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(100, 255, 100),
        ToggleOff = Color3.fromRGB(255, 80, 80),
    },
    Sunset = {
        MainColor = Color3.fromRGB(40, 25, 35),
        SecondaryColor = Color3.fromRGB(50, 35, 45),
        AccentColor = Color3.fromRGB(255, 150, 100),
        TextColor = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(255, 200, 100),
        ToggleOff = Color3.fromRGB(255, 80, 80),
    },
}

-- Config Storage
Library.ConfigData = {}
Library.Flags = {}

-- Notification System
Library.Notifications = {}

function Library:Notify(title, message, duration, notifType)
    duration = duration or 3
    notifType = notifType or "Info" -- Info, Success, Warning, Error
    
    local NotifColors = {
        Info = Config.AccentColor,
        Success = Color3.fromRGB(14, 255, 110),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 44, 44),
    }
    
    spawn(function()
        local NotifGui = CreateInstance("ScreenGui", {
            Name = "Notification",
            Parent = Services.CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        
        local NotifFrame = CreateInstance("Frame", {
            Name = "NotifFrame",
            Parent = NotifGui,
            BackgroundColor3 = Config.SecondaryColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 10, 0.95, 0),
            Size = UDim2.new(0, 300, 0, 0),
            AnchorPoint = Vector2.new(1, 1)
        })
        
        CreateInstance("UICorner", {
            Parent = NotifFrame,
            CornerRadius = UDim.new(0, 6)
        })
        
        local AccentBar = CreateInstance("Frame", {
            Name = "AccentBar",
            Parent = NotifFrame,
            BackgroundColor3 = NotifColors[notifType] or Config.AccentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 4)
        })
        
        CreateInstance("UICorner", {
            Parent = AccentBar,
            CornerRadius = UDim.new(0, 6)
        })
        
        local TitleLabel = CreateInstance("TextLabel", {
            Name = "Title",
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Config.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local MessageLabel = CreateInstance("TextLabel", {
            Name = "Message",
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(1, -20, 1, -45),
            Font = Enum.Font.Gotham,
            Text = message,
            TextColor3 = Config.TextColor,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        -- Calculate height based on text
        local textHeight = Services.TextService:GetTextSize(
            message,
            12,
            Enum.Font.Gotham,
            Vector2.new(280, 1000)
        ).Y
        
        local finalHeight = math.max(70, textHeight + 55)
        
        -- Slide in animation
        Tween(NotifFrame, {
            Position = UDim2.new(1, -10, 0.95, 0),
            Size = UDim2.new(0, 300, 0, finalHeight)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        wait(duration)
        
        -- Slide out animation
        Tween(NotifFrame, {
            Position = UDim2.new(1, 10, 0.95, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        wait(0.3)
        NotifGui:Destroy()
    end)
end

-- Theme Management
function Library:SetTheme(themeName)
    if not Library.Themes[themeName] then
        warn("Theme not found:", themeName)
        return
    end
    
    for key, value in pairs(Library.Themes[themeName]) do
        Config[key] = value
    end
    
    Library:Notify("Theme Changed", "Theme set to " .. themeName, 2, "Success")
end

-- Config Management
function Library:SaveConfig(configName)
    configName = configName or "default"
    
    local data = HttpService:JSONEncode(Library.ConfigData)
    
    if writefile then
        writefile(configName .. ".json", data)
        Library:Notify("Config Saved", "Configuration saved as " .. configName, 2, "Success")
    else
        warn("Executor does not support file writing")
    end
end

function Library:LoadConfig(configName)
    configName = configName or "default"
    
    if readfile and isfile and isfile(configName .. ".json") then
        local data = readfile(configName .. ".json")
        Library.ConfigData = HttpService:JSONDecode(data)
        
        -- Apply loaded config
        for flag, value in pairs(Library.ConfigData) do
            if Library.Flags[flag] then
                Library.Flags[flag](value)
            end
        end
        
        Library:Notify("Config Loaded", "Configuration loaded from " .. configName, 2, "Success")
    else
        warn("Config file not found or executor doesn't support file reading")
    end
end

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
        
        -- Add Color Picker
        function Dropdown:AddColorPicker(colorName, defaultColor, callback)
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
            callback = callback or function() end
            
            local ColorFrame = CreateInstance("Frame", {
                Name = "ColorPicker",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            CreateInstance("UICorner", {
                Parent = ColorFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ColorLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = ColorFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = colorName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ColorDisplay = CreateInstance("TextButton", {
                Name = "Display",
                Parent = ColorFrame,
                BackgroundColor3 = defaultColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -35, 0.5, -12),
                Size = UDim2.new(0, 24, 0, 24),
                Text = ""
            })
            
            CreateInstance("UICorner", {
                Parent = ColorDisplay,
                CornerRadius = UDim.new(0, 4)
            })
            
            CreateInstance("UIStroke", {
                Parent = ColorDisplay,
                Color = Config.TextColor,
                Thickness = 2,
                Transparency = 0.5
            })
            
            local currentColor = defaultColor
            local pickerOpen = false
            
            -- Color Picker Popup
            local function CreateColorPickerPopup()
                if pickerOpen then return end
                pickerOpen = true
                
                local PickerGui = CreateInstance("ScreenGui", {
                    Name = "ColorPickerPopup",
                    Parent = Services.CoreGui,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                })
                
                local PickerFrame = CreateInstance("Frame", {
                    Name = "Picker",
                    Parent = PickerGui,
                    BackgroundColor3 = Config.MainColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, -125, 0.5, -125),
                    Size = UDim2.new(0, 250, 0, 280)
                })
                
                CreateInstance("UICorner", {
                    Parent = PickerFrame,
                    CornerRadius = UDim.new(0, 8)
                })
                
                local TitleLabel = CreateInstance("TextLabel", {
                    Name = "Title",
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamBold,
                    Text = "Color Picker",
                    TextColor3 = Config.TextColor,
                    TextSize = 14
                })
                
                -- RGB Sliders
                local function CreateRGBSlider(name, yPos, startValue)
                    local SliderLabel = CreateInstance("TextLabel", {
                        Parent = PickerFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, yPos),
                        Size = UDim2.new(0, 30, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = name .. ":",
                        TextColor3 = Config.TextColor,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    local SliderBack = CreateInstance("Frame", {
                        Parent = PickerFrame,
                        BackgroundColor3 = Config.SecondaryColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 45, 0, yPos + 2),
                        Size = UDim2.new(0, 150, 0, 16)
                    })
                    
                    CreateInstance("UICorner", {
                        Parent = SliderBack,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    local SliderFill = CreateInstance("Frame", {
                        Parent = SliderBack,
                        BackgroundColor3 = name == "R" and Color3.fromRGB(255, 0, 0) or 
                                          name == "G" and Color3.fromRGB(0, 255, 0) or 
                                          Color3.fromRGB(0, 0, 255),
                        BorderSizePixel = 0,
                        Size = UDim2.new(startValue / 255, 0, 1, 0)
                    })
                    
                    CreateInstance("UICorner", {
                        Parent = SliderFill,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    local ValueLabel = CreateInstance("TextLabel", {
                        Parent = PickerFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 200, 0, yPos),
                        Size = UDim2.new(0, 40, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = tostring(startValue),
                        TextColor3 = Config.TextColor,
                        TextSize = 12
                    })
                    
                    return SliderBack, SliderFill, ValueLabel
                end
                
                local rSlider, rFill, rValue = CreateRGBSlider("R", 50, math.floor(currentColor.R * 255))
                local gSlider, gFill, gValue = CreateRGBSlider("G", 80, math.floor(currentColor.G * 255))
                local bSlider, bFill, bValue = CreateRGBSlider("B", 110, math.floor(currentColor.B * 255))
                
                -- Preview
                local PreviewFrame = CreateInstance("Frame", {
                    Name = "Preview",
                    Parent = PickerFrame,
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 150),
                    Size = UDim2.new(1, -20, 0, 60)
                })
                
                CreateInstance("UICorner", {
                    Parent = PreviewFrame,
                    CornerRadius = UDim.new(0, 6)
                })
                
                CreateInstance("UIStroke", {
                    Parent = PreviewFrame,
                    Color = Config.TextColor,
                    Thickness = 2,
                    Transparency = 0.5
                })
                
                -- Buttons
                local ApplyButton = CreateInstance("TextButton", {
                    Parent = PickerFrame,
                    BackgroundColor3 = Config.AccentColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 230),
                    Size = UDim2.new(0, 110, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = "Apply",
                    TextColor3 = Config.TextColor,
                    TextSize = 13
                })
                
                CreateInstance("UICorner", {
                    Parent = ApplyButton,
                    CornerRadius = UDim.new(0, 6)
                })
                
                local CancelButton = CreateInstance("TextButton", {
                    Parent = PickerFrame,
                    BackgroundColor3 = Config.SecondaryColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -120, 0, 230),
                    Size = UDim2.new(0, 110, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = "Cancel",
                    TextColor3 = Config.TextColor,
                    TextSize = 13
                })
                
                CreateInstance("UICorner", {
                    Parent = CancelButton,
                    CornerRadius = UDim.new(0, 6)
                })
                
                -- Slider functionality
                local function UpdateColor(slider, fill, valueLabel, colorComponent)
                    local dragging = false
                    
                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            local value = math.floor(pos * 255)
                            
                            fill.Size = UDim2.new(pos, 0, 1, 0)
                            valueLabel.Text = tostring(value)
                            
                            if colorComponent == "R" then
                                currentColor = Color3.fromRGB(value, currentColor.G * 255, currentColor.B * 255)
                            elseif colorComponent == "G" then
                                currentColor = Color3.fromRGB(currentColor.R * 255, value, currentColor.B * 255)
                            else
                                currentColor = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, value)
                            end
                            
                            PreviewFrame.BackgroundColor3 = currentColor
                        end
                    end)
                    
                    slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            local value = math.floor(pos * 255)
                            
                            fill.Size = UDim2.new(pos, 0, 1, 0)
                            valueLabel.Text = tostring(value)
                            
                            if colorComponent == "R" then
                                currentColor = Color3.fromRGB(value, currentColor.G * 255, currentColor.B * 255)
                            elseif colorComponent == "G" then
                                currentColor = Color3.fromRGB(currentColor.R * 255, value, currentColor.B * 255)
                            else
                                currentColor = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, value)
                            end
                            
                            PreviewFrame.BackgroundColor3 = currentColor
                        end
                    end)
                end
                
                UpdateColor(rSlider, rFill, rValue, "R")
                UpdateColor(gSlider, gFill, gValue, "G")
                UpdateColor(bSlider, bFill, bValue, "B")
                
                ApplyButton.MouseButton1Click:Connect(function()
                    ColorDisplay.BackgroundColor3 = currentColor
                    callback(currentColor)
                    PickerGui:Destroy()
                    pickerOpen = false
                end)
                
                CancelButton.MouseButton1Click:Connect(function()
                    PickerGui:Destroy()
                    pickerOpen = false
                end)
            end
            
            ColorDisplay.MouseButton1Click:Connect(CreateColorPickerPopup)
            
            UpdateDropdownSize()
            return ColorDisplay
        end
        
        -- Add Dropdown Selector
        function Dropdown:AddDropdownSelector(selectorName, options, default, callback)
            options = options or {"Option 1", "Option 2", "Option 3"}
            default = default or options[1]
            callback = callback or function() end
            
            local SelectorFrame = CreateInstance("Frame", {
                Name = "Selector",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = false
            })
            
            CreateInstance("UICorner", {
                Parent = SelectorFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local SelectorLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = SelectorFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -90, 1, 0),
                Font = Enum.Font.Gotham,
                Text = selectorName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SelectorButton = CreateInstance("TextButton", {
                Name = "Button",
                Parent = SelectorFrame,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -75, 0.5, -12),
                Size = UDim2.new(0, 65, 0, 24),
                Font = Enum.Font.Gotham,
                Text = default,
                TextColor3 = Config.TextColor,
                TextSize = 11,
                ClipsDescendants = true
            })
            
            CreateInstance("UICorner", {
                Parent = SelectorButton,
                CornerRadius = UDim.new(0, 4)
            })
            
            local Arrow = CreateInstance("TextLabel", {
                Parent = SelectorButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -15, 0, 0),
                Size = UDim2.new(0, 15, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = Config.AccentColor,
                TextSize = 10
            })
            
            local OptionsFrame = CreateInstance("Frame", {
                Name = "Options",
                Parent = SelectorFrame,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -75, 1, 5),
                Size = UDim2.new(0, 65, 0, 0),
                ClipsDescendants = true,
                ZIndex = 10
            })
            
            CreateInstance("UICorner", {
                Parent = OptionsFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            CreateInstance("UIListLayout", {
                Parent = OptionsFrame,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            local isOpen = false
            local selectedOption = default
            
            for _, option in ipairs(options) do
                local OptionButton = CreateInstance("TextButton", {
                    Name = option,
                    Parent = OptionsFrame,
                    BackgroundColor3 = Config.SecondaryColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = Config.TextColor,
                    TextSize = 11
                })
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(65, 65, 65)}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Config.SecondaryColor}, 0.2)
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    SelectorButton.Text = option
                    callback(option)
                    
                    isOpen = false
                    Tween(OptionsFrame, {Size = UDim2.new(0, 65, 0, 0)}, 0.2)
                    Tween(Arrow, {Rotation = 0}, 0.2)
                end)
            end
            
            SelectorButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    Tween(OptionsFrame, {Size = UDim2.new(0, 65, 0, #options * 25)}, 0.2)
                    Tween(Arrow, {Rotation = 180}, 0.2)
                else
                    Tween(OptionsFrame, {Size = UDim2.new(0, 65, 0, 0)}, 0.2)
                    Tween(Arrow, {Rotation = 0}, 0.2)
                end
            end)
            
            UpdateDropdownSize()
            return SelectorButton
        end
        
        -- Add Section
        function Dropdown:AddSection(sectionName)
            local Section = CreateInstance("Frame", {
                Name = "Section",
                Parent = DropdownContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25)
            })
            
            local Line = CreateInstance("Frame", {
                Name = "Line",
                Parent = Section,
                BackgroundColor3 = Config.AccentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0, 2)
            })
            
            CreateInstance("UIGradient", {
                Parent = Line,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Config.SecondaryColor),
                    ColorSequenceKeypoint.new(0.5, Config.AccentColor),
                    ColorSequenceKeypoint.new(1, Config.SecondaryColor)
                })
            })
            
            local SectionLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = Section,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 20),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Font = Enum.Font.GothamBold,
                Text = " " .. sectionName .. " ",
                TextColor3 = Config.AccentColor,
                TextSize = 12
            })
            
            -- Auto-size the label
            spawn(function()
                wait()
                local textSize = Services.TextService:GetTextSize(
                    SectionLabel.Text,
                    12,
                    Enum.Font.GothamBold,
                    Vector2.new(1000, 20)
                ).X
                SectionLabel.Size = UDim2.new(0, textSize + 10, 0, 20)
            end)
            
            UpdateDropdownSize()
            return Section
        end
        
        -- Add Info Box
        function Dropdown:AddInfoBox(infoText)
            local InfoFrame = CreateInstance("Frame", {
                Name = "InfoBox",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50)
            })
            
            CreateInstance("UICorner", {
                Parent = InfoFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            CreateInstance("UIStroke", {
                Parent = InfoFrame,
                Color = Config.AccentColor,
                Thickness = 2,
                Transparency = 0.7
            })
            
            local InfoIcon = CreateInstance("TextLabel", {
                Name = "Icon",
                Parent = InfoFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(0, 30, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "ℹ️",
                TextColor3 = Config.AccentColor,
                TextSize = 20
            })
            
            local InfoLabel = CreateInstance("TextLabel", {
                Name = "Text",
                Parent = InfoFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 35, 0, 5),
                Size = UDim2.new(1, -40, 1, -10),
                Font = Enum.Font.Gotham,
                Text = infoText,
                TextColor3 = Config.TextColor,
                TextSize = 11,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            })
            
            -- Auto-adjust height
            spawn(function()
                wait()
                local textHeight = Services.TextService:GetTextSize(
                    infoText,
                    11,
                    Enum.Font.Gotham,
                    Vector2.new(InfoLabel.AbsoluteSize.X, 1000)
                ).Y
                InfoFrame.Size = UDim2.new(1, 0, 0, math.max(50, textHeight + 15))
                UpdateDropdownSize()
            end)
            
            UpdateDropdownSize()
            return InfoFrame
        end
        
        -- Add Progress Bar
        function Dropdown:AddProgressBar(barName, maxValue)
            maxValue = maxValue or 100
            
            local ProgressFrame = CreateInstance("Frame", {
                Name = "ProgressBar",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            
            CreateInstance("UICorner", {
                Parent = ProgressFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ProgressLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = ProgressFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 15),
                Font = Enum.Font.Gotham,
                Text = barName,
                TextColor3 = Config.TextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ProgressBack = CreateInstance("Frame", {
                Name = "Back",
                Parent = ProgressFrame,
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 1, -15),
                Size = UDim2.new(1, -20, 0, 8)
            })
            
            CreateInstance("UICorner", {
                Parent = ProgressBack,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ProgressFill = CreateInstance("Frame", {
                Name = "Fill",
                Parent = ProgressBack,
                BackgroundColor3 = Config.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0)
            })
            
            CreateInstance("UICorner", {
                Parent = ProgressFill,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ProgressPercent = CreateInstance("TextLabel", {
                Name = "Percent",
                Parent = ProgressFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 5),
                Size = UDim2.new(0, 40, 0, 15),
                Font = Enum.Font.GothamBold,
                Text = "0%",
                TextColor3 = Config.AccentColor,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local ProgressBar = {
                Frame = ProgressFrame,
                Fill = ProgressFill,
                Percent = ProgressPercent,
                MaxValue = maxValue
            }
            
            function ProgressBar:SetValue(value)
                value = math.clamp(value, 0, self.MaxValue)
                local percent = (value / self.MaxValue)
                
                Tween(self.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.3)
                self.Percent.Text = math.floor(percent * 100) .. "%"
            end
            
            UpdateDropdownSize()
            return ProgressBar
        end
        
        -- Add Multi-Toggle (Radio Buttons)
        function Dropdown:AddMultiToggle(multiName, options, default, callback)
            options = options or {"Option 1", "Option 2", "Option 3"}
            default = default or options[1]
            callback = callback or function() end
            
            local MultiFrame = CreateInstance("Frame", {
                Name = "MultiToggle",
                Parent = DropdownContent,
                BackgroundColor3 = Config.SecondaryColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30 + (#options * 25))
            })
            
            CreateInstance("UICorner", {
                Parent = MultiFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local MultiLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Parent = MultiFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamSemibold,
                Text = multiName,
                TextColor3 = Config.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local selectedOption = default
            local optionButtons = {}
            
            for i, option in ipairs(options) do
                local OptionButton = CreateInstance("TextButton", {
                    Name = option,
                    Parent = MultiFrame,
                    BackgroundColor3 = Config.MainColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 30 + ((i - 1) * 25)),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. option,
                    TextColor3 = Config.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                CreateInstance("UICorner", {
                    Parent = OptionButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local Indicator = CreateInstance("Frame", {
                    Name = "Indicator",
                    Parent = OptionButton,
                    BackgroundColor3 = option == default and Config.AccentColor or Config.SecondaryColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -18, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                
                CreateInstance("UICorner", {
                    Parent = Indicator,
                    CornerRadius = UDim.new(1, 0)
                })
                
                optionButtons[option] = {Button = OptionButton, Indicator = Indicator}
                
                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    
                    for opt, data in pairs(optionButtons) do
                        if opt == option then
                            Tween(data.Indicator, {BackgroundColor3 = Config.AccentColor}, 0.2)
                        else
                            Tween(data.Indicator, {BackgroundColor3 = Config.SecondaryColor}, 0.2)
                        end
                    end
                    
                    callback(option)
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Config.MainColor}, 0.2)
                end)
            end
            
            UpdateDropdownSize()
            return MultiFrame
        end
        
        return Dropdown
    end
    
    return Window
end

return Library
