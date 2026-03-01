# 🚀 Nexus Loader - Quick Start Guide

Get up and running in 5 minutes!

---

## For Users

### Step 1: Execute the Loader
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/nexus-loader/main/NexusLoader.lua"))()
```

### Step 2: Wait for Loading
The loader will automatically:
- Check its status
- Load themes
- Detect your game
- Find the right script

### Step 3: Click Execute
Press the "EXECUTE SCRIPT" button and you're done!

---

## For Developers

### Step 1: Fork & Setup

1. **Fork this repository** to your GitHub account

2. **Upload config files** to your fork:
   ```
   config/
   ├── status.json
   ├── themes.json
   ├── whitelist.txt
   ├── changelog.json
   └── scripts.json
   ```

3. **Edit NexusLoader.lua** and replace URLs:
   ```lua
   RemoteConfig = {
       StatusURL = "https://raw.githubusercontent.com/YourUsername/nexus-loader/main/config/status.json",
       ThemeURL = "https://raw.githubusercontent.com/YourUsername/nexus-loader/main/config/themes.json",
       -- ... etc
   }
   ```

### Step 2: Add Your Scripts

Edit `config/scripts.json`:

```json
{
  "Name": "My Awesome Script",
  "GameId": 123456789,
  "PlaceId": 123456789,
  "URL": "https://raw.githubusercontent.com/YourUsername/my-scripts/main/myscript.lua",
  "Version": "1.0.0",
  "Description": "Does awesome things!"
}
```

### Step 3: Configure Settings

Edit `config/status.json`:
```json
{
  "Enabled": true,
  "Maintenance": false,
  "Message": "Welcome to my loader!"
}
```

### Step 4: Test It

1. Execute your loader
2. Verify it loads correctly
3. Test script execution
4. Check all features work

---

## Optional: Enable Whitelist

1. **Enable in config**:
   ```lua
   Security = {
       RequireWhitelist = true
   }
   ```

2. **Add users to whitelist.txt**:
   ```
   123456789
   987654321
   ```

3. **Upload and test**

---

## Optional: Customize Themes

1. **Edit themes.json**
2. **Modify RGB values** (0-255)
3. **Save and upload**
4. **Themes available immediately!**

---

## Troubleshooting

### Issue: "Failed to load status"
- **Fix**: Check StatusURL is correct and accessible
- **Verify**: Repository is public

### Issue: "Not whitelisted"
- **Fix**: Add your User ID to whitelist.txt
- **Or**: Disable whitelist system

### Issue: "No script found"
- **Fix**: Add game to scripts.json
- **Or**: Add universal script

---

## Quick Config Reference

```lua
-- Enable/Disable Features
Features = {
    AutoUpdate = true,        -- Auto check for updates
    Analytics = false,        -- Usage tracking
    DeveloperMode = false,    -- Debug logs
    SaveSettings = true,      -- Save user preferences
}

-- Security
Security = {
    RequireWhitelist = false, -- User access control
    RequireKeySystem = false, -- Key verification
    AntiTamper = true,        -- Protection
}

-- UI
UI = {
    AnimationSpeed = 0.5,     -- Animation duration
    NotificationDuration = 5,  -- Notification display time
    EnableSounds = true,       -- Sound effects
    EnableParticles = true,    -- Visual effects
}
```

---

## Need Help?

- 📚 Read the full [README.md](README.md)
- 💬 Join our Discord: [Link Here](#)
- 🐛 Report issues: [GitHub Issues](#)
- 📧 Contact: your-email@example.com

---

**That's it! You're ready to go! 🎉**
