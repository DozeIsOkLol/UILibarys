local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

local Window = UI.New({
    Title = "Notifications",
    Subtitle = "Demo",
    Theme = "Default",
    Size = UDim2.new(0, 520, 0, 400)
})

local Demo = Window:AddTab("Demo", UI.Icons.Info)

Demo:AddSection("Standard Notifications")

Demo:AddButton("Success", function()
    UI.Success("Success!", "Operation completed successfully")
end)

Demo:AddButton("Error", function()
    UI.Error("Error!", "Something went wrong")
end)

Demo:AddButton("Warning", function()
    UI.Warning("Warning!", "Proceed with caution")
end)

Demo:AddButton("Info", function()
    UI.Info("Info", "Here is some information")
end)

Demo:AddSection("Styles")

Demo:AddButton("Toast", function()
    UI.Toast("Toast", "A simple toast notification")
end)

Demo:AddButton("Banner", function()
    UI.Banner("Banner", "Full width banner notification")
end)

Demo:AddButton("Pill", function()
    UI.Pill("Pill notification!")
end)

Demo:AddButton("Slide", function()
    UI.Slide("Slide", "Slides in from the right")
end)

Demo:AddButton("Minimal", function()
    UI.Minimal("Minimal notification text")
end)

Demo:AddSection("Custom")

Demo:AddButton("Custom Notify", function()
    UI.Notify({
        Title = "Custom",
        Content = "You can customize everything!",
        Style = "Default",
        Duration = 3
    })
end)

if UI.IsMobile then
    UI.MobileToggle({ Window = Window })
end

UI.Success("Demo Ready", "Try the notification buttons!")

