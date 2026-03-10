--[[
    ██╗    ██╗██╗███╗   ██╗██╗  ██╗██████╗     ██╗  ██╗██████╗
    ██║    ██║██║████╗  ██║╚██╗██╔╝██╔══██╗    ██║  ██║██╔══██╗
    ██║ █╗ ██║██║██╔██╗ ██║ ╚███╔╝ ██████╔╝    ██║  ██║██║  ██║
    ██║███╗██║██║██║╚██╗██║ ██╔██╗ ██╔═══╝     ██║  ██║██║  ██║
    ╚███╔███╔╝██║██║ ╚████║██╔╝ ██╗██║         ╚██████╔╝██████╔╝
     ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝          ╚═════╝ ╚═════╝

    Windows XP UI Library for Roblox  —  v0.0.4
    License : MIT

    Layout:
        ┌──────────────────────────────────────────┐
        │  TITLE BAR                          ─ □ ✕│
        ├─────────────╥────────────────────────────┤
        │ ▌ Main      ║  [Content + Scrollbar]     │
        │   Visuals   ║                            │
        │   Settings  ║                            │
        └─────────────╨────────────────────────────┘

    v1.3 fix: tab-list and sidebar divider are now in SEPARATE
              containers so UIListLayout never sees the full-height
              divider frames (which previously pushed all tabs off-screen).
]]

local WinXP = {}
WinXP.__index = WinXP

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

-- ══════════════════════════════════════════════════════════════
--  CONSTANTS
-- ══════════════════════════════════════════════════════════════
local SIDEBAR_W  = 108   -- sidebar width in pixels
local TITLEBAR_H = 28    -- title bar height in pixels
local TAB_H      = 28    -- height of one tab button in pixels

-- ══════════════════════════════════════════════════════════════
--  THEME  — Windows XP Luna Blue
-- ══════════════════════════════════════════════════════════════
local Theme = {
    -- Title bar
    TitleGradL      = Color3.fromRGB(10,  36,  106),
    TitleGradR      = Color3.fromRGB(166, 202, 240),
    TitleText       = Color3.fromRGB(255, 255, 255),
    TitleShadow     = Color3.fromRGB(0,   0,   80),

    -- Window chrome
    WinOutline      = Color3.fromRGB(10,  36,  106),
    WinBody         = Color3.fromRGB(236, 233, 216),

    -- 3-D border shades
    B_Bright        = Color3.fromRGB(255, 255, 255),
    B_Light         = Color3.fromRGB(214, 211, 196),
    B_Dark          = Color3.fromRGB(172, 168, 153),
    B_Darker        = Color3.fromRGB(113, 111, 100),

    -- Window control buttons
    CtrlBlueL       = Color3.fromRGB(58,  110, 195),
    CtrlBlueR       = Color3.fromRGB(140, 190, 245),
    CtrlRedL        = Color3.fromRGB(185, 50,  15),
    CtrlRedR        = Color3.fromRGB(235, 100, 60),

    -- Sidebar
    SidebarBg       = Color3.fromRGB(210, 207, 190),

    -- Tab buttons
    TabActive       = Color3.fromRGB(236, 233, 216),  -- same as WinBody (flush look)
    TabInactive     = Color3.fromRGB(210, 207, 190),  -- same as SidebarBg
    TabHover        = Color3.fromRGB(222, 220, 207),
    TabAccent       = Color3.fromRGB(49,  106, 197),  -- blue left bar
    TabTextOn       = Color3.fromRGB(10,  36,  106),  -- active tab text
    TabTextOff      = Color3.fromRGB(50,  50,  50),   -- inactive tab text

    -- Push buttons
    BtnFace         = Color3.fromRGB(236, 233, 216),
    BtnText         = Color3.fromRGB(0,   0,   0),
    BtnHover        = Color3.fromRGB(224, 222, 210),
    BtnPressed      = Color3.fromRGB(204, 201, 188),
    BtnDisabledBg   = Color3.fromRGB(210, 207, 190),
    BtnDisabledText = Color3.fromRGB(172, 168, 153),

    -- Inputs / tracks
    InputBg         = Color3.fromRGB(255, 255, 255),
    InputText       = Color3.fromRGB(0,   0,   0),
    InputPh         = Color3.fromRGB(160, 160, 160),

    -- Slider
    SliderTrack     = Color3.fromRGB(255, 255, 255),
    SliderFill      = Color3.fromRGB(49,  106, 197),

    -- Checkbox
    CheckBg         = Color3.fromRGB(255, 255, 255),
    CheckMark       = Color3.fromRGB(0,   0,   0),

    -- Section headings
    SecText         = Color3.fromRGB(10,  36,  106),
    SecLine         = Color3.fromRGB(172, 168, 153),

    -- Labels
    LabelText       = Color3.fromRGB(0,   0,   0),

    -- Dropdown list
    DropBg          = Color3.fromRGB(255, 255, 255),
    DropHover       = Color3.fromRGB(49,  106, 197),
    DropText        = Color3.fromRGB(0,   0,   0),
    DropHoverText   = Color3.fromRGB(255, 255, 255),
    DropBorder      = Color3.fromRGB(113, 111, 100),

    -- Scrollbar
    ScrollThumb     = Color3.fromRGB(172, 168, 153),

    -- Notifications
    NotifBg         = Color3.fromRGB(236, 233, 216),
    NotifText       = Color3.fromRGB(0,   0,   0),
}

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

