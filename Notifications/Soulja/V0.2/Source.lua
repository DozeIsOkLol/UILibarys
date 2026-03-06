--[[
╔═══════════════════════════════════════════════════╗
║                NotifyLib  v0.2                    ║
║   Polished Roblox Notification ModuleScript       ║
╠═══════════════════════════════════════════════════╣
║  Features:                                        ║
║  · 5 notification types + custom color            ║
║  · Stacking with auto-shift animation             ║
║  · Spring slide-in / slide-out                    ║
║  · Progress bar (pauses on hover)                 ║
║  · Optional 1–2 action buttons                    ║
║  · Optional image thumbnail                       ║
║  · Drop shadow + left accent strip                ║
║  · Returns dismiss handle                         ║
╚═══════════════════════════════════════════════════╝

  USAGE
  ─────
  local N = require(game.ReplicatedStorage.NotifyLib)

  -- Simple
  N:Notify({ Title="Hello!", Message="Welcome.", Type="Success", Duration=5 })

  -- With buttons
  N:Notify({
      Title   = "Friend Request",
      Message = "Player123 wants to join.",
      Type    = "Info",
      Duration = 8,
      Button1 = { Text="Decline", Callback=function() end },
      Button2 = { Text="Accept",  Callback=function() end },
  })

  -- Custom color
  N:Notify({ Title="VIP Reward", Type="Custom", Color=Color3.fromRGB(255,200,0), Duration=6 })

  -- Early dismiss
  local handle = N:Notify({ Title="Loading…", Type="Info", Duration=30 })
  handle.Dismiss()

  -- Clear all
  N:ClearAll()
--]]

-- ─────────────────────────────────────────────────
--  Services
-- ─────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────────
--  Config
-- ─────────────────────────────────────────────────
local CFG = {
    MaxStack         = 5,
    DefaultDuration  = 5,
    CardWidth        = 315,
    CardMinHeight    = 78,      -- no buttons, no image
    CardBtnHeight    = 112,     -- with buttons
    CardImgHeight    = 94,      -- with image
    PaddingRight     = 16,
    PaddingBottom    = 16,
    Gap              = 9,
    SlideInTime      = 0.42,
    SlideOutTime     = 0.22,
    Font             = Enum.Font.GothamBold,
    FontBody         = Enum.Font.Gotham,
    FontMono         = Enum.Font.Code,
    ZIndex           = 950,
}

-- ─────────────────────────────────────────────────
--  Type Definitions
-- ─────────────────────────────────────────────────
local TYPES = {
    Success = { Color = Color3.fromRGB(34,  213, 90),  Label = "SUCCESS" },
    Error   = { Color = Color3.fromRGB(255,  77, 77),  Label = "ERROR"   },
    Warning = { Color = Color3.fromRGB(245, 166, 35),  Label = "WARNING" },
    Info    = { Color = Color3.fromRGB(77,  159, 255), Label = "INFO"    },
    Custom  = { Color = Color3.fromRGB(180,  92, 255), Label = "NOTICE"  },
}

-- ─────────────────────────────────────────────────
--  State
-- ─────────────────────────────────────────────────
local NotifyLib = {}
NotifyLib.__index = NotifyLib

local stack = {}   -- { frame, height }
local count = 0

-- ─────────────────────────────────────────────────
--  ScreenGui
-- ─────────────────────────────────────────────────
local Gui = Instance.new("ScreenGui")
Gui.Name           = "NotifyLib_GUI"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder   = CFG.ZIndex
Gui.IgnoreGuiInset = true
Gui.Parent         = PlayerGui

-- ─────────────────────────────────────────────────
--  Helpers
-- ─────────────────────────────────────────────────
local function tw(obj, style, dir, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

local function spring(obj, t, props)
    return tw(obj, Enum.EasingStyle.Back, Enum.EasingDirection.Out, t, props)
end

local function quint(obj, t, props)
    return tw(obj, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, t, props)
end

local function linear(obj, t, props)
    return tw(obj, Enum.EasingStyle.Linear, Enum.EasingDirection.In, t, props)
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function addPadding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t)
    p.PaddingRight  = UDim.new(0, r)
    p.PaddingBottom = UDim.new(0, b)
    p.PaddingLeft   = UDim.new(0, l)
    p.Parent = parent
