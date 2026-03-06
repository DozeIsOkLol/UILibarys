--[[
╔══════════════════════════════════════════════════════════════╗
║                   NotifyLib  ·  v0.3                         ║
║            Roblox Notification ModuleScript                  ║
╠══════════════════════════════════════════════════════════════╣
║  NEW IN v3:                                                  ║
║  · Queue system   – overflow waits, then auto-shows          ║
║  · Priority       – High / Normal / Low                      ║
║  · Positions      – BottomRight/BottomLeft/TopRight/TopLeft  ║
║  · Sounds         – per-type SoundId support                 ║
║  · OnDismiss      – callback fired when card leaves          ║
║  · Update()       – change title/msg on a live notification  ║
║  · Persistent     – cards that never auto-dismiss            ║
║  · HideProgress   – optional hidden progress bar             ║
║  · Icon override  – custom rbxassetid per notification       ║
║  · History log    – GetHistory() / ClearHistory()            ║
║  · Themes         – Dark (default) / Light / Midnight        ║
║  · ClearType()    – dismiss only a specific type             ║
║  · Pause/Resume   – NotifyLib:Pause() / :Resume()            ║
╚══════════════════════════════════════════════════════════════╝
--]]

-- ────────────────────────────────────────────────────────────
--  Services
-- ────────────────────────────────────────────────────────────
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local SoundService   = game:GetService("SoundService")
local RunService     = game:GetService("RunService")

local LocalPlayer    = Players.LocalPlayer
local PlayerGui      = LocalPlayer:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────────────────
--  Enums (string constants for readability)
-- ────────────────────────────────────────────────────────────
local Priority = { High = 3, Normal = 2, Low = 1 }
local Position = {
    BottomRight = "BottomRight",
    BottomLeft  = "BottomLeft",
    TopRight    = "TopRight",
    TopLeft     = "TopLeft",
}

-- ────────────────────────────────────────────────────────────
--  Default Config  (override with NotifyLib:SetConfig())
-- ────────────────────────────────────────────────────────────
local CFG = {
    -- Layout
    Position         = Position.BottomRight,
    MaxVisible       = 5,           -- cards on screen at once
    MaxQueue         = 20,          -- queued notifications cap
    CardWidth        = 318,
    EdgePadding      = 16,          -- screen edge gap
    CardGap          = 9,
    DefaultDuration  = 5,

    -- Animation
    SlideInDuration  = 0.40,
    SlideOutDuration = 0.22,
    ShiftDuration    = 0.30,

    -- Font
    Font      = Enum.Font.GothamBold,
    FontBody  = Enum.Font.Gotham,
    FontMono  = Enum.Font.Code,

    -- Theme  ("Dark" | "Light" | "Midnight")
    Theme = "Dark",

    -- Sound toggle
    PlaySounds = true,

    -- ZIndex base
    ZIndex = 950,
}