-- Raised (convex) XP 3-D border
local function Raised(f)
    local z = f.ZIndex + 1
    local function E(s, p, c)
        New("Frame",{Size=s,Position=p,BackgroundColor3=c,BorderSizePixel=0,ZIndex=z,Parent=f})
    end
    E(UDim2.new(1,0,0,1),  UDim2.new(0,0,0,0),   Theme.B_Bright)
    E(UDim2.new(0,1,1,0),  UDim2.new(0,0,0,0),   Theme.B_Bright)
    E(UDim2.new(1,-1,0,1), UDim2.new(0,1,0,1),   Theme.B_Light)
    E(UDim2.new(0,1,1,-1), UDim2.new(0,1,0,1),   Theme.B_Light)
    E(UDim2.new(1,0,0,1),  UDim2.new(0,0,1,-1),  Theme.B_Darker)
    E(UDim2.new(0,1,1,0),  UDim2.new(1,-1,0,0),  Theme.B_Darker)
    E(UDim2.new(1,-2,0,1), UDim2.new(0,1,1,-2),  Theme.B_Dark)
    E(UDim2.new(0,1,1,-2), UDim2.new(1,-2,0,1),  Theme.B_Dark)
end

-- Sunken (concave) XP 3-D border
local function Sunken(f)
    local z = f.ZIndex + 1
    local function E(s, p, c)
        New("Frame",{Size=s,Position=p,BackgroundColor3=c,BorderSizePixel=0,ZIndex=z,Parent=f})
    end
    E(UDim2.new(1,0,0,1),  UDim2.new(0,0,0,0),   Theme.B_Darker)
    E(UDim2.new(0,1,1,0),  UDim2.new(0,0,0,0),   Theme.B_Darker)
    E(UDim2.new(1,-1,0,1), UDim2.new(0,1,0,1),   Theme.B_Dark)
    E(UDim2.new(0,1,1,-1), UDim2.new(0,1,0,1),   Theme.B_Dark)
    E(UDim2.new(1,0,0,1),  UDim2.new(0,0,1,-1),  Theme.B_Bright)
    E(UDim2.new(0,1,1,0),  UDim2.new(1,-1,0,0),  Theme.B_Bright)
    E(UDim2.new(1,-2,0,1), UDim2.new(0,1,1,-2),  Theme.B_Light)
    E(UDim2.new(0,1,1,-2), UDim2.new(1,-2,0,1),  Theme.B_Light)
end

local function Draggable(handle, target)
    local drag, base, origin = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; base = i.Position; origin = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - base
            target.Position = UDim2.new(
                origin.X.Scale, origin.X.Offset + d.X,
                origin.Y.Scale, origin.Y.Offset + d.Y
            )
        end
    end)
end

local function GuiParent()
    if gethui then return gethui() end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        local ok2 = pcall(function()
            local t = Instance.new("ScreenGui"); t.Parent = core; t:Destroy()
        end)
        if ok2 then return core end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ══════════════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════════════
