--[[
    NexusLib - Minimal Roblox UI Library
    Usage: local Nexus = loadstring(game:HttpGet("YOUR_RAW_URL"))()
    
    MIT License - Free to use and modify
]]

local NexusLib = {}
NexusLib.__index = NexusLib

-- ─── Services ───────────────────────────────────────────────────────────────
local Players         = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─── Theme ──────────────────────────────────────────────────────────────────
local Theme = {
    Background    = Color3.fromRGB(15, 15, 18),
    Surface       = Color3.fromRGB(22, 22, 27),
    Elevated      = Color3.fromRGB(30, 30, 38),
    Border        = Color3.fromRGB(45, 45, 58),
    Accent        = Color3.fromRGB(100, 160, 255),
    AccentDark    = Color3.fromRGB(60, 110, 200),
    Text          = Color3.fromRGB(225, 225, 235),
    TextMuted     = Color3.fromRGB(130, 130, 150),
    Success       = Color3.fromRGB(80, 200, 120),
    Warning       = Color3.fromRGB(255, 190, 80),
    Danger        = Color3.fromRGB(255, 90, 90),
    ToggleOn      = Color3.fromRGB(100, 160, 255),
    ToggleOff     = Color3.fromRGB(50, 50, 65),
}

-- ─── Utility Functions ───────────────────────────────────────────────────────
local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, frameStart
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── Notification System ─────────────────────────────────────────────────────
local NotifHolder

local function InitNotifications()
    NotifHolder = Create("Frame", {
        Name = "NexusNotifications",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -290, 0, 0),
        BackgroundTransparency = 1,
        Parent = CoreGui:FindFirstChild("NexusLibGui") or CoreGui,
    })
    Create("UIListLayout", {
        Parent = NotifHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6),
    })
end

function NexusLib:Notify(options)
    options = options or {}
    local title    = options.Title   or "Notification"
    local message  = options.Message or ""
    local ntype    = options.Type    or "Info"   -- Info, Success, Warning, Error
    local duration = options.Duration or 4

    local colors = {
        Info    = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error   = Theme.Danger,
    }
    local accent = colors[ntype] or Theme.Accent

    local notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifHolder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = notif })
    Create("UIStroke", { Color = accent, Thickness = 1, Parent = notif })

    -- Accent bar
    Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = notif,
    })

    Create("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -14, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    Create("TextLabel", {
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -18, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif,
    })

    -- Progress bar
    local progress = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = notif,
    })

    notif.Size = UDim2.new(1, 0, 0, 0)
    Tween(notif, { Size = UDim2.new(1, 0, 0, 70) }, 0.3)
    Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(notif, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, 0.3)
        task.wait(0.35)
        notif:Destroy()
    end)
end

