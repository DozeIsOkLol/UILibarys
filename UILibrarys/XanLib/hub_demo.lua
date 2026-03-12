local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

UI.Splash({ Title = "Game Hub", Subtitle = "Select a game...", Duration = 2 })
task.wait(2.2)

local Window = UI.New({
    Title = "Game Hub",
    Subtitle = "Demo",
    Theme = "Default",
    Size = UDim2.new(0, 620, 0, 480),
    ShowUserInfo = true,
    ShowLogo = true,
    Logo = UI.Logos.XanBar
})

local Games = Window:AddTab("Games", UI.Icons.Hubs)

Games:AddHubHeader({ 
    Title = "Available Games", 
    Subtitle = "Select a game to load its script" 
})

Games:AddGameCard({ 
    Name = "Frontlines", 
    Image = UI.GameIcons.Frontlines, 
    Description = "Full ESP, Aimbot, and utilities.", 
    Popular = true, 
    GameId = 5938036553, 
    OnLoad = function() 
        UI.Success("Loading", "Frontlines script...")
    end 
})

Games:AddGameCard({ 
    Name = "Deadline", 
    Image = UI.GameIcons.Deadline, 
    Description = "Silent aim and visual enhancements.", 
    New = true, 
    GameId = 7101775479, 
    OnLoad = function() 
        UI.Success("Loading", "Deadline script...")
    end 
})

Games:AddGameCard({ 
    Name = "Arsenal", 
    Image = UI.GameIcons.Arsenal, 
    Description = "Aimbot, ESP, and kill all.", 
    Updated = true, 
    GameId = 286090429, 
    OnLoad = function() 
        UI.Success("Loading", "Arsenal script...")
    end 
})

Games:AddGameCard({ 
    Name = "Coming Soon", 
    Description = "New game support in development.", 
    Maintenance = true 
})

Games:AddDivider()
Games:AddSection("Quick Select")

Games:AddGameStrip({
    Games = {
        { Name = "Ohio", Image = UI.GameIcons.Ohio, GameId = 10952685455, OnLoad = function() UI.Info("Loading", "Ohio...") end },
        { Name = "Bad Business", Image = UI.GameIcons.BadBusiness, GameId = 3233893879, New = true, OnLoad = function() UI.Info("Loading", "Bad Business...") end },
        { Name = "Strucid", Image = UI.GameIcons.Strucid, GameId = 2377868063, OnLoad = function() UI.Info("Loading", "Strucid...") end },
        { Name = "Rivals", Image = UI.GameIcons.Rivals, Maintenance = true },
    },
    IconSize = 64
})

local Settings = Window:AddTab("Settings", UI.Icons.Settings)

Settings:AddSection("Hub Settings")
Settings:AddToggle("Auto-Join Game", { Default = false, Flag = "AutoJoin" }, function(v)
    UI.Info("Auto-Join", v and "Enabled" or "Disabled")
end)

Settings:AddToggle("Remember Last Game", { Default = true, Flag = "RememberGame" })

Settings:AddSection("Appearance")
Settings:AddDropdown("Theme", UI.GetThemes(), function(theme)
    UI.SetTheme(theme)
    UI.Success("Theme", "Changed to " .. theme)
end)

Settings:AddDivider()

Settings:AddButton("Copy Loader", function()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("https://xan.bar/hub_demo.lua"))()')
        UI.Success("Copied", "Loader copied to clipboard!")
    end
end)

if UI.IsMobile then
    UI.MobileToggle({ Window = Window })
end

UI.Success("Hub Loaded!", "Select a game to begin")

