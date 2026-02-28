--[[
╔══════════════════════════════════════════════════════════════╗
║           NexusLib v0.6 — Full Feature Demo UI              ║
║  Showcases every element: Tabs, SubTabs, Sections,          ║
║  Label, Image, Button, Toggle, Slider, Dropdown,            ║
║  MultiDropdown, TextInput, Keybind, ColorPicker,             ║
║  ConfigPanel, Divider, InfoBox, ProgressBar, Checkbox,       ║
║  Radio, Stepper, Badge, Accordion, Dependencies,             ║
║  Confirm/Alert dialogs, Notifications, Themes                ║
╚══════════════════════════════════════════════════════════════╝
]]

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/MadeByDoze/NexusUILib/v0.7/NexusLib.lua"))()


local Win = Nexus:CreateWindow({
    Title     = "NexusLib v0.7 Demo",
    Subtitle  = "Full feature showcase",
    Size      = UDim2.new(0, 600, 0, 450),
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigDir = "NexusLibDemo",
    Theme     = "Dark",
    AutoSave  = true,
})

local wm = Win:AddWatermark("NexusLib v0.6 Demo")

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 1: NEW ELEMENTS (InfoBox, Divider, ProgressBar, Checkbox, Radio, Stepper, Badge)
-- ═══════════════════════════════════════════════════════════════════════════

local NewTab = Win:AddTab({ Name = "New Elements", Icon = "✨" })

NewTab:AddSection("Information Elements")

NewTab:AddInfoBox({ Type = "Info",    Message = "Info box — great for tips and notices." })
NewTab:AddInfoBox({ Type = "Success", Message = "Success box — confirmations and results." })
NewTab:AddInfoBox({ Type = "Warning", Message = "Warning — use for caution messages." })
NewTab:AddInfoBox({ Type = "Error",   Message = "Error — failures or invalid actions." })

NewTab:AddDivider({ Text = "PROGRESS & CONTROLS" })

local progress = NewTab:AddProgressBar({
    Id = "demo_progress",
    Name = "Loading Progress",
    Value = 0,
    Color = Color3.fromRGB(68, 196, 110),
    Tooltip = "Animated progress bar",
})
spawn(function()
    for i = 0, 100, 5 do task.wait(0.4) progress:Set(i) end
end)

NewTab:AddDivider({ Text = "SELECTION" })

NewTab:AddCheckbox({
    Id = "opt_a", Name = "Option A", Default = true,
    Tooltip = "Right-click for context menu",
    Callback = function(v) print("Option A:", v) end,
    Context = {
        { Label = "Reset", Callback = function() Nexus:Notify({ Title = "Reset", Message = "Option A reset", Type = "Info" }) end },
        "---",
        { Label = "Help", Callback = function() Nexus:Notify({ Title = "Help", Message = "This is a checkbox.", Type = "Info" }) end },
    },
})

NewTab:AddCheckbox({ Id = "opt_b", Name = "Option B", Default = false, Callback = function(v) print("Option B:", v) end })

NewTab:AddRadio({
    Id = "difficulty",
    Name = "Difficulty",
    Options = {"Easy", "Normal", "Hard", "Extreme"},
    Default = "Normal",
    Tooltip = "Single selection",
    Callback = function(v) print("Difficulty:", v) end,
})

NewTab:AddDivider({ Text = "NUMBER STEPPER" })

NewTab:AddStepper({
    Id = "team_size", Name = "Team Size",
    Min = 1, Max = 10, Step = 1, Default = 4,
    Tooltip = "Increment/decrement value",
    Callback = function(v) print("Team size:", v) end,
})

