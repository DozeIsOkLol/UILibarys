# OxBlood UI Library

A sleek, dark Roblox UI library with a blood-red accent theme. Fully featured with notifications, keybinds, inputs, and more.

## 🩸 What Changed from Twink UI

### Visual Theme
- **Accent Color**: Deep blood red (RGB 160, 20, 40) instead of purple
- **Backgrounds**: Dark with subtle red tints throughout
  - Main frame: RGB(28, 22, 25)
  - Sidebar: RGB(18, 12, 15)
  - Components: Various shades with red undertones
- **Dividers**: Red-tinted grays instead of neutral grays
- **Section Headers**: Blood red instead of white
- **TopBar Button**: Dark red background with red accent text
- **Status Dot**: Blood red instead of green
- **Error Color**: Darker red (RGB 200, 30, 30)
- **Info Color**: Burgundy (RGB 120, 40, 60)

### Branding
- Library name: "OxBlood" instead of "Twink UI"
- ASCII art header updated
- Version: v1.0.0
- Default topbar letter: "O"

### Preserved Features
✅ All functionality maintained:
- Notification system (success, error, info, warn)
- Active tab indicator strip
- TopBar toggle button
- All UI components (Button, Label, Section, Input, Keybind, TextInfo, Dropdown, ColorPicker, Slider, Toggle)
- Same API and usage pattern
- Draggable window
- Minimize/maximize
- Search bars
- Player info panel

## 📦 Installation

```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/refs/heads/main/UILibrarys/OxBloodLib/v0.0.1/Source.lua"))()
```

## 🚀 Quick Start

```lua
local UI = UILibrary.Load("OxBlood", "Your Game", "v1.0", {
    Letter = "O",  -- Shows blood-red "O" in topbar
})

-- Create a page
local MainPage = UI.AddPage("Main")

-- Add a section divider
MainPage.AddSection("Combat")

-- Add a toggle
MainPage.AddToggle("Enable Feature", false, function(state)
    print("Feature:", state)
end)

-- Add a slider
MainPage.AddSlider("Speed", { Min = 1, Max = 100, Def = 50 }, function(value)
    print("Speed:", value)
end)

-- Send a notification
UI.Notify("Success", "Script loaded!", "success", 4)
```

## 🎨 Color Palette

| Element | RGB | Hex |
|---------|-----|-----|
| Accent (Blood Red) | 160, 20, 40 | #A01428 |
| Success | 0, 210, 100 | #00D264 |
| Error | 200, 30, 30 | #C81E1E |
| Info (Burgundy) | 120, 40, 60 | #78283C |
| Warning | 220, 100, 50 | #DC6432 |
| Main Background | 28, 22, 25 | #1C1619 |
| Sidebar | 18, 12, 15 | #120C0F |
| Components | 32, 22, 26 | #20161A |

## 📚 Full API Reference

### Initialize UI
```lua
UILibrary.Load(HubName, GameName, Version, TopBarConfig)
```
**Parameters:**
- `HubName` (string): Name of your hub (default: "OxBlood")
- `GameName` (string): Game name (default: "Unknown Game")
- `Version` (string): Version string (default: "v1.0")
- `TopBarConfig` (table, optional):
  - `{ Letter = "O" }` - Shows a letter in the topbar
  - `{ Image = "rbxassetid://..." }` - Shows an image
  - `nil` - No topbar button

### Notifications
```lua
UI.Notify(Title, Message, Type, Duration)
```
**Types:** `"success"`, `"error"`, `"info"`, `"warn"`

### Create Pages
```lua
local Page = UI.AddPage(PageTitle, SearchBarIncluded)
```

### Add Components

#### Button
```lua
Page.AddButton(Text, Callback)
```

#### Label
```lua
Page.AddLabel(Text)
```

#### Section (Divider)
```lua
Page.AddSection(Text)
```

#### Toggle
```lua
Page.AddToggle(Text, Default, Callback)
-- Callback receives: function(state) end
```

