--[[
    ██╗    ██╗██╗███╗   ██╗██╗  ██╗██████╗     ██╗  ██╗██████╗
    ██║    ██║██║████╗  ██║╚██╗██╔╝██╔══██╗    ██║  ██║██╔══██╗
    ██║ █╗ ██║██║██╔██╗ ██║ ╚███╔╝ ██████╔╝    ██║  ██║██║  ██║
    ██║███╗██║██║██║╚██╗██║ ██╔██╗ ██╔═══╝     ██║  ██║██║  ██║
    ╚███╔███╔╝██║██║ ╚████║██╔╝ ██╗██║         ╚██████╔╝██████╔╝
     ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝          ╚═════╝ ╚═════╝

    Windows XP UI Library for Roblox
    Version : 0.0.1
    License : MIT

    Usage:
        local WinXP = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
        local Window = WinXP:CreateWindow({ Title = "My Script" })
        local Tab = Window:AddTab("Main")
        Tab:AddButton({ Text = "Click Me", Callback = function() print("clicked") end })
]]

local WinXP = {}
WinXP.__index = WinXP

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

-- ════════════════════════════════════════════════════════════════
--  THEME  (Windows XP Luna Blue)
-- ════════════════════════════════════════════════════════════════
local Theme = {
    -- Title bar
    TitleGradLeft      = Color3.fromRGB(10,  36,  106),
    TitleGradRight     = Color3.fromRGB(166, 202, 240),
    TitleText          = Color3.fromRGB(255, 255, 255),
    TitleShadow        = Color3.fromRGB(0,   0,   80),

    -- Window chrome
    WindowOutline      = Color3.fromRGB(10,  36,  106),
    WindowBody         = Color3.fromRGB(236, 233, 216),

    -- Classic 3-D border shades
    BorderBright       = Color3.fromRGB(255, 255, 255),
    BorderLight        = Color3.fromRGB(214, 211, 196),
    BorderDark         = Color3.fromRGB(172, 168, 153),
    BorderDarker       = Color3.fromRGB(113, 111, 100),

    -- Buttons
    ButtonFace         = Color3.fromRGB(236, 233, 216),
    ButtonText         = Color3.fromRGB(0,   0,   0),
    ButtonHover        = Color3.fromRGB(224, 222, 210),
    ButtonPressed      = Color3.fromRGB(204, 201, 188),

    -- Window-control buttons
    CtrlBlue           = Color3.fromRGB(82,  148, 224),
    CtrlBlueLight      = Color3.fromRGB(148, 200, 248),
    CtrlRed            = Color3.fromRGB(199, 60,  20),
    CtrlRedLight       = Color3.fromRGB(244, 110, 70),

    -- Tabs
    TabActive          = Color3.fromRGB(236, 233, 216),
    TabInactive        = Color3.fromRGB(199, 196, 180),
    TabText            = Color3.fromRGB(0,   0,   0),
    TabBorder          = Color3.fromRGB(113, 111, 100),

    -- Input / Textbox
    InputBg            = Color3.fromRGB(255, 255, 255),
    InputText          = Color3.fromRGB(0,   0,   0),
    InputPlaceholder   = Color3.fromRGB(160, 160, 160),

    -- Slider
    SliderTrack        = Color3.fromRGB(255, 255, 255),
    SliderFill         = Color3.fromRGB(49,  106, 197),
    SliderThumb        = Color3.fromRGB(236, 233, 216),

    -- Checkbox / Toggle
    CheckBg            = Color3.fromRGB(255, 255, 255),
    CheckMark          = Color3.fromRGB(0,   0,   0),

    -- Section header
    SectionText        = Color3.fromRGB(10,  36,  106),
    SectionLine        = Color3.fromRGB(172, 168, 153),

    -- Label
    LabelText          = Color3.fromRGB(0,   0,   0),

    -- Dropdown list
    DropBg             = Color3.fromRGB(255, 255, 255),
    DropHover          = Color3.fromRGB(49,  106, 197),
    DropText           = Color3.fromRGB(0,   0,   0),
    DropHoverText      = Color3.fromRGB(255, 255, 255),

    -- Scrollbar
    ScrollThumb        = Color3.fromRGB(172, 168, 153),
    ScrollBg           = Color3.fromRGB(214, 211, 196),

    -- Notification
    NotifBg            = Color3.fromRGB(236, 233, 216),
    NotifText          = Color3.fromRGB(0,   0,   0),
}

-- ════════════════════════════════════════════════════════════════
--  INTERNAL HELPERS
-- ════════════════════════════════════════════════════════════════

local function Create(class, props)
    local obj = Instance.new(class)
    local parent, children
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        elseif k == "Children" then
            children = v
        else
            obj[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do c.Parent = obj end
    end
    if parent then obj.Parent = parent end
    return obj
end

-- Raised (convex) 3-D border — 2 pixel thick double edge
local function RaisedBorder(f, z)
    z = z or (f.ZIndex + 1)
    local function edge(size, pos, col)
        return Create("Frame", {
            Size = size, Position = pos,
            BackgroundColor3 = col, BorderSizePixel = 0,
            ZIndex = z, Parent = f,
        })
    end
    -- outer bright TL
    edge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Theme.BorderBright)
    edge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Theme.BorderBright)
    -- inner light TL
    edge(UDim2.new(1,-1,0,1),UDim2.new(0,1,0,1),  Theme.BorderLight)
    edge(UDim2.new(0,1,1,-1),UDim2.new(0,1,0,1),  Theme.BorderLight)
    -- outer dark BR
    edge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Theme.BorderDarker)
    edge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Theme.BorderDarker)
    -- inner shadow BR
    edge(UDim2.new(1,-2,0,1),UDim2.new(0,1,1,-2), Theme.BorderDark)
    edge(UDim2.new(0,1,1,-2),UDim2.new(1,-2,0,1), Theme.BorderDark)
