local NotifyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/Notifications/Soulja/V0.1/Source.lua"))();
-- Simple typed notification
NotifyLib:Notify({
    Title    = "Quest Complete!",
    Message  = "You finished: Explore the Forest.",
    Type     = "Success",  -- Success | Error | Warning | Info | Custom
    Duration = 5,
})

-- With action buttons
NotifyLib:Notify({
    Title    = "Server Restart",
    Message  = "Server restarting in 60 seconds.",
    Type     = "Warning",
    Duration = 10,
    Button1  = { Text = "Dismiss",  Callback = function() end },
    Button2  = { Text = "Leave",    Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end },
})

-- Custom color
NotifyLib:Notify({
    Title   = "VIP Bonus",
    Message = "You received 500 coins!",
    Type    = "Custom",
    Color   = Color3.fromRGB(255, 170, 0),
    Duration = 6,
})
wait(10)
-- Clear all
NotifyLib:ClearAll()
