# Zen-Ware UI Library v1.0

> A modern, feature-rich UI library for Roblox scripts with peace of mind design and maximum functionality.

![Preview](Preview.png)

## ✨ Features

### 🎨 **Multi-Theme Support**
- **Zen Theme** (Default) - Peaceful teal/cyan accents with dark backgrounds
- **Ocean Theme** - Deep blue tones for a calming experience
- **Forest Theme** - Natural green theme for organic vibes
- **Sunset Theme** - Warm orange/pink colors for a cozy feel
- Switch themes dynamically with `UI.SetTheme("ThemeName")`

### 💾 **Configuration System**
- Automatic config saving/loading using flags
- Persistent settings across sessions
- Custom config file names
- Each element can have a unique flag for saving its state

### 🔒 **Ghost Mode**
- Anti-detection feature
- Randomizes GUI names to avoid script detection
- Enable with `GhostMode = true` option

### 🔔 **Notification System**
- Toast-style notifications in top-right corner
- 4 types: `success`, `error`, `info`, `warn`
- Auto-dismiss with custom duration
- Smooth slide-in/out animations

### 🎯 **UI Elements**
All the standard elements plus new additions:

**Standard:**
- Toggle switches with visual indicators
- Sliders with real-time value display
- Dropdowns with smooth expansion
- Color pickers with RGB sliders
- Buttons with hover effects
- Labels and text display
- Keybind configurators
- Input fields

**New in Zen-Ware:**
- `AddSection()` - Enhanced section headers with underlines
- `AddDivider()` - Thin separator lines
- `AddParagraph()` - Info blocks with title and body text
- `AddTextArea()` - Multi-line text input
- `AddTextInfo()` - Live-updatable read-only labels

### 🎭 **Design Features**
- Smooth animations with multiple easing styles
- Active tab indicator strip (2px accent bar)
- Search functionality on pages
- Draggable interface
- Topbar integration (Roblox topbar button)
- Drop shadows and rounded corners
- Responsive hover effects

---

## 📖 Quick Start

### Basic Usage

```lua
local UILibrary = loadstring(game:HttpGet("YOUR_URL_HERE"))()

-- Initialize UI
local UI = UILibrary.Load("Zen-Ware", "Game Name", "v1.0", {
    Letter = "Z",              -- Topbar button letter
    Theme = "Zen",             -- Initial theme
    SaveConfig = true,         -- Enable config saving
    ConfigName = "MyConfig",   -- Config file name
    GhostMode = false,         -- Anti-detection mode
})

-- Create a page
local MainPage = UI.AddPage("Main")

-- Add elements
MainPage.AddToggle("Feature", false, function(state)
    print("Feature:", state)
end, "FeatureFlag")  -- Last param is flag name for saving
```

---

## 🔧 API Reference

### Initialization

```lua
UILibrary.Load(Title, GameName, Version, Options)
```

**Options:**
- `Letter` - Single character for topbar button
- `Image` - rbxassetid for topbar button icon
- `Theme` - Initial theme ("Zen", "Ocean", "Forest", "Sunset")
- `SaveConfig` - Enable automatic config saving (boolean)
- `ConfigName` - Custom config file name (string)
- `GhostMode` - Enable anti-detection (boolean)

### Global Functions

```lua
UI.Notify(Title, Message, Type, Duration)
-- Type: "success", "error", "info", "warn"

UI.SetTheme(ThemeName)
-- ThemeName: "Zen", "Ocean", "Forest", "Sunset"
```

### Page Functions

```lua
UI.AddPage(PageName, HasSearch)
-- HasSearch: true/false, default true
```

### Element Functions

#### Labels & Info
```lua
Page.AddLabel(Text)
Page.AddSection(Text)  -- Bold text with underline
Page.AddDivider()      -- Thin separator line
Page.AddParagraph(Title, Text)  -- Info block
```

#### Interactive Elements
```lua
Page.AddButton(Text, Callback)

Page.AddToggle(Text, Default, Callback, FlagName)
-- Default: boolean, FlagName: string (optional)

Page.AddSlider(Text, Config, Callback, Parent, FlagName)
-- Config: { Min = 0, Max = 100, Def = 50 }

Page.AddDropdown(Text, Options, Callback, FlagName)
-- Options: {"Option1", "Option2", ...}

Page.AddColourPicker(Text, DefaultColor, Callback, FlagName)
-- DefaultColor: Color3 or {R, G, B} or "red"/"green"/etc

Page.AddInput(Text, Placeholder, Callback, FlagName)
-- Callback receives (text, enterPressed)

Page.AddTextArea(Text, Height, Callback, FlagName)
-- Height: number (default 80)

Page.AddKeybind(Text, DefaultKey, Callback, FlagName)
-- DefaultKey: Enum.KeyCode
```

