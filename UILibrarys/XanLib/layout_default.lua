local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

if UI.IsMobile then
    UI.Loading({ Title = "Xan UI Showcase", Subtitle = "Loading...", Duration = 2 })
    task.wait(2.2)
else
    UI.Splash({ Title = "Xan UI Showcase", Subtitle = "Loading...", Duration = 2.5 })
    task.wait(2.7)
end

local Window = UI.New({
    Title = "Xan",
    Subtitle = "UI Showcase",
    Theme = "Default",
    WindowButtonStyle = "Default",
    Size = UDim2.new(0, 620, 0, 480),
    ShowUserInfo = true,
    UserName = "User",
    ConfigName = "xanbar_config",
    Logo = UI.Logos.XanBar,
    ShowLogo = true,
    ShowSettings = true,
    ShowActiveList = true,
    ProfilePage = {
        ProductName = "xan.bar Lite",
        DefaultGame = "Frontlines",
        Price = "10 euro per month",
        BannerImage = "rbxassetid://134273401437114",
        Products = {{ Name = "xan.bar Lite" }, { Name = "xan.bar Pro" }},
        Games = {
            Frontlines = { BannerImage = "rbxassetid://120690417782505", Expiry = "lifetime", Status = "up to date", Features = {"Aimbot", "ESP", "Triggerbot", "Silent Aim", "No Recoil"}, GameId = 5765028413 },
            Deadline = { BannerImage = "rbxassetid://79191012612844", Expiry = "Dec 25, 2025", Status = "active", Features = {"Aimbot", "Wallhack", "Speed Boost", "Infinite Ammo"}, GameId = 16972943626 },
            Riotfall = { Expiry = "expired", Status = "expired", Features = {"ESP", "Aimbot", "Auto Parry"}, GameId = 17625359962 },
            PhantomForces = { Expiry = "Jan 15, 2026", Status = "active", Features = {"Silent Aim", "ESP", "No Spread", "Rapid Fire"}, GameId = 292439477 },
            Arsenal = { Expiry = "Feb 1, 2026", Status = "active", Features = {"Aimbot", "ESP", "Kill All", "Infinite Coins"}, GameId = 286090429 },
            ["My Custom Game"] = { Icon = "rbxassetid://7733960981", BannerImage = "rbxassetid://134273401437114", Expiry = "lifetime", Status = "active", Features = {"Feature 1", "Feature 2"}, GameId = 123456789 }
        },
        OnLoad = function(game) print("Loading:", game) end
    }
})

local Combat = Window:AddTab("Combat", UI.Icons.Aimbot)

Combat:AddSection("Aimbot")
local AimbotToggle = Combat:AddToggle("Enable Aimbot", { Flag = "AimbotEnabled", ShowInActiveList = true }, function(v) print("Aimbot:", v) end)
Combat:AddDropdown("Target Part", {"Head", "Neck", "Chest", "Closest"}, function(v) print("Target:", v) end)
Combat:AddSlider("FOV Size", { Min = 50, Max = 400, Default = 180, Increment = 10, Suffix = "px", Flag = "FOVSize" }, function(v) print("FOV:", v) end)
Combat:AddGraph("Smoothing Curve", { Min = 0.01, Max = 0.5, Default = 0.15, Flag = "AimSmooth" }, function(v) print("Smooth:", v) end)
Combat:AddBezierCurve("Acceleration Curve", { P1 = { x = 0.2, y = 0.0 }, P2 = { x = 0.8, y = 1.0 }, Flag = "AccelCurve" })

