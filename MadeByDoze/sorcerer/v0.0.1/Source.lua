-- ╔══════════════════════════════════════════╗
-- ║         Sorcerer LIBRARY v0.0.1          ║
-- ║     Dark Cyan-Accent Roblox UI Lib       ║
-- ╚══════════════════════════════════════════╝

local Library = {}
Library.__index = Library

-- ─── Services ───────────────────────────────
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local LocalPlayer     = Players.LocalPlayer

-- ─── Theme ──────────────────────────────────
local Theme = {
    Background      = Color3.fromRGB(30, 30, 32),
    Header          = Color3.fromRGB(22, 22, 24),
    Section         = Color3.fromRGB(38, 38, 42),
    SectionHeader   = Color3.fromRGB(28, 28, 31),
    Element         = Color3.fromRGB(50, 50, 55),
    ElementHover    = Color3.fromRGB(62, 62, 68),
    ElementPressed  = Color3.fromRGB(40, 40, 45),
    Accent          = Color3.fromRGB(0, 210, 230),
    AccentDark      = Color3.fromRGB(0, 160, 175),
    AccentGlow      = Color3.fromRGB(0, 230, 255),
    Text            = Color3.fromRGB(235, 235, 240),
    TextDim         = Color3.fromRGB(160, 160, 170),
    TextDisabled    = Color3.fromRGB(90, 90, 100),
    Border          = Color3.fromRGB(0, 200, 220),
    BorderSubtle    = Color3.fromRGB(55, 55, 62),
    SliderFill      = Color3.fromRGB(0, 210, 230),
    SliderTrack     = Color3.fromRGB(55, 55, 62),
    ToggleOn        = Color3.fromRGB(0, 210, 230),
    ToggleOff       = Color3.fromRGB(70, 70, 78),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    DropdownBG      = Color3.fromRGB(35, 35, 40),
    Chevron         = Color3.fromRGB(0, 210, 230),
    WindowWidth     = 200,
    CornerRadius    = UDim.new(0, 5),
    Padding         = UDim.new(0, 6),
    ElementHeight   = 30,
    HeaderHeight    = 34,
    SectionHeaderH  = 28,
}

-- ─── Utilities ───────────────────────────────
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
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

