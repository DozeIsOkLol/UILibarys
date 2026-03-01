--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                    NEXUS LOADER v0.0.1                    ║
    ║          Professional Script Management System            ║
    ║                 Created by: SouljaWitchSrc                ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local NexusLoader = {}

-- ═══════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════

local Config = {
    -- Core Settings
    LoaderVersion = "0.0.1",
    LoaderName = "Nexus Loader",
    
    -- Remote URLs (Replace with your own)
    RemoteConfig = {
        StatusURL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/Loaders/NexusLoader/status.json",
        ThemeURL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/Loaders/NexusLoader/themes.json",
        WhitelistURL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/Loaders/NexusLoader/whitelist.txt",
        ChangelogURL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/Loaders/NexusLoader/changelog.json",
        ScriptsURL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/Loaders/NexusLoader/scripts.json",
        AnalyticsURL = "https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/Loaders/NexusLoader/analytics.json"
    },
    
    -- UI Settings
    UI = {
        AnimationSpeed = 0.5,
        FadeSpeed = 0.3,
        NotificationDuration = 5,
        LogLimit = 100,
        EnableSounds = true,
        EnableParticles = true
    },
    
    -- Security Settings
    Security = {
        RequireWhitelist = false,
        RequireKeySystem = false,
        KeyURL = "https://raw.githubusercontent.com/YourRepo/nexus-loader/main/keys/",
        AntiTamper = true,
        RateLimitRequests = true,
        MaxRequestsPerMinute = 30
    },
    
    -- Feature Flags
    Features = {
        AutoUpdate = true,
        Analytics = false,
        DeveloperMode = false,
        SaveSettings = true,
        MultiLanguage = false
    },
    
    -- Default Theme (Cyberpunk Blue)
    DefaultTheme = {
        Name = "Cyberpunk Blue",
        Primary = Color3.fromRGB(0, 200, 255),
        Secondary = Color3.fromRGB(138, 43, 226),
        Background = Color3.fromRGB(15, 15, 25),
        Surface = Color3.fromRGB(25, 25, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(0, 255, 136),
        Warning = Color3.fromRGB(255, 170, 0),
        Error = Color3.fromRGB(255, 50, 80),
        Accent = Color3.fromRGB(255, 0, 170)
    }
}

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════

local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local Utils = {}

function Utils.Request(url, method)
    method = method or "GET"
    local success, result = pcall(function()
        return Services.HttpService:RequestAsync({
            Url = url,
            Method = method
        })
    end)
    
    if success and result.Success then
        return true, result.Body
    else
        return false, result
    end
end

function Utils.DecodeJSON(str)
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(str)
    end)
    return success and result or nil
end

function Utils.GetGameInfo()
    local gameId = game.GameId
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    
    return {
        GameId = gameId,
        PlaceId = placeId,
        GameName = gameName
    }
end

function Utils.GetPlayerInfo()
    return {
        Name = Player.Name,
        DisplayName = Player.DisplayName,
        UserId = Player.UserId,
        AccountAge = Player.AccountAge,
        MembershipType = tostring(Player.MembershipType)
    }
end

function Utils.CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

function Utils.CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

function Utils.CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

function Utils.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = Services.TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Config.UI.AnimationSpeed,
            easingStyle or Enum.EasingStyle.Quad,
            easingDirection or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