-- ────────────────────────────────────────────────────────────
--  Themes
-- ────────────────────────────────────────────────────────────
local THEMES = {
    Dark = {
        CardBG         = Color3.fromRGB(20,  20,  28),
        CardBGHover    = Color3.fromRGB(26,  26,  36),
        CardBGGrad     = Color3.fromRGB(14,  14,  20),
        TextTitle      = Color3.fromRGB(245, 245, 255),
        TextBody       = Color3.fromRGB(148, 148, 175),
        CloseBG        = Color3.fromRGB(255, 255, 255),
        CloseBGHover   = Color3.fromRGB(255,  60,  60),
        CloseText      = Color3.fromRGB(150, 150, 180),
        TrackBG        = Color3.fromRGB(255, 255, 255),
        TrackOpacity   = 0.94,
        ShimmerOpacity = 0.50,
        ShadowOpacity  = 0.42,
        BorderOpacity  = 0.92,
    },
    Light = {
        CardBG         = Color3.fromRGB(250, 250, 255),
        CardBGHover    = Color3.fromRGB(242, 242, 252),
        CardBGGrad     = Color3.fromRGB(235, 235, 248),
        TextTitle      = Color3.fromRGB(15,  15,  30),
        TextBody       = Color3.fromRGB(80,  80, 110),
        CloseBG        = Color3.fromRGB(0,    0,   0),
        CloseBGHover   = Color3.fromRGB(255,  60,  60),
        CloseText      = Color3.fromRGB(130, 130, 155),
        TrackBG        = Color3.fromRGB(0,    0,   0),
        TrackOpacity   = 0.90,
        ShimmerOpacity = 0.30,
        ShadowOpacity  = 0.15,
        BorderOpacity  = 0.86,
    },
    Midnight = {
        CardBG         = Color3.fromRGB(10,  10,  18),
        CardBGHover    = Color3.fromRGB(16,  16,  26),
        CardBGGrad     = Color3.fromRGB(6,    6,  12),
        TextTitle      = Color3.fromRGB(220, 220, 240),
        TextBody       = Color3.fromRGB(120, 120, 155),
        CloseBG        = Color3.fromRGB(255, 255, 255),
        CloseBGHover   = Color3.fromRGB(255,  60,  60),
        CloseText      = Color3.fromRGB(120, 120, 155),
        TrackBG        = Color3.fromRGB(255, 255, 255),
        TrackOpacity   = 0.96,
        ShimmerOpacity = 0.40,
        ShadowOpacity  = 0.60,
        BorderOpacity  = 0.94,
    },
}

-- ────────────────────────────────────────────────────────────
--  Notification Types
-- ────────────────────────────────────────────────────────────
local TYPES = {
    Success = {
        Color   = Color3.fromRGB(34,  213,  90),
        Label   = "SUCCESS",
        Icon    = "rbxassetid://7733715400",
        Sound   = "rbxassetid://9120386446",
    },
    Error = {
        Color   = Color3.fromRGB(255,  70,  70),
        Label   = "ERROR",
        Icon    = "rbxassetid://7733672041",
        Sound   = "rbxassetid://9120385676",
    },
    Warning = {
        Color   = Color3.fromRGB(245, 168,  35),
        Label   = "WARNING",
        Icon    = "rbxassetid://7733961674",
        Sound   = "rbxassetid://9120386715",
    },
    Info = {
        Color   = Color3.fromRGB(77,  159, 255),
        Label   = "INFO",
        Icon    = "rbxassetid://7733960981",
        Sound   = "rbxassetid://9120386252",
    },
    Custom = {
        Color   = Color3.fromRGB(180,  92, 255),
        Label   = "NOTICE",
        Icon    = "rbxassetid://7733960981",
        Sound   = "rbxassetid://9120386252",
    },
}

-- ────────────────────────────────────────────────────────────
--  Internal State
-- ────────────────────────────────────────────────────────────
local NotifyLib       = {}
NotifyLib.__index     = NotifyLib

local visible         = {}   -- { id, frame, height, dismiss, type }
local queue           = {}   -- pending opts tables
local history         = {}   -- all notifications ever shown
local globalPaused    = false
local notifID         = 0

-- ────────────────────────────────────────────────────────────
--  ScreenGui
-- ────────────────────────────────────────────────────────────
local Gui = Instance.new("ScreenGui")
Gui.Name           = "NotifyLib_GUI"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder   = CFG.ZIndex
Gui.IgnoreGuiInset = true
Gui.Parent         = PlayerGui

-- ────────────────────────────────────────────────────────────
--  Utility
-- ────────────────────────────────────────────────────────────
local function tw(obj, t, style, dir, props)
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

local function addCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local function addStroke(p, color, trans, thick)
    local s = Instance.new("UIStroke")
    s.Color        = color
    s.Transparency = trans
    s.Thickness    = thick or 1
    s.Parent       = p
    return s
end