end

-- ─────────────────────────────────────────────────
--  Stack management
-- ─────────────────────────────────────────────────
local function getBottomOffset()
    local total = CFG.PaddingBottom
    for _, entry in ipairs(stack) do
        total = total + entry.height + CFG.Gap
    end
    return total
end

local function rebuildPositions(excludeFrame)
    local offset = CFG.PaddingBottom
    for i = #stack, 1, -1 do
        local entry = stack[i]
        if entry.frame ~= excludeFrame then
            local targetY = -(offset + entry.height)
            quint(entry.frame, CFG.SlideInTime, {
                Position = UDim2.new(1, -(CFG.CardWidth + CFG.PaddingRight), 1, targetY)
            }):Play()
            offset = offset + entry.height + CFG.Gap
        end
    end
end

local function removeFromStack(frame)
    for i, entry in ipairs(stack) do
        if entry.frame == frame then
            table.remove(stack, i)
            return
        end
    end
end

-- ─────────────────────────────────────────────────
--  Build Card
-- ─────────────────────────────────────────────────
local function buildCard(opts)
    local typeDef   = TYPES[opts.Type] or TYPES.Info
    local accent    = opts.Color or typeDef.Color
    local label     = typeDef.Label
    local hasImg    = opts.Image ~= nil
    local hasBtn1   = opts.Button1 ~= nil
    local hasBtn2   = opts.Button2 ~= nil
    local hasBtns   = hasBtn1 or hasBtn2
    local cardH     = hasBtns and CFG.CardBtnHeight
                   or hasImg  and CFG.CardImgHeight
                   or CFG.CardMinHeight

    -- ── Root frame ──────────────────────────────
    local frame = Instance.new("Frame")
    frame.Name              = "NotifCard_" .. count
    frame.Size              = UDim2.new(0, CFG.CardWidth, 0, cardH)
    frame.BackgroundColor3  = Color3.fromRGB(22, 22, 31)
    frame.BorderSizePixel   = 0
    frame.ZIndex            = CFG.ZIndex + 1
    -- Start off-screen right
    frame.Position = UDim2.new(1, CFG.CardWidth + 24, 1,
        -(CFG.PaddingBottom + cardH + getBottomOffset() - CFG.PaddingBottom))
    frame.Parent = Gui

    addCorner(frame, 12)

    -- Gradient overlay
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 24)),
    })
    grad.Rotation = 145
    grad.Parent = frame

    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name                   = "Shadow"
    shadow.Size                   = UDim2.new(1, 28, 1, 28)
    shadow.Position               = UDim2.new(0, -14, 0, -4)
    shadow.BackgroundTransparency = 1
    shadow.Image                  = "rbxassetid://6014261993"
    shadow.ImageColor3            = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency      = 0.45
    shadow.ScaleType              = Enum.ScaleType.Slice
    shadow.SliceCenter            = Rect.new(49, 49, 450, 450)
    shadow.ZIndex                 = CFG.ZIndex
    shadow.Parent                 = frame

    -- ── Top shimmer line ────────────────────────
    local shimmer = Instance.new("Frame")
    shimmer.Name             = "Shimmer"
    shimmer.Size             = UDim2.new(1, 0, 0, 1)
    shimmer.Position         = UDim2.new(0, 0, 0, 0)
    shimmer.BackgroundColor3 = accent
    shimmer.BackgroundTransparency = 0.5
    shimmer.BorderSizePixel  = 0
    shimmer.ZIndex           = CFG.ZIndex + 3
    shimmer.Parent           = frame

    local shimGrad = Instance.new("UIGradient")
    shimGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    shimGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    shimGrad.Parent = shimmer

    -- ── Left accent strip ───────────────────────
    local strip = Instance.new("Frame")
    strip.Name             = "Strip"
    strip.Size             = UDim2.new(0, 2.5, 1, 0)
    strip.Position         = UDim2.new(0, 0, 0, 0)
    strip.BackgroundColor3 = accent
    strip.BorderSizePixel  = 0
    strip.ZIndex           = CFG.ZIndex + 3
    strip.Parent           = frame
    addCorner(strip, 12)

    -- Inner glow from left
    local glow = Instance.new("Frame")
    glow.Name             = "Glow"
    glow.Size             = UDim2.new(0, 80, 1, 0)
    glow.Position         = UDim2.new(0, 0, 0, 0)
    glow.BackgroundColor3 = accent
    glow.BackgroundTransparency = 0.96
    glow.BorderSizePixel  = 0
    glow.ZIndex           = CFG.ZIndex + 2
    glow.Parent           = frame

    local glowGrad = Instance.new("UIGradient")
    glowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    glowGrad.Parent = glow

    -- ── Badge ────────────────────────────────────
    local badge = Instance.new("Frame")
    badge.Name              = "Badge"
    badge.Size              = UDim2.new(0, 0, 0, 17)
    badge.AutomaticSize     = Enum.AutomaticSize.X
    badge.Position          = UDim2.new(0, 12, 0, 10)
    badge.BackgroundColor3  = accent
    badge.BackgroundTransparency = 0.88
    badge.BorderSizePixel   = 0
    badge.ZIndex            = CFG.ZIndex + 4
    badge.Parent            = frame
    addCorner(badge, 99)
    addPadding(badge, 0, 8, 0, 6)

    -- Badge border
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color       = accent
    badgeStroke.Transparency = 0.72
    badgeStroke.Thickness   = 1
    badgeStroke.Parent      = badge

    -- Badge inner dot
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 5, 0, 5)
    dot.AnchorPoint      = Vector2.new(0, 0.5)
    dot.Position         = UDim2.new(0, 0, 0.5, 0)
    dot.BackgroundColor3 = accent
    dot.BorderSizePixel  = 0
    dot.ZIndex           = CFG.ZIndex + 5
    dot.Parent           = badge
    addCorner(dot, 99)

    local badgeLabel = Instance.new("TextLabel")
    badgeLabel.Size                   = UDim2.new(0, 0, 1, 0)
    badgeLabel.AutomaticSize          = Enum.AutomaticSize.X
    badgeLabel.Position               = UDim2.new(0, 8, 0, 0)
    badgeLabel.BackgroundTransparency = 1
    badgeLabel.Text                   = label
    badgeLabel.Font                   = CFG.FontMono
    badgeLabel.TextSize               = 8
    badgeLabel.TextColor3             = accent
    badgeLabel.ZIndex                 = CFG.ZIndex + 5
    badgeLabel.Parent                 = badge

    -- ── Close button ────────────────────────────
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                  = "CloseBtn"
    closeBtn.Size                  = UDim2.new(0, 20, 0, 20)
    closeBtn.Position              = UDim2.new(1, -29, 0, 9)
    closeBtn.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundTransparency = 0.95
    closeBtn.BorderSizePixel       = 0
    closeBtn.Text                  = "✕"
    closeBtn.Font                  = CFG.Font
    closeBtn.TextSize              = 9
    closeBtn.TextColor3            = Color3.fromRGB(160, 160, 185)
    closeBtn.AutoButtonColor       = false
    closeBtn.ZIndex                = CFG.ZIndex + 5
    closeBtn.Parent                = frame
    addCorner(closeBtn, 6)

    local closeBtnStroke = Instance.new("UIStroke")
    closeBtnStroke.Color       = Color3.fromRGB(255, 255, 255)
    closeBtnStroke.Transparency = 0.92
    closeBtnStroke.Thickness   = 1
    closeBtnStroke.Parent      = closeBtn

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {
            BackgroundColor3        = Color3.fromRGB(255, 60, 60),
            BackgroundTransparency  = 0.8,
            TextColor3              = Color3.fromRGB(255, 100, 100),
        }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {
            BackgroundColor3        = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency  = 0.95,
            TextColor3              = Color3.fromRGB(160, 160, 185),
        }):Play()
    end)

    -- ── Image thumbnail (optional) ───────────────
    local contentX = 14
    if hasImg then
        local thumb = Instance.new("ImageLabel")
        thumb.Size                   = UDim2.new(0, 38, 0, 38)
        thumb.Position               = UDim2.new(0, 12, 0, 32)
        thumb.BackgroundColor3       = Color3.fromRGB(30, 30, 40)
        thumb.BackgroundTransparency = 0
        thumb.Image                  = opts.Image
        thumb.ScaleType              = Enum.ScaleType.Crop
        thumb.ZIndex                 = CFG.ZIndex + 4
        thumb.Parent                 = frame
        addCorner(thumb, 7)

        local thumbStroke = Instance.new("UIStroke")
        thumbStroke.Color       = Color3.fromRGB(255, 255, 255)
        thumbStroke.Transparency = 0.9
        thumbStroke.Thickness   = 1
        thumbStroke.Parent      = thumb

        contentX = 58
    end

    -- ── Title ────────────────────────────────────
    local title = Instance.new("TextLabel")
    title.Name                   = "Title"
    title.Size                   = UDim2.new(1, -(contentX + 36), 0, 20)
    title.Position               = UDim2.new(0, contentX, 0, 31)
    title.BackgroundTransparency = 1
    title.Text                   = opts.Title or "Notification"
    title.Font                   = CFG.Font
    title.TextSize               = 13
    title.TextColor3             = Color3.fromRGB(245, 245, 255)
    title.TextXAlignment         = Enum.TextXAlignment.Left
    title.TextTruncate           = Enum.TextTruncate.AtEnd
    title.ZIndex                 = CFG.ZIndex + 4
    title.Parent                 = frame

    -- ── Message ──────────────────────────────────
    local msg = Instance.new("TextLabel")
    msg.Name                   = "Message"
    msg.Size                   = UDim2.new(1, -(contentX + 14), 0, 28)
    msg.Position               = UDim2.new(0, contentX, 0, 51)
    msg.BackgroundTransparency = 1
    msg.Text                   = opts.Message or ""
    msg.Font                   = CFG.FontBody
    msg.TextSize               = 11
    msg.TextColor3             = Color3.fromRGB(155, 155, 180)
    msg.TextXAlignment         = Enum.TextXAlignment.Left
    msg.TextWrapped            = true
    msg.ZIndex                 = CFG.ZIndex + 4
    msg.Parent                 = frame

    -- ── Buttons ──────────────────────────────────
    if hasBtns then
        local btnY = cardH - 34

        local function makeBtn(btnOpts, xPos, btnW)
            if not btnOpts then return end

            local btn = Instance.new("TextButton")
            btn.Size                  = UDim2.new(0, btnW, 0, 24)
            btn.Position              = UDim2.new(0, xPos, 0, btnY)
            btn.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
            btn.BackgroundTransparency = 0.97
            btn.BorderSizePixel       = 0
            btn.Text                  = btnOpts.Text or "OK"
            btn.Font                  = CFG.Font
            btn.TextSize              = 11
            btn.TextColor3            = accent
            btn.AutoButtonColor       = false
            btn.ZIndex                = CFG.ZIndex + 5
            btn.Parent                = frame
            addCorner(btn, 7)

            local stroke = Instance.new("UIStroke")
            stroke.Color       = accent
            stroke.Transparency = 0.72
            stroke.Thickness   = 1
            stroke.Parent      = btn

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.13), {
                    BackgroundColor3        = accent,
                    BackgroundTransparency  = 0.82,
                    TextColor3              = Color3.fromRGB(255, 255, 255),
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.13), { Transparency = 0.5 }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.13), {
                    BackgroundColor3        = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency  = 0.97,
                    TextColor3              = accent,
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.13), { Transparency = 0.72 }):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                if btnOpts.Callback then task.spawn(btnOpts.Callback) end
            end)

            return btn
        end

        local totalBtnW = CFG.CardWidth - 24
        if hasBtn1 and hasBtn2 then
            local half = math.floor((totalBtnW - 6) / 2)
            makeBtn(opts.Button1, 12, half)
            makeBtn(opts.Button2, 12 + half + 6, half)
        elseif hasBtn1 then
            makeBtn(opts.Button1, 12, totalBtnW)
        end
    end

    -- ── Progress bar ─────────────────────────────
    local trackH = 2
    local track = Instance.new("Frame")
    track.Name             = "Track"
    track.Size             = UDim2.new(1, 0, 0, trackH)
    track.Position         = UDim2.new(0, 0, 1, -trackH)
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    track.BackgroundTransparency = 0.95
    track.BorderSizePixel  = 0
    track.ZIndex           = CFG.ZIndex + 4
    track.Parent           = frame

    local fill = Instance.new("Frame")
    fill.Name             = "Fill"
    fill.Size             = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = CFG.ZIndex + 5
    fill.Parent           = track
    addCorner(fill, 2)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0),
    })
    fillGrad.Rotation = 90
    fillGrad.Parent = fill

    return frame, cardH, fill, closeBtn
