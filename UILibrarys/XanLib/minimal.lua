local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

local Window = UI.New({
    Title = "My Script",
    Theme = "Default"
})

local Main = Window:AddTab("Main", UI.Icons.Home)

Main:AddSection("Features")

Main:AddToggle("Enable Feature", { Default = false }, function(value)
    print("Feature:", value)
end)

Main:AddSlider("Speed", { Min = 16, Max = 100, Default = 16 }, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

Main:AddButton("Click Me", function()
    UI.Success("Clicked!", "Button works")
end)

if UI.IsMobile then
    UI.MobileToggle({ Window = Window })
end

print("Script loaded!")

