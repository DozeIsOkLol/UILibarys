# Custom Roblox UI Library v0.1.2

A modern, feature-rich Roblox UI library with dropdown tabs, smooth animations, extensive customization options, and advanced features.

## ✨ New in v0.1.2

🎨 **Color Picker** - RGB color selection with live preview  
📋 **Dropdown Selector** - Choose from multiple options  
📌 **Section Dividers** - Organize your UI better  
🔔 **Notification System** - In-game notifications with types  
💾 **Config System** - Save and load configurations  
🎭 **Theme System** - 5 built-in themes (Dark, Light, Ocean, Forest, Sunset)  
ℹ️ **Info Boxes** - Contextual help and tips  
📊 **Progress Bars** - Visual progress indicators  
🔘 **Multi-Toggle** - Radio button style selection  
🔍 **Auto-sizing** - Smart element sizing

## Features

✨ **Modern Design**
- Clean, dark-themed interface (with 4 additional themes)
- Smooth animations and transitions
- Ripple click effects
- Gradient accent lines

🎯 **Dropdown/Tab System**
- Multiple dropdown tabs per window
- Collapsible sections
- Automatic size management
- Smooth open/close animations

🛠️ **UI Elements**
- Buttons
- Toggles
- Sliders
- Labels
- Textboxes
- Keybinds
- **Color Pickers** ⭐ NEW
- **Dropdown Selectors** ⭐ NEW
- **Section Dividers** ⭐ NEW
- **Info Boxes** ⭐ NEW
- **Progress Bars** ⭐ NEW
- **Multi-Toggles** ⭐ NEW

⚡ **Advanced Features**
- Notification system with 4 types (Info, Success, Warning, Error)
- Config save/load system
- Theme management (5 themes)
- Performance optimized
- Flag system for config management

🎨 **Customizable**
- Easy color configuration
- Multiple pre-made themes
- Adjustable sizes
- Custom keybinds

## Installation

### Method 1: Direct Load (Recommended)
```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL_HERE"))()
```

### Method 2: Local Script
1. Copy the contents of `CustomUILib.lua`
2. Paste into your executor
3. Execute the script

## Quick Start

```lua
-- Load the library
local Library = loadstring(game:HttpGet("path/to/CustomUILib.lua"))()

-- Create a window
local Window = Library:CreateWindow("My UI", Enum.KeyCode.RightShift)

-- Create a dropdown/tab
local Tab = Window:CreateDropdown("Main")

-- Add elements
Tab:AddButton("Click Me", function()
    print("Button clicked!")
end)

Tab:AddToggle("Toggle Me", false, function(state)
    print("Toggle state:", state)
end)

Tab:AddSlider("Value", 0, 100, 50, function(value)
    print("Slider value:", value)
end)
```

## Documentation

### Creating a Window

```lua
Library:CreateWindow(windowName, toggleKey)
```

**Parameters:**
- `windowName` (string): The title of the window
- `toggleKey` (KeyCode): Key to toggle UI visibility (default: RightShift)

**Returns:** Window object

**Example:**
```lua
local Window = Library:CreateWindow("Custom UI", Enum.KeyCode.RightShift)
```

---

### Creating a Dropdown/Tab

```lua
Window:CreateDropdown(dropdownName)
```

**Parameters:**
- `dropdownName` (string): Name of the dropdown tab

**Returns:** Dropdown object

**Example:**
```lua
local CombatTab = Window:CreateDropdown("Combat")
local PlayerTab = Window:CreateDropdown("Player")
```

---

### Adding Elements

#### Button
```lua
Dropdown:AddButton(buttonName, callback)
```

**Parameters:**
- `buttonName` (string): Text displayed on the button
- `callback` (function): Function called when button is clicked

**Example:**
```lua
Tab:AddButton("Teleport", function()
    -- Your code here
end)
```

---

#### Toggle
```lua
Dropdown:AddToggle(toggleName, default, callback)
```

**Parameters:**
- `toggleName` (string): Text displayed next to toggle
- `default` (boolean): Initial state (default: false)
- `callback` (function): Function called when toggled, receives state (boolean)

**Example:**
```lua
Tab:AddToggle("Auto Farm", false, function(state)
    if state then
        print("Auto farm enabled")
    else
        print("Auto farm disabled")
    end
end)
```

---

#### Slider
```lua
Dropdown:AddSlider(sliderName, min, max, default, callback)
```

**Parameters:**
- `sliderName` (string): Text displayed above slider
- `min` (number): Minimum value (default: 0)
- `max` (number): Maximum value (default: 100)
- `default` (number): Initial value (default: min)
- `callback` (function): Function called when value changes, receives value (number)

