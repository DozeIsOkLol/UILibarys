# Doze's Roblox UI Libraries Collection

A massive curated archive of **Roblox UI Libraries** (and related assets like notification systems) collected over time for exploit scripting, custom hubs, GUIs, and community preservation.

Currently contains **20+** UI libraries/frameworks + extras. (I have yet to upload all of them (200+))

## Why this repo exists

I started collecting these because many great UI libs disappear over time — repos get deleted, sources change, or creators stop maintaining them.  
This is an attempt to keep them accessible in one place for learning, testing, inspiration, or just nostalgia.

**Important:**  
Almost all libraries here are **publicly shared** works made by others.  
**Always credit** the original creators when using them in projects.  
Do **not** claim them as your own.

## 📂 Folder Structure

- **For UI makers/**  
  Helpful Things to make your own UI Library.
  
- **MadeByDoze/**  
  UI Librarys that are made by Doze (Me).

- **Notifications/**  
  Standalone notification systems & custom notifiers
  
- **UILibrarys/**  
  The main collection — individual folders for each UI library  
  (AquaLIB, AkiriLib, TwinkLib, DrawingUILib, BitchBotLib, AriesLib, etc.)

- **Utilitys/**
  Utilities, Scripts, etc.

## 📢 Important Notices

- Many libraries are **very old** or use **Drawing API** / **CoreGui** — behavior can differ across executors.
- Some may break due to:
  - Roblox updates
  - Original source changes/deletions
  - HttpGet restrictions or rate limits
- If a library doesn't load or looks broken → check console (F9) for errors, or try a different executor.
- Feel free to open an **issue** or DM me on Discord if something is missing/broken/wrongly credited.
- My discord is vampxity

## 🧩 Current Stats (approximate)

- **20+** UI libraries & variants
- **Multiple styles**: CoreGui-based, Drawing-based, modern/minimal, old-school cheat menus, anime-themed, etc.
- Constantly growing — new folders added regularly

**Last major update:** 6th March 2026

## 🚀 How to Use

### Quick loadstring example (most libraries)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarys/main/UILibrarys/AquaLIB/Source.lua"))()