local function playSound(soundId)
    if not CFG.PlaySounds then return end
    if not soundId or soundId == "" then return end
    local ok, s = pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId    = soundId
        snd.Volume     = 0.35
        snd.RollOffMaxDistance = 0
        snd.Parent     = SoundService
        snd:Play()
        game:GetService("Debris"):AddItem(snd, 4)
    end)
end

-- Get anchor / direction info from position setting
local function getLayout()
    local p = CFG.Position
    local isRight  = (p == Position.BottomRight or p == Position.TopRight)
    local isBottom = (p == Position.BottomLeft  or p == Position.BottomRight)
    return {
        anchorX  = isRight  and 1 or 0,
        anchorY  = isBottom and 1 or 0,
        dirX     = isRight  and -1 or 1,
        dirY     = isBottom and -1 or 1,
        offscreenX = isRight and (CFG.CardWidth + 30) or -(CFG.CardWidth + 30),
    }
end

-- Reposition all visible cards cleanly
local function rebuildStack()
    local L      = getLayout()
    local offset = CFG.EdgePadding

    -- Iterate from bottom of stack up (index 1 = bottom-most visible)
    for i = #visible, 1, -1 do
        local e    = visible[i]
        local posX = L.dirX * (CFG.CardWidth + CFG.EdgePadding)
        local posY = L.dirY * (offset + e.height)

        tw(e.frame, CFG.ShiftDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            Position = UDim2.new(L.anchorX, posX, L.anchorY, posY)
        }):Play()

        offset = offset + e.height + CFG.CardGap
    end
end

-- Remove entry from visible list and trigger queue
local function removeVisible(id)
    for i, e in ipairs(visible) do
        if e.id == id then
            table.remove(visible, i)
            break
        end
    end
    -- Show next queued item (after a tiny delay so the slide-out finishes)
    task.delay(CFG.SlideOutDuration + 0.05, function()
        rebuildStack()
        if #queue > 0 then
            local next = table.remove(queue, 1)
            NotifyLib:_show(next)
        end
    end)
end

-- ────────────────────────────────────────────────────────────
--  Card Heights
-- ────────────────────────────────────────────────────────────
local function calcHeight(opts)
    local hasBtns = opts.Button1 ~= nil
    local hasImg  = opts.Image ~= nil

    if hasBtns and hasImg then return 122 end
    if hasBtns then return 110 end
    if hasImg  then return  94 end
    return 80
end