function WinXP:CreateWindow(config)
    config = config or {}
    local title     = config.Title     or "WinXP UI"
    local winSize   = config.Size      or UDim2.new(0, 560, 0, 430)
    local winPos    = config.Position  or UDim2.new(0.5, -(winSize.X.Offset/2), 0.5, -(winSize.Y.Offset/2))
    local icon      = config.Icon      or ""
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    -- ── ScreenGui ──────────────────────────────────────────────
    local gui = New("ScreenGui", {
        Name           = "WinXP_" .. title:gsub("%s+", "_"),
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = GuiParent(),
    })

    -- ── Outer shell ─────────────────────────────────────────────
    local shell = New("Frame", {
        Name             = "Shell",
        Size             = winSize,
        Position         = winPos,
        BackgroundColor3 = Theme.WinOutline,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = gui,
    })
    Raised(shell)

    -- ── Body (clips all children to window bounds) ──────────────
    local body = New("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, -4, 1, -4),
        Position         = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Theme.WinBody,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 2,
        Parent           = shell,
    })

    -- ── Title bar ───────────────────────────────────────────────
    local titleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, TITLEBAR_H),
        BackgroundColor3 = Theme.TitleGradL,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = body,
    })
    New("UIGradient", {
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.TitleGradL),
            ColorSequenceKeypoint.new(1, Theme.TitleGradR),
        }),
        Rotation = 0,
        Parent   = titleBar,
    })

    local iconOff = 6
    if icon ~= "" then
        New("ImageLabel", {
            Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,4,0.5,-8),
            BackgroundTransparency = 1, Image = icon,
            ZIndex = 4, Parent = titleBar,
        })
        iconOff = 26
    end
    New("TextLabel", {   -- drop-shadow
        Size = UDim2.new(1,-96,1,0), Position = UDim2.new(0, iconOff+1, 0, 1),
        BackgroundTransparency = 1, Text = title,
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = Theme.TitleShadow, TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = titleBar,
    })
    local titleLbl = New("TextLabel", {
        Size = UDim2.new(1,-96,1,0), Position = UDim2.new(0, iconOff, 0, 0),
        BackgroundTransparency = 1, Text = title,
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = Theme.TitleText,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = titleBar,
    })

    -- ── Window control buttons ──────────────────────────────────
    local function CtrlBtn(xOff, w, lbl, cL, cR)
        local b = New("TextButton", {
            Size = UDim2.new(0,w,0,20), Position = UDim2.new(1,xOff,0.5,-10),
            BackgroundColor3 = cL, BorderSizePixel = 0,
            Text = lbl, Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = Color3.new(1,1,1), ZIndex = 4, AutoButtonColor = false,
            Parent = titleBar,
        })
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, cL),
                ColorSequenceKeypoint.new(1, cR),
            }),
            Rotation = 90, Parent = b,
        })
        Raised(b)
        return b
    end
    local btnMin   = CtrlBtn(-73, 20, "─", Theme.CtrlBlueL, Theme.CtrlBlueR)
    local btnMax   = CtrlBtn(-50, 20, "□", Theme.CtrlBlueL, Theme.CtrlBlueR)
    local btnClose = CtrlBtn(-26, 23, "✕", Theme.CtrlRedL,  Theme.CtrlRedR)

    Draggable(titleBar, shell)

    local minimised = false
    btnClose.MouseButton1Click:Connect(function()
        TweenService:Create(shell, TweenInfo.new(0.15), {Size=UDim2.new(0,winSize.X.Offset,0,0)}):Play()
        task.delay(0.15, function() gui:Destroy() end)
    end)
    btnMin.MouseButton1Click:Connect(function()
        minimised = not minimised
        TweenService:Create(shell, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Size = minimised and UDim2.new(0, winSize.X.Offset, 0, TITLEBAR_H+4) or winSize
        }):Play()
    end)
    btnMax.MouseButton1Click:Connect(function()
        local vp = workspace.CurrentCamera.ViewportSize
        if math.abs(shell.Size.X.Offset - winSize.X.Offset) < 2 then
            TweenService:Create(shell, TweenInfo.new(0.18), {
                Size     = UDim2.new(0, vp.X-4, 0, vp.Y-4),
                Position = UDim2.new(0, 2, 0, 2),
            }):Play()
        else
            TweenService:Create(shell, TweenInfo.new(0.18), {
                Size = winSize, Position = winPos,
            }):Play()
        end
    end)
    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == toggleKey then
            shell.Visible = not shell.Visible
        end
    end)

    -- ═══════════════════════════════════════════════════════════
    --  SIDEBAR STRUCTURE
    --
    --  THE KEY FIX: the sidebar is split into two layers:
    --
    --   sidebarBg  ← plain background frame (ZIndex 3, no layout)
    --    ├─ tabList  ← Frame with UIListLayout; ONLY tab buttons go here
    --   dividerDark ← 1px frame child of BODY, not sidebar (ZIndex 3)
    --   dividerLight← 1px frame child of BODY, not sidebar (ZIndex 3)
    --
    --  Separating dividers from the UIListLayout container is what
    --  fixes the invisible-tabs bug. Previously the dividers were
    --  full-height (Size.Y scale=1) siblings of the tab buttons
    --  inside the same UIListLayout, which pushed every tab button
    --  completely below the visible area.
    -- ═══════════════════════════════════════════════════════════

    -- Sidebar background (no UIListLayout, no dividers)
    local sidebarBg = New("Frame", {
        Name             = "SidebarBg",
        Size             = UDim2.new(0, SIDEBAR_W, 1, -TITLEBAR_H),
        Position         = UDim2.new(0, 0, 0, TITLEBAR_H),
        BackgroundColor3 = Theme.SidebarBg,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = body,
    })

    -- Tab button list — a plain Frame inside sidebarBg WITH UIListLayout
    -- Nothing else gets parented here except TextButtons.
    local tabList = New("Frame", {
        Name             = "TabList",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = sidebarBg,
    })
    New("UIListLayout", {
        SortOrder     = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 0),
        Parent        = tabList,
    })

    -- Etched vertical divider — parented to BODY, not to the sidebar/tabList.
    -- This means UIListLayout never sees these frames.
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, -TITLEBAR_H),
        Position         = UDim2.new(0, SIDEBAR_W, 0, TITLEBAR_H),
        BackgroundColor3 = Theme.B_Dark,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = body,
    })
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, -TITLEBAR_H),
        Position         = UDim2.new(0, SIDEBAR_W+1, 0, TITLEBAR_H),
        BackgroundColor3 = Theme.B_Bright,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = body,
    })

    -- Content area — starts 2px to the right of sidebar's right edge
    local contentArea = New("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -(SIDEBAR_W+2), 1, -TITLEBAR_H),
        Position         = UDim2.new(0, SIDEBAR_W+2, 0, TITLEBAR_H),
        BackgroundColor3 = Theme.WinBody,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 3,
        Parent           = body,
    })

    -- Notification overlay — lives at ScreenGui level, never clipped by body
    local notifHolder = New("Frame", {
        Name               = "NotifHolder",
        Size               = UDim2.new(0, 290, 1, -16),
        Position           = UDim2.new(1, -302, 0, 8),
        BackgroundTransparency = 1,
        ZIndex             = 50,
        Parent             = gui,
    })
    New("UIListLayout", {
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding           = UDim.new(0, 6),
        Parent            = notifHolder,
    })

    -- ══════════════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ══════════════════════════════════════════════════════════
    local Window = {
        _gui         = gui,
        _shell       = shell,
        _titleLbl    = titleLbl,
        _notifHolder = notifHolder,
        _tabs        = {},
        _activeIdx   = 0,
        _notifSeq    = 0,
    }

    function Window:_Switch(idx)
        for i, t in ipairs(self._tabs) do
            local active = (i == idx)
            t.scroll.Visible          = active
            t.btn.BackgroundColor3    = active and Theme.TabActive or Theme.TabInactive
            t.btn.Font                = active and Enum.Font.GothamBold or Enum.Font.Gotham
            t.btn.TextColor3          = active and Theme.TabTextOn or Theme.TabTextOff
            t.accent.Visible          = active
        end
        self._activeIdx = idx
    end

    -- ══════════════════════════════════════════════════════════
    --  AddTab
    -- ══════════════════════════════════════════════════════════
    function Window:AddTab(name)
        local idx = #self._tabs + 1

        -- Single TextButton — no Frame wrapper, no transparent overlay.
        -- Children: only the 3px accent bar and 1px bottom rule.
        local btn = New("TextButton", {
            Name             = "Tab_" .. name,
            Size             = UDim2.new(1, 0, 0, TAB_H),
            BackgroundColor3 = Theme.TabInactive,
            BorderSizePixel  = 0,
            Text             = name,
            Font             = Enum.Font.Gotham,
            TextSize         = 13,
            TextColor3       = Theme.TabTextOff,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LayoutOrder      = idx,
            ZIndex           = 4,
            AutoButtonColor  = false,
            -- Parent is tabList (the UIListLayout container), not sidebarBg
            Parent           = tabList,
        })
        -- Indent text to the right of the accent bar
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            Parent      = btn,
        })
        -- Blue accent bar on left edge (only visible when tab is active)
        local accent = New("Frame", {
            Size             = UDim2.new(0, 3, 1, 0),
            Position         = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.TabAccent,
            BorderSizePixel  = 0,
            Visible          = false,
            ZIndex           = 5,
            Parent           = btn,
        })
        -- Horizontal rule at bottom of tab button
        New("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Theme.B_Dark,
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = btn,
        })

        btn.MouseEnter:Connect(function()
            if self._activeIdx ~= idx then
                btn.BackgroundColor3 = Theme.TabHover
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._activeIdx ~= idx then
                btn.BackgroundColor3 = Theme.TabInactive
            end
        end)
        btn.MouseButton1Click:Connect(function()
            self:_Switch(idx)
        end)

        -- Per-tab scroll frame inside contentArea
        local scroll = New("ScrollingFrame", {
            Name                 = "Scroll_" .. name,
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 8,
            ScrollBarImageColor3 = Theme.ScrollThumb,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = false,
            ZIndex               = 4,
            Parent               = contentArea,
        })
        New("UIPadding", {
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 12),
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            Parent        = scroll,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 5),
            Parent    = scroll,
        })

        table.insert(self._tabs, { btn=btn, accent=accent, scroll=scroll })
        if idx == 1 then self:_Switch(1) end

        -- ════════════════════════════════════════════════════
        --  TAB OBJECT
        -- ════════════════════════════════════════════════════
        local Tab = { _scroll=scroll, _n=0 }

        local function Row(h, tag)
            Tab._n = Tab._n + 1
            return New("Frame", {
                Name               = (tag or "E") .. "_" .. Tab._n,
                Size               = UDim2.new(1, 0, 0, h),
                BackgroundTransparency = 1,
                BorderSizePixel    = 0,
                LayoutOrder        = Tab._n,
                ZIndex             = 5,
                Parent             = scroll,
            })
        end

        -- ────────────────────────── BUTTON ───────────────
        function Tab:AddButton(cfg)
            cfg = cfg or {}
            local text = cfg.Text     or "Button"
            local cb   = cfg.Callback or function() end
            local dis  = cfg.Disabled or false
            Tab._n = Tab._n + 1
            local b = New("TextButton", {
                Name             = "Btn_" .. text,
                Size             = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = dis and Theme.BtnDisabledBg or Theme.BtnFace,
                BorderSizePixel  = 0,
                Text             = "  " .. text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextColor3       = dis and Theme.BtnDisabledText or Theme.BtnText,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LayoutOrder      = Tab._n,
                ZIndex           = 5,
                Active           = not dis,
                AutoButtonColor  = false,
                Parent           = scroll,
            })
            Raised(b)
            if not dis then
                b.MouseEnter:Connect(function()       b.BackgroundColor3=Theme.BtnHover   end)
                b.MouseLeave:Connect(function()       b.BackgroundColor3=Theme.BtnFace    end)
                b.MouseButton1Down:Connect(function() b.BackgroundColor3=Theme.BtnPressed end)
                b.MouseButton1Up:Connect(function()   b.BackgroundColor3=Theme.BtnFace; cb() end)
            end
            local o = {}
            function o:SetText(t)    b.Text = "  " .. t end
            function o:SetDisabled(v)
                dis = v; b.Active = not v
                b.BackgroundColor3 = v and Theme.BtnDisabledBg or Theme.BtnFace
                b.TextColor3       = v and Theme.BtnDisabledText or Theme.BtnText
            end
            return o
        end

        -- ────────────────────────── TOGGLE ───────────────
        function Tab:AddToggle(cfg)
            cfg = cfg or {}
            local text  = cfg.Text     or "Toggle"
            local state = cfg.Default  ~= nil and cfg.Default or false
            local cb    = cfg.Callback or function() end
            local row   = Row(24, "Toggle")

            local box = New("Frame", {
                Size=UDim2.new(0,15,0,15), Position=UDim2.new(0,0,0.5,-8),
                BackgroundColor3=Theme.CheckBg, BorderSizePixel=0, ZIndex=6, Parent=row,
            })
            Sunken(box)
            local tick = New("TextLabel", {
                Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1),
                BackgroundTransparency=1, Text="✓",
                Font=Enum.Font.GothamBold, TextSize=12,
                TextColor3=Theme.CheckMark, Visible=state, ZIndex=8, Parent=box,
            })
            New("TextLabel", {
                Size=UDim2.new(1,-22,1,0), Position=UDim2.new(0,22,0,0),
                BackgroundTransparency=1, Text=text,
                Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.LabelText,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6, Parent=row,
            })
            local hit = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text="", ZIndex=9, Parent=row,
            })
            hit.MouseButton1Click:Connect(function()
                state = not state; tick.Visible = state; cb(state)
            end)
            local o = {}
            function o:Set(v) state=v; tick.Visible=v; cb(v) end
            function o:Get() return state end
            return o
        end

        -- ────────────────────────── SLIDER ───────────────
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local text = cfg.Text     or "Slider"
            local mn   = cfg.Min      or 0
            local mx   = cfg.Max      or 100
            local val  = math.clamp(cfg.Default or mn, mn, mx)
            local suf  = cfg.Suffix   or ""
            local dec  = cfg.Decimals or 0
            local cb   = cfg.Callback or function() end
            local slide = false
            local ctr   = Row(44, "Slider")

            local function fmt(v)
                if dec > 0 then return string.format("%." .. dec .. "f", v) end
                return tostring(math.floor(v + 0.5))
            end

            local top = New("Frame", {
                Size=UDim2.new(1,0,0,18), BackgroundTransparency=1, ZIndex=6, Parent=ctr,
            })
            New("TextLabel", {
                Size=UDim2.new(0.58,0,1,0), BackgroundTransparency=1,
                Text=text, Font=Enum.Font.Gotham, TextSize=13,
                TextColor3=Theme.LabelText, TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=6, Parent=top,
            })
            local valLbl = New("TextLabel", {
                Size=UDim2.new(0.42,0,1,0), Position=UDim2.new(0.58,0,0,0),
                BackgroundTransparency=1, Text=fmt(val)..suf,
                Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.LabelText,
                TextXAlignment=Enum.TextXAlignment.Right, ZIndex=6, Parent=top,
            })

            local track = New("Frame", {
                Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,22),
                BackgroundColor3=Theme.SliderTrack, BorderSizePixel=0, ZIndex=6, Parent=ctr,
            })
            Sunken(track)
            local fill = New("Frame", {
                Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=Theme.SliderFill, BorderSizePixel=0, ZIndex=7, Parent=track,
            })

            local function update(mouseX)
                local rel = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = tonumber(fmt(mn + rel * (mx - mn)))
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valLbl.Text = fmt(val) .. suf
                cb(val)
            end
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then slide=true; update(i.Position.X) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then slide=false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if slide and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
            end)

            local o = {}
            function o:Set(v)
                val = math.clamp(v, mn, mx)
                fill.Size = UDim2.new((val-mn)/(mx-mn), 0, 1, 0)
                valLbl.Text = fmt(val) .. suf; cb(val)
            end
            function o:Get() return val end
            return o
        end

        -- ────────────────────────── DROPDOWN ─────────────
        -- List is parented to ScreenGui so it escapes all ClipsDescendants.
        function Tab:AddDropdown(cfg)
            cfg = cfg or {}
            local text   = cfg.Text     or "Dropdown"
            local opts   = cfg.Options  or {}
            local sel    = cfg.Default  or opts[1] or ""
            local cb     = cfg.Callback or function() end
            local isOpen = false
            local ctr    = Row(44, "Dropdown")

            New("TextLabel", {
                Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
                Text=text, Font=Enum.Font.Gotham, TextSize=13,
                TextColor3=Theme.LabelText, TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=6, Parent=ctr,
            })
            local box = New("Frame", {
                Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,18),
                BackgroundColor3=Theme.InputBg, BorderSizePixel=0, ZIndex=6, Parent=ctr,
            })
            Sunken(box)
            local selTxt = New("TextLabel", {
                Size=UDim2.new(1,-26,1,0), Position=UDim2.new(0,4,0,0),
                BackgroundTransparency=1, Text=sel,
                Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.InputText,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextTruncate=Enum.TextTruncate.AtEnd,
                ZIndex=7, Parent=box,
            })
            local arrow = New("TextButton", {
                Size=UDim2.new(0,22,1,0), Position=UDim2.new(1,-22,0,0),
                BackgroundColor3=Theme.BtnFace, BorderSizePixel=0,
                Text="▼", Font=Enum.Font.Gotham, TextSize=10,
                TextColor3=Theme.BtnText, ZIndex=8, Parent=box,
            })
            Raised(arrow)

            local listH = math.min(#opts, 6) * 22
            local list  = New("ScrollingFrame", {
                Size=UDim2.new(0,200,0,listH),
                BackgroundColor3=Theme.DropBg, BorderSizePixel=1,
                BorderColor3=Theme.DropBorder,
                ScrollBarThickness = #opts > 6 and 8 or 0,
                CanvasSize=UDim2.new(0,0,0,#opts*22),
                Visible=false, ZIndex=100, Parent=gui,
            })
            New("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, Parent=list })

            local function Build(options)
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local item = New("TextButton", {
                        Size=UDim2.new(1,0,0,22), BackgroundColor3=Theme.DropBg,
                        BorderSizePixel=0, Text="  "..opt,
                        Font=Enum.Font.Gotham, TextSize=13,
                        TextColor3=Theme.DropText, TextXAlignment=Enum.TextXAlignment.Left,
                        LayoutOrder=i, ZIndex=101, AutoButtonColor=false, Parent=list,
                    })
                    item.MouseEnter:Connect(function()
                        item.BackgroundColor3=Theme.DropHover; item.TextColor3=Theme.DropHoverText
                    end)
                    item.MouseLeave:Connect(function()
                        item.BackgroundColor3=Theme.DropBg; item.TextColor3=Theme.DropText
                    end)
                    item.MouseButton1Click:Connect(function()
                        sel=opt; selTxt.Text=opt
                        isOpen=false; list.Visible=false; arrow.Text="▼"; cb(sel)
                    end)
                end
            end
            Build(opts)

            local function Open()
                local ap=box.AbsolutePosition; local as=box.AbsoluteSize
                list.Size     = UDim2.new(0, as.X, 0, listH)
                list.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
                list.Visible  = true; isOpen=true; arrow.Text="▲"
            end
            local function Close()
                list.Visible=false; isOpen=false; arrow.Text="▼"
            end

            arrow.MouseButton1Click:Connect(function() if isOpen then Close() else Open() end end)
            New("TextButton",{
                Size=UDim2.new(1,-22,1,0), BackgroundTransparency=1,
                Text="", ZIndex=9, Parent=box,
            }).MouseButton1Click:Connect(function() if isOpen then Close() else Open() end end)
            UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 and isOpen then
                    task.defer(Close)
                end
            end)

            local o = {}
            function o:Set(v) sel=v; selTxt.Text=v; cb(v) end
            function o:Get() return sel end
            function o:Refresh(newOpts)
                opts=newOpts; listH=math.min(#newOpts,6)*22
                list.CanvasSize=UDim2.new(0,0,0,#newOpts*22)
                Build(newOpts)
            end
            return o
        end

        -- ────────────────────────── TEXTBOX ──────────────
        function Tab:AddTextbox(cfg)
            cfg = cfg or {}
            local text = cfg.Text        or "Textbox"
            local def  = cfg.Default     or ""
            local ph   = cfg.Placeholder or "Type here..."
            local eo   = cfg.EnterOnly   or false
            local cb   = cfg.Callback    or function() end
            local ctr  = Row(44, "Textbox")

            New("TextLabel", {
                Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
                Text=text, Font=Enum.Font.Gotham, TextSize=13,
                TextColor3=Theme.LabelText, TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=6, Parent=ctr,
            })
            local frame = New("Frame", {
                Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,18),
                BackgroundColor3=Theme.InputBg, BorderSizePixel=0, ZIndex=6, Parent=ctr,
            })
            Sunken(frame)
            local inp = New("TextBox", {
                Size=UDim2.new(1,-8,1,-4), Position=UDim2.new(0,4,0,2),
                BackgroundTransparency=1, Text=def,
                PlaceholderText=ph, PlaceholderColor3=Theme.InputPh,
                Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.InputText,
                TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false,
                ZIndex=7, Parent=frame,
            })
            if eo then
                inp.FocusLost:Connect(function(enter) if enter then cb(inp.Text) end end)
            else
                inp:GetPropertyChangedSignal("Text"):Connect(function() cb(inp.Text) end)
            end
            local o = {}
            function o:Set(v) inp.Text = v end
            function o:Get() return inp.Text end
            return o
        end

        -- ────────────────────────── KEYBIND ──────────────
        function Tab:AddKeybind(cfg)
            cfg = cfg or {}
            local text   = cfg.Text     or "Keybind"
            local key    = cfg.Default  or Enum.KeyCode.Unknown
            local cb     = cfg.Callback or function() end
            local listen = false
            local row    = Row(24, "Keybind")

            New("TextLabel", {
                Size=UDim2.new(0.55,0,1,0), BackgroundTransparency=1,
                Text=text, Font=Enum.Font.Gotham, TextSize=13,
                TextColor3=Theme.LabelText, TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=6, Parent=row,
            })
            local kBtn = New("TextButton", {
                Size=UDim2.new(0.43,0,0,20), Position=UDim2.new(0.57,0,0.5,-10),
                BackgroundColor3=Theme.BtnFace, BorderSizePixel=0,
                Text=key.Name, Font=Enum.Font.Gotham, TextSize=12,
                TextColor3=Theme.BtnText, ZIndex=6, Parent=row,
            })
            Sunken(kBtn)
            kBtn.MouseButton1Click:Connect(function()
                listen=true; kBtn.Text="[ ... ]"; kBtn.TextColor3=Theme.TabAccent
            end)
            UserInputService.InputBegan:Connect(function(i, gpe)
                if listen and i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode; kBtn.Text=key.Name; kBtn.TextColor3=Theme.BtnText; listen=false
                elseif not listen and not gpe and i.KeyCode==key then cb() end
            end)
            local o = {}
            function o:Set(k) key=k; kBtn.Text=k.Name end
            function o:Get() return key end
            return o
        end

        -- ────────────────────────── COLOR PICKER ─────────
        function Tab:AddColorPicker(cfg)
            cfg = cfg or {}
            local text = cfg.Text     or "Color"
            local def  = cfg.Default  or Color3.fromRGB(255, 0, 0)
            local cb   = cfg.Callback or function() end
            local open = false
            local cur  = def
            local r = math.floor(def.R*255+.5)
            local g = math.floor(def.G*255+.5)
            local b = math.floor(def.B*255+.5)

            local hRow = Row(24, "ColorPicker")
            New("TextLabel", {
                Size=UDim2.new(0.65,0,1,0), BackgroundTransparency=1,
                Text=text, Font=Enum.Font.Gotham, TextSize=13,
                TextColor3=Theme.LabelText, TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=6, Parent=hRow,
            })
            local prev = New("Frame", {
                Size=UDim2.new(0,44,0,18), Position=UDim2.new(1,-44,0.5,-9),
                BackgroundColor3=cur, BorderSizePixel=0, ZIndex=6, Parent=hRow,
            })
            Sunken(prev)

            Tab._n = Tab._n + 1
            local panel = New("Frame", {
                Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1, BorderSizePixel=0,
                Visible=false, LayoutOrder=Tab._n, ZIndex=5, Parent=scroll,
            })
            New("UIListLayout", { Padding=UDim.new(0,2), Parent=panel })

            local function Refresh()
                cur=Color3.fromRGB(r,g,b); prev.BackgroundColor3=cur; cb(cur)
            end

            for _, ch in ipairs({
                {"R", Color3.fromRGB(200,40,40),  function(v) r=v end, function() return r end},
                {"G", Color3.fromRGB(40,160,40),  function(v) g=v end, function() return g end},
                {"B", Color3.fromRGB(40,100,220), function(v) b=v end, function() return b end},
            }) do
                local cr = New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Parent=panel})
                New("TextLabel",{Size=UDim2.new(0,12,1,0),BackgroundTransparency=1,
                    Text=ch[1],Font=Enum.Font.GothamBold,TextSize=12,TextColor3=ch[2],ZIndex=6,Parent=cr})
                local tr = New("Frame",{Size=UDim2.new(1,-44,0,10),Position=UDim2.new(0,14,0.5,-5),
                    BackgroundColor3=Theme.SliderTrack,BorderSizePixel=0,ZIndex=6,Parent=cr})
                Sunken(tr)
                local fi = New("Frame",{Size=UDim2.new(ch[4]()/255,0,1,0),
                    BackgroundColor3=ch[2],BorderSizePixel=0,ZIndex=7,Parent=tr})
                local vl = New("TextLabel",{Size=UDim2.new(0,28,1,0),Position=UDim2.new(1,-28,0,0),
                    BackgroundTransparency=1,Text=tostring(ch[4]()),
                    Font=Enum.Font.Gotham,TextSize=11,TextColor3=Theme.LabelText,
                    TextXAlignment=Enum.TextXAlignment.Right,ZIndex=6,Parent=cr})
                local sl = false
                local function setV(mx2)
                    local rel=math.clamp((mx2-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
                    local v=math.floor(rel*255+.5)
                    fi.Size=UDim2.new(rel,0,1,0); vl.Text=tostring(v); ch[3](v); Refresh()
                end
                tr.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true; setV(i.Position.X) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sl and i.UserInputType==Enum.UserInputType.MouseMovement then setV(i.Position.X) end
                end)
            end

            local hit = New("TextButton",{
                Size=UDim2.new(0,44,0,18),Position=UDim2.new(1,-44,0.5,-9),
                BackgroundTransparency=1,Text="",ZIndex=10,Parent=hRow,
            })
            hit.MouseButton1Click:Connect(function() open=not open; panel.Visible=open end)

            local o = {}
            function o:Set(c)
                cur=c; prev.BackgroundColor3=c
                r=math.floor(c.R*255+.5); g=math.floor(c.G*255+.5); b=math.floor(c.B*255+.5); cb(c)
            end
            function o:Get() return cur end
            return o
        end

        -- ────────────────────────── LABEL ────────────────
        function Tab:AddLabel(text)
            Tab._n = Tab._n + 1
            local lbl = New("TextLabel", {
                Name               = "Lbl_" .. Tab._n,
                Size               = UDim2.new(1, 0, 0, 18),
                AutomaticSize      = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text               = text or "",
                Font               = Enum.Font.Gotham,
                TextSize           = 13,
                TextColor3         = Theme.LabelText,
                TextXAlignment     = Enum.TextXAlignment.Left,
                TextWrapped        = true,
                LayoutOrder        = Tab._n,
                ZIndex             = 5,
                Parent             = scroll,
            })
            local o = {}
            function o:Set(v) lbl.Text = v end
            function o:Get() return lbl.Text end
            return o
        end

        -- ────────────────────────── SECTION ──────────────
        function Tab:AddSection(text)
            Tab._n = Tab._n + 1
            local sec = New("Frame", {
                Name=text, Size=UDim2.new(1,0,0,22),
                BackgroundTransparency=1, BorderSizePixel=0,
                LayoutOrder=Tab._n, ZIndex=5, Parent=scroll,
            })
            New("TextLabel", {
                Size=UDim2.new(0,0,0,16), AutomaticSize=Enum.AutomaticSize.X,
                BackgroundTransparency=1, Text=text,
                Font=Enum.Font.GothamBold, TextSize=13, TextColor3=Theme.SecText,
                ZIndex=6, Parent=sec,
            })
            New("Frame", {
                Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-3),
                BackgroundColor3=Theme.SecLine, BorderSizePixel=0, ZIndex=5, Parent=sec,
            })
            New("Frame", {
                Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-2),
                BackgroundColor3=Theme.B_Bright, BorderSizePixel=0, ZIndex=5, Parent=sec,
            })
        end

        -- ────────────────────────── SEPARATOR ────────────
        function Tab:AddSeparator()
            Tab._n = Tab._n + 1
            local sep = New("Frame", {
                Name="Sep_"..Tab._n, Size=UDim2.new(1,0,0,8),
                BackgroundTransparency=1, BorderSizePixel=0,
                LayoutOrder=Tab._n, ZIndex=5, Parent=scroll,
            })
            New("Frame", {
                Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,0),
                BackgroundColor3=Theme.B_Dark, BorderSizePixel=0, ZIndex=6, Parent=sep,
            })
            New("Frame", {
                Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,1),
                BackgroundColor3=Theme.B_Bright, BorderSizePixel=0, ZIndex=6, Parent=sep,
            })
        end

        return Tab
    end -- AddTab

    -- ══════════════════════════════════════════════════════════
    --  NOTIFY
    -- ══════════════════════════════════════════════════════════
    function Window:Notify(cfg)
        cfg = cfg or {}
        local ntitle = cfg.Title    or "Notification"
        local msg    = cfg.Message  or ""
        local dur    = cfg.Duration or 4
        local ntype  = cfg.Type     or "Info"

        local accs = {
            Info    = Color3.fromRGB(10,  36,  106),
            Success = Color3.fromRGB(0,   120, 0),
            Warning = Color3.fromRGB(180, 120, 0),
            Error   = Color3.fromRGB(170, 20,  0),
        }
        local acc = accs[ntype] or accs.Info

        self._notifSeq = self._notifSeq + 1
        local n = self._notifSeq

        local card = New("Frame", {
            Name=n, Size=UDim2.new(1,0,0,72),
            BackgroundColor3=Theme.NotifBg, BorderSizePixel=0,
            ZIndex=51, LayoutOrder=n, ClipsDescendants=true,
            Parent=self._notifHolder,
        })
        Raised(card)
        New("Frame", {
            Size=UDim2.new(0,4,1,0), BackgroundColor3=acc,
            BorderSizePixel=0, ZIndex=52, Parent=card,
        })
        local tbar = New("Frame", {
            Size=UDim2.new(1,0,0,22), BackgroundColor3=acc,
            BorderSizePixel=0, ZIndex=52, Parent=card,
        })
        New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, acc),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(
                    math.min(acc.R*255+70,255),
                    math.min(acc.G*255+70,255),
                    math.min(acc.B*255+70,255)
                )),
            }),
            Rotation=0, Parent=tbar,
        })
        New("TextLabel", {
            Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,8,0,0),
            BackgroundTransparency=1, Text=ntitle,
            Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.new(1,1,1),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=53, Parent=tbar,
        })
        local xBtn = New("TextButton", {
            Size=UDim2.new(0,16,0,14), Position=UDim2.new(1,-18,0.5,-7),
            BackgroundColor3=Color3.fromRGB(160,50,20), BorderSizePixel=0,
            Text="✕", Font=Enum.Font.GothamBold, TextSize=9,
            TextColor3=Color3.new(1,1,1), ZIndex=54, Parent=tbar,
        })
        New("TextLabel", {
            Size=UDim2.new(1,-14,0,32), Position=UDim2.new(0,10,0,26),
            BackgroundTransparency=1, Text=msg,
            Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.NotifText,
            TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
            ZIndex=53, Parent=card,
        })
        local pbBg = New("Frame", {
            Size=UDim2.new(1,-10,0,3), Position=UDim2.new(0,5,1,-5),
            BackgroundColor3=Theme.B_Light, BorderSizePixel=0, ZIndex=53, Parent=card,
        })
        local pbF = New("Frame", {
            Size=UDim2.new(1,0,1,0), BackgroundColor3=acc,
            BorderSizePixel=0, ZIndex=54, Parent=pbBg,
        })
        TweenService:Create(pbF, TweenInfo.new(dur, Enum.EasingStyle.Linear),
            {Size=UDim2.new(0,0,1,0)}):Play()

        local function Dismiss()
            TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad),
                {Size=UDim2.new(1,0,0,0)}):Play()
            task.delay(0.22, function()
                if card and card.Parent then card:Destroy() end
            end)
        end
        xBtn.MouseButton1Click:Connect(Dismiss)
        task.delay(dur, Dismiss)
    end

    -- ══════════════════════════════════════════════════════════
    --  PUBLIC WINDOW METHODS
    -- ══════════════════════════════════════════════════════════
    function Window:Toggle()    shell.Visible = not shell.Visible end
    function Window:Destroy()   gui:Destroy() end
    function Window:SetTitle(t) titleLbl.Text = t end

    return Window
end

-- ══════════════════════════════════════════════════════════════
--  THEME API
-- ══════════════════════════════════════════════════════════════
function WinXP:SetTheme(overrides)
    for k, v in pairs(overrides or {}) do
        if Theme[k] ~= nil then Theme[k] = v end
    end
end

function WinXP:GetTheme()
    return Theme
end

return WinXP
