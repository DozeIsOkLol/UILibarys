-- LoderLib UI Library (v2.0)
-- Dark terminal-aesthetic UI library for Roblox executors.
--
-- Hierarchy:  Lib  >  Window  >  Tab  >  Section  >  Elements
--
-- Elements:
--   Button, ButtonGroup, Toggle, MultiToggle, Slider, Textbox,
--   Input (multiline), Dropdown, Colorpicker, Bind, Label,
--   Separator, Progress, Table
--
-- Window-level:
--   :Tab(name, icon?)  :Badge(tabObj, count)  :Destroy()
--
-- Library-level:
--   :Window()  :Notification()  :Dialog()  :SetTheme()

---------------------------------------------------------------------
-- Services
---------------------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Default colour palette
---------------------------------------------------------------------
local C = {
    BG          = Color3.fromRGB(13,  15,  23),
    SURFACE     = Color3.fromRGB(22,  25,  36),
    SURFACE2    = Color3.fromRGB(30,  34,  48),
    SURFACE3    = Color3.fromRGB(38,  43,  60),
    BORDER      = Color3.fromRGB(50,  55,  75),
    BORDER2     = Color3.fromRGB(38,  43,  58),
    ACCENT      = Color3.fromRGB(59, 125, 216),
    ACCENT_DIM  = Color3.fromRGB(40,  85, 160),
    ACCENT_BG   = Color3.fromRGB(20,  40,  80),
    TEXT        = Color3.fromRGB(220, 225, 235),
    TEXT_DIM    = Color3.fromRGB(120, 128, 150),
    TEXT_DARK   = Color3.fromRGB(65,  72,  95),
    OK          = Color3.fromRGB(92,  184,  92),
    WARN        = Color3.fromRGB(240, 180,  41),
    ERR         = Color3.fromRGB(224,  92,  92),
    INFO        = Color3.fromRGB(126, 200, 227),
    TOGGLE_OFF  = Color3.fromRGB(45,  50,  70),
    TOGGLE_ON   = Color3.fromRGB(59, 125, 216),
    RED_DOT     = Color3.fromRGB(224,  92,  92),
    YLW_DOT     = Color3.fromRGB(240, 180,  41),
    GRN_DOT     = Color3.fromRGB(92,  184,  92),
    WHITE       = Color3.new(1,1,1),
    SLIDER_BG   = Color3.fromRGB(30, 34, 48),
    BADGE_BG    = Color3.fromRGB(224, 92, 92),
    BADGE_TEXT  = Color3.new(1,1,1),
}

---------------------------------------------------------------------
-- Severity accent colours for notifications / dialog
---------------------------------------------------------------------
local SEVERITY = {
    info    = Color3.fromRGB(59,  125, 216),
    success = Color3.fromRGB(92,  184,  92),
    warning = Color3.fromRGB(240, 180,  41),
    error   = Color3.fromRGB(224,  92,  92),
}

---------------------------------------------------------------------
-- Utility helpers
---------------------------------------------------------------------
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(r, parent)
    return make("UICorner", {CornerRadius = UDim.new(0, r)}, parent)
end

local function stroke(t, col, parent)
    return make("UIStroke", {
        Thickness = t,
        Color = col,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function pad(top, bot, left, right, parent)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, top),
        PaddingBottom = UDim.new(0, bot),
        PaddingLeft   = UDim.new(0, left),
        PaddingRight  = UDim.new(0, right),
    }, parent)
end

local function listLayout(parent, dir, gap, sort)
    return make("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        SortOrder     = sort or Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, gap or 6),
    }, parent)
end

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end

local function hoverBtn(btn, base, hover)
    btn.MouseEnter:Connect(function()    tween(btn, 0.12, {BackgroundColor3 = hover})       end)
    btn.MouseLeave:Connect(function()    tween(btn, 0.12, {BackgroundColor3 = base})        end)
    btn.MouseButton1Down:Connect(function() tween(btn, 0.06, {BackgroundColor3 = C.ACCENT_DIM}) end)
    btn.MouseButton1Up:Connect(function()   tween(btn, 0.06, {BackgroundColor3 = hover})    end)
end

---------------------------------------------------------------------
-- Library table
---------------------------------------------------------------------
local LoderLib = {}
LoderLib.__index = LoderLib

---------------------------------------------------------------------
-- SetTheme  –  swap accent colour at runtime; affects all new elements
---------------------------------------------------------------------
function LoderLib:SetTheme(accentColor)
    C.ACCENT      = accentColor
    C.TOGGLE_ON   = accentColor
    C.SLIDER_FILL = accentColor
    -- Dim variant: darken by blending toward black
    C.ACCENT_DIM  = accentColor:Lerp(Color3.new(0,0,0), 0.35)
    C.ACCENT_BG   = accentColor:Lerp(Color3.new(0,0,0), 0.75)
end