#### Slider
```lua
Page.AddSlider(Text, Config, Callback)
-- Config: { Min = 0, Max = 100, Def = 50 }
-- Callback receives: function(value) end
```

#### Dropdown
```lua
Page.AddDropdown(Text, Options, Callback)
-- Options: {"Option1", "Option2", "Option3"}
-- Callback receives: function(selected) end
```

#### Input Field
```lua
Page.AddInput(Text, Placeholder, Callback)
-- Callback receives: function(text, enterPressed) end
```

#### Keybind
```lua
Page.AddKeybind(Text, Default, Callback)
-- Default: Enum.KeyCode.RightShift
-- Callback fires when key is pressed OR when rebound
-- Callback receives: function(key) end
```

#### TextInfo (Live Label)
```lua
local Info = Page.AddTextInfo(InitialText)
-- Update it later:
Info.Set("New text here")
```

#### Color Picker
```lua
Page.AddColourPicker(Text, DefaultColour, Callback)
-- DefaultColour: Color3.fromRGB(255, 0, 0) or "red" or {255, 0, 0}
-- Callback receives: function(colour) end
```

## 🎯 Usage Examples

### Complete Script Template
```lua
local UILibrary = loadstring(game:HttpGet("YOUR_URL_HERE"))()

local UI = UILibrary.Load("OxBlood", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, "v1.0", {
    Letter = "O",
})

-- Home Tab
local Home = UI.AddPage("Home", false)
Home.AddSection("Welcome")
Home.AddLabel("OxBlood UI - Loaded successfully!")
Home.AddButton("Test Notification", function()
    UI.Notify("Test", "This is a test notification!", "info", 3)
end)

-- Combat Tab
local Combat = UI.AddPage("Combat")
Combat.AddSection("Aimbot")
Combat.AddToggle("Enable Aimbot", false, function(enabled)
    _G.AimbotEnabled = enabled
    UI.Notify("Aimbot", enabled and "Enabled" or "Disabled", 
        enabled and "success" or "warn", 2)
end)

Combat.AddSlider("FOV", { Min = 10, Max = 360, Def = 90 }, function(value)
    _G.AimbotFOV = value
end)

-- Settings Tab
local Settings = UI.AddPage("Settings")
Settings.AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(key)
    print("UI Keybind:", key)
end)

local StatusLabel = Settings.AddTextInfo("Status: Ready")
task.spawn(function()
    while task.wait(1) do
        StatusLabel.Set("Status: Running | Time: " .. os.date("%X"))
    end
end)

print("[OxBlood] Script loaded!")
```

## 🛠️ Features

### Notification System
- 4 types: success, error, info, warn
- Auto-dismiss with timer bar
- Click to dismiss
- Slide animations
- Top-right positioning

### Tab System
- Active tab indicator (2px blood-red strip)
- Smooth transitions
- Search functionality (optional per-page)
- Scrollable content

### TopBar Integration
- Mimics Roblox topbar style
- 36px button
- Letter or image mode
- Toggle UI visibility
- Hover effects

### Player Info Panel
- Avatar display
- Display name
- Blood-red status indicator
- Welcome message

### Draggable Window
- Click and drag title bar
- Smooth positioning
- Minimize/maximize button

## 🎨 Customization

All colors are defined at the top of the source:
```lua
local AccentColor    = Color3.fromRGB(160, 20, 40)    -- Main accent
local SuccessColor   = Color3.fromRGB(0,   210, 100)
local ErrorColor     = Color3.fromRGB(200,  30,  30)
local InfoColor      = Color3.fromRGB(120,  40,  60)
local WarnColor      = Color3.fromRGB(220, 100,  50)
```

Modify these to change the entire UI theme!

## 📝 Notes

- Designed for Roblox executors
- All functionality from the original Twink UI is preserved
- Optimized for performance with tweens
- Mobile-friendly (touch support)
- Studio-compatible for testing

## 🔗 Credits

Based on Twink UI v0.0.3, rebranded and restyled as OxBlood UI v1.0.0

---

**Made with 🩸 by [Your Name]**
