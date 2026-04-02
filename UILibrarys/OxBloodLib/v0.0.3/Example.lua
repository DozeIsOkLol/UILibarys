local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/OxBloodLib/v0.0.3/Source.lua"))().Load({
    Name = "OxBlood v0.0.3"
})

UI:CreateSearchBar()

local Main = UI:AddPage("Main")

Main:AddSection("Core")

Main:AddButton({
    Text = "Notify",
    Callback = function()
        UI:Notify({
            Title = "OxBlood",
            Description = "This is a premium notification",
            Type = "Info"
        })
    end
})

Main:AddToggle({
    Text = "God Mode",
    Default = false,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Main:AddSlider({
    Text = "WalkSpeed",
    Min = 0,
    Max = 100,
    Step = 1,
    Callback = function(v)
        print("Speed:", v)
    end
})

Main:AddDropdown({
    Text = "Select Weapon",
    Options = {"Gun", "Knife", "Bat"},
    Multi = true,
    Callback = function(v)
        print(v)
    end
})

Main:AddInput({
    Placeholder = "Enter name",
    Callback = function(v)
        print(v)
    end
})

Main:AddKeybind({
    Text = "Open Menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        UI:Hide()
    end
})

Main:AddSeparator("Extras")

Main:AddParagraph("<b>OxBlood UI</b> now supports <font color='rgb(160,20,40)'>RichText</font>")

local Progress = Main:AddProgress({Value = 0.3})
task.wait(2)
Progress:Set(0.8)

Main:AddImage("rbxassetid://7072718364")

-- CONFIG
UI:SaveConfig("test")
task.wait(1)
UI:LoadConfig("test")