end

-- ─────────────────────────────────────────────────
--  Public: Notify
-- ─────────────────────────────────────────────────
function NotifyLib:Notify(opts)
    assert(type(opts) == "table", "[NotifyLib] opts must be a table")

    -- Drop oldest if over limit
    if #stack >= CFG.MaxStack then
        local oldest = stack[1]
        if oldest and oldest.dismiss then oldest.dismiss() end
    end

    count += 1
    local duration = opts.Duration or CFG.DefaultDuration

    local frame, height, fill, closeBtn = buildCard(opts)

    -- Position: stacked above existing
    local stackedOffset = CFG.PaddingBottom
    for _, e in ipairs(stack) do
        stackedOffset = stackedOffset + e.height + CFG.Gap
    end

    local targetY = -(stackedOffset + height)
    local targetX = -(CFG.CardWidth + CFG.PaddingRight)

    frame.Position = UDim2.new(1, CFG.CardWidth + 24, 1, targetY)

    table.insert(stack, { frame = frame, height = height })

    -- Slide in
    spring(frame, CFG.SlideInTime, {
        Position = UDim2.new(1, targetX, 1, targetY)
    }):Play()

    -- Progress bar drain
    local progTween = linear(fill, duration, {
        Size = UDim2.new(0, 0, 1, 0)
    })
    progTween:Play()

    local dismissed = false

    local function dismiss()
        if dismissed then return end
        dismissed = true
        progTween:Cancel()

        -- Slide out
        local cur = frame.Position
        local slideOut = TweenService:Create(frame,
            TweenInfo.new(CFG.SlideOutTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { Position = UDim2.new(1, CFG.CardWidth + 24, 1, cur.Y.Offset) }
        )
        slideOut:Play()
        slideOut.Completed:Connect(function()
            removeFromStack(frame)
            frame:Destroy()
        end)
    end

    -- Hover: pause progress
    frame.MouseEnter:Connect(function()
        if not dismissed then
            progTween:Pause()
            TweenService:Create(frame, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(26, 26, 36)
            }):Play()
        end
    end)
    frame.MouseLeave:Connect(function()
        if not dismissed then
            progTween:Play()
            TweenService:Create(frame, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(22, 22, 31)
            }):Play()
        end
    end)

    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)

    return { Dismiss = dismiss, Frame = frame }
end

-- ─────────────────────────────────────────────────
--  Public: ClearAll
-- ─────────────────────────────────────────────────
function NotifyLib:ClearAll()
    for _, entry in ipairs(table.clone(stack)) do
        if entry.dismiss then entry.dismiss() end
        entry.frame:Destroy()
    end
    table.clear(stack)
end

-- ─────────────────────────────────────────────────
--  Public: UpdateConfig
-- ─────────────────────────────────────────────────
function NotifyLib:UpdateConfig(tbl)
    for k, v in pairs(tbl) do CFG[k] = v end
end

return NotifyLib