end

-- Sunken (concave) 3-D border — used for inputs / tracks
local function SunkenBorder(f, z)
    z = z or (f.ZIndex + 1)
    local function edge(size, pos, col)
        return Create("Frame", {
            Size = size, Position = pos,
            BackgroundColor3 = col, BorderSizePixel = 0,
            ZIndex = z, Parent = f,
        })
    end
    -- outer dark TL
    edge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Theme.BorderDarker)
    edge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Theme.BorderDarker)
    -- inner shadow TL
    edge(UDim2.new(1,-1,0,1),UDim2.new(0,1,0,1),  Theme.BorderDark)
    edge(UDim2.new(0,1,1,-1),UDim2.new(0,1,0,1),  Theme.BorderDark)
    -- outer bright BR
    edge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Theme.BorderBright)
    edge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Theme.BorderBright)
    -- inner light BR
    edge(UDim2.new(1,-2,0,1),UDim2.new(0,1,1,-2), Theme.BorderLight)
    edge(UDim2.new(0,1,1,-2),UDim2.new(1,-2,0,1), Theme.BorderLight)
end

-- Makes a Frame draggable via a handle
local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- Resolve where to parent the ScreenGui (executor-aware)
local function GetGuiParent()
    if gethui then return gethui() end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        local ok2 = pcall(function()
            local t = Instance.new("ScreenGui")
            t.Parent = core
            t:Destroy()
        end)
        if ok2 then return core end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ════════════════════════════════════════════════════════════════