-- ─── Window ──────────────────────────────────────────────────────────────────
function NexusLib:CreateWindow(options)
    options = options or {}
    local title    = options.Title   or "Nexus"
    local subtitle = options.Subtitle or ""
    local size     = options.Size    or UDim2.new(0, 520, 0, 380)
    local keybind  = options.ToggleKey or Enum.KeyCode.RightShift

    -- Root ScreenGui
    local gui = Create("ScreenGui", {
        Name = "NexusLibGui",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    NotifHolder = Create("Frame", {
        Name = "NexusNotifications",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -290, 0, 0),
        BackgroundTransparency = 1,
        Parent = gui,
    })
    Create("UIListLayout", {
        Parent = NotifHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6),
    })

    -- Main Window Frame
    local window = Create("Frame", {
        Name = "NexusWindow",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = gui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = window })
    Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = window })

    -- Drop shadow effect
    local shadow = Create("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = window,
    })

    -- Titlebar
    local titlebar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = window,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = titlebar })
    -- Cover bottom corners of titlebar
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = titlebar,
    })

    -- Accent dot
    Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 14, 0.5, -3),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = titlebar,
    }):SetAttribute("UICorner", true)
    do
        local dot = titlebar:FindFirstChild("Frame")
        Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = dot })
    end

    Create("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titlebar,
    })

    if subtitle ~= "" then
        Create("TextLabel", {
            Text = subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Theme.TextMuted,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 24),
            Size = UDim2.new(0, 200, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = titlebar,
        })
    end

    -- Close / Minimize buttons
    local function makeBtn(pos, color, icon)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 22, 0, 22),
            Position = pos,
            BackgroundColor3 = color,
            Text = "",
            BorderSizePixel = 0,
            Parent = titlebar,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
        Create("TextLabel", {
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            TextTransparency = 0.4,
            Parent = btn,
        })
        return btn
    end

    local closeBtn = makeBtn(UDim2.new(1, -32, 0.5, -11), Color3.fromRGB(255, 90, 90), "✕")
    local minBtn   = makeBtn(UDim2.new(1, -60, 0.5, -11), Color3.fromRGB(255, 190, 80), "−")

    MakeDraggable(window, titlebar)

    -- Tab system
    local tabBar = Create("Frame", {
        Size = UDim2.new(0, 130, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = window,
    })
    Create("Frame", { -- right border
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = tabBar,
    })
    local tabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        Parent = tabBar,
    })
    Create("UIListLayout", {
        Parent = tabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = tabList,
    })

    local contentArea = Create("Frame", {
        Size = UDim2.new(1, -130, 1, -44),
        Position = UDim2.new(0, 130, 0, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = window,
    })

    local tabs = {}
    local activeTab = nil

    local minimized = false
    local origSize = size

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(window, { Size = UDim2.new(0, size.X.Offset, 0, 44) }, 0.3)
        else
            Tween(window, { Size = size }, 0.3)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(window, { Size = UDim2.new(0, size.X.Offset, 0, 0), Position = UDim2.new(window.Position.X.Scale, window.Position.X.Offset, window.Position.Y.Scale, window.Position.Y.Offset + size.Y.Offset/2) }, 0.25)
        task.wait(0.3)
        gui:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == keybind then
            window.Visible = not window.Visible
        end
    end)

    -- ── Window Object ──────────────────────────────────────────────────────
    local WindowObj = {}

    function WindowObj:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or ""

        -- Tab button
        local tabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 1,
            Text = "",
            BorderSizePixel = 0,
            Parent = tabList,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tabBtn })

        local tabLabel = Create("TextLabel", {
            Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.TextMuted,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabBtn,
        })

        local indicator = Create("Frame", {
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent = tabBtn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = indicator })

        -- Tab content frame
        local tabContent = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Border,
            Visible = false,
            Parent = contentArea,
        })
        Create("UIListLayout", {
            Parent = tabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent,
        })

        local function activateTab()
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                Tween(t.Label,       { TextColor3 = Theme.TextMuted }, 0.15)
                Tween(t.Button,      { BackgroundTransparency = 1 }, 0.15)
                Tween(t.Indicator,   { BackgroundTransparency = 1 }, 0.15)
            end
            tabContent.Visible = true
            Tween(tabLabel,    { TextColor3 = Theme.Text }, 0.15)
            Tween(tabBtn,      { BackgroundTransparency = 0 }, 0.15)
            Tween(indicator,   { BackgroundTransparency = 0 }, 0.15)
            activeTab = tabName
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        local tabEntry = { Content = tabContent, Label = tabLabel, Button = tabBtn, Indicator = indicator }
        table.insert(tabs, tabEntry)

        if #tabs == 1 then activateTab() end

        -- ── Tab Element Builders ───────────────────────────────────────────
        local TabObj = {}

        -- Section label
        function TabObj:AddSection(name)
            Create("TextLabel", {
                Text = string.upper(name),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Theme.TextMuted,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #tabContent:GetChildren(),
                Parent = tabContent,
            })
            -- Divider
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                LayoutOrder = #tabContent:GetChildren(),
                Parent = tabContent,
            })
        end

        -- Generic element container helper
        local function MakeElement(labelText, height)
            local row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, height or 36),
                BackgroundColor3 = Theme.Elevated,
                BorderSizePixel = 0,
                LayoutOrder = #tabContent:GetChildren(),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })
            if labelText then
                Create("TextLabel", {
                    Text = labelText,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.55, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
            end
            return row
        end

        -- ── Button ─────────────────────────────────────────────────────────
        function TabObj:AddButton(opts)
            opts = opts or {}
            local row = MakeElement(opts.Name, 36)
            local btn = Create("TextButton", {
                Text = opts.ButtonText or "Click",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new(0, 80, 0, 22),
                Position = UDim2.new(1, -90, 0.5, -11),
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })

            btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Theme.AccentDark }, 0.12) end)
            btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.12) end)
            btn.MouseButton1Click:Connect(function()
                if opts.Callback then opts.Callback() end
            end)
        end

        -- ── Toggle ─────────────────────────────────────────────────────────
        function TabObj:AddToggle(opts)
            opts = opts or {}
            local state = opts.Default or false
            local row = MakeElement(opts.Name, 36)

            local track = Create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

            local knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

            local clickRegion = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = track,
            })

            clickRegion.MouseButton1Click:Connect(function()
                state = not state
                Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                Tween(knob, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.2)
                if opts.Callback then opts.Callback(state) end
            end)

            return {
                Set = function(_, val)
                    state = val
                    Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                    Tween(knob, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.2)
                    if opts.Callback then opts.Callback(state) end
                end
            }
        end

        -- ── Slider ─────────────────────────────────────────────────────────
        function TabObj:AddSlider(opts)
            opts = opts or {}
            local min   = opts.Min     or 0
            local max   = opts.Max     or 100
            local value = opts.Default or min
            local row   = MakeElement(nil, 50)

            Create("TextLabel", {
                Text = opts.Name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(0.7, 0, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local valLabel = Create("TextLabel", {
                Text = tostring(value),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Theme.Accent,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 6),
                Size = UDim2.new(0, 40, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })

            local track = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 4),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

            local fill = Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

            local knob = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

            local sliding = false
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + rel * (max - min))
                    valLabel.Text = tostring(value)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, -6, 0.5, -6)
                    if opts.Callback then opts.Callback(value) end
                end
            end)

            return {
                Set = function(_, val)
                    value = math.clamp(val, min, max)
                    local rel = (value - min) / (max - min)
                    valLabel.Text = tostring(value)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, -6, 0.5, -6)
                    if opts.Callback then opts.Callback(value) end
                end
            }
        end

        -- ── Dropdown ───────────────────────────────────────────────────────
        function TabObj:AddDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local selected = opts.Default or (items[1] or "Select...")
            local open    = false

            local row = MakeElement(opts.Name, 36)

            local dropBtn = Create("TextButton", {
                Text = selected .. "  ▾",
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(0, 130, 0, 22),
                Position = UDim2.new(1, -140, 0.5, -11),
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = dropBtn })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = dropBtn })

            local menuFrame = Create("Frame", {
                Size = UDim2.new(0, 130, 0, math.min(#items, 5) * 26 + 4),
                Position = UDim2.new(1, -140, 1, 2),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                ZIndex = 10,
                Visible = false,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = menuFrame })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = menuFrame })
            Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = menuFrame })
            local menuList = Create("UIListLayout", { Parent = menuFrame, SortOrder = Enum.SortOrder.LayoutOrder })

            for _, item in ipairs(items) do
                local itemBtn = Create("TextButton", {
                    Text = item,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.Text,
                    BackgroundColor3 = Theme.Surface,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26),
                    BorderSizePixel = 0,
                    ZIndex = 11,
                    Parent = menuFrame,
                })
                itemBtn.MouseEnter:Connect(function() Tween(itemBtn, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Elevated }, 0.1) end)
                itemBtn.MouseLeave:Connect(function() Tween(itemBtn, { BackgroundTransparency = 1 }, 0.1) end)
                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    dropBtn.Text = item .. "  ▾"
                    menuFrame.Visible = false
                    open = false
                    if opts.Callback then opts.Callback(selected) end
                end)
            end

            dropBtn.MouseButton1Click:Connect(function()
                open = not open
                menuFrame.Visible = open
            end)

            return {
                Set = function(_, val)
                    selected = val
                    dropBtn.Text = val .. "  ▾"
                    if opts.Callback then opts.Callback(val) end
                end,
                Get = function() return selected end,
            }
        end

        -- ── Text Input ─────────────────────────────────────────────────────
        function TabObj:AddTextInput(opts)
            opts = opts or {}
            local row = MakeElement(opts.Name, 36)

            local box = Create("TextBox", {
                Text = opts.Default or "",
                PlaceholderText = opts.Placeholder or "Type here...",
                PlaceholderColor3 = Theme.TextMuted,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(0, 150, 0, 22),
                Position = UDim2.new(1, -160, 0.5, -11),
                ClearTextOnFocus = false,
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = box })
            Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = box })

            box.Focused:Connect(function() Tween(box, { BackgroundColor3 = Theme.Elevated }, 0.15) end)
            box.FocusLost:Connect(function(enter)
                Tween(box, { BackgroundColor3 = Theme.Surface }, 0.15)
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)

            return {
                Get = function() return box.Text end,
                Set = function(_, val) box.Text = val end,
            }
        end

        -- ── Keybind ────────────────────────────────────────────────────────
        function TabObj:AddKeybind(opts)
            opts = opts or {}
            local current = opts.Default or Enum.KeyCode.Unknown
            local listening = false
            local row = MakeElement(opts.Name, 36)

            local btn = Create("TextButton", {
                Text = tostring(current.Name):gsub("^Enum%.KeyCode%.", ""),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Theme.Accent,
                BackgroundColor3 = Theme.Surface,
                Size = UDim2.new(0, 90, 0, 22),
                Position = UDim2.new(1, -100, 0.5, -11),
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = btn })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = btn })

            btn.MouseButton1Click:Connect(function()
                listening = true
                btn.Text = "..."
                btn.TextColor3 = Theme.Warning
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        current = input.KeyCode
                        btn.Text = tostring(current.Name):gsub("^Enum%.KeyCode%.", "")
                        btn.TextColor3 = Theme.Accent
                        listening = false
                        if opts.Callback then opts.Callback(current) end
                    end
                elseif input.KeyCode == current and opts.OnPress then
                    opts.OnPress()
                end
            end)

            return { Get = function() return current end }
        end

        -- ── Color Picker ───────────────────────────────────────────────────
        function TabObj:AddColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or Color3.fromRGB(255, 255, 255)
            local open  = false
            local hue, sat, val = color:ToHSV()

            local row = MakeElement(opts.Name, 36)

            local preview = Create("Frame", {
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(1, -32, 0.5, -11),
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = preview })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = preview })

            local clickRegion = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = preview,
            })

            -- Picker panel
            local panel = Create("Frame", {
                Size = UDim2.new(0, 200, 0, 170),
                Position = UDim2.new(1, -210, 1, 4),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                ZIndex = 15,
                Visible = false,
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = panel })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = panel })

            -- SV Canvas
            local canvas = Create("ImageLabel", {
                Size = UDim2.new(1, -20, 0, 110),
                Position = UDim2.new(0, 10, 0, 10),
                Image = "rbxassetid://4155801252",
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 16,
                Parent = panel,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = canvas })

            local svKnob = Create("Frame", {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                ZIndex = 17,
                Position = UDim2.new(sat, -5, 1 - val, -5),
                Parent = canvas,
            })
            Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = svKnob })
            Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, Parent = svKnob })

            -- Hue bar
            local hueBar = Create("ImageLabel", {
                Size = UDim2.new(1, -20, 0, 14),
                Position = UDim2.new(0, 10, 0, 126),
                Image = "rbxassetid://4155801252",
                ImageRectOffset = Vector2.new(0, 4),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                ZIndex = 16,
                Parent = panel,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hueBar })

            -- Use gradient for hue
            local hueGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
                    ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
                    ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
                    ColorSequenceKeypoint.new(1,   Color3.fromHSV(1, 1, 1)),
                }),
                Parent = hueBar,
            })

            local hueKnob = Create("Frame", {
                Size = UDim2.new(0, 8, 1, 0),
                Position = UDim2.new(hue, -4, 0, 0),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                ZIndex = 17,
                Parent = hueBar,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = hueKnob })
            Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, Parent = hueKnob })

            -- Hex label
            local hexLabel = Create("TextBox", {
                Text = "#" .. string.format("%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Elevated,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 144),
                BorderSizePixel = 0,
                ZIndex = 16,
                ClearTextOnFocus = false,
                Parent = panel,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hexLabel })

            local function updateColor()
                color = Color3.fromHSV(hue, sat, val)
                preview.BackgroundColor3 = color
                canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                hexLabel.Text = "#" .. string.format("%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                if opts.Callback then opts.Callback(color) end
            end

            local svDrag, hueDrag = false, false
            canvas.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end end)
            hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false; hueDrag = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if svDrag then
                    sat = math.clamp((Mouse.X - canvas.AbsolutePosition.X) / canvas.AbsoluteSize.X, 0, 1)
                    val = 1 - math.clamp((Mouse.Y - canvas.AbsolutePosition.Y) / canvas.AbsoluteSize.Y, 0, 1)
                    svKnob.Position = UDim2.new(sat, -5, 1 - val, -5)
                    updateColor()
                elseif hueDrag then
                    hue = math.clamp((Mouse.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hueKnob.Position = UDim2.new(hue, -4, 0, 0)
                    updateColor()
                end
            end)

            clickRegion.MouseButton1Click:Connect(function()
                open = not open
                panel.Visible = open
            end)

            return {
                Get = function() return color end,
                Set = function(_, c)
                    color = c
                    hue, sat, val = c:ToHSV()
                    preview.BackgroundColor3 = c
                    updateColor()
                end
            }
        end

        return TabObj
    end -- AddTab

    return WindowObj
end

return NexusLib