-- ────────────────────────────────────────────────────────────
--  Build Card UI
-- ────────────────────────────────────────────────────────────
local function buildCard(opts, id)
    local typeDef    = TYPES[opts.Type] or TYPES.Info
    local accent     = opts.Color    or typeDef.Color
    local label      = opts.Label    or typeDef.Label
    local iconId     = opts.Icon     or typeDef.Icon
    local theme      = THEMES[CFG.Theme] or THEMES.Dark
    local cardH      = calcHeight(opts)
    local L          = getLayout()

    -- ── Root ────────────────────────────────────────
    local frame = Instance.new("Frame")
    frame.Name             = "NCard_" .. id
    frame.Size             = UDim2.new(0, CFG.CardWidth, 0, cardH)
    frame.BackgroundColor3 = theme.CardBG
    frame.BorderSizePixel  = 0
    frame.ZIndex           = CFG.ZIndex + 1
    frame.ClipsDescendants = false

    -- Start off-screen
    local startX = L.anchorX == 1
        and (-(CFG.CardWidth + CFG.EdgePadding))   -- right side, card slides from right
        or  (CFG.CardWidth + CFG.EdgePadding)      -- left side
    -- Placeholder Y; will be corrected by rebuildStack after insertion
    frame.Position = UDim2.new(L.anchorX, L.dirX * (CFG.CardWidth + 50), L.anchorY,
        L.dirY * (CFG.EdgePadding + cardH))
    frame.Parent = Gui
    addCorner(frame, 12)

    -- Card border (very subtle)
    addStroke(frame, Color3.fromRGB(255,255,255), theme.BorderOpacity, 1)

    -- Background gradient
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.CardBG),
        ColorSequenceKeypoint.new(1, theme.CardBGGrad),
    })
    bgGrad.Rotation = 140
    bgGrad.Parent   = frame

    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size                   = UDim2.new(1, 36, 1, 36)
    shadow.Position               = UDim2.new(0, -18, 0, -6)
    shadow.BackgroundTransparency = 1
    shadow.Image                  = "rbxassetid://6014261993"
    shadow.ImageColor3            = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency      = theme.ShadowOpacity
    shadow.ScaleType              = Enum.ScaleType.Slice
    shadow.SliceCenter            = Rect.new(49, 49, 450, 450)
    shadow.ZIndex                 = CFG.ZIndex
    shadow.Parent                 = frame

    -- Top shimmer (1px highlight)
    local shimmer = Instance.new("Frame")
    shimmer.Size             = UDim2.new(1, 0, 0, 1)
    shimmer.BackgroundColor3 = accent
    shimmer.BackgroundTransparency = theme.ShimmerOpacity
    shimmer.BorderSizePixel  = 0
    shimmer.ZIndex           = CFG.ZIndex + 5
    shimmer.Parent           = frame

    local shimGrad = Instance.new("UIGradient")
    shimGrad.Transparency = NumberSequence.new(
        {NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.65, 0), NumberSequenceKeypoint.new(1, 1)}
    )
    shimGrad.Parent = shimmer

    -- Left accent strip
    local strip = Instance.new("Frame")
    strip.Size             = UDim2.new(0, 3, 1, 0)
    strip.BackgroundColor3 = accent
    strip.BorderSizePixel  = 0
    strip.ZIndex           = CFG.ZIndex + 4
    strip.Parent           = frame
    addCorner(strip, 12)

    -- Soft inner glow from left strip
    local glow = Instance.new("Frame")
    glow.Size             = UDim2.new(0, 90, 1, 0)
    glow.BackgroundColor3 = accent
    glow.BackgroundTransparency = 0.95
    glow.BorderSizePixel  = 0
    glow.ZIndex           = CFG.ZIndex + 2
    glow.Parent           = frame
    local glowG = Instance.new("UIGradient")
    glowG.Transparency = NumberSequence.new(
        {NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
    )
    glowG.Parent = glow

    -- Priority indicator (high = pulsing dot in badge area)
    if opts.Priority == Priority.High then
        local pulse = Instance.new("Frame")
        pulse.Size             = UDim2.new(0, 6, 0, 6)
        pulse.Position         = UDim2.new(1, -11, 0, 10)
        pulse.AnchorPoint      = Vector2.new(0.5, 0.5)
        pulse.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        pulse.BorderSizePixel  = 0
        pulse.ZIndex           = CFG.ZIndex + 6
        pulse.Parent           = frame
        addCorner(pulse, 99)

        -- Pulse animation
        local pulseTween = TweenService:Create(pulse,
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { BackgroundTransparency = 0.5, Size = UDim2.new(0, 9, 0, 9) }
        )
        pulseTween:Play()
    end

    -- ── Badge ────────────────────────────────────
    local badge = Instance.new("Frame")
    badge.Name                  = "Badge"
    badge.Size                  = UDim2.new(0, 0, 0, 18)
    badge.AutomaticSize         = Enum.AutomaticSize.X
    badge.Position              = UDim2.new(0, 12, 0, 10)
    badge.BackgroundColor3      = accent
    badge.BackgroundTransparency = 0.86
    badge.BorderSizePixel       = 0
    badge.ZIndex                = CFG.ZIndex + 5
    badge.Parent                = frame
    addCorner(badge, 99)
    addStroke(badge, accent, 0.68, 1)

    local badgePad = Instance.new("UIPadding")
    badgePad.PaddingLeft   = UDim.new(0, 6)
    badgePad.PaddingRight  = UDim.new(0, 8)
    badgePad.Parent        = badge

    local badgeLayout = Instance.new("UIListLayout")
    badgeLayout.FillDirection = Enum.FillDirection.Horizontal
    badgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    badgeLayout.Padding = UDim.new(0, 5)
    badgeLayout.Parent  = badge

    local bdot = Instance.new("Frame")
    bdot.Size             = UDim2.new(0, 5, 0, 5)
    bdot.BackgroundColor3 = accent
    bdot.BorderSizePixel  = 0
    bdot.ZIndex           = CFG.ZIndex + 6
    bdot.Parent           = badge
    addCorner(bdot, 99)

    local btext = Instance.new("TextLabel")
    btext.Size                  = UDim2.new(0, 0, 1, 0)
    btext.AutomaticSize         = Enum.AutomaticSize.X
    btext.BackgroundTransparency = 1
    btext.Text                  = label
    btext.Font                  = CFG.FontMono
    btext.TextSize              = 8
    btext.TextColor3            = accent
    btext.ZIndex                = CFG.ZIndex + 6
    btext.Parent                = badge

    -- ── Icon ────────────────────────────────────
    local iconFrame = Instance.new("Frame")
    iconFrame.Size             = UDim2.new(0, 28, 0, 28)
    iconFrame.Position         = UDim2.new(0, 12, 0, 34)
    iconFrame.BackgroundColor3 = accent
    iconFrame.BackgroundTransparency = 0.88
    iconFrame.BorderSizePixel  = 0
    iconFrame.ZIndex           = CFG.ZIndex + 4
    iconFrame.Parent           = frame
    addCorner(iconFrame, 8)

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size                   = UDim2.new(0.7, 0, 0.7, 0)
    iconImg.Position               = UDim2.new(0.15, 0, 0.15, 0)
    iconImg.BackgroundTransparency = 1
    iconImg.Image                  = iconId
    iconImg.ImageColor3            = accent
    iconImg.ZIndex                 = CFG.ZIndex + 5
    iconImg.Parent                 = iconFrame

    -- Optional image thumbnail (overrides icon)
    if opts.Image then
        iconFrame.Size = UDim2.new(0, 36, 0, 36)
        iconFrame.Position = UDim2.new(0, 12, 0, 32)
        iconFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        iconFrame.BackgroundTransparency = 0
        iconImg.Size   = UDim2.new(1, 0, 1, 0)
        iconImg.Position = UDim2.new(0, 0, 0, 0)
        iconImg.Image  = opts.Image
        iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
        addStroke(iconFrame, Color3.fromRGB(255, 255, 255), 0.90, 1)
    end

    -- ── Close button ────────────────────────────
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size                  = UDim2.new(0, 20, 0, 20)
    closeBtn.Position              = UDim2.new(1, -28, 0, 9)
    closeBtn.BackgroundColor3      = theme.CloseBG
    closeBtn.BackgroundTransparency = 0.95
    closeBtn.BorderSizePixel       = 0
    closeBtn.Text                  = "✕"
    closeBtn.Font                  = CFG.Font
    closeBtn.TextSize              = 9
    closeBtn.TextColor3            = theme.CloseText
    closeBtn.AutoButtonColor       = false
    closeBtn.ZIndex                = CFG.ZIndex + 6
    closeBtn.Parent                = frame
    addCorner(closeBtn, 6)
    addStroke(closeBtn, theme.CloseBG, 0.91, 1)

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {
            BackgroundColor3        = Color3.fromRGB(255, 60, 60),
            BackgroundTransparency  = 0.78,
            TextColor3              = Color3.fromRGB(255, 110, 110),
        }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {
            BackgroundColor3        = theme.CloseBG,
            BackgroundTransparency  = 0.95,
            TextColor3              = theme.CloseText,
        }):Play()
    end)

    -- ── Title ────────────────────────────────────
    local contentX = 49  -- after icon
    local contentW = -(contentX + 34)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name                   = "Title"
    titleLabel.Size                   = UDim2.new(1, contentW, 0, 20)
    titleLabel.Position               = UDim2.new(0, contentX, 0, 32)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text                   = opts.Title or "Notification"
    titleLabel.Font                   = CFG.Font
    titleLabel.TextSize               = 13
    titleLabel.TextColor3             = theme.TextTitle
    titleLabel.TextXAlignment         = Enum.TextXAlignment.Left
    titleLabel.TextTruncate           = Enum.TextTruncate.AtEnd
    titleLabel.ZIndex                 = CFG.ZIndex + 5
    titleLabel.Parent                 = frame

    -- ── Message ──────────────────────────────────
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Name                   = "Message"
    msgLabel.Size                   = UDim2.new(1, contentW, 0, 24)
    msgLabel.Position               = UDim2.new(0, contentX, 0, 52)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text                   = opts.Message or ""
    msgLabel.Font                   = CFG.FontBody
    msgLabel.TextSize               = 11
    msgLabel.TextColor3             = theme.TextBody
    msgLabel.TextXAlignment         = Enum.TextXAlignment.Left
    msgLabel.TextWrapped            = true
    msgLabel.ZIndex                 = CFG.ZIndex + 5
    msgLabel.Parent                 = frame

    -- ── Action Buttons ───────────────────────────
    if opts.Button1 or opts.Button2 then
        local btnY   = cardH - 32
        local totalW = CFG.CardWidth - 24
        local hasBoth = opts.Button1 and opts.Button2

        local function makeBtn(def, xPos, btnW)
            if not def then return end
            local btn = Instance.new("TextButton")
            btn.Size                  = UDim2.new(0, btnW, 0, 24)
            btn.Position              = UDim2.new(0, xPos, 0, btnY)
            btn.BackgroundColor3      = accent
            btn.BackgroundTransparency = 0.90
            btn.BorderSizePixel       = 0
            btn.Text                  = def.Text or "OK"
            btn.Font                  = CFG.Font
            btn.TextSize              = 11
            btn.TextColor3            = accent
            btn.AutoButtonColor       = false
            btn.ZIndex                = CFG.ZIndex + 6
            btn.Parent                = frame
            addCorner(btn, 7)
            addStroke(btn, accent, 0.70, 1)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.13), {
                    BackgroundTransparency = 0.75,
                    TextColor3             = Color3.fromRGB(255, 255, 255),
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.13), {
                    BackgroundTransparency = 0.90,
                    TextColor3             = accent,
                }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                if def.Callback then task.spawn(def.Callback) end
            end)
            return btn
        end

        if hasBoth then
            local half = math.floor((totalW - 6) / 2)
            makeBtn(opts.Button1, 12, half)
            makeBtn(opts.Button2, 12 + half + 6, half)
        else
            makeBtn(opts.Button1 or opts.Button2, 12, totalW)
        end
    end

    -- ── Progress Bar ─────────────────────────────
    local progressFill
    if not opts.HideProgress then
        local trackFrame = Instance.new("Frame")
        trackFrame.Name             = "ProgressTrack"
        trackFrame.Size             = UDim2.new(1, 0, 0, 3)
        trackFrame.Position         = UDim2.new(0, 0, 1, -3)
        trackFrame.BackgroundColor3 = theme.TrackBG
        trackFrame.BackgroundTransparency = theme.TrackOpacity
        trackFrame.BorderSizePixel  = 0
        trackFrame.ZIndex           = CFG.ZIndex + 5
        trackFrame.ClipsDescendants = true
        trackFrame.Parent           = frame
        addCorner(trackFrame, 3)

        progressFill = Instance.new("Frame")
        progressFill.Name             = "ProgressFill"
        progressFill.Size             = UDim2.new(1, 0, 1, 0)
        progressFill.BackgroundColor3 = accent
        progressFill.BorderSizePixel  = 0
        progressFill.ZIndex           = CFG.ZIndex + 6
        progressFill.Parent           = trackFrame

        local fillGrad = Instance.new("UIGradient")
        fillGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.10),
            NumberSequenceKeypoint.new(1, 0),
        })
        fillGrad.Rotation = 90
        fillGrad.Parent   = progressFill
    end

    return frame, cardH, progressFill, closeBtn, titleLabel, msgLabel