Combat:AddSection("Target Selection")
Combat:AddHitList({ Name = "Target Parts", Parts = {"Head", "Neck", "Chest", "Stomach", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Default = { Head = true, Chest = true }, Flag = "AimParts" })
Combat:AddCharacterPreview({ Name = "Visual Preview", HitboxParts = {"Head", "Neck", "Chest", "Stomach", "Arms", "Legs"}, HitboxColors = { Head = UI.RGB(255, 80, 100), Neck = UI.RGB(255, 140, 100), Chest = UI.RGB(100, 255, 120), Stomach = UI.RGB(100, 200, 255), Arms = UI.RGB(180, 100, 255), Legs = UI.RGB(255, 200, 100) }, Default = { Head = true, Chest = true }, Flag = "AimHitboxes" })
Combat:AddBodyPicker({ Name = "Body Picker", Parts = {"Head", "Chest", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}, Colors = { Head = UI.RGB(255, 80, 100), Chest = UI.RGB(100, 255, 120), LeftArm = UI.RGB(65, 165, 255), RightArm = UI.RGB(65, 165, 255), LeftLeg = UI.RGB(255, 190, 60), RightLeg = UI.RGB(255, 190, 60) }, Default = { Head = true }, Flag = "BodyParts" })

Combat:AddSection("Triggerbot")
Combat:AddToggle("Enable Triggerbot", { Flag = "TriggerEnabled", ShowInActiveList = true })
Combat:AddHitSelector({ Name = "Hit Areas", Segments = {"Head", "Chest", "Arms", "Legs"}, Colors = { UI.Colors.Pink, UI.Colors.Green, UI.Colors.Blue, UI.Colors.Yellow }, Default = { Head = true, Chest = true }, Flag = "TriggerHitAreas" })
Combat:AddSlider("Trigger Delay", { Min = 0, Max = 200, Default = 50, Increment = 5, Suffix = "ms", Flag = "TriggerDelay" })

local Visuals = Window:AddTab("Visuals", UI.Icons.ESP)

Visuals:AddSection("ESP Settings")
Visuals:AddToggle("Enable ESP", { Default = true, Flag = "ESPEnabled", ShowInActiveList = true })

local ESPStylePicker
local ESPColorPicker = Visuals:AddColorPicker("ESP Color", { 
    Default = UI.RGB(255, 75, 85), 
    Flag = "ESPColor",
    Callback = function(color)
        if ESPStylePicker and ESPStylePicker.SetESPColor then
            ESPStylePicker:SetESPColor(color)
        end
    end
})

ESPStylePicker = Visuals:AddESPStylePicker({ 
    Name = "Box Style", 
    Styles = {"Full", "Cornered"}, 
    Default = "Full", 
    DefaultColor = UI.RGB(255, 75, 85),
    ESPColorFlag = "ESPColor",
    Flag = "ESPBoxStyle",
    ShowRainbow = true,
    CharacterIcon = UI.Icons.ESPMan2,
    Callback = function(style) print("ESP Style:", style) end
})

Visuals:AddSlider("ESP Range", { Min = 100, Max = 2000, Default = 500, Increment = 50, Suffix = "m", Flag = "ESPRange" })

Visuals:AddSection("Crosshair Engine")
Visuals:AddParagraph("Crosshair Styles", "Supports: None, Dot, Small Cross, Cross, Open Cross, Circle, and Icon (custom image)")
Visuals:AddCrosshair({
    Name = "Crosshair Settings",
    Styles = {"None", "Dot", "Small Cross", "Cross", "Open Cross", "Circle", "Icon"},
    DefaultStyle = "None",
    DefaultColor = UI.Colors.Red,
    DefaultSize = 12,
    DefaultThickness = 2,
    Enabled = false,
    Flag = "Crosshair"
})

Visuals:AddSection("Display")
Visuals:AddToggle("Show Names", { Default = true, Flag = "ShowNames" })
Visuals:AddToggle("Show Distance", { Default = true, Flag = "ShowDistance" })
Visuals:AddToggle("Show Tracers", { Default = false, Flag = "ShowTracers" })
Visuals:AddToggle("Team Check", { Default = true, Flag = "TeamCheck" })

local Misc = Window:AddTab("Misc", UI.Icons.Misc)

Misc:AddSection("Movement")
local SpeedMeter = Misc:AddSpeedometer({ Name = "Current Speed", Min = 0, Max = 100, Flag = "SpeedDisplay" })
Misc:AddSlider("Walk Speed", { Min = 16, Max = 100, Default = 16, Flag = "WalkSpeed" }, function(v)
    SpeedMeter:Set(v)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
end)
Misc:AddSlider("Jump Power", { Min = 50, Max = 200, Default = 50, Increment = 5, Flag = "JumpPower" })

Misc:AddSection("Utilities")
Misc:AddToggle("Noclip", { Flag = "Noclip", ShowInActiveList = true })
Misc:AddToggle("Infinite Jump", { Flag = "InfiniteJump", ShowInActiveList = true })

Misc:AddSection("Notification Styles")
Misc:AddButton("Default Notification", function() UI.Notify({ Title = "Default", Content = "Clean minimal", Style = "Default", Icon = 129616069466345 }) end)
Misc:AddButton("Flat Notification", function() UI.Flat("Flat", "Sharp edges") end)
Misc:AddButton("Toast Notification", function() UI.Toast("Toast", "Bottom center pill") end)
Misc:AddButton("Minimal Notification", function() UI.Minimal("Super subtle") end)
Misc:AddButton("Banner Notification", function() UI.Banner("Banner Alert", "Important message") end)
Misc:AddButton("Pill Notification", function() UI.Pill("Pill") end)
Misc:AddButton("Slide Notification", function() UI.Slide("Slide In", "Slides from right") end)
Misc:AddButton("Capsule Notification", function() UI.Capsule("Big Capsule", "Larger notification", 4, 129616069466345) end)
Misc:AddButton("Corner Notification", function() UI.Corner("xan.bar", "Bottom right popup with logo!", 5, 129616069466345) end)

Misc:AddSection("Loading Animations")
Misc:AddButton("Splash Screen", function() UI.Splash({ Title = "xan.bar", Subtitle = "Loading...", Duration = 3 }) end)
Misc:AddButton("Bottom Notification", function() UI.Loading({ Title = "Processing", Subtitle = "Please wait...", Duration = 2, Fullscreen = false }) end)
Misc:AddButton("Fullscreen Loading", function() UI.Loading({ Title = "Loading", Subtitle = "Initializing...", Duration = 2, Fullscreen = true }) end)
Misc:AddButton("Sideloader", function()
    UI.Sideloader({
        Steps = { "Initializing...", "Loading modules...", "Connecting...", "Fetching data...", "Validating...", "Preparing UI...", "Loading assets...", "Finalizing...", "Ready!" },
        StepDelay = 0.35,
        OnComplete = function() UI.Success("Loaded!", "Sideloader complete") end
    })
end)
Misc:AddButton("Show Login Screen", function()
    local login = UI.Login({
        Title = "Welcome to xan.bar!",
        Subtitle = "Sign in to continue",
        ShowSignup = true,
        ShowForgotPassword = true,
        OnLogin = function(user, pass)
            if user ~= "" and pass ~= "" then
                UI.Success("Success!", "Logged in as " .. user)
                return true
            else
                login:SetError("Fill in all fields")
                UI.Error("Error", "Fill in all fields")
                return false
            end
        end
    })
end)

local Watermark = UI.Watermark({ Text = "FPS Monitor", Position = UDim2.new(0, 10, 0, 10), ShowFPS = true, ShowPing = true, Visible = false })
local FOVCircle = UI.FOV({ Radius = 180, Color = UI.Accent(), Thickness = 1, Visible = false, FollowMouse = true })

Visuals:AddSection("Overlays")
Visuals:AddToggle("Show FPS & Ping", function(v) if v then Watermark:Show() else Watermark:Hide() end end)
Visuals:AddToggle("Show FOV Circle", function(v) FOVCircle:SetVisible(v) end)

local Buttons = Window:AddTab("Buttons", UI.Icons.Buttons)

Buttons:AddSection("Standard Buttons")
Buttons:AddButton("Default Button", function() UI.Info("Clicked!", "Default button") end)
Buttons:AddPlainButton({ Name = "Flat Button", Callback = function() UI.Info("Flat!", "Flat button") end })
Buttons:AddPrimaryButton("Primary Button", function() UI.Success("Primary!", "Primary button") end)
Buttons:AddDangerButton("Danger Button", function() UI.Error("Danger!", "Danger button") end)
Buttons:AddOutlineButton({ Name = "Outline Button", Callback = function() UI.Warning("Outline!", "Outline button") end })
Buttons:AddIconButton({ Name = "Icon Button", Icon = UI.Icons.Check, Callback = function() UI.Info("Icon!", "Icon button") end })
Buttons:AddIconButton({ Name = "Preview Button", Icon = UI.Icons.Preview, Callback = function() UI.Info("Preview!", "Preview icon button") end })

Buttons:AddSection("Glass & Styled Buttons")
Buttons:AddGlassButton({ Name = "Glass Button", Frosted = true, Callback = function() UI.Info("Glass!", "Frosted glass") end })
Buttons:AddGlassButton({ Name = "Tinted Glass", Frosted = false, Callback = function() UI.Info("Glass!", "Tinted glass") end })
Buttons:AddBorderedButton({ Name = "Outlined Button (Toggle Style)", Callback = function() UI.Info("Bordered!", "Toggle-style") end })
Buttons:AddIconBorderedButton({ Name = "Icon Outlined Button", Icon = UI.Icons.Settings, Callback = function() UI.Info("Icon Bordered!", "Icon button") end })
Buttons:AddGradientButton({ Name = "Gradient Button", Colors = { UI.Colors.Red, UI.Colors.Orange }, Callback = function() UI.Success("Gradient!", "Gradient button") end })

Buttons:AddSection("Unique Styles")
Buttons:AddD3DButton({ Name = "D3D / IMGUI Style", Callback = function() UI.Info("D3D!", "IMGUI-style") end })
Buttons:AddPillButton({ Name = "Pill Button", Callback = function() UI.Info("Pill!", "Pill button") end })
Buttons:AddSquareButton({ Name = "Square Button", Callback = function() UI.Info("Square!", "Square button") end })
Buttons:AddCuteButton({ Name = "Cute Button", Callback = function() UI.Success("Cute!", "Cute button") end })
Buttons:AddLuffyButton({ Name = "Set Sail!", Callback = function() UI.Success("Adventure!", "Luffy button") end })
Buttons:AddMinimalButton({ Name = "Minimal Button", Callback = function() UI.Info("Minimal!", "Minimal button") end })
Buttons:AddCompactButton({ Name = "Compact Button", Callback = function() UI.Info("Compact!", "Compact button") end })
Buttons:AddRetroButton({ Name = "Retro Button", Callback = function() UI.Info("Retro!", "Retro button") end })

Buttons:AddSection("Hyperlinks & Text Buttons")
Buttons:AddHyperlink({ Name = "Simple Hyperlink", Callback = function() UI.Info("Link!", "Hyperlink clicked") end })
Buttons:AddIconHyperlink({ Name = "Open Settings", Icon = UI.Icons.Settings, Callback = function() UI.Info("Settings!", "Settings link") end })
Buttons:AddOutlinedLink({ Name = "Outlined Link", Callback = function() UI.Info("Outlined!", "Outlined link") end })
Buttons:AddIconOutlinedLink({ Name = "Download Config", Icon = UI.Icons.Download, Callback = function() UI.Success("Download!", "Download link") end })
Buttons:AddShimmerLink({ Name = "Shimmer Link", Callback = function() UI.Success("Shimmer!", "Shimmer link") end })
Buttons:AddRainbowButton({ Name = "Rainbow Cycle Button", Callback = function() UI.Success("Rainbow!", "Color cycle") end })

local Layouts = Window:AddTab("Layouts", UI.Icons.Layouts)

Layouts:AddSection("About Layouts")
Layouts:AddParagraph("What are Layouts?", "Layouts define the overall GUI structure. Use Layout = \"LayoutName\" in UI.New() to change.")

Layouts:AddSection("Default Layout")
Layouts:AddParagraph("Layout = \"Default\"", "• Sidebar with tabs on left\n• Content area on right\n• Hub & Cheat Compatible\n• Full mobile support")

Layouts:AddSection("Traditional Layout")
Layouts:AddParagraph("Layout = \"Traditional\"", "• Top tab bar (no sidebar)\n• Content pushed below tabs\n• Hub & Cheat Compatible\n• Rayfield-style")

Layouts:AddSection("Currently Using")
Layouts:AddParagraph("This Example", "This script uses the Default sidebar layout. Compare with layout_traditional.lua to see the top tabs version.")

Layouts:AddSection("Understanding the System")
Layouts:AddParagraph("Layouts vs Hubs", "LAYOUTS = GUI structure (sidebar vs top tabs)\nHUBS = Game selection UI (works in any layout)")

Layouts:AddDivider()
Layouts:AddParagraph("Example Scripts", "• layout_default.lua - Sidebar layout\n• layout_traditional.lua - Top tabs layout\n• hub_example.lua - Full hub example")

local Hubs = Window:AddTab("Hubs", UI.Icons.Hubs)

Hubs:AddHubHeader({ Title = "Game Scripts", Subtitle = "Select a game to load" })
Hubs:AddGameCard({ Name = "Frontlines", Image = UI.GameIcons.Frontlines, Description = "Aimbot, ESP, and more.", Popular = true, GameId = 5938036553, OnLoad = function() print("Loading Frontlines...") end })
Hubs:AddGameCard({ Name = "Deadline", Image = UI.GameIcons.Deadline, Description = "Silent aim and visuals.", New = true, GameId = 7101775479, OnLoad = function() print("Loading Deadline...") end })
Hubs:AddGameCard({ Name = "Riotfall", Image = UI.GameIcons.Riotfall, Description = "Combat utilities.", Updated = true, GameId = 17625359962, OnLoad = function() print("Loading Riotfall...") end })
Hubs:AddGameCard({ Name = "Phantom Forces", Description = "Under maintenance.", Maintenance = true })

Hubs:AddDivider()
Hubs:AddSection("Strip Style")

Hubs:AddGameStrip({
    Games = {
        { Name = "Arsenal", Image = UI.GameIcons.Arsenal, Description = "Aimbot and ESP.", GameId = 286090429, Popular = true, OnLoad = function() print("Loading Arsenal...") end },
        { Name = "Bad Business", Image = UI.GameIcons.BadBusiness, Description = "Silent aim.", GameId = 3233893879, New = true, OnLoad = function() print("Loading Bad Business...") end },
        { Name = "Ohio", Image = UI.GameIcons.Ohio, Description = "Crime utilities.", GameId = 10952685455, OnLoad = function() print("Loading Ohio...") end },
        { Name = "Strucid", Image = UI.GameIcons.Strucid, Description = "Build and shoot.", GameId = 2377868063, Updated = true, OnLoad = function() print("Loading Strucid...") end },
        { Name = "Rivals", Image = UI.GameIcons.Rivals, Description = "Coming soon.", Maintenance = true },
        { Name = "Ground War", Image = UI.GameIcons.GroundWar, Description = "FPS combat.", OnLoad = function() print("Loading Ground War...") end }
    },
    IconSize = 64
})

Hubs:AddDivider()
Hubs:AddSection("Grid Style")

Hubs:AddGameGrid({
    Games = {
        { Name = "Frontlines", Image = UI.GameIcons.Frontlines, GameId = 5938036553, Popular = true, OnLoad = function() print("Loading Frontlines...") end },
        { Name = "Deadline", Image = UI.GameIcons.Deadline, GameId = 7101775479, New = true, OnLoad = function() print("Loading Deadline...") end },
        { Name = "Arsenal", Image = UI.GameIcons.Arsenal, GameId = 286090429, OnLoad = function() print("Loading Arsenal...") end },
        { Name = "Rivals", Image = UI.GameIcons.Rivals, Maintenance = true },
        { Name = "Ohio", Image = UI.GameIcons.Ohio, GameId = 10952685455, Updated = true, OnLoad = function() print("Loading Ohio...") end },
        { Name = "Strucid", Image = UI.GameIcons.Strucid, GameId = 2377868063, OnLoad = function() print("Loading Strucid...") end },
        { Name = "Bad Business", Image = UI.GameIcons.BadBusiness, GameId = 3233893879, OnLoad = function() print("Loading Bad Business...") end },
        { Name = "Inhuman", Image = UI.GameIcons.Inhuman, OnLoad = function() print("Loading Inhuman...") end }
    },
    Columns = 4,
    CardSize = 70,
    AutoJoin = true,
    OnSelect = function(game) UI.Success("Loading", game.Name) end
})

local Plugins = Window:AddTab("Plugins", UI.Icons.Plugins)

Plugins:AddSection("xan.bar Plugins")
Plugins:AddParagraph("About Plugins", "Extend xan.bar with additional features. Use UI.LoadPlugin(name) to load plugins dynamically.")

Plugins:AddSection("Available Plugins")

Plugins:AddButton("Load Notes Plugin", function()
    local notes = UI.GetPlugin("notes")
    if notes then
        notes:Toggle()
        return
    end
    UI.Info("Loading...", "Fetching Notes plugin")
    notes = UI.LoadPlugin("notes")
    if notes then
        UI.Success("Notes Loaded!", "Notes window opened")
    else
        UI.Error("Failed", "Could not load Notes plugin")
    end
end)
Plugins:AddParagraph("Notes", "Create floating sticky notes on your screen. Drag, resize, and customize colors.")

Plugins:AddDivider()

Plugins:AddButton("Load Music Player", function()
    if _G.XanMusicPlayerInstance then
        _G.XanMusicPlayerInstance:ToggleUI()
        return
    end
    UI.Info("Loading...", "Fetching Music Player")
    pcall(function()
        loadstring(game:HttpGet("https://xan.bar/musicplayershowcase.lua"))()
    end)
    if _G.XanMusicPlayerInstance then
        UI.Success("Music Player Loaded!", "Player window opened")
    else
        UI.Error("Failed", "Could not load Music Player")
    end
end)
Plugins:AddParagraph("Music Player", "Full-featured music player with playlists, search, and visualizer. Stream from music.e-vil.com")

Plugins:AddDivider()

Plugins:AddButton("Load Script Search", function()
    local search = UI.GetPlugin("script_search")
    if search then
        search:Toggle()
        return
    end
    UI.Info("Loading...", "Fetching Script Search plugin")
    search = UI.LoadPlugin("script_search")
    if search then
        search:Init()
        search:Show()
        UI.Success("Script Search Loaded!", "Search window opened")
    else
        UI.Error("Failed", "Could not load Script Search")
    end
end)
Plugins:AddParagraph("Script Search", "Search and load scripts from ScriptBlox and RScripts. Syncs with xan theme and toggle key.")

Plugins:AddSection("Plugin API")
Plugins:AddParagraph("Usage", "UI.LoadPlugin('name') - Load from xan.bar/plugins/\nUI.GetPlugin('name') - Get loaded plugin\nUI.ListPlugins() - List all loaded plugins")

Plugins:AddButton("List Loaded Plugins", function()
    local list = UI.ListPlugins()
    if #list > 0 then
        UI.Info("Loaded Plugins", table.concat(list, ", "))
    else
        UI.Info("No Plugins", "No plugins loaded yet")
    end
end)

Plugins:AddSection("Unload Plugins")

Plugins:AddDangerButton("Unload Notes", function()
    local notes = UI.GetPlugin("notes")
    if notes then
        UI.UnloadPlugin("notes")
        UI.Warning("Unloaded", "Notes plugin removed")
    else
        UI.Info("Not Loaded", "Notes plugin is not loaded")
    end
end)

Plugins:AddDangerButton("Unload Music Player", function()
    if _G.XanMusicPlayerInstance then
        _G.XanMusicPlayerInstance:Destroy()
        _G.XanMusicPlayerInstance = nil
        UI.Warning("Unloaded", "Music Player removed")
    else
        UI.Info("Not Loaded", "Music Player is not loaded")
    end
end)

local Settings = Window:AddTab("Settings", UI.Icons.Settings)

Settings:AddSection("Keybinds")

Settings:AddKeybind("Toggle Menu", {
    Default = Enum.KeyCode.RightShift,
    Flag = "Key_Menu"
}, function()
    Window:Toggle()
end)

Settings:AddKeybind("Toggle Aimbot", {
    Default = Enum.KeyCode.LeftAlt,
    Flag = "Key_Aimbot"
})

Settings:AddDivider()

Settings:AddSection("Information")

Settings:AddParagraph("About", "This is a demonstration of the Default layout with a sidebar. All xan.bar elements and features are fully supported in this layout.")

Settings:AddButton("Join Discord", function()
    UI.Info("Discord", "Join at discord.gg/example")
end)

Settings:AddButton("Copy Script", function()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("https://xan.bar/init.lua"))()')
        UI.Success("Copied", "Script copied to clipboard!")
    else
        UI.Error("Error", "Clipboard not supported on this executor")
    end
end)

if UI.IsMobile then
    UI.MobileToggle({ Window = Window, Position = UDim2.new(0.5, 0, 0, 50) })
    
    local AimBtn = UI.AimButton({ HoldMode = true, Callback = function(s) print("Aim:", s) end })
    local TriggerBtn = UI.TriggerButton({ HoldMode = true, Callback = function(s) print("Trigger:", s) end })
    
    Misc:AddSection("Mobile Controls")
    Misc:AddToggle("Show Aim Button", { Default = true }, function(v) if v then AimBtn:Show() else AimBtn:Hide() end end)
    Misc:AddToggle("Show Trigger Button", { Default = true }, function(v) if v then TriggerBtn:Show() else TriggerBtn:Hide() end end)
    Misc:AddToggle("Aim Hold Mode", { Default = true }, function(v) AimBtn:SetHoldMode(v) end)
    Misc:AddToggle("Trigger Hold Mode", { Default = true }, function(v) TriggerBtn:SetHoldMode(v) end)
end

AimbotToggle.Callback = function(v)
    FOVCircle:SetVisible(v)
    print("Aimbot:", v)
end

print("xan.bar loaded!")
print("Features: Crosshair Engine, Theme Editor with Color Picker, and more!")
