--[[
    NexusLib v0.6 — Example Script with NEW Features
    Demonstrates all new elements and functionality
]]

local Nexus = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local Win = Nexus:CreateWindow({
    Title     = "Enhanced UI Demo",
    Subtitle  = "v0.6 Features",
    Size      = UDim2.new(0, 600, 0, 450),
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigDir = "NexusEnhanced",
    Theme     = "Dark",      -- Try: "Ocean", "Forest" (NEW themes!)
    AutoSave  = true,        -- NEW: Auto-save every 30 seconds
})

local wm = Win:AddWatermark("Enhanced Demo")

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: NEW ELEMENTS SHOWCASE
-- ═══════════════════════════════════════════════════════════════════════════

local NewElements = Win:AddTab({ Name = "New Elements", Icon = "✨" })

NewElements:AddSection("Information Elements")

-- NEW: Info Box (4 types: Info, Success, Warning, Error)
NewElements:AddInfoBox({
    Type = "Info",
    Message = "This is an info box! Perfect for displaying important messages to users."
})

NewElements:AddInfoBox({
    Type = "Success",
    Message = "Operation completed successfully! ✓"
})

NewElements:AddInfoBox({
    Type = "Warning",
    Message = "Warning: This action cannot be undone!"
})

NewElements:AddInfoBox({
    Type = "Error",
    Message = "Error: Failed to connect to server."
})

-- NEW: Divider with text
NewElements:AddDivider({ Text = "PROGRESS & STATS" })

-- NEW: Progress Bar
local progressBar = NewElements:AddProgressBar({
    Id = "progress_demo",
    Name = "Loading Progress",
    Value = 0,
    Color = Color3.fromRGB(68, 196, 110),
    Tooltip = "Shows current progress",
})

-- Animate progress bar for demo
spawn(function()
    for i = 0, 100, 5 do
        task.wait(0.5)
        progressBar:Set(i)
    end
end)

NewElements:AddDivider({ Text = "SELECTION CONTROLS" })

-- NEW: Checkbox (simpler than toggle for lists)
NewElements:AddCheckbox({
    Id = "feature_1",
    Name = "Enable Feature 1",
    Default = true,
    Tooltip = "Toggle this feature on/off",
    Callback = function(v) print("Feature 1:", v) end,
})

NewElements:AddCheckbox({
    Id = "feature_2",
    Name = "Enable Feature 2",
    Default = false,
    Callback = function(v) print("Feature 2:", v) end,
})

-- NEW: Radio Button Group (choose one option)
NewElements:AddRadio({
    Id = "difficulty",
    Name = "Difficulty Level",
    Options = {"Easy", "Normal", "Hard", "Extreme"},
    Default = "Normal",
    Tooltip = "Select game difficulty",
    Callback = function(v) print("Difficulty:", v) end,
})

NewElements:AddRadio({
    Id = "gamemode",
    Name = "Game Mode",
    Options = {"Solo", "Duo", "Squad"},
    Default = "Solo",
    Callback = function(v) print("Game Mode:", v) end,
})

NewElements:AddDivider({ Text = "NUMBER CONTROLS" })

-- NEW: Number Stepper (increment/decrement buttons)
NewElements:AddStepper({
    Id = "team_size",
    Name = "Team Size",
    Min = 1,
    Max = 10,
    Step = 1,
    Default = 4,
    Tooltip = "Number of players per team",
    Callback = function(v) print("Team size:", v) end,
})

NewElements:AddStepper({
    Id = "rounds",
    Name = "Number of Rounds",
    Min = 1,
    Max = 50,
    Step = 5,
    Default = 10,
    Callback = function(v) print("Rounds:", v) end,
})

-- NEW: Badge (decorative status indicator)
NewElements:AddBadge({
    Name = "Premium Feature",
    BadgeText = "PRO",
    BadgeColor = Color3.fromRGB(255, 215, 0),
    Tooltip = "This is a premium-only feature",
})

