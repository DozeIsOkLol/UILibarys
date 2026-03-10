local MangoLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/MangoLib/Source.lua"))()

local win = MangoLib:Window("Mango Lib")
MangoLib:Notify("Notification!", "UI LOADED!")

local TabFarm = win:Tab("Autofarm")

TabFarm:Label("This is A Label")

TabFarm:Button("print hi", function()
    print("Hi!")
end)

TabFarm:Toggle("Print True / False", function(Bool)
    print(tostring(Bool))
end)

TabFarm:Dropdown("Select Enemies", {"Bandit", "Crook", "Marine"}, function(EnemyName)
    print(EnemyName)
end)

TabFarm:Slider("Walk Speed", 16, 500, 50, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

TabFarm:TextBox("Type Hi", function(Value)
    if Value == "Hi" then
        print("Correct Text")
    else
        print("Incorrect Text")
    end
end)

TabFarm:KeyBind("Spam Hi", Enum.KeyCode.B, function(Value)
    while Value do task.wait()
        print("Hi")
    end
end)