function Utils.FormatTime(seconds)
    if seconds < 60 then
        return string.format("%.1fs", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    else
        return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    end
end

function Utils.CopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
-- LOGGER SYSTEM
-- ═══════════════════════════════════════════════════════════

local Logger = {
    Logs = {},
    MaxLogs = Config.UI.LogLimit
}

function Logger:Add(message, logType)
    logType = logType or "INFO"
    local timestamp = os.date("%H:%M:%S")
    
    local log = {
        Time = timestamp,
        Type = logType,
        Message = message,
        Timestamp = tick()
    }
    
    table.insert(self.Logs, 1, log)
    
    if #self.Logs > self.MaxLogs then
        table.remove(self.Logs, #self.Logs)
    end
    
    if Config.Features.DeveloperMode then
        local prefix = string.format("[%s][%s]", timestamp, logType)
        print(prefix, message)
    end
    
    return log
end

function Logger:Info(message)
    return self:Add(message, "INFO")
end

function Logger:Success(message)
    return self:Add(message, "SUCCESS")
end

function Logger:Warning(message)
    return self:Add(message, "WARNING")
end

function Logger:Error(message)
    return self:Add(message, "ERROR")
end

function Logger:GetLogs()
    return self.Logs
end

-- ═══════════════════════════════════════════════════════════
-- THEME MANAGER
-- ═══════════════════════════════════════════════════════════

local ThemeManager = {
    CurrentTheme = Config.DefaultTheme,
    AvailableThemes = {}
}

function ThemeManager:LoadThemes()
    Logger:Info("Loading themes from remote...")
    local success, data = Utils.Request(Config.RemoteConfig.ThemeURL)
    
    if success then
        local themes = Utils.DecodeJSON(data)
        if themes then
            self.AvailableThemes = themes
            Logger:Success("Loaded " .. #themes .. " themes")
            return true
        end
    end
    
    Logger:Warning("Failed to load themes, using default")
    self.AvailableThemes = {Config.DefaultTheme}
    return false
end

function ThemeManager:SetTheme(themeName)
    for _, theme in ipairs(self.AvailableThemes) do
        if theme.Name == themeName then
            self.CurrentTheme = theme
            Logger:Success("Theme changed to: " .. themeName)
            return true
        end
    end
    Logger:Error("Theme not found: " .. themeName)
    return false
end

function ThemeManager:GetTheme()
    return self.CurrentTheme
end

-- ═══════════════════════════════════════════════════════════
-- STATUS MANAGER
-- ═══════════════════════════════════════════════════════════

local StatusManager = {
    Status = {
        Enabled = true,
        Maintenance = false,
        Message = "All systems operational"
    }
}

function StatusManager:CheckStatus()
    Logger:Info("Checking loader status...")
    local success, data = Utils.Request(Config.RemoteConfig.StatusURL)
    
    if success then
        local status = Utils.DecodeJSON(data)
        if status then
            self.Status = status
            Logger:Success("Status check complete")
            return true, status
        end
    end
    
    Logger:Warning("Failed to check status, assuming operational")
    return false, self.Status
end

function StatusManager:IsEnabled()
    return self.Status.Enabled and not self.Status.Maintenance
end

-- ═══════════════════════════════════════════════════════════
-- WHITELIST MANAGER
-- ═══════════════════════════════════════════════════════════

local WhitelistManager = {
    Whitelist = {}
}

function WhitelistManager:Load()
    if not Config.Security.RequireWhitelist then
        return true
    end
    
    Logger:Info("Loading whitelist...")
    local success, data = Utils.Request(Config.RemoteConfig.WhitelistURL)
    
    if success then
        for userId in string.gmatch(data, "%d+") do
            table.insert(self.Whitelist, tonumber(userId))
        end
        Logger:Success("Loaded " .. #self.Whitelist .. " whitelisted users")
        return true
    end
    
    Logger:Error("Failed to load whitelist")
    return false
end

function WhitelistManager:IsWhitelisted(userId)
    if not Config.Security.RequireWhitelist then
        return true
    end
    
    for _, id in ipairs(self.Whitelist) do
        if id == userId then
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
-- SCRIPT MANAGER
-- ═══════════════════════════════════════════════════════════

local ScriptManager = {
    Scripts = {},
    CurrentScript = nil
}

function ScriptManager:LoadScripts()
    Logger:Info("Loading script database...")
    local success, data = Utils.Request(Config.RemoteConfig.ScriptsURL)
    
    if success then
        local scripts = Utils.DecodeJSON(data)
        if scripts then
            self.Scripts = scripts
            Logger:Success("Loaded " .. #scripts .. " scripts")
            return true
        end
    end
    
    Logger:Error("Failed to load scripts")
    return false
end

function ScriptManager:FindScript(gameId)
    -- First try to find game-specific script
    for _, script in ipairs(self.Scripts) do
        if script.GameId == gameId or script.PlaceId == game.PlaceId then
            return script
        end
    end
    
    -- Fall back to universal script
    for _, script in ipairs(self.Scripts) do
        if script.Universal then
            return script
        end
    end
    
    return nil
end

function ScriptManager:ExecuteScript(script)
    Logger:Info("Executing script: " .. script.Name)
    
    local success, scriptData = Utils.Request(script.URL)
    if not success then
        Logger:Error("Failed to download script")
        return false, "Download failed"
    end
    
    local executeSuccess, executeError = pcall(function()
        loadstring(scriptData)()
    end)
    
    if executeSuccess then
        Logger:Success("Script executed successfully")
        return true
    else
        Logger:Error("Script execution failed: " .. tostring(executeError))
        return false, tostring(executeError)
    end
end

-- ═══════════════════════════════════════════════════════════
-- CHANGELOG MANAGER
-- ═══════════════════════════════════════════════════════════

local ChangelogManager = {
    Changelog = {}
}

function ChangelogManager:Load()
    Logger:Info("Loading changelog...")
    local success, data = Utils.Request(Config.RemoteConfig.ChangelogURL)
    
    if success then
        local changelog = Utils.DecodeJSON(data)
        if changelog then
            self.Changelog = changelog
            Logger:Success("Changelog loaded")
            return true
        end
    end
    
    Logger:Warning("Failed to load changelog")
    return false
end

function ChangelogManager:GetLatest()
    return self.Changelog[1] or {Version = "Unknown", Changes = {}}
end

-- ═══════════════════════════════════════════════════════════
-- UI MANAGER
-- ═══════════════════════════════════════════════════════════

local UI = {}

function UI:CreateMainUI()
    local theme = ThemeManager:GetTheme()
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusLoader"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protection
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = Services.CoreGui
    else
        ScreenGui.Parent = Services.CoreGui
    end
    
    -- Background Blur
    local Blur = Instance.new("Frame")
    Blur.Name = "Blur"
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.Position = UDim2.new(0, 0, 0, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.3
    Blur.Parent = ScreenGui
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    Utils.CreateCorner(MainFrame, 12)
    Utils.CreateStroke(MainFrame, theme.Primary, 2)
    
    -- Animated gradient background
    local GradientBG = Instance.new("Frame")
    GradientBG.Name = "GradientBG"
    GradientBG.Size = UDim2.new(1, 0, 1, 0)
    GradientBG.BackgroundColor3 = theme.Surface
    GradientBG.BackgroundTransparency = 0.7
    GradientBG.BorderSizePixel = 0
    GradientBG.Parent = MainFrame
    
    Utils.CreateGradient(GradientBG, theme.Primary, theme.Secondary, 45)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundColor3 = theme.Surface
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    Utils.CreateGradient(Header, theme.Primary, theme.Secondary, 90)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = Config.LoaderName
    Title.TextColor3 = theme.Text
    Title.TextSize = 24
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Version
    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Size = UDim2.new(0, 100, 1, 0)
    Version.Position = UDim2.new(1, -110, 0, 0)
    Version.BackgroundTransparency = 1
    Version.Font = Enum.Font.Gotham
    Version.Text = "v" .. Config.LoaderVersion
    Version.TextColor3 = theme.TextSecondary
    Version.TextSize = 14
    Version.TextXAlignment = Enum.TextXAlignment.Right
    Version.Parent = Header
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -50, 0, 10)
    CloseButton.BackgroundColor3 = theme.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = theme.Text
    CloseButton.TextSize = 24
    CloseButton.Parent = Header
    
    Utils.CreateCorner(CloseButton, 8)
    
    CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Content Container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -40, 1, -100)
    Content.Position = UDim2.new(0, 20, 0, 70)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    -- Status Text
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, 0, 0, 30)
    StatusText.Position = UDim2.new(0, 0, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.Gotham
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = theme.Text
    StatusText.TextSize = 16
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = Content
    
    -- Progress Bar Container
    local ProgressContainer = Instance.new("Frame")
    ProgressContainer.Name = "ProgressContainer"
    ProgressContainer.Size = UDim2.new(1, 0, 0, 8)
    ProgressContainer.Position = UDim2.new(0, 0, 0, 40)
    ProgressContainer.BackgroundColor3 = theme.Surface
    ProgressContainer.BorderSizePixel = 0
    ProgressContainer.Parent = Content
    
    Utils.CreateCorner(ProgressContainer, 4)
    
    -- Progress Bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = theme.Primary
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressContainer
    
    Utils.CreateCorner(ProgressBar, 4)
    Utils.CreateGradient(ProgressBar, theme.Primary, theme.Secondary, 90)
    
    -- Info Container
    local InfoContainer = Instance.new("Frame")
    InfoContainer.Name = "InfoContainer"
    InfoContainer.Size = UDim2.new(1, 0, 0, 100)
    InfoContainer.Position = UDim2.new(0, 0, 0, 60)
    InfoContainer.BackgroundColor3 = theme.Surface
    InfoContainer.BackgroundTransparency = 0.5
    InfoContainer.BorderSizePixel = 0
    InfoContainer.Parent = Content
    
    Utils.CreateCorner(InfoContainer, 8)
    
    -- Info Text
    local InfoText = Instance.new("TextLabel")
    InfoText.Name = "InfoText"
    InfoText.Size = UDim2.new(1, -20, 1, -20)
    InfoText.Position = UDim2.new(0, 10, 0, 10)
    InfoText.BackgroundTransparency = 1
    InfoText.Font = Enum.Font.Gotham
    InfoText.Text = "Loading information..."
    InfoText.TextColor3 = theme.TextSecondary
    InfoText.TextSize = 14
    InfoText.TextWrapped = true
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.Parent = InfoContainer
    
    -- Button Container
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Size = UDim2.new(1, 0, 0, 50)
    ButtonContainer.Position = UDim2.new(0, 0, 1, -60)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = Content
    
    -- Execute Button
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Name = "ExecuteButton"
    ExecuteButton.Size = UDim2.new(0.48, 0, 1, 0)
    ExecuteButton.Position = UDim2.new(0, 0, 0, 0)
    ExecuteButton.BackgroundColor3 = theme.Success
    ExecuteButton.BorderSizePixel = 0
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Text = "EXECUTE SCRIPT"
    ExecuteButton.TextColor3 = theme.Text
    ExecuteButton.TextSize = 16
    ExecuteButton.Parent = ButtonContainer
    
    Utils.CreateCorner(ExecuteButton, 8)
    
    -- Settings Button
    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Size = UDim2.new(0.48, 0, 1, 0)
    SettingsButton.Position = UDim2.new(0.52, 0, 0, 0)
    SettingsButton.BackgroundColor3 = theme.Secondary
    SettingsButton.BorderSizePixel = 0
    SettingsButton.Font = Enum.Font.GothamBold
    SettingsButton.Text = "SETTINGS"
    SettingsButton.TextColor3 = theme.Text
    SettingsButton.TextSize = 16
    SettingsButton.Parent = ButtonContainer
    
    Utils.CreateCorner(SettingsButton, 8)
    
    -- Store references
    self.UI = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        StatusText = StatusText,
        ProgressBar = ProgressBar,
        InfoText = InfoText,
        ExecuteButton = ExecuteButton,
        SettingsButton = SettingsButton
    }
    
    -- Animate in
    MainFrame.Position = UDim2.new(0.5, -300, 1.5, 0)
    Utils.Tween(MainFrame, {Position = UDim2.new(0.5, -300, 0.5, -200)}, 0.8, Enum.EasingStyle.Back)
    
    return self.UI
end

function UI:UpdateStatus(text, progress)
    if self.UI then
        self.UI.StatusText.Text = text
        if progress then
            Utils.Tween(self.UI.ProgressBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
        end
    end
end

function UI:UpdateInfo(text)
    if self.UI then
        self.UI.InfoText.Text = text
    end
end

function UI:ShowNotification(title, message, notifType)
    local theme = ThemeManager:GetTheme()
    local color = theme.Primary
    
    if notifType == "success" then
        color = theme.Success
    elseif notifType == "error" then
        color = theme.Error
    elseif notifType == "warning" then
        color = theme.Warning
    end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 350, 0, 80)
    Notification.Position = UDim2.new(1, 10, 0, 10)
    Notification.BackgroundColor3 = theme.Surface
    Notification.BorderSizePixel = 0
    Notification.Parent = self.UI.ScreenGui
    
    Utils.CreateCorner(Notification, 8)
    Utils.CreateStroke(Notification, color, 2)
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 25)
    NotifTitle.Position = UDim2.new(0, 10, 0, 5)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.Text = title
    NotifTitle.TextColor3 = color
    NotifTitle.TextSize = 16
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = Notification
    
    local NotifMessage = Instance.new("TextLabel")
    NotifMessage.Size = UDim2.new(1, -20, 0, 45)
    NotifMessage.Position = UDim2.new(0, 10, 0, 30)
    NotifMessage.BackgroundTransparency = 1
    NotifMessage.Font = Enum.Font.Gotham
    NotifMessage.Text = message
    NotifMessage.TextColor3 = theme.Text
    NotifMessage.TextSize = 14
    NotifMessage.TextWrapped = true
    NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
    NotifMessage.TextYAlignment = Enum.TextYAlignment.Top
    NotifMessage.Parent = Notification
    
    -- Animate in
    Utils.Tween(Notification, {Position = UDim2.new(1, -360, 0, 10)}, 0.5, Enum.EasingStyle.Back)
    
    -- Auto dismiss
    task.delay(Config.UI.NotificationDuration, function()
        Utils.Tween(Notification, {Position = UDim2.new(1, 10, 0, 10)}, 0.5, Enum.EasingStyle.Back)
        task.wait(0.5)
        Notification:Destroy()
    end)
end

function UI:ShowError(errorMessage)
    local theme = ThemeManager:GetTheme()
    
    local ErrorFrame = Instance.new("Frame")
    ErrorFrame.Name = "ErrorFrame"
    ErrorFrame.Size = UDim2.new(0, 500, 0, 250)
    ErrorFrame.Position = UDim2.new(0.5, -250, 0.5, -125)
    ErrorFrame.BackgroundColor3 = theme.Surface
    ErrorFrame.BorderSizePixel = 0
    ErrorFrame.Parent = self.UI.ScreenGui
    
    Utils.CreateCorner(ErrorFrame, 12)
    Utils.CreateStroke(ErrorFrame, theme.Error, 2)
    
    local ErrorTitle = Instance.new("TextLabel")
    ErrorTitle.Size = UDim2.new(1, -40, 0, 40)
    ErrorTitle.Position = UDim2.new(0, 20, 0, 20)
    ErrorTitle.BackgroundTransparency = 1
    ErrorTitle.Font = Enum.Font.GothamBold
    ErrorTitle.Text = "⚠ ERROR"
    ErrorTitle.TextColor3 = theme.Error
    ErrorTitle.TextSize = 24
    ErrorTitle.TextXAlignment = Enum.TextXAlignment.Left
    ErrorTitle.Parent = ErrorFrame
    
    local ErrorText = Instance.new("TextLabel")
    ErrorText.Size = UDim2.new(1, -40, 0, 100)
    ErrorText.Position = UDim2.new(0, 20, 0, 70)
    ErrorText.BackgroundTransparency = 1
    ErrorText.Font = Enum.Font.Gotham
    ErrorText.Text = errorMessage
    ErrorText.TextColor3 = theme.Text
    ErrorText.TextSize = 14
    ErrorText.TextWrapped = true
    ErrorText.TextXAlignment = Enum.TextXAlignment.Left
    ErrorText.TextYAlignment = Enum.TextYAlignment.Top
    ErrorText.Parent = ErrorFrame
    
    local CopyButton = Instance.new("TextButton")
    CopyButton.Size = UDim2.new(0, 150, 0, 40)
    CopyButton.Position = UDim2.new(0.5, -155, 1, -60)
    CopyButton.BackgroundColor3 = theme.Primary
    CopyButton.BorderSizePixel = 0
    CopyButton.Font = Enum.Font.GothamBold
    CopyButton.Text = "COPY ERROR"
    CopyButton.TextColor3 = theme.Text
    CopyButton.TextSize = 14
    CopyButton.Parent = ErrorFrame
    
    Utils.CreateCorner(CopyButton, 8)
    
    CopyButton.MouseButton1Click:Connect(function()
        if Utils.CopyToClipboard(errorMessage) then
            CopyButton.Text = "COPIED!"
            task.wait(2)
            CopyButton.Text = "COPY ERROR"
        end
    end)
    
    local CloseErrorButton = Instance.new("TextButton")
    CloseErrorButton.Size = UDim2.new(0, 150, 0, 40)
    CloseErrorButton.Position = UDim2.new(0.5, 5, 1, -60)
    CloseErrorButton.BackgroundColor3 = theme.Error
    CloseErrorButton.BorderSizePixel = 0
    CloseErrorButton.Font = Enum.Font.GothamBold
    CloseErrorButton.Text = "CLOSE"
    CloseErrorButton.TextColor3 = theme.Text
    CloseErrorButton.TextSize = 14
    CloseErrorButton.Parent = ErrorFrame
    
    Utils.CreateCorner(CloseErrorButton, 8)
    
    CloseErrorButton.MouseButton1Click:Connect(function()
        ErrorFrame:Destroy()
    end)
end

function UI:Destroy()
    if self.UI and self.UI.ScreenGui then
        Utils.Tween(self.UI.MainFrame, {Position = UDim2.new(0.5, -300, 1.5, 0)}, 0.5, Enum.EasingStyle.Back)
        task.wait(0.6)
        self.UI.ScreenGui:Destroy()
    end
end

-- ═══════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════

function NexusLoader:Initialize()
    Logger:Info("Starting Nexus Loader...")
    
    -- Create UI
    UI:CreateMainUI()
    UI:UpdateStatus("Initializing loader...", 0.1)
    
    task.wait(0.5)
    
    -- Check status
    UI:UpdateStatus("Checking loader status...", 0.2)
    local statusOk, status = StatusManager:CheckStatus()
    
    if not StatusManager:IsEnabled() then
        UI:ShowError("Loader is currently disabled or under maintenance.\n\nMessage: " .. (status.Message or "Unknown"))
        Logger:Error("Loader is disabled")
        return
    end
    
    task.wait(0.5)
    
    -- Load themes
    UI:UpdateStatus("Loading themes...", 0.3)
    ThemeManager:LoadThemes()
    task.wait(0.3)
    
    -- Check whitelist
    if Config.Security.RequireWhitelist then
        UI:UpdateStatus("Verifying whitelist...", 0.4)
        WhitelistManager:Load()
        
        if not WhitelistManager:IsWhitelisted(Player.UserId) then
            UI:ShowError("You are not whitelisted to use this loader.\n\nUser ID: " .. Player.UserId)
            Logger:Error("User not whitelisted: " .. Player.UserId)
            return
        end
    end
    
    task.wait(0.5)
    
    -- Load scripts
    UI:UpdateStatus("Loading script database...", 0.6)
    if not ScriptManager:LoadScripts() then
        UI:ShowError("Failed to load script database. Please try again later.")
        return
    end
    
    task.wait(0.5)
    
    -- Load changelog
    UI:UpdateStatus("Loading changelog...", 0.7)
    ChangelogManager:Load()
    task.wait(0.3)
    
    -- Get game info
    UI:UpdateStatus("Detecting game...", 0.8)
    local gameInfo = Utils.GetGameInfo()
    Logger:Info("Game detected: " .. gameInfo.GameName)
    
    task.wait(0.5)
    
    -- Find script
    UI:UpdateStatus("Finding script...", 0.9)
    local script = ScriptManager:FindScript(gameInfo.GameId)
    
    if not script then
        UI:ShowError("No script found for this game.\n\nGame: " .. gameInfo.GameName .. "\nGame ID: " .. gameInfo.GameId)
        Logger:Warning("No script found for game: " .. gameInfo.GameId)
        return
    end
    
    ScriptManager.CurrentScript = script
    Logger:Success("Found script: " .. script.Name)
    
    -- Update UI
    UI:UpdateStatus("Ready to execute!", 1.0)
    UI:UpdateInfo(
        "Game: " .. gameInfo.GameName .. "\n" ..
        "Script: " .. script.Name .. "\n" ..
        "Version: " .. (script.Version or "Unknown") .. "\n" ..
        "Description: " .. (script.Description or "No description")
    )
    
    UI:ShowNotification("Ready!", "Script loaded successfully. Click Execute to run.", "success")
    
    -- Setup execute button
    UI.UI.ExecuteButton.MouseButton1Click:Connect(function()
        self:ExecuteScript()
    end)
    
    -- Setup settings button
    UI.UI.SettingsButton.MouseButton1Click:Connect(function()
        self:OpenSettings()
    end)
    
    Logger:Success("Loader initialized successfully")
end

function NexusLoader:ExecuteScript()
    if not ScriptManager.CurrentScript then
        UI:ShowNotification("Error", "No script loaded", "error")
        return
    end
    
    UI:UpdateStatus("Executing script...", 0.5)
    UI.UI.ExecuteButton.Text = "EXECUTING..."
    UI.UI.ExecuteButton.BackgroundColor3 = ThemeManager:GetTheme().Warning
    
    local success, error = ScriptManager:ExecuteScript(ScriptManager.CurrentScript)
    
    if success then
        UI:ShowNotification("Success!", "Script executed successfully", "success")
        UI:UpdateStatus("Script executed successfully!", 1.0)
        
        -- Close after delay
        task.wait(2)
        UI:Destroy()
    else
        UI:ShowError("Script execution failed:\n\n" .. (error or "Unknown error"))
        UI.UI.ExecuteButton.Text = "EXECUTE SCRIPT"
        UI.UI.ExecuteButton.BackgroundColor3 = ThemeManager:GetTheme().Success
    end
end

function NexusLoader:OpenSettings()
    UI:ShowNotification("Coming Soon", "Settings panel is under development", "warning")
end

-- ═══════════════════════════════════════════════════════════
-- START THE LOADER
-- ═══════════════════════════════════════════════════════════

task.spawn(function()
    local success, error = pcall(function()
        NexusLoader:Initialize()
    end)
    
    if not success then
        warn("Nexus Loader Error:", error)
        if UI.UI then
            UI:ShowError("Critical Error:\n\n" .. tostring(error))
        end
    end
end)

return NexusLoader
