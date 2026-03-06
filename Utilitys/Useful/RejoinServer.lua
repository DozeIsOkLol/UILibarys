local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

Players.LocalPlayer.Chatted:Connect(function(msg)
    if msg == "/rejoin" then
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end
end)

print("Rejoin loaded! Chat '/rejoin'.")