**Example:**
```lua
Tab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

---

#### Label
```lua
Dropdown:AddLabel(text)
```

**Parameters:**
- `text` (string): Text to display

**Example:**
```lua
Tab:AddLabel("--- Settings ---")
```

---

#### Textbox
```lua
Dropdown:AddTextbox(placeholder, callback)
```

**Parameters:**
- `placeholder` (string): Placeholder text
- `callback` (function): Function called when Enter is pressed, receives text (string)

**Example:**
```lua
Tab:AddTextbox("Enter Player Name", function(text)
    print("Entered:", text)
end)
```

---

#### Keybind
```lua
Dropdown:AddKeybind(keybindName, defaultKey, callback)
```

**Parameters:**
- `keybindName` (string): Text displayed next to keybind
- `defaultKey` (KeyCode): Default key (default: E)
- `callback` (function): Function called when key is pressed, receives key (KeyCode)

**Example:**
```lua
Tab:AddKeybind("Fly", Enum.KeyCode.F, function(key)
    print("Fly activated with key:", key.Name)
end)
```

---

#### Color Picker ⭐ NEW
```lua
Dropdown:AddColorPicker(colorName, defaultColor, callback)
```

**Parameters:**
- `colorName` (string): Text displayed next to color picker
- `defaultColor` (Color3): Initial color (default: white)
- `callback` (function): Function called when color changes, receives color (Color3)

**Example:**
```lua
Tab:AddColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    print("New color selected:", color)
end)
```

**Features:**
- RGB sliders with live preview
- Visual color display
- Smooth popup animation

---

#### Dropdown Selector ⭐ NEW
```lua
Dropdown:AddDropdownSelector(selectorName, options, default, callback)
```

**Parameters:**
- `selectorName` (string): Text displayed next to selector
- `options` (table): Array of option strings
- `default` (string): Initial selected option (default: first option)
- `callback` (function): Function called when selection changes, receives option (string)

**Example:**
```lua
Tab:AddDropdownSelector("Game Mode", {"Easy", "Normal", "Hard", "Extreme"}, "Normal", function(mode)
    print("Selected mode:", mode)
end)
```

**Features:**
- Expandable dropdown menu
- Hover effects
- Smooth animations

---

#### Section ⭐ NEW
```lua
Dropdown:AddSection(sectionName)
```

**Parameters:**
- `sectionName` (string): Text displayed in section divider

**Example:**
```lua
Tab:AddSection("Combat Settings")
```

**Features:**
- Gradient divider line
- Centered text
- Auto-sizing

---

#### Info Box ⭐ NEW
```lua
Dropdown:AddInfoBox(infoText)
```

**Parameters:**
- `infoText` (string): Information or help text to display

**Example:**
```lua
Tab:AddInfoBox("This feature requires game pass. Make sure you have purchased it before enabling.")
```

**Features:**
- Auto-sizing based on text length
- Icon indicator
- Accent border
- Word wrapping

---

#### Progress Bar ⭐ NEW
```lua
Dropdown:AddProgressBar(barName, maxValue)
```

**Parameters:**
- `barName` (string): Text displayed above progress bar
- `maxValue` (number): Maximum value for progress (default: 100)

**Returns:** ProgressBar object with SetValue method

**Example:**
```lua
local Progress = Tab:AddProgressBar("Loading", 100)

