--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                   StarlightUI v1.0                        ║
    ║                A Modern Lua GUI Toolkit                   ║
    ║                  Inspired by BloxHub                      ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local StarlightUI = {}
StarlightUI.__index = StarlightUI

-- ┬─┐┌─┐┌┬┐┌─┐┬─┐┌─┐┌─┐
-- ├┬┘│ │ │ │ │├┬┘├┤ └─┐
-- ┴└─└─┘ ┴ └─┘┴└─└─┘└─┘

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ╔═╗┌─┐┌┐┌┌─┐┬ ┬
-- ╚═╗├─┤│││├┤ │││
-- ╚═╝┴ ┴┘└┘└─┘└┴┘

local function tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-- ╔═╗┬ ┬┌─┐┬  ┌─┐
-- ║ ╦│ │├─┤│  ├┤
-- ╚═╝└─┘┴ ┴┴─┘└─┘

function StarlightUI.new(config)
    local self = setmetatable({}, StarlightUI)

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "StarlightUI_Root"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

    self.theme = {
        Background = Color3.fromRGB(25, 25, 25),
        Primary = Color3.fromRGB(35, 35, 35),
        Secondary = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(80, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(170, 170, 170)
    }

    if config and config.theme then
        for i, v in pairs(config.theme) do
            self.theme[i] = v
        end
    end

    return self
end

function StarlightUI:createWindow(config)
    local window = {}
    window.tabs = {}
    window.activeTab = nil

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Window"
    mainFrame.Size = config.size or UDim2.new(0, 500, 0, 380)
    mainFrame.Position = config.position or UDim2.new(0.5, -250, 0.5, -190)
    mainFrame.BackgroundColor3 = self.theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = self.screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = self.theme.Primary
    header.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -15, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.title or "StarlightUI"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = self.theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = self.theme.Primary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, -40)
    contentContainer.Position = UDim2.new(0, 120, 0, 40)
    contentContainer.BackgroundColor3 = self.theme.Background
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame

    -- Make Draggable
    local dragging = false
    local dragInput, mousePos, framePos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - mousePos
            mainFrame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)

    -- Window Methods
    function window:createTab(title)
        local tab = {}

        local button = Instance.new("TextButton")
        button.Name = title
        button.Size = UDim2.new(1, -10, 0, 30)
        button.BackgroundColor3 = self.theme.Secondary
        button.Text = title
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 14
        button.TextColor3 = self.theme.Text
        button.Parent = tabContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button

        local content = Instance.new("ScrollingFrame")
        content.Name = title .. "_Content"
        content.Size = UDim2.new(1, -20, 1, -10)
        content.Position = UDim2.new(0, 10, 0, 5)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 3
        content.Visible = false
        content.Parent = contentContainer

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = content

        local function activate()
            for _, t in pairs(window.tabs) do
                t.content.Visible = false
                tween(t.button, { BackgroundColor3 = self.theme.Secondary }, 0.15)
            end
            content.Visible = true
            tween(button, { BackgroundColor3 = self.theme.Accent }, 0.15)
            window.activeTab = tab
        end

        button.MouseButton1Click:Connect(activate)

        table.insert(window.tabs, {button = button, content = content})

        if not window.activeTab then
            activate()
        end

        function tab:addButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Name = text
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundColor3 = self.theme.Primary
            btn.Text = text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextColor3 = self.theme.Text
            btn.Parent = content

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn

            btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = self.theme.Accent }, 0.15) end)
            btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = self.theme.Primary }, 0.15) end)
            if callback then btn.MouseButton1Click:Connect(callback) end

            return btn
        end

        function tab:addToggle(text, defaultValue, callback)
            local toggled = defaultValue or false

            local container = Instance.new("Frame")
            container.Name = text
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundColor3 = self.theme.Primary
            container.BorderSizePixel = 0
            container.Parent = content

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = container

            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.Text = text
            label.TextSize = 14
            label.TextColor3 = self.theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local switch = Instance.new("TextButton")
            switch.Name = "Switch"
            switch.Size = UDim2.new(0, 40, 0, 20)
            switch.Position = UDim2.new(1, -45, 0.5, -10)
            switch.BackgroundColor3 = toggled and self.theme.Accent or self.theme.Secondary
            switch.Text = ""
            switch.Parent = container

            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(0, 10)
            switchCorner.Parent = switch

            local knob = Instance.new("Frame")
            knob.Name = "Knob"
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.Parent = switch

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(0, 8)
            knobCorner.Parent = knob

            switch.MouseButton1Click:Connect(function()
                toggled = not toggled
                tween(switch, { BackgroundColor3 = toggled and self.theme.Accent or self.theme.Secondary }, 0.2)
                tween(knob, { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.2)
                if callback then pcall(callback, toggled) end
            end)

            return {
                getValue = function() return toggled end,
                setValue = function(value)
                    toggled = value
                    tween(switch, { BackgroundColor3 = toggled and self.theme.Accent or self.theme.Secondary }, 0.2)
                    tween(knob, { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.2)
                end
            }
        end

        return tab
    end

    return window
end

return StarlightUI
