-- toggle with 'E'
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Drawing = Drawing.new  -- Requires Drawing API support

local player = Players.LocalPlayer
local espEnabled = false
local boxes = {}

local function createBox(targetPlayer)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    box.Rounding = 0
    boxes[targetPlayer] = box
end

local function updateESP()
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not boxes[targetPlayer] then createBox(targetPlayer) end
            local box = boxes[targetPlayer]
            box.Visible = espEnabled
            local rootPart = targetPlayer.Character.HumanoidRootPart
            local vector, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local size = (Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)) - Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 5, 0))).Magnitude
                box.Size = Vector2.new(size, size)
                box.Position = Vector2.new(vector.X - size/2, vector.Y - size/2)
            else
                box.Visible = false
            end
        end
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        print("ESP:", espEnabled and "ON" or "OFF")
    end
end)

RunService.RenderStepped:Connect(updateESP)

Players.PlayerRemoving:Connect(function(plr)
    if boxes[plr] then boxes[plr]:Remove() end
end)

print("ESP loaded! Press 'E' to toggle player boxes.")
