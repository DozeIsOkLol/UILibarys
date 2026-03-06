local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/Notifications/Akali/Source.lua"))();
local Notify = AkaliNotif.Notify;

wait(1);

Notify({
Description = "This description is super long and should cause an overlap in wrapping";
Title = "Early | Wave 1";
Duration = 5;
});

wait(1);

Notify({
Description = "This description is super long and should cause an overlap in wrapping";
Title = "Early | Wave 1";
Duration = 10;
});

wait(1);

Notify({
Description = "This description is super long and should cause an overlap in wrapping";
Title = "Early | Wave 1";
Duration = 1;
});

wait(1);

Notify({
Description = "This description is super long and should cause an overlap in wrapping";
Duration = 3;
});