-- Update progress
Progress:SetValue(50)  -- Sets to 50%
Progress:SetValue(100) -- Sets to 100%
```

**Methods:**
- `ProgressBar:SetValue(value)` - Updates progress with smooth animation

---

#### Multi-Toggle (Radio Buttons) ⭐ NEW
```lua
Dropdown:AddMultiToggle(multiName, options, default, callback)
```

**Parameters:**
- `multiName` (string): Text displayed above options
- `options` (table): Array of option strings
- `default` (string): Initially selected option (default: first option)
- `callback` (function): Function called when selection changes, receives option (string)

**Example:**
```lua
Tab:AddMultiToggle("Attack Mode", {"Single", "Multi", "AoE"}, "Single", function(mode)
    print("Attack mode changed to:", mode)
end)
```

**Features:**
- Radio button style selection
- Visual indicators
- Hover effects
- Only one option can be selected at a time

---

## Notification System ⭐ NEW

```lua
Library:Notify(title, message, duration, notifType)
```

**Parameters:**
- `title` (string): Notification title
- `message` (string): Notification message
- `duration` (number): How long to show notification in seconds (default: 3)
- `notifType` (string): Type of notification - "Info", "Success", "Warning", or "Error"

**Example:**
```lua
Library:Notify("Welcome!", "UI loaded successfully", 3, "Success")
Library:Notify("Warning", "This action cannot be undone", 4, "Warning")
Library:Notify("Error", "Failed to connect to server", 5, "Error")
```

**Features:**
- 4 notification types with different colors
- Slide-in/out animations
- Auto-dismiss after duration
- Non-intrusive positioning

---

## Theme System ⭐ NEW

```lua
Library:SetTheme(themeName)
```

**Available Themes:**
- `"Dark"` - Default dark theme (purple accent)
- `"Light"` - Light theme with blue accent
- `"Ocean"` - Blue ocean theme
- `"Forest"` - Green forest theme
- `"Sunset"` - Orange sunset theme

**Example:**
```lua
Library:SetTheme("Ocean")
Library:SetTheme("Forest")
Library:SetTheme("Sunset")
```

**Features:**
- Instant theme switching
- Affects all UI elements
- Notification on theme change

---

## Config System ⭐ NEW

### Save Configuration
```lua
Library:SaveConfig(configName)
```

**Parameters:**
- `configName` (string): Name for the config file (default: "default")

**Example:**
```lua
Library:SaveConfig("myconfig")
```

**Requires:** Executor with `writefile` support

---

### Load Configuration
```lua
Library:LoadConfig(configName)
```

**Parameters:**
- `configName` (string): Name of the config file to load (default: "default")

**Example:**
```lua
Library:LoadConfig("myconfig")
```

**Requires:** Executor with `readfile` and `isfile` support

**Note:** The config system automatically saves all values set with the flag system. Use `Library.ConfigData` to store custom values.

---

## Window Methods ⭐

### Destroy Window
```lua
Window:Destroy()
```

**Description:** Properly destroys the UI and cleans up all elements

**Example:**
```lua
local Window = Library:CreateWindow("My UI", Enum.KeyCode.RightShift)

-- Later, when you want to destroy the UI
Window:Destroy()
```

---

## Complete Example

```lua
local Library = loadstring(game:HttpGet("path/to/CustomUILib.lua"))()

-- Send welcome notification
Library:Notify("Welcome!", "UI loaded successfully", 3, "Success")

-- Create window
local Window = Library:CreateWindow("Game Hub", Enum.KeyCode.RightShift)

-- Combat Tab
local Combat = Window:CreateDropdown("Combat")
Combat:AddSection("Attack Settings")
Combat:AddButton("Kill All", function()
    Library:Notify("Combat", "Kill all activated", 2, "Info")
end)
Combat:AddToggle("Auto Attack", false, function(state)
    Library.ConfigData["AutoAttack"] = state
end)
Combat:AddSlider("Damage", 1, 100, 10, function(value)
    Library.ConfigData["Damage"] = value
end)
Combat:AddMultiToggle("Mode", {"Single", "Multi", "AoE"}, "Single", function(mode)
    print("Attack mode:", mode)
end)

-- Player Tab
local Player = Window:CreateDropdown("Player")
Player:AddSection("Movement")
Player:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
Player:AddSlider("Jump Power", 50, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)
Player:AddToggle("Infinite Jump", false, function(state)
    -- Infinite jump code
end)
Player:AddKeybind("Toggle Fly", Enum.KeyCode.E, function()
    Library:Notify("Player", "Fly toggled", 2, "Info")
end)

-- Visuals Tab
local Visuals = Window:CreateDropdown("Visuals")
Visuals:AddSection("ESP")
Visuals:AddToggle("ESP", false, function(state)
    -- ESP code
end)
Visuals:AddColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    Library:Notify("Visuals", "ESP color updated", 2, "Success")
end)
Visuals:AddToggle("Tracers", false, function(state)
    -- Tracers code
end)
Visuals:AddColorPicker("Tracer Color", Color3.fromRGB(0, 255, 0), function(color)
    -- Set tracer color
end)
Visuals:AddSlider("FOV", 70, 120, 70, function(value)
    workspace.CurrentCamera.FieldOfView = value
end)

-- Farm Tab
local Farm = Window:CreateDropdown("Auto Farm")
Farm:AddInfoBox("Configure your auto-farming settings below. Make sure to select the correct mode.")
Farm:AddToggle("Auto Farm", false, function(state)
    if state then
        Library:Notify("Farm", "Auto farm started", 2, "Success")
    else
        Library:Notify("Farm", "Auto farm stopped", 2, "Warning")
    end
end)
Farm:AddDropdownSelector("Mode", {"Coins", "Items", "XP", "Boss"}, "Coins", function(mode)
    Library:Notify("Farm", "Farm mode: " .. mode, 2, "Info")
end)

local Progress = Farm:AddProgressBar("Progress", 100)
-- Update progress with: Progress:SetValue(50)

-- Settings Tab
local Settings = Window:CreateDropdown("Settings")
Settings:AddSection("Theme")
Settings:AddDropdownSelector("Theme", {"Dark", "Light", "Ocean", "Forest", "Sunset"}, "Dark", function(theme)
    Library:SetTheme(theme)
end)