local function AddStroke(parent, color, thickness)
    return MakeInstance("UIStroke", {
        Color     = color or Theme.Border,
        Thickness = thickness or 1,
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

local function Ripple(button)
    local rip = MakeInstance("Frame", {
        Size            = UDim2.new(0, 0, 0, 0),
        Position        = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint     = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.75,
        ZIndex          = button.ZIndex + 10,
        ClipsDescendants = false,
    }, button)
    AddCorner(rip, UDim.new(1, 0))
    Tween(rip, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.4)
    game:GetService("Debris"):AddItem(rip, 0.45)
end

-- ─── Dragging ────────────────────────────────
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── ScreenGui ───────────────────────────────
local function GetGui()
    local sg
    pcall(function()
        sg = game:GetService("CoreGui"):FindFirstChild("DozeUILibrary")
    end)
    if not sg then
        sg = MakeInstance("ScreenGui", {
            Name             = "DozeUILibrary",
            ResetOnSpawn     = false,
            ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset   = true,
        })
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end
    return sg
end

-- ════════════════════════════════════════════
--  Library:NewWindow(title)
-- ════════════════════════════════════════════
function Library:NewWindow(title)
    local GUI = GetGui()

    -- Outer window frame
    local WindowFrame = MakeInstance("Frame", {
        Name             = "Window_" .. title,
        Size             = UDim2.new(0, Theme.WindowWidth, 0, Theme.HeaderHeight),
        Position         = UDim2.new(0.5, -Theme.WindowWidth/2, 0.15, 0),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = false,
        AutomaticSize    = Enum.AutomaticSize.Y,
    }, GUI)
    AddCorner(WindowFrame, UDim.new(0, 6))
    AddStroke(WindowFrame, Theme.Border, 1.2)

    -- Cyan top-border accent line
    local TopLine = MakeInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, WindowFrame)
    AddCorner(TopLine, UDim.new(0, 2))

    -- Header bar
    local Header = MakeInstance("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Header,
        ZIndex           = 4,
    }, WindowFrame)
    AddCorner(Header, UDim.new(0, 6))

    local HeaderLabel = MakeInstance("TextLabel", {
        Name             = "Title",
        Size             = UDim2.new(1, -30, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 5,
    }, Header)

    -- Collapse chevron
    local Chevron = MakeInstance("TextLabel", {
        Name             = "Chevron",
        Size             = UDim2.new(0, 24, 0, 24),
        Position         = UDim2.new(1, -28, 0.5, -12),
        BackgroundTransparency = 1,
        Text             = "-",
        TextColor3       = Theme.Accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 18,
        ZIndex           = 6,
    }, Header)

    -- Content container (holds all sections)
    local Content = MakeInstance("Frame", {
        Name             = "Content",
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 0, Theme.HeaderHeight),
        BackgroundTransparency = 1,
        AutomaticSize    = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
    }, WindowFrame)

    local ContentLayout = MakeInstance("UIListLayout", {
        SortOrder    = Enum.SortOrder.LayoutOrder,
        Padding      = UDim.new(0, 0),
    }, Content)

    MakeInstance("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
    }, Content)

    -- Collapse / expand
    local collapsed = false
    local function ToggleCollapse()
        collapsed = not collapsed
        Chevron.Text = collapsed and "v" or "-"
        Tween(Content, {Size = collapsed
            and UDim2.new(1, 0, 0, 0)
            or  UDim2.new(1, 0, 0, 0)  -- AutomaticSize handles real height
        }, 0.2)
        Content.Visible = not collapsed
    end

    Chevron.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then ToggleCollapse() end
    end)

    MakeDraggable(WindowFrame, Header)

    -- ── Window Object ──────────────────────────
    local Window = {}
    Window._frame   = WindowFrame
    Window._content = Content

    -- ════════════════════════════════════════
    --  Window:NewSection(name)
    -- ════════════════════════════════════════
    function Window:NewSection(name)
        -- Section wrapper
        local SectionFrame = MakeInstance("Frame", {
            Name             = "Section_" .. name,
            Size             = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize    = Enum.AutomaticSize.Y,
            ClipsDescendants = false,
        }, Content)

        local SectionLayout = MakeInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 0),
        }, SectionFrame)

        -- Section header row
        local SectionHeader = MakeInstance("Frame", {
            Name             = "SectionHeader",
            Size             = UDim2.new(1, 0, 0, Theme.SectionHeaderH),
            BackgroundColor3 = Theme.SectionHeader,
            LayoutOrder      = 0,
            ZIndex           = 3,
        }, SectionFrame)

        local SecLabel = MakeInstance("TextLabel", {
            Size             = UDim2.new(1, -26, 1, 0),
            Position         = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text             = name,
            TextColor3       = Theme.Text,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 12,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 4,
        }, SectionHeader)
        AddPadding(SecLabel, 0, 0, 8, 0)

        local SecChevron = MakeInstance("TextLabel", {
            Size             = UDim2.new(0, 20, 1, 0),
            Position         = UDim2.new(1, -24, 0, 0),
            BackgroundTransparency = 1,
            Text             = "-",
            TextColor3       = Theme.Accent,
            Font             = Enum.Font.GothamBold,
            TextSize         = 16,
            ZIndex           = 4,
        }, SectionHeader)

        -- Element container
        local ElemContainer = MakeInstance("Frame", {
            Name             = "Elements",
            Size             = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Section,
            AutomaticSize    = Enum.AutomaticSize.Y,
            LayoutOrder      = 1,
            ClipsDescendants = false,
        }, SectionFrame)

        local ElemLayout = MakeInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 1),
        }, ElemContainer)

        MakeInstance("UIPadding", {
            PaddingTop    = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft   = UDim.new(0, 7),
            PaddingRight  = UDim.new(0, 7),
        }, ElemContainer)

        -- Section collapse
        local secCollapsed = false
        local function ToggleSec()
            secCollapsed = not secCollapsed
            SecChevron.Text = secCollapsed and "v" or "-"
            ElemContainer.Visible = not secCollapsed
        end
        SectionHeader.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then ToggleSec() end
        end)

        -- ── Section Object ──────────────────────
        local Section = {}
        Section._container = ElemContainer
        local elemOrder = 0

        local function NextOrder()
            elemOrder = elemOrder + 1
            return elemOrder
        end

        -- Helper: wraps label + right-side widget in a row
        local function MakeRow(labelText, height, order)
            local row = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, height or Theme.ElementHeight),
                BackgroundTransparency = 1,
                LayoutOrder      = order or NextOrder(),
            }, ElemContainer)
            if labelText and labelText ~= "" then
                local lbl = MakeInstance("TextLabel", {
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = labelText,
                    TextColor3       = Theme.Text,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 4,
                }, row)
            end
            return row
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateButton                        │
        -- └─────────────────────────────────────┘
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
            AddCorner(btn, UDim.new(0, 4))
            AddStroke(btn, Theme.BorderSubtle, 1)

            -- Hover
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
                if callback then pcall(callback) end
            end)

            return btn
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateTextbox                       │
        -- └─────────────────────────────────────┘
        function Section:CreateTextbox(placeholder, callback)
            local order = NextOrder()
            local box = MakeInstance("TextBox", {
                Name             = "Textbox_" .. placeholder,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundColor3 = Theme.Element,
                PlaceholderText  = placeholder,
                PlaceholderColor3 = Theme.TextDim,
                Text             = "",
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                ClearTextOnFocus = false,
                LayoutOrder      = order,
                ZIndex           = 4,
            }, ElemContainer)
            AddCorner(box, UDim.new(0, 4))
            AddStroke(box, Theme.BorderSubtle, 1)
            AddPadding(box, 0, 0, 8, 8)

            box.Focused:Connect(function()
                Tween(box, {BackgroundColor3 = Theme.ElementHover}, 0.12)
                AddStroke(box, Theme.Accent, 1.2)
            end)
            box.FocusLost:Connect(function(enter)
                Tween(box, {BackgroundColor3 = Theme.Element}, 0.12)
                AddStroke(box, Theme.BorderSubtle, 1)
                if enter and callback then pcall(callback, box.Text) end
            end)

            return box
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateToggle                        │
        -- └─────────────────────────────────────┘
        function Section:CreateToggle(labelText, callback, default)
            local order = NextOrder()
            local value = default or false

            local row = MakeInstance("Frame", {
                Name             = "Toggle_" .. labelText,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundTransparency = 1,
                LayoutOrder      = order,
            }, ElemContainer)

            local lbl = MakeInstance("TextLabel", {
                Size             = UDim2.new(1, -44, 1, 0),
                BackgroundTransparency = 1,
                Text             = labelText,
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 4,
            }, row)

            -- Track
            local track = MakeInstance("Frame", {
                Size             = UDim2.new(0, 38, 0, 20),
                Position         = UDim2.new(1, -40, 0.5, -10),
                BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
                ZIndex           = 4,
            }, row)
            AddCorner(track, UDim.new(1, 0))

            -- Knob
            local knob = MakeInstance("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = value
                    and UDim2.new(1, -17, 0.5, -7)
                    or  UDim2.new(0,   3, 0.5, -7),
                BackgroundColor3 = Theme.ToggleKnob,
                ZIndex           = 5,
            }, track)
            AddCorner(knob, UDim.new(1, 0))

            local function SetValue(v)
                value = v
                Tween(track, {BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff}, 0.18)
                Tween(knob, {Position = v
                    and UDim2.new(1, -17, 0.5, -7)
                    or  UDim2.new(0,   3, 0.5, -7)
                }, 0.18)
                if callback then pcall(callback, value) end
            end

            row.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    SetValue(not value)
                end
            end)
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    SetValue(not value)
                end
            end)

            local toggleObj = {Value = value}
            function toggleObj:Set(v) SetValue(v) end
            return toggleObj
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateDropdown                      │
        -- └─────────────────────────────────────┘
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
            AddCorner(row, UDim.new(0, 4))
            AddStroke(row, Theme.BorderSubtle, 1)

            local selLabel = MakeInstance("TextLabel", {
                Size             = UDim2.new(1, -28, 1, 0),
                Position         = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text             = selected,
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 7,
            }, row)

            local arrow = MakeInstance("TextLabel", {
                Size             = UDim2.new(0, 22, 1, 0),
                Position         = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text             = ">",
                TextColor3       = Theme.Accent,
                Font             = Enum.Font.GothamBold,
                TextSize         = 14,
                ZIndex           = 7,
            }, row)

            -- Dropdown list (rendered above all)
            local listFrame = MakeInstance("Frame", {
                Name             = "DropList",
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Theme.DropdownBG,
                ZIndex           = 30,
                Visible          = false,
                ClipsDescendants = false,
            }, row)
            AddCorner(listFrame, UDim.new(0, 4))
            AddStroke(listFrame, Theme.Border, 1)

            local listLayout = MakeInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 1),
            }, listFrame)

            MakeInstance("UIPadding", {
                PaddingTop = UDim.new(0,3), PaddingBottom = UDim.new(0,3),
                PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4),
            }, listFrame)

            local isOpen = false
            local function BuildList()
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
                end
                local totalH = 6
                for i, opt in ipairs(options) do
                    local item = MakeInstance("TextButton", {
                        Name             = "Option_" .. opt,
                        Size             = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = opt == selected
                            and Theme.ElementHover
                            or  Theme.DropdownBG,
                        Text             = opt,
                        TextColor3       = opt == selected
                            and Theme.Accent
                            or  Theme.Text,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 12,
                        AutoButtonColor  = false,
                        LayoutOrder      = i,
                        ZIndex           = 31,
                    }, listFrame)
                    AddCorner(item, UDim.new(0, 3))
                    totalH = totalH + 25

                    item.MouseEnter:Connect(function()
                        if opt ~= selected then
                            Tween(item, {BackgroundColor3 = Theme.ElementHover}, 0.1)
                        end
                    end)
                    item.MouseLeave:Connect(function()
                        if opt ~= selected then
                            Tween(item, {BackgroundColor3 = Theme.DropdownBG}, 0.1)
                        end
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        selLabel.Text = opt
                        isOpen = false
                        arrow.Text = ">"
                        Tween(listFrame, {Size = UDim2.new(1,0,0,0)}, 0.15)
                        task.delay(0.16, function() listFrame.Visible = false end)
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
                    listFrame.Size   = UDim2.new(1, 0, 0, 0)
                    listFrame.Visible = true
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.18)
                    arrow.Text = "<"
                else
                    arrow.Text = ">"
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                    task.delay(0.16, function() listFrame.Visible = false end)
                end
            end

            row.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    ToggleDropdown()
                end
            end)

            BuildList()

            local dropObj = {Value = selected}
            function dropObj:Set(v)
                selected = v
                selLabel.Text = v
                BuildList()
            end
            function dropObj:SetOptions(newOpts)
                options = newOpts
                BuildList()
            end
            return dropObj
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateSlider                        │
        -- └─────────────────────────────────────┘
        function Section:CreateSlider(labelText, min, max, default, integer, callback)
            local order = NextOrder()
            local value = math.clamp(default or min, min, max)

            -- Label row
            local labelRow = MakeInstance("Frame", {
                Name             = "SliderLabel_" .. labelText,
                Size             = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                LayoutOrder      = order,
            }, ElemContainer)

            local lbl = MakeInstance("TextLabel", {
                Size             = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = labelText,
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 4,
            }, labelRow)

            local valLabel = MakeInstance("TextLabel", {
                Size             = UDim2.new(0.3, 0, 1, 0),
                Position         = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text             = tostring(value),
                TextColor3       = Theme.Accent,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = 4,
            }, labelRow)

            -- Track row
            local trackRow = MakeInstance("Frame", {
                Name             = "SliderTrack_" .. labelText,
                Size             = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                LayoutOrder      = order + 0.5,
            }, ElemContainer)

            local track = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 4),
                Position         = UDim2.new(0, 0, 0.5, -2),
                BackgroundColor3 = Theme.SliderTrack,
                ZIndex           = 4,
            }, trackRow)
            AddCorner(track, UDim.new(1, 0))

            local fill = MakeInstance("Frame", {
                Size             = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                ZIndex           = 5,
            }, track)
            AddCorner(fill, UDim.new(1, 0))

            -- Glow on fill
            MakeInstance("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.AccentDark),
                    ColorSequenceKeypoint.new(1, Theme.AccentGlow),
                }),
            }, fill)

            -- Knob
            local knob = MakeInstance("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new((value - min) / (max - min), -5, 0.5, -5),
                BackgroundColor3 = Theme.ToggleKnob,
                ZIndex           = 6,
            }, track)
            AddCorner(knob, UDim.new(1, 0))
            AddStroke(knob, Theme.Accent, 1.5)

            local dragging = false

            local function UpdateSlider(inputX)
                local rel = math.clamp(
                    (inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                    0, 1
                )
                value = min + (max - min) * rel
                if integer then value = math.round(value) end
                value = math.clamp(value, min, max)

                local pct = (value - min) / (max - min)
                Tween(fill,  {Size     = UDim2.new(pct, 0, 1, 0)}, 0.05)
                Tween(knob,  {Position = UDim2.new(pct, -5, 0.5, -5)}, 0.05)
                valLabel.Text = integer and tostring(math.round(value))
                    or string.format("%.2f", value)
                if callback then pcall(callback, value) end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    UpdateSlider(i.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local sliderObj = {Value = value}
            function sliderObj:Set(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                Tween(fill,  {Size     = UDim2.new(pct, 0, 1, 0)}, 0.1)
                Tween(knob,  {Position = UDim2.new(pct, -5, 0.5, -5)}, 0.1)
                valLabel.Text = integer and tostring(math.round(value))
                    or string.format("%.2f", value)
            end
            return sliderObj
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateColorPicker                   │
        -- └─────────────────────────────────────┘
        function Section:CreateColorPicker(labelText, defaultColor, callback)
            local order = NextOrder()
            local hue, sat, val = Color3.toHSV(defaultColor or Color3.new(1,1,1))
            local currentColor = defaultColor or Color3.new(1,1,1)
            local pickerOpen = false

            -- Row
            local row = MakeInstance("Frame", {
                Name             = "ColorPicker_" .. labelText,
                Size             = UDim2.new(1, 0, 0, Theme.ElementHeight),
                BackgroundTransparency = 1,
                LayoutOrder      = order,
                ClipsDescendants = false,
            }, ElemContainer)

            local lbl = MakeInstance("TextLabel", {
                Size             = UDim2.new(1, -36, 1, 0),
                BackgroundTransparency = 1,
                Text             = labelText,
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 4,
            }, row)

            -- Preview swatch
            local swatch = MakeInstance("Frame", {
                Size             = UDim2.new(0, 22, 0, 22),
                Position         = UDim2.new(1, -24, 0.5, -11),
                BackgroundColor3 = currentColor,
                ZIndex           = 4,
            }, row)
            AddCorner(swatch, UDim.new(0, 4))
            AddStroke(swatch, Theme.BorderSubtle, 1)

            -- Picker popup
            local popup = MakeInstance("Frame", {
                Name             = "ColorPopup",
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.DropdownBG,
                ZIndex           = 25,
                Visible          = false,
                ClipsDescendants = false,
            }, row)
            AddCorner(popup, UDim.new(0, 5))
            AddStroke(popup, Theme.Border, 1)

            local popupLayout = MakeInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 6),
            }, popup)
            MakeInstance("UIPadding", {
                PaddingTop = UDim.new(0,8), PaddingBottom = UDim.new(0,8),
                PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8),
            }, popup)

            -- Hue/Sat palette
            local paletteFrame = MakeInstance("Frame", {
                Name        = "Palette",
                Size        = UDim2.new(1, 0, 0, 90),
                LayoutOrder = 1,
                ZIndex      = 26,
            }, popup)

            local paletteBase = MakeInstance("ImageLabel", {
                Size            = UDim2.new(1, 0, 1, 0),
                Image           = "rbxassetid://3570695787",
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                ZIndex          = 26,
            }, paletteFrame)
            AddCorner(paletteBase, UDim.new(0, 4))

            local paletteWhite = MakeInstance("ImageLabel", {
                Size  = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://3570695786",
                BackgroundTransparency = 1,
                ZIndex = 27,
            }, paletteBase)
            AddCorner(paletteWhite, UDim.new(0, 4))

            local paletteDark = MakeInstance("ImageLabel", {
                Size  = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://3570695785",
                BackgroundTransparency = 1,
                ZIndex = 28,
            }, paletteBase)
            AddCorner(paletteDark, UDim.new(0, 4))

            -- Palette cursor
            local palCursor = MakeInstance("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new(sat, -5, 1 - val, -5),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex           = 29,
            }, paletteBase)
            AddCorner(palCursor, UDim.new(1, 0))
            AddStroke(palCursor, Color3.new(0,0,0), 1.5)

            -- Hue bar
            local hueBarFrame = MakeInstance("Frame", {
                Name        = "HueBar",
                Size        = UDim2.new(1, 0, 0, 14),
                LayoutOrder = 2,
                ZIndex      = 26,
            }, popup)

            local hueBar = MakeInstance("ImageLabel", {
                Size  = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://3570695789",
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex = 27,
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

            -- Hex output
            local hexRow = MakeInstance("Frame", {
                Name        = "HexRow",
                Size        = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                LayoutOrder = 3,
            }, popup)
            local hexLabel = MakeInstance("TextLabel", {
                Size             = UDim2.new(0.3, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "HEX",
                TextColor3       = Theme.TextDim,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 10,
                ZIndex           = 26,
            }, hexRow)
            local hexBox = MakeInstance("TextBox", {
                Size             = UDim2.new(0.7, 0, 1, 0),
                Position         = UDim2.new(0.3, 0, 0, 0),
                BackgroundColor3 = Theme.Element,
                Text             = "#FFFFFF",
                TextColor3       = Theme.Accent,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 11,
                ZIndex           = 26,
            }, hexRow)
            AddCorner(hexBox, UDim.new(0, 3))
            AddPadding(hexBox, 0, 0, 6, 6)

            local function RefreshUI()
                currentColor = Color3.fromHSV(hue, sat, val)
                swatch.BackgroundColor3    = currentColor
                paletteBase.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                palCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                hueCursor.Position = UDim2.new(hue, -3, 0, -2)
                local r = math.round(currentColor.R * 255)
                local g = math.round(currentColor.G * 255)
                local b = math.round(currentColor.B * 255)
                hexBox.Text = string.format("#%02X%02X%02X", r, g, b)
                if callback then pcall(callback, currentColor) end
            end

            -- Palette drag
            local palDrag = false
            paletteBase.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    palDrag = true
                    local rel = paletteBase.AbsoluteSize
                    local pos = i.Position - paletteBase.AbsolutePosition
                    sat = math.clamp(pos.X / rel.X, 0, 1)
                    val = math.clamp(1 - pos.Y / rel.Y, 0, 1)
                    RefreshUI()
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if palDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = paletteBase.AbsoluteSize
                    local pos = i.Position - paletteBase.AbsolutePosition
                    sat = math.clamp(pos.X / rel.X, 0, 1)
                    val = math.clamp(1 - pos.Y / rel.Y, 0, 1)
                    RefreshUI()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    palDrag = false
                end
            end)

            -- Hue bar drag
            local hueDrag = false
            hueBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = true
                    local pos = i.Position.X - hueBar.AbsolutePosition.X
                    hue = math.clamp(pos / hueBar.AbsoluteSize.X, 0, 1)
                    RefreshUI()
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = i.Position.X - hueBar.AbsolutePosition.X
                    hue = math.clamp(pos / hueBar.AbsoluteSize.X, 0, 1)
                    RefreshUI()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = false
                end
            end)

            -- Toggle popup
            swatch.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        popup.Size    = UDim2.new(1, 0, 0, 0)
                        popup.Visible = true
                        Tween(popup, {Size = UDim2.new(1, 0, 0, 155)}, 0.2)
                    else
                        Tween(popup, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.16, function() popup.Visible = false end)
                    end
                end
            end)

            local pickerObj = {Value = currentColor}
            function pickerObj:Set(color)
                hue, sat, val = Color3.toHSV(color)
                RefreshUI()
            end
            return pickerObj
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateLabel                         │
        -- └─────────────────────────────────────┘
        function Section:CreateLabel(text, color)
            local order = NextOrder()
            local lbl = MakeInstance("TextLabel", {
                Name             = "Label_" .. text,
                Size             = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text             = text,
                TextColor3       = color or Theme.TextDim,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LayoutOrder      = order,
                ZIndex           = 4,
                TextWrapped      = true,
            }, ElemContainer)
            return lbl
        end

        -- ┌─────────────────────────────────────┐
        -- │  CreateSeparator                     │
        -- └─────────────────────────────────────┘
        function Section:CreateSeparator()
            local order = NextOrder()
            local sep = MakeInstance("Frame", {
                Name             = "Separator",
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.BorderSubtle,
                LayoutOrder      = order,
            }, ElemContainer)
            return sep
        end

        return Section
    end -- Window:NewSection

    return Window
end -- Library:NewWindow

-- ─── Destroy ──────────────────────────────────
function Library:Destroy()
    local gui = GetGui()
    if gui then gui:Destroy() end
end

return Library
