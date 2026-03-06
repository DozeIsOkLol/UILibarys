-- ╔══════════════════════════════════════════╗
-- ║        KeystrokeUI by loadstring         ║
-- ║   Drag to reposition • Works externally  ║
-- ╚══════════════════════════════════════════╝

local Players        = game:GetService("Players")
local UIS            = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")

local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

-- ══════════════ CONFIG ══════════════
local CFG = {
    -- Colors
    BG_IDLE      = Color3.fromRGB(15, 15, 20),
    BG_PRESSED   = Color3.fromRGB(80, 200, 255),
    TEXT_IDLE    = Color3.fromRGB(180, 180, 200),
    TEXT_PRESSED = Color3.fromRGB(10, 10, 15),
    BORDER_IDLE  = Color3.fromRGB(50, 50, 70),
    BORDER_PRESS = Color3.fromRGB(80, 200, 255),
    ACCENT       = Color3.fromRGB(80, 200, 255),

    -- Sizes
    KEY_SIZE     = UDim2.new(0, 46, 0, 46),
    CORNER_R     = UDim.new(0, 8),
    GAP          = 4,

    -- Animation
    TWEEN_IN     = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TWEEN_OUT    = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    -- Toggle key to show/hide UI
    TOGGLE_KEY   = Enum.KeyCode.RightBracket,
}
-- ════════════════════════════════════

-- ══════════ CLEANUP OLD GUI ══════════
local existing = LocalPlayer.PlayerGui:FindFirstChild("KeystrokeUI")
if existing then existing:Destroy() end
-- ════════════════════════════════════

-- ══════════ BUILD GUI ══════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "KeystrokeUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = LocalPlayer.PlayerGui

-- Outer draggable frame
local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0, 152, 0, 156)
Main.Position         = UDim2.new(0.5, -76, 1, -200)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel  = 0
Main.Parent           = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color     = Color3.fromRGB(40, 40, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent    = Main

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 22)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Patch bottom corners of title bar
local TitlePatch = Instance.new("Frame")
TitlePatch.Size             = UDim2.new(1, 0, 0, 12)
TitlePatch.Position         = UDim2.new(0, 0, 1, -12)
TitlePatch.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitlePatch.BorderSizePixel  = 0
TitlePatch.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size              = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "KEYSTROKES"
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextSize          = 9
TitleLabel.TextColor3        = Color3.fromRGB(120, 120, 150)
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Center
TitleLabel.Parent            = TitleBar

-- Key container
local KeyContainer = Instance.new("Frame")
KeyContainer.Name             = "KeyContainer"
KeyContainer.Size             = UDim2.new(1, -16, 1, -30)
KeyContainer.Position         = UDim2.new(0, 8, 0, 26)
KeyContainer.BackgroundTransparency = 1
KeyContainer.Parent           = Main

-- ═══════════════════════════════════════
-- Helper: create a single key button
-- ═══════════════════════════════════════
local function MakeKey(label, posX, posY, sizeOverride)
    local btn = Instance.new("Frame")
    btn.Size             = sizeOverride or CFG.KEY_SIZE
    btn.Position         = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = CFG.BG_IDLE
    btn.BorderSizePixel  = 0
    btn.Parent           = KeyContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CFG.CORNER_R
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color     = CFG.BORDER_IDLE
    stroke.Thickness = 1.5
    stroke.Parent    = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = label
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextSize               = 14
    lbl.TextColor3             = CFG.TEXT_IDLE
    lbl.Parent                 = btn

    return btn, stroke, lbl
end

-- Layout:
--         [W]
--     [A] [S] [D]
--   [SHIFT]  [SPACE ]
--   [LMB]    [RMB]

local KS = 46   -- key size
local G  = 4    -- gap

-- Row 1 – W
local W_frame, W_stroke, W_lbl       = MakeKey("W",     KS+G,        0)
-- Row 2 – A S D
local A_frame, A_stroke, A_lbl       = MakeKey("A",     0,           KS+G)
local S_frame, S_stroke, S_lbl       = MakeKey("S",     KS+G,        KS+G)
local D_frame, D_stroke, D_lbl       = MakeKey("D",     (KS+G)*2,    KS+G)
-- Row 3 – Shift / Space  (wide keys)
local SH_W = UDim2.new(0, KS, 0, KS)
local SP_W = UDim2.new(0, KS*2+G, 0, KS)  -- double-wide
local SH_frame, SH_stroke, SH_lbl   = MakeKey("⇧",    0,           (KS+G)*2, SH_W)
local SP_frame, SP_stroke, SP_lbl   = MakeKey("SPC",   KS+G,        (KS+G)*2, SP_W)