#### Live Updates
```lua
local InfoLabel = Page.AddTextInfo(Text)
InfoLabel.Set("New text")  -- Update text dynamically
```

---

## 🎨 Theme Customization

Themes define the entire color scheme:

```lua
{
    Accent       -- Primary accent color
    AccentDark   -- Darker variant of accent
    AccentLight  -- Lighter variant of accent
    
    Background   -- Main background
    BackgroundLight -- Lighter background areas
    BackgroundDark  -- Darker background areas
    
    Card         -- Card/element background
    CardHover    -- Card hover state
    
    Text         -- Primary text color
    TextSecondary -- Secondary text color
    TextDim      -- Dimmed text
    
    Success      -- Success notification color
    Error        -- Error notification color
    Info         -- Info notification color
    Warn         -- Warning notification color
    
    Border       -- Border color
    Divider      -- Divider line color
}
```

---

## 💡 Usage Examples

### With Config Saving

```lua
-- Toggle with saved state
Page.AddToggle("Enable Feature", false, function(state)
    _G.FeatureEnabled = state
end, "MyFeature_Toggle")

-- Slider with saved value
Page.AddSlider("Speed", {Min = 1, Max = 10, Def = 5}, function(val)
    _G.Speed = val
end, nil, "MyFeature_Speed")

-- Input with saved text
Page.AddInput("Username", "Enter name...", function(text)
    _G.TargetUser = text
end, "MyFeature_Username")
```

### Dynamic Updates

```lua
local StatusLabel = Page.AddTextInfo("Status: Idle")

-- Update from anywhere
task.spawn(function()
    while task.wait(1) do
        StatusLabel.Set("Status: Active - " .. os.date("%H:%M:%S"))
    end
end)
```

### Theme Switching

```lua
Page.AddButton("Ocean Theme", function()
    UI.SetTheme("Ocean")
end)

Page.AddButton("Forest Theme", function()
    UI.SetTheme("Forest")
end)
```

---

## 📋 Changelog

### v1.0.0 (Based on TwinkLib v0.0.3)

#### ✨ New Features
- **Multi-theme system** with 4 built-in themes
- **Flag-based config system** for automatic saving/loading
- **Ghost mode** for anti-detection
- **Enhanced theming** with new Zen-inspired color schemes
- **AddDivider()** - Visual separator lines
- **AddParagraph()** - Info blocks with title + text
- **AddTextArea()** - Multi-line text input
- **Improved animations** - Smoother, more polished transitions
- **Better visual feedback** - Enhanced hover states

#### 🎨 Design Improvements
- New Zen-inspired color palette (teal/cyan accents)
- Better contrast and readability
- Refined spacing and padding
- Enhanced section headers with underlines
- Improved notification styling

#### 🔧 Technical Improvements
- Better code organization
- Centralized theme management
- Flag system for persistent settings
- Performance optimizations
- Ghost mode naming system

---

## 🔄 Migration from TwinkLib

If you're upgrading from TwinkLib v0.0.3:

**What stays the same:**
- All core element functions (AddToggle, AddSlider, etc.)
- Page system and navigation
- Notification system
- Keybind system
- Search functionality

**What's new:**
- Theme selection in Load options
- Flag parameters on all elements
- New AddDivider() and AddParagraph()
- AddTextArea() for multi-line input
- UI.SetTheme() for dynamic theme switching

**Simple upgrade:**
```lua
-- Old (TwinkLib)
local UI = UILibrary.Load("App", "Game", "v1.0", {Letter = "T"})

-- New (Zen-Ware)
local UI = UILibrary.Load("App", "Game", "v1.0", {
    Letter = "T",
    Theme = "Zen",        -- New
    SaveConfig = true,    -- New
})
```

---

## 🎯 Best Practices

1. **Use flags consistently** - Name flags clearly (e.g., "Combat_Aimbot", "Visual_ESP")
2. **Enable SaveConfig** - Let users keep their settings
3. **Choose appropriate themes** - Match your script's aesthetic
4. **Use sections** - Organize related features together
5. **Add descriptions** - Use AddParagraph() to explain features
6. **Provide feedback** - Use notifications for important events

---

## 📝 License

Free to use and modify. Credit appreciated but not required.

---

## 🙏 Credits

- **Original Base:** TwinkLib v0.0.3 by ???/Doze
- **Inspiration:** XanLib for advanced features
- **Enhanced by:** Zen-Ware Team

---

## 💬 Support

For issues, suggestions, or contributions, please open an issue on GitHub or join our Discord community.

**Enjoy building with Zen-Ware! ☯️**