end

-- ────────────────────────────────────────────────────────────
--  Internal Show  (used by :Notify and the queue)
-- ────────────────────────────────────────────────────────────
function NotifyLib:_show(opts)
    if globalPaused then
        table.insert(queue, 1, opts)   -- re-insert at front
        return
    end

    notifID += 1
    local id       = notifID
    local duration = opts.Persistent and math.huge or (opts.Duration or CFG.DefaultDuration)

    local frame, height, progFill, closeBtn, titleLbl, msgLbl =
        buildCard(opts, id)

    local entry = { id = id, frame = frame, height = height, type = opts.Type }
    table.insert(visible, entry)

    -- Record in history
    table.insert(history, {
        id        = id,
        type      = opts.Type or "Info",
        title     = opts.Title or "",
        message   = opts.Message or "",
        timestamp = os.time(),
    })

    -- ── Animate in ──────────────────────────────
    rebuildStack()   -- set correct Y for all cards

    -- Then slide in from off-screen X
    local L = getLayout()
    local finalX = L.dirX * (CFG.CardWidth + CFG.EdgePadding)

    task.delay(0.02, function()
        -- Get current Y from rebuildStack, slide in on X
        local cur = frame.Position
        frame.Position = UDim2.new(L.anchorX, L.dirX * (CFG.CardWidth + 50), cur.Y.Scale, cur.Y.Offset)

        TweenService:Create(frame,
            TweenInfo.new(CFG.SlideInDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(L.anchorX, finalX, cur.Y.Scale, cur.Y.Offset) }
        ):Play()
    end)

    -- ── Sound ────────────────────────────────────
    local typeDef = TYPES[opts.Type] or TYPES.Info
    playSound(opts.Sound or typeDef.Sound)

    -- ── Progress tween ───────────────────────────
    local progTween
    if progFill and not opts.Persistent then
        progTween = TweenService:Create(progFill,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            { Size = UDim2.new(0, 0, 1, 0) }
        )
        progTween:Play()
    end

    -- ── Dismiss logic ────────────────────────────
    local dismissed = false

    local function dismiss(reason)
        if dismissed then return end
        dismissed = true

        if progTween then progTween:Cancel() end

        -- Fire callback
        if opts.OnDismiss then
            task.spawn(opts.OnDismiss, reason or "auto", id)
        end

        local L2 = getLayout()
        local cur = frame.Position
        TweenService:Create(frame,
            TweenInfo.new(CFG.SlideOutDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { Position = UDim2.new(L2.anchorX, L2.dirX * (CFG.CardWidth + 50), cur.Y.Scale, cur.Y.Offset) }
        ):Play()

        task.delay(CFG.SlideOutDuration + 0.05, function()
            frame:Destroy()
            removeVisible(id)
        end)
    end

    entry.dismiss = dismiss

    -- ── Hover: pause progress ────────────────────
    local theme = THEMES[CFG.Theme] or THEMES.Dark

    frame.MouseEnter:Connect(function()
        if dismissed then return end
        if progTween then progTween:Pause() end
        TweenService:Create(frame, TweenInfo.new(0.14), {
            BackgroundColor3 = theme.CardBGHover
        }):Play()
    end)
    frame.MouseLeave:Connect(function()
        if dismissed then return end
        if progTween then progTween:Play() end
        TweenService:Create(frame, TweenInfo.new(0.14), {
            BackgroundColor3 = theme.CardBG
        }):Play()
    end)

    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        dismiss("user")
    end)

    -- Auto dismiss
    if not opts.Persistent then
        task.delay(duration, function()
            dismiss("auto")
        end)
    end

    -- ── Update method ────────────────────────────
    local function update(newTitle, newMsg)
        if dismissed then return end
        if newTitle and titleLbl then
            titleLbl.Text = newTitle
        end
        if newMsg and msgLbl then
            msgLbl.Text = newMsg
        end
    end

    return {
        Dismiss  = dismiss,
        Update   = update,
        Frame    = frame,
        ID       = id,
    }