-- Resize container to fit
KeyContainer.Size = UDim2.new(0, KS*3+G*2, 0, KS*3+G*2)
Main.Size         = UDim2.new(0, KS*3+G*2+16, 0, KS*3+G*2+34)

-- ═══════════════════════════════════
-- Press / Release animation helpers
-- ═══════════════════════════════════
local function PressKey(frame, stroke, lbl)
    TweenService:Create(frame,  CFG.TWEEN_IN, {BackgroundColor3 = CFG.BG_PRESSED}):Play()
    TweenService:Create(stroke, CFG.TWEEN_IN, {Color = CFG.BORDER_PRESS}):Play()
    TweenService:Create(lbl,    CFG.TWEEN_IN, {TextColor3 = CFG.TEXT_PRESSED}):Play()
    TweenService:Create(frame,  CFG.TWEEN_IN, {Size = UDim2.new(
        frame.Size.X.Scale, frame.Size.X.Offset - 2,
        frame.Size.Y.Scale, frame.Size.Y.Offset - 2
    )}):Play()
end

local function ReleaseKey(frame, stroke, lbl, origSize)
    TweenService:Create(frame,  CFG.TWEEN_OUT, {BackgroundColor3 = CFG.BG_IDLE}):Play()
    TweenService:Create(stroke, CFG.TWEEN_OUT, {Color = CFG.BORDER_IDLE}):Play()
    TweenService:Create(lbl,    CFG.TWEEN_OUT, {TextColor3 = CFG.TEXT_IDLE}):Play()
    TweenService:Create(frame,  CFG.TWEEN_OUT, {Size = origSize}):Play()
end

-- Store original sizes
local origSizes = {
    [W_frame]  = W_frame.Size,
    [A_frame]  = A_frame.Size,
    [S_frame]  = S_frame.Size,
    [D_frame]  = D_frame.Size,
    [SH_frame] = SH_frame.Size,
    [SP_frame] = SP_frame.Size,
}

-- Key → frame/stroke/lbl mapping
local KeyMap = {
    [Enum.KeyCode.W]          = {W_frame,  W_stroke,  W_lbl},
    [Enum.KeyCode.A]          = {A_frame,  A_stroke,  A_lbl},
    [Enum.KeyCode.S]          = {S_frame,  S_stroke,  S_lbl},
    [Enum.KeyCode.D]          = {D_frame,  D_stroke,  D_lbl},
    [Enum.KeyCode.LeftShift]  = {SH_frame, SH_stroke, SH_lbl},
    [Enum.KeyCode.RightShift] = {SH_frame, SH_stroke, SH_lbl},
    [Enum.KeyCode.Space]      = {SP_frame, SP_stroke, SP_lbl},
}

-- ═══════════════════════════════════
-- Input Listeners
-- ═══════════════════════════════════
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Toggle visibility
    if input.KeyCode == CFG.TOGGLE_KEY then
        Main.Visible = not Main.Visible
        return
    end

    local k = KeyMap[input.KeyCode]
    if k then
        PressKey(k[1], k[2], k[3])
    end
end)

UIS.InputEnded:Connect(function(input)
    local k = KeyMap[input.KeyCode]
    if k then
        ReleaseKey(k[1], k[2], k[3], origSizes[k[1]])
    end
end)

-- ═══════════════════════════════════
-- Dragging Logic
-- ═══════════════════════════════════
local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = Main.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ═══════════════════════════════════
-- Subtle idle pulse on border
-- ═══════════════════════════════════
local t = 0
RunService.RenderStepped:Connect(function(dt)
    t += dt
    local alpha = (math.sin(t * 1.2) + 1) / 2  -- 0..1
    local r = math.floor(30 + alpha * 20)
    local g = math.floor(30 + alpha * 20)
    local b = math.floor(50 + alpha * 25)
    MainStroke.Color = Color3.fromRGB(r, g, b)
end)

print("[KeystrokeUI] Loaded! Press " .. tostring(CFG.TOGGLE_KEY) .. " to toggle.")
