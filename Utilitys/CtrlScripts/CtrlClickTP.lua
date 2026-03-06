game.StarterGui:SetCore("SendNotification",{
    Title = "Usage";
    Text = "Hover mouse on target then press ctrl + mouse1";
})

game.StarterGui:SetCore("SendNotification",{
    Title = "Shameless Plugin";
    Text = "Perhaps join our Discord :)";
})

local Plr = game:GetService("Players").LocalPlayer
local Mouse = Plr:GetMouse()

Mouse.Button1Down:connect(function()
if not game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then return end
if not Mouse.Target then return end
Plr.Character:MoveTo(Mouse.Hit.p)
end)