end

-- ────────────────────────────────────────────────────────────
--  Public API
-- ────────────────────────────────────────────────────────────

--- Notify(opts)  →  handle { Dismiss, Update, Frame, ID }
--
--  opts fields:
--    Title          string
--    Message        string
--    Type           "Success"|"Error"|"Warning"|"Info"|"Custom"
--    Duration       number  (seconds, default 5)
--    Persistent     bool    (never auto-dismiss)
--    Priority       Priority.High / .Normal / .Low
--    Color          Color3  (custom accent)
--    Label          string  (custom badge text)
--    Icon           string  (rbxassetid://)
--    Image          string  (thumbnail rbxassetid://)
--    Sound          string  (rbxassetid://)
--    Button1        { Text="…", Callback=fn }
--    Button2        { Text="…", Callback=fn }
--    HideProgress   bool
--    OnDismiss      fn(reason, id)   reason = "auto"|"user"
function NotifyLib:Notify(opts)
    assert(type(opts) == "table", "[NotifyLib] opts must be a table")

    -- Respect priority ordering in the queue
    if #visible >= CFG.MaxVisible then
        if #queue >= CFG.MaxQueue then return nil end  -- drop silently if queue full

        -- Insert into queue at correct priority position
        local pri = opts.Priority or Priority.Normal
        local inserted = false
        for i, q in ipairs(queue) do
            if (q.Priority or Priority.Normal) < pri then
                table.insert(queue, i, opts)
                inserted = true
                break
            end
        end
        if not inserted then
            table.insert(queue, opts)
        end
        return nil
    end

    return self:_show(opts)
end

--- ClearAll()  – dismiss every visible notification
function NotifyLib:ClearAll()
    for _, e in ipairs(table.clone(visible)) do
        if e.dismiss then e.dismiss("clear") end
    end
    table.clear(visible)
    table.clear(queue)
end

--- ClearType(typeName)  – dismiss only cards of a given type
function NotifyLib:ClearType(typeName)
    for _, e in ipairs(table.clone(visible)) do
        if e.type == typeName and e.dismiss then
            e.dismiss("clear")
        end
    end
end

--- Pause()  – stop showing new notifications (queue still builds)
function NotifyLib:Pause()
    globalPaused = true
end

--- Resume()  – un-pause and flush the queue
function NotifyLib:Resume()
    globalPaused = false
    while #visible < CFG.MaxVisible and #queue > 0 do
        local next = table.remove(queue, 1)
        self:_show(next)
    end
end

--- GetHistory()  – returns the log table (read-only snapshot)
function NotifyLib:GetHistory()
    return table.clone(history)
end

--- ClearHistory()
function NotifyLib:ClearHistory()
    table.clear(history)
end

--- GetQueueLength()  – how many are waiting
function NotifyLib:GetQueueLength()
    return #queue
end

--- GetVisibleCount()
function NotifyLib:GetVisibleCount()
    return #visible
end

--- SetTheme(name)  – "Dark" | "Light" | "Midnight"
function NotifyLib:SetTheme(name)
    assert(THEMES[name], "[NotifyLib] Unknown theme: " .. tostring(name))
    CFG.Theme = name
end

--- SetPosition(pos)  – use Position.BottomRight etc.
function NotifyLib:SetPosition(pos)
    CFG.Position = pos
end

--- SetConfig(tbl)  – override any config keys
function NotifyLib:SetConfig(tbl)
    for k, v in pairs(tbl) do CFG[k] = v end
end

-- Export enums so callers don't need to hardcode strings
NotifyLib.Priority = Priority
NotifyLib.Position = Position

return NotifyLib
