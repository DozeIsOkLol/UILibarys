-- (Keybind: Spacebar for infinite jumps)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

UserInputService.JumpRequest:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

print("Infinite Jump loaded! Spam Spacebar.")
