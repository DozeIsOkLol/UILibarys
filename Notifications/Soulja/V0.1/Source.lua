--[[
    ╔══════════════════════════════════════════════╗
    ║          NotifyLib — v1.0.0                  ║
    ║    A sleek Roblox Notification Library       ║
    ╚══════════════════════════════════════════════╝

    USAGE EXAMPLE:
    ──────────────
    local NotifyLib = require(path.to.NotifyLib)

    -- Simple notification
    NotifyLib:Notify({
        Title   = "Welcome!",
        Message = "You joined the game.",
        Type    = "Success",   -- "Success" | "Error" | "Warning" | "Info"
        Duration = 5,
    })

    -- With a button
    NotifyLib:Notify({
        Title    = "Update Available",
        Message  = "A new version is ready.",
        Type     = "Info",
        Duration = 8,
        Button1  = { Text = "Dismiss",  Callback = function() end },
        Button2  = { Text = "Reload",   Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end },
    })

    -- Image notification
    NotifyLib:Notify({
        Title   = "Item Received",
        Message = "You got: Dragon Sword!",
        Type    = "Success",
        Image   = "rbxassetid://7733960981",
        Duration = 6,
    })

    -- Custom color
    NotifyLib:Notify({
        Title   = "Server Restart",
        Message = "Server restarting in 60 seconds.",
        Type    = "Custom",
        Color   = Color3.fromRGB(138, 43, 226),
        Duration = 10,
    })

    -- Clear all notifications
    NotifyLib:ClearAll()
--]]

local NotifyLib = {}
NotifyLib.__index = NotifyLib

-- ──────────────────────────────────────────────
--  Services
-- ──────────────────────────────────────────────
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ──────────────────────────────────────────────
--  Constants / Config
-- ──────────────────────────────────────────────
local CONFIG = {
    MaxNotifications  = 5,
    DefaultDuration   = 5,
    Width             = 320,
    PaddingBottom     = 16,
    Gap               = 10,
    AnimDuration      = 0.35,
    Font              = Enum.Font.GothamBold,
    FontBody          = Enum.Font.Gotham,
    CornerRadius      = 10,
    IconSize          = 36,
    ProgressBarHeight = 3,
    ZIndex            = 999,
}

local TYPES = {
    Success = {
        Color   = Color3.fromRGB(34, 197, 94),
        Icon    = "rbxassetid://7733715400",   -- checkmark circle
        Label   = "SUCCESS",
    },
    Error = {
        Color   = Color3.fromRGB(239, 68, 68),
        Icon    = "rbxassetid://7733672041",   -- x circle
        Label   = "ERROR",
    },
    Warning = {
        Color   = Color3.fromRGB(234, 179, 8),
        Icon    = "rbxassetid://7733961674",   -- warning triangle
        Label   = "WARNING",
    },
    Info = {
        Color   = Color3.fromRGB(59, 130, 246),
        Icon    = "rbxassetid://7733960981",   -- info circle
        Label   = "INFO",
    },
    Custom = {
        Color   = Color3.fromRGB(168, 85, 247),
        Icon    = "rbxassetid://7733960981",
        Label   = "NOTICE",
    },
}

-- ──────────────────────────────────────────────
--  Internal State
-- ──────────────────────────────────────────────
local activeNotifications = {}   -- { frame, height }
local notifCount          = 0

-- ──────────────────────────────────────────────
--  ScreenGui Setup
-- ──────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "NotifyLib_GUI"
ScreenGui.ResetOnSpawn     = false
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder     = CONFIG.ZIndex
ScreenGui.IgnoreGuiInset   = true
ScreenGui.Parent           = PlayerGui

local Container = Instance.new("Frame")
Container.Name             = "Container"
Container.Size             = UDim2.new(0, CONFIG.Width, 1, 0)
Container.Position         = UDim2.new(1, -(CONFIG.Width + 16), 0, 0)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = false
Container.ZIndex           = CONFIG.ZIndex
Container.Parent           = ScreenGui

-- ──────────────────────────────────────────────
--  Helpers
-- ──────────────────────────────────────────────
local function tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x"..hex:sub(1,2)),
        tonumber("0x"..hex:sub(3,4)),
        tonumber("0x"..hex:sub(5,6))
    )
end

--- Shifts all existing notifications upward to make room
local function shiftNotifications(excludeFrame, heightDelta)
    for _, entry in ipairs(activeNotifications) do
        if entry.frame ~= excludeFrame then
            local cur = entry.frame.Position
            local newY = cur.Y.Offset - heightDelta - CONFIG.Gap
            tween(entry.frame,
                TweenInfo.new(CONFIG.AnimDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Position = UDim2.new(cur.X.Scale, cur.X.Offset, cur.Y.Scale, newY) }
            ):Play()
        end
    end