--  WINDOW  CONSTRUCTOR
-- ════════════════════════════════════════════════════════════════
function WinXP:CreateWindow(config)
    config = config or {}

    local title    = config.Title    or "WinXP UI"
    local size     = config.Size     or UDim2.new(0, 540, 0, 420)
    local position = config.Position or UDim2.new(0.5, -(size.X.Offset/2), 0.5, -(size.Y.Offset/2))
    local icon     = config.Icon     or ""
    local key      = config.ToggleKey or Enum.KeyCode.RightControl

    -- ── ScreenGui ──────────────────────────────────────────────
    local screenGui = Create("ScreenGui", {
        Name             = "WinXP_" .. title:gsub("%s+", "_"),
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Global,
        Parent           = GetGuiParent(),
    })

    -- ── Outer window frame ─────────────────────────────────────
    local winFrame = Create("Frame", {
        Name             = "WinFrame",
        Size             = size,
        Position         = position,
        BackgroundColor3 = Theme.WindowOutline,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = screenGui,
    })
    RaisedBorder(winFrame, 11)

    -- ── Inner body ─────────────────────────────────────────────
    local body = Create("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, -4, 1, -4),
        Position         = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Theme.WindowBody,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = winFrame,
    })

    -- ── Title bar ──────────────────────────────────────────────
    local titleBar = Create("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.TitleGradLeft,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = body,
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.TitleGradLeft),
            ColorSequenceKeypoint.new(1, Theme.TitleGradRight),
        }),
        Rotation = 0,
        Parent   = titleBar,
    })

    -- Title icon (optional)
    if icon ~= "" then
        Create("ImageLabel", {
            Size                 = UDim2.new(0, 16, 0, 16),
            Position             = UDim2.new(0, 4, 0.5, -8),
            BackgroundTransparency = 1,
            Image                = icon,
            ZIndex               = 12,
            Parent               = titleBar,
        })
    end

    -- Title text (with drop-shadow trick)
    Create("TextLabel", {  -- shadow
        Size               = UDim2.new(1, -90, 1, 0),
        Position           = UDim2.new(0, (icon ~= "" and 26 or 6) + 1, 0, 1),
        BackgroundTransparency = 1,
        Text               = title,
        Font               = Enum.Font.GothamBold,
        TextSize           = 13,
        TextColor3         = Theme.TitleShadow,
        TextTransparency   = 0.45,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 11,
        Parent             = titleBar,
    })
    Create("TextLabel", {  -- main
        Size               = UDim2.new(1, -90, 1, 0),
        Position           = UDim2.new(0, (icon ~= "" and 26 or 6), 0, 0),
        BackgroundTransparency = 1,
        Text               = title,
        Font               = Enum.Font.GothamBold,
        TextSize           = 13,
        TextColor3         = Theme.TitleText,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 12,
        Parent             = titleBar,
    })

    -- ── Window control buttons ─────────────────────────────────
    local ctrlHolder = Create("Frame", {
        Size               = UDim2.new(0, 68, 0, 22),
        Position           = UDim2.new(1, -72, 0.5, -11),
        BackgroundTransparency = 1,
        ZIndex             = 12,
        Parent             = titleBar,
    })

    local function MakeCtrlBtn(xOff, w, text, gradL, gradR)
        local btn = Create("TextButton", {
            Size             = UDim2.new(0, w, 0, 19),
            Position         = UDim2.new(0, xOff, 0, 0),
            BackgroundColor3 = gradL,
            BorderSizePixel  = 0,
            Text             = text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            TextColor3       = Color3.fromRGB(255, 255, 255),
            ZIndex           = 13,
            Parent           = ctrlHolder,
        })
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, gradL),
                ColorSequenceKeypoint.new(1, gradR),
            }),
            Rotation = 90,
            Parent   = btn,
        })
        RaisedBorder(btn, 14)
        return btn
    end

    local minBtn   = MakeCtrlBtn(0,  19, "─",  Theme.CtrlBlue,  Theme.CtrlBlueLight)
    local maxBtn   = MakeCtrlBtn(22, 19, "□",  Theme.CtrlBlue,  Theme.CtrlBlueLight)
    local closeBtn = MakeCtrlBtn(44, 22, "✕",  Theme.CtrlRed,   Theme.CtrlRedLight)

    -- ── Dragging ───────────────────────────────────────────────
    MakeDraggable(titleBar, winFrame)

    -- ── Minimize / Maximize / Close logic ──────────────────────
    local minimized = false

    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(winFrame, TweenInfo.new(0.15), { Size = UDim2.new(0, size.X.Offset, 0, 0) }):Play()
        task.delay(0.15, function() screenGui:Destroy() end)
    end)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized
            and UDim2.new(0, size.X.Offset, 0, 30)
            or size
        TweenService:Create(winFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Size = targetSize }):Play()
    end)

    maxBtn.MouseButton1Click:Connect(function()
        -- Toggle between original size and viewport fill
        local vp = workspace.CurrentCamera.ViewportSize
        if winFrame.Size == size then
            TweenService:Create(winFrame, TweenInfo.new(0.18), {
                Size     = UDim2.new(0, vp.X - 4, 0, vp.Y - 4),
                Position = UDim2.new(0, 2, 0, 2),
            }):Play()
        else
            TweenService:Create(winFrame, TweenInfo.new(0.18), {
                Size     = size,
                Position = position,
            }):Play()
        end
    end)

    -- Toggle visibility keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == key then
            winFrame.Visible = not winFrame.Visible
        end
    end)

    -- ── Tab bar ────────────────────────────────────────────────
    local tabBar = Create("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, 0, 0, 24),
        Position         = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Theme.TabInactive,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = body,
    })
    Create("Frame", {  -- bottom border line
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.TabBorder,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = tabBar,
    })
    Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Horizontal,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Padding          = UDim.new(0, 0),
        Parent           = tabBar,
    })

    -- ── Scrollable content canvas ──────────────────────────────
    local contentScroll = Create("ScrollingFrame", {
        Name                  = "ContentScroll",
        Size                  = UDim2.new(1, 0, 1, -54),
        Position              = UDim2.new(0, 0, 0, 53),
        BackgroundColor3      = Theme.WindowBody,
        BorderSizePixel       = 0,
        ScrollBarThickness    = 8,
        ScrollBarImageColor3  = Theme.ScrollThumb,
        CanvasSize            = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
        ZIndex                = 11,
        ClipsDescendants      = true,
        Parent                = body,
    })
    Create("UIPadding", {
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
        PaddingTop    = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent        = contentScroll,
    })

    -- ── Notification holder (top-right of screen) ──────────────
    local notifHolder = Create("Frame", {
        Name               = "NotifHolder",
        Size               = UDim2.new(0, 290, 1, -16),
        Position           = UDim2.new(1, -300, 0, 8),
        BackgroundTransparency = 1,
        ZIndex             = 200,
        Parent             = screenGui,
    })
    Create("UIListLayout", {
        SortOrder          = Enum.SortOrder.LayoutOrder,
        VerticalAlignment  = Enum.VerticalAlignment.Bottom,
        Padding            = UDim.new(0, 6),
        Parent             = notifHolder,
    })

    -- ════════════════════════════════════════════════════════════
    --  WINDOW  OBJECT
    -- ════════════════════════════════════════════════════════════
    local Window = {}
    Window._tabButtons  = {}
    Window._tabFrames   = {}
    Window._activeTab   = nil
    Window._tabCount    = 0
    Window._notifSeq    = 0
    Window._gui         = screenGui
    Window._notifHolder = notifHolder
    Window._winFrame    = winFrame

    -- ── Internal: switch active tab ────────────────────────────
    function Window:_SwitchTab(idx)
        for i, frm in ipairs(self._tabFrames) do
            frm.Visible = (i == idx)
        end
        for i, btn in ipairs(self._tabButtons) do
            local active = (i == idx)
            btn.BackgroundColor3 = active and Theme.TabActive or Theme.TabInactive
            btn.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
            -- flush-bottom illusion: hide the 1px bottom edge when active
            local stripe = btn:FindFirstChild("_ActiveStripe")
            if active then
                if not stripe then
                    stripe = Create("Frame", {
                        Name             = "_ActiveStripe",
                        Size             = UDim2.new(1, 0, 0, 2),
                        Position         = UDim2.new(0, 0, 1, -1),
                        BackgroundColor3 = Theme.TabActive,
                        BorderSizePixel  = 0,
                        ZIndex           = 14,
                        Parent           = btn,
                    })
                else
                    stripe.Visible = true
                end
            else
                if stripe then stripe.Visible = false end
            end
        end
        self._activeTab = idx
    end

    -- ════════════════════════════════════════════════════════════
    --  AddTab
    -- ════════════════════════════════════════════════════════════
    function Window:AddTab(name)
        self._tabCount = self._tabCount + 1
        local idx = self._tabCount

        -- Tab button
        local tabBtn = Create("TextButton", {
            Name             = "TabBtn_" .. name,
            Size             = UDim2.new(0, math.max(64, #name * 8 + 20), 1, 0),
            BackgroundColor3 = Theme.TabInactive,
            BorderSizePixel  = 0,
            Text             = name,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            TextColor3       = Theme.TabText,
            LayoutOrder      = idx,
            ZIndex           = 12,
            Parent           = tabBar,
        })
        -- Right separator
        Create("Frame", {
            Size             = UDim2.new(0, 1, 1, 0),
            Position         = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = Theme.TabBorder,
            BorderSizePixel  = 0,
            ZIndex           = 13,
            Parent           = tabBtn,
        })
        -- Left separator (first tab gets a left edge too)
        if idx == 1 then
            Create("Frame", {
                Size             = UDim2.new(0, 1, 1, 0),
                Position         = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.TabBorder,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = tabBtn,
            })
        end

        -- Tab content frame (inside the scroll canvas)
        local tabFrame = Create("Frame", {
            Name               = "TabFrame_" .. name,
            Size               = UDim2.new(1, 0, 0, 0),
            AutomaticSize      = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel    = 0,
            Visible            = false,
            ZIndex             = 12,
            Parent             = contentScroll,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 5),
            Parent    = tabFrame,
        })

        table.insert(self._tabButtons, tabBtn)
        table.insert(self._tabFrames,  tabFrame)

        tabBtn.MouseButton1Click:Connect(function()
            self:_SwitchTab(idx)
        end)

        if idx == 1 then self:_SwitchTab(1) end

        -- ══════════════════════════════════════════════════════
        --  TAB  OBJECT
        -- ══════════════════════════════════════════════════════
        local Tab = {}
        Tab._frame      = tabFrame
        Tab._elemCount  = 0

        -- ────────────────────────────────────────────────────
        --  Helper: new element row inside tab
        -- ────────────────────────────────────────────────────
        local function NewRow(h, name_)
            Tab._elemCount = Tab._elemCount + 1
            return Create("Frame", {
                Name               = name_ or ("Elem_" .. Tab._elemCount),
                Size               = UDim2.new(1, 0, 0, h),
                BackgroundTransparency = 1,
                BorderSizePixel    = 0,
                LayoutOrder        = Tab._elemCount,
                ZIndex             = 12,
                Parent             = tabFrame,
            })
        end

        -- ────────────────────────────────────────────────────
        --  BUTTON
        -- ────────────────────────────────────────────────────
        function Tab:AddButton(config)
            config = config or {}
            local text     = config.Text     or "Button"
            local callback = config.Callback or function() end
            local disabled = config.Disabled or false

            local btn = Create("TextButton", {
                Name             = "Btn_" .. text,
                Size             = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = disabled and Theme.TabInactive or Theme.ButtonFace,
                BorderSizePixel  = 0,
                Text             = "  " .. text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextColor3       = disabled and Theme.BorderDark or Theme.ButtonText,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LayoutOrder      = Tab._elemCount + 1,
                ZIndex           = 12,
                Active           = not disabled,
                AutoButtonColor  = false,
                Parent           = tabFrame,
            })
            Tab._elemCount = Tab._elemCount + 1
            RaisedBorder(btn, 13)

            if not disabled then
                btn.MouseEnter:Connect(function()      btn.BackgroundColor3 = Theme.ButtonHover   end)
                btn.MouseLeave:Connect(function()      btn.BackgroundColor3 = Theme.ButtonFace    end)
                btn.MouseButton1Down:Connect(function() btn.BackgroundColor3 = Theme.ButtonPressed end)
                btn.MouseButton1Up:Connect(function()
                    btn.BackgroundColor3 = Theme.ButtonFace
                    callback()
                end)
            end

            local obj = {}
            function obj:SetText(t) btn.Text = "  " .. t end
            function obj:SetDisabled(v)
                disabled = v
                btn.Active = not v
                btn.BackgroundColor3 = v and Theme.TabInactive or Theme.ButtonFace
                btn.TextColor3 = v and Theme.BorderDark or Theme.ButtonText
            end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  TOGGLE  (checkbox)
        -- ────────────────────────────────────────────────────
        function Tab:AddToggle(config)
            config = config or {}
            local text     = config.Text     or "Toggle"
            local default  = config.Default  ~= nil and config.Default or false
            local callback = config.Callback or function() end

            local state = default
            local row   = NewRow(24, "Toggle_" .. text)

            local checkFrame = Create("Frame", {
                Size             = UDim2.new(0, 15, 0, 15),
                Position         = UDim2.new(0, 0, 0.5, -8),
                BackgroundColor3 = Theme.CheckBg,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = row,
            })
            SunkenBorder(checkFrame, 14)

            local checkMark = Create("TextLabel", {
                Size               = UDim2.new(1, -2, 1, -2),
                Position           = UDim2.new(0, 1, 0, 1),
                BackgroundTransparency = 1,
                Text               = "✓",
                Font               = Enum.Font.GothamBold,
                TextSize           = 12,
                TextColor3         = Theme.CheckMark,
                Visible            = state,
                ZIndex             = 15,
                Parent             = checkFrame,
            })

            Create("TextLabel", {
                Size               = UDim2.new(1, -22, 1, 0),
                Position           = UDim2.new(0, 22, 0, 0),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = row,
            })

            -- Transparent hit area
            local hit = Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = 16,
                Parent             = row,
            })
            hit.MouseButton1Click:Connect(function()
                state = not state
                checkMark.Visible = state
                callback(state)
            end)

            local obj = {}
            function obj:Set(v)
                state = v
                checkMark.Visible = v
                callback(v)
            end
            function obj:Get() return state end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  SLIDER
        -- ────────────────────────────────────────────────────
        function Tab:AddSlider(config)
            config = config or {}
            local text     = config.Text     or "Slider"
            local min      = config.Min      or 0
            local max      = config.Max      or 100
            local default  = math.clamp(config.Default or min, min, max)
            local suffix   = config.Suffix   or ""
            local callback = config.Callback or function() end
            local decimals = config.Decimals or 0

            local value    = default
            local sliding  = false

            local container = NewRow(42, "Slider_" .. text)

            -- Label row
            Create("TextLabel", {
                Size               = UDim2.new(0.65, 0, 0, 18),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = container,
            })
            local valLbl = Create("TextLabel", {
                Size               = UDim2.new(0.35, 0, 0, 18),
                Position           = UDim2.new(0.65, 0, 0, 0),
                BackgroundTransparency = 1,
                Text               = tostring(value) .. suffix,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Right,
                ZIndex             = 13,
                Parent             = container,
            })

            -- Track
            local track = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 14),
                Position         = UDim2.new(0, 0, 0, 22),
                BackgroundColor3 = Theme.SliderTrack,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = container,
            })
            SunkenBorder(track, 14)

            local initPct = (value - min) / (max - min)
            local fill    = Create("Frame", {
                Size             = UDim2.new(initPct, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = 14,
                Parent           = track,
            })

            local function fmt(v)
                if decimals > 0 then
                    return string.format("%." .. decimals .. "f", v)
                end
                return tostring(math.floor(v + 0.5))
            end

            local function updateSlider(mouseX)
                local abs  = track.AbsolutePosition.X
                local sz   = track.AbsoluteSize.X
                local rel  = math.clamp((mouseX - abs) / sz, 0, 1)
                value      = tonumber(fmt(min + rel * (max - min)))
                fill.Size  = UDim2.new(rel, 0, 1, 0)
                valLbl.Text = fmt(value) .. suffix
                callback(value)
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    updateSlider(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(inp.Position.X)
                end
            end)

            local obj = {}
            function obj:Set(v)
                value = math.clamp(v, min, max)
                local rel = (value - min) / (max - min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valLbl.Text = fmt(value) .. suffix
                callback(value)
            end
            function obj:Get() return value end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  DROPDOWN
        -- ────────────────────────────────────────────────────
        function Tab:AddDropdown(config)
            config = config or {}
            local text     = config.Text     or "Dropdown"
            local options  = config.Options  or {}
            local default  = config.Default  or options[1] or ""
            local callback = config.Callback or function() end

            local selected = default
            local isOpen   = false

            local container = NewRow(44, "Dropdown_" .. text)

            Create("TextLabel", {
                Size               = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = container,
            })

            local dropBtn = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 22),
                Position         = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                ClipsDescendants = false,
                Parent           = container,
            })
            SunkenBorder(dropBtn, 14)

            local selText = Create("TextLabel", {
                Size               = UDim2.new(1, -24, 1, 0),
                Position           = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Text               = selected,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.InputText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 14,
                Parent             = dropBtn,
            })

            local arrowBtn = Create("TextButton", {
                Size             = UDim2.new(0, 22, 1, 0),
                Position         = UDim2.new(1, -22, 0, 0),
                BackgroundColor3 = Theme.ButtonFace,
                BorderSizePixel  = 0,
                Text             = "▼",
                Font             = Enum.Font.Gotham,
                TextSize         = 10,
                TextColor3       = Theme.ButtonText,
                ZIndex           = 15,
                Parent           = dropBtn,
            })
            RaisedBorder(arrowBtn, 16)

            -- List (rendered above everything via high ZIndex)
            local listH   = math.min(#options, 6) * 22
            local dropList = Create("Frame", {
                Name             = "DropList",
                Size             = UDim2.new(1, 0, 0, listH),
                Position         = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Theme.DropBg,
                BorderSizePixel  = 1,
                BorderColor3     = Theme.BorderDark,
                Visible          = false,
                ZIndex           = 80,
                ClipsDescendants = false,
                Parent           = dropBtn,
            })

            -- If more than 6 items, make it a scroll frame
            local listContainer
            if #options > 6 then
                listContainer = Create("ScrollingFrame", {
                    Size                 = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel      = 0,
                    ScrollBarThickness   = 6,
                    ScrollBarImageColor3 = Theme.ScrollThumb,
                    CanvasSize           = UDim2.new(0, 0, 0, #options * 22),
                    ZIndex               = 81,
                    Parent               = dropList,
                })
            else
                listContainer = Create("Frame", {
                    Size               = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel    = 0,
                    ZIndex             = 81,
                    Parent             = dropList,
                })
            end
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = listContainer })

            local function BuildOptions(opts)
                for _, c in ipairs(listContainer:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, opt in ipairs(opts) do
                    local item = Create("TextButton", {
                        Name             = "Item_" .. i,
                        Size             = UDim2.new(1, 0, 0, 22),
                        BackgroundColor3 = Theme.DropBg,
                        BorderSizePixel  = 0,
                        Text             = "  " .. opt,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 13,
                        TextColor3       = Theme.DropText,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        LayoutOrder      = i,
                        ZIndex           = 82,
                        AutoButtonColor  = false,
                        Parent           = listContainer,
                    })
                    item.MouseEnter:Connect(function()
                        item.BackgroundColor3 = Theme.DropHover
                        item.TextColor3       = Theme.DropHoverText
                    end)
                    item.MouseLeave:Connect(function()
                        item.BackgroundColor3 = Theme.DropBg
                        item.TextColor3       = Theme.DropText
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected      = opt
                        selText.Text  = opt
                        isOpen        = false
                        dropList.Visible = false
                        arrowBtn.Text = "▼"
                        callback(selected)
                    end)
                end
            end
            BuildOptions(options)

            arrowBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropList.Visible = isOpen
                arrowBtn.Text = isOpen and "▲" or "▼"
            end)

            local obj = {}
            function obj:Set(v)
                selected     = v
                selText.Text = v
                callback(v)
            end
            function obj:Get() return selected end
            function obj:Refresh(newOpts)
                options = newOpts
                listH   = math.min(#newOpts, 6) * 22
                dropList.Size = UDim2.new(1, 0, 0, listH)
                if listContainer:IsA("ScrollingFrame") then
                    listContainer.CanvasSize = UDim2.new(0, 0, 0, #newOpts * 22)
                end
                BuildOptions(newOpts)
            end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  TEXTBOX
        -- ────────────────────────────────────────────────────
        function Tab:AddTextbox(config)
            config = config or {}
            local text       = config.Text        or "Textbox"
            local default    = config.Default      or ""
            local placeholder = config.Placeholder or "Type here..."
            local enterOnly  = config.EnterOnly    or false
            local callback   = config.Callback     or function() end

            local container = NewRow(44, "Textbox_" .. text)

            Create("TextLabel", {
                Size               = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = container,
            })

            local inputFrame = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 22),
                Position         = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = container,
            })
            SunkenBorder(inputFrame, 14)

            local box = Create("TextBox", {
                Size              = UDim2.new(1, -8, 1, -4),
                Position          = UDim2.new(0, 4, 0, 2),
                BackgroundTransparency = 1,
                Text              = default,
                PlaceholderText   = placeholder,
                PlaceholderColor3 = Theme.InputPlaceholder,
                Font              = Enum.Font.Gotham,
                TextSize          = 13,
                TextColor3        = Theme.InputText,
                TextXAlignment    = Enum.TextXAlignment.Left,
                ClearTextOnFocus  = false,
                ZIndex            = 14,
                Parent            = inputFrame,
            })

            if enterOnly then
                box.FocusLost:Connect(function(enter)
                    if enter then callback(box.Text) end
                end)
            else
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    callback(box.Text)
                end)
            end

            local obj = {}
            function obj:Set(v)  box.Text = v end
            function obj:Get()   return box.Text end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  KEYBIND
        -- ────────────────────────────────────────────────────
        function Tab:AddKeybind(config)
            config = config or {}
            local text       = config.Text     or "Keybind"
            local default    = config.Default   or Enum.KeyCode.Unknown
            local callback   = config.Callback  or function() end
            local holdMode   = config.Hold      or false

            local currentKey = default
            local listening  = false

            local row = NewRow(24, "Keybind_" .. text)

            Create("TextLabel", {
                Size               = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = row,
            })

            local keyBtn = Create("TextButton", {
                Size             = UDim2.new(0.38, 0, 0, 20),
                Position         = UDim2.new(0.62, 0, 0.5, -10),
                BackgroundColor3 = Theme.ButtonFace,
                BorderSizePixel  = 0,
                Text             = currentKey.Name,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = Theme.ButtonText,
                ZIndex           = 13,
                Parent           = row,
            })
            SunkenBorder(keyBtn, 14)

            keyBtn.MouseButton1Click:Connect(function()
                listening       = true
                keyBtn.Text     = "[ ... ]"
                keyBtn.TextColor3 = Color3.fromRGB(49, 106, 197)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey        = input.KeyCode
                    keyBtn.Text       = currentKey.Name
                    keyBtn.TextColor3 = Theme.ButtonText
                    listening         = false
                elseif not listening and not gpe and input.KeyCode == currentKey then
                    callback()
                end
            end)

            local obj = {}
            function obj:Set(k)
                currentKey   = k
                keyBtn.Text  = k.Name
            end
            function obj:Get() return currentKey end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  LABEL
        -- ────────────────────────────────────────────────────
        function Tab:AddLabel(text)
            Tab._elemCount = Tab._elemCount + 1
            local lbl = Create("TextLabel", {
                Name               = "Label_" .. Tab._elemCount,
                Size               = UDim2.new(1, 0, 0, 18),
                AutomaticSize      = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text               = text or "",
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                TextWrapped        = true,
                LayoutOrder        = Tab._elemCount,
                ZIndex             = 12,
                Parent             = tabFrame,
            })
            local obj = {}
            function obj:Set(v) lbl.Text = v end
            function obj:Get()  return lbl.Text end
            return obj
        end

        -- ────────────────────────────────────────────────────
        --  SECTION  (styled header + ruled line)
        -- ────────────────────────────────────────────────────
        function Tab:AddSection(text)
            Tab._elemCount = Tab._elemCount + 1
            local sec = Create("Frame", {
                Name               = "Section_" .. text,
                Size               = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                BorderSizePixel    = 0,
                LayoutOrder        = Tab._elemCount,
                ZIndex             = 12,
                Parent             = tabFrame,
            })
            Create("TextLabel", {
                Size               = UDim2.new(0, 0, 0, 16),
                AutomaticSize      = Enum.AutomaticSize.X,
                Position           = UDim2.new(0, 0, 0, 2),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.GothamBold,
                TextSize           = 13,
                TextColor3         = Theme.SectionText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = sec,
            })
            -- Ruled line
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -3),
                BackgroundColor3 = Theme.SectionLine,
                BorderSizePixel  = 0,
                ZIndex           = 12,
                Parent           = sec,
            })
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -2),
                BackgroundColor3 = Theme.BorderBright,
                BorderSizePixel  = 0,
                ZIndex           = 12,
                Parent           = sec,
            })
        end

        -- ────────────────────────────────────────────────────
        --  SEPARATOR  (thin horizontal divider)
        -- ────────────────────────────────────────────────────
        function Tab:AddSeparator()
            Tab._elemCount = Tab._elemCount + 1
            local sep = Create("Frame", {
                Name               = "Sep_" .. Tab._elemCount,
                Size               = UDim2.new(1, 0, 0, 6),
                BackgroundTransparency = 1,
                BorderSizePixel    = 0,
                LayoutOrder        = Tab._elemCount,
                ZIndex             = 12,
                Parent             = tabFrame,
            })
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = Theme.BorderDark,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = sep,
            })
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 0.5, 1),
                BackgroundColor3 = Theme.BorderBright,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = sep,
            })
        end

        -- ────────────────────────────────────────────────────
        --  COLOR PICKER  (RGB sliders)
        -- ────────────────────────────────────────────────────
        function Tab:AddColorPicker(config)
            config = config or {}
            local text     = config.Text     or "Color"
            local default  = config.Default  or Color3.fromRGB(255, 0, 0)
            local callback = config.Callback or function() end

            local currentColor = default
            local pickerOpen   = false

            -- Collapsed row
            local row = NewRow(24, "ColorPicker_" .. text)

            Create("TextLabel", {
                Size               = UDim2.new(0.65, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = text,
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 13,
                Parent             = row,
            })

            local preview = Create("Frame", {
                Size             = UDim2.new(0, 44, 0, 18),
                Position         = UDim2.new(1, -44, 0.5, -9),
                BackgroundColor3 = currentColor,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = row,
            })
            SunkenBorder(preview, 14)

            -- Expanded RGB panel
            Tab._elemCount = Tab._elemCount + 1
            local panel = Create("Frame", {
                Name               = "ColorPanel_" .. text,
                Size               = UDim2.new(1, 0, 0, 0),
                AutomaticSize      = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel    = 0,
                Visible            = false,
                LayoutOrder        = Tab._elemCount,
                ZIndex             = 12,
                Parent             = tabFrame,
            })
            Create("UIListLayout", { Padding = UDim.new(0, 2), Parent = panel })

            local r = math.floor(default.R * 255 + 0.5)
            local g = math.floor(default.G * 255 + 0.5)
            local b = math.floor(default.B * 255 + 0.5)

            local function refresh()
                currentColor        = Color3.fromRGB(r, g, b)
                preview.BackgroundColor3 = currentColor
                callback(currentColor)
            end

            local channels = {
                { "R", Color3.fromRGB(200, 40,  40),  function(v) r = v end, function() return r end },
                { "G", Color3.fromRGB(40,  160, 40),  function(v) g = v end, function() return g end },
                { "B", Color3.fromRGB(40,  100, 220), function(v) b = v end, function() return b end },
            }

            for _, ch in ipairs(channels) do
                local chRow = Create("Frame", {
                    Size               = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent             = panel,
                })
                Create("TextLabel", {
                    Size               = UDim2.new(0, 12, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = ch[1],
                    Font               = Enum.Font.GothamBold,
                    TextSize           = 12,
                    TextColor3         = ch[2],
                    ZIndex             = 13,
                    Parent             = chRow,
                })
                local chTrack = Create("Frame", {
                    Size             = UDim2.new(1, -46, 0, 10),
                    Position         = UDim2.new(0, 14, 0.5, -5),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel  = 0,
                    ZIndex           = 13,
                    Parent           = chRow,
                })
                SunkenBorder(chTrack, 14)
                local chFill = Create("Frame", {
                    Size             = UDim2.new(ch[4]() / 255, 0, 1, 0),
                    BackgroundColor3 = ch[2],
                    BorderSizePixel  = 0,
                    ZIndex           = 14,
                    Parent           = chTrack,
                })
                local chVal = Create("TextLabel", {
                    Size               = UDim2.new(0, 28, 1, 0),
                    Position           = UDim2.new(1, -28, 0, 0),
                    BackgroundTransparency = 1,
                    Text               = tostring(ch[4]()),
                    Font               = Enum.Font.Gotham,
                    TextSize           = 11,
                    TextColor3         = Theme.LabelText,
                    TextXAlignment     = Enum.TextXAlignment.Right,
                    ZIndex             = 13,
                    Parent             = chRow,
                })

                local sliding = false
                chTrack.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        local rel = math.clamp((inp.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                        local val = math.floor(rel * 255 + 0.5)
                        chFill.Size = UDim2.new(rel, 0, 1, 0)
                        chVal.Text  = tostring(val)
                        ch[3](val)
                        refresh()
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((inp.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                        local val = math.floor(rel * 255 + 0.5)
                        chFill.Size = UDim2.new(rel, 0, 1, 0)
                        chVal.Text  = tostring(val)
                        ch[3](val)
                        refresh()
                    end
                end)
            end

            -- Toggle panel
            local hit = Create("TextButton", {
                Size               = UDim2.new(0, 44, 0, 18),
                Position           = UDim2.new(1, -44, 0.5, -9),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = 20,
                Parent             = row,
            })
            hit.MouseButton1Click:Connect(function()
                pickerOpen   = not pickerOpen
                panel.Visible = pickerOpen
            end)

            local obj = {}
            function obj:Set(color)
                currentColor        = color
                preview.BackgroundColor3 = color
                r = math.floor(color.R * 255 + 0.5)
                g = math.floor(color.G * 255 + 0.5)
                b = math.floor(color.B * 255 + 0.5)
                callback(color)
            end
            function obj:Get() return currentColor end
            return obj
        end

        return Tab
    end -- end AddTab

    -- ════════════════════════════════════════════════════════════
    --  NOTIFY
    -- ════════════════════════════════════════════════════════════
    function Window:Notify(config)
        config = config or {}
        local title    = config.Title    or "Notification"
        local message  = config.Message  or ""
        local duration = config.Duration or 4
        local notifType = config.Type    or "Info"

        local typeAccent = {
            Info    = Color3.fromRGB(10,  36,  106),
            Warning = Color3.fromRGB(195, 130, 0),
            Error   = Color3.fromRGB(175, 20,  0),
            Success = Color3.fromRGB(0,   120, 0),
        }
        local accent = typeAccent[notifType] or typeAccent.Info

        self._notifSeq  = self._notifSeq + 1
        local n         = self._notifSeq

        local notif = Create("Frame", {
            Name             = "Notif_" .. n,
            Size             = UDim2.new(1, 0, 0, 72),
            BackgroundColor3 = Theme.NotifBg,
            BorderSizePixel  = 0,
            ZIndex           = 200,
            LayoutOrder      = n,
            ClipsDescendants = true,
            Parent           = self._notifHolder,
        })
        RaisedBorder(notif, 201)

        -- Colour accent strip (left edge)
        Create("Frame", {
            Size             = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            ZIndex           = 202,
            Parent           = notif,
        })

        -- Title bar
        local tbar = Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            ZIndex           = 201,
            Parent           = notif,
        })
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, accent),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(
                    math.min(accent.R * 255 + 80, 255),
                    math.min(accent.G * 255 + 80, 255),
                    math.min(accent.B * 255 + 80, 255)
                )),
            }),
            Rotation = 0,
            Parent   = tbar,
        })
        Create("TextLabel", {
            Size               = UDim2.new(1, -28, 1, 0),
            Position           = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text               = title,
            Font               = Enum.Font.GothamBold,
            TextSize           = 12,
            TextColor3         = Color3.fromRGB(255, 255, 255),
            TextXAlignment     = Enum.TextXAlignment.Left,
            ZIndex             = 202,
            Parent             = tbar,
        })

        -- Close (X) on title bar
        local closeN = Create("TextButton", {
            Size             = UDim2.new(0, 16, 0, 14),
            Position         = UDim2.new(1, -18, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(160, 50, 20),
            BorderSizePixel  = 0,
            Text             = "✕",
            Font             = Enum.Font.GothamBold,
            TextSize         = 9,
            TextColor3       = Color3.fromRGB(255, 255, 255),
            ZIndex           = 203,
            Parent           = tbar,
        })

        -- Message body
        Create("TextLabel", {
            Size               = UDim2.new(1, -14, 0, 32),
            Position           = UDim2.new(0, 10, 0, 26),
            BackgroundTransparency = 1,
            Text               = message,
            Font               = Enum.Font.Gotham,
            TextSize           = 12,
            TextColor3         = Theme.NotifText,
            TextXAlignment     = Enum.TextXAlignment.Left,
            TextWrapped        = true,
            ZIndex             = 202,
            Parent             = notif,
        })

        -- Countdown progress bar
        local pbBg = Create("Frame", {
            Size             = UDim2.new(1, -10, 0, 3),
            Position         = UDim2.new(0, 5, 1, -5),
            BackgroundColor3 = Theme.BorderLight,
            BorderSizePixel  = 0,
            ZIndex           = 202,
            Parent           = notif,
        })
        local pbFill = Create("Frame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            ZIndex           = 203,
            Parent           = pbBg,
        })
        TweenService:Create(pbFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0),
        }):Play()

        local function dismiss()
            TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, 0, 0, 0),
            }):Play()
            task.delay(0.25, function()
                if notif and notif.Parent then notif:Destroy() end
            end)
        end

        closeN.MouseButton1Click:Connect(dismiss)
        task.delay(duration, dismiss)
    end

    -- ════════════════════════════════════════════════════════════
    --  MISC  WINDOW  METHODS
    -- ════════════════════════════════════════════════════════════
    function Window:Destroy()
        screenGui:Destroy()
    end

    function Window:Toggle()
        winFrame.Visible = not winFrame.Visible
    end

    function Window:SetTitle(t)
        for _, lbl in ipairs(titleBar:GetChildren()) do
            if lbl:IsA("TextLabel") then lbl.Text = t end
        end
    end

    return Window
end

-- ════════════════════════════════════════════════════════════════
--  THEME  CUSTOMISATION  (optional)
-- ════════════════════════════════════════════════════════════════
function WinXP:SetTheme(overrides)
    for k, v in pairs(overrides or {}) do
        if Theme[k] ~= nil then Theme[k] = v end
    end
end

function WinXP:GetTheme()
    return Theme
end

return WinXP
