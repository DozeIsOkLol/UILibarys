local NotifyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/Notifications/Soulja/V0.2/Source.lua"))();

-- ① Typed notification
NotifyLib:Notify({
    Title    = "Quest Complete!",
    Message  = "You finished: Explore the Forest. +250 XP.",
    Type     = "Success",  -- Success | Error | Warning | Info | Custom
    Duration = 5,
})

-- ② With action buttons
NotifyLib:Notify({
    Title    = "Friend Request",
    Message  = "Player123 wants to join your party.",
    Type     = "Info",
    Duration = 8,
    Button1  = { Text = "Decline", Callback = function() end },
    Button2  = { Text = "Accept",  Callback = function() end },
})

-- ③ Custom accent + early dismiss
local handle = NotifyLib:Notify({
    Title  = "VIP Reward",
    Type   = "Custom",
    Color  = Color3.fromRGB(255, 200, 0),
})

Wait(10)
NotifyLib:ClearAll()  -- wipe all active notifications
