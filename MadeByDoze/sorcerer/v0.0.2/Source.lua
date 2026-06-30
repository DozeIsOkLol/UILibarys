-- ╔══════════════════════════════════════════╗
-- ║            SORCERERLIB v0.0.2            ║
-- ║      Clean Dark / Cyan Roblox UI Lib     ║
-- ╚══════════════════════════════════════════╝

local SorcererLib = {}
SorcererLib.__index = SorcererLib
SorcererLib.Version = "0.0.2"

-- ─── Services ───────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Debris           = game:GetService("Debris")
local LocalPlayer      = Players.LocalPlayer

-- ─── Theme ──────────────────────────────────
local Theme = {
    Background      = Color3.fromRGB(24, 24, 27),
    Header          = Color3.fromRGB(19, 19, 21),
    Section         = Color3.fromRGB(31, 31, 35),
    SectionHeader   = Color3.fromRGB(26, 26, 29),
    Element         = Color3.fromRGB(40, 40, 45),
    ElementHover    = Color3.fromRGB(50, 50, 56),
    ElementPressed  = Color3.fromRGB(33, 33, 37),
    Accent          = Color3.fromRGB(0, 210, 230),
    AccentDark      = Color3.fromRGB(0, 150, 165),
    AccentGlow      = Color3.fromRGB(80, 235, 250),
    Text            = Color3.fromRGB(235, 235, 240),
    TextDim         = Color3.fromRGB(145, 145, 155),
    TextDisabled    = Color3.fromRGB(85, 85, 95),
    BorderSubtle    = Color3.fromRGB(45, 45, 50),
    SliderTrack     = Color3.fromRGB(48, 48, 54),
    ToggleOff       = Color3.fromRGB(58, 58, 64),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    DropdownBG      = Color3.fromRGB(28, 28, 32),
    Success         = Color3.fromRGB(80, 220, 130),
    Warning         = Color3.fromRGB(230, 180, 60),
    Error           = Color3.fromRGB(235, 80, 90),

    WindowWidth     = 210,
    CornerRadius    = UDim.new(0, 6),
    ElementHeight   = 30,
    HeaderHeight    = 34,
    SectionHeaderH  = 28,
}