---------------------------------------------------------------------
-- Notification  (severity: "info" | "success" | "warning" | "error")
---------------------------------------------------------------------
function LoderLib:Notification(title, message, btnText, severity, duration)
    severity = severity or "info"
    duration = duration or 5
    local accentCol = SEVERITY[severity] or C.ACCENT
    btnText = btnText or "OK"

    -- Stack notifications instead of replacing
    local yOffset = 20
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name:sub(1, 13) == "LoderLibNotif" then
            yOffset = yOffset + 110
        end
    end

    local uid = tostring(os.clock()):gsub("%.", "")
    local sg = make("ScreenGui", {
        Name           = "LoderLibNotif" .. uid,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, PlayerGui)

    local frame = make("Frame", {
        Size             = UDim2.new(0, 310, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Position         = UDim2.new(1, 20, 1, -yOffset),
        AnchorPoint      = Vector2.new(0, 1),
        BackgroundColor3 = C.SURFACE,
        BorderSizePixel  = 0,
    }, sg)
    corner(8, frame)
    stroke(1, C.BORDER, frame)
    pad(0, 12, 0, 0, frame)
    listLayout(frame, Enum.FillDirection.Vertical, 6)

    -- Coloured accent top bar
    local topBar = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
    }, frame)
    corner(8, topBar)

    -- Title row with severity icon
    local icons = {info = "ℹ", success = "✔", warning = "⚠", error = "✕"}
    local titleRow = make("Frame", {
        Size                  = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder           = 1,
    }, frame)
    pad(0, 0, 14, 14, titleRow)

    make("TextLabel", {
        Size                  = UDim2.new(0, 16, 1, 0),
        BackgroundTransparency = 1,
        Text                  = icons[severity] or "ℹ",
        TextColor3            = accentCol,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 12,
        TextXAlignment        = Enum.TextXAlignment.Left,
    }, titleRow)

    make("TextLabel", {
        Size                  = UDim2.new(1, -20, 1, 0),
        Position              = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text                  = title,
        TextColor3            = C.TEXT,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13,
        TextXAlignment        = Enum.TextXAlignment.Left,
    }, titleRow)

    -- Message
    local msgWrap = make("Frame", {
        Size                  = UDim2.new(1, 0, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder           = 2,
    }, frame)
    pad(0, 0, 14, 14, msgWrap)

    make("TextLabel", {
        Size                  = UDim2.new(1, 0, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text                  = message,
        TextColor3            = C.TEXT_DIM,
        Font                  = Enum.Font.Gotham,
        TextSize              = 11,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextWrapped           = true,
    }, msgWrap)

    -- Progress bar (auto-dismiss timer visual)
    local progressBg = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = C.SURFACE3,
        BorderSizePixel  = 0,
        LayoutOrder      = 3,
    }, frame)
    local progressFill = make("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
    }, progressBg)

    -- Button row
    local btnRow = make("Frame", {
        Size                  = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder           = 4,
    }, frame)
    pad(0, 0, 12, 12, btnRow)
    listLayout(btnRow, Enum.FillDirection.Horizontal, 6)

    local okBtn = make("TextButton", {
        Size             = UDim2.new(0, 70, 1, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        Text             = btnText,
        TextColor3       = C.WHITE,
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        LayoutOrder      = 1,
    }, btnRow)
    corner(5, okBtn)
    okBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Slide in
    tween(frame, 0.3, {Position = UDim2.new(1, -330, 1, -yOffset)})

    -- Countdown bar
    TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    task.delay(duration, function()
        if sg and sg.Parent then
            tween(frame, 0.25, {Position = UDim2.new(1, 20, 1, -yOffset)})
            task.wait(0.3)
            sg:Destroy()
        end
    end)

    return sg
end

---------------------------------------------------------------------
-- Dialog  –  modal confirm/cancel popup
-- buttons = { {text="Confirm", color=C.ACCENT, callback=fn}, ... }
---------------------------------------------------------------------
function LoderLib:Dialog(title, message, buttons)
    buttons = buttons or {{text = "OK", callback = nil}}

    local sg = make("ScreenGui", {
        Name           = "LoderLibDialog",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, PlayerGui)

    -- Dim overlay
    local overlay = make("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.5,
        BorderSizePixel  = 0,
        ZIndex           = 50,
    }, sg)

    local box = make("Frame", {
        Size             = UDim2.new(0, 340, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Position         = UDim2.new(0.5, -170, 0.5, -80),
        BackgroundColor3 = C.SURFACE,
        BorderSizePixel  = 0,
        ZIndex           = 51,
    }, sg)
    corner(10, box)
    stroke(1, C.BORDER, box)
    pad(18, 18, 20, 20, box)
    listLayout(box, Enum.FillDirection.Vertical, 12)

    -- Accent stripe
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
    }, box)

    make("TextLabel", {
        Size                  = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text                  = title,
        TextColor3            = C.TEXT,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 15,
        TextXAlignment        = Enum.TextXAlignment.Left,
        LayoutOrder           = 1,
    }, box)

    make("TextLabel", {
        Size                  = UDim2.new(1, 0, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text                  = message,
        TextColor3            = C.TEXT_DIM,
        Font                  = Enum.Font.Gotham,
        TextSize              = 12,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextWrapped           = true,
        LayoutOrder           = 2,
    }, box)

    -- Button row
    local brow = make("Frame", {
        Size                  = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder           = 3,
    }, box)
    listLayout(brow, Enum.FillDirection.Horizontal, 8)

    for i, def in ipairs(buttons) do
        local bCol = def.color or C.ACCENT
        local b = make("TextButton", {
            Size             = UDim2.new(0, 90, 1, 0),
            BackgroundColor3 = bCol,
            BorderSizePixel  = 0,
            Text             = def.text or "OK",
            TextColor3       = C.WHITE,
            Font             = Enum.Font.GothamBold,
            TextSize         = 12,
            LayoutOrder      = i,
        }, brow)
        corner(6, b)
        hoverBtn(b, bCol, bCol:Lerp(Color3.new(1,1,1), 0.1))
        b.MouseButton1Click:Connect(function()
            sg:Destroy()
            if def.callback then pcall(def.callback) end
        end)
    end

    -- Animate in
    box.Position = UDim2.new(0.5, -170, 0.5, -60)
    box.BackgroundTransparency = 1
    tween(box, 0.2, {Position = UDim2.new(0.5, -170, 0.5, -80), BackgroundTransparency = 0})

    return sg
end

---------------------------------------------------------------------
-- Window
---------------------------------------------------------------------
function LoderLib:Window(title, width, height)
    width  = width  or 520
    height = height or 580

    local sg = make("ScreenGui", {
        Name           = "LoderLib_" .. title:gsub("%s",""),
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, PlayerGui)

    local win = make("Frame", {
        Size             = UDim2.new(0, width, 0, height),
        Position         = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, sg)
    corner(10, win)
    stroke(1, C.BORDER, win)

    ----------------------------------------------------------------
    -- Title bar
    ----------------------------------------------------------------
    local titleBar = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.SURFACE,
        BorderSizePixel  = 0,
    }, win)
    corner(10, titleBar)
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = C.SURFACE,
        BorderSizePixel  = 0,
    }, titleBar)

    -- Traffic lights
    local dotsF = make("Frame", {
        Size                  = UDim2.new(0, 58, 0, 12),
        Position              = UDim2.new(0, 12, 0.5, -6),
        BackgroundTransparency = 1,
    }, titleBar)
    for i, col in ipairs({C.RED_DOT, C.YLW_DOT, C.GRN_DOT}) do
        local d = make("Frame", {
            Size             = UDim2.new(0, 10, 0, 10),
            Position         = UDim2.new(0, (i-1)*18, 0, 1),
            BackgroundColor3 = col,
            BorderSizePixel  = 0,
        }, dotsF)
        corner(5, d)
    end

    make("TextLabel", {
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                  = title,
        TextColor3            = C.TEXT_DIM,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 12,
        TextXAlignment        = Enum.TextXAlignment.Center,
    }, titleBar)

    -- Close + Minimise
    local closeBtn = make("TextButton", {
        Size                  = UDim2.new(0, 28, 0, 28),
        Position              = UDim2.new(1, -36, 0.5, -14),
        BackgroundTransparency = 1,
        Text                  = "✕",
        TextColor3            = C.TEXT_DIM,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13,
    }, titleBar)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local minBtn = make("TextButton", {
        Size                  = UDim2.new(0, 28, 0, 28),
        Position              = UDim2.new(1, -68, 0.5, -14),
        BackgroundTransparency = 1,
        Text                  = "─",
        TextColor3            = C.TEXT_DIM,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13,
    }, titleBar)

    local minimised  = false
    local normalSize = UDim2.new(0, width, 0, height)
    local miniSize   = UDim2.new(0, width, 0, 40)
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        tween(win, 0.2, {Size = minimised and miniSize or normalSize})
        minBtn.Text = minimised and "□" or "─"
    end)

    -- Drag
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    ----------------------------------------------------------------
    -- Tab bar
    ----------------------------------------------------------------
    local tabBar = make("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        Position         = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, win)
    pad(4, 4, 10, 10, tabBar)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 6),
    }, tabBar)

    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 76),
        BackgroundColor3 = C.BORDER2,
        BorderSizePixel  = 0,
    }, win)

    ----------------------------------------------------------------
    -- Content area
    ----------------------------------------------------------------
    local contentArea = make("Frame", {
        Size             = UDim2.new(1, 0, 1, -77),
        Position         = UDim2.new(0, 0, 0, 77),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, win)

    ----------------------------------------------------------------
    -- Window object
    ----------------------------------------------------------------
    local winObj   = {_tabBtns = {}, _pages = {}, _sg = sg, _lib = self}
    local tabCount = 0

    ----------------------------------------------------------------
    -- Badge helper  (call after Tab creation)
    -- winObj:Badge(tabObj, count)   count=0 hides it
    ----------------------------------------------------------------
    function winObj:Badge(tabObj, count)
        if tabObj._badgeLabel then
            tabObj._badgeLabel.Text    = tostring(count)
            tabObj._badgeLabel.Visible = count > 0
        end
    end

    ----------------------------------------------------------------
    -- Destroy window
    ----------------------------------------------------------------
    function winObj:Destroy()
        sg:Destroy()
    end

    ----------------------------------------------------------------
    -- Tab
    ----------------------------------------------------------------
    function winObj:Tab(tabName, icon)
        tabCount += 1
        local order = tabCount

        local displayText = icon and (icon .. "  " .. tabName) or tabName

        local tabBtn = make("TextButton", {
            Size             = UDim2.new(0, 0, 1, -8),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundColor3 = C.SURFACE2,
            BorderSizePixel  = 0,
            Text             = "  " .. displayText .. "  ",
            TextColor3       = C.TEXT_DIM,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            LayoutOrder      = order,
            ClipsDescendants = true,
        }, tabBar)
        corner(6, tabBtn)

        -- Badge dot
        local badge = make("TextLabel", {
            Size             = UDim2.new(0, 16, 0, 16),
            Position         = UDim2.new(1, -14, 0, -2),
            BackgroundColor3 = C.BADGE_BG,
            BorderSizePixel  = 0,
            Text             = "0",
            TextColor3       = C.BADGE_TEXT,
            Font             = Enum.Font.GothamBold,
            TextSize         = 9,
            TextXAlignment   = Enum.TextXAlignment.Center,
            Visible          = false,
            ZIndex           = 5,
        }, tabBtn)
        corner(8, badge)

        local page = make("ScrollingFrame", {
            Size               = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel    = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.BORDER,
            CanvasSize         = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible            = false,
        }, contentArea)
        pad(10, 10, 10, 10, page)
        listLayout(page, Enum.FillDirection.Vertical, 8)

        table.insert(self._tabBtns, tabBtn)
        table.insert(self._pages,   page)

        local function activateTab()
            for _, btn in ipairs(self._tabBtns) do
                tween(btn, 0.15, {BackgroundColor3 = C.SURFACE2, TextColor3 = C.TEXT_DIM})
            end
            for _, pg in ipairs(self._pages) do pg.Visible = false end
            tween(tabBtn, 0.15, {BackgroundColor3 = C.ACCENT, TextColor3 = C.WHITE})
            page.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(activateTab)
        if order == 1 then activateTab() end

        ----------------------------------------------------------------
        -- Tab object
        ----------------------------------------------------------------
        local tabObj = {_page = page, _sectionCount = 0, _badgeLabel = badge}

        ----------------------------------------------------------------
        -- Section
        ----------------------------------------------------------------
        function tabObj:Section(sectionName, collapsible)
            self._sectionCount += 1
            local secOrder = self._sectionCount
            local collapsed = false

            local sec = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
                LayoutOrder      = secOrder,
                ClipsDescendants = collapsible or false,
            }, self._page)
            corner(8, sec)
            stroke(1, C.BORDER2, sec)
            pad(10, 10, 12, 12, sec)
            listLayout(sec, Enum.FillDirection.Vertical, 6)

            -- Section header
            local headerHeight = 20
            if sectionName and sectionName ~= "" then
                local hdr = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, headerHeight),
                    BackgroundTransparency = 1,
                    LayoutOrder      = 0,
                }, sec)

                make("TextLabel", {
                    Size                  = UDim2.new(1, collapsible and -20 or -4, 1, 0),
                    Position              = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = sectionName:upper(),
                    TextColor3            = C.TEXT_DARK,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 10,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, hdr)

                make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    Position         = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = C.BORDER2,
                    BorderSizePixel  = 0,
                }, hdr)

                -- Collapse arrow
                if collapsible then
                    local arrow = make("TextLabel", {
                        Size                  = UDim2.new(0, 16, 1, 0),
                        Position              = UDim2.new(1, -16, 0, 0),
                        BackgroundTransparency = 1,
                        Text                  = "▾",
                        TextColor3            = C.TEXT_DARK,
                        Font                  = Enum.Font.GothamBold,
                        TextSize              = 12,
                        TextXAlignment        = Enum.TextXAlignment.Center,
                    }, hdr)

                    local clickArea = make("TextButton", {
                        Size                  = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text                  = "",
                    }, hdr)

                    clickArea.MouseButton1Click:Connect(function()
                        collapsed = not collapsed
                        tween(arrow, 0.15, {Rotation = collapsed and -90 or 0})
                        if collapsed then
                            -- collapse: fix size to header only, hide content
                            sec.AutomaticSize = Enum.AutomaticSize.None
                            tween(sec, 0.2, {Size = UDim2.new(1, 0, 0, headerHeight + 22)})
                        else
                            sec.AutomaticSize = Enum.AutomaticSize.Y
                            sec.Size = UDim2.new(1, 0, 0, 0)
                        end
                    end)
                end
            end

            local elemCount = 0
            local secObj = {_sec = sec}

            local function nextOrder()
                elemCount += 1
                return elemCount
            end

            ----------------------------------------------------------------
            -- Button
            ----------------------------------------------------------------
            function secObj:Button(label, callback)
                local lo = nextOrder()
                local btn = make("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    Text             = label,
                    TextColor3       = C.TEXT,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 12,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, btn)
                stroke(1, C.BORDER2, btn)
                hoverBtn(btn, C.SURFACE2, C.SURFACE3)
                btn.MouseButton1Click:Connect(function()
                    if callback then pcall(callback) end
                end)
                return btn
            end

            ----------------------------------------------------------------
            -- ButtonGroup  –  horizontal row of equal-width buttons
            -- defs = { {text="A", callback=fn}, ... }
            ----------------------------------------------------------------
            function secObj:ButtonGroup(defs)
                local lo  = nextOrder()
                local row = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                listLayout(row, Enum.FillDirection.Horizontal, 6)
                make("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder     = Enum.SortOrder.LayoutOrder,
                    Padding       = UDim.new(0, 6),
                }, row)

                local btnCount = #defs
                for i, def in ipairs(defs) do
                    local b = make("TextButton", {
                        Size             = UDim2.new(1/btnCount, -(6*(btnCount-1)/btnCount), 1, 0),
                        BackgroundColor3 = def.color or C.SURFACE2,
                        BorderSizePixel  = 0,
                        Text             = def.text or "Btn",
                        TextColor3       = def.textColor or C.TEXT,
                        Font             = Enum.Font.GothamBold,
                        TextSize         = 11,
                        LayoutOrder      = i,
                    }, row)
                    corner(6, b)
                    stroke(1, C.BORDER2, b)
                    hoverBtn(b, def.color or C.SURFACE2, C.SURFACE3)
                    b.MouseButton1Click:Connect(function()
                        if def.callback then pcall(def.callback) end
                    end)
                end
                return row
            end

            ----------------------------------------------------------------
            -- Separator
            ----------------------------------------------------------------
            function secObj:Separator()
                local lo = nextOrder()
                make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = C.BORDER2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
            end

            ----------------------------------------------------------------
            -- Label
            ----------------------------------------------------------------
            function secObj:Label(text, color)
                local lo = nextOrder()
                local lbl = make("TextLabel", {
                    Size                  = UDim2.new(1, 0, 0, 0),
                    AutomaticSize         = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text                  = text,
                    TextColor3            = color or C.TEXT_DIM,
                    Font                  = Enum.Font.Gotham,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextWrapped           = true,
                    LayoutOrder           = lo,
                }, sec)
                local lblObj = {}
                function lblObj:SetText(t) lbl.Text = t end
                function lblObj:SetColor(c) lbl.TextColor3 = c end
                return lblObj
            end

            ----------------------------------------------------------------
            -- Toggle
            ----------------------------------------------------------------
            function secObj:Toggle(label, default, callback)
                local lo    = nextOrder()
                local state = default or false

                local row = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, row)
                stroke(1, C.BORDER2, row)

                make("TextLabel", {
                    Size                  = UDim2.new(1, -56, 1, 0),
                    Position              = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, row)

                local track = make("Frame", {
                    Size             = UDim2.new(0, 36, 0, 20),
                    Position         = UDim2.new(1, -46, 0.5, -10),
                    BackgroundColor3 = state and C.TOGGLE_ON or C.TOGGLE_OFF,
                    BorderSizePixel  = 0,
                }, row)
                corner(10, track)

                local thumb = make("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = state and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7),
                    BackgroundColor3 = C.WHITE,
                    BorderSizePixel  = 0,
                }, track)
                corner(7, thumb)

                local clickLayer = make("TextButton", {
                    Size                  = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text                  = "",
                }, row)

                local togObj = {Value = state}

                local function updateVisual()
                    tween(track, 0.15, {BackgroundColor3 = state and C.TOGGLE_ON or C.TOGGLE_OFF})
                    tween(thumb, 0.15, {Position = state and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7)})
                end

                clickLayer.MouseButton1Click:Connect(function()
                    state = not state
                    togObj.Value = state
                    updateVisual()
                    if callback then pcall(callback, state) end
                end)

                function togObj:Set(val)
                    state = val
                    togObj.Value = val
                    updateVisual()
                    if callback then pcall(callback, state) end
                end

                return togObj
            end

            ----------------------------------------------------------------
            -- MultiToggle  –  checkbox group
            -- options = {"A","B","C"}   returns set of selected values
            ----------------------------------------------------------------
            function secObj:MultiToggle(label, options, defaults, callback)
                local lo      = nextOrder()
                local selected = {}
                for _, v in ipairs(defaults or {}) do selected[v] = true end

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)
                pad(8, 8, 10, 10, wrap)
                listLayout(wrap, Enum.FillDirection.Vertical, 4)

                make("TextLabel", {
                    Size                  = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    LayoutOrder           = 0,
                }, wrap)

                local mtObj = {Value = selected}

                for i, opt in ipairs(options) do
                    local isOn = selected[opt] or false

                    local row = make("Frame", {
                        Size             = UDim2.new(1, 0, 0, 24),
                        BackgroundTransparency = 1,
                        LayoutOrder      = i,
                    }, wrap)

                    local box = make("Frame", {
                        Size             = UDim2.new(0, 14, 0, 14),
                        Position         = UDim2.new(0, 0, 0.5, -7),
                        BackgroundColor3 = isOn and C.ACCENT or C.SURFACE3,
                        BorderSizePixel  = 0,
                    }, row)
                    corner(3, box)
                    stroke(1, C.BORDER, box)

                    local tick = make("TextLabel", {
                        Size                  = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text                  = "✔",
                        TextColor3            = C.WHITE,
                        Font                  = Enum.Font.GothamBold,
                        TextSize              = 9,
                        TextXAlignment        = Enum.TextXAlignment.Center,
                        Visible               = isOn,
                    }, box)

                    make("TextLabel", {
                        Size                  = UDim2.new(1, -22, 1, 0),
                        Position              = UDim2.new(0, 22, 0, 0),
                        BackgroundTransparency = 1,
                        Text                  = opt,
                        TextColor3            = C.TEXT_DIM,
                        Font                  = Enum.Font.Gotham,
                        TextSize              = 11,
                        TextXAlignment        = Enum.TextXAlignment.Left,
                    }, row)

                    local clk = make("TextButton", {
                        Size                  = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text                  = "",
                    }, row)

                    clk.MouseButton1Click:Connect(function()
                        isOn = not isOn
                        selected[opt] = isOn or nil
                        tween(box, 0.12, {BackgroundColor3 = isOn and C.ACCENT or C.SURFACE3})
                        tick.Visible = isOn
                        mtObj.Value = selected
                        if callback then pcall(callback, selected) end
                    end)
                end

                function mtObj:GetSelected()
                    local out = {}
                    for k, _ in pairs(selected) do table.insert(out, k) end
                    return out
                end

                return mtObj
            end

            ----------------------------------------------------------------
            -- Slider
            ----------------------------------------------------------------
            function secObj:Slider(label, min, max, default, callback)
                local lo  = nextOrder()
                min       = min     or 0
                max       = max     or 100
                default   = math.clamp(default or min, min, max)
                local val = default

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)
                pad(6, 6, 10, 10, wrap)
                listLayout(wrap, Enum.FillDirection.Vertical, 4)

                local topRow = make("Frame", {
                    Size                  = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    LayoutOrder           = 1,
                }, wrap)

                make("TextLabel", {
                    Size                  = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, topRow)

                local valLabel = make("TextLabel", {
                    Size                  = UDim2.new(0.3, 0, 1, 0),
                    Position              = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = tostring(val),
                    TextColor3            = C.ACCENT,
                    Font                  = Enum.Font.Code,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Right,
                }, topRow)

                local trackBg = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    BackgroundColor3 = C.SLIDER_BG,
                    BorderSizePixel  = 0,
                    LayoutOrder      = 2,
                }, wrap)
                corner(3, trackBg)
                stroke(1, C.BORDER2, trackBg)

                local fill = make("Frame", {
                    Size             = UDim2.new((val-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = C.ACCENT,
                    BorderSizePixel  = 0,
                }, trackBg)
                corner(3, fill)

                -- Thumb knob
                local thumb = make("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new((val-min)/(max-min), 0, 0.5, 0),
                    BackgroundColor3 = C.WHITE,
                    BorderSizePixel  = 0,
                    ZIndex           = 2,
                }, trackBg)
                corner(6, thumb)
                stroke(2, C.ACCENT, thumb)

                local draggingSlider = false

                local function updateSlider(inputX)
                    local abs  = trackBg.AbsolutePosition.X
                    local size = trackBg.AbsoluteSize.X
                    local pct  = math.clamp((inputX - abs) / size, 0, 1)
                    val = math.floor(min + pct * (max - min))
                    valLabel.Text = tostring(val)
                    tween(fill,  0.05, {Size     = UDim2.new(pct, 0, 1, 0)})
                    tween(thumb, 0.05, {Position = UDim2.new(pct, 0, 0.5, 0)})
                    if callback then pcall(callback, val) end
                end

                trackBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        updateSlider(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                local sliderObj = {Value = val}

                function sliderObj:Change(newVal)
                    newVal = math.clamp(newVal, min, max)
                    val = newVal
                    sliderObj.Value = val
                    local pct = (val - min) / (max - min)
                    valLabel.Text = tostring(val)
                    tween(fill,  0.1, {Size     = UDim2.new(pct, 0, 1, 0)})
                    tween(thumb, 0.1, {Position = UDim2.new(pct, 0, 0.5, 0)})
                    if callback then pcall(callback, val) end
                end

                return sliderObj
            end

            ----------------------------------------------------------------
            -- Textbox  (single-line)
            ----------------------------------------------------------------
            function secObj:Textbox(label, placeholder, clearOnFocus, callback)
                local lo = nextOrder()

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 54),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)
                pad(6, 6, 10, 10, wrap)
                listLayout(wrap, Enum.FillDirection.Vertical, 4)

                make("TextLabel", {
                    Size                  = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    LayoutOrder           = 1,
                }, wrap)

                local box = make("TextBox", {
                    Size              = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3  = C.SURFACE3,
                    BorderSizePixel   = 0,
                    Text              = "",
                    PlaceholderText   = placeholder or "Type here...",
                    PlaceholderColor3 = C.TEXT_DARK,
                    TextColor3        = C.INFO,
                    Font              = Enum.Font.Code,
                    TextSize          = 12,
                    TextXAlignment    = Enum.TextXAlignment.Left,
                    ClearTextOnFocus  = clearOnFocus or false,
                    LayoutOrder       = 2,
                }, wrap)
                corner(4, box)
                stroke(1, C.BORDER2, box)
                pad(0, 0, 8, 8, box)

                -- Focus highlight
                box.Focused:Connect(function()
                    tween(box, 0.1, {BackgroundColor3 = C.SURFACE})
                end)
                box.FocusLost:Connect(function()
                    tween(box, 0.1, {BackgroundColor3 = C.SURFACE3})
                    if callback then pcall(callback, box.Text) end
                end)

                local tbObj = {}
                function tbObj:SetText(t) box.Text = t end
                function tbObj:GetText() return box.Text end

                return tbObj
            end

            ----------------------------------------------------------------
            -- Input  (multi-line text area)
            ----------------------------------------------------------------
            function secObj:Input(label, placeholder, lines, callback)
                local lo    = nextOrder()
                lines       = lines or 4
                local rowH  = 16
                local totalH= 22 + (rowH * lines) + 8

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, totalH),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)
                pad(6, 8, 10, 10, wrap)
                listLayout(wrap, Enum.FillDirection.Vertical, 4)

                make("TextLabel", {
                    Size                  = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    LayoutOrder           = 1,
                }, wrap)

                local area = make("TextBox", {
                    Size              = UDim2.new(1, 0, 0, rowH * lines),
                    BackgroundColor3  = C.SURFACE3,
                    BorderSizePixel   = 0,
                    Text              = "",
                    PlaceholderText   = placeholder or "Enter text...",
                    PlaceholderColor3 = C.TEXT_DARK,
                    TextColor3        = C.INFO,
                    Font              = Enum.Font.Code,
                    TextSize          = 11,
                    TextXAlignment    = Enum.TextXAlignment.Left,
                    TextYAlignment    = Enum.TextYAlignment.Top,
                    MultiLine         = true,
                    ClearTextOnFocus  = false,
                    LayoutOrder       = 2,
                }, wrap)
                corner(4, area)
                stroke(1, C.BORDER2, area)
                pad(4, 4, 8, 8, area)

                area.Focused:Connect(function()    tween(area, 0.1, {BackgroundColor3 = C.SURFACE}) end)
                area.FocusLost:Connect(function()
                    tween(area, 0.1, {BackgroundColor3 = C.SURFACE3})
                    if callback then pcall(callback, area.Text) end
                end)

                local inObj = {}
                function inObj:SetText(t) area.Text = t end
                function inObj:GetText() return area.Text end

                return inObj
            end

            ----------------------------------------------------------------
            -- Progress bar
            -- :Set(percent)  0-100
            -- :SetLabel(text)
            ----------------------------------------------------------------
            function secObj:Progress(label, initial, color)
                local lo  = nextOrder()
                local pct = math.clamp(initial or 0, 0, 100)
                local col = color or C.ACCENT

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 46),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)
                pad(6, 6, 10, 10, wrap)
                listLayout(wrap, Enum.FillDirection.Vertical, 6)

                local topRow = make("Frame", {
                    Size                  = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    LayoutOrder           = 1,
                }, wrap)

                make("TextLabel", {
                    Size                  = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, topRow)

                local pctLabel = make("TextLabel", {
                    Size                  = UDim2.new(0.3, 0, 1, 0),
                    Position              = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = tostring(pct) .. "%",
                    TextColor3            = col,
                    Font                  = Enum.Font.Code,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Right,
                }, topRow)

                local trackBg = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 8),
                    BackgroundColor3 = C.SURFACE3,
                    BorderSizePixel  = 0,
                    LayoutOrder      = 2,
                }, wrap)
                corner(4, trackBg)
                stroke(1, C.BORDER2, trackBg)

                local fill = make("Frame", {
                    Size             = UDim2.new(pct/100, 0, 1, 0),
                    BackgroundColor3 = col,
                    BorderSizePixel  = 0,
                }, trackBg)
                corner(4, fill)

                local progObj = {Value = pct}

                function progObj:Set(newPct)
                    newPct = math.clamp(newPct, 0, 100)
                    pct = newPct
                    progObj.Value = pct
                    pctLabel.Text = tostring(math.floor(pct)) .. "%"
                    tween(fill, 0.3, {Size = UDim2.new(pct/100, 0, 1, 0)})
                end

                function progObj:SetLabel(text)
                    pctLabel.Text = text
                end

                function progObj:SetColor(newCol)
                    col = newCol
                    tween(fill, 0.15, {BackgroundColor3 = newCol})
                    pctLabel.TextColor3 = newCol
                end

                return progObj
            end

            ----------------------------------------------------------------
            -- Table  –  scrollable key/value or multi-column data table
            -- columns = {"Name","Value","Status"}
            -- :AddRow({"Alice","100","OK"})
            -- :Clear()
            ----------------------------------------------------------------
            function secObj:Table(columns, maxRows)
                local lo    = nextOrder()
                maxRows     = maxRows or 6
                local rowH  = 24
                local colW  = 1 / #columns

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)

                -- Header row
                local hdrRow = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = C.ACCENT_BG,
                    BorderSizePixel  = 0,
                }, wrap)
                corner(6, hdrRow)
                -- cover bottom corners
                make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 8),
                    Position         = UDim2.new(0, 0, 1, -8),
                    BackgroundColor3 = C.ACCENT_BG,
                    BorderSizePixel  = 0,
                }, hdrRow)
                for i, col in ipairs(columns) do
                    make("TextLabel", {
                        Size                  = UDim2.new(colW, 0, 1, 0),
                        Position              = UDim2.new(colW*(i-1), 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text                  = col:upper(),
                        TextColor3            = C.ACCENT,
                        Font                  = Enum.Font.GothamBold,
                        TextSize              = 10,
                        TextXAlignment        = Enum.TextXAlignment.Left,
                    }, hdrRow)
                end
                pad(0, 0, 10, 10, hdrRow)

                -- Body scroll
                local body = make("ScrollingFrame", {
                    Size               = UDim2.new(1, 0, 0, 0),
                    AutomaticSize      = Enum.AutomaticSize.Y,
                    Position           = UDim2.new(0, 0, 0, 26),
                    BackgroundTransparency = 1,
                    BorderSizePixel    = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = C.BORDER,
                    CanvasSize         = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                }, wrap)
                listLayout(body, Enum.FillDirection.Vertical, 0)

                local rowCount  = 0
                local tableObj  = {}

                function tableObj:AddRow(cells)
                    rowCount += 1
                    local even   = rowCount % 2 == 0
                    local rowBg  = even and C.SURFACE3 or C.SURFACE2

                    local row = make("Frame", {
                        Size             = UDim2.new(1, 0, 0, rowH),
                        BackgroundColor3 = rowBg,
                        BorderSizePixel  = 0,
                        LayoutOrder      = rowCount,
                    }, body)

                    pad(0, 0, 10, 10, row)

                    for i, cell in ipairs(cells) do
                        make("TextLabel", {
                            Size                  = UDim2.new(colW, 0, 1, 0),
                            Position              = UDim2.new(colW*(i-1), 0, 0, 0),
                            BackgroundTransparency = 1,
                            Text                  = tostring(cell),
                            TextColor3            = i == 1 and C.TEXT or C.TEXT_DIM,
                            Font                  = i == 1 and Enum.Font.GothamBold or Enum.Font.Code,
                            TextSize              = 11,
                            TextXAlignment        = Enum.TextXAlignment.Left,
                            TextTruncate          = Enum.TextTruncate.AtEnd,
                        }, row)
                    end

                    return row
                end

                function tableObj:Clear()
                    for _, c in ipairs(body:GetChildren()) do
                        if c:IsA("Frame") then c:Destroy() end
                    end
                    rowCount = 0
                end

                function tableObj:UpdateRow(index, cells)
                    local rows = {}
                    for _, c in ipairs(body:GetChildren()) do
                        if c:IsA("Frame") then table.insert(rows, c) end
                    end
                    if rows[index] then
                        local row = rows[index]
                        local labels = {}
                        for _, c in ipairs(row:GetChildren()) do
                            if c:IsA("TextLabel") then table.insert(labels, c) end
                        end
                        table.sort(labels, function(a,b) return a.Position.X.Scale < b.Position.X.Scale end)
                        for i, cell in ipairs(cells) do
                            if labels[i] then labels[i].Text = tostring(cell) end
                        end
                    end
                end

                return tableObj
            end

            ----------------------------------------------------------------
            -- Dropdown
            ----------------------------------------------------------------
            function secObj:Dropdown(label, options, callback)
                local lo       = nextOrder()
                local selected = nil
                local open     = false
                options        = options or {}

                local wrap = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, wrap)
                stroke(1, C.BORDER2, wrap)

                local header = make("TextButton", {
                    Size                  = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    Text                  = "",
                }, wrap)

                make("TextLabel", {
                    Size                  = UDim2.new(1, -40, 1, 0),
                    Position              = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT_DIM,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, header)

                local arrow = make("TextLabel", {
                    Size                  = UDim2.new(0, 20, 1, 0),
                    Position              = UDim2.new(1, -28, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = "▾",
                    TextColor3            = C.TEXT_DIM,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 14,
                    TextXAlignment        = Enum.TextXAlignment.Center,
                }, header)

                local selectedLabel = make("TextLabel", {
                    Size                  = UDim2.new(1, -40, 1, 0),
                    Position              = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = "",
                    TextColor3            = C.ACCENT,
                    Font                  = Enum.Font.Code,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    Visible               = false,
                }, header)

                -- Search box inside dropdown
                local searchBox = make("TextBox", {
                    Size              = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3  = C.SURFACE3,
                    BorderSizePixel   = 0,
                    Text              = "",
                    PlaceholderText   = "Search...",
                    PlaceholderColor3 = C.TEXT_DARK,
                    TextColor3        = C.TEXT,
                    Font              = Enum.Font.Code,
                    TextSize          = 11,
                    Visible           = false,
                    LayoutOrder       = 0,
                }, wrap)
                corner(4, searchBox)
                stroke(1, C.BORDER2, searchBox)
                pad(0, 0, 8, 8, searchBox)

                local listContainer = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 32),
                }, wrap)
                pad(0, 4, 8, 8, listContainer)
                listLayout(listContainer, Enum.FillDirection.Vertical, 3)

                local dropObj = {Value = selected}

                local function buildOptions(filter)
                    for _, c in ipairs(listContainer:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    local count = 0
                    for i, opt in ipairs(options) do
                        if not filter or filter == "" or opt:lower():find(filter:lower(), 1, true) then
                            count += 1
                            local optBtn = make("TextButton", {
                                Size             = UDim2.new(1, 0, 0, 26),
                                BackgroundColor3 = opt == selected and C.ACCENT_BG or C.SURFACE3,
                                BorderSizePixel  = 0,
                                Text             = opt,
                                TextColor3       = opt == selected and C.ACCENT or C.TEXT_DIM,
                                Font             = Enum.Font.Gotham,
                                TextSize         = 11,
                                LayoutOrder      = count,
                            }, listContainer)
                            corner(4, optBtn)
                            hoverBtn(optBtn, opt == selected and C.ACCENT_BG or C.SURFACE3, C.BORDER2)
                            optBtn.MouseButton1Click:Connect(function()
                                selected = opt
                                dropObj.Value = opt
                                selectedLabel.Text    = opt
                                selectedLabel.Visible = true
                                open = false
                                listContainer.Visible = false
                                searchBox.Visible = false
                                searchBox.Text = ""
                                tween(arrow, 0.15, {Rotation = 0})
                                buildOptions("")
                                if callback then pcall(callback, opt) end
                            end)
                        end
                    end
                end

                buildOptions("")
                listContainer.Visible = false

                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    buildOptions(searchBox.Text)
                end)

                header.MouseButton1Click:Connect(function()
                    open = not open
                    listContainer.Visible = open
                    searchBox.Visible = open
                    if open then searchBox:CaptureFocus() end
                    tween(arrow, 0.15, {Rotation = open and 180 or 0})
                end)

                function dropObj:Clear()
                    selected = nil
                    dropObj.Value = nil
                    selectedLabel.Text    = ""
                    selectedLabel.Visible = false
                    buildOptions("")
                end

                function dropObj:Add(opt)
                    table.insert(options, opt)
                    buildOptions(searchBox.Text)
                end

                function dropObj:Remove(opt)
                    for i, v in ipairs(options) do
                        if v == opt then table.remove(options, i) break end
                    end
                    if selected == opt then dropObj:Clear() end
                    buildOptions(searchBox.Text)
                end

                function dropObj:Set(opt)
                    if table.find(options, opt) then
                        selected = opt
                        dropObj.Value = opt
                        selectedLabel.Text    = opt
                        selectedLabel.Visible = true
                        buildOptions("")
                        if callback then pcall(callback, opt) end
                    end
                end

                return dropObj
            end

            ----------------------------------------------------------------
            -- Colorpicker
            ----------------------------------------------------------------
            function secObj:Colorpicker(label, default, callback)
                local lo    = nextOrder()
                local color = default or Color3.new(1,1,1)

                local row = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, row)
                stroke(1, C.BORDER2, row)
                pad(0, 0, 10, 10, row)

                make("TextLabel", {
                    Size                  = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, row)

                local swatch = make("Frame", {
                    Size             = UDim2.new(0, 26, 0, 18),
                    Position         = UDim2.new(1, -32, 0.5, -9),
                    BackgroundColor3 = color,
                    BorderSizePixel  = 0,
                }, row)
                corner(4, swatch)
                stroke(1, C.BORDER, swatch)

                local pickerOpen = false
                local pickerGui  = nil

                local clickLayer = make("TextButton", {
                    Size                  = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                  = "",
                }, row)

                local function closePicker()
                    if pickerGui then pickerGui:Destroy(); pickerGui = nil end
                    pickerOpen = false
                end

                clickLayer.MouseButton1Click:Connect(function()
                    if pickerOpen then closePicker(); return end
                    pickerOpen = true

                    pickerGui = make("Frame", {
                        Size             = UDim2.new(0, 230, 0, 200),
                        Position         = UDim2.new(0, row.AbsolutePosition.X, 0, row.AbsolutePosition.Y + 36),
                        BackgroundColor3 = C.SURFACE,
                        BorderSizePixel  = 0,
                        ZIndex           = 20,
                    }, sg:FindFirstChildOfClass("Frame") or win)
                    corner(8, pickerGui)
                    stroke(1, C.BORDER, pickerGui)
                    pad(12, 12, 12, 12, pickerGui)
                    listLayout(pickerGui, Enum.FillDirection.Vertical, 8)

                    local h, s, v = Color3.toHSV(color)

                    local hexBox = make("TextBox", {
                        Size              = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3  = C.SURFACE3,
                        BorderSizePixel   = 0,
                        Text              = string.format("%02X%02X%02X", color.R*255, color.G*255, color.B*255),
                        PlaceholderText   = "RRGGBB",
                        PlaceholderColor3 = C.TEXT_DARK,
                        TextColor3        = C.INFO,
                        Font              = Enum.Font.Code,
                        TextSize          = 12,
                        TextXAlignment    = Enum.TextXAlignment.Center,
                        ClearTextOnFocus  = true,
                    }, pickerGui)
                    corner(4, hexBox)
                    stroke(1, C.BORDER2, hexBox)

                    hexBox.FocusLost:Connect(function()
                        local hex = hexBox.Text:gsub("#","")
                        if #hex == 6 then
                            local r = tonumber(hex:sub(1,2),16)
                            local g = tonumber(hex:sub(3,4),16)
                            local b = tonumber(hex:sub(5,6),16)
                            if r and g and b then
                                color = Color3.fromRGB(r, g, b)
                                h, s, v = Color3.toHSV(color)
                                swatch.BackgroundColor3 = color
                                if callback then pcall(callback, color) end
                            end
                        end
                    end)

                    local function hsvRow(ch, getter, setter, colAcc)
                        local rw = make("Frame", {
                            Size                  = UDim2.new(1, 0, 0, 24),
                            BackgroundTransparency = 1,
                        }, pickerGui)

                        make("TextLabel", {
                            Size                  = UDim2.new(0, 14, 1, 0),
                            BackgroundTransparency = 1,
                            Text                  = ch,
                            TextColor3            = colAcc,
                            Font                  = Enum.Font.GothamBold,
                            TextSize              = 10,
                        }, rw)

                        local bg2 = make("Frame", {
                            Size             = UDim2.new(1, -54, 0, 6),
                            Position         = UDim2.new(0, 18, 0.5, -3),
                            BackgroundColor3 = C.SURFACE3,
                            BorderSizePixel  = 0,
                        }, rw)
                        corner(3, bg2)

                        local fl2 = make("Frame", {
                            Size             = UDim2.new(getter(), 0, 1, 0),
                            BackgroundColor3 = colAcc,
                            BorderSizePixel  = 0,
                        }, bg2)
                        corner(3, fl2)

                        local vLbl = make("TextLabel", {
                            Size                  = UDim2.new(0, 32, 1, 0),
                            Position              = UDim2.new(1, -32, 0, 0),
                            BackgroundTransparency = 1,
                            Text                  = tostring(math.floor(getter()*255)),
                            TextColor3            = C.TEXT_DIM,
                            Font                  = Enum.Font.Code,
                            TextSize              = 10,
                            TextXAlignment        = Enum.TextXAlignment.Right,
                        }, rw)

                        local dragC = false
                        bg2.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragC = true
                                local pct = math.clamp((inp.Position.X - bg2.AbsolutePosition.X)/bg2.AbsoluteSize.X,0,1)
                                setter(pct)
                                fl2.Size  = UDim2.new(pct,0,1,0)
                                vLbl.Text = tostring(math.floor(pct*255))
                                color = Color3.fromHSV(h,s,v)
                                swatch.BackgroundColor3 = color
                                hexBox.Text = string.format("%02X%02X%02X", color.R*255, color.G*255, color.B*255)
                                if callback then pcall(callback, color) end
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if dragC and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                local pct = math.clamp((inp.Position.X - bg2.AbsolutePosition.X)/bg2.AbsoluteSize.X,0,1)
                                setter(pct)
                                fl2.Size  = UDim2.new(pct,0,1,0)
                                vLbl.Text = tostring(math.floor(pct*255))
                                color = Color3.fromHSV(h,s,v)
                                swatch.BackgroundColor3 = color
                                hexBox.Text = string.format("%02X%02X%02X", color.R*255, color.G*255, color.B*255)
                                if callback then pcall(callback, color) end
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragC = false end
                        end)
                    end

                    hsvRow("H", function() return h end, function(val) h=val end, Color3.fromRGB(224,92,92))
                    hsvRow("S", function() return s end, function(val) s=val end, Color3.fromRGB(92,184,92))
                    hsvRow("V", function() return v end, function(val) v=val end, Color3.fromRGB(126,200,227))

                    local doneBtn = make("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = C.ACCENT,
                        BorderSizePixel  = 0,
                        Text             = "Apply",
                        TextColor3       = C.WHITE,
                        Font             = Enum.Font.GothamBold,
                        TextSize         = 12,
                    }, pickerGui)
                    corner(6, doneBtn)
                    doneBtn.MouseButton1Click:Connect(closePicker)
                end)

                local cpObj = {Value = color}

                function cpObj:Set(c)
                    color = c
                    cpObj.Value = c
                    swatch.BackgroundColor3 = c
                    if callback then pcall(callback, c) end
                end

                return cpObj
            end

            ----------------------------------------------------------------
            -- Keybind
            ----------------------------------------------------------------
            function secObj:Bind(label, default, callback)
                local lo       = nextOrder()
                local binding  = default
                local listening = false

                local row = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = C.SURFACE2,
                    BorderSizePixel  = 0,
                    LayoutOrder      = lo,
                }, sec)
                corner(6, row)
                stroke(1, C.BORDER2, row)
                pad(0, 0, 10, 10, row)

                make("TextLabel", {
                    Size                  = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                  = label,
                    TextColor3            = C.TEXT,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 12,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, row)

                local keyBtn = make("TextButton", {
                    Size             = UDim2.new(0, 80, 0, 22),
                    Position         = UDim2.new(1, -86, 0.5, -11),
                    BackgroundColor3 = C.SURFACE3,
                    BorderSizePixel  = 0,
                    Text             = binding and binding.Name or "None",
                    TextColor3       = C.ACCENT,
                    Font             = Enum.Font.Code,
                    TextSize         = 11,
                }, row)
                corner(4, keyBtn)
                stroke(1, C.BORDER2, keyBtn)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text       = "..."
                    keyBtn.TextColor3 = C.WARN
                end)

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        binding = inp.KeyCode
                        keyBtn.Text       = binding.Name
                        keyBtn.TextColor3 = C.ACCENT
                        listening = false
                    elseif not gpe and binding and inp.KeyCode == binding then
                        if callback then pcall(callback) end
                    end
                end)

                local bindObj = {Value = binding}

                function bindObj:Set(kc)
                    binding = kc
                    bindObj.Value = kc
                    keyBtn.Text = kc and kc.Name or "None"
                end

                return bindObj
            end

            return secObj
        end -- Section

        return tabObj
    end -- Tab

    return winObj
end -- Window

return LoderLib