NewElements:AddBadge({
    Name = "Beta Feature",
    BadgeText = "BETA",
    BadgeColor = Color3.fromRGB(150, 100, 255),
    Tooltip = "This feature is in beta testing",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: COLLAPSIBLE SECTIONS
-- ═══════════════════════════════════════════════════════════════════════════

local Collapsible = Win:AddTab({ Name = "Accordions", Icon = "📁" })

Collapsible:AddSection("Organized Settings")

-- NEW: Accordion/Collapsible (group settings together)
local basicSettings = Collapsible:AddAccordion({
    Name = "Basic Settings",
    DefaultExpanded = true,
})

basicSettings:AddToggle({
    Id = "sound",
    Name = "Sound Effects",
    Default = true,
    Callback = function(v) print("Sound:", v) end,
})

basicSettings:AddToggle({
    Id = "music",
    Name = "Background Music",
    Default = true,
    Callback = function(v) print("Music:", v) end,
})

basicSettings:AddSlider({
    Id = "volume",
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 75,
    Callback = function(v) print("Volume:", v) end,
})

local advancedSettings = Collapsible:AddAccordion({
    Name = "Advanced Settings",
    DefaultExpanded = false,
})

advancedSettings:AddToggle({
    Id = "vsync",
    Name = "V-Sync",
    Default = false,
})

advancedSettings:AddToggle({
    Id = "motion_blur",
    Name = "Motion Blur",
    Default = false,
})

advancedSettings:AddSlider({
    Id = "render_distance",
    Name = "Render Distance",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Step = 100,
})

local graphicsSettings = Collapsible:AddAccordion({
    Name = "Graphics Quality",
    DefaultExpanded = false,
})

graphicsSettings:AddToggle({
    Id = "shadows",
    Name = "Shadows",
    Default = true,
})

graphicsSettings:AddToggle({
    Id = "reflections",
    Name = "Reflections",
    Default = false,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: ELEMENT DEPENDENCIES (NEW FEATURE!)
-- ═══════════════════════════════════════════════════════════════════════════

local Dependencies = Win:AddTab({ Name = "Dependencies", Icon = "🔗" })

Dependencies:AddSection("Smart Element Visibility")

Dependencies:AddLabel({
    Text = "Elements can show/hide based on other element values!\nTry toggling the options below:"
})

-- Master toggle
Dependencies:AddToggle({
    Id = "enable_advanced",
    Name = "Enable Advanced Mode",
    Default = false,
    Tooltip = "Shows advanced options when enabled",
    Callback = function(v) print("Advanced mode:", v) end,
})

-- These elements only show when advanced mode is ON
Dependencies:AddSlider({
    Id = "advanced_slider",
    Name = "Advanced Setting 1",
    Min = 0,
    Max = 100,
    Default = 50,
})

Dependencies:AddToggle({
    Id = "advanced_toggle",
    Name = "Advanced Setting 2",
    Default = false,
})

-- Register dependencies (these elements depend on enable_advanced)
Dependencies:AddDependency("advanced_slider", "enable_advanced", function(v) return v == true end)
Dependencies:AddDependency("advanced_toggle", "enable_advanced", function(v) return v == true end)

Dependencies:AddDivider({ Text = "MORE DEPENDENCIES" })

-- Difficulty selector
Dependencies:AddRadio({
    Id = "ai_difficulty",
    Name = "AI Difficulty",
    Options = {"Off", "Easy", "Hard"},
    Default = "Off",
})

-- These only show when AI is not off
Dependencies:AddSlider({
    Id = "ai_count",
    Name = "Number of AI",
    Min = 1,
    Max = 20,
    Default = 5,
})

Dependencies:AddCheckbox({
    Id = "ai_voice",
    Name = "AI Voice Chat",
    Default = false,
})

Dependencies:AddDependency("ai_count", "ai_difficulty", function(v) return v ~= "Off" end)
Dependencies:AddDependency("ai_voice", "ai_difficulty", function(v) return v ~= "Off" end)

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: DIALOGS & THEMES
-- ═══════════════════════════════════════════════════════════════════════════

local Dialogs = Win:AddTab({ Name = "Dialogs", Icon = "💬" })

Dialogs:AddSection("Modal Dialogs")

-- NEW: Confirm Dialog
Dialogs:AddButton({
    Name = "Show Confirm Dialog",
    ButtonText = "Confirm",
    Callback = function()
        Win:Confirm({
            Title = "Delete Account?",
            Message = "Are you sure you want to delete your account? This action cannot be undone.",
            ConfirmText = "Delete",
            CancelText = "Cancel",
            OnConfirm = function()
                Nexus:Notify({ Title = "Deleted", Message = "Account deleted", Type = "Success" })
            end,
            OnCancel = function()
                Nexus:Notify({ Title = "Cancelled", Message = "Action cancelled", Type = "Info" })
            end,
        })
    end,
})

-- NEW: Alert Dialog
Dialogs:AddButton({
    Name = "Show Alert Dialog",
    ButtonText = "Alert",
    Color = Color3.fromRGB(255, 182, 65),
    Callback = function()
        Win:Alert({
            Title = "Important Message",
            Message = "Your session will expire in 5 minutes. Please save your work.",
            ButtonText = "Got it!",
            OnClose = function()
                print("Alert dismissed")
            end,
        })
    end,
})

-- Custom dialog with multiple buttons
Dialogs:AddButton({
    Name = "Show Custom Dialog",
    ButtonText = "Custom",
    Color = Color3.fromRGB(150, 100, 255),
    Callback = function()
        Win:Confirm({
            Title = "Save Changes?",
            Message = "You have unsaved changes. What would you like to do?",
            Width = 380,
            Height = 160,
            ConfirmText = "Save",
            CancelText = "Don't Save",
            OnConfirm = function()
                Nexus:Notify({ Title = "Saved", Message = "Changes saved successfully", Type = "Success" })
            end,
            OnCancel = function()
                Nexus:Notify({ Title = "Discarded", Message = "Changes discarded", Type = "Warning" })
            end,
        })
    end,
})

Dialogs:AddDivider({ Text = "THEME SWITCHER" })

Dialogs:AddSection("Enhanced Themes")

Dialogs:AddLabel({
    Text = "NexusLib v0.6 includes 6 beautiful themes:\nDark, Light, Midnight, Rose, Ocean, Forest"
})

-- Theme buttons
local themes = {
    {name = "Dark", color = Color3.fromRGB(99, 157, 255)},
    {name = "Light", color = Color3.fromRGB(79, 130, 230)},
    {name = "Midnight", color = Color3.fromRGB(150, 100, 255)},
    {name = "Rose", color = Color3.fromRGB(240, 100, 148)},
    {name = "Ocean", color = Color3.fromRGB(65, 185, 230)},
    {name = "Forest", color = Color3.fromRGB(110, 200, 125)},
}

for _, theme in ipairs(themes) do
    Dialogs:AddButton({
        Name = theme.name .. " Theme",
        ButtonText = "Apply",
        Color = theme.color,
        Callback = function()
            Win:SetTheme(theme.name)
            Nexus:Notify({ 
                Title = "Theme Changed", 
                Message = "Switched to " .. theme.name .. " theme", 
                Type = "Success",
                Duration = 2
            })
        end,
    })
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: CLASSIC ELEMENTS (Still Available!)
-- ═══════════════════════════════════════════════════════════════════════════

local Classic = Win:AddTab({ Name = "Classic", Icon = "📦" })

Classic:AddSection("Original Elements")

Classic:AddLabel({
    Text = "All original NexusLib elements still work perfectly!"
})

Classic:AddToggle({
    Id = "classic_toggle",
    Name = "Toggle Example",
    Default = false,
    Tooltip = "Original toggle element",
    Callback = function(v) print("Toggle:", v) end,
})

Classic:AddSlider({
    Id = "classic_slider",
    Name = "Slider Example",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 5,
    Tooltip = "Original slider element",
    Callback = function(v) print("Slider:", v) end,
})

Classic:AddDropdown({
    Id = "classic_dropdown",
    Name = "Dropdown Example",
    Items = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Callback = function(v) print("Selected:", v) end,
})

Classic:AddMultiDropdown({
    Id = "classic_multi",
    Name = "Multi-Select",
    Items = {"Feature 1", "Feature 2", "Feature 3", "Feature 4"},
    Default = {"Feature 1", "Feature 2"},
    Callback = function(arr) print("Selected:", table.concat(arr, ", ")) end,
})

Classic:AddTextInput({
    Id = "username",
    Name = "Username",
    Placeholder = "Enter username...",
    Default = "Player123",
    Callback = function(text) print("Username:", text) end,
})

Classic:AddKeybind({
    Id = "jump_key",
    Name = "Jump Key",
    Default = Enum.KeyCode.Space,
    Tooltip = "Press to change jump key",
    OnPress = function() print("Jump!") end,
    Callback = function(key) print("Key changed to:", key.Name) end,
})

Classic:AddColorPicker({
    Id = "player_color",
    Name = "Player Color",
    Default = Color3.fromRGB(255, 100, 150),
    Callback = function(color) print("Color:", color) end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB: SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════

local Settings = Win:AddTab({ Name = "Settings", Icon = "⚙" })

Settings:AddSection("Configuration")

Settings:AddInfoBox({
    Type = "Info",
    Message = "Auto-save is enabled! Your settings are automatically saved every 30 seconds."
})

-- Config management panel
Settings:AddConfigPanel()

Settings:AddDivider({ Text = "NOTIFICATIONS" })

Settings:AddButton({
    Name = "Test Info Notification",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Info", Message = "This is an info notification", Type = "Info", Duration = 3 })
    end,
})

Settings:AddButton({
    Name = "Test Success Notification",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Success", Message = "Operation successful!", Type = "Success", Duration = 3 })
    end,
})

Settings:AddButton({
    Name = "Test Warning Notification",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Warning", Message = "Proceed with caution", Type = "Warning", Duration = 3 })
    end,
})

Settings:AddButton({
    Name = "Test Error Notification",
    ButtonText = "Send",
    Callback = function()
        Nexus:Notify({ Title = "Error", Message = "Something went wrong", Type = "Error", Duration = 3 })
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

Nexus:Notify({
    Title = "NexusLib v0.6",
    Message = "Enhanced version loaded! Press RightShift to toggle UI.",
    Type = "Success",
    Duration = 5,
})

print("NexusLib v0.6 Enhanced Demo loaded successfully!")
