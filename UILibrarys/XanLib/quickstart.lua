local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

UI.Splash({ Title = "Quick Start", Subtitle = "Loading...", Duration = 1.5 })
task.wait(1.7)

local Window = UI.New({
    Title = "Quick Start",
    Subtitle = "Template",
    Theme = "Default",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ShowActiveList = true,
    ShowLogo = true
})

local Main = Window:AddTab("Main", UI.Icons.Home)

Main:AddSection("Player")

Main:AddSlider("Walk Speed", { Min = 16, Max = 200, Default = 16, Flag = "WalkSpeed" }, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end)

Main:AddSlider("Jump Power", { Min = 50, Max = 200, Default = 50, Flag = "JumpPower" }, function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = v
    end
end)

Main:AddSection("Toggles")

Main:AddToggle("Infinite Jump", { Default = false, Flag = "InfJump", ShowInActiveList = true }, function(v)
    _G.InfiniteJump = v
end)

Main:AddToggle("Noclip", { Default = false, Flag = "Noclip", ShowInActiveList = true }, function(v)
    _G.Noclip = v
end)

local Visuals = Window:AddTab("Visuals", UI.Icons.ESP)

Visuals:AddSection("Display")

local Watermark = UI.Watermark({ 
    Text = "Quick Start", 
    ShowFPS = true, 
    ShowPing = true, 
    Visible = false 
})

Visuals:AddToggle("Show Watermark", { Default = false }, function(v)
    if v then Watermark:Show() else Watermark:Hide() end
end)

Visuals:AddSection("Crosshair")

Visuals:AddCrosshair({
    Name = "Custom Crosshair",
    Styles = {"None", "Dot", "Cross", "Circle"},
    DefaultStyle = "None",
    DefaultColor = UI.Colors.Red,
    DefaultSize = 10,
    Enabled = false,
    Flag = "Crosshair"
})

local Settings = Window:AddTab("Settings", UI.Icons.Settings)

Settings:AddSection("Theme")

Settings:AddDropdown("Select Theme", UI.GetThemes(), function(theme)
    UI.SetTheme(theme)
end)

Settings:AddSection("Keybinds")

Settings:AddKeybind("Toggle Menu", { Default = Enum.KeyCode.RightShift }, function()
    Window:Toggle()
end)

Settings:AddDivider()

Settings:AddSection("Script")

Settings:AddButton("Copy Loader", function()
    if setclipboard then
        setclipboard('loadstring(game:HttpGet("https://xan.bar/quickstart.lua"))()')
        UI.Success("Copied!", "Loader copied")
    end
end)

Settings:AddDangerButton("Unload", function()
    Watermark:Destroy()
    Window:Destroy()
end)

game:GetService("RunService").Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    if _G.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

if UI.IsMobile then
    UI.MobileToggle({ Window = Window })
    UI.Info("Mobile", "Touch controls enabled")
end

UI.Success("Loaded!", "Quick Start ready")