NewTab:AddBadge({
    Name = "Premium", BadgeText = "PRO",
    BadgeColor = Color3.fromRGB(255, 215, 0),
    Tooltip = "Badge label",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 2: ACCORDIONS (collapsible sections)
-- ═══════════════════════════════════════════════════════════════════════════

local AccordionTab = Win:AddTab({ Name = "Accordions", Icon = "📁" })

AccordionTab:AddSection("Collapsible Sections")

local basic = AccordionTab:AddAccordion({ Name = "Basic Settings", DefaultExpanded = true })
basic:AddToggle({ Id = "sound", Name = "Sound", Default = true, Callback = function(v) print("Sound:", v) end })
basic:AddToggle({ Id = "music", Name = "Music", Default = true })
basic:AddSlider({ Id = "volume", Name = "Volume", Min = 0, Max = 100, Default = 75 })

local advanced = AccordionTab:AddAccordion({ Name = "Advanced", DefaultExpanded = false })
advanced:AddToggle({ Id = "vsync", Name = "V-Sync", Default = false })
advanced:AddSlider({ Id = "render_dist", Name = "Render Distance", Min = 100, Max = 5000, Default = 1000, Step = 100 })
advanced:AddDropdown({ Id = "quality", Name = "Quality", Options = {"Low", "Medium", "High", "Ultra"}, Default = "High" })

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 3: SUB-TABS (nested tabs inside a main tab)
-- ═══════════════════════════════════════════════════════════════════════════

local SubTabDemo = Win:AddTab({ Name = "Sub-Tabs", Icon = "📑" })

SubTabDemo:AddSection("Nested sub-tabs")

local CombatSub = SubTabDemo:AddSubTab({ Name = "Combat" })
CombatSub:AddToggle({ Id = "aimbot", Name = "Aimbot", Default = false, Callback = function(v) print("Aimbot:", v) end })
CombatSub:AddSlider({ Id = "fov", Name = "FOV", Min = 0, Max = 120, Default = 90 })
CombatSub:AddDropdown({ Id = "target", Name = "Target", Options = {"Head", "Body", "Closest"}, Default = "Head" })

local VisualSub = SubTabDemo:AddSubTab({ Name = "Visuals" })
VisualSub:AddToggle({ Id = "esp", Name = "ESP", Default = false })
VisualSub:AddColorPicker({ Id = "esp_color", Name = "ESP Color", Default = Color3.fromRGB(255, 0, 0) })
VisualSub:AddSlider({ Id = "esp_dist", Name = "Distance", Min = 50, Max = 500, Default = 200 })

local MiscSub = SubTabDemo:AddSubTab({ Name = "Misc" })
MiscSub:AddButton({
    Name = "Reset All",
    ButtonText = "Reset",
    Color = Color3.fromRGB(255, 78, 78),
    Callback = function()
        Win:Confirm({
            Title = "Reset Settings?",
            Message = "Reset all options in this sub-tab?",
            ConfirmText = "Reset",
            CancelText = "Cancel",
            OnConfirm = function() Nexus:Notify({ Title = "Reset", Message = "Settings reset", Type = "Success" }) end,
        })
    end,
})
MiscSub:AddConfigPanel()

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 4: DEPENDENCIES (show/hide elements based on others)
-- ═══════════════════════════════════════════════════════════════════════════

local DepTab = Win:AddTab({ Name = "Dependencies", Icon = "🔗" })

DepTab:AddSection("Conditional visibility")

DepTab:AddLabel({ Text = "Elements below only appear when \"Advanced Mode\" is ON." })

DepTab:AddToggle({
    Id = "advanced_mode",
    Name = "Enable Advanced Mode",
    Default = false,
    Callback = function(v) print("Advanced:", v) end,
})

DepTab:AddSlider({ Id = "adv_slider", Name = "Advanced Slider", Min = 0, Max = 100, Default = 50 })
DepTab:AddToggle({ Id = "adv_toggle", Name = "Advanced Toggle", Default = false })
DepTab:AddDependency("adv_slider", "advanced_mode", function(v) return v == true end)
DepTab:AddDependency("adv_toggle", "advanced_mode", function(v) return v == true end)

DepTab:AddDivider({ Text = "AI OPTIONS" })

DepTab:AddRadio({
    Id = "ai_mode",
    Name = "AI Mode",
    Options = {"Off", "Easy", "Hard"},
    Default = "Off",
})
DepTab:AddSlider({ Id = "ai_count", Name = "AI Count", Min = 1, Max = 20, Default = 5 })
DepTab:AddDependency("ai_count", "ai_mode", function(v) return v ~= "Off" end)

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 5: DIALOGS & THEMES (Confirm, Alert, SetTheme)
-- ═══════════════════════════════════════════════════════════════════════════

local DialogTab = Win:AddTab({ Name = "Dialogs & Themes", Icon = "💬" })

DialogTab:AddSection("Modal dialogs")

DialogTab:AddButton({
    Name = "Confirm dialog",
    ButtonText = "Open",
    Callback = function()
        Win:Confirm({
            Title = "Confirm Action",
            Message = "Are you sure?",
            ConfirmText = "Yes",
            CancelText = "No",
            OnConfirm = function() Nexus:Notify({ Title = "Confirmed", Message = "You confirmed.", Type = "Success" }) end,
            OnCancel = function() Nexus:Notify({ Title = "Cancelled", Message = "You cancelled.", Type = "Info" }) end,
        })
    end,
})

DialogTab:AddButton({
    Name = "Alert dialog",
    ButtonText = "Open",
    Color = Color3.fromRGB(255, 182, 65),
    Callback = function()
        Win:Alert({
            Title = "Notice",
            Message = "This is an alert. Click OK to close.",
            ButtonText = "OK",
            OnClose = function() print("Alert closed") end,
        })
    end,
})

DialogTab:AddDivider({ Text = "THEMES" })

DialogTab:AddLabel({ Text = "NexusLib v0.6: Dark, Light, Midnight, Rose, Ocean, Forest" })

local themeList = {
    { name = "Dark",     color = Color3.fromRGB(99, 157, 255) },
    { name = "Light",    color = Color3.fromRGB(79, 130, 230) },
    { name = "Midnight", color = Color3.fromRGB(150, 100, 255) },
    { name = "Rose",     color = Color3.fromRGB(240, 100, 148) },
    { name = "Ocean",    color = Color3.fromRGB(65, 185, 230) },
    { name = "Forest",   color = Color3.fromRGB(110, 200, 125) },
}
for _, t in ipairs(themeList) do
    DialogTab:AddButton({
        Name = t.name .. " theme",
        ButtonText = "Apply",
        Color = t.color,
        Callback = function()
            Win:SetTheme(t.name)
            Nexus:Notify({ Title = "Theme", Message = "Switched to " .. t.name, Type = "Success", Duration = 2 })
        end,
    })
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 6: CLASSIC ELEMENTS (Label, Image, Button, Toggle, Slider, Dropdown, etc.)
-- ═══════════════════════════════════════════════════════════════════════════

local ClassicTab = Win:AddTab({ Name = "Classic", Icon = "📦" })

ClassicTab:AddSection("Core elements")

ClassicTab:AddLabel({
    Text = "All v0.5-style elements: Label, Image, Button, Toggle, Slider, Dropdown, MultiDropdown, TextInput, Keybind, ColorPicker.",
})

-- Image (optional: use a valid Roblox asset ID or leave default)
ClassicTab:AddImage({
    Id = "demo_image",
    Name = "Image element",
    Image = "rbxassetid://6031097223",
    Height = 80,
    ScaleType = Enum.ScaleType.Fit,
    Caption = "NexusLib demo",
    Tooltip = "Supports Image, Height, Caption, ScaleType",
})

ClassicTab:AddButton({
    Name = "Button with context menu",
    ButtonText = "Run",
    Tooltip = "Right-click for menu",
    Context = {
        { Label = "Copy", Callback = function() Nexus:Notify({ Title = "Copy", Message = "Copied", Type = "Info" }) end },
        { Label = "Paste", Callback = function() Nexus:Notify({ Title = "Paste", Message = "Pasted", Type = "Info" }) end },
    },
    Callback = function() Nexus:Notify({ Title = "Button", Message = "Clicked!", Type = "Success" }) end,
})

ClassicTab:AddToggle({
    Id = "classic_toggle",
    Name = "Toggle",
    Default = false,
    Tooltip = "Toggle example",
    Callback = function(v) print("Toggle:", v) end,
})

ClassicTab:AddSlider({
    Id = "classic_slider",
    Name = "Slider",
    Min = 0, Max = 100, Default = 50, Step = 5,
    Tooltip = "Slider example",
    Callback = function(v) print("Slider:", v) end,
})

ClassicTab:AddDropdown({
    Id = "classic_dropdown",
    Name = "Dropdown",
    Options = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Callback = function(v) print("Dropdown:", v) end,
})

ClassicTab:AddMultiDropdown({
    Id = "classic_multi",
    Name = "Multi-select",
    Items = {"A", "B", "C", "D"},
    Default = {"A", "B"},
    Callback = function(arr) print("Multi:", table.concat(arr, ", ")) end,
})

ClassicTab:AddTextInput({
    Id = "username",
    Name = "Username",
    Placeholder = "Enter name...",
    Default = "Player",
    Callback = function(text) print("Username:", text) end,
})

ClassicTab:AddKeybind({
    Id = "keybind_demo",
    Name = "Keybind",
    Default = Enum.KeyCode.E,
    Tooltip = "Click then press a key",
    OnPress = function() print("Key pressed!") end,
    Callback = function(key) print("Key:", key.Name) end,
})

ClassicTab:AddColorPicker({
    Id = "player_color",
    Name = "Player color",
    Default = Color3.fromRGB(255, 100, 150),
    Callback = function(c) print("Color:", c) end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB 7: SETTINGS (Config panel + notifications)
-- ═══════════════════════════════════════════════════════════════════════════

local SettingsTab = Win:AddTab({ Name = "Settings", Icon = "⚙" })

SettingsTab:AddSection("Config & Notifications")

SettingsTab:AddInfoBox({
    Type = "Info",
    Message = "Config panel: save/load/export/import profiles. Auto-save runs every 30s.",
})

SettingsTab:AddConfigPanel()

SettingsTab:AddDivider({ Text = "NOTIFICATIONS" })

SettingsTab:AddButton({
    Name = "Info notification",
    ButtonText = "Send",
    Callback = function() Nexus:Notify({ Title = "Info", Message = "Info notification", Type = "Info", Duration = 3 }) end,
})
SettingsTab:AddButton({
    Name = "Success notification",
    ButtonText = "Send",
    Callback = function() Nexus:Notify({ Title = "Success", Message = "Done!", Type = "Success", Duration = 3 }) end,
})
SettingsTab:AddButton({
    Name = "Warning notification",
    ButtonText = "Send",
    Callback = function() Nexus:Notify({ Title = "Warning", Message = "Be careful", Type = "Warning", Duration = 3 }) end,
})
SettingsTab:AddButton({
    Name = "Error notification",
    ButtonText = "Send",
    Callback = function() Nexus:Notify({ Title = "Error", Message = "Something failed", Type = "Error", Duration = 3 }) end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- Startup notification
-- ═══════════════════════════════════════════════════════════════════════════

Nexus:Notify({
    Title = "NexusLib v0.7 Demo",
    Message = "Full feature demo loaded. Press RightShift to toggle. Right-click elements for context menus.",
    Type = "Success",
    Duration = 5,
})

print("NexusLib v0.7 demo UI loaded.")