-- ─── Tween helpers ───────────────────────────
local function Tween(obj, props, t, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function MakeInstance(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function AddCorner(parent, radius)
    return MakeInstance("UICorner", {CornerRadius = radius or Theme.CornerRadius}, parent)
end

local function AddStroke(parent, color, thickness, transparency)
    return MakeInstance("UIStroke", {
        Color           = color or Theme.BorderSubtle,
        Thickness       = thickness or 1,
        Transparency    = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function AddPadding(parent, top, bottom, left, right)
    return MakeInstance("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 4),
        PaddingBottom = UDim.new(0, bottom or 4),
        PaddingLeft   = UDim.new(0, left   or 8),
        PaddingRight  = UDim.new(0, right  or 8),
    }, parent)
end

-- Soft drop-shadow using a 9-slice image (clean look, no flat outline)
local function AddShadow(parent)
    local shadow = MakeInstance("ImageLabel", {
        Name             = "Shadow",
        BackgroundTransparency = 1,
        Image            = "rbxassetid://6014261993",
        ImageColor3      = Color3.new(0, 0, 0),
        ImageTransparency = 0.45,
        ScaleType        = Enum.ScaleType.Slice,
        SliceCenter      = Rect.new(49, 49, 450, 450),
        Size             = UDim2.new(1, 40, 1, 40),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        ZIndex           = parent.ZIndex and (parent.ZIndex - 1) or 0,
    }, parent)
    return shadow
end

local function Ripple(button, light)
    local rip = MakeInstance("Frame", {
        Size                    = UDim2.new(0, 0, 0, 0),
        Position                = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint             = Vector2.new(0.5, 0.5),
        BackgroundColor3        = light and Color3.new(1,1,1) or Theme.Accent,
        BackgroundTransparency  = 0.7,
        ZIndex                  = (button.ZIndex or 1) + 10,
        BorderSizePixel         = 0,
    }, button)
    AddCorner(rip, UDim.new(1, 0))
    Tween(rip, {Size = UDim2.new(1.6, 0, 1.6, 0), BackgroundTransparency = 1}, 0.45, Enum.EasingStyle.Quad)
    Debris:AddItem(rip, 0.5)
end

-- ─── Dragging ────────────────────────────────
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ─── ScreenGui (singleton) ────────────────────
local function GetGui()
    local sg
    pcall(function()
        sg = game:GetService("CoreGui"):FindFirstChild("SorcererLib")
    end)
    if not sg then
        sg = MakeInstance("ScreenGui", {
            Name           = "SorcererLib",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
        })
        local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not ok or not sg.Parent then
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    return sg
end

local GUI = GetGui()

-- ─── Notification stack ───────────────────────
local NotifyHolder = MakeInstance("Frame", {
    Name                   = "Notifications",
    AnchorPoint            = Vector2.new(1, 1),
    Position               = UDim2.new(1, -16, 1, -16),
    Size                   = UDim2.new(0, 260, 1, -32),
    BackgroundTransparency = 1,
    ZIndex                 = 100,
}, GUI)
local NotifyLayout = MakeInstance("UIListLayout", {
    SortOrder       = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding         = UDim.new(0, 8),
}, NotifyHolder)

function SorcererLib:Notify(title, text, duration, kind)
    duration = duration or 4
    local accentColor = Theme.Accent
    if kind == "success" then accentColor = Theme.Success
    elseif kind == "warning" then accentColor = Theme.Warning
    elseif kind == "error" then accentColor = Theme.Error end

    local card = MakeInstance("Frame", {
        Name                   = "Notif",
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundColor3       = Theme.Background,
        BackgroundTransparency = 1,
        ZIndex                 = 101,
        ClipsDescendants       = true,
    }, NotifyHolder)
    AddCorner(card, UDim.new(0, 6))

    local accentBar = MakeInstance("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        ZIndex           = 102,
        BackgroundTransparency = 1,
    }, card)

    local titleLbl = MakeInstance("TextLabel", {
        Size                   = UDim2.new(1, -20, 0, 18),
        Position               = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = Theme.Text,
        TextTransparency       = 1,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 102,
    }, card)

    local bodyLbl = MakeInstance("TextLabel", {
        Size                   = UDim2.new(1, -20, 0, 0),
        Position               = UDim2.new(0, 12, 0, 26),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = Theme.TextDim,
        TextTransparency       = 1,
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextWrapped            = true,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 102,
    }, card)
    MakeInstance("UIPadding", {PaddingBottom = UDim.new(0, 10)}, card)

    Tween(card, {BackgroundTransparency = 0}, 0.2)
    Tween(accentBar, {BackgroundTransparency = 0}, 0.2)
    Tween(titleLbl, {TextTransparency = 0}, 0.25)
    Tween(bodyLbl, {TextTransparency = 0}, 0.25)
    AddStroke(card, Theme.BorderSubtle, 1)

    task.delay(duration, function()
        Tween(card, {BackgroundTransparency = 1}, 0.25)
        Tween(accentBar, {BackgroundTransparency = 1}, 0.25)
        Tween(titleLbl, {TextTransparency = 1}, 0.25)
        Tween(bodyLbl, {TextTransparency = 1}, 0.25)
        task.wait(0.27)
        card:Destroy()
    end)
end

-- ─── Global UI toggle (keybind to show/hide everything) ─────
local UIVisible = true
function SorcererLib:SetToggleKey(keycode)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keycode then
            UIVisible = not UIVisible
            for _, child in ipairs(GUI:GetChildren()) do
                if child:IsA("Frame") and child.Name:match("^Window_") then
                    child.Visible = UIVisible
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════
--  SorcererLib:NewWindow(title)
-- ════════════════════════════════════════════
function SorcererLib:NewWindow(title)

    local WindowFrame = MakeInstance("Frame", {
        Name                   = "Window_" .. title,
        Size                   = UDim2.new(0, Theme.WindowWidth, 0, Theme.HeaderHeight),
        Position               = UDim2.new(0.5, -Theme.WindowWidth/2, 0.15, 0),
        BackgroundColor3       = Theme.Background,
        BackgroundTransparency = 1,
        ClipsDescendants       = false,
        AutomaticSize          = Enum.AutomaticSize.Y,
        ZIndex                 = 2,
    }, GUI)
    AddCorner(WindowFrame, UDim.new(0, 7))
    AddShadow(WindowFrame)

    -- entrance animation
    Tween(WindowFrame, {BackgroundTransparency = 0}, 0.25)

    -- Header bar
    local Header = MakeInstance("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Header,
        ZIndex           = 4,
    }, WindowFrame)
    AddCorner(Header, UDim.new(0, 7))
    -- mask bottom corners of header square so only top is rounded
    MakeInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Header)

    local AccentDot = MakeInstance("Frame", {
        Size             = UDim2.new(0, 6, 0, 6),
        Position         = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = Theme.Accent,
        ZIndex           = 5,
    }, Header)
    AddCorner(AccentDot, UDim.new(1, 0))

    local HeaderLabel = MakeInstance("TextLabel", {
        Name                   = "Title",
        Size                   = UDim2.new(1, -50, 1, 0),
        Position               = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = Theme.Text,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
    }, Header)

    local Chevron = MakeInstance("TextLabel", {
        Name                   = "Chevron",
        Size                   = UDim2.new(0, 24, 0, 24),
        Position               = UDim2.new(1, -30, 0.5, -12),
        BackgroundTransparency = 1,
        Text                   = "—",
        TextColor3             = Theme.Accent,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 14,
        Rotation               = 0,
        ZIndex                 = 6,
    }, Header)

    local ChevHitbox = MakeInstance("TextButton", {
        Size                   = UDim2.new(0, 30, 1, 0),
        Position               = UDim2.new(1, -34, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 7,
    }, Header)

    -- Content container
    local Content = MakeInstance("Frame", {
        Name                   = "Content",
        Size                   = UDim2.new(1, 0, 0, 0),
        Position               = UDim2.new(0, 0, 0, Theme.HeaderHeight),
        BackgroundTransparency = 1,
        AutomaticSize          = Enum.AutomaticSize.Y,
        ClipsDescendants       = true,
        ZIndex                 = 2,
    }, WindowFrame)

    MakeInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 0),
    }, Content)
    MakeInstance("UIPadding", {PaddingBottom = UDim.new(0, 6)}, Content)

    -- Collapse window (whole content)
    local collapsed = false
    local function ToggleWindowCollapse()
        collapsed = not collapsed
        Tween(Chevron, {Rotation = collapsed and -90 or 0}, 0.25)
        if collapsed then
            Content.ClipsDescendants = true
            local tw = Tween(Content, {Size = UDim2.new(1, 0, 0, 0)}, 0.22)
            tw.Completed:Once(function()
                if collapsed then Content.Visible = false end
            end)
        else
            Content.Visible = true
            Content.Size = UDim2.new(1, 0, 0, 0)
            -- AutomaticSize recalculates true height; nothing else needed
        end
    end

    ChevHitbox.MouseButton1Click:Connect(ToggleWindowCollapse)
    MakeDraggable(WindowFrame, Header)

    -- ── Window Object ──────────────────────────
    local Window = {}
    Window._frame   = WindowFrame
    Window._content = Content

    function Window:Notify(t, body, dur, kind)
        SorcererLib:Notify(t, body, dur, kind)
    end

    function Window:SetTitle(newTitle)
        HeaderLabel.Text = newTitle
    end

    -- ════════════════════════════════════════
    --  Window:NewSection(name)
    -- ════════════════════════════════════════
    function Window:NewSection(name)
        local SectionFrame = MakeInstance("Frame", {
            Name                   = "Section_" .. name,
            Size                   = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize          = Enum.AutomaticSize.Y,
            ClipsDescendants       = false,
        }, Content)
        MakeInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 0),
        }, SectionFrame)

        local SectionHeader = MakeInstance("TextButton", {
            Name             = "SectionHeader",
            Size             = UDim2.new(1, 0, 0, Theme.SectionHeaderH),
            BackgroundColor3 = Theme.SectionHeader,
            Text             = "",
            AutoButtonColor  = false,
            LayoutOrder      = 0,
            ZIndex           = 3,
        }, SectionFrame)

        local SecLabel = MakeInstance("TextLabel", {
            Size                   = UDim2.new(1, -26, 1, 0),
            Position               = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text                   = name,
            TextColor3             = Theme.Text,
            Font                   = Enum.Font.GothamSemibold,
            TextSize               = 12,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 4,
        }, SectionHeader)

        local SecChevron = MakeInstance("TextLabel", {
            Size                   = UDim2.new(0, 20, 1, 0),
            Position               = UDim2.new(1, -24, 0, 0),
            BackgroundTransparency = 1,
            Text                   = "—",
            TextColor3             = Theme.Accent,
            Font                   = Enum.Font.GothamBold,
            TextSize               = 12,
            Rotation               = 0,
            ZIndex                 = 4,
        }, SectionHeader)

        local ElemContainer = MakeInstance("Frame", {
            Name             = "Elements",
            Size             = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Section,
            AutomaticSize    = Enum.AutomaticSize.Y,
            LayoutOrder      = 1,
            ClipsDescendants = true,
        }, SectionFrame)
        MakeInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 5),
        }, ElemContainer)
        MakeInstance("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
        }, ElemContainer)

        SectionHeader.MouseEnter:Connect(function()
            Tween(SectionHeader, {BackgroundColor3 = Theme.ElementHover}, 0.12)
        end)
        SectionHeader.MouseLeave:Connect(function()
            Tween(SectionHeader, {BackgroundColor3 = Theme.SectionHeader}, 0.12)
        end)

        local secCollapsed = false
        local function ToggleSec()
            secCollapsed = not secCollapsed
            Tween(SecChevron, {Rotation = secCollapsed and -90 or 0}, 0.22)
            if secCollapsed then
                local tw = Tween(ElemContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                tw.Completed:Once(function()
                    if secCollapsed then ElemContainer.Visible = false end
                end)
            else
                ElemContainer.Visible = true
            end
        end
        SectionHeader.MouseButton1Click:Connect(ToggleSec)

        -- ── Section Object ──────────────────────
        local Section = {}
        local elemOrder = 0
        local function NextOrder()
            elemOrder = elemOrder + 1
            return elemOrder
        end

        -- ┌───────────── Button ─────────────┐
        function Section:CreateButton(text, callback)
            local order = NextOrder()
            local btn = MakeInstance("TextButton", {
                Name             = "Button_" .. text,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundColor3 = Theme.Element,
                Text             = text,
                TextColor3       = Theme.Text,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 12,
                AutoButtonColor  = false,
                LayoutOrder      = order,
                ZIndex           = 4,
                ClipsDescendants = true,
            }, ElemContainer)
            AddCorner(btn, UDim.new(0, 5))

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.ElementHover}, 0.12)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.Element}, 0.12)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.ElementPressed}, 0.08)
                Ripple(btn)
            end)
            btn.MouseButton1Up:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.ElementHover}, 0.1)
            end)
            btn.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
            end)

            local btnObj = {}
            function btnObj:SetText(t) btn.Text = t end
            return btnObj
        end

        -- ┌───────────── Textbox ─────────────┐
        function Section:CreateTextbox(placeholder, callback)
            local order = NextOrder()
            local box = MakeInstance("TextBox", {
                Name               = "Textbox_" .. placeholder,
                Size               = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundColor3   = Theme.Element,
                PlaceholderText    = placeholder,
                PlaceholderColor3  = Theme.TextDim,
                Text               = "",
                TextColor3         = Theme.Text,
                Font               = Enum.Font.Gotham,
                TextSize           = 12,
                ClearTextOnFocus   = false,
                LayoutOrder        = order,
                ZIndex             = 4,
            }, ElemContainer)
            AddCorner(box, UDim.new(0, 5))
            AddPadding(box, 0, 0, 9, 9)
            local stroke = AddStroke(box, Theme.BorderSubtle, 1)

            box.Focused:Connect(function()
                Tween(box, {BackgroundColor3 = Theme.ElementHover}, 0.12)
                Tween(stroke, {Color = Theme.Accent}, 0.15)
            end)
            box.FocusLost:Connect(function(enter)
                Tween(box, {BackgroundColor3 = Theme.Element}, 0.12)
                Tween(stroke, {Color = Theme.BorderSubtle}, 0.15)
                if enter and callback then pcall(callback, box.Text) end
            end)

            local boxObj = {}
            function boxObj:Set(t) box.Text = t end
            function boxObj:Get() return box.Text end
            return boxObj
        end

        -- ┌───────────── Toggle ─────────────┐
        function Section:CreateToggle(labelText, callback, default)
            local order = NextOrder()
            local value = default or false

            local row = MakeInstance("TextButton", {
                Name             = "Toggle_" .. labelText,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight - 4),
                BackgroundTransparency = 1,
                Text             = "",
                LayoutOrder      = order,
            }, ElemContainer)

            MakeInstance("TextLabel", {
                Size                   = UDim2.new(1, -44, 1, 0),
                BackgroundTransparency = 1,
                Text                   = labelText,
                TextColor3             = Theme.Text,
                Font                   = Enum.Font.Gotham,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 4,
            }, row)

            local track = MakeInstance("Frame", {
                Size             = UDim2.new(0, 36, 0, 18),
                Position         = UDim2.new(1, -36, 0.5, -9),
                BackgroundColor3 = value and Theme.Accent or Theme.ToggleOff,
                ZIndex           = 4,
            }, row)
            AddCorner(track, UDim.new(1, 0))

            local knob = MakeInstance("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = Theme.ToggleKnob,
                ZIndex           = 5,
            }, track)
            AddCorner(knob, UDim.new(1, 0))

            local function SetValue(v, fire)
                value = v
                Tween(track, {BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff}, 0.18)
                Tween(knob, {Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.18, Enum.EasingStyle.Back)
                if fire ~= false and callback then pcall(callback, value) end
            end

            row.MouseButton1Click:Connect(function() SetValue(not value) end)

            local toggleObj = {Value = value}
            function toggleObj:Set(v) SetValue(v, true) end
            function toggleObj:Get() return value end
            return toggleObj
        end

        -- ┌───────────── Dropdown ─────────────┐
        function Section:CreateDropdown(labelText, options, defaultIndex, callback)
            local order = NextOrder()
            local selected = options[defaultIndex] or options[1]

            local row = MakeInstance("Frame", {
                Name             = "Dropdown_" .. labelText,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundColor3 = Theme.Element,
                LayoutOrder      = order,
                ClipsDescendants = false,
                ZIndex           = 6,
            }, ElemContainer)
            AddCorner(row, UDim.new(0, 5))

            local clickArea = MakeInstance("TextButton", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = "",
                ZIndex                 = 8,
            }, row)

            local selLabel = MakeInstance("TextLabel", {
                Size                   = UDim2.new(1, -28, 1, 0),
                Position               = UDim2.new(0, 9, 0, 0),
                BackgroundTransparency = 1,
                Text                   = selected,
                TextColor3             = Theme.Text,
                Font                   = Enum.Font.Gotham,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                ZIndex                 = 7,
            }, row)

            local arrow = MakeInstance("TextLabel", {
                Size                   = UDim2.new(0, 22, 1, 0),
                Position               = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text                   = "▾",
                TextColor3             = Theme.Accent,
                Font                   = Enum.Font.GothamBold,
                TextSize               = 13,
                Rotation               = 0,
                ZIndex                 = 7,
            }, row)

            local listFrame = MakeInstance("Frame", {
                Name             = "DropList",
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.DropdownBG,
                ZIndex           = 30,
                Visible          = false,
                ClipsDescendants = true,
            }, row)
            AddCorner(listFrame, UDim.new(0, 5))
            AddStroke(listFrame, Theme.BorderSubtle, 1)
            MakeInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 2),
            }, listFrame)
            MakeInstance("UIPadding", {
                PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
                PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4),
            }, listFrame)

            local isOpen = false
            local function BuildList()
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                local totalH = 8
                for i, opt in ipairs(options) do
                    local item = MakeInstance("TextButton", {
                        Name             = "Option_" .. tostring(opt),
                        Size             = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = opt == selected and Theme.ElementHover or Theme.DropdownBG,
                        Text             = tostring(opt),
                        TextColor3       = opt == selected and Theme.Accent or Theme.Text,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 12,
                        AutoButtonColor  = false,
                        LayoutOrder      = i,
                        ZIndex           = 31,
                    }, listFrame)
                    AddCorner(item, UDim.new(0, 4))
                    totalH = totalH + 26

                    item.MouseEnter:Connect(function()
                        if opt ~= selected then Tween(item, {BackgroundColor3 = Theme.ElementHover}, 0.1) end
                    end)
                    item.MouseLeave:Connect(function()
                        if opt ~= selected then Tween(item, {BackgroundColor3 = Theme.DropdownBG}, 0.1) end
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        selLabel.Text = tostring(opt)
                        isOpen = false
                        Tween(arrow, {Rotation = 0}, 0.18)
                        local tw = Tween(listFrame, {Size = UDim2.new(1,0,0,0)}, 0.16)
                        tw.Completed:Once(function() if not isOpen then listFrame.Visible = false end end)
                        BuildList()
                        if callback then pcall(callback, selected) end
                    end)
                end
                return totalH
            end

            local function ToggleDropdown()
                isOpen = not isOpen
                if isOpen then
                    local h = BuildList()
                    listFrame.Size    = UDim2.new(1, 0, 0, 0)
                    listFrame.Visible = true
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.2)
                    Tween(arrow, {Rotation = 180}, 0.2)
                else
                    Tween(arrow, {Rotation = 0}, 0.18)
                    local tw = Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.16)
                    tw.Completed:Once(function() if not isOpen then listFrame.Visible = false end end)
                end
            end

            clickArea.MouseButton1Click:Connect(ToggleDropdown)
            BuildList()

            local dropObj = {Value = selected}
            function dropObj:Set(v)
                selected = v
                selLabel.Text = tostring(v)
                BuildList()
            end
            function dropObj:SetOptions(newOpts)
                options = newOpts
                BuildList()
            end
            function dropObj:Get() return selected end
            return dropObj
        end

        -- ┌───────────── Slider ─────────────┐
        function Section:CreateSlider(labelText, min, max, default, integer, callback)
            local order = NextOrder()
            local value = math.clamp(default or min, min, max)

            local wrap = MakeInstance("Frame", {
                Name             = "Slider_" .. labelText,
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder      = order,
            }, ElemContainer)

            MakeInstance("TextLabel", {
                Size                   = UDim2.new(0.6, 0, 0, 16),
                BackgroundTransparency = 1,
                Text                   = labelText,
                TextColor3             = Theme.Text,
                Font                   = Enum.Font.Gotham,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 4,
            }, wrap)

            local valLabel = MakeInstance("TextLabel", {
                Size                   = UDim2.new(0.4, 0, 0, 16),
                Position               = UDim2.new(0.6, 0, 0, 0),
                BackgroundTransparency = 1,
                Text                   = integer and tostring(math.round(value)) or string.format("%.2f", value),
                TextColor3             = Theme.Accent,
                Font                   = Enum.Font.GothamSemibold,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Right,
                ZIndex                 = 4,
            }, wrap)

            local track = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 5),
                Position         = UDim2.new(0, 0, 0, 24),
                BackgroundColor3 = Theme.SliderTrack,
                ZIndex           = 4,
            }, wrap)
            AddCorner(track, UDim.new(1, 0))

            local fill = MakeInstance("Frame", {
                Size             = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                ZIndex           = 5,
            }, track)
            AddCorner(fill, UDim.new(1, 0))
            MakeInstance("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.AccentDark),
                    ColorSequenceKeypoint.new(1, Theme.AccentGlow),
                }),
            }, fill)

            local knob = MakeInstance("Frame", {
                Size             = UDim2.new(0, 12, 0, 12),
                Position         = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                BackgroundColor3 = Theme.ToggleKnob,
                ZIndex           = 6,
            }, track)
            AddCorner(knob, UDim.new(1, 0))

            local hitbox = MakeInstance("TextButton", {
                Size             = UDim2.new(1, 0, 0, 20),
                Position         = UDim2.new(0, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 7,
            }, wrap)

            local dragging = false
            local function UpdateSlider(inputX, fire)
                local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * rel
                if integer then value = math.round(value) end
                value = math.clamp(value, min, max)
                local pct = (value - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -6, 0.5, -6)
                valLabel.Text = integer and tostring(math.round(value)) or string.format("%.2f", value)
                if fire ~= false and callback then pcall(callback, value) end
            end

            hitbox.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(i.Position.X)
                    Tween(knob, {Size = UDim2.new(0, 15, 0, 15)}, 0.1)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                    Tween(knob, {Size = UDim2.new(0, 12, 0, 12)}, 0.12)
                end
            end)

            local sliderObj = {Value = value}
            function sliderObj:Set(v, fire)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.12)
                Tween(knob, {Position = UDim2.new(pct, -6, 0.5, -6)}, 0.12)
                valLabel.Text = integer and tostring(math.round(value)) or string.format("%.2f", value)
                if fire ~= false and callback then pcall(callback, value) end
            end
            function sliderObj:Get() return value end
            return sliderObj
        end

        -- ┌───────────── Color Picker ─────────────┐
        function Section:CreateColorPicker(labelText, defaultColor, callback)
            local order = NextOrder()
            local hue, sat, val = Color3.toHSV(defaultColor or Color3.new(1,1,1))
            local currentColor = defaultColor or Color3.new(1,1,1)
            local pickerOpen = false

            local row = MakeInstance("Frame", {
                Name             = "ColorPicker_" .. labelText,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundTransparency = 1,
                LayoutOrder      = order,
                ClipsDescendants = false,
            }, ElemContainer)

            MakeInstance("TextLabel", {
                Size                   = UDim2.new(1, -36, 1, 0),
                BackgroundTransparency = 1,
                Text                   = labelText,
                TextColor3             = Theme.Text,
                Font                   = Enum.Font.Gotham,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 4,
            }, row)

            local swatchBtn = MakeInstance("TextButton", {
                Size             = UDim2.new(0, 22, 0, 22),
                Position         = UDim2.new(1, -24, 0.5, -11),
                BackgroundColor3 = currentColor,
                Text             = "",
                ZIndex           = 4,
            }, row)
            AddCorner(swatchBtn, UDim.new(0, 5))
            AddStroke(swatchBtn, Theme.BorderSubtle, 1)

            local popup = MakeInstance("Frame", {
                Name             = "ColorPopup",
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.DropdownBG,
                ZIndex           = 25,
                Visible          = false,
                ClipsDescendants = true,
            }, row)
            AddCorner(popup, UDim.new(0, 6))
            AddStroke(popup, Theme.BorderSubtle, 1)
            MakeInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 7),
            }, popup)
            MakeInstance("UIPadding", {
                PaddingTop = UDim.new(0,9), PaddingBottom = UDim.new(0,9),
                PaddingLeft = UDim.new(0,9), PaddingRight = UDim.new(0,9),
            }, popup)

            local paletteFrame = MakeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 90), LayoutOrder = 1, ZIndex = 26,
            }, popup)
            local paletteBase = MakeInstance("ImageLabel", {
                Size  = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://3570695787",
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                ZIndex = 26,
            }, paletteFrame)
            AddCorner(paletteBase, UDim.new(0, 5))
            local paletteWhite = MakeInstance("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0), Image = "rbxassetid://3570695786",
                BackgroundTransparency = 1, ZIndex = 27,
            }, paletteBase)
            AddCorner(paletteWhite, UDim.new(0, 5))
            local paletteDark = MakeInstance("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0), Image = "rbxassetid://3570695785",
                BackgroundTransparency = 1, ZIndex = 28,
            }, paletteBase)
            AddCorner(paletteDark, UDim.new(0, 5))

            local palCursor = MakeInstance("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new(sat, -5, 1 - val, -5),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex           = 29,
            }, paletteBase)
            AddCorner(palCursor, UDim.new(1, 0))
            AddStroke(palCursor, Color3.new(0,0,0), 1.5)

            local hueBarFrame = MakeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2, ZIndex = 26,
            }, popup)
            local hueBar = MakeInstance("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0), Image = "rbxassetid://3570695789",
                BackgroundColor3 = Color3.new(1,1,1), ZIndex = 27,
            }, hueBarFrame)
            AddCorner(hueBar, UDim.new(1, 0))
            local hueCursor = MakeInstance("Frame", {
                Size             = UDim2.new(0, 6, 1, 4),
                Position         = UDim2.new(hue, -3, 0, -2),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex           = 28,
            }, hueBar)
            AddCorner(hueCursor, UDim.new(0, 3))
            AddStroke(hueCursor, Color3.new(0,0,0), 1)

            local hexRow = MakeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 3,
            }, popup)
            MakeInstance("TextLabel", {
                Size = UDim2.new(0.28, 0, 1, 0), BackgroundTransparency = 1,
                Text = "HEX", TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamSemibold, TextSize = 10, ZIndex = 26,
            }, hexRow)
            local hexBox = MakeInstance("TextBox", {
                Size = UDim2.new(0.72, 0, 1, 0), Position = UDim2.new(0.28, 0, 0, 0),
                BackgroundColor3 = Theme.Element, Text = "#FFFFFF",
                TextColor3 = Theme.Accent, Font = Enum.Font.GothamSemibold,
                TextSize = 11, ZIndex = 26,
            }, hexRow)
            AddCorner(hexBox, UDim.new(0, 4))
            AddPadding(hexBox, 0, 0, 7, 7)

            local function RefreshUI(fire)
                currentColor = Color3.fromHSV(hue, sat, val)
                swatchBtn.BackgroundColor3 = currentColor
                paletteBase.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                palCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                hueCursor.Position = UDim2.new(hue, -3, 0, -2)
                local r = math.round(currentColor.R * 255)
                local g = math.round(currentColor.G * 255)
                local b = math.round(currentColor.B * 255)
                hexBox.Text = string.format("#%02X%02X%02X", r, g, b)
                if fire ~= false and callback then pcall(callback, currentColor) end
            end

            local palDrag = false
            local function PalUpdate(inputPos)
                local rel = paletteBase.AbsoluteSize
                local pos = inputPos - paletteBase.AbsolutePosition
                sat = math.clamp(pos.X / rel.X, 0, 1)
                val = math.clamp(1 - pos.Y / rel.Y, 0, 1)
                RefreshUI()
            end
            paletteBase.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    palDrag = true; PalUpdate(i.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if palDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    PalUpdate(i.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then palDrag = false end
            end)

            local hueDrag = false
            local function HueUpdate(inputX)
                local pos = inputX - hueBar.AbsolutePosition.X
                hue = math.clamp(pos / hueBar.AbsoluteSize.X, 0, 1)
                RefreshUI()
            end
            hueBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = true; HueUpdate(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    HueUpdate(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
            end)

            hexBox.FocusLost:Connect(function(enter)
                if enter then
                    local hexStr = hexBox.Text:gsub("#", "")
                    if #hexStr == 6 and hexStr:match("^%x+$") then
                        local r = tonumber(hexStr:sub(1,2), 16) / 255
                        local g = tonumber(hexStr:sub(3,4), 16) / 255
                        local b = tonumber(hexStr:sub(5,6), 16) / 255
                        hue, sat, val = Color3.toHSV(Color3.new(r, g, b))
                        RefreshUI()
                    end
                end
            end)

            swatchBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    popup.Size    = UDim2.new(1, 0, 0, 0)
                    popup.Visible = true
                    Tween(popup, {Size = UDim2.new(1, 0, 0, 160)}, 0.22)
                else
                    local tw = Tween(popup, {Size = UDim2.new(1, 0, 0, 0)}, 0.18)
                    tw.Completed:Once(function() if not pickerOpen then popup.Visible = false end end)
                end
            end)

            local pickerObj = {Value = currentColor}
            function pickerObj:Set(color, fire)
                hue, sat, val = Color3.toHSV(color)
                RefreshUI(fire)
            end
            function pickerObj:Get() return currentColor end
            return pickerObj
        end

        -- ┌───────────── Keybind ─────────────┐
        function Section:CreateKeybind(labelText, defaultKey, callback)
            local order = NextOrder()
            local currentKey = defaultKey
            local listening = false

            local row = MakeInstance("Frame", {
                Name             = "Keybind_" .. labelText,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundTransparency = 1,
                LayoutOrder      = order,
            }, ElemContainer)

            MakeInstance("TextLabel", {
                Size                   = UDim2.new(1, -64, 1, 0),
                BackgroundTransparency = 1,
                Text                   = labelText,
                TextColor3             = Theme.Text,
                Font                   = Enum.Font.Gotham,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 4,
            }, row)

            local keyBtn = MakeInstance("TextButton", {
                Size             = UDim2.new(0, 58, 0, 22),
                Position         = UDim2.new(1, -58, 0.5, -11),
                BackgroundColor3 = Theme.Element,
                Text             = currentKey and currentKey.Name or "None",
                TextColor3       = Theme.Accent,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 11,
                AutoButtonColor  = false,
                ZIndex           = 4,
            }, row)
            AddCorner(keyBtn, UDim.new(0, 5))

            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyBtn.Text = "..."
                Tween(keyBtn, {BackgroundColor3 = Theme.ElementHover}, 0.1)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if not listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBtn.Text = currentKey.Name
                    listening = false
                    Tween(keyBtn, {BackgroundColor3 = Theme.Element}, 0.1)
                end
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or listening then return end
                if currentKey and input.KeyCode == currentKey then
                    if callback then pcall(callback) end
                end
            end)

            local kbObj = {}
            function kbObj:Set(keycode)
                currentKey = keycode
                keyBtn.Text = keycode and keycode.Name or "None"
            end
            function kbObj:Get() return currentKey end
            return kbObj
        end

        -- ┌───────────── Label / Separator ─────────────┐
        function Section:CreateLabel(text, color)
            local order = NextOrder()
            return MakeInstance("TextLabel", {
                Name                   = "Label_" .. text,
                Size                   = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text                   = text,
                TextColor3             = color or Theme.TextDim,
                Font                   = Enum.Font.Gotham,
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
                LayoutOrder            = order,
                ZIndex                 = 4,
                TextWrapped            = true,
            }, ElemContainer)
        end

        function Section:CreateSeparator()
            local order = NextOrder()
            return MakeInstance("Frame", {
                Name             = "Separator",
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.BorderSubtle,
                LayoutOrder      = order,
            }, ElemContainer)
        end

        return Section
    end -- Window:NewSection

    return Window
end -- SorcererLib:NewWindow

-- ─── Destroy ──────────────────────────────────
function SorcererLib:Destroy()
    GUI:Destroy()
end

return SorcererLib