end

--- Removes an entry from the active list
local function removeEntry(frame)
    for i, entry in ipairs(activeNotifications) do
        if entry.frame == frame then
            -- Shift everything below up
            local totalHeight = entry.height + CONFIG.Gap
            local found = false
            for j, e in ipairs(activeNotifications) do
                if found then
                    local cur = e.frame.Position
                    tween(e.frame,
                        TweenInfo.new(CONFIG.AnimDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                        { Position = UDim2.new(cur.X.Scale, cur.X.Offset, cur.Y.Scale, cur.Y.Offset + totalHeight) }
                    ):Play()
                end
                if e.frame == frame then found = true end
            end
            table.remove(activeNotifications, i)
            break
        end
    end
end

-- ──────────────────────────────────────────────
--  Build Notification UI
-- ──────────────────────────────────────────────
local function buildNotification(opts)
    local notifType    = TYPES[opts.Type] or TYPES.Info
    local accentColor  = opts.Color or notifType.Color
    local duration     = opts.Duration or CONFIG.DefaultDuration
    local hasButtons   = opts.Button1 ~= nil
    local hasImage     = opts.Image ~= nil
    local baseHeight   = hasButtons and 108 or (hasImage and 90 or 80)

    -- ── Outer Frame ──────────────────────────────
    local frame = Instance.new("Frame")
    frame.Name              = "Notification_" .. tostring(notifCount)
    frame.Size              = UDim2.new(0, CONFIG.Width, 0, baseHeight)
    frame.Position          = UDim2.new(0, CONFIG.Width + 20, 1, -CONFIG.PaddingBottom - baseHeight)
    frame.BackgroundColor3  = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel   = 0
    frame.ClipsDescendants  = false
    frame.ZIndex            = CONFIG.ZIndex
    frame.Parent            = Container

    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name                    = "Shadow"
    shadow.Size                    = UDim2.new(1, 24, 1, 24)
    shadow.Position                = UDim2.new(0, -12, 0, -6)
    shadow.BackgroundTransparency  = 1
    shadow.Image                   = "rbxassetid://6014261993"
    shadow.ImageColor3             = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency       = 0.55
    shadow.ScaleType               = Enum.ScaleType.Slice
    shadow.SliceCenter             = Rect.new(49, 49, 450, 450)
    shadow.ZIndex                  = CONFIG.ZIndex - 1
    shadow.Parent                  = frame

    -- Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
    corner.Parent = frame

    -- Left accent bar
    local accent = Instance.new("Frame")
    accent.Name              = "Accent"
    accent.Size              = UDim2.new(0, 3, 1, -CONFIG.ProgressBarHeight)
    accent.Position          = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3  = accentColor
    accent.BorderSizePixel   = 0
    accent.ZIndex            = CONFIG.ZIndex + 1
    accent.Parent            = frame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
    accentCorner.Parent = accent

    -- Subtle gradient overlay
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24)),
    })
    gradient.Rotation = 90
    gradient.Parent = frame

    -- ── Type Badge ───────────────────────────────
    local badge = Instance.new("Frame")
    badge.Name              = "Badge"
    badge.Size              = UDim2.new(0, 54, 0, 18)
    badge.Position          = UDim2.new(0, 12, 0, 12)
    badge.BackgroundColor3  = accentColor
    badge.BorderSizePixel   = 0
    badge.ZIndex            = CONFIG.ZIndex + 2
    badge.Parent            = frame

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = badge

    local badgeTint = Instance.new("UIGradient")
    badgeTint.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.3),
    })
    badgeTint.Rotation = 90
    badgeTint.Parent = badge

    local badgeLabel = Instance.new("TextLabel")
    badgeLabel.Size                  = UDim2.new(1, 0, 1, 0)
    badgeLabel.BackgroundTransparency = 1
    badgeLabel.Text                  = notifType.Label
    badgeLabel.Font                  = CONFIG.Font
    badgeLabel.TextSize              = 9
    badgeLabel.TextColor3            = Color3.fromRGB(255, 255, 255)
    badgeLabel.ZIndex                = CONFIG.ZIndex + 3
    badgeLabel.Parent                = badge

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                  = "CloseBtn"
    closeBtn.Size                  = UDim2.new(0, 20, 0, 20)
    closeBtn.Position              = UDim2.new(1, -28, 0, 8)
    closeBtn.BackgroundColor3      = Color3.fromRGB(35, 35, 45)
    closeBtn.BorderSizePixel       = 0
    closeBtn.Text                  = "✕"
    closeBtn.Font                  = CONFIG.Font
    closeBtn.TextSize              = 9
    closeBtn.TextColor3            = Color3.fromRGB(160, 160, 180)
    closeBtn.AutoButtonColor       = false
    closeBtn.ZIndex                = CONFIG.ZIndex + 3
    closeBtn.Parent                = frame

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(1, 0)
    closeBtnCorner.Parent = closeBtn

    -- Hover effect on close
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(239, 68, 68), TextColor3 = Color3.fromRGB(255,255,255) }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.fromRGB(160,160,180) }):Play()
    end)

    -- ── Icon or Image ────────────────────────────
    local iconSize = CONFIG.IconSize
    local iconX    = 12

    if hasImage then
        local img = Instance.new("ImageLabel")
        img.Size                   = UDim2.new(0, iconSize, 0, iconSize)
        img.Position               = UDim2.new(0, iconX, 0, 36)
        img.BackgroundTransparency = 1
        img.Image                  = opts.Image
        img.ScaleType              = Enum.ScaleType.Crop
        img.ZIndex                 = CONFIG.ZIndex + 2
        img.Parent                 = frame

        local imgCorner = Instance.new("UICorner")
        imgCorner.CornerRadius = UDim.new(0, 6)
        imgCorner.Parent = img
    end

    -- ── Title ────────────────────────────────────
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name                  = "Title"
    titleLabel.Size                  = UDim2.new(1, hasImage and -(iconSize + iconX + 18) or -50, 0, 22)
    titleLabel.Position              = UDim2.new(0, hasImage and (iconX + iconSize + 8) or 12, 0, 34)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text                  = opts.Title or "Notification"
    titleLabel.Font                  = CONFIG.Font
    titleLabel.TextSize              = 14
    titleLabel.TextColor3            = Color3.fromRGB(240, 240, 250)
    titleLabel.TextXAlignment        = Enum.TextXAlignment.Left
    titleLabel.TextTruncate          = Enum.TextTruncate.AtEnd
    titleLabel.ZIndex                = CONFIG.ZIndex + 2
    titleLabel.Parent                = frame

    -- ── Message ──────────────────────────────────
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Name                  = "Message"
    msgLabel.Size                  = UDim2.new(1, hasImage and -(iconSize + iconX + 18) or -18, 0, 30)
    msgLabel.Position              = UDim2.new(0, hasImage and (iconX + iconSize + 8) or 12, 0, 56)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text                  = opts.Message or ""
    msgLabel.Font                  = CONFIG.FontBody
    msgLabel.TextSize              = 12
    msgLabel.TextColor3            = Color3.fromRGB(170, 170, 190)
    msgLabel.TextXAlignment        = Enum.TextXAlignment.Left
    msgLabel.TextWrapped           = true
    msgLabel.ZIndex                = CONFIG.ZIndex + 2
    msgLabel.Parent                = frame

    -- ── Buttons ──────────────────────────────────
    if hasButtons then
        local btnY = baseHeight - 34

        local function makeButton(btnOpts, xPos, wide)
            if not btnOpts then return end
            local btn = Instance.new("TextButton")
            btn.Size                  = UDim2.new(0, wide and 142 or 69, 0, 24)
            btn.Position              = UDim2.new(0, xPos, 0, btnY)
            btn.BackgroundColor3      = Color3.fromRGB(30, 30, 42)
            btn.BorderSizePixel       = 0
            btn.Text                  = btnOpts.Text or "OK"
            btn.Font                  = CONFIG.Font
            btn.TextSize              = 12
            btn.TextColor3            = accentColor
            btn.AutoButtonColor       = false
            btn.ZIndex                = CONFIG.ZIndex + 3
            btn.Parent                = frame

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = btn

            local stroke = Instance.new("UIStroke")
            stroke.Color             = accentColor
            stroke.Transparency      = 0.6
            stroke.Thickness         = 1
            stroke.Parent            = btn

            btn.MouseEnter:Connect(function()
                tween(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = accentColor,
                    TextColor3       = Color3.fromRGB(255, 255, 255),
                }):Play()
                tween(stroke, TweenInfo.new(0.15), { Transparency = 0 }):Play()
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 42),
                    TextColor3       = accentColor,
                }):Play()
                tween(stroke, TweenInfo.new(0.15), { Transparency = 0.6 }):Play()
            end)

            return btn
        end

        if opts.Button1 and opts.Button2 then
            local b1 = makeButton(opts.Button1, 12,  false)
            local b2 = makeButton(opts.Button2, 89,  false)

            if b1 then b1.MouseButton1Click:Connect(function()
                if opts.Button1.Callback then opts.Button1.Callback() end
            end) end
            if b2 then b2.MouseButton1Click:Connect(function()
                if opts.Button2.Callback then opts.Button2.Callback() end
            end) end
        elseif opts.Button1 then
            local b1 = makeButton(opts.Button1, 12, true)
            if b1 then b1.MouseButton1Click:Connect(function()
                if opts.Button1.Callback then opts.Button1.Callback() end
            end) end
        end
    end

    -- ── Progress Bar ─────────────────────────────
    local progressBg = Instance.new("Frame")
    progressBg.Name              = "ProgressBg"
    progressBg.Size              = UDim2.new(1, 0, 0, CONFIG.ProgressBarHeight)
    progressBg.Position          = UDim2.new(0, 0, 1, -CONFIG.ProgressBarHeight)
    progressBg.BackgroundColor3  = Color3.fromRGB(35, 35, 45)
    progressBg.BorderSizePixel   = 0
    progressBg.ZIndex            = CONFIG.ZIndex + 2
    progressBg.Parent            = frame

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
    progressCorner.Parent = progressBg

    local progressFill = Instance.new("Frame")
    progressFill.Name              = "ProgressFill"
    progressFill.Size              = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3  = accentColor
    progressFill.BorderSizePixel   = 0
    progressFill.ZIndex            = CONFIG.ZIndex + 3
    progressFill.Parent            = progressBg

    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
    progressFillCorner.Parent = progressFill

    local progressGlow = Instance.new("UIGradient")
    progressGlow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0),
    })
    progressGlow.Rotation = 90
    progressGlow.Parent = progressFill

    return frame, baseHeight, progressFill, closeBtn