Settings:AddSection("Config")
local configName = ""
Settings:AddTextbox("Config Name", function(text)
    configName = text
end)
Settings:AddButton("Save Config", function()
    if configName ~= "" then
        Library:SaveConfig(configName)
    end
end)
Settings:AddButton("Load Config", function()
    if configName ~= "" then
        Library:LoadConfig(configName)
    end
end)
```

## Customization

You can customize colors by modifying the Config table in the library or by using the theme system:

### Using Pre-made Themes
```lua
Library:SetTheme("Ocean")  -- Switch to Ocean theme
Library:SetTheme("Forest") -- Switch to Forest theme
Library:SetTheme("Sunset") -- Switch to Sunset theme
```

### Custom Theme Configuration
```lua
local Config = {
    MainColor = Color3.fromRGB(35, 35, 35),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(120, 120, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(14, 255, 110),
    ToggleOff = Color3.fromRGB(255, 44, 44),
}
```

## Features Comparison

| Feature | 0x Library | Bacon Library | Custom v1.0 | Custom v2.0 |
|---------|-----------|---------------|-------------|-------------|
| Dropdown Tabs | ❌ | ✅ | ✅ | ✅ |
| Multiple Tabs | ❌ | ✅ | ✅ | ✅ |
| Color Picker | ❌ | ❌ | ❌ | ✅ |
| Dropdown Selector | ❌ | ✅ | ❌ | ✅ |
| Section Dividers | ❌ | ❌ | ❌ | ✅ |
| Notifications | ❌ | ✅ | ❌ | ✅ |
| Config System | ❌ | ❌ | ❌ | ✅ |
| Theme System | ❌ | ❌ | ❌ | ✅ |
| Info Boxes | ❌ | ❌ | ❌ | ✅ |
| Progress Bars | ❌ | ❌ | ❌ | ✅ |
| Multi-Toggle | ❌ | ❌ | ❌ | ✅ |
| Ripple Effects | ✅ | ❌ | ✅ | ✅ |
| Smooth Animations | ✅ | ✅ | ✅ | ✅ |
| Keybinds | ❌ | ✅ | ✅ | ✅ |
| Sliders | ✅ | ✅ | ✅ | ✅ |
| Textboxes | ❌ | ✅ | ✅ | ✅ |
| Modern Design | ✅ | ⚠️ | ✅ | ✅ |

## Credits

Inspired by:
- 0x UI Library (Design & Animations)
- BaconLib (Dropdown System)

Enhanced and expanded with custom features.

## Changelog

### v2.0.1 (Latest)
- 🐛 Fixed dropdown selectors appearing behind other UI elements (z-index issue)
- 🐛 Fixed theme system not updating existing UI elements when theme changes
- 🐛 Fixed destroy UI button not working
- ✅ Added Window:Destroy() method for proper UI cleanup
- ✅ Enhanced theme switching to update all elements in real-time

### v2.0
- ✅ Added Color Picker with RGB sliders
- ✅ Added Dropdown Selector for multiple options
- ✅ Added Section dividers for better organization
- ✅ Added Notification system (4 types)
- ✅ Added Config save/load system
- ✅ Added Theme system (5 themes)
- ✅ Added Info Boxes
- ✅ Added Progress Bars
- ✅ Added Multi-Toggle (Radio buttons)
- ✅ Improved auto-sizing
- ✅ Enhanced animations
- ✅ Better error handling

### v1.0
- ✅ Initial release
- ✅ Basic dropdown tabs
- ✅ Buttons, Toggles, Sliders, Labels, Textboxes, Keybinds
- ✅ Ripple effects
- ✅ Draggable windows
- ✅ Smooth animations

## FAQ

**Q: Does this require a specific executor?**  
A: Works with most executors. Config save/load requires `writefile`/`readfile` support.

**Q: Can I use this in my scripts?**  
A: Yes! Free to use and modify for your projects.

**Q: How do I change themes?**  
A: Use `Library:SetTheme("ThemeName")` - Available themes: Dark, Light, Ocean, Forest, Sunset

**Q: How do I save my settings?**  
A: Use `Library:SaveConfig("configname")` and `Library:LoadConfig("configname")`

**Q: Can I create custom themes?**  
A: Yes! Add your theme to `Library.Themes` table or modify the Config values directly.

**Q: The color picker isn't showing up?**  
A: Make sure you're clicking the color button. The picker opens as a popup.

## License

Free to use and modify for personal projects.

## Support

For issues or suggestions, please contact the developer or submit an issue on GitHub.

---

**Made with ❤️ for the Roblox scripting community**
