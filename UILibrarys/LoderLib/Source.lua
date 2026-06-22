-- LoderLib UI Library (v1.0)
-- Dark terminal-aesthetic UI library for Roblox executors.
-- API: Window > Tab > Section > Elements (Button, Toggle, Slider, Dropdown, Textbox, Label, Bind, Colorpicker, Separator)

---------------------------------------------------------------------
-- Services
---------------------------------------------------------------------
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Colour palette
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
    WHITE       = Color3.new(1, 1, 1),
    SLIDER_FILL = Color3.fromRGB(59, 125, 216),
    SLIDER_BG   = Color3.fromRGB(30,  34,  48),
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
    btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = hover}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = base}) end)
    btn.MouseButton1Down:Connect(function() tween(btn, 0.06, {BackgroundColor3 = C.ACCENT_DIM}) end)
    btn.MouseButton1Up:Connect(function() tween(btn, 0.06, {BackgroundColor3 = hover}) end)
end

---------------------------------------------------------------------
-- Library table
---------------------------------------------------------------------
local LoderLib = {}
LoderLib.__index = LoderLib

---------------------------------------------------------------------
-- Notification
---------------------------------------------------------------------
function LoderLib:Notification(title, message, btnText)
    local existing = PlayerGui:FindFirstChild("LoderLibNotif")
    if existing then existing:Destroy() end

    local sg = make("ScreenGui", {
        Name           = "LoderLibNotif",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, PlayerGui)

    local frame = make("Frame", {
        Size             = UDim2.new(0, 300, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Position         = UDim2.new(1, -320, 1, -20),
        AnchorPoint      = Vector2.new(0, 1),
        BackgroundColor3 = C.SURFACE,
        BorderSizePixel  = 0,
    }, sg)
    corner(8, frame)
    stroke(1, C.BORDER, frame)
    pad(14, 14, 16, 16, frame)
    listLayout(frame, Enum.FillDirection.Vertical, 8)

    -- Accent top bar
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
    }, frame)

    make("TextLabel", {
        Size                  = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text                  = title,
        TextColor3            = C.TEXT,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13,
        TextXAlignment        = Enum.TextXAlignment.Left,
        LayoutOrder           = 1,
    }, frame)

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
        LayoutOrder           = 2,
    }, frame)

    local ok = make("TextButton", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
        Text             = btnText or "OK",
        TextColor3       = C.WHITE,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        LayoutOrder      = 3,
    }, frame)
    corner(6, ok)
    ok.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Slide in from right
    frame.Position = UDim2.new(1, 20, 1, -20)
    tween(frame, 0.3, {Position = UDim2.new(1, -320, 1, -20)})

    task.delay(5, function()
        if sg and sg.Parent then
            tween(frame, 0.25, {Position = UDim2.new(1, 20, 1, -20)})
            task.wait(0.3)
            sg:Destroy()
        end
    end)
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

    -- Root window frame
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
    -- Cover bottom rounded corners of title bar
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

    -- Close
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

    -- Minimise
    local minBtn = make("TextButton", {
        Size                  = UDim2.new(0, 28, 0, 28),
        Position              = UDim2.new(1, -68, 0.5, -14),
        BackgroundTransparency = 1,
        Text                  = "─",
        TextColor3            = C.TEXT_DIM,
        Font                  = Enum.Font.GothamBold,
        TextSize              = 13,
    }, titleBar)

    local minimised = false
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
    -- Tab bar (horizontal pill tabs)
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

    -- Divider under tab bar
    make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 76),
        BackgroundColor3 = C.BORDER2,
        BorderSizePixel  = 0,
    }, win)

    ----------------------------------------------------------------
    -- Content area (pages live here)
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
    local winObj  = {_tabBtns = {}, _pages = {}, _activeTab = nil, _sg = sg, _lib = self}
    local tabCount = 0

    function winObj:Tab(tabName)
        tabCount += 1
        local order = tabCount

        -- Tab button
        local tabBtn = make("TextButton", {
            Size             = UDim2.new(0, 0, 1, -8),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundColor3 = C.SURFACE2,
            BorderSizePixel  = 0,
            Text             = "  " .. tabName .. "  ",
            TextColor3       = C.TEXT_DIM,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            LayoutOrder      = order,
        }, tabBar)
        corner(6, tabBtn)

        -- Page scroll frame
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
            self._activeTab = order
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        -- Auto-activate first tab
        if order == 1 then activateTab() end

        ----------------------------------------------------------------
        -- Tab object → Sections
        ----------------------------------------------------------------
        local tabObj = {_page = page, _sectionCount = 0}

        function tabObj:Section(sectionName)
            self._sectionCount += 1
            local secOrder = self._sectionCount

            -- Section card
            local sec = make("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = C.SURFACE,
                BorderSizePixel  = 0,
                LayoutOrder      = secOrder,
            }, self._page)
            corner(8, sec)
            stroke(1, C.BORDER2, sec)
            pad(10, 10, 12, 12, sec)
            listLayout(sec, Enum.FillDirection.Vertical, 6)

            -- Section header
            if sectionName and sectionName ~= "" then
                local hdr = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    LayoutOrder      = 0,
                }, sec)
                make("TextLabel", {
                    Size                  = UDim2.new(1, -4, 1, 0),
                    Position              = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text                  = sectionName:upper(),
                    TextColor3            = C.TEXT_DARK,
                    Font                  = Enum.Font.GothamBold,
                    TextSize              = 10,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                }, hdr)
                -- Thin accent line under header
                make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    Position         = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = C.BORDER2,
                    BorderSizePixel  = 0,
                }, hdr)
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
            function secObj:Label(text)
                local lo = nextOrder()
                make("TextLabel", {
                    Size                  = UDim2.new(1, 0, 0, 0),
                    AutomaticSize         = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text                  = text,
                    TextColor3            = C.TEXT_DIM,
                    Font                  = Enum.Font.Gotham,
                    TextSize              = 11,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    TextWrapped           = true,
                    LayoutOrder           = lo,
                }, sec)
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
                    Position         = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = C.WHITE,
                    BorderSizePixel  = 0,
                }, track)
                corner(7, thumb)

                local clickLayer = make("TextButton", {
                    Size                  = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                  = "",
                }, row)

                local togObj = {Value = state}

                local function updateVisual()
                    tween(track, 0.15, {BackgroundColor3 = state and C.TOGGLE_ON or C.TOGGLE_OFF})
                    tween(thumb, 0.15, {Position = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
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

                -- Track
                local trackBg = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    BackgroundColor3 = C.SLIDER_BG,
                    BorderSizePixel  = 0,
                    LayoutOrder      = 2,
                }, wrap)
                corner(3, trackBg)
                stroke(1, C.BORDER2, trackBg)

                local fill = make("Frame", {
                    Size             = UDim2.new((val - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = C.SLIDER_FILL,
                    BorderSizePixel  = 0,
                }, trackBg)
                corner(3, fill)

                -- Interaction
                local draggingSlider = false

                local function updateSlider(inputX)
                    local abs  = trackBg.AbsolutePosition.X
                    local size = trackBg.AbsoluteSize.X
                    local pct  = math.clamp((inputX - abs) / size, 0, 1)
                    val = math.floor(min + pct * (max - min))
                    valLabel.Text = tostring(val)
                    tween(fill, 0.05, {Size = UDim2.new(pct, 0, 1, 0)})
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
                    tween(fill, 0.1, {Size = UDim2.new(pct, 0, 1, 0)})
                    if callback then pcall(callback, val) end
                end

                return sliderObj
            end

            ----------------------------------------------------------------
            -- Textbox
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

                box.FocusLost:Connect(function(enter)
                    if callback then pcall(callback, box.Text) end
                end)

                local tbObj = {}
                function tbObj:SetText(t) box.Text = t end
                function tbObj:GetText() return box.Text end

                return tbObj
            end

            ----------------------------------------------------------------
            -- Dropdown
            ----------------------------------------------------------------
            function secObj:Dropdown(label, options, callback)
                local lo      = nextOrder()
                local selected = nil
                local open     = false

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

                -- Header
                local header = make("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    Text             = "",
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

                -- Dropdown list container
                local listContainer = make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0, 0, 0, 32),
                }, wrap)
                pad(0, 4, 8, 8, listContainer)
                listLayout(listContainer, Enum.FillDirection.Vertical, 3)

                local optionBtns = {}

                local function buildOptions()
                    for _, c in ipairs(listContainer:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    optionBtns = {}
                    for i, opt in ipairs(options) do
                        local optBtn = make("TextButton", {
                            Size             = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = C.SURFACE3,
                            BorderSizePixel  = 0,
                            Text             = opt,
                            TextColor3       = C.TEXT_DIM,
                            Font             = Enum.Font.Gotham,
                            TextSize         = 11,
                            LayoutOrder      = i,
                        }, listContainer)
                        corner(4, optBtn)
                        hoverBtn(optBtn, C.SURFACE3, C.BORDER2)
                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            selectedLabel.Text    = opt
                            selectedLabel.Visible = true
                            arrow.Text = "▾"
                            open = false
                            listContainer.Visible = false
                            if callback then pcall(callback, opt) end
                        end)
                        table.insert(optionBtns, optBtn)
                    end
                end

                buildOptions()
                listContainer.Visible = false

                header.MouseButton1Click:Connect(function()
                    open = not open
                    listContainer.Visible = open
                    tween(arrow, 0.15, {Rotation = open and 180 or 0})
                end)

                local dropObj = {Value = selected}

                function dropObj:Clear()
                    selected = nil
                    dropObj.Value = nil
                    selectedLabel.Text    = ""
                    selectedLabel.Visible = false
                end

                function dropObj:Add(opt)
                    table.insert(options, opt)
                    buildOptions()
                end

                function dropObj:Set(opt)
                    if table.find(options, opt) then
                        selected = opt
                        dropObj.Value = opt
                        selectedLabel.Text    = opt
                        selectedLabel.Visible = true
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
                local color = default or Color3.new(1, 1, 1)

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

                -- Simple HSV picker popup
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
                        Size             = UDim2.new(0, 220, 0, 180),
                        Position         = UDim2.new(0, row.AbsolutePosition.X, 0, row.AbsolutePosition.Y + 36),
                        BackgroundColor3 = C.SURFACE,
                        BorderSizePixel  = 0,
                        ZIndex           = 10,
                    }, sg:FindFirstChildOfClass("Frame") or win)
                    corner(8, pickerGui)
                    stroke(1, C.BORDER, pickerGui)
                    pad(10, 10, 10, 10, pickerGui)
                    listLayout(pickerGui, Enum.FillDirection.Vertical, 8)
                    pickerGui.ZIndex = 20

                    local h, s, v = Color3.toHSV(color)

                    local function rgbRow(ch, getter, setter, colAcc)
                        local rw = make("Frame", {
                            Size                  = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1,
                        }, pickerGui)
                        make("TextLabel", {
                            Size                  = UDim2.new(0, 16, 1, 0),
                            BackgroundTransparency = 1,
                            Text                  = ch,
                            TextColor3            = colAcc,
                            Font                  = Enum.Font.GothamBold,
                            TextSize              = 11,
                        }, rw)
                        local bg2 = make("Frame", {
                            Size             = UDim2.new(1, -50, 0, 6),
                            Position         = UDim2.new(0, 20, 0.5, -3),
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
                            Size                  = UDim2.new(0, 26, 1, 0),
                            Position              = UDim2.new(1, -26, 0, 0),
                            BackgroundTransparency = 1,
                            Text                  = tostring(math.floor(getter() * 255)),
                            TextColor3            = C.TEXT_DIM,
                            Font                  = Enum.Font.Code,
                            TextSize              = 10,
                            TextXAlignment        = Enum.TextXAlignment.Right,
                        }, rw)

                        local dragCh = false
                        bg2.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragCh = true
                                local pct = math.clamp((inp.Position.X - bg2.AbsolutePosition.X)/bg2.AbsoluteSize.X,0,1)
                                setter(pct)
                                fl2.Size = UDim2.new(pct, 0, 1, 0)
                                vLbl.Text = tostring(math.floor(pct*255))
                                color = Color3.fromHSV(h, s, v)
                                swatch.BackgroundColor3 = color
                                if callback then pcall(callback, color) end
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if dragCh and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                local pct = math.clamp((inp.Position.X - bg2.AbsolutePosition.X)/bg2.AbsoluteSize.X,0,1)
                                setter(pct)
                                fl2.Size = UDim2.new(pct, 0, 1, 0)
                                vLbl.Text = tostring(math.floor(pct*255))
                                color = Color3.fromHSV(h, s, v)
                                swatch.BackgroundColor3 = color
                                if callback then pcall(callback, color) end
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragCh = false end
                        end)
                    end

                    rgbRow("H", function() return h end, function(val) h = val end, Color3.fromRGB(224,92,92))
                    rgbRow("S", function() return s end, function(val) s = val end, Color3.fromRGB(92,184,92))
                    rgbRow("V", function() return v end, function(val) v = val end, Color3.fromRGB(126,200,227))

                    local doneBtn = make("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = C.ACCENT,
                        BorderSizePixel  = 0,
                        Text             = "Done",
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
                local lo      = nextOrder()
                local binding = default
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