end

-- ──────────────────────────────────────────────
--  Animate In
-- ──────────────────────────────────────────────
local function animateIn(frame, targetX)
    local tweenIn = tween(frame,
        TweenInfo.new(CONFIG.AnimDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, targetX, frame.Position.Y.Scale, frame.Position.Y.Offset) }
    )
    tweenIn:Play()
    return tweenIn
end

-- ──────────────────────────────────────────────
--  Animate Out
-- ──────────────────────────────────────────────
local function animateOut(frame, callback)
    local tweenOut = tween(frame,
        TweenInfo.new(CONFIG.AnimDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        {
            Position          = UDim2.new(0, CONFIG.Width + 30, frame.Position.Y.Scale, frame.Position.Y.Offset),
            BackgroundTransparency = 1,
        }
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        frame:Destroy()
        if callback then callback() end
    end)
end

-- ──────────────────────────────────────────────
--  Public: Notify
-- ──────────────────────────────────────────────
function NotifyLib:Notify(opts)
    assert(type(opts) == "table", "[NotifyLib] opts must be a table")

    -- Enforce max
    if #activeNotifications >= CONFIG.MaxNotifications then
        local oldest = activeNotifications[1]
        if oldest then
            animateOut(oldest.frame, function() end)
            removeEntry(oldest.frame)
        end
    end

    notifCount += 1

    local frame, height, progressFill, closeBtn = buildNotification(opts)
    local duration = opts.Duration or CONFIG.DefaultDuration

    -- Stack above existing
    local stackOffset = CONFIG.PaddingBottom
    for _, entry in ipairs(activeNotifications) do
        stackOffset = stackOffset + entry.height + CONFIG.Gap
    end

    local targetY = -stackOffset - height
    frame.Position = UDim2.new(0, CONFIG.Width + 20, 1, targetY)

    table.insert(activeNotifications, { frame = frame, height = height })

    -- Animate in (slide from right)
    animateIn(frame, 0)

    -- Progress bar tween
    local progressTween = tween(progressFill,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 1, 0) }
    )
    progressTween:Play()

    -- Dismiss function
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        progressTween:Cancel()
        animateOut(frame, function()
            removeEntry(frame)
        end)
    end

    -- Close button
    closeBtn.MouseButton1Click:Connect(dismiss)

    -- Auto-dismiss
    task.delay(duration, dismiss)

    -- Hover to pause progress
    local pausedAt
    frame.MouseEnter:Connect(function()
        if dismissed then return end
        progressTween:Pause()
        pausedAt = tick()
        tween(frame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(22, 22, 30) }):Play()
    end)
    frame.MouseLeave:Connect(function()
        if dismissed then return end
        progressTween:Play()
        tween(frame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(18, 18, 24) }):Play()
    end)

    return {
        Dismiss = dismiss,
        Frame   = frame,
    }
end

-- ──────────────────────────────────────────────
--  Public: ClearAll
-- ──────────────────────────────────────────────
function NotifyLib:ClearAll()
    for _, entry in ipairs(activeNotifications) do
        animateOut(entry.frame, function() end)
    end
    table.clear(activeNotifications)
end

-- ──────────────────────────────────────────────
--  Public: UpdateConfig
-- ──────────────────────────────────────────────
function NotifyLib:UpdateConfig(newCfg)
    for k, v in pairs(newCfg) do
        CONFIG[k] = v
    end
end

return NotifyLib
