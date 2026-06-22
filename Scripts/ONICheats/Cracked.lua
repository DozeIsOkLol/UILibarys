local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = nil
pcall(function()
	VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

local function ensureCamera()
	local cam = Workspace.CurrentCamera
	if cam then
		Camera = cam
	end
	return Camera
end

local LockStatusGui = nil
local lockStatusGuiLabel = nil

local function initLockHud()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
	if not playerGui then
		warn("[ONICheats] PlayerGui missing - HUD cannot show.")
		return false
	end

	local old = playerGui:FindFirstChild("ONICheats_LockStatus")
	if old then old:Destroy() end

	LockStatusGui = Instance.new("ScreenGui")
	LockStatusGui.Name = "ONICheats_LockStatus"
	LockStatusGui.ResetOnSpawn = false
	LockStatusGui.IgnoreGuiInset = true
	LockStatusGui.DisplayOrder = 10000000
	LockStatusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	LockStatusGui.Enabled = true
	LockStatusGui.Parent = playerGui

	lockStatusGuiLabel = Instance.new("TextLabel")
	lockStatusGuiLabel.Name = "ONI_LockStatus"
	lockStatusGuiLabel.Size = UDim2.new(0, 520, 0, 38)
	lockStatusGuiLabel.Position = UDim2.new(0.5, -260, 0, 6)
	lockStatusGuiLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	lockStatusGuiLabel.BackgroundTransparency = 0.05
	lockStatusGuiLabel.BorderSizePixel = 0
	lockStatusGuiLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	lockStatusGuiLabel.Font = Enum.Font.GothamBold
	lockStatusGuiLabel.TextSize = 16
	lockStatusGuiLabel.Text = "ONICheats loading..."
	lockStatusGuiLabel.Visible = true
	lockStatusGuiLabel.ZIndex = 10
	lockStatusGuiLabel.Parent = LockStatusGui
	Instance.new("UICorner", lockStatusGuiLabel).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(220, 20, 40)
	stroke.Thickness = 1.5
	stroke.Parent = lockStatusGuiLabel
	return true
end

local function setLockHud(text, visible)
	if type(Settings) ~= "table" or type(Settings.Aim) ~= "table" or not Settings.Aim.ShowLockHud then
		if LockStatusGui then
			LockStatusGui.Enabled = false
		end
		return
	end
	if not lockStatusGuiLabel or not lockStatusGuiLabel.Parent then
		initLockHud()
	end
	if LockStatusGui then
		LockStatusGui.Enabled = true
	end
	if lockStatusGuiLabel then
		lockStatusGuiLabel.Text = text or ""
		lockStatusGuiLabel.Visible = visible ~= false
	end
end

local hasFileSystem = (writefile and readfile and isfile)
local LOGO_FILE_NAME = "ONICheats_Logo.png"
local CONFIG_FILE = "ONICheats_Config.json"
local CONFIG_FILE_LEGACY = "DevSuite_Config.json"
local CONFIG_DIR = "ONICheats_Configs"
local CONFIG_INDEX_FILE = "ONICheats_ConfigIndex.json"
local AUTOLOAD_FLAG_FILE = "ONICheats_AutoLoad.txt"

local ConfigNameInputRef = nil
local ConfigStatusLabelRef = nil
local ConfigListLabelRef = nil
local ConfigDropdownBtnRef = nil
local ConfigDropdownListRef = nil
local ConfigDropdownLayoutFn = nil
local savedConfigNames = {}
local configDropdownOpen = false
local defaultGravity = Workspace.Gravity
local LogoImageRef = nil
local MenuKeyBtnRef = nil

local function notify(title, text, duration)
	duration = duration or 4
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = tostring(title),
			Text = tostring(text),
			Duration = duration,
		})
	end)
end

local function protectGui(gui)
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, gui)
	elseif protectgui then
		pcall(protectgui, gui)
	end
end

local BindToastGui = nil
local BindToastFrame = nil
local BindToastLabel = nil
local bindToastToken = 0

local function initBindToast()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
	if not playerGui then
		return false
	end

	local old = playerGui:FindFirstChild("ONICheats_BindToast")
	if old then
		old:Destroy()
	end

	BindToastGui = Instance.new("ScreenGui")
	BindToastGui.Name = "ONICheats_BindToast"
	BindToastGui.ResetOnSpawn = false
	BindToastGui.IgnoreGuiInset = true
	BindToastGui.DisplayOrder = 10000001
	BindToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	BindToastGui.Enabled = true
	BindToastGui.Parent = playerGui

	BindToastFrame = Instance.new("Frame")
	BindToastFrame.Name = "Toast"
	BindToastFrame.Size = UDim2.new(0, 300, 0, 46)
	BindToastFrame.Position = UDim2.new(0.5, -150, 0, 52)
	BindToastFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	BindToastFrame.BackgroundTransparency = 0.05
	BindToastFrame.BorderSizePixel = 0
	BindToastFrame.Visible = false
	BindToastFrame.ZIndex = 20
	BindToastFrame.Parent = BindToastGui
	Instance.new("UICorner", BindToastFrame).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke")
	stroke.Name = "ToastStroke"
	stroke.Color = Color3.fromRGB(220, 20, 40)
	stroke.Thickness = 1.5
	stroke.Transparency = 0
	stroke.Parent = BindToastFrame

	BindToastLabel = Instance.new("TextLabel")
	BindToastLabel.Size = UDim2.new(1, -16, 1, 0)
	BindToastLabel.Position = UDim2.new(0, 8, 0, 0)
	BindToastLabel.BackgroundTransparency = 1
	BindToastLabel.Font = Enum.Font.GothamBold
	BindToastLabel.TextSize = 16
	BindToastLabel.TextTransparency = 0
	BindToastLabel.ZIndex = 21
	BindToastLabel.Text = ""
	BindToastLabel.Parent = BindToastFrame

	return true
end

local function showBindToggleToast(featureName, enabled)
	pcall(function()
		if not BindToastFrame or not BindToastLabel or not BindToastGui.Parent then
			if not initBindToast() then
				notify("ONICheats", featureName .. ": " .. (enabled and "ENABLED" or "DISABLED"), 3)
				return
			end
		end

		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui and BindToastGui.Parent ~= playerGui then
			BindToastGui.Parent = playerGui
		end
		BindToastGui.Enabled = true

		bindToastToken = bindToastToken + 1
		local token = bindToastToken

		local stateText = enabled and "ENABLED" or "DISABLED"
		local accent = enabled and Color3.fromRGB(70, 220, 110) or Color3.fromRGB(220, 70, 70)
		BindToastLabel.Text = featureName .. ": " .. stateText
		BindToastLabel.TextColor3 = accent
		BindToastLabel.TextTransparency = 0
		BindToastFrame.BackgroundTransparency = 0.05
		BindToastFrame.Visible = true

		local stroke = BindToastFrame:FindFirstChild("ToastStroke")
		if stroke then
			stroke.Color = accent
			stroke.Transparency = 0
		end

		task.delay(2, function()
			if bindToastToken ~= token or not BindToastFrame then
				return
			end
			BindToastFrame.Visible = false
		end)
	end)
end

local function showActionToast(message, accentColor)
	pcall(function()
		if not BindToastFrame or not BindToastLabel or not BindToastGui.Parent then
			if not initBindToast() then
				notify("ONICheats", tostring(message), 3)
				return
			end
		end

		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui and BindToastGui.Parent ~= playerGui then
			BindToastGui.Parent = playerGui
		end
		BindToastGui.Enabled = true

		bindToastToken = bindToastToken + 1
		local token = bindToastToken

		local accent = accentColor or Color3.fromRGB(220, 20, 40)
		BindToastLabel.Text = tostring(message)
		BindToastLabel.TextColor3 = accent
		BindToastLabel.TextTransparency = 0
		BindToastFrame.BackgroundTransparency = 0.05
		BindToastFrame.Visible = true

		local stroke = BindToastFrame:FindFirstChild("ToastStroke")
		if stroke then
			stroke.Color = accent
			stroke.Transparency = 0
		end

		task.delay(2, function()
			if bindToastToken ~= token or not BindToastFrame then
				return
			end
			BindToastFrame.Visible = false
		end)
	end)
end

task.spawn(initBindToast)

local Settings = {
	Aim = {
		Enabled = false,
		Keybind = Enum.UserInputType.MouseButton2,
		Smoothness = 0.25,
		FOV = 150,
		ShowFOV = true,
		WallCheck = true,
		TeamCheck = true,
		TargetMode = "FOV",
		LockMode = "Hold",
		AutoSwitch = true,
		TargetPart = "Head",
		Prediction = 0,
		SilentAim = false,
		SnapOnLock = true,
		StickyLock = true,
		AimMethod = "Auto",
		SilentAimMode = "On Shoot",
		UseScreenCenter = true,
		FreeMouseOnLock = false,
		AimWhileShooting = true,
		FreezeAimWhileShooting = true,
		ShootingAimScale = 0.2,
		ShootingMaxStep = 2,
		ShowLockHud = true,
		AutoShootEnabled = false,
		AutoShootMode = "On Lock",
		AutoShootFireMode = "Tap",
		AutoShootInterval = 0.1,
		AutoShootWallCheck = true,
		TriggerbotEnabled = false,
		TriggerbotRadius = 20,
		TriggerbotDelay = 0.05,
		TriggerbotWallCheck = true,
		GunOnlyShoot = false,
		VelocityResolver = false,
		ResolverStrength = 1,
		CrosshairEnabled = false,
		CrosshairSize = 8,
		CrosshairColor = Color3.fromRGB(255, 255, 255),
		FOVColor = Color3.fromRGB(220, 20, 40),
	},
	ESP = {
		CharmsEnabled = false,
		TeamVisible = false,
		Color = Color3.fromRGB(220, 20, 40),
		TeamColorEnabled = false,
		EnemyColor = Color3.fromRGB(220, 20, 40),
		TeamColor = Color3.fromRGB(80, 160, 255),
		BoxESP = false,
		NameESP = false,
		Tracers = false,
		ShowDistance = false,
		SkeletonESP = false,
		ESPMode = "Auto",
	},
	Movement = {
		SpeedEnabled = false,
		SpeedValue = 16,
		JumpEnabled = false,
		JumpValue = 50,
		FlyEnabled = false,
		FlySpeed = 50,
		NoclipEnabled = false,
		InfiniteJump = false,
		GravityEnabled = false,
		GravityValue = 196.2,
	},
	Misc = {
		FpsCounter = true,
		Fullbright = false,
		NoFog = false,
		AntiAFK = false,
		MenuKeybind = Enum.KeyCode.Insert,
		LogoAssetId = "",
		LogoFileName = "ONICheats_Logo.png",
		AutoLoadConfig = true,
		UnlockMouseOnMenu = true,
		TopMostUI = true,
		StreamProof = false,
		Whitelist = {},
		HitNotifyLock = false,
		HitNotifyShot = false,
	},
	Troll = {
		FlingPower = 500000,
		OrbitSpeed = 6,
		OrbitRadius = 10,
		ConstantFling = false,
		OrbitTarget = false,
		HeadSit = false,
		SpinTroll = false,
		Invisible = false,
	},
	Binds = {
		AimToggle = false,
		NoclipToggle = false,
		FlyToggle = false,
		EspToggle = false,
		PanicKey = false,
		TriggerbotToggle = false,
	},
}

local ONI_GUI_NAMES = {"ONICheatsUI", "ONICheats_ESP", "ONICheats_LockStatus", "ONICheats_BindToast"}
local SETTING_DEFAULTS = {}
local logoWarnShown = false

do
	for cat, sub in pairs(Settings) do
		if type(sub) == "table" then
			SETTING_DEFAULTS[cat] = {}
			for k, v in pairs(sub) do
				if typeof(v) == "Color3" then
					SETTING_DEFAULTS[cat][k] = Color3.new(v.R, v.G, v.B)
				elseif type(v) == "table" then
					local t = {}
					for ik, iv in ipairs(v) do
						t[ik] = iv
					end
					SETTING_DEFAULTS[cat][k] = t
				else
					SETTING_DEFAULTS[cat][k] = v
				end
			end
		end
	end
end

local function fillMissingSettings()
	for cat, sub in pairs(SETTING_DEFAULTS) do
		if type(Settings[cat]) ~= "table" then
			Settings[cat] = {}
		end
		for k, v in pairs(sub) do
			if Settings[cat][k] == nil then
				if typeof(v) == "Color3" then
					Settings[cat][k] = Color3.new(v.R, v.G, v.B)
				elseif type(v) == "table" then
					local t = {}
					for ik, iv in ipairs(v) do
						t[ik] = iv
					end
					Settings[cat][k] = t
				else
					Settings[cat][k] = v
				end
			end
		end
	end
end

local function applyLogoImage(imageLabel)
	if not imageLabel then return false end

	if Settings.Misc.LogoAssetId and Settings.Misc.LogoAssetId ~= "" then
		imageLabel.Image = "rbxassetid://" .. tostring(Settings.Misc.LogoAssetId)
		imageLabel.Visible = true
		return true
	end

	local fileName = Settings.Misc.LogoFileName or LOGO_FILE_NAME
	if getcustomasset and isfile and isfile(fileName) then
		local ok, asset = pcall(getcustomasset, fileName)
		if ok and asset then
			imageLabel.Image = asset
			imageLabel.Visible = true
			return true
		end
	end

	imageLabel.Visible = false
	return false
end

local isAming = false
local isShooting = false
local shotTargetPlayer = nil
local shotTargetExpire = 0
local pendingLockCFrame = nil
local lockIndicator = nil
local cameraLockActive = false
local savedAimMouseState = nil
local aimLockSavedSubject = nil
local aimLockSavedCameraType = nil
local suppressedCameraScripts = {}
local lastMouseMove = Vector2.zero
local mouseApiName = "unknown"
local toggleActive = false
local characterScanCache = {}
local lastCharacterScan = 0
local currentTargetPlayer = nil
local lastAimTargetPlayer = nil
local aimRuntimeConnection = nil
local lastAimErrX = 0
local lastAimErrY = 0
local AIM_MAX_STEP = 14
local AIM_PULL_FRACTION = 0.68
local savedCameraType = nil
local lockGraceTimer = 0
local LOCK_GRACE_TIME = 0.2
local fovCircle = nil
local crosshairDrawings = {}
local velocityHistory = {}
local lastTriggerbotAt = 0
local scriptActive = true
local runtimeConnections = {}
local savedMetamethodHooks = {}
local refreshWhitelistSection = nil
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local MainFrame = nil
local MenuShell = nil
local ScreenGui = nil
local Containers = nil
local espDrawings = {}
local espWorld = {}
local EspScreen = nil
local lastEspFullScan = 0
local lastEspRenderAt = 0
local espSystemActive = false
local lastMouseDriverRefreshAt = 0
local ESP_PLAYER_RESCAN_INTERVAL = 0.5
local ESP_RENDER_INTERVAL = 1 / 30
local menuOpen = false
local KeybindCaptureActive = false
local savedMouseState = nil
local mouseUnlockConnection = nil
local trollTargetIndex = 1
local trollTargetLabel = nil
local spectating = false
local spectateTarget = nil
local originalCameraSubject = nil
local originalCameraType = nil
local flingVelocity = nil
local flingAngular = nil
local spinGyro = nil
local SKELETON_LINE_COUNT = 18
local SKELETON_BONES = {
	{"Head", "UpperTorso"}, {"Head", "Torso"},
	{"UpperTorso", "LowerTorso"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}
local defaultLighting = {
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
}

local UIComponents = {Toggles = {}, Sliders = {}, Selectors = {}}

if Drawing then
	fovCircle = Drawing.new("Circle")
	fovCircle.Color = Settings.Aim.FOVColor
	fovCircle.Thickness = 1
	fovCircle.NumSides = 64
	fovCircle.Filled = false
	fovCircle.Transparency = 0.5
	fovCircle.Visible = false
end


local function getConfigFilePath()
	if not hasFileSystem then return CONFIG_FILE end
	if isfile(CONFIG_FILE) then return CONFIG_FILE end
	if isfile(CONFIG_FILE_LEGACY) then return CONFIG_FILE_LEGACY end
	return CONFIG_FILE
end

local function sanitizeConfigName(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[^%w%-%_ ]", "")
	name = name:gsub("%s+", "_")
	if name == "" then
		return nil
	end
	if #name > 32 then
		name = name:sub(1, 32)
	end
	return name
end

local function getNamedConfigPath(name)
	local safeName = sanitizeConfigName(name)
	if not safeName then
		return nil
	end
	return CONFIG_DIR .. "/" .. safeName .. ".json"
end

local function ensureConfigDir()
	if not hasFileSystem then
		return
	end
	if makefolder then
		pcall(makefolder, CONFIG_DIR)
	end
end

local function isAutoLoadEnabled()
	if not hasFileSystem then
		return false
	end
	if isfile(AUTOLOAD_FLAG_FILE) then
		return readfile(AUTOLOAD_FLAG_FILE) == "true"
	end
	return Settings.Misc.AutoLoadConfig
end

local function setAutoLoadEnabled(enabled)
	Settings.Misc.AutoLoadConfig = enabled
	if hasFileSystem then
		pcall(function()
			writefile(AUTOLOAD_FLAG_FILE, enabled and "true" or "false")
		end)
	end
end

local function getConfigIndex()
	local defaultIndex = {
		active = "Default",
		gameProfiles = {},
		configs = {},
	}
	if not hasFileSystem or not isfile(CONFIG_INDEX_FILE) then
		return defaultIndex
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_INDEX_FILE))
	end)
	if ok and type(data) == "table" then
		data.active = data.active or defaultIndex.active
		data.gameProfiles = data.gameProfiles or {}
		data.configs = data.configs or {}
		return data
	end
	return defaultIndex
end

local function saveConfigIndex(index)
	if not hasFileSystem then
		return
	end
	pcall(function()
		writefile(CONFIG_INDEX_FILE, HttpService:JSONEncode(index))
	end)
end

local function registerConfigName(index, name)
	local safeName = sanitizeConfigName(name)
	if not safeName then
		return nil
	end
	local found = false
	for _, existing in ipairs(index.configs) do
		if existing == safeName then
			found = true
			break
		end
	end
	if not found then
		table.insert(index.configs, safeName)
	end
	index.active = safeName
	saveConfigIndex(index)
	return safeName
end

local function getCurrentGameProfileKeys()
	local keys = {tostring(game.PlaceId)}
	local gameKey = tostring(game.Name):lower():gsub("[^%w]+", "_")
	if gameKey ~= "" then
		table.insert(keys, gameKey)
	end
	return keys
end

local function serializeConfigValue(val)
	if typeof(val) == "EnumItem" then
		return {Type = tostring(val.EnumType), Name = val.Name}
	end
	if typeof(val) == "Color3" then
		return {val.R, val.G, val.B}
	end
	return val
end

local function isSerializedColor3(val)
	return typeof(val) == "table"
		and type(val[1]) == "number"
		and type(val[2]) == "number"
		and type(val[3]) == "number"
		and val[4] == nil
		and val.Name == nil
		and val.Type == nil
		and val[1] >= 0 and val[1] <= 1
		and val[2] >= 0 and val[2] <= 1
		and val[3] >= 0 and val[3] <= 1
end

local function deserializeConfigEnum(val)
	if typeof(val) ~= "table" or not val.Name then
		return nil
	end
	local enumTypeName = tostring(val.Type or ""):gsub("^Enum%.", "")
	if enumTypeName == "" or not Enum[enumTypeName] then
		return nil
	end
	local ok, enumItem = pcall(function()
		return Enum[enumTypeName][val.Name]
	end)
	return ok and enumItem or nil
end

local function buildConfigPayload()
	local payload = {}
	for category, subTable in pairs(Settings) do
		if type(subTable) == "table" then
			payload[category] = {}
			for key, val in pairs(subTable) do
				payload[category][key] = serializeConfigValue(val)
			end
		end
	end
	return payload
end

local function syncUIAfterConfigLoad()
	if not UIComponents then
		return
	end
	for _, comp in pairs(UIComponents.Toggles) do
		local path = comp.Path
		if Settings[path[1]] and Settings[path[1]][path[2]] ~= nil then
			comp.Toggle(Settings[path[1]][path[2]])
		end
	end
	for _, comp in pairs(UIComponents.Sliders) do
		local path = comp.Path
		if Settings[path[1]] and Settings[path[1]][path[2]] ~= nil then
			comp.Update(Settings[path[1]][path[2]])
		end
	end
	for _, comp in pairs(UIComponents.Selectors) do
		local path = comp.Path
		if Settings[path[1]] and Settings[path[1]][path[2]] ~= nil then
			comp.Update(Settings[path[1]][path[2]])
		end
	end
	if refreshAllCharms then refreshAllCharms() end
	if updateESP then updateESP() end
	if updateFlyState then updateFlyState(Settings.Movement.FlyEnabled) end
	if updateLightingState then updateLightingState() end
	if updateInvisibleState then updateInvisibleState() end
	if updateTrollTargetLabel then updateTrollTargetLabel() end
	if LogoImageRef then applyLogoImage(LogoImageRef) end
	if MenuKeyBtnRef and Settings.Misc.MenuKeybind then
		MenuKeyBtnRef.Text = Settings.Misc.MenuKeybind.Name
	end
	if UIComponents.Toggles["Auto Load Config"] then
		UIComponents.Toggles["Auto Load Config"].Toggle(Settings.Misc.AutoLoadConfig)
	end
	setAutoLoadEnabled(Settings.Misc.AutoLoadConfig)
	if refreshLockHud then refreshLockHud() end
	if refreshWhitelistSection then refreshWhitelistSection() end
	if fovCircle and Settings.Aim.FOVColor then
		fovCircle.Color = Settings.Aim.FOVColor
	end
	if updateCrosshairOverlay then updateCrosshairOverlay() end
	if ScreenGui then applyTopMostUI(ScreenGui) end
	if UIComponents.BindKeys then
		for _, comp in pairs(UIComponents.BindKeys) do
			local path = comp.Path
			if Settings[path[1]] and Settings[path[1]][path[2]] ~= nil then
				comp.Update(Settings[path[1]][path[2]])
			else
				comp.Update(false)
			end
		end
	end
end

local function formatBindLabel(bind)
	if bind == false or bind == nil or typeof(bind) ~= "EnumItem" then
		return "None"
	end
	if bind == Enum.UserInputType.MouseButton1 then
		return "Left Click"
	end
	if bind == Enum.UserInputType.MouseButton2 then
		return "Right Click"
	end
	if bind == Enum.UserInputType.MouseButton3 then
		return "Middle Click"
	end
	return bind.Name
end

local function inputMatchesBind(input, bind)
	if bind == false or bind == nil or typeof(bind) ~= "EnumItem" then
		return false
	end
	if bind.EnumType == Enum.KeyCode then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind
	end
	if bind.EnumType == Enum.UserInputType then
		return input.UserInputType == bind
	end
	return false
end

local function syncToggleFromBind(label, state)
	local comp = UIComponents and UIComponents.Toggles and UIComponents.Toggles[label]
	if comp then
		comp.Toggle(state)
	end
end

local function handleFeatureBindToggles(input)
	if menuOpen or KeybindCaptureActive then
		return
	end
	local binds = Settings.Binds
	if type(binds) ~= "table" then
		return
	end

	if inputMatchesBind(input, binds.AimToggle) then
		Settings.Aim.Enabled = not Settings.Aim.Enabled
		syncToggleFromBind("Enable Aimbot", Settings.Aim.Enabled)
		if refreshLockHud then refreshLockHud() end
		showBindToggleToast("Aimbot", Settings.Aim.Enabled)
		return
	end
	if inputMatchesBind(input, binds.NoclipToggle) then
		Settings.Movement.NoclipEnabled = not Settings.Movement.NoclipEnabled
		syncToggleFromBind("Noclip", Settings.Movement.NoclipEnabled)
		if not Settings.Movement.NoclipEnabled and LocalPlayer.Character and setNoclipState then
			setNoclipState(LocalPlayer.Character, false)
		end
		showBindToggleToast("Noclip", Settings.Movement.NoclipEnabled)
		return
	end
	if inputMatchesBind(input, binds.FlyToggle) then
		Settings.Movement.FlyEnabled = not Settings.Movement.FlyEnabled
		syncToggleFromBind("Fly Mode", Settings.Movement.FlyEnabled)
		if updateFlyState then updateFlyState(Settings.Movement.FlyEnabled) end
		showBindToggleToast("Fly", Settings.Movement.FlyEnabled)
		return
	end
	if inputMatchesBind(input, binds.EspToggle) then
		Settings.ESP.CharmsEnabled = not Settings.ESP.CharmsEnabled
		syncToggleFromBind("Enable Charms", Settings.ESP.CharmsEnabled)
		if refreshAllCharms then refreshAllCharms() end
		if updateESP then updateESP() end
		showBindToggleToast("Charms ESP", Settings.ESP.CharmsEnabled)
		return
	end
	if inputMatchesBind(input, binds.TriggerbotToggle) then
		Settings.Aim.TriggerbotEnabled = not Settings.Aim.TriggerbotEnabled
		syncToggleFromBind("Triggerbot", Settings.Aim.TriggerbotEnabled)
		showBindToggleToast("Triggerbot", Settings.Aim.TriggerbotEnabled)
		return
	end
end

local function applyConfigData(data)
	if type(Settings.Misc) ~= "table" then
		Settings.Misc = {}
	end
	for category, subTable in pairs(data) do
		if type(Settings[category]) == "table" and type(subTable) == "table" then
			for key, val in pairs(subTable) do
				if isSerializedColor3(val) then
					Settings[category][key] = Color3.new(val[1], val[2], val[3])
				else
					local enumItem = deserializeConfigEnum(val)
					if enumItem then
						Settings[category][key] = enumItem
					else
						Settings[category][key] = val
					end
				end
			end
		end
	end
	fillMissingSettings()
	if type(Settings.Misc.Whitelist) ~= "table" then
		Settings.Misc.Whitelist = {}
	end
	local ok, syncErr = pcall(syncUIAfterConfigLoad)
	if not ok then
		warn("[ONICheats] Config UI sync error: " .. tostring(syncErr))
	end
	if refreshLockHud then refreshLockHud() end
end

local function listSavedConfigs()
	local index = getConfigIndex()
	local names = {}
	local seen = {}
	for _, name in ipairs(index.configs) do
		local path = getNamedConfigPath(name)
		if path and isfile(path) and not seen[name] then
			table.insert(names, name)
			seen[name] = true
		end
	end
	local listFn = listfiles or (syn and syn.list_files)
	if listFn then
		pcall(function()
			local files = listFn(CONFIG_DIR)
			if type(files) == "table" then
				for _, filePath in ipairs(files) do
					local fileName = tostring(filePath):match("([^/\\]+)%.json$")
					if fileName and not seen[fileName] then
						table.insert(names, fileName)
						seen[fileName] = true
					end
				end
			end
		end)
	end
	table.sort(names)
	return names
end

local function populateConfigDropdown(selectName)
	if not ConfigDropdownListRef then
		return
	end
	for _, child in ipairs(ConfigDropdownListRef:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	savedConfigNames = listSavedConfigs()
	for i, name in ipairs(savedConfigNames) do
		local item = Instance.new("TextButton")
		item.Name = "ConfigItem_" .. name
		item.Size = UDim2.new(1, -4, 0, 24)
		item.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		item.Text = name
		item.TextColor3 = Color3.fromRGB(255, 255, 255)
		item.Font = Enum.Font.GothamMedium
		item.TextSize = 11
		item.AutoButtonColor = true
		item.LayoutOrder = i
		item.Parent = ConfigDropdownListRef
		Instance.new("UICorner", item).CornerRadius = UDim.new(0, 3)
		item.MouseButton1Click:Connect(function()
			if ConfigNameInputRef then
				ConfigNameInputRef.Text = name
			end
			if ConfigDropdownBtnRef then
				ConfigDropdownBtnRef.Text = name
			end
			configDropdownOpen = false
			if ConfigDropdownListRef then
				ConfigDropdownListRef.Visible = false
			end
			if ConfigDropdownLayoutFn then
				ConfigDropdownLayoutFn(false)
			end
			refreshSavedConfigList(name)
		end)
	end

	local layout = ConfigDropdownListRef:FindFirstChildOfClass("UIListLayout")
	if layout then
		ConfigDropdownListRef.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
	end

	if selectName and ConfigDropdownBtnRef then
		ConfigDropdownBtnRef.Text = selectName
	elseif ConfigDropdownBtnRef then
		if selectName == nil and ConfigDropdownBtnRef.Text == "" then
			ConfigDropdownBtnRef.Text = #savedConfigNames > 0 and savedConfigNames[1] or "Select profile..."
		end
	end
end

local function refreshSavedConfigList(selectName)
	savedConfigNames = listSavedConfigs()
	populateConfigDropdown(selectName)

	local activeName = selectName
	if not activeName and ConfigDropdownBtnRef and ConfigDropdownBtnRef.Text ~= "Select profile..." then
		activeName = ConfigDropdownBtnRef.Text
	end
	if not activeName and #savedConfigNames > 0 then
		activeName = savedConfigNames[1]
	end

	if ConfigNameInputRef and selectName then
		ConfigNameInputRef.Text = selectName
	elseif ConfigNameInputRef and ConfigNameInputRef.Text == "" and activeName then
		ConfigNameInputRef.Text = activeName
	end

	if ConfigListLabelRef then
		if #savedConfigNames == 0 then
			ConfigListLabelRef.Text = "No saved profiles yet"
		else
			ConfigListLabelRef.Text = #savedConfigNames .. " saved profile" .. (#savedConfigNames == 1 and "" or "s")
				.. (activeName and ("  •  " .. activeName) or "")
		end
	end
end

local function getConfigNameFromInput()
	if ConfigNameInputRef and ConfigNameInputRef.Text ~= "" then
		return ConfigNameInputRef.Text
	end
	local index = getConfigIndex()
	return index.active
end

local function saveNamedConfiguration(name)
	if not hasFileSystem then
		return "Executor Missing File Functions"
	end
	local safeName = sanitizeConfigName(name)
	if not safeName then
		return "Enter a config name"
	end

	local success, err = pcall(function()
		ensureConfigDir()
		local payload = buildConfigPayload()
		writefile(getNamedConfigPath(safeName), HttpService:JSONEncode(payload))
		local index = getConfigIndex()
		registerConfigName(index, safeName)
		setAutoLoadEnabled(Settings.Misc.AutoLoadConfig)
	end)

	if success then
		refreshSavedConfigList(safeName)
		return "Saved: " .. safeName
	end
	return "Save Failed: " .. tostring(err)
end

local function loadNamedConfiguration(name)
	if not hasFileSystem then
		return "Executor Missing File Functions"
	end
	local safeName = sanitizeConfigName(name)
	if not safeName then
		return "Enter a config name"
	end
	local configPath = getNamedConfigPath(safeName)
	if not configPath or not isfile(configPath) then
		return "Config not found: " .. safeName
	end

	local success, err = pcall(function()
		local rawData = readfile(configPath)
		local data = HttpService:JSONDecode(rawData)
		applyConfigData(data)
		local index = getConfigIndex()
		index.active = safeName
		saveConfigIndex(index)
	end)

	if success then
		refreshSavedConfigList(safeName)
		if ConfigNameInputRef then
			ConfigNameInputRef.Text = safeName
		end
		return "Loaded: " .. safeName
	end
	return "Load Error: " .. tostring(err)
end

local function deleteNamedConfiguration(name)
	if not hasFileSystem then
		return "Executor Missing File Functions"
	end
	local safeName = sanitizeConfigName(name)
	if not safeName then
		return "Enter a config name"
	end
	local configPath = getNamedConfigPath(safeName)
	if not configPath or not isfile(configPath) then
		return "Config not found: " .. safeName
	end

	local success, err = pcall(function()
		if delfile then
			delfile(configPath)
		else
			writefile(configPath, "{}")
		end
		local index = getConfigIndex()
		for i = #index.configs, 1, -1 do
			if index.configs[i] == safeName then
				table.remove(index.configs, i)
			end
		end
		for key, linkedName in pairs(index.gameProfiles) do
			if linkedName == safeName then
				index.gameProfiles[key] = nil
			end
		end
		if index.active == safeName then
			index.active = index.configs[1] or "Default"
		end
		saveConfigIndex(index)
	end)

	if success then
		refreshSavedConfigList()
		return "Deleted: " .. safeName
	end
	return "Delete Failed: " .. tostring(err)
end

local function linkConfigToCurrentGame(name)
	local safeName = sanitizeConfigName(name)
	if not safeName then
		return "Enter a config name"
	end
	local index = getConfigIndex()
	for _, key in ipairs(getCurrentGameProfileKeys()) do
		index.gameProfiles[key] = safeName
	end
	registerConfigName(index, safeName)
	return "Linked \"" .. safeName .. "\" to " .. game.Name
end

local function getAutoLoadConfigName()
	local index = getConfigIndex()
	for _, key in ipairs(getCurrentGameProfileKeys()) do
		local linked = index.gameProfiles[key]
		local linkedPath = linked and getNamedConfigPath(linked)
		if linkedPath and isfile(linkedPath) then
			return linked
		end
	end
	local activePath = index.active and getNamedConfigPath(index.active)
	if activePath and isfile(activePath) then
		return index.active
	end
	return nil
end

local function setConfigStatus(text, color)
	if not ConfigStatusLabelRef then
		return
	end
	ConfigStatusLabelRef.Text = text
	ConfigStatusLabelRef.TextColor3 = color or Color3.fromRGB(150, 150, 155)
end

local function saveConfiguration()
	if not hasFileSystem then
		return "Executor Missing File Functions"
	end
	local name = getConfigNameFromInput() or "Default"
	local msg = saveNamedConfiguration(name)
	if msg:find("^Saved:") then
		local success, err = pcall(function()
			writefile(CONFIG_FILE, readfile(getNamedConfigPath(sanitizeConfigName(name))))
		end)
		if success then
			return "Saved Successfully!"
		end
		return msg
	end
	return msg
end

local function loadConfiguration()
	if not hasFileSystem then
		return "Executor Missing File Functions"
	end
	local name = getConfigNameFromInput()
	if name then
		local namedPath = getNamedConfigPath(name)
		if namedPath and isfile(namedPath) then
			return loadNamedConfiguration(name)
		end
	end
	local configPath = getConfigFilePath()
	if not isfile(configPath) then
		return "No Saved Config Found"
	end

	local success, err = pcall(function()
		local rawData = readfile(configPath)
		local data = HttpService:JSONDecode(rawData)
		applyConfigData(data)
	end)

	return success and "Loaded Successfully!" or "Load Error: " .. tostring(err)
end

local function autoLoadConfiguration()
	if not hasFileSystem then
		return false
	end

	local index = getConfigIndex()
	for _, key in ipairs(getCurrentGameProfileKeys()) do
		local linked = index.gameProfiles[key]
		local linkedPath = linked and getNamedConfigPath(linked)
		if linkedPath and isfile(linkedPath) then
			local msg = loadNamedConfiguration(linked)
			if msg:find("^Loaded:") then
				notify("ONICheats", "Auto-loaded linked config: " .. linked)
				return true
			end
		end
	end

	if not isAutoLoadEnabled() then
		return false
	end

	local named = index.active
	local activePath = named and getNamedConfigPath(named)
	if activePath and isfile(activePath) then
		local msg = loadNamedConfiguration(named)
		if msg:find("^Loaded:") then
			notify("ONICheats", "Auto-loaded config: " .. named)
			return true
		end
	end

	local msg = loadConfiguration()
	if msg == "Loaded Successfully!" or msg:find("^Loaded:") then
		notify("ONICheats", "Config auto-loaded on startup.")
		return true
	end
	return false
end

local updateESP
local applyFPSPreset
local refreshLockHud
local cacheShotTarget
local acquireAimTarget
local disableAllFeatures
local unloadONICheats
local updateCrosshairOverlay
local refreshMouseDriver
local isPlayerWhitelisted
local applyTopMostUI
local setMenuMouseState
local getTargetPart
local getCharacterRoot
local getCharacterHead
local getAimHitParts

local function trackConnection(conn)
	if conn then
		table.insert(runtimeConnections, conn)
	end
	return conn
end

local function initGpCore()

local AIM_PART_FALLBACKS = {
	Head = {"Head", "HeadHB", "HitboxHead", "UpperTorso", "Torso", "HumanoidRootPart"},
	HumanoidRootPart = {"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Root"},
	UpperTorso = {"UpperTorso", "Torso", "Chest", "HumanoidRootPart", "Head"},
}

local CHARACTER_FOLDER_NAMES = {
	"Characters", "Live", "Players", "Entities", "Alive", "PlayerModels", "Rivals",
	"Orange", "Blue", "TeamOrange", "TeamBlue", "InGame", "Match",
}

getTargetPart = function(character)
	if not character then return nil end
	local preferred = Settings.Aim.TargetPart
	local fallbacks = AIM_PART_FALLBACKS[preferred] or {preferred}
	for _, name in ipairs(fallbacks) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return character:FindFirstChildWhichIsA("BasePart", true)
end

local MouseDriver = {name = "NONE", moveRel = nil, moveAbs = nil}
local mouseGlobalsScanned = false

local function lookupGlobalFunction(...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		local fn = rawget(_G, name)
		if type(fn) == "function" then
			return fn, name
		end
	end
	if getgenv then
		local ok, env = pcall(getgenv)
		if ok and type(env) == "table" then
			for i = 1, select("#", ...) do
				local name = select(i, ...)
				if type(env[name]) == "function" then
					return env[name], "getgenv." .. name
				end
			end
		end
	end
	if syn then
		for i = 1, select("#", ...) do
			local name = select(i, ...)
			if type(syn[name]) == "function" then
				return syn[name], "syn." .. name
			end
		end
	end
	return nil, nil
end

local function lookupInputMouseMove()
	local tables = {}
	if type(Input) == "table" then
		table.insert(tables, {tbl = Input, prefix = "Input"})
	end
	if type(input) == "table" then
		table.insert(tables, {tbl = input, prefix = "input"})
	end
	if getgenv then
		local ok, env = pcall(getgenv)
		if ok and type(env) == "table" then
			if type(env.Input) == "table" then
				table.insert(tables, {tbl = env.Input, prefix = "getgenv.Input"})
			end
			if type(env.input) == "table" then
				table.insert(tables, {tbl = env.input, prefix = "getgenv.input"})
			end
		end
	end

	for _, entry in ipairs(tables) do
		local moveFn = entry.tbl.MouseMove or entry.tbl.move or entry.tbl.Move
		if type(moveFn) == "function" then
			local key = entry.tbl.MouseMove and "MouseMove" or (entry.tbl.move and "move" or "Move")
			return moveFn, entry.prefix .. "." .. key
		end
	end
	return nil, nil
end

local function scanMouseGlobalsOnce()
	if mouseGlobalsScanned then
		return
	end
	mouseGlobalsScanned = true
end

refreshMouseDriver = function()
	scanMouseGlobalsOnce()
	MouseDriver.name = "NONE"
	MouseDriver.moveRel = nil
	MouseDriver.moveAbs = nil

	pcall(function()
		if type(mousemoverel) == "function" and not MouseDriver.moveRel then
			MouseDriver.moveRel = mousemoverel
			MouseDriver.name = "mousemoverel"
		end
		if type(mousemoveabs) == "function" and not MouseDriver.moveAbs then
			MouseDriver.moveAbs = mousemoveabs
		end
	end)

	local relFn, relName = lookupGlobalFunction(
		"mousemoverel", "mouse_move_relative", "MouseMoveRelative",
		"MouseMoveRel", "mouse_move_rel", "mousereco"
	)
	if relFn then
		MouseDriver.moveRel = relFn
		MouseDriver.name = relName
	end

	if not MouseDriver.moveRel then
		local inputMove, inputMoveName = lookupInputMouseMove()
		if inputMove then
			MouseDriver.moveRel = inputMove
			MouseDriver.name = inputMoveName
		end
	end

	local absFn, absName = lookupGlobalFunction("mousemoveabs", "MouseMoveAbs", "mouse_move_absolute")
	if absFn then
		MouseDriver.moveAbs = absFn
		if MouseDriver.name == "NONE" then
			MouseDriver.name = absName
		end
	end

	if input and type(input.move) == "function" then
		MouseDriver.moveRel = MouseDriver.moveRel or input.move
		if MouseDriver.name == "NONE" then
			MouseDriver.name = "input.move"
		end
	end

	if not MouseDriver.moveRel and VirtualInputManager then
		MouseDriver.name = "VIM"
		MouseDriver.moveRel = function(ix, iy)
			local pos = UserInputService:GetMouseLocation()
			pcall(function()
				VirtualInputManager:SendMouseMoveEvent(pos.X + ix, pos.Y + iy, game)
			end)
		end
		MouseDriver.moveAbs = function(x, y)
			pcall(function()
				VirtualInputManager:SendMouseMoveEvent(x, y, game)
			end)
		end
	end

	mouseApiName = MouseDriver.name
end

refreshMouseDriver()

local function hasMouseMoveRel()
	refreshMouseDriver()
	return MouseDriver.moveRel ~= nil
end

local function mouseMoveRel(dx, dy)
	if math.abs(dx) < 0.5 and math.abs(dy) < 0.5 then
		return
	end
	local ix = math.floor(dx + 0.5)
	local iy = math.floor(dy + 0.5)
	if ix == 0 and math.abs(dx) >= 1 then
		ix = dx > 0 and 1 or -1
	end
	if iy == 0 and math.abs(dy) >= 1 then
		iy = dy > 0 and 1 or -1
	end
	if ix == 0 and iy == 0 then
		return
	end
	lastMouseMove = Vector2.new(ix, iy)
	if tick() - lastMouseDriverRefreshAt > 3 then
		refreshMouseDriver()
		lastMouseDriverRefreshAt = tick()
	end
	if MouseDriver.moveRel then
		pcall(MouseDriver.moveRel, ix, iy)
	end
end

local function mouseMoveAbsScreen(screenX, screenY)
	local inset = GuiService:GetGuiInset()
	local absY = screenY + inset.Y
	refreshMouseDriver()
	if MouseDriver.moveAbs then
		pcall(MouseDriver.moveAbs, screenX, absY)
	end
end

local function isMouseButtonHeld(button)
	if UserInputService:IsMouseButtonPressed(button) then
		return true
	end
	for _, pressed in ipairs(UserInputService:GetMouseButtonsPressed()) do
		if pressed == button then
			return true
		end
	end
	return false
end

local function syncAimKeyState()
	if Settings.Aim.LockMode == "Always On" then
		isAming = true
		return
	end
	if Settings.Aim.LockMode == "Toggle" then
		return
	end

	local bind = Settings.Aim.Keybind
	if typeof(bind) ~= "EnumItem" then
		return
	end

	if bind.EnumType == Enum.KeyCode then
		isAming = UserInputService:IsKeyDown(bind)
		return
	end

	if bind.EnumType == Enum.UserInputType then
		local held = isMouseButtonHeld(bind)
		if Settings.Aim.AimWhileShooting then
			held = held or isMouseButtonHeld(Enum.UserInputType.MouseButton1) or isShooting
		end
		isAming = held
	end
end

local function isAimKeyHeld()
	syncAimKeyState()
	local bind = Settings.Aim.Keybind
	if typeof(bind) ~= "EnumItem" then
		return isAming
	end
	if bind.EnumType == Enum.KeyCode then
		return UserInputService:IsKeyDown(bind) or isAming
	end
	if bind.EnumType == Enum.UserInputType then
		local held = isMouseButtonHeld(bind) or isAming
		if Settings.Aim.AimWhileShooting then
			held = held or isMouseButtonHeld(Enum.UserInputType.MouseButton1) or isShooting
		end
		return held
	end
	return isAming
end

local function getAimPoint2D()
	if not ensureCamera() then
		return Vector2.new(0, 0)
	end
	if Settings.Aim.UseScreenCenter then
		local viewport = Camera.ViewportSize
		return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	end
	return UserInputService:GetMouseLocation()
end

local function isFiringWeapon()
	if isMouseButtonHeld(Enum.UserInputType.MouseButton1) then
		return true
	end
	return isShooting
end

local function scanWorkspaceCharacters()
	local now = tick()
	if now - lastCharacterScan < 0.75 then
		return
	end
	lastCharacterScan = now
	characterScanCache = {}

	local function registerModel(model)
		if not model or not model:IsA("Model") then return end
		if not model:FindFirstChildWhichIsA("BasePart", true) then return end

		local owner = Players:GetPlayerFromCharacter(model)
		if owner then
			characterScanCache[owner] = model
			return
		end

		local namedPlayer = Players:FindFirstChild(model.Name)
		if namedPlayer and namedPlayer:IsA("Player") then
			characterScanCache[namedPlayer] = model
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			registerModel(Workspace:FindFirstChild(player.Name))
			registerModel(Workspace:FindFirstChild(player.DisplayName))
		end
	end

	for _, child in ipairs(Workspace:GetChildren()) do
		registerModel(child)
		if child:IsA("Folder") or child:IsA("Model") then
			for _, folderName in ipairs(CHARACTER_FOLDER_NAMES) do
				local folder = child:FindFirstChild(folderName)
				if folder then
					for _, model in ipairs(folder:GetChildren()) do
						registerModel(model)
					end
				end
			end
			for _, sub in ipairs(child:GetChildren()) do
				if sub:IsA("Model") and sub:FindFirstChildOfClass("Humanoid") then
					registerModel(sub)
				end
			end
		end
	end
end

local function invalidateCharacterCache(player)
	if player then
		characterScanCache[player] = nil
	end
end

getCharacterRoot = function(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character.PrimaryPart
		or character:FindFirstChildWhichIsA("BasePart")
end

local function isCharacterAlive(character, player)
	if not character or not character.Parent then
		return false
	end
	if player and player.Character and player.Character ~= character then
		local liveRoot = getCharacterRoot(player.Character)
		if player.Character.Parent and liveRoot then
			return false
		end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if humanoid.Health <= 0 then
			return false
		end
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return false
		end
		return true
	end
	if getCharacterRoot(character) then
		return true
	end
	return false
end

local function isLikelyFFA()
	local myTeam = LocalPlayer.Team
	if not myTeam then
		return true
	end
	local others = 0
	local sameTeam = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			others = others + 1
			if player.Team == myTeam then
				sameTeam = sameTeam + 1
			end
		end
	end
	return others > 0 and sameTeam == others
end

local function passesTeamFilter(player)
	if not Settings.Aim.TeamCheck then
		return true
	end
	if not player.Team or not LocalPlayer.Team then
		return true
	end
	if player.Team ~= LocalPlayer.Team then
		return true
	end
	return isLikelyFFA()
end

isPlayerWhitelisted = function(player)
	if not player or type(Settings.Misc.Whitelist) ~= "table" then
		return false
	end
	local pid = player.UserId
	for _, uid in ipairs(Settings.Misc.Whitelist) do
		if uid == pid or tonumber(uid) == pid then
			return true
		end
	end
	return false
end

local function shouldSkipPlayer(player)
	if not player or player == LocalPlayer then
		return true
	end
	return isPlayerWhitelisted(player)
end

local function hasGunEquipped()
	local char = LocalPlayer.Character
	if not char then
		return false
	end
	return char:FindFirstChildWhichIsA("Tool") ~= nil
end

local function canUseShootFeatures()
	if not Settings.Aim.GunOnlyShoot then
		return true
	end
	return hasGunEquipped()
end

local function getEspColorForPlayer(player)
	if Settings.ESP.TeamColorEnabled and player.Team and LocalPlayer.Team then
		if player.Team == LocalPlayer.Team then
			return Settings.ESP.TeamColor
		end
		return Settings.ESP.EnemyColor
	end
	return Settings.ESP.Color
end

local function isStreamProofActive()
	return Settings.Misc.StreamProof == true
end

local function shouldDrawPlayer(player)
	if player == LocalPlayer then return false end
	if shouldSkipPlayer(player) then return false end
	if Settings.ESP.TeamVisible then
		return true
	end
	if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
		if isLikelyFFA() then
			return true
		end
		return false
	end
	return true
end

local function getPlayerCharacter(player)
	if not player then
		return nil
	end

	local liveChar = player.Character
	if liveChar and liveChar.Parent then
		local liveRoot = getCharacterRoot(liveChar)
		if liveRoot and isCharacterAlive(liveChar, player) then
			characterScanCache[player] = liveChar
			return liveChar
		end
	end

	scanWorkspaceCharacters()

	local cached = characterScanCache[player]
	if cached and cached.Parent and getCharacterRoot(cached) and isCharacterAlive(cached, player) then
		if not liveChar or cached == liveChar then
			return cached
		end
		invalidateCharacterCache(player)
	end

	local char = liveChar
	if char and char.Parent and getCharacterRoot(char) then
		return char
	end

	local function acceptCharacter(model)
		return model
			and model:IsA("Model")
			and model:FindFirstChildWhichIsA("BasePart", true)
			and getCharacterRoot(model)
			and isCharacterAlive(model, player)
	end

	char = Workspace:FindFirstChild(player.Name)
	if acceptCharacter(char) then
		characterScanCache[player] = char
		return char
	end

	for _, folderName in ipairs(CHARACTER_FOLDER_NAMES) do
		local folder = Workspace:FindFirstChild(folderName)
		if folder then
			char = folder:FindFirstChild(player.Name)
			if acceptCharacter(char) then
				characterScanCache[player] = char
				return char
			end
		end
	end

	for _, child in ipairs(Workspace:GetChildren()) do
		if acceptCharacter(child) and child.Name == player.Name then
			characterScanCache[player] = child
			return child
		end
		if child:IsA("Folder") then
			char = child:FindFirstChild(player.Name)
			if acceptCharacter(char) then
				characterScanCache[player] = char
				return char
			end
		end
	end

	return nil
end

local function getAimCharacter(player)
	if not player then
		return nil
	end
	return getPlayerCharacter(player)
end

getCharacterHead = function(character)
	if not character then return nil end
	return character:FindFirstChild("Head")
		or character:FindFirstChild("HeadHB")
		or character:FindFirstChild("HitboxHead")
		or character:FindFirstChild("FakeHead")
		or character:FindFirstChild("UpperTorso")
		or getCharacterRoot(character)
end

local AIM_HIT_PARTS = {"Head", "UpperTorso", "HumanoidRootPart", "Torso", "LowerTorso"}

getAimHitParts = function(char, deep)
	if not char then
		return {}
	end
	local parts = {}
	local seen = {}
	local function add(p)
		if p and p:IsA("BasePart") and not seen[p] then
			seen[p] = true
			table.insert(parts, p)
		end
	end
	add(getTargetPart(char))
	add(getCharacterHead(char))
	add(getCharacterRoot(char))
	for _, name in ipairs(AIM_HIT_PARTS) do
		add(char:FindFirstChild(name))
	end
	if deep then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and (part.Name == "Head" or part.Name:find("Torso", 1, true) or part.Name == "HumanoidRootPart") then
				add(part)
			end
		end
	end
	return parts
end

local function mountEspHighlight(char, color, data, fillTransparency)
	local highlight = data.Highlight
	if highlight and highlight.Adornee ~= char then
		highlight:Destroy()
		highlight = nil
	end
	if not highlight or not highlight.Parent then
		if highlight then highlight:Destroy() end
		highlight = Instance.new("Highlight")
		highlight.Name = "ONI_HighlightESP"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		data.Highlight = highlight
	end
	highlight.Adornee = char
	highlight.FillColor = color
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = fillTransparency
	highlight.OutlineTransparency = 0
	highlight.Enabled = true

	local mounted = false
	pcall(function()
		highlight.Parent = game:GetService("CoreGui")
		mounted = true
	end)
	if not mounted then
		pcall(function()
			highlight.Parent = char
		end)
	end
end

local function destroyEspInstance(data, key)
	local inst = data[key]
	if inst then
		pcall(function()
			inst:Destroy()
		end)
		data[key] = nil
	end
end

local function purgeStaleEspPlayers()
	local active = {}
	for _, player in ipairs(Players:GetPlayers()) do
		active[player] = true
	end
	for player in pairs(espWorld) do
		if not active[player] then
			cleanupWorldEsp(player)
		end
	end
	for player in pairs(espDrawings) do
		if not active[player] then
			cleanupPlayerDrawings(player)
		end
	end
end

local function refreshEspPlayerRegistry()
	local now = tick()
	if now - lastEspFullScan < ESP_PLAYER_RESCAN_INTERVAL then
		return
	end
	lastEspFullScan = now
	lastCharacterScan = 0
	scanWorkspaceCharacters()
	purgeStaleEspPlayers()
end

local function isAnyEspEnabled()
	return Settings.ESP.CharmsEnabled
		or Settings.ESP.BoxESP
		or Settings.ESP.NameESP
		or Settings.ESP.Tracers
		or Settings.ESP.ShowDistance
		or Settings.ESP.SkeletonESP
end

local function shouldUseDrawingEsp()
	if Settings.ESP.ESPMode == "Drawing" or Settings.ESP.ESPMode == "Both" then
		return Drawing ~= nil
	end
	if Settings.ESP.ESPMode == "Auto" then
		return Drawing ~= nil
	end
	return false
end

local function shouldUseWorldEsp()
	return Settings.ESP.ESPMode == "World3D"
		or Settings.ESP.ESPMode == "Both"
		or Settings.ESP.ESPMode == "Auto"
end

local function getEspScreen()
	if EspScreen and EspScreen.Parent then return EspScreen end

	EspScreen = Instance.new("ScreenGui")
	EspScreen.Name = "ONICheats_ESP"
	EspScreen.ResetOnSpawn = false
	EspScreen.IgnoreGuiInset = true
	EspScreen.DisplayOrder = 999998
	EspScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	EspScreen.Enabled = true
	EspScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")

	if Settings.Misc.TopMostUI and not isStreamProofActive() and gethui then
		local ok, hui = pcall(gethui)
		if ok and hui then
			pcall(function()
				EspScreen.Parent = hui
			end)
		end
	end
	protectGui(EspScreen)
	return EspScreen
end

local function hideAllDrawingEsp()
	for player in pairs(espDrawings) do
		hidePlayerDrawings(player)
	end
end

local function hideWorldEsp(player)
	local data = espWorld[player]
	if not data then return end
	if data.Highlight then
		data.Highlight.Enabled = false
	end
	if data.Box then
		data.Box.Visible = false
	end
	if data.Billboard then
		data.Billboard.Enabled = false
	end
	if data.TracerAtt0 then
		data.TracerAtt0.Visible = false
	end
	if data.TracerAtt1 then
		data.TracerAtt1.Visible = false
	end
end

local function cleanupWorldEsp(player)
	hideWorldEsp(player)
	local data = espWorld[player]
	if not data then return end
	for key, inst in pairs(data) do
		if key == "TracerAtt0" or key == "TracerAtt1" then
			if inst and inst.Parent then inst:Destroy() end
		elseif inst and inst.Parent then
			inst:Destroy()
		end
	end
	espWorld[player] = nil
end

local function hideAllWorldEsp()
	for player in pairs(espWorld) do
		cleanupWorldEsp(player)
	end
end

local function getOrCreateWorldEsp(player)
	if not espWorld[player] then
		espWorld[player] = {}
	end
	return espWorld[player]
end

local function updateWorldESP()
	if not ensureCamera() then return end
	local espScreen = getEspScreen()
	local anyEspEnabled = Settings.ESP.BoxESP or Settings.ESP.NameESP or Settings.ESP.Tracers
		or Settings.ESP.ShowDistance or Settings.ESP.CharmsEnabled
	if not anyEspEnabled then
		hideAllWorldEsp()
		return
	end

	local localChar = getPlayerCharacter(LocalPlayer)
	local localRoot = localChar and getCharacterRoot(localChar)

	for _, player in ipairs(Players:GetPlayers()) do
		if not shouldDrawPlayer(player) then
			cleanupWorldEsp(player)
			continue
		end

		local char = getPlayerCharacter(player)
		local root = char and getCharacterRoot(char)
		local head = char and getCharacterHead(char)
		if not char or not root or not isCharacterAlive(char, player) then
			cleanupWorldEsp(player)
			invalidateCharacterCache(player)
			continue
		end

		local color = getEspColorForPlayer(player)
		local data = getOrCreateWorldEsp(player)

		if Settings.ESP.CharmsEnabled then
			mountEspHighlight(char, color, data, Settings.ESP.BoxESP and 0.55 or 0.35)
		else
			destroyEspInstance(data, "Highlight")
		end

		if Settings.ESP.BoxESP then
			if not data.Box or not data.Box.Parent or data.Box.Parent ~= root then
				if data.Box then data.Box:Destroy() end
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "ONI_BoxESP"
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Transparency = 0.45
				box.Parent = root
				data.Box = box
			end
			data.Box.Adornee = root
			data.Box.Size = root.Size + Vector3.new(0.8, 2, 0.8)
			data.Box.Color3 = color
			data.Box.Visible = true
		else
			destroyEspInstance(data, "Box")
		end

		if Settings.ESP.NameESP or Settings.ESP.ShowDistance then
			local nameAdornee = head or root
			if not data.Billboard or not data.Billboard.Parent or data.Billboard.Parent ~= nameAdornee then
				if data.Billboard then data.Billboard:Destroy() end
				local billboard = Instance.new("BillboardGui")
				billboard.Name = "ONI_NameESP"
				billboard.AlwaysOnTop = true
				billboard.Size = UDim2.new(0, 140, 0, 40)
				billboard.StudsOffset = Vector3.new(0, 2.8, 0)
				billboard.MaxDistance = math.huge
				billboard.LightInfluence = 0
				billboard.Parent = nameAdornee

				local label = Instance.new("TextLabel")
				label.Name = "Label"
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, 0, 1, 0)
				label.Font = Enum.Font.GothamBold
				label.TextSize = 12
				label.TextStrokeTransparency = 0.3
				label.TextColor3 = color
				label.Parent = billboard
				data.Billboard = billboard
			end
			local label = data.Billboard:FindFirstChild("Label")
			if label then
				local text = player.DisplayName
				if Settings.ESP.ShowDistance and localRoot then
					text = text .. "\n" .. math.floor((root.Position - localRoot.Position).Magnitude) .. "m"
				end
				label.Text = text
				label.TextColor3 = color
			end
			data.Billboard.Enabled = true
		else
			destroyEspInstance(data, "Billboard")
		end

		if Settings.ESP.Tracers and localRoot then
			if not data.TracerBeam or not data.TracerBeam.Parent then
				if data.TracerBeam then data.TracerBeam:Destroy() end
				if data.TracerAtt0 then data.TracerAtt0:Destroy() end
				if data.TracerAtt1 then data.TracerAtt1:Destroy() end

				local att0 = Instance.new("Attachment")
				att0.Name = "ONI_Tracer0"
				att0.Parent = localRoot

				local att1 = Instance.new("Attachment")
				att1.Name = "ONI_Tracer1"
				att1.Parent = root

				local beam = Instance.new("Beam")
				beam.Name = "ONI_TracerBeam"
				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.Width0 = 0.1
				beam.Width1 = 0.1
				beam.FaceCamera = true
				beam.LightEmission = 1
				beam.Transparency = NumberSequence.new(0.2)
				beam.Parent = localRoot

				data.TracerAtt0 = att0
				data.TracerAtt1 = att1
				data.TracerBeam = beam
			end

			if data.TracerAtt0.Parent ~= localRoot then
				data.TracerAtt0.Parent = localRoot
			end
			if data.TracerAtt1.Parent ~= root then
				data.TracerAtt1.Parent = root
			end
			data.TracerBeam.Attachment0 = data.TracerAtt0
			data.TracerBeam.Attachment1 = data.TracerAtt1
			data.TracerBeam.Color = ColorSequence.new(color)
			data.TracerBeam.Enabled = true
		else
			destroyEspInstance(data, "TracerBeam")
			destroyEspInstance(data, "TracerAtt0")
			destroyEspInstance(data, "TracerAtt1")
		end
	end
end

local updateDrawingESP

applyTopMostUI = function(gui)
	if not gui then return end
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Enabled = true

	if Settings.Misc.TopMostUI and not isStreamProofActive() then
		gui.DisplayOrder = 999999
		local moved = false
		if gethui then
			local ok, hui = pcall(gethui)
			if ok and hui then
				pcall(function()
					gui.Parent = hui
					moved = true
				end)
			end
		end
		if not moved then
			gui.Parent = playerGui
		end
		protectGui(gui)
	else
		gui.DisplayOrder = 100
		gui.Parent = playerGui
	end

	if MenuShell then
		MenuShell.ZIndex = 1
	end
	if MainFrame then
		MainFrame.ZIndex = 1
	end
end

local function forceMouseUnlocked()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
end

local function restoreMouseState()
	if mouseUnlockConnection then
		mouseUnlockConnection:Disconnect()
		mouseUnlockConnection = nil
	end
	if savedMouseState then
		UserInputService.MouseBehavior = savedMouseState.Behavior
		UserInputService.MouseIconEnabled = savedMouseState.Icon
		savedMouseState = nil
	end
end

setMenuMouseState = function(open)
	if not Settings.Misc.UnlockMouseOnMenu then
		if not open then restoreMouseState() end
		return
	end

	if open then
		if not savedMouseState then
			savedMouseState = {
				Behavior = UserInputService.MouseBehavior,
				Icon = UserInputService.MouseIconEnabled,
			}
		end
		forceMouseUnlocked()

		if mouseUnlockConnection then mouseUnlockConnection:Disconnect() end
		mouseUnlockConnection = RunService.RenderStepped:Connect(function()
			if menuOpen and Settings.Misc.UnlockMouseOnMenu then
				forceMouseUnlocked()
			end
		end)
	else
		restoreMouseState()
	end
end

updateESP = function()
	if not ensureCamera() then return end
	if not isAnyEspEnabled() then
		if espSystemActive then
			if hideAllWorldEsp then hideAllWorldEsp() end
			if hideAllDrawingEsp then hideAllDrawingEsp() end
			espSystemActive = false
		end
		return
	end
	espSystemActive = true
	refreshEspPlayerRegistry()
	if shouldUseWorldEsp() then
		if updateWorldESP then updateWorldESP() end
	else
		if hideAllWorldEsp then hideAllWorldEsp() end
	end

	if shouldUseDrawingEsp() then
		if updateDrawingESP then updateDrawingESP() end
	else
		if hideAllDrawingEsp then hideAllDrawingEsp() end
	end
end

local function getOrCreatePlayerDrawings(player)
	if not Drawing or type(Drawing.new) ~= "function" then return nil end
	if not espDrawings[player] then
		espDrawings[player] = {
			Box = Drawing.new("Square"),
			Name = Drawing.new("Text"),
			Distance = Drawing.new("Text"),
			Tracer = Drawing.new("Line"),
			Skeleton = {},
		}
		local drawings = espDrawings[player]
		drawings.Box.Thickness = 1
		drawings.Box.Filled = false
		drawings.Box.Visible = false
		drawings.Name.Size = 14
		drawings.Name.Center = true
		drawings.Name.Outline = true
		drawings.Name.Visible = false
		drawings.Distance.Size = 12
		drawings.Distance.Center = true
		drawings.Distance.Outline = true
		drawings.Distance.Visible = false
		drawings.Tracer.Thickness = 1
		drawings.Tracer.Visible = false
		for i = 1, SKELETON_LINE_COUNT do
			local line = Drawing.new("Line")
			line.Thickness = 1
			line.Visible = false
			drawings.Skeleton[i] = line
		end
	end
	return espDrawings[player]
end

local function hidePlayerDrawings(player)
	local drawings = espDrawings[player]
	if not drawings then return end
	drawings.Box.Visible = false
	drawings.Name.Visible = false
	drawings.Distance.Visible = false
	drawings.Tracer.Visible = false
	if drawings.Skeleton then
		for _, line in ipairs(drawings.Skeleton) do
			line.Visible = false
		end
	end
end

local function cleanupPlayerDrawings(player)
	local drawings = espDrawings[player]
	if not drawings then return end
	drawings.Box:Remove()
	drawings.Name:Remove()
	drawings.Distance:Remove()
	drawings.Tracer:Remove()
	if drawings.Skeleton then
		for _, line in ipairs(drawings.Skeleton) do
			line:Remove()
		end
	end
	espDrawings[player] = nil
end

local function getWallCheckOrigin()
	local char = LocalPlayer.Character
	if char then
		local head = char:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head.Position
		end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			return hrp.Position + Vector3.new(0, 1.5, 0)
		end
	end
	if ensureCamera() then
		return Camera.CFrame.Position
	end
	return Vector3.zero
end

local WALLCHECK_IGNORE_FOLDERS = {
	"BulletVisuals", "Bullets", "Effects", "Debris", "Ignore", "RaycastIgnore",
	"Projectiles", "Shells", "Casings", "VFX", "Particles", "Tracers",
}

local function addToRaycastFilter(filter, inst)
	if not inst or table.find(filter, inst) then
		return
	end
	table.insert(filter, inst)
end

local function getRaycastIgnoreList()
	local filter = {}
	addToRaycastFilter(filter, Camera)
	for _, inst in ipairs(Camera:GetDescendants()) do
		addToRaycastFilter(filter, inst)
	end
	local localChar = getPlayerCharacter(LocalPlayer)
	if localChar then
		addToRaycastFilter(filter, localChar)
	end
	for _, folderName in ipairs(WALLCHECK_IGNORE_FOLDERS) do
		local folder = Workspace:FindFirstChild(folderName)
		if folder then
			addToRaycastFilter(filter, folder)
		end
	end
	return filter
end

local function getWallCheckIgnoreList(targetCharacter)
	local filter = getRaycastIgnoreList()
	for _, player in ipairs(Players:GetPlayers()) do
		local char = getPlayerCharacter(player)
		if char and char ~= targetCharacter then
			addToRaycastFilter(filter, char)
		end
	end
	return filter
end

local function partBelongsToCharacter(part, character, targetPlayer)
	if not part or not character then
		return false
	end
	if part == character or part:IsDescendantOf(character) then
		return true
	end
	local model = part:FindFirstAncestorOfClass("Model")
	if model and (model == character or model:IsDescendantOf(character)) then
		return true
	end
	if targetPlayer and model and model.Name == targetPlayer.Name then
		return true
	end
	return false
end

local function rayHitsCharacter(origin, part, character, targetPlayer, ignoreList)
	local delta = part.Position - origin
	local distance = delta.Magnitude
	if distance < 0.05 then
		return true
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.IgnoreWater = true
	if raycastParams.RespectCanCollide ~= nil then
		raycastParams.RespectCanCollide = true
	end

	local direction = delta.Unit * math.min(distance + 1.5, distance * 1.01 + 1.5)
	local result = Workspace:Raycast(origin, direction, raycastParams)
	if not result then
		return true
	end
	return partBelongsToCharacter(result.Instance, character, targetPlayer)
end

local function isTargetVisible(targetCharacter, targetPlayer)
	if not Settings.Aim.WallCheck then
		return true
	end
	if not targetCharacter then
		return false
	end

	targetPlayer = targetPlayer or Players:GetPlayerFromCharacter(targetCharacter)
	local origin = getWallCheckOrigin()
	local ignoreList = getWallCheckIgnoreList(targetCharacter)

	for _, part in ipairs(getAimHitParts(targetCharacter, true)) do
		if rayHitsCharacter(origin, part, targetCharacter, targetPlayer, ignoreList) then
			return true
		end
	end

	return false
end

local function getTargetAngleDeg(worldPos)
	local camPos = Camera.CFrame.Position
	local look = Camera.CFrame.LookVector
	local offset = worldPos - camPos
	if offset.Magnitude < 0.05 then
		return 0
	end
	return math.deg(math.acos(math.clamp(look:Dot(offset.Unit), -1, 1)))
end

local function getMaxLockAngle()
	return math.clamp(Settings.Aim.FOV / 4, 15, 120)
end

local function getBestTargetPlayer()
	local bestPlayer = nil
	local minScore = math.huge

	local localChar = getPlayerCharacter(LocalPlayer)
	local localRoot = localChar and getCharacterRoot(localChar)
	local localPos = localRoot and localRoot.Position or Camera.CFrame.Position
	local mousePos = getAimPoint2D()
	local maxAngle = getMaxLockAngle()

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if shouldSkipPlayer(player) then continue end
		if not passesTeamFilter(player) then continue end

		local char = getPlayerCharacter(player)
		local aimPart = char and getTargetPart(char)
		local root = char and getCharacterRoot(char)
		if not char or not aimPart or not root then continue end
		if not isCharacterAlive(char) then continue end

		local screenPos = Camera:WorldToViewportPoint(aimPart.Position)
		if screenPos.Z <= 0 then continue end

		local angleDeg = getTargetAngleDeg(aimPart.Position)
		local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
		local fovDistance = (screenPos2D - mousePos).Magnitude
		local inFov = angleDeg <= maxAngle or fovDistance <= Settings.Aim.FOV
		if not inFov then continue end
		if Settings.Aim.WallCheck and not isTargetVisible(char, player) then continue end

		local worldDist = (root.Position - localPos).Magnitude
		local score
		if Settings.Aim.TargetMode == "Distance" then
			score = worldDist
		elseif Settings.Aim.TargetMode == "FOV+Distance" then
			local fovNorm = fovDistance / math.max(Settings.Aim.FOV, 20)
			local distNorm = worldDist / 250
			score = fovNorm * 0.55 + distNorm * 0.45
		else
			score = angleDeg * 2 + fovDistance * 0.25
		end

		if score < minScore then
			minScore = score
			bestPlayer = player
		end
	end

	return bestPlayer
end

local function isCharacterAimValid(character)
	return character
		and character.Parent
		and getTargetPart(character) ~= nil
		and isCharacterAlive(character)
end

acquireAimTarget = function()
	if not Settings.Aim.Enabled then return end
	local targetPlayer = getBestTargetPlayer()
	if targetPlayer then
		currentTargetPlayer = targetPlayer
	end
end

local CAMERA_SCRIPT_KEYWORDS = {
	"camera", "playermoduleloader", "playerscriptloader", "viewmodel",
}

local function suppressGameCamera()
	local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return
	end
	for _, inst in ipairs(playerScripts:GetDescendants()) do
		if inst:IsA("LocalScript") and inst.Enabled and not suppressedCameraScripts[inst] then
			local name = inst.Name:lower()
			local disable = false
			for _, keyword in ipairs(CAMERA_SCRIPT_KEYWORDS) do
				if name:find(keyword, 1, true) then
					disable = true
					break
				end
			end
			if disable then
				suppressedCameraScripts[inst] = true
				inst.Disabled = true
			end
		end
	end
end

local function restoreGameCamera()
	for inst in pairs(suppressedCameraScripts) do
		if inst and inst.Parent then
			inst.Disabled = false
		end
	end
	table.clear(suppressedCameraScripts)
end

local function enableAimMouse()
	if Settings.Aim.FreeMouseOnLock == false then
		return
	end
	if not savedAimMouseState then
		savedAimMouseState = {
			Behavior = UserInputService.MouseBehavior,
			Icon = UserInputService.MouseIconEnabled,
		}
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = false
end

local function restoreAimMouse()
	if savedAimMouseState then
		UserInputService.MouseBehavior = savedAimMouseState.Behavior
		UserInputService.MouseIconEnabled = savedAimMouseState.Icon
		savedAimMouseState = nil
	end
end

local function beginAimCameraCapture()
	if aimLockSavedSubject == nil then
		aimLockSavedSubject = Camera.CameraSubject
		aimLockSavedCameraType = Camera.CameraType
	end
	suppressGameCamera()
	Camera.CameraSubject = nil
	Camera.CameraType = Enum.CameraType.Scriptable
end

local function endAimCameraCapture()
	restoreGameCamera()
	restoreAimMouse()
	if aimLockSavedSubject ~= nil then
		Camera.CameraSubject = aimLockSavedSubject
		Camera.CameraType = aimLockSavedCameraType or Enum.CameraType.Custom
		aimLockSavedSubject = nil
		aimLockSavedCameraType = nil
	end
end

local function restoreCameraType()
	if savedCameraType and Camera.CameraType == Enum.CameraType.Scriptable then
		Camera.CameraType = savedCameraType
	end
	savedCameraType = nil
end

local function getAimCameraPosition()
	if not ensureCamera() then
		return Vector3.zero
	end
	local char = LocalPlayer.Character
	if char then
		local head = char:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head.CFrame.Position
		end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			return hrp.Position + Vector3.new(0, 1.5, 0)
		end
	end
	return Camera.CFrame.Position
end

local function setLockCamera(targetCFrame)
	pendingLockCFrame = targetCFrame
	cameraLockActive = true
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = targetCFrame
end

local function applyLookAtTarget(worldPos, smoothSpeed)
	if not ensureCamera() or not worldPos then return end
	if Camera.CameraType ~= Enum.CameraType.Scriptable then
		beginAimCameraCapture()
	end
	local camPos = getAimCameraPosition()
	local targetCF = CFrame.new(camPos, worldPos)
	if smoothSpeed and smoothSpeed < 0.95 then
		targetCF = Camera.CFrame:Lerp(targetCF, math.clamp(smoothSpeed * 1.12, 0.08, 0.88))
	end
	setLockCamera(targetCF)
end

local function isSyntheticMouseDriver()
	return mouseApiName == "VIM"
end

local function needsCameraAimFallback()
	refreshMouseDriver()
	return mouseApiName == "NONE" or isSyntheticMouseDriver()
end

local function getMousePullStrength(smoothSpeed)
	if (Settings.Aim.Smoothness or 0) <= 0 then
		return 1
	end
	if Settings.Aim.SnapOnLock and smoothSpeed >= 0.95 then
		return 1
	end
	return math.clamp(smoothSpeed * 1.08, 0.15, 1)
end

local function isRobloxWindowActive()
	if type(isrbxactive) == "function" then
		local ok, active = pcall(isrbxactive)
		return ok and active
	end
	return true
end

local function shouldPauseAimWhileFiring()
	if Settings.Aim.FreezeAimWhileShooting == false then
		return false
	end
	return isFiringWeapon()
end

local function computeMouseAimDelta(errorX, errorY, smoothSpeed)
	local allowSnap = Settings.Aim.SnapOnLock and smoothSpeed >= 0.95
	local strength = getMousePullStrength(smoothSpeed)
	local dist = math.sqrt(errorX * errorX + errorY * errorY)

	local dampX = 1
	local dampY = 1
	if errorX * lastAimErrX < 0 then
		dampX = 0.65
	end
	if errorY * lastAimErrY < 0 then
		dampY = 0.65
	end
	lastAimErrX = errorX
	lastAimErrY = errorY

	local proximity = math.clamp(dist / 36, 0.62, 1.28)
	local frac = math.clamp(strength * AIM_PULL_FRACTION * proximity, 0.18, 0.82)
	if dist < 18 then
		frac = math.max(frac, 0.38 + (1 - dist / 18) * 0.28)
	end
	if allowSnap then
		frac = math.min(frac * 2.0, 0.9)
	end

	local dx = errorX * frac * dampX
	local dy = errorY * frac * dampY

	local maxStep = AIM_MAX_STEP
	if dist > 40 then
		maxStep = AIM_MAX_STEP + 6
	end
	if dist < 12 then
		maxStep = math.max(maxStep - 2, 8)
	end
	if allowSnap then
		maxStep = maxStep + 5
	end

	dx = math.clamp(dx, -maxStep, maxStep)
	dy = math.clamp(dy, -maxStep, maxStep)

	local overshootCap = dist > 28 and 0.94 or 0.89
	if math.abs(dx) > math.abs(errorX) * overshootCap then
		dx = errorX * overshootCap
	end
	if math.abs(dy) > math.abs(errorY) * overshootCap then
		dy = errorY * overshootCap
	end

	return dx, dy
end

local function applyMouseLockAim(worldPos, smoothSpeed)
	refreshMouseDriver()
	if not MouseDriver.moveRel or not isRobloxWindowActive() then
		return
	end

	if shouldPauseAimWhileFiring() then
		return
	end

	local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
	if not onScreen or screenPos.Z <= 0 then
		return
	end

	local mousePos = getAimPoint2D()
	local errorX = screenPos.X - mousePos.X
	local errorY = screenPos.Y - mousePos.Y
	local dx, dy = computeMouseAimDelta(errorX, errorY, smoothSpeed)

	if math.abs(dx) < 0.02 and math.abs(dy) < 0.02 then
		lastMouseMove = Vector2.zero
		return
	end

	mouseMoveRel(dx, dy)
end

local function applyCameraAim(worldPos, smoothSpeed)
	applyLookAtTarget(worldPos, smoothSpeed)
end

local function resolveAimMethod()
	local method = Settings.Aim.AimMethod or "Auto"
	if method == "Auto" then
		if hasMouseMoveRel() then
			return "Mouse"
		end
		return "Camera"
	end
	return method
end

local function usesCameraAimMethod()
	if needsCameraAimFallback() then
		return true
	end
	return resolveAimMethod() == "Camera"
end

local function applyAimAt(worldPos, smoothSpeed)
	local useMouse = not needsCameraAimFallback()
		and hasMouseMoveRel()
		and (Settings.Aim.UseScreenCenter or resolveAimMethod() == "Mouse" or resolveAimMethod() == "Auto")

	if useMouse then
		pendingLockCFrame = nil
		cameraLockActive = false
		applyMouseLockAim(worldPos, smoothSpeed)
		return
	end

	if Settings.Aim.FreeMouseOnLock then
		enableAimMouse()
	end
	if shouldPauseAimWhileFiring() then
		return
	end
	applyCameraAim(worldPos, smoothSpeed)
end

local function shouldAim()
	if not Settings.Aim.Enabled then return false end

	if Settings.Aim.LockMode == "Always On" then
		return true
	elseif Settings.Aim.LockMode == "Toggle" then
		return toggleActive
	elseif Settings.Aim.LockMode == "Hold" then
		return isAimKeyHeld()
	end

	return false
end

refreshLockHud = function()
	if type(Settings) ~= "table" or type(Settings.Aim) ~= "table" or not Settings.Aim.ShowLockHud then
		if LockStatusGui then
			LockStatusGui.Enabled = false
		end
		if lockIndicator then
			lockIndicator.Visible = false
		end
		return
	end

	syncAimKeyState()
	if not Settings.Aim.Enabled then
		setLockHud("ONICheats | Aim OFF", true)
		return
	end
	if not shouldAim() then
		local hint = Settings.Aim.AimWhileShooting and "Hold RMB or LMB" or "Hold RMB"
		setLockHud("ONICheats | Aim ON - " .. hint, true)
		return
	end
	if currentTargetPlayer then
		setLockHud("ONICheats | LOCK: " .. currentTargetPlayer.DisplayName, true)
	else
		setLockHud("ONICheats | No target", true)
	end
end

local function updateLockIndicator(worldPos, targetPlayer)
	refreshLockHud()
	if not Settings.Aim.ShowLockHud or not Drawing or not ensureCamera() then
		if lockIndicator then
			lockIndicator.Visible = false
		end
		return
	end
	if isStreamProofActive() or not Settings.Aim.Enabled or not shouldAim() or not worldPos or not targetPlayer then
		if lockIndicator then
			lockIndicator.Visible = false
		end
		return
	end
	if not lockIndicator then
		lockIndicator = Drawing.new("Circle")
		lockIndicator.Filled = true
		lockIndicator.Radius = 6
		lockIndicator.Thickness = 1
		lockIndicator.Color = Color3.fromRGB(255, 50, 50)
		lockIndicator.NumSides = 12
	end
	local screenPos = Camera:WorldToViewportPoint(worldPos)
	if screenPos.Z > 0 then
		lockIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
		lockIndicator.Visible = true
	else
		lockIndicator.Visible = false
	end
end

applyFPSPreset = function()
	Settings.Aim.Enabled = true
	if mouseApiName == "VIM" or mouseApiName == "NONE" then
		Settings.Aim.AimMethod = "Camera"
	else
		Settings.Aim.AimMethod = "Mouse"
	end
	Settings.Aim.UseScreenCenter = true
	Settings.Aim.FOV = 125
	Settings.Aim.WallCheck = true
	Settings.Aim.TeamCheck = true
	Settings.Aim.Smoothness = 0.05
	Settings.Aim.SnapOnLock = true
	Settings.Aim.StickyLock = true
	Settings.Aim.Prediction = 0
	Settings.Aim.FreeMouseOnLock = false
	Settings.Aim.LockMode = "Hold"
	Settings.Aim.AimWhileShooting = true
	Settings.Aim.SilentAim = false
	Settings.Aim.FreezeAimWhileShooting = false
	Settings.ESP.CharmsEnabled = true
	Settings.ESP.BoxESP = false
	Settings.ESP.NameESP = false
	Settings.ESP.Tracers = false
	Settings.ESP.ShowDistance = false
	Settings.ESP.SkeletonESP = false

	syncUIAfterConfigLoad()
	refreshMouseDriver()
	if refreshLockHud then refreshLockHud() end
	notify("ONICheats", "Jailbird preset ON. FOV 125, smooth 0.05, charms only. Hold RMB.")
	if mouseApiName == "NONE" then
		notify("ONICheats", "No input driver found - using camera fallback.")
	end
end

local function shouldSilentAim()
	if not scriptActive then
		return false
	end
	if not Settings.Aim.SilentAim or not Settings.Aim.Enabled then
		return false
	end

	local mode = Settings.Aim.SilentAimMode or "Hold"
	if mode == "Always" then
		return true
	elseif mode == "On Shoot" then
		return isShooting or shouldAim()
	end
	return shouldAim()
end

local function getPlayerFromPart(part)
	if not part then
		return nil
	end
	local model = part:FindFirstAncestorOfClass("Model")
	if not model then
		return nil
	end
	return Players:GetPlayerFromCharacter(model)
end

local function getPredictedPosition(part)
	if not part then
		return Vector3.zero
	end
	local pos = part.Position
	local velocity = part.AssemblyLinearVelocity
	local extraLead = Vector3.zero

	if Settings.Aim.VelocityResolver then
		local player = getPlayerFromPart(part)
		if player then
			local uid = player.UserId
			local hist = velocityHistory[uid]
			local now = tick()
			if hist and hist.velocity then
				local dt = math.max(now - hist.time, 0.016)
				local delta = velocity - hist.velocity
				local strength = math.clamp(Settings.Aim.ResolverStrength or 1, 0.5, 2)
				extraLead = delta * strength * dt * 12
				if extraLead.Magnitude > 40 then
					extraLead = extraLead.Unit * 40
				end
			end
			velocityHistory[uid] = {velocity = velocity, time = now}
		end
	end

	if Settings.Aim.Prediction > 0 then
		return pos + velocity * Settings.Aim.Prediction + extraLead
	elseif Settings.Aim.VelocityResolver then
		return pos + extraLead
	end
	return pos
end

local function getSilentAimTarget()
	if shotTargetPlayer and tick() < shotTargetExpire then
		local char = getAimCharacter(shotTargetPlayer)
		if char and isCharacterAimValid(char) then
			return char
		end
	end
	if currentTargetPlayer then
		local char = getAimCharacter(currentTargetPlayer)
		if char and isCharacterAimValid(char) then
			return char
		end
	end
	local player = getBestTargetPlayer()
	if player then
		currentTargetPlayer = player
		return getAimCharacter(player)
	end
	return nil
end

cacheShotTarget = function()
	shotTargetPlayer = getBestTargetPlayer()
	shotTargetExpire = tick() + 0.5
	if shotTargetPlayer then
		currentTargetPlayer = shotTargetPlayer
		invalidateCharacterCache(shotTargetPlayer)
		lastCharacterScan = 0
	end
end

local function pollShootState()
	local lmb = isMouseButtonHeld(Enum.UserInputType.MouseButton1)
	if lmb then
		if not isShooting then
			cacheShotTarget()
		end
		isShooting = true
	else
		isShooting = false
	end
end

local autoShootHolding = false
local lastAutoShootAt = 0

local function sendMouseButton(buttonId, isDown)
	local pos = UserInputService:GetMouseLocation()
	if VirtualInputManager then
		local ok = pcall(function()
			VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, buttonId, isDown, game)
		end)
		if ok then
			return true
		end
	end
	if isDown and buttonId == 0 then
		local clickFn = mouse1click or (getgenv and getgenv().mouse1click)
		if type(clickFn) == "function" then
			return pcall(clickFn)
		end
	end
	return false
end

local function releaseAutoShoot()
	if autoShootHolding then
		sendMouseButton(0, false)
		autoShootHolding = false
	end
end

local function getAutoShootTarget()
	if Settings.Aim.AutoShootMode == "On Lock" then
		return currentTargetPlayer
	end
	if Settings.Aim.AutoShootMode == "In FOV" then
		return getBestTargetPlayer()
	end
	if Settings.Aim.AutoShootMode == "While Aiming" and shouldAim() then
		return currentTargetPlayer or getBestTargetPlayer()
	end
	return nil
end

local function shouldAutoShoot()
	if not Settings.Aim.AutoShootEnabled then
		return false
	end
	if menuOpen or KeybindCaptureActive then
		return false
	end
	if not isRobloxWindowActive() then
		return false
	end
	if not canUseShootFeatures() then
		return false
	end

	local targetPlayer = getAutoShootTarget()
	if not targetPlayer then
		return false
	end

	local char = getAimCharacter(targetPlayer)
	if not char or not isCharacterAlive(char) then
		return false
	end

	if Settings.Aim.AutoShootWallCheck then
		if not isTargetVisible(char, targetPlayer) then
			return false
		end
	end

	if shouldSkipPlayer(targetPlayer) then
		return false
	end

	if not passesTeamFilter(targetPlayer) then
		return false
	end

	return true
end

local function updateTriggerbot()
	if not Settings.Aim.TriggerbotEnabled then
		return
	end
	if menuOpen or KeybindCaptureActive then
		return
	end
	if not isRobloxWindowActive() then
		return
	end
	if not canUseShootFeatures() then
		return
	end
	if not ensureCamera() then
		return
	end

	local now = tick()
	local delay = math.max(Settings.Aim.TriggerbotDelay or 0.05, 0.03)
	if now - lastTriggerbotAt < delay then
		return
	end

	local radius = math.max(Settings.Aim.TriggerbotRadius or 20, 1)
	local crosshair = getAimPoint2D()

	for _, player in ipairs(Players:GetPlayers()) do
		if shouldSkipPlayer(player) then continue end
		if not passesTeamFilter(player) then continue end

		local char = getPlayerCharacter(player)
		if not char or not isCharacterAlive(char, player) then
			continue
		end

		if Settings.Aim.TriggerbotWallCheck and not isTargetVisible(char, player) then
			continue
		end

		local hit = false
		for _, part in ipairs(getAimHitParts(char)) do
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen and screenPos.Z > 0 then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - crosshair).Magnitude
				if dist <= radius then
					hit = true
					break
				end
			end
		end

		if hit then
			lastTriggerbotAt = now
			if sendMouseButton(0, true) then
				task.delay(0.03, function()
					sendMouseButton(0, false)
				end)
			end
			if Settings.Misc.HitNotifyShot then
				showActionToast("Triggerbot: " .. player.DisplayName, Color3.fromRGB(220, 20, 40))
			end
			return
		end
	end
end

local function updateAutoShoot()
	if not shouldAutoShoot() then
		releaseAutoShoot()
		return
	end

	if Settings.Aim.AutoShootFireMode == "Hold" then
		if not autoShootHolding then
			if sendMouseButton(0, true) then
				autoShootHolding = true
			end
		end
		return
	end

	local interval = math.clamp(Settings.Aim.AutoShootInterval or 0.1, 0.05, 0.5)
	local now = tick()
	if now - lastAutoShootAt < interval then
		return
	end
	lastAutoShootAt = now

	if sendMouseButton(0, true) then
		task.delay(0.03, function()
			sendMouseButton(0, false)
		end)
	end
end

local function isAimRelatedVector(vec, originHint)
	if typeof(vec) ~= "Vector3" then
		return false
	end
	local camPos = Camera.CFrame.Position
	local distFromCam = (vec - camPos).Magnitude
	if distFromCam > 1.5 and distFromCam < 8000 then
		return true
	end
	if originHint and typeof(originHint) == "Vector3" then
		local dist = (vec - originHint).Magnitude
		if dist > 0.5 and dist < 5000 then
			return true
		end
	end
	return false
end

local function deepRedirectSilentTable(tbl, aimPos, aimPart, depth)
	if depth > 10 or typeof(tbl) ~= "table" then
		return false
	end
	local changed = false
	local origin = tbl.Origin or tbl.origin or tbl.Start or tbl.start or tbl.From or tbl.from
	for key, value in pairs(tbl) do
		local keyText = string.lower(tostring(key))
		if typeof(value) == "Vector3" then
			if keyText:find("dir", 1, true) then
				local from = origin or Camera.CFrame.Position
				tbl[key] = (aimPos - from).Unit * math.max(value.Magnitude, 50)
				changed = true
			elseif not keyText:find("origin", 1, true) and not keyText:find("start", 1, true) and not keyText:find("from", 1, true) then
				if isAimRelatedVector(value, origin or Camera.CFrame.Position) then
					tbl[key] = aimPos
					changed = true
				end
			end
		elseif typeof(value) == "Instance" then
			if value:IsA("BasePart") then
				local model = value:FindFirstAncestorOfClass("Model")
				local owner = model and Players:GetPlayerFromCharacter(model)
				if owner and owner ~= LocalPlayer then
					tbl[key] = aimPart
					changed = true
				end
			elseif value:IsA("Player") and value ~= LocalPlayer then
				tbl[key] = shotTargetPlayer or currentTargetPlayer or value
				changed = true
			elseif value:IsA("Model") then
				local owner = Players:GetPlayerFromCharacter(value)
				if owner and owner ~= LocalPlayer then
					tbl[key] = aimPart and aimPart:FindFirstAncestorOfClass("Model") or value
					changed = true
				end
			end
		elseif typeof(value) == "CFrame" then
			tbl[key] = CFrame.new(aimPos)
			changed = true
		elseif typeof(value) == "table" then
			if deepRedirectSilentTable(value, aimPos, aimPart, depth + 1) then
				changed = true
			end
		elseif typeof(value) == "Ray" then
			tbl[key] = Ray.new(value.Origin, (aimPos - value.Origin).Unit * math.max(value.Direction.Magnitude, 50))
			changed = true
		end
	end
	return changed
end

local function redirectSilentArgs(args)
	local aimPart = getSilentAimPart()
	local aimPos = getSilentAimPosition()
	local aimChar = getSilentAimTarget()
	if not aimPart or not aimPos then
		return false
	end

	local changed = false
	local camPos = Camera.CFrame.Position
	for i, arg in ipairs(args) do
		if typeof(arg) == "Instance" then
			if arg:IsA("BasePart") then
				local model = arg:FindFirstAncestorOfClass("Model")
				local owner = model and Players:GetPlayerFromCharacter(model)
				if owner and owner ~= LocalPlayer then
					args[i] = aimPart
					changed = true
				end
			elseif arg:IsA("Player") and arg ~= LocalPlayer then
				args[i] = shotTargetPlayer or currentTargetPlayer or arg
				changed = true
			elseif arg:IsA("Model") then
				local owner = Players:GetPlayerFromCharacter(arg)
				if owner and owner ~= LocalPlayer and aimChar then
					args[i] = aimChar
					changed = true
				end
			end
		elseif typeof(arg) == "Vector3" then
			if arg.Magnitude > 0.01 and arg.Magnitude < 12 then
				args[i] = (aimPos - camPos).Unit * arg.Magnitude
				changed = true
			elseif isAimRelatedVector(arg, camPos) then
				args[i] = aimPos
				changed = true
			end
		elseif typeof(arg) == "CFrame" then
			args[i] = CFrame.new(aimPos)
			changed = true
		elseif typeof(arg) == "table" then
			if deepRedirectSilentTable(arg, aimPos, aimPart, 1) then
				changed = true
			end
		elseif typeof(arg) == "Ray" then
			args[i] = Ray.new(arg.Origin, (aimPos - arg.Origin).Unit * math.max(arg.Direction.Magnitude, 50))
			changed = true
		end
	end
	return changed
end

local function getSilentAimPosition()
	if not shouldSilentAim() then return nil end
	local target = getSilentAimTarget()
	if not target then return nil end
	local part = getTargetPart(target)
	if not part then return nil end
	return getPredictedPosition(part)
end

local function getSilentAimPart()
	local target = getSilentAimTarget()
	if not target then return nil end
	return getTargetPart(target)
end

function getTrollTargetList()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(list, player)
		end
	end
	return list
end

function getTrollTarget()
	local list = getTrollTargetList()
	if #list == 0 then return nil end
	trollTargetIndex = ((trollTargetIndex - 1) % #list) + 1
	return list[trollTargetIndex]
end

function cycleTrollTarget()
	local list = getTrollTargetList()
	if #list == 0 then
		trollTargetIndex = 1
		return nil
	end
	trollTargetIndex = (trollTargetIndex % #list) + 1
	return list[trollTargetIndex]
end

function updateTrollTargetLabel()
	if trollTargetLabel then
		local target = getTrollTarget()
		trollTargetLabel.Text = target and (target.DisplayName .. " (@ " .. target.Name .. ")") or "No Players Found"
	end
end

local function clearFlingForce()
	if flingAngular then flingAngular:Destroy() flingAngular = nil end
	if flingVelocity then flingVelocity:Destroy() flingVelocity = nil end
end

local function applyFlingForce(power)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if not flingAngular or not flingAngular.Parent then
		flingAngular = Instance.new("BodyAngularVelocity")
		flingAngular.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		flingAngular.Parent = hrp
	end
	if not flingVelocity or not flingVelocity.Parent then
		flingVelocity = Instance.new("BodyVelocity")
		flingVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		flingVelocity.Parent = hrp
	end

	local spin = power * 0.01
	flingAngular.AngularVelocity = Vector3.new(math.random(-spin, spin), math.random(-spin, spin), math.random(-spin, spin))
	flingVelocity.Velocity = Vector3.new(math.random(-power, power), power * 2, math.random(-power, power))
end

function flingTargetOnce(targetPlayer)
	local targetChar = targetPlayer and targetPlayer.Character
	local char = LocalPlayer.Character
	if not targetChar or not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHRP then return end

	hrp.CFrame = targetHRP.CFrame
	applyFlingForce(Settings.Troll.FlingPower)
	task.delay(0.4, function()
		if not Settings.Troll.ConstantFling then
			clearFlingForce()
		end
	end)
end

function flingAllPlayers()
	task.spawn(function()
		for _, player in ipairs(getTrollTargetList()) do
			flingTargetOnce(player)
			task.wait(0.15)
		end
	end)
end

function yeetTargetUp(targetPlayer)
	local targetChar = targetPlayer and targetPlayer.Character
	local char = LocalPlayer.Character
	if not targetChar or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHRP then return end

	hrp.CFrame = targetHRP.CFrame * CFrame.new(0, -2, 0)
	applyFlingForce(Settings.Troll.FlingPower * 1.5)
	if flingVelocity then
		flingVelocity.Velocity = Vector3.new(0, Settings.Troll.FlingPower * 3, 0)
	end
	task.delay(0.35, function()
		if not Settings.Troll.ConstantFling then clearFlingForce() end
	end)
end

function slamTargetDown(targetPlayer)
	local targetChar = targetPlayer and targetPlayer.Character
	local char = LocalPlayer.Character
	if not targetChar or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHRP then return end

	hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 25, 0)
	task.wait()
	hrp.CFrame = targetHRP.CFrame
	applyFlingForce(Settings.Troll.FlingPower)
	if flingVelocity then
		flingVelocity.Velocity = Vector3.new(0, -Settings.Troll.FlingPower * 4, 0)
	end
	task.delay(0.35, function()
		if not Settings.Troll.ConstantFling then clearFlingForce() end
	end)
end

function bringTargetToMe(targetPlayer)
	local targetChar = targetPlayer and targetPlayer.Character
	local char = LocalPlayer.Character
	if not targetChar or not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHRP then return end

	hrp.CFrame = targetHRP.CFrame
	task.wait(0.05)
	hrp.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * -8)
	flingTargetOnce(targetPlayer)
end

local voteKickRemote = nil
local voteKickArgsTemplate = nil
local voteKickArgSlots = {}

local function isVoteKickRemoteName(name)
	local lower = string.lower(tostring(name))
	if lower:find("votekick", 1, true) or lower:find("vote_kick", 1, true) then
		return true
	end
	return lower:find("kick", 1, true) ~= nil
		and (lower:find("vote", 1, true) ~= nil or lower:find("poll", 1, true) ~= nil)
end

local function recordVoteKickFire(remote, args)
	if not remote or type(args) ~= "table" then
		return
	end
	voteKickRemote = remote
	voteKickArgsTemplate = {}
	voteKickArgSlots = {}
	for i, arg in ipairs(args) do
		voteKickArgsTemplate[i] = arg
		if typeof(arg) == "Instance" and arg:IsA("Player") and arg ~= LocalPlayer then
			voteKickArgSlots[i] = "player"
		elseif type(arg) == "number" and arg > 1000 and Players:GetPlayerByUserId(arg) then
			voteKickArgSlots[i] = "userid"
		elseif type(arg) == "string" and Players:FindFirstChild(arg) then
			voteKickArgSlots[i] = "name"
		end
	end
	if next(voteKickArgSlots) then
		notify("ONICheats", "Vote kick remote captured: " .. remote:GetFullName())
	end
end

local function sniffVoteKickFire(remote, args)
	if not remote then
		return
	end
	if isVoteKickRemoteName(remote.Name) then
		recordVoteKickFire(remote, args)
		return
	end
	for _, arg in ipairs(args) do
		if typeof(arg) == "Instance" and arg:IsA("Player") and arg ~= LocalPlayer then
			recordVoteKickFire(remote, args)
			return
		end
	end
end

local function findVoteKickRemotes()
	local found = {}
	local services = {
		game:GetService("ReplicatedStorage"),
		game:GetService("ReplicatedFirst"),
	}
	for _, service in ipairs(services) do
		for _, inst in ipairs(service:GetDescendants()) do
			if (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction")) and isVoteKickRemoteName(inst.Name) then
				table.insert(found, inst)
			end
		end
	end
	return found
end

local function buildVoteKickPayloads(targetPlayer)
	return {
		{targetPlayer},
		{targetPlayer.UserId},
		{targetPlayer.Name},
		{targetPlayer.DisplayName},
		{true, targetPlayer},
		{targetPlayer, true},
		{"Yes", targetPlayer},
		{"yes", targetPlayer},
		{"Vote", targetPlayer.UserId},
		{"VoteYes", targetPlayer.UserId},
		{"VoteKick", targetPlayer},
		{"VoteKick", targetPlayer.UserId},
		{"VoteKick", targetPlayer.Name},
		{LocalPlayer, targetPlayer},
		{targetPlayer, LocalPlayer},
	}
end

local function fireVoteKickRemote(remote, args)
	if remote:IsA("RemoteEvent") then
		remote:FireServer(table.unpack(args))
	elseif remote:IsA("RemoteFunction") then
		remote:InvokeServer(table.unpack(args))
	end
end

function attemptVoteKick(targetPlayer)
	if not targetPlayer or targetPlayer == LocalPlayer then
		notify("ONICheats", "Pick another player to vote kick.")
		return false
	end

	if voteKickRemote and voteKickRemote.Parent and voteKickArgsTemplate then
		local args = {}
		for i, templateArg in ipairs(voteKickArgsTemplate) do
			local slot = voteKickArgSlots[i]
			if slot == "player" then
				args[i] = targetPlayer
			elseif slot == "userid" then
				args[i] = targetPlayer.UserId
			elseif slot == "name" then
				args[i] = targetPlayer.Name
			else
				args[i] = templateArg
			end
		end
		local ok, err = pcall(fireVoteKickRemote, voteKickRemote, args)
		if ok then
			notify("ONICheats", "Vote kick sent for " .. targetPlayer.DisplayName)
			return true
		end
		notify("ONICheats", "Vote kick failed: " .. tostring(err))
		return false
	end

	local remotes = findVoteKickRemotes()
	if voteKickRemote and voteKickRemote.Parent then
		table.insert(remotes, 1, voteKickRemote)
	end

	for _, remote in ipairs(remotes) do
		for _, payload in ipairs(buildVoteKickPayloads(targetPlayer)) do
			local ok = pcall(fireVoteKickRemote, remote, payload)
			if ok then
				recordVoteKickFire(remote, payload)
				notify("ONICheats", "Vote kick sent for " .. targetPlayer.DisplayName)
				return true
			end
		end
	end

	notify("ONICheats", "Vote kick remote unknown. Use in-game vote kick once, then press VOTE again.")
	return false
end

local originalTransparency = {}

function updateInvisibleState()
	local char = LocalPlayer.Character
	if not char then return end

	if Settings.Troll.Invisible then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				if originalTransparency[part] == nil then
					originalTransparency[part] = part.Transparency
				end
				part.Transparency = 1
			end
		end
	else
		for part, transparency in pairs(originalTransparency) do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
		table.clear(originalTransparency)
	end
end

local function clearSpinTroll()
	if spinGyro then spinGyro:Destroy() spinGyro = nil end
end

local function updateSpinTroll()
	if not Settings.Troll.SpinTroll then
		clearSpinTroll()
		return
	end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if not spinGyro or not spinGyro.Parent then
		spinGyro = Instance.new("BodyAngularVelocity")
		spinGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		spinGyro.Parent = hrp
	end
	spinGyro.AngularVelocity = Vector3.new(0, Settings.Troll.FlingPower * 0.02, 0)
end

function startSpectate(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if not spectating then
		originalCameraSubject = Camera.CameraSubject
		originalCameraType = Camera.CameraType
	end
	Camera.CameraSubject = humanoid
	Camera.CameraType = Enum.CameraType.Custom
	spectating = true
	spectateTarget = targetPlayer
end

function stopSpectate()
	if spectating then
		Camera.CameraSubject = originalCameraSubject or LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		Camera.CameraType = originalCameraType or Enum.CameraType.Custom
	end
	spectating = false
	spectateTarget = nil
end

local function wrapClosure(fn)
	if newcclosure then
		return newcclosure(fn)
	end
	return fn
end

local function applySilentRayRedirect(origin, direction)
	local aimPos = getSilentAimPosition()
	if not aimPos or typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return nil
	end
	return (aimPos - origin).Unit * direction.Magnitude
end

local function isGameCameraObject(obj)
	return obj == Camera or obj == Workspace.CurrentCamera
end


local function installPrototypeHooks()
	if not hookfunction then
		return
	end

	pcall(function()
		local sampleEvent = Instance.new("RemoteEvent")
		local oldFire = hookfunction(sampleEvent.FireServer, wrapClosure(function(self, ...)
			if checkcaller and checkcaller() then
				return oldFire(self, ...)
			end
			if shouldSilentAim() then
				local args = {...}
				if redirectSilentArgs(args) then
					return oldFire(self, table.unpack(args))
				end
			end
			return oldFire(self, ...)
		end))
	end)

	pcall(function()
		local sampleFunction = Instance.new("RemoteFunction")
		local oldInvoke = hookfunction(sampleFunction.InvokeServer, wrapClosure(function(self, ...)
			if checkcaller and checkcaller() then
				return oldInvoke(self, ...)
			end
			if shouldSilentAim() then
				local args = {...}
				if redirectSilentArgs(args) then
					return oldInvoke(self, table.unpack(args))
				end
			end
			return oldInvoke(self, ...)
		end))
	end)

	pcall(function()
		local raycastFn = Workspace.Raycast
		if raycastFn then
			local oldRaycast = hookfunction(raycastFn, wrapClosure(function(origin, direction, raycastParams)
				if checkcaller and checkcaller() then
					return oldRaycast(origin, direction, raycastParams)
				end
				if shouldSilentAim() then
					local newDir = applySilentRayRedirect(origin, direction)
					if newDir then
						direction = newDir
					end
				end
				return oldRaycast(origin, direction, raycastParams)
			end))
		end
	end)
end

local function installAimHooks()
	if hookmetamethod and getnamecallmethod then
		local oldNamecall
		local function onNamecall(self, ...)
			if checkcaller and checkcaller() then
				return oldNamecall(self, ...)
			end

			local method = getnamecallmethod()
			local args = {...}

			if shouldSilentAim() then
				local aimPos = getSilentAimPosition()
				if aimPos then
					if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
						local newDir = applySilentRayRedirect(args[1], args[2])
						if newDir then
							args[2] = newDir
							return oldNamecall(self, table.unpack(args))
						end
					elseif method == "Spherecast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
						local newDir = applySilentRayRedirect(args[1], args[2])
						if newDir then
							args[2] = newDir
							return oldNamecall(self, table.unpack(args))
						end
					elseif method == "Blockcast" and typeof(args[1]) == "CFrame" and typeof(args[2]) == "Vector3" then
						local origin = args[1].Position
						local newDir = (aimPos - origin).Unit * math.max(args[2].Magnitude, 100)
						args[1] = CFrame.new(origin, origin + newDir)
						return oldNamecall(self, table.unpack(args))
					elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
						local ray = args[1]
						if typeof(ray) == "Ray" then
							local origin = ray.Origin
							local newDir = (aimPos - origin).Unit * math.max(ray.Direction.Magnitude, 50)
							args[1] = Ray.new(origin, newDir)
							return oldNamecall(self, table.unpack(args))
						end
					elseif (method == "ScreenPointToRay" or method == "ViewportPointToRay") and isGameCameraObject(self) then
						local origin = Camera.CFrame.Position
						return Ray.new(origin, (aimPos - origin).Unit * 1000)
					elseif method == "FireServer" and self.ClassName == "RemoteEvent" then
						sniffVoteKickFire(self, args)
						if redirectSilentArgs(args) then
							return oldNamecall(self, table.unpack(args))
						end
					elseif method == "InvokeServer" and self.ClassName == "RemoteFunction" then
						if redirectSilentArgs(args) then
							return oldNamecall(self, table.unpack(args))
						end
					end
				end
			end

			return oldNamecall(self, ...)
		end
		oldNamecall = hookmetamethod(game, "__namecall", wrapClosure(onNamecall))
		savedMetamethodHooks.namecall = oldNamecall
	end

	if hookmetamethod then
		local oldIndex
		local function onIndex(self, key)
			if checkcaller and checkcaller() then
				return oldIndex(self, key)
			end

			if shouldSilentAim() and typeof(self) == "Instance" and self:IsA("Mouse") then
				if key == "Hit" or key == "hit" then
					local aimPos = getSilentAimPosition()
					if aimPos then
						return CFrame.new(aimPos)
					end
				elseif key == "Target" or key == "target" then
					local part = getSilentAimPart()
					if part then
						return part
					end
				elseif key == "UnitRay" or key == "unitRay" then
					local aimPos = getSilentAimPosition()
					if aimPos then
						local origin = Camera.CFrame.Position
						return Ray.new(origin, (aimPos - origin).Unit)
					end
				end
			end

			return oldIndex(self, key)
		end
		oldIndex = hookmetamethod(game, "__index", wrapClosure(onIndex))
		savedMetamethodHooks.index = oldIndex
	end

	installPrototypeHooks()
end

pcall(installAimHooks)

function updateLightingState()
	if Settings.Misc.Fullbright then
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	else
		Lighting.Brightness = defaultLighting.Brightness
		Lighting.Ambient = defaultLighting.Ambient
		Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
	end

	if Settings.Misc.NoFog then
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
	else
		Lighting.FogEnd = defaultLighting.FogEnd
		Lighting.FogStart = defaultLighting.FogStart
	end
end

updateDrawingESP = function()
	if not ensureCamera() then return end
	if not Drawing or type(Drawing.new) ~= "function" then return end
	if isStreamProofActive() then
		hideAllDrawingEsp()
		return
	end

	local anyEspEnabled = Settings.ESP.BoxESP or Settings.ESP.NameESP or Settings.ESP.Tracers
		or Settings.ESP.ShowDistance or Settings.ESP.SkeletonESP
	if not anyEspEnabled then
		for player in pairs(espDrawings) do
			hidePlayerDrawings(player)
		end
		return
	end

	local localChar = getPlayerCharacter(LocalPlayer)
	local localRoot = localChar and getCharacterRoot(localChar)
	local viewportSize = Camera.ViewportSize

	for _, player in ipairs(Players:GetPlayers()) do
		if not shouldDrawPlayer(player) then
			hidePlayerDrawings(player)
			continue
		end

		local char = getPlayerCharacter(player)
		local root = char and getCharacterRoot(char)
		if not char or not root or not isCharacterAlive(char, player) then
			cleanupPlayerDrawings(player)
			invalidateCharacterCache(player)
			continue
		end

		local drawings = getOrCreatePlayerDrawings(player)
		if not drawings then
			hidePlayerDrawings(player)
			continue
		end
		local head = getCharacterHead(char)
		local feet = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg") or root
		local topPos = head and head.Position + Vector3.new(0, 0.5, 0) or root.Position + Vector3.new(0, 2.5, 0)
		local bottomPos = feet.Position - Vector3.new(0, 1, 0)

		local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPos)
		local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos)
		if not topOnScreen and not bottomOnScreen then
			hidePlayerDrawings(player)
			continue
		end

		local top2D = Vector2.new(topScreen.X, topScreen.Y)
		local bottom2D = Vector2.new(bottomScreen.X, bottomScreen.Y)
		local height = math.abs(bottom2D.Y - top2D.Y)
		local width = height * 0.55
		local centerX = (top2D.X + bottom2D.X) * 0.5
		local color = getEspColorForPlayer(player)

		if Settings.ESP.BoxESP then
			drawings.Box.Size = Vector2.new(width, height)
			drawings.Box.Position = Vector2.new(centerX - width * 0.5, top2D.Y)
			drawings.Box.Color = color
			drawings.Box.Thickness = 1
			drawings.Box.Filled = false
			drawings.Box.Visible = true
		else
			drawings.Box.Visible = false
		end

		if Settings.ESP.NameESP then
			drawings.Name.Text = player.DisplayName
			drawings.Name.Position = Vector2.new(centerX, top2D.Y - 16)
			drawings.Name.Color = color
			drawings.Name.Visible = true
		else
			drawings.Name.Visible = false
		end

		if Settings.ESP.ShowDistance and localRoot then
			local distance = math.floor((root.Position - localRoot.Position).Magnitude)
			drawings.Distance.Text = distance .. "m"
			drawings.Distance.Position = Vector2.new(centerX, bottom2D.Y + 4)
			drawings.Distance.Color = color
			drawings.Distance.Visible = true
		else
			drawings.Distance.Visible = false
		end

		if Settings.ESP.Tracers then
			drawings.Tracer.From = Vector2.new(viewportSize.X * 0.5, viewportSize.Y)
			drawings.Tracer.To = bottom2D
			drawings.Tracer.Color = color
			drawings.Tracer.Visible = true
		else
			drawings.Tracer.Visible = false
		end

		if Settings.ESP.SkeletonESP and drawings.Skeleton then
			local lineIndex = 1
			for _, pair in ipairs(SKELETON_BONES) do
				if lineIndex > SKELETON_LINE_COUNT then break end
				local partA = char:FindFirstChild(pair[1])
				local partB = char:FindFirstChild(pair[2])
				local line = drawings.Skeleton[lineIndex]
				if partA and partB and line then
					local posA, onA = Camera:WorldToViewportPoint(partA.Position)
					local posB, onB = Camera:WorldToViewportPoint(partB.Position)
					if onA or onB then
						line.From = Vector2.new(posA.X, posA.Y)
						line.To = Vector2.new(posB.X, posB.Y)
						line.Color = color
						line.Visible = true
						lineIndex = lineIndex + 1
					end
				end
			end
			for i = lineIndex, SKELETON_LINE_COUNT do
				if drawings.Skeleton[i] then
					drawings.Skeleton[i].Visible = false
				end
			end
		elseif drawings.Skeleton then
			for _, line in ipairs(drawings.Skeleton) do
				line.Visible = false
			end
		end
	end
end

function setNoclipState(character, enabled)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not enabled
		end
	end
end


local function initCrosshairDrawings()
	if not Drawing or type(Drawing.new) ~= "function" then
		return
	end
	for i = 1, 4 do
		if not crosshairDrawings[i] then
			local line = Drawing.new("Line")
			line.Thickness = 1
			line.Transparency = 0
			line.Visible = false
			crosshairDrawings[i] = line
		end
	end
end

updateCrosshairOverlay = function()
	if not Drawing or isStreamProofActive() or not Settings.Aim.CrosshairEnabled then
		for _, line in ipairs(crosshairDrawings) do
			if line then
				line.Visible = false
			end
		end
		return
	end
	if not ensureCamera() then
		return
	end
	initCrosshairDrawings()

	local center = Camera.ViewportSize * 0.5
	local size = math.max(Settings.Aim.CrosshairSize or 8, 2)
	local color = Settings.Aim.CrosshairColor or Color3.fromRGB(255, 255, 255)
	local gap = math.max(size * 0.25, 2)

	local h1, h2, v1, v2 = crosshairDrawings[1], crosshairDrawings[2], crosshairDrawings[3], crosshairDrawings[4]
	if h1 and h2 and v1 and v2 then
		h1.From = Vector2.new(center.X - size, center.Y)
		h1.To = Vector2.new(center.X - gap, center.Y)
		h1.Color = color
		h1.Visible = true

		h2.From = Vector2.new(center.X + gap, center.Y)
		h2.To = Vector2.new(center.X + size, center.Y)
		h2.Color = color
		h2.Visible = true

		v1.From = Vector2.new(center.X, center.Y - size)
		v1.To = Vector2.new(center.X, center.Y - gap)
		v1.Color = color
		v1.Visible = true

		v2.From = Vector2.new(center.X, center.Y + gap)
		v2.To = Vector2.new(center.X, center.Y + size)
		v2.Color = color
		v2.Visible = true
	end
end

trackConnection(RunService.RenderStepped:Connect(function()
	if not scriptActive then return end
	ensureCamera()
	if fovCircle and Camera then
		fovCircle.Radius = Settings.Aim.FOV
		fovCircle.Position = getAimPoint2D()
		fovCircle.Color = Settings.Aim.FOVColor or Color3.fromRGB(220, 20, 40)
		fovCircle.Visible = not isStreamProofActive() and Settings.Aim.Enabled and Settings.Aim.ShowFOV
	end
	updateCrosshairOverlay()
end))

trackConnection(RunService.Heartbeat:Connect(function()
	if not scriptActive then return end
	if not isAnyEspEnabled() then
		if espSystemActive then
			local ok, err = pcall(updateESP)
			if not ok then
				warn("[ONICheats] ESP error: " .. tostring(err))
			end
		end
		return
	end
	local now = tick()
	if now - lastEspRenderAt < ESP_RENDER_INTERVAL then
		return
	end
	lastEspRenderAt = now
	local ok, err = pcall(updateESP)
	if not ok then
		warn("[ONICheats] ESP error: " .. tostring(err))
	end
end))

local function runAimLoop(deltaTime)
	if not scriptActive then return end
	syncAimKeyState()
	pollShootState()
	if not ensureCamera() then return end
	if not Settings.Aim.Enabled then
		endAimCameraCapture()
		pendingLockCFrame = nil
		cameraLockActive = false
		updateLockIndicator(nil, nil)
		return
	end

	local aiming = shouldAim()
	if not aiming then
		currentTargetPlayer = nil
		lastAimTargetPlayer = nil
		lastAimErrX = 0
		lastAimErrY = 0
		lockGraceTimer = 0
		pendingLockCFrame = nil
		cameraLockActive = false
		endAimCameraCapture()
		restoreCameraType()
		updateLockIndicator(nil, nil)
		refreshLockHud()
		return
	end

	local freshTarget = getBestTargetPlayer()
	if freshTarget then
		currentTargetPlayer = freshTarget
		lockGraceTimer = LOCK_GRACE_TIME
	elseif Settings.Aim.StickyLock and currentTargetPlayer then
		lockGraceTimer = math.max(lockGraceTimer - deltaTime, 0)
		if lockGraceTimer <= 0 then
			currentTargetPlayer = nil
		end
	else
		currentTargetPlayer = nil
	end

	local currentTarget = getAimCharacter(currentTargetPlayer)
	if currentTarget and Settings.Aim.WallCheck and not isTargetVisible(currentTarget, currentTargetPlayer) then
		if not Settings.Aim.StickyLock or lockGraceTimer <= 0 then
			currentTarget = nil
			currentTargetPlayer = nil
		end
	end

	local targetPart = currentTarget and getTargetPart(currentTarget)
	if targetPart then
		if usesCameraAimMethod() then
			beginAimCameraCapture()
		end
		local targetPos = getPredictedPosition(targetPart)
		local isNewTarget = currentTargetPlayer ~= lastAimTargetPlayer
		local smoothSpeed
		if Settings.Aim.Smoothness <= 0 then
			smoothSpeed = 1
		elseif Settings.Aim.SnapOnLock and isNewTarget then
			smoothSpeed = 1
		else
			smoothSpeed = math.clamp(deltaTime * (1 / math.max(Settings.Aim.Smoothness, 0.01)) * 28, 0.12, 1)
		end

		if not shouldPauseAimWhileFiring() then
			applyAimAt(targetPos, smoothSpeed)
		end
		if isNewTarget and currentTargetPlayer and Settings.Misc.HitNotifyLock then
			showActionToast("Target locked: " .. currentTargetPlayer.DisplayName, Color3.fromRGB(70, 220, 110))
		end
		updateLockIndicator(targetPos, currentTargetPlayer)
		refreshLockHud()
		lastAimTargetPlayer = currentTargetPlayer
	else
		endAimCameraCapture()
		pendingLockCFrame = nil
		cameraLockActive = false
		updateLockIndicator(nil, nil)
		refreshLockHud()
	end
end

local lastAimLoopError = ""
local function safeRunAimLoop(deltaTime)
	local ok, err = pcall(runAimLoop, deltaTime)
	if not ok then
		local message = tostring(err)
		if message ~= lastAimLoopError then
			lastAimLoopError = message
			warn("[ONICheats] Aim loop error: " .. message)
		end
	end
end

local function enforceLockCamera()
	if not usesCameraAimMethod() then return end
	if shouldPauseAimWhileFiring() then return end
	if not ensureCamera() or not Settings.Aim.Enabled or not shouldAim() then return end
	if pendingLockCFrame and cameraLockActive then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = pendingLockCFrame
		return
	end
	if currentTargetPlayer then
		local char = getAimCharacter(currentTargetPlayer)
		local part = char and getTargetPart(char)
		if part then
			local camSmooth = 0.35
			if Settings.Aim.Smoothness and Settings.Aim.Smoothness > 0 then
				camSmooth = math.clamp(0.18 + Settings.Aim.Smoothness * 1.1, 0.18, 0.72)
			end
			applyLookAtTarget(getPredictedPosition(part), camSmooth)
		end
	end
end

local function bindAimRuntime()
	pcall(function() RunService:UnbindFromRenderStep("ONICheatsAim") end)
	pcall(function() RunService:UnbindFromRenderStep("ONICheatsAimLate") end)
	pcall(function() RunService:UnbindFromRenderStep("ONICheatsAimFinal") end)
	if aimRuntimeConnection then
		aimRuntimeConnection:Disconnect()
		aimRuntimeConnection = nil
	end

	local aimBindOk = false
	local aimPriority = Enum.RenderPriority.Last.Value + 1
	pcall(function()
		RunService:BindToRenderStep("ONICheatsAimFinal", aimPriority, function(dt)
			safeRunAimLoop(dt)
			enforceLockCamera()
		end)
		aimBindOk = true
	end)
	if not aimBindOk then
		aimRuntimeConnection = RunService.Heartbeat:Connect(function(dt)
			safeRunAimLoop(dt)
			enforceLockCamera()
		end)
		warn("[ONICheats] RenderStep aim bind failed - using Heartbeat fallback.")
	end
end
bindAimRuntime()

trackConnection(RunService.Heartbeat:Connect(function()
	if not scriptActive then return end
	pcall(updateAutoShoot)
	pcall(updateTriggerbot)
end))

trackConnection(RunService.Heartbeat:Connect(function()
	if not scriptActive then return end
	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if Settings.Movement.SpeedEnabled then
		humanoid.WalkSpeed = Settings.Movement.SpeedValue
	end

	if Settings.Movement.JumpEnabled then
		if humanoid.UseJumpPower then
			humanoid.JumpPower = Settings.Movement.JumpValue
		else
			humanoid.JumpHeight = Settings.Movement.JumpValue
		end
	end

	if Settings.Movement.GravityEnabled then
		Workspace.Gravity = Settings.Movement.GravityValue
	elseif Workspace.Gravity ~= defaultGravity then
		Workspace.Gravity = defaultGravity
	end

	if Settings.Movement.NoclipEnabled then
		setNoclipState(character, true)
	end

	updateSpinTroll()

	local trollTarget = getTrollTarget()
	if trollTarget and trollTarget.Character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local targetHRP = trollTarget.Character:FindFirstChild("HumanoidRootPart")
		if hrp and targetHRP then
			if Settings.Troll.OrbitTarget then
				local angle = tick() * Settings.Troll.OrbitSpeed
				local radius = Settings.Troll.OrbitRadius
				hrp.CFrame = targetHRP.CFrame * CFrame.new(math.cos(angle) * radius, 3, math.sin(angle) * radius)
				hrp.AssemblyLinearVelocity = Vector3.zero
			elseif Settings.Troll.HeadSit then
				local head = trollTarget.Character:FindFirstChild("Head")
				if head then
					hrp.CFrame = head.CFrame * CFrame.new(0, 2.2, 0)
					hrp.AssemblyLinearVelocity = Vector3.zero
				end
			end

			if Settings.Troll.ConstantFling then
				hrp.CFrame = targetHRP.CFrame
				applyFlingForce(Settings.Troll.FlingPower)
			end
		end
	elseif Settings.Troll.ConstantFling then
		clearFlingForce()
	end

	if spectating and spectateTarget then
		local hum = spectateTarget.Character and spectateTarget.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			Camera.CameraSubject = hum
		else
			stopSpectate()
		end
	end
end))

trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
	releaseAutoShoot()
	task.wait(0.2)
	table.clear(originalTransparency)
	updateInvisibleState()
	if Settings.Movement.NoclipEnabled then
		setNoclipState(char, true)
	end
end))

function updateFlyState(enabled)
	if not enabled then
		if flyConnection then flyConnection:Disconnect() flyConnection = nil end
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		return
	end

	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = rootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	flyConnection = RunService.RenderStepped:Connect(function()
		local internalChar = LocalPlayer.Character
		if not internalChar or not bodyVelocity or not bodyGyro then return end
		local internalRoot = internalChar:FindFirstChild("HumanoidRootPart")
		local internalHumanoid = internalChar:FindFirstChildOfClass("Humanoid")
		if not internalRoot or not internalHumanoid then return end

		bodyGyro.CFrame = Camera.CFrame
		local moveDirection = internalHumanoid.MoveDirection
		local velocity = moveDirection * Settings.Movement.FlySpeed

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			velocity = velocity + Vector3.new(0, Settings.Movement.FlySpeed, 0)
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			velocity = velocity + Vector3.new(0, -Settings.Movement.FlySpeed, 0)
		end

		bodyVelocity.Velocity = velocity
	end)
end

function applyCharms(player)
	if player == LocalPlayer then return end

	player.CharacterAdded:Connect(function(char)
		if not scriptActive then return end
		invalidateCharacterCache(player)
		lastCharacterScan = 0
		task.wait(0.35)
		if not scriptActive then return end
		if updateESP then updateESP() end
		if Settings.Movement.NoclipEnabled and player == LocalPlayer then
			setNoclipState(char, true)
		end
	end)

	player.CharacterRemoving:Connect(function()
		if not scriptActive then return end
		invalidateCharacterCache(player)
		lastCharacterScan = 0
		cleanupWorldEsp(player)
		hidePlayerDrawings(player)
	end)
end


disableAllFeatures = function(silent)
	Settings.Aim.Enabled = false
	Settings.Aim.SilentAim = false
	Settings.Aim.TriggerbotEnabled = false
	Settings.Aim.AutoShootEnabled = false
	Settings.Aim.CrosshairEnabled = false
	Settings.Aim.VelocityResolver = false
	Settings.ESP.CharmsEnabled = false
	Settings.ESP.BoxESP = false
	Settings.ESP.NameESP = false
	Settings.ESP.Tracers = false
	Settings.ESP.ShowDistance = false
	Settings.ESP.SkeletonESP = false
	Settings.Movement.SpeedEnabled = false
	Settings.Movement.JumpEnabled = false
	Settings.Movement.FlyEnabled = false
	Settings.Movement.NoclipEnabled = false
	Settings.Movement.InfiniteJump = false
	Settings.Movement.GravityEnabled = false
	Settings.Troll.ConstantFling = false
	Settings.Troll.OrbitTarget = false
	Settings.Troll.HeadSit = false
	Settings.Troll.SpinTroll = false
	Settings.Troll.Invisible = false

	releaseAutoShoot()
	currentTargetPlayer = nil
	lastAimTargetPlayer = nil
	toggleActive = false
	isAming = false
	isShooting = false
	endAimCameraCapture()
	restoreCameraType()

	if LocalPlayer.Character and setNoclipState then
		setNoclipState(LocalPlayer.Character, false)
	end
	pcall(function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
			if hum.UseJumpPower then
				hum.JumpPower = 50
			else
				hum.JumpHeight = 7
			end
		end
	end)
	Workspace.Gravity = defaultGravity

	if updateFlyState then updateFlyState(false) end
	if clearFlingForce then clearFlingForce() end
	if clearSpinTroll then clearSpinTroll() end
	if updateInvisibleState then updateInvisibleState() end
	if updateLightingState then updateLightingState() end
	if refreshAllCharms then refreshAllCharms() end
	if updateESP then updateESP() end
	if refreshLockHud then refreshLockHud() end
	if stopSpectate then stopSpectate() end

	local toggleSync = {
		{"Enable Aimbot", Settings.Aim.Enabled},
		{"Silent Aim", Settings.Aim.SilentAim},
		{"Triggerbot", Settings.Aim.TriggerbotEnabled},
		{"Auto Shoot", Settings.Aim.AutoShootEnabled},
		{"Crosshair Overlay", Settings.Aim.CrosshairEnabled},
		{"Velocity Resolver", Settings.Aim.VelocityResolver},
		{"Enable Charms", Settings.ESP.CharmsEnabled},
		{"Box ESP", Settings.ESP.BoxESP},
		{"Name ESP", Settings.ESP.NameESP},
		{"Tracers", Settings.ESP.Tracers},
		{"Distance ESP", Settings.ESP.ShowDistance},
		{"Skeleton ESP", Settings.ESP.SkeletonESP},
		{"Speed Hack", Settings.Movement.SpeedEnabled},
		{"Jump Height Modifier", Settings.Movement.JumpEnabled},
		{"Fly Mode", Settings.Movement.FlyEnabled},
		{"Noclip", Settings.Movement.NoclipEnabled},
		{"Infinite Jump", Settings.Movement.InfiniteJump},
		{"Custom Gravity", Settings.Movement.GravityEnabled},
		{"Constant Fling", Settings.Troll.ConstantFling},
		{"Orbit Target", Settings.Troll.OrbitTarget},
		{"Head Sit", Settings.Troll.HeadSit},
		{"Spin Troll", Settings.Troll.SpinTroll},
		{"Invisible Character", Settings.Troll.Invisible},
	}
	for _, entry in ipairs(toggleSync) do
		syncToggleFromBind(entry[1], entry[2])
	end

	if fovCircle then
		fovCircle.Visible = false
	end
	if updateCrosshairOverlay then
		updateCrosshairOverlay()
	end

	if not silent then
		showActionToast("All features disabled", Color3.fromRGB(220, 70, 70))
	end
end

unloadONICheats = function()
	if not scriptActive then
		return
	end
	scriptActive = false
	menuOpen = false
	KeybindCaptureActive = false

	notify("ONICheats", "Script unloaded.", 3)
	disableAllFeatures(true)
	releaseAutoShoot()

	pcall(function() RunService:UnbindFromRenderStep("ONICheatsAim") end)
	pcall(function() RunService:UnbindFromRenderStep("ONICheatsAimLate") end)
	pcall(function() RunService:UnbindFromRenderStep("ONICheatsAimFinal") end)

	if aimRuntimeConnection then
		pcall(function() aimRuntimeConnection:Disconnect() end)
		aimRuntimeConnection = nil
	end
	if flyConnection then
		pcall(function() flyConnection:Disconnect() end)
		flyConnection = nil
	end
	restoreMouseState()

	for _, conn in ipairs(runtimeConnections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(runtimeConnections)

	if hookmetamethod then
		if savedMetamethodHooks.namecall then
			pcall(function() hookmetamethod(game, "__namecall", savedMetamethodHooks.namecall) end)
		end
		if savedMetamethodHooks.index then
			pcall(function() hookmetamethod(game, "__index", savedMetamethodHooks.index) end)
		end
	end

	if refreshAllCharms then
		refreshAllCharms()
	end
	for player in pairs(espDrawings) do
		cleanupPlayerDrawings(player)
	end

	if fovCircle then
		pcall(function() fovCircle:Remove() end)
		fovCircle = nil
	end
	if lockIndicator then
		pcall(function() lockIndicator:Remove() end)
		lockIndicator = nil
	end
	for i, line in ipairs(crosshairDrawings) do
		if line then
			pcall(function() line:Remove() end)
			crosshairDrawings[i] = nil
		end
	end

	local function destroyNamedGui(parent, names)
		if not parent then
			return
		end
		for _, name in ipairs(names) do
			local inst = parent:FindFirstChild(name)
			if inst then
				inst:Destroy()
			end
		end
	end

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	destroyNamedGui(playerGui, ONI_GUI_NAMES)
	pcall(function()
		if gethui then
			local hui = gethui()
			destroyNamedGui(hui, ONI_GUI_NAMES)
		end
	end)
	table.clear(velocityHistory)

	ScreenGui = nil
	EspScreen = nil
	LockStatusGui = nil
	BindToastGui = nil
	MenuShell = nil
	MainFrame = nil

	endAimCameraCapture()
	restoreCameraType()
	restoreGameCamera()
	stopSpectate()
	clearFlingForce()
	clearSpinTroll()
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	Workspace.Gravity = defaultGravity
	updateLightingState()

	if LocalPlayer.Character and setNoclipState then
		setNoclipState(LocalPlayer.Character, false)
	end
end

function refreshAllCharms()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			for _, child in ipairs(p.Character:GetDescendants()) do
				if child.Name == "ONI_HighlightESP" or child.Name == "ONI_NameESP" or child.Name == "ONI_BoxESP" then
					child:Destroy()
				end
			end
		end
	end
	for player, data in pairs(espWorld) do
		cleanupWorldEsp(player)
	end
	lastCharacterScan = 0
	lastEspFullScan = 0
	updateESP()
end

trackConnection(Players.PlayerAdded:Connect(function(player)
	applyCharms(player)
	lastCharacterScan = 0
	lastEspFullScan = 0
	invalidateCharacterCache(player)
	task.defer(function()
		if not scriptActive then return end
		scanWorkspaceCharacters()
		if updateESP then updateESP() end
	end)
end))
trackConnection(Players.PlayerRemoving:Connect(function(player)
	cleanupPlayerDrawings(player)
	cleanupWorldEsp(player)
	velocityHistory[player.UserId] = nil
end))

for _, p in ipairs(Players:GetPlayers()) do applyCharms(p) end
end

local function initGameplaySystems()
	initGpCore()
end

local function loadUI()

local function createDisclaimer(tabName, text)
	local Row = Instance.new("Frame")
	Row.Name = "Disclaimer"
	Row.Size = UDim2.new(1, 0, 0, 0)
	Row.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	Row.BackgroundTransparency = 0.25
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -20, 0, 36)
	Label.Position = UDim2.new(0, 10, 0, 4)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(125, 127, 135)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 10
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Top
	Label.Parent = Row

	Row.Size = UDim2.new(1, 0, 0, math.max(32, Label.TextBounds.Y + 10))
	Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
		Row.Size = UDim2.new(1, 0, 0, math.max(32, Label.TextBounds.Y + 10))
	end)
end

local function createArsenalNote(tabName, text)
	local Row = Instance.new("Frame")
	Row.Name = "ArsenalNote"
	Row.Size = UDim2.new(1, 0, 0, 0)
	Row.BackgroundColor3 = Color3.fromRGB(28, 18, 14)
	Row.BackgroundTransparency = 0.45
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -20, 0, 36)
	Label.Position = UDim2.new(0, 10, 0, 4)
	Label.BackgroundTransparency = 1
	Label.Text = "Game tip · " .. text
	Label.TextColor3 = Color3.fromRGB(235, 155, 105)
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 10
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Top
	Label.Parent = Row

	Row.Size = UDim2.new(1, 0, 0, math.max(32, Label.TextBounds.Y + 10))
	Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
		Row.Size = UDim2.new(1, 0, 0, math.max(32, Label.TextBounds.Y + 10))
	end)
end

local function createToggle(tabName, label, configPath, callback, disclaimer)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 44)
	Row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(0.65, 0, 1, 0)
	Text.Position = UDim2.new(0, 14, 0, 0)
	Text.BackgroundTransparency = 1
	Text.Text = label
	Text.TextColor3 = Color3.fromRGB(236, 236, 242)
	Text.Font = Enum.Font.GothamMedium
	Text.TextSize = 12
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.Parent = Row

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
	ToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
	ToggleBtn.Text = ""
	ToggleBtn.Parent = Row
	Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

	local Dot = Instance.new("Frame")
	Dot.Size = UDim2.new(0, 16, 0, 16)
	Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Dot.Parent = ToggleBtn
	Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

	local defaultState = Settings[configPath[1]][configPath[2]]
	ToggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(220, 20, 40) or Color3.fromRGB(35, 35, 40)
	Dot.Position = defaultState and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)

	local function setVisualState(state)
		Settings[configPath[1]][configPath[2]] = state
		local targetColor = state and Color3.fromRGB(220, 20, 40) or Color3.fromRGB(35, 35, 40)
		local targetPos = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
		TweenService:Create(ToggleBtn, TweenInfo.new(0.12), {BackgroundColor3 = targetColor}):Play()
		TweenService:Create(Dot, TweenInfo.new(0.12), {Position = targetPos}):Play()
	end

	ToggleBtn.MouseButton1Click:Connect(function()
		local state = not Settings[configPath[1]][configPath[2]]
		setVisualState(state)
		callback(state)
	end)

	UIComponents.Toggles[label] = {Path = configPath, Toggle = setVisualState}
	if disclaimer then createDisclaimer(tabName, disclaimer) end
end

local function createCycleSelector(tabName, label, options, configPath, callback, disclaimer)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 44)
	Row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(0.5, -10, 1, 0)
	Text.Position = UDim2.new(0, 12, 0, 0)
	Text.BackgroundTransparency = 1
	Text.Text = label
	Text.TextColor3 = Color3.fromRGB(230, 230, 235)
	Text.Font = Enum.Font.GothamMedium
	Text.TextSize = 12
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.Parent = Row

	local CycleBtn = Instance.new("TextButton")
	CycleBtn.Size = UDim2.new(0, 130, 0, 26)
	CycleBtn.Position = UDim2.new(1, -142, 0.5, -13)
	CycleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	CycleBtn.Text = tostring(Settings[configPath[1]][configPath[2]])
	CycleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	CycleBtn.Font = Enum.Font.GothamBold
	CycleBtn.TextSize = 11
	CycleBtn.Parent = Row
	Instance.new("UICorner", CycleBtn).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", CycleBtn).Color = Color3.fromRGB(45, 45, 50)

	local function updateSelector(newVal)
		Settings[configPath[1]][configPath[2]] = newVal
		CycleBtn.Text = tostring(newVal)
	end

	CycleBtn.MouseButton1Click:Connect(function()
		local currentOpt = Settings[configPath[1]][configPath[2]]
		local currentIndex = table.find(options, currentOpt) or 1
		currentIndex = currentIndex % #options + 1
		updateSelector(options[currentIndex])
		callback(options[currentIndex])
	end)

	UIComponents.Selectors[label] = {Path = configPath, Update = updateSelector}
	if disclaimer then createDisclaimer(tabName, disclaimer) end
end

local function formatSliderValue(value, min, max)
	if max <= 1 and min < 1 then
		return string.format("%.2f", value)
	end
	if math.floor(value) == value then
		return tostring(value)
	end
	return string.format("%.2f", value)
end

local function createSlider(tabName, label, min, max, configPath, callback, disclaimer)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 60)
	Row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

	local defaultVal = Settings[configPath[1]][configPath[2]]
	if defaultVal == nil then defaultVal = min end

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(0.55, 0, 0, 22)
	Text.Position = UDim2.new(0, 12, 0, 4)
	Text.BackgroundTransparency = 1
	Text.Text = label
	Text.TextColor3 = Color3.fromRGB(230, 230, 235)
	Text.Font = Enum.Font.GothamMedium
	Text.TextSize = 12
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.TextTruncate = Enum.TextTruncate.AtEnd
	Text.Parent = Row

	local ValLabel = Instance.new("TextLabel")
	ValLabel.AnchorPoint = Vector2.new(1, 0)
	ValLabel.Size = UDim2.new(0.4, -16, 0, 22)
	ValLabel.Position = UDim2.new(1, -12, 0, 4)
	ValLabel.BackgroundTransparency = 1
	ValLabel.Text = formatSliderValue(defaultVal, min, max)
	ValLabel.TextColor3 = Color3.fromRGB(220, 20, 40)
	ValLabel.Font = Enum.Font.GothamBold
	ValLabel.TextSize = 13
	ValLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValLabel.Parent = Row

	local SlideTrack = Instance.new("TextButton")
	SlideTrack.Size = UDim2.new(1, -24, 0, 16)
	SlideTrack.Position = UDim2.new(0, 12, 0, 34)
	SlideTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	SlideTrack.AutoButtonColor = false
	SlideTrack.Text = ""
	SlideTrack.Parent = Row
	Instance.new("UICorner", SlideTrack).CornerRadius = UDim.new(0, 4)

	local SlideFill = Instance.new("Frame")
	local span = math.max(max - min, 0.0001)
	local initPercent = (defaultVal - min) / span
	SlideFill.Size = UDim2.new(math.clamp(initPercent, 0, 1), 0, 1, 0)
	SlideFill.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
	SlideFill.BorderSizePixel = 0
	SlideFill.Parent = SlideTrack
	Instance.new("UICorner", SlideFill).CornerRadius = UDim.new(0, 4)

	local function setSliderValue(value)
		value = math.clamp(value, min, max)
		Settings[configPath[1]][configPath[2]] = value
		local percent = (value - min) / span
		SlideFill.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
		ValLabel.Text = formatSliderValue(value, min, max)
	end

	local isDragging = false
	local function updateSliderInput(input)
		if SlideTrack.AbsoluteSize.X <= 0 then return end
		local xOffset = math.clamp(input.Position.X - SlideTrack.AbsolutePosition.X, 0, SlideTrack.AbsoluteSize.X)
		local alpha = xOffset / SlideTrack.AbsoluteSize.X
		local rawValue = min + (alpha * (max - min))
		local finalValue = (max > 50) and math.floor(rawValue) or math.floor(rawValue * 100 + 0.5) / 100

		setSliderValue(finalValue)
		callback(finalValue)
	end

	SlideTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			updateSliderInput(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSliderInput(input) end
	end)

	UIComponents.Sliders[label] = {Path = configPath, Update = setSliderValue}
	if disclaimer then createDisclaimer(tabName, disclaimer) end
end

local function createColorChart(tabName, label, callback)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 62)
	Row.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(0.4, 0, 1, 0)
	Text.Position = UDim2.new(0, 12, 0, 0)
	Text.BackgroundTransparency = 1
	Text.Text = label
	Text.TextColor3 = Color3.fromRGB(230, 230, 235)
	Text.Font = Enum.Font.GothamMedium
	Text.TextSize = 12
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.Parent = Row

	local ColorContainer = Instance.new("Frame")
	ColorContainer.Size = UDim2.new(0, 190, 0, 45)
	ColorContainer.Position = UDim2.new(1, -202, 0.5, -22)
	ColorContainer.BackgroundTransparency = 1
	ColorContainer.Parent = Row

	local UIGrid = Instance.new("UIGridLayout")
	UIGrid.CellSize = UDim2.new(0, 19, 0, 19)
	UIGrid.CellPadding = UDim2.new(0, 5, 0, 5)
	UIGrid.Parent = ColorContainer

	local presetColors = {
		Color3.fromRGB(220, 20, 40), Color3.fromRGB(255, 120, 0), Color3.fromRGB(255, 220, 0),
		Color3.fromRGB(0, 230, 120), Color3.fromRGB(0, 180, 255), Color3.fromRGB(160, 0, 255),
		Color3.fromRGB(255, 0, 200), Color3.fromRGB(255, 255, 255),
	}

	for _, color in ipairs(presetColors) do
		local ColorPatch = Instance.new("TextButton")
		ColorPatch.Text = ""
		ColorPatch.BackgroundColor3 = color
		ColorPatch.Parent = ColorContainer
		Instance.new("UICorner", ColorPatch).CornerRadius = UDim.new(0, 3)

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = (color == Settings.ESP.Color) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
		stroke.Parent = ColorPatch

		ColorPatch.MouseButton1Click:Connect(function()
			for _, child in ipairs(ColorContainer:GetChildren()) do
				if child:IsA("TextButton") and child:FindFirstChild("UIStroke") then
					child.UIStroke.Color = Color3.fromRGB(0, 0, 0)
				end
			end
			stroke.Color = Color3.fromRGB(255, 255, 255)
			callback(color)
		end)
	end
end

local function createBindKeybinder(tabName, label, path, disclaimer)
	UIComponents.BindKeys = UIComponents.BindKeys or {}

	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 44)
	Row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	Row.Parent = Containers[tabName]
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(0.5, 0, 1, 0)
	Text.Position = UDim2.new(0, 14, 0, 0)
	Text.BackgroundTransparency = 1
	Text.Text = label
	Text.TextColor3 = Color3.fromRGB(236, 236, 242)
	Text.Font = Enum.Font.GothamMedium
	Text.TextSize = 12
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.Parent = Row

	local BindBtn = Instance.new("TextButton")
	BindBtn.Size = UDim2.new(0, 120, 0, 26)
	BindBtn.Position = UDim2.new(1, -132, 0.5, -13)
	BindBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	BindBtn.Text = formatBindLabel(Settings[path[1]][path[2]])
	BindBtn.TextColor3 = Color3.fromRGB(220, 20, 40)
	BindBtn.Font = Enum.Font.Code
	BindBtn.TextSize = 11
	BindBtn.Parent = Row
	Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", BindBtn).Color = Color3.fromRGB(45, 45, 50)

	local function setBindValue(value)
		Settings[path[1]][path[2]] = value
		BindBtn.Text = formatBindLabel(value)
		BindBtn.TextColor3 = Color3.fromRGB(220, 20, 40)
	end

	UIComponents.BindKeys[label] = {
		Path = path,
		Update = setBindValue,
	}

	local parsing = false
	BindBtn.MouseButton1Click:Connect(function()
		parsing = true
		KeybindCaptureActive = true
		BindBtn.Text = "..."
		BindBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
	end)

	BindBtn.MouseButton2Click:Connect(function()
		parsing = false
		KeybindCaptureActive = false
		setBindValue(false)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not parsing then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
				parsing = false
				KeybindCaptureActive = false
				setBindValue(false)
				return
			end
			parsing = false
			KeybindCaptureActive = false
			setBindValue(input.KeyCode)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then
			parsing = false
			KeybindCaptureActive = false
			setBindValue(input.UserInputType)
		end
	end)

	if disclaimer then
		createDisclaimer(tabName, disclaimer)
	end
end

local function createActionButton(tabName, label, callback, disclaimer)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 34)
	Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	Btn.Text = label
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 11
	Btn.Parent = Containers[tabName]
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", Btn).Color = Color3.fromRGB(45, 45, 50)
	Btn.MouseButton1Click:Connect(callback)
	if disclaimer then createDisclaimer(tabName, disclaimer) end
end

local function populateAimTab()

createActionButton("Aim", "JAILBIRD PRESET", function()
	applyFPSPreset()
	refreshLockHud()
end, "Quick preset: FOV 125, smooth 0.05, charms only, hold-RMB aim. Overwrites current aim/visual settings.")

createDisclaimer("Aim",
	"Aim features depend on your executor. Mouse aim needs mousemoverel or VirtualInputManager. Silent aim needs hook support.")

createToggle("Aim", "Enable Aimbot", {"Aim", "Enabled"}, function() end,
	"Activates aim lock. With Hold mode, keep your aim key pressed (default: Right Click).")

createCycleSelector("Aim", "Aim Lock Mode", {"Hold", "Toggle", "Always On"}, {"Aim", "LockMode"}, function() toggleActive = false end,
	"Hold = aim while key is pressed. Toggle = press once to lock on/off. Always On = constant lock.")

createBindKeybinder("Aim", "Aim Hold Key", {"Aim", "Keybind"},
	"Key or mouse button used for Hold/Toggle aim. Right-click the bind box to clear.")

createCycleSelector("Aim", "Aim Method", {"Auto", "Mouse", "Camera"}, {"Aim", "AimMethod"}, function() end,
	"Mouse moves your cursor (best for FPS). Camera rotates view directly. Auto picks the best available.")

createArsenalNote("Aim", "Arsenal/Jailbird: use Mouse on Xeno. Auto is fine if mousemoverel is detected.")

createToggle("Aim", "Use Screen Center FOV", {"Aim", "UseScreenCenter"}, function() end,
	"Uses screen center instead of cursor for FOV checks. ON for fixed crosshair games; OFF for free-cursor games.")

createArsenalNote("Aim", "Arsenal: OFF. Jailbird: ON.")

createToggle("Aim", "Aim While Shooting (LMB)", {"Aim", "AimWhileShooting"}, function() end,
	"Keeps aim active while left-clicking. Useful when the game does not register your aim hold key.")

createArsenalNote("Aim", "Arsenal: OFF if you hold RMB to aim and LMB to shoot separately.")

createToggle("Aim", "Pause Aim While Shooting", {"Aim", "FreezeAimWhileShooting"}, function() end,
	"Temporarily stops aim pull while firing. Reduces jitter on games where shooting fights mouse movement.")

createArsenalNote("Aim", "Arsenal: ON if you get shake while firing.")

createToggle("Aim", "Auto Shoot", {"Aim", "AutoShootEnabled"}, function(enabled)
	if not enabled then
		releaseAutoShoot()
	end
end, "Automatically clicks for you. Requires VirtualInputManager or mouse1click. May not work in every game.")

createCycleSelector("Aim", "Auto Shoot When", {"On Lock", "In FOV", "While Aiming"}, {"Aim", "AutoShootMode"}, function() end,
	"On Lock = fires at your locked target. In FOV = fires at best FOV target. While Aiming = fires whenever aim key is active.")

createCycleSelector("Aim", "Auto Shoot Mode", {"Tap", "Hold"}, {"Aim", "AutoShootFireMode"}, function()
	releaseAutoShoot()
end, "Tap = repeated clicks (semi-auto/burst). Hold = holds left click (full-auto weapons).")

createSlider("Aim", "Shot Interval", 0.05, 0.35, {"Aim", "AutoShootInterval"}, function() end,
	"Delay between tap shots. Lower = faster firing. Only applies when Auto Shoot Mode is Tap.")

createToggle("Aim", "Auto Shoot Wall Check", {"Aim", "AutoShootWallCheck"}, function() end,
	"Only auto-shoots at targets you can see. Turn OFF to shoot through walls (not recommended).")

createToggle("Aim", "Show Lock Status Bar", {"Aim", "ShowLockHud"}, function()
	if refreshLockHud then refreshLockHud() end
end, "Shows a small status bar at the top with lock state and hints.")

createToggle("Aim", "Silent Aim", {"Aim", "SilentAim"}, function() end,
	"Redirects shots without moving camera. Requires hookmetamethod/namecall support in your executor.")

createArsenalNote("Aim", "Leave OFF unless you specifically need silent redirect.")

createCycleSelector("Aim", "Silent Aim Mode", {"On Shoot", "Hold", "Always"}, {"Aim", "SilentAimMode"}, function() end,
	"On Shoot = redirect on click. Hold = only while aiming. Always = every shot.")

createToggle("Aim", "Snap On Lock", {"Aim", "SnapOnLock"}, function() end,
	"Snaps instantly when acquiring a new target. OFF = fully smooth tracking only.")

createArsenalNote("Aim", "ON helps first contact; OFF is smoother on strafing targets.")

createToggle("Aim", "Sticky Lock", {"Aim", "StickyLock"}, function() end,
	"Briefly keeps lock when a target moves behind cover instead of dropping immediately.")

createCycleSelector("Aim", "Target Bone", {"Head", "HumanoidRootPart", "UpperTorso"}, {"Aim", "TargetPart"}, function() end,
	"Head = precision. HumanoidRootPart = center mass. UpperTorso = stable on R15 rigs.")

createToggle("Aim", "Auto Target Switch", {"Aim", "AutoSwitch"}, function() end,
	"Automatically switches to a better target when your current target is no longer valid.")

createCycleSelector("Aim", "Target Priority", {"FOV", "Distance", "FOV+Distance"}, {"Aim", "TargetMode"}, function() end,
	"FOV = nearest to crosshair. Distance = nearest in studs. FOV+Distance = balanced mix of both.")

createSlider("Aim", "Aim Smoothness", 0, 1.0, {"Aim", "Smoothness"}, function() end,
	"Lower = faster/snappier pull. Higher = slower/smoother. Too low may overshoot strafing targets.")

createArsenalNote("Aim", "Start around 0.2–0.35 for Arsenal. Jailbird preset uses 0.05.")

createSlider("Aim", "Prediction", 0, 0.5, {"Aim", "Prediction"}, function() end,
	"Leads moving targets. Effect varies by game hit detection; many games ignore this.")

createArsenalNote("Aim", "Use 0 unless you know the game supports lead prediction.")

createSlider("Aim", "FOV Radius", 30, 600, {"Aim", "FOV"}, function() end,
	"Screen radius for target selection. Larger = easier to acquire; smaller = more precise.")

createArsenalNote("Aim", "150–200 is a balanced range for most shooters.")

createToggle("Aim", "Toggle FOV Circle", {"Aim", "ShowFOV"}, function() end,
	"Draws an on-screen FOV ring. Requires the Drawing library (not available on all executors).")

createToggle("Aim", "Wall Check", {"Aim", "WallCheck"}, function() end,
	"Only targets visible enemies. Map geometry blocks lock; player models are ignored in ray checks.")

createArsenalNote("Aim", "Keep ON for legit-style targeting.")

createToggle("Aim", "Team Check", {"Aim", "TeamCheck"}, function() end,
	"Skips teammates when the game uses Roblox Teams. May not work in FFA or single-team modes.")

createArsenalNote("Aim", "Turn OFF in FFA modes where everyone shares one team.")

createToggle("Aim", "Triggerbot", {"Aim", "TriggerbotEnabled"}, function() end,
	"Fires when your crosshair is over an enemy hitbox within the set pixel radius. Requires VirtualInputManager or mouse1click.")

createSlider("Aim", "Triggerbot Radius", 5, 80, {"Aim", "TriggerbotRadius"}, function() end,
	"Pixel radius around the crosshair to detect enemy hitboxes. Smaller = more precise.")

createSlider("Aim", "Triggerbot Delay", 0, 0.5, {"Aim", "TriggerbotDelay"}, function() end,
	"Minimum delay between triggerbot shots in seconds.")

createToggle("Aim", "Triggerbot Wall Check", {"Aim", "TriggerbotWallCheck"}, function() end,
	"Only fires when the target is visible. Turn OFF to shoot through walls (not recommended).")

createToggle("Aim", "Gun Only Shoot", {"Aim", "GunOnlyShoot"}, function() end,
	"When ON, auto shoot and triggerbot only work while a Tool (weapon) is equipped.")

createToggle("Aim", "Velocity Resolver", {"Aim", "VelocityResolver"}, function() end,
	"Tracks velocity changes per player for improved prediction on strafing targets.")

createSlider("Aim", "Resolver Strength", 0.5, 2, {"Aim", "ResolverStrength"}, function() end,
	"How aggressively velocity deltas are applied. Higher = more lead on direction changes.")

createToggle("Aim", "Crosshair Overlay", {"Aim", "CrosshairEnabled"}, function() end,
	"Draws a simple crosshair at screen center. Requires the Drawing library.")

createSlider("Aim", "Crosshair Size", 4, 24, {"Aim", "CrosshairSize"}, function() end,
	"Length of each crosshair arm in pixels.")

createColorChart("Aim", "Crosshair Color", function(v) Settings.Aim.CrosshairColor = v end)

createColorChart("Aim", "FOV Circle Color", function(v)
	Settings.Aim.FOVColor = v
	if fovCircle then
		fovCircle.Color = v
	end
end)

createToggle("Aim", "Hit Notify On Lock", {"Misc", "HitNotifyLock"}, function() end,
	"Shows a toast when a new aim target is acquired.")

createToggle("Aim", "Hit Notify On Shot", {"Misc", "HitNotifyShot"}, function() end,
	"Shows a toast when triggerbot fires at a target.")

end

local function populateVisualsTab()
createDisclaimer("Visuals",
	"ESP is client-side only. Some games remove Highlights or use custom character rigs. Re-execute after spawning if ESP does not appear.")

createCycleSelector("Visuals", "ESP Render Mode", {"Auto", "World3D", "Drawing", "Both"}, {"ESP", "ESPMode"}, function()
	updateESP()
end, "Auto = picks best method. World3D = in-world highlights. Drawing = 2D overlay. Both = combined fallback.")

createArsenalNote("Visuals", "Charms-only setup: Auto or World3D. Use Both if one method fails.")

createToggle("Visuals", "Enable Charms", {"ESP", "CharmsEnabled"}, function() refreshAllCharms(); updateESP() end,
	"Highlight outline on players. If charms disappear, the game may be stripping Highlights — try Box ESP or re-execute.")

createArsenalNote("Visuals", "Recommended ON for Jailbird/Arsenal.")

createToggle("Visuals", "Box ESP", {"ESP", "BoxESP"}, function() updateESP() end,
	"Draws boxes around players. Drawing mode needs the Drawing API; World3D mode works on most standard rigs.")

createArsenalNote("Visuals", "OFF if you only want clean charms.")

createToggle("Visuals", "Name ESP", {"ESP", "NameESP"}, function() updateESP() end,
	"Shows player names. May fail on custom rigs without a standard Head part.")

createToggle("Visuals", "Tracers", {"ESP", "Tracers"}, function() updateESP() end,
	"Lines from screen bottom to players. Drawing tracers can hide behind fullscreen UI.")

createToggle("Visuals", "Distance ESP", {"ESP", "ShowDistance"}, function() updateESP() end,
	"Shows distance in meters. Works best with Name ESP enabled in World3D mode.")

createToggle("Visuals", "Skeleton ESP", {"ESP", "SkeletonESP"}, function() updateESP() end,
	"Bone lines between body parts. Drawing only — requires Drawing API and standard R6/R15 rigs.")

createToggle("Visuals", "Show Teammates", {"ESP", "TeamVisible"}, function() refreshAllCharms(); updateESP() end,
	"Shows friendly players. Turn ON in team modes; in FFA everyone may appear as the same team.")

createArsenalNote("Visuals", "Turn ON in FFA if enemies are hidden by team filtering.")

createColorChart("Visuals", "ESP Color", function(v) Settings.ESP.Color = v; refreshAllCharms(); updateESP() end)

createToggle("Visuals", "Team Color ESP", {"ESP", "TeamColorEnabled"}, function() refreshAllCharms(); updateESP() end,
	"Uses separate colors for teammates and enemies instead of the default ESP color.")

createColorChart("Visuals", "Enemy Color", function(v) Settings.ESP.EnemyColor = v; refreshAllCharms(); updateESP() end)

createColorChart("Visuals", "Team Color", function(v) Settings.ESP.TeamColor = v; refreshAllCharms(); updateESP() end)

createDisclaimer("Visuals",
	"If ESP still fails, switch render mode to Both and re-execute. Custom avatars may only support charms or boxes.")

end

local function populateMovementTab()
createDisclaimer("Movement",
	"All movement features are client-side. Competitive or server-authoritative games may reset or ignore these values.")

createToggle("Movement", "Speed Hack", {"Movement", "SpeedEnabled"}, function(v)
	if not v then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end
end, "Changes local WalkSpeed. Many live games force default speed every frame.")

createSlider("Movement", "WalkSpeed Modifier", 16, 250, {"Movement", "SpeedValue"}, function() end)

createToggle("Movement", "Jump Height Modifier", {"Movement", "JumpEnabled"}, function(v)
	if not v then
		pcall(function()
			local hum = LocalPlayer.Character.Humanoid
			if hum.UseJumpPower then hum.JumpPower = 50 else hum.JumpHeight = 7 end
		end)
	end
end, "Adjusts jump power/height locally. Games using custom jump systems may override this.")

createSlider("Movement", "JumpPower Value", 7, 500, {"Movement", "JumpValue"}, function() end)

createToggle("Movement", "Infinite Jump", {"Movement", "InfiniteJump"}, function() end,
	"Allows repeated jumps in mid-air. Blocked by some anti-cheat and custom movement scripts.")

createToggle("Movement", "Fly Mode", {"Movement", "FlyEnabled"}, function(v) updateFlyState(v) end,
	"Local flight using legacy physics movers. Can be unstable or patched on newer games.")

createSlider("Movement", "Flight Speed", 10, 300, {"Movement", "FlySpeed"}, function() end)

createToggle("Movement", "Noclip", {"Movement", "NoclipEnabled"}, function(v)
	if not v and LocalPlayer.Character then setNoclipState(LocalPlayer.Character, false) end
end, "Disables collision on your character locally. Server-sided barriers may still block you.")

createToggle("Movement", "Custom Gravity", {"Movement", "GravityEnabled"}, function(v)
	if not v then Workspace.Gravity = defaultGravity end
end, "Changes local gravity. Server-controlled physics will ignore or revert this.")

createSlider("Movement", "Gravity Value", 0, 500, {"Movement", "GravityValue"}, function() end)

end

local function populatePlayersTab()
local WhitelistCountLabel = nil
local WhitelistListLabel = nil

local function teleportToPlayer(targetPlayer)
	local localChar = LocalPlayer.Character
	local targetChar = targetPlayer.Character
	if not localChar or not targetChar then return end
	local localRoot = localChar:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if localRoot and targetRoot then
		localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
	end
end

local function toggleWhitelist(player)
	if type(Settings.Misc.Whitelist) ~= "table" then
		Settings.Misc.Whitelist = {}
	end
	local uid = player.UserId
	for i, id in ipairs(Settings.Misc.Whitelist) do
		if id == uid or tonumber(id) == uid then
			table.remove(Settings.Misc.Whitelist, i)
			if refreshWhitelistSection then refreshWhitelistSection() end
			if updateESP then updateESP() end
			refreshPlayerList()
			return
		end
	end
	table.insert(Settings.Misc.Whitelist, uid)
	if refreshWhitelistSection then refreshWhitelistSection() end
	if updateESP then updateESP() end
	refreshPlayerList()
end

refreshWhitelistSection = function()
	if not WhitelistCountLabel or not WhitelistListLabel then
		return
	end
	local list = Settings.Misc.Whitelist or {}
	local count = #list
	WhitelistCountLabel.Text = "Whitelisted: " .. tostring(count)

	if count == 0 then
		WhitelistListLabel.Text = "No whitelisted players."
		return
	end

	local names = {}
	for _, uid in ipairs(list) do
		local numUid = tonumber(uid) or uid
		local foundName = "UserId " .. tostring(uid)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.UserId == numUid then
				foundName = plr.DisplayName
				break
			end
		end
		table.insert(names, foundName)
	end
	WhitelistListLabel.Text = table.concat(names, ", ")
end

local function refreshPlayerList()
	for _, child in ipairs(Containers.Players:GetChildren()) do
		if child:IsA("Frame") and child.Name == "PlayerRow" then child:Destroy() end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		local row = Instance.new("Frame")
		row.Name = "PlayerRow"
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		row.Parent = Containers.Players
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.28, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 12, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.DisplayName
		nameLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
		nameLabel.Font = Enum.Font.GothamMedium
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		local wlBtn = Instance.new("TextButton")
		wlBtn.Size = UDim2.new(0, 44, 0, 24)
		wlBtn.Position = UDim2.new(1, -250, 0.5, -12)
		wlBtn.BackgroundColor3 = isPlayerWhitelisted(player) and Color3.fromRGB(70, 180, 90) or Color3.fromRGB(28, 28, 34)
		wlBtn.Text = isPlayerWhitelisted(player) and "WL+" or "WL"
		wlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		wlBtn.Font = Enum.Font.GothamBold
		wlBtn.TextSize = 9
		wlBtn.Parent = row
		Instance.new("UICorner", wlBtn).CornerRadius = UDim.new(0, 4)
		Instance.new("UIStroke", wlBtn).Color = Color3.fromRGB(45, 45, 50)
		wlBtn.MouseButton1Click:Connect(function()
			toggleWhitelist(player)
		end)

		local voteBtn = Instance.new("TextButton")
		voteBtn.Size = UDim2.new(0, 50, 0, 24)
		voteBtn.Position = UDim2.new(1, -200, 0.5, -12)
		voteBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
		voteBtn.Text = "VOTE"
		voteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		voteBtn.Font = Enum.Font.GothamBold
		voteBtn.TextSize = 9
		voteBtn.Parent = row
		Instance.new("UICorner", voteBtn).CornerRadius = UDim.new(0, 4)
		voteBtn.MouseButton1Click:Connect(function()
			attemptVoteKick(player)
		end)

		local tpBtn = Instance.new("TextButton")
		tpBtn.Size = UDim2.new(0, 50, 0, 24)
		tpBtn.Position = UDim2.new(1, -144, 0.5, -12)
		tpBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
		tpBtn.Text = "TP"
		tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 10
		tpBtn.Parent = row
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
		tpBtn.MouseButton1Click:Connect(function() teleportToPlayer(player) end)

		local specBtn = Instance.new("TextButton")
		specBtn.Size = UDim2.new(0, 50, 0, 24)
		specBtn.Position = UDim2.new(1, -88, 0.5, -12)
		specBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
		specBtn.Text = "SPEC"
		specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		specBtn.Font = Enum.Font.GothamBold
		specBtn.TextSize = 10
		specBtn.Parent = row
		Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 4)
		Instance.new("UIStroke", specBtn).Color = Color3.fromRGB(45, 45, 50)
		specBtn.MouseButton1Click:Connect(function()
			if spectating and spectateTarget == player then
				stopSpectate()
			else
				startSpectate(player)
			end
		end)
	end
end

local WhitelistHeader = Instance.new("TextLabel")
WhitelistHeader.Size = UDim2.new(1, 0, 0, 25)
WhitelistHeader.BackgroundTransparency = 1
WhitelistHeader.Text = "  FRIEND WHITELIST"
WhitelistHeader.TextColor3 = Color3.fromRGB(130, 130, 135)
WhitelistHeader.Font = Enum.Font.GothamBold
WhitelistHeader.TextSize = 10
WhitelistHeader.TextXAlignment = Enum.TextXAlignment.Left
WhitelistHeader.Parent = Containers.Players

local WhitelistPanel = Instance.new("Frame")
WhitelistPanel.Size = UDim2.new(1, 0, 0, 56)
WhitelistPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
WhitelistPanel.Parent = Containers.Players
Instance.new("UICorner", WhitelistPanel).CornerRadius = UDim.new(0, 4)

WhitelistCountLabel = Instance.new("TextLabel")
WhitelistCountLabel.Size = UDim2.new(1, -24, 0, 18)
WhitelistCountLabel.Position = UDim2.new(0, 12, 0, 6)
WhitelistCountLabel.BackgroundTransparency = 1
WhitelistCountLabel.Text = "Whitelisted: 0"
WhitelistCountLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
WhitelistCountLabel.Font = Enum.Font.GothamBold
WhitelistCountLabel.TextSize = 11
WhitelistCountLabel.TextXAlignment = Enum.TextXAlignment.Left
WhitelistCountLabel.Parent = WhitelistPanel

WhitelistListLabel = Instance.new("TextLabel")
WhitelistListLabel.Size = UDim2.new(1, -24, 0, 28)
WhitelistListLabel.Position = UDim2.new(0, 12, 0, 24)
WhitelistListLabel.BackgroundTransparency = 1
WhitelistListLabel.Text = "No whitelisted players."
WhitelistListLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
WhitelistListLabel.Font = Enum.Font.GothamMedium
WhitelistListLabel.TextSize = 10
WhitelistListLabel.TextXAlignment = Enum.TextXAlignment.Left
WhitelistListLabel.TextWrapped = true
WhitelistListLabel.TextTruncate = Enum.TextTruncate.AtEnd
WhitelistListLabel.Parent = WhitelistPanel

createDisclaimer("Players",
	"Whitelist skips players in aim, ESP, and triggerbot. Player tools are local-only. Vote kick requires a compatible remote.")

createActionButton("Players", "REFRESH PLAYER LIST", refreshPlayerList)

createActionButton("Players", "STOP SPECTATING", stopSpectate,
	"Returns your camera to normal. Games with forced custom cameras may override spectate.")
refreshWhitelistSection()
refreshPlayerList()
trackConnection(Players.PlayerAdded:Connect(function()
	if not scriptActive then return end
	refreshPlayerList()
	updateTrollTargetLabel()
end))
trackConnection(Players.PlayerRemoving:Connect(function(player)
	if not scriptActive then return end
	refreshPlayerList()
	updateTrollTargetLabel()
	if spectateTarget == player then stopSpectate() end
end))

end

local function populateTrollTab()
local TrollHeader = Instance.new("TextLabel")
TrollHeader.Size = UDim2.new(1, 0, 0, 25)
TrollHeader.BackgroundTransparency = 1
TrollHeader.Text = "  TROLL TARGET"
TrollHeader.TextColor3 = Color3.fromRGB(130, 130, 135)
TrollHeader.Font = Enum.Font.GothamBold
TrollHeader.TextSize = 10
TrollHeader.TextXAlignment = Enum.TextXAlignment.Left
TrollHeader.Parent = Containers.Troll

local TrollTargetRow = Instance.new("Frame")
TrollTargetRow.Size = UDim2.new(1, 0, 0, 42)
TrollTargetRow.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TrollTargetRow.Parent = Containers.Troll
Instance.new("UICorner", TrollTargetRow).CornerRadius = UDim.new(0, 4)

trollTargetLabel = Instance.new("TextLabel")
trollTargetLabel.Size = UDim2.new(0.55, 0, 1, 0)
trollTargetLabel.Position = UDim2.new(0, 12, 0, 0)
trollTargetLabel.BackgroundTransparency = 1
trollTargetLabel.Text = "No Players Found"
trollTargetLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
trollTargetLabel.Font = Enum.Font.GothamMedium
trollTargetLabel.TextSize = 11
trollTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
trollTargetLabel.TextTruncate = Enum.TextTruncate.AtEnd
trollTargetLabel.Parent = TrollTargetRow

local CycleTargetBtn = Instance.new("TextButton")
CycleTargetBtn.Size = UDim2.new(0, 130, 0, 26)
CycleTargetBtn.Position = UDim2.new(1, -142, 0.5, -13)
CycleTargetBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
CycleTargetBtn.Text = "NEXT TARGET"
CycleTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CycleTargetBtn.Font = Enum.Font.GothamBold
CycleTargetBtn.TextSize = 10
CycleTargetBtn.Parent = TrollTargetRow
Instance.new("UICorner", CycleTargetBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", CycleTargetBtn).Color = Color3.fromRGB(45, 45, 50)
CycleTargetBtn.MouseButton1Click:Connect(function()
	cycleTrollTarget()
	updateTrollTargetLabel()
end)
updateTrollTargetLabel()

createDisclaimer("Troll",
	"Troll features use local physics tricks. Most live games block or rubber-band these. Use in private servers for testing.")

createSlider("Troll", "Fling Power", 100000, 1000000, {"Troll", "FlingPower"}, function() end,
	"Higher values hit harder but increase lag and detection risk.")
createSlider("Troll", "Orbit Radius", 3, 30, {"Troll", "OrbitRadius"}, function() end)
createSlider("Troll", "Orbit Speed", 1, 20, {"Troll", "OrbitSpeed"}, function() end)

createActionButton("Troll", "ONE-TIME FLING", function()
	flingTargetOnce(getTrollTarget())
end, "Single fling using local velocity. You must be near the target. Often patched on main games.")
createToggle("Troll", "Constant Fling", {"Troll", "ConstantFling"}, function(v)
	if not v then clearFlingForce() end
end, "Repeats fling every frame. Very laggy, easy to detect, and may crash physics.")
createActionButton("Troll", "FLING ALL PLAYERS", flingAllPlayers,
	"Attempts to fling every player sequentially. Heavy on performance; protected players may not move.")
createActionButton("Troll", "YEET TARGET UP", function()
	yeetTargetUp(getTrollTarget())
end, "Launches the target upward locally. Other players may not see the same movement.")
createActionButton("Troll", "SLAM TARGET DOWN", function()
	task.spawn(function() slamTargetDown(getTrollTarget()) end)
end, "Teleports above target then slams down. Anti-teleport games will rubber-band this.")
createActionButton("Troll", "BRING TARGET TO ME", function()
	bringTargetToMe(getTrollTarget())
end, "Pulls target toward you using local physics only — not a true server-side teleport.")
createToggle("Troll", "Orbit Target", {"Troll", "OrbitTarget"}, function(v)
	if v then
		Settings.Troll.HeadSit = false
		if UIComponents.Toggles["Head Sit"] then UIComponents.Toggles["Head Sit"].Toggle(false) end
	end
end, "Orbits your character around the target each frame. Filtered games will snap you back.")
createToggle("Troll", "Head Sit", {"Troll", "HeadSit"}, function(v)
	if v then
		Settings.Troll.OrbitTarget = false
		if UIComponents.Toggles["Orbit Target"] then UIComponents.Toggles["Orbit Target"].Toggle(false) end
	end
end, "Positions you above the target's head locally. Others may see you elsewhere.")
createToggle("Troll", "Spin Troll", {"Troll", "SpinTroll"}, function(v)
	if not v then clearSpinTroll() end
end, "Spins your character rapidly. Can cause random flings on contact.")
createToggle("Troll", "Invisible Character", {"Troll", "Invisible"}, function()
	updateInvisibleState()
end, "Hides your character on your screen only. Other players usually still see you.")

end

local function populateMiscTab(menuGui)
local MiscRow = Instance.new("Frame")
MiscRow.Size = UDim2.new(1, 0, 0, 42)
MiscRow.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MiscRow.Parent = Containers.Misc
Instance.new("UICorner", MiscRow).CornerRadius = UDim.new(0, 4)

local FpsTitle = Instance.new("TextLabel")
FpsTitle.Size = UDim2.new(0.4, 0, 1, 0)
FpsTitle.Position = UDim2.new(0, 12, 0, 0)
FpsTitle.BackgroundTransparency = 1
FpsTitle.Text = "Show Performance FPS"
FpsTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
FpsTitle.Font = Enum.Font.GothamMedium
FpsTitle.TextSize = 11
FpsTitle.TextXAlignment = Enum.TextXAlignment.Left
FpsTitle.Parent = MiscRow

local FpsValueLabel = Instance.new("TextLabel")
FpsValueLabel.Size = UDim2.new(0.25, 0, 1, 0)
FpsValueLabel.Position = UDim2.new(1, -120, 0, 0)
FpsValueLabel.BackgroundTransparency = 1
FpsValueLabel.Text = "Checking..."
FpsValueLabel.TextColor3 = Color3.fromRGB(220, 20, 40)
FpsValueLabel.Font = Enum.Font.Code
FpsValueLabel.TextSize = 11
FpsValueLabel.TextXAlignment = Enum.TextXAlignment.Right
FpsValueLabel.Parent = MiscRow

local FpsToggleBtn = Instance.new("TextButton")
FpsToggleBtn.Size = UDim2.new(0, 44, 0, 22)
FpsToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
FpsToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
FpsToggleBtn.Text = ""
FpsToggleBtn.Parent = MiscRow
Instance.new("UICorner", FpsToggleBtn).CornerRadius = UDim.new(1, 0)

local FpsDot = Instance.new("Frame")
FpsDot.Size = UDim2.new(0, 16, 0, 16)
FpsDot.Position = UDim2.new(1, -20, 0.5, -8)
FpsDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FpsDot.Parent = FpsToggleBtn
Instance.new("UICorner", FpsDot).CornerRadius = UDim.new(1, 0)

FpsToggleBtn.MouseButton1Click:Connect(function()
	Settings.Misc.FpsCounter = not Settings.Misc.FpsCounter
	local targetColor = Settings.Misc.FpsCounter and Color3.fromRGB(220, 20, 40) or Color3.fromRGB(35, 35, 40)
	local targetPos = Settings.Misc.FpsCounter and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
	TweenService:Create(FpsToggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
	TweenService:Create(FpsDot, TweenInfo.new(0.15), {Position = targetPos}):Play()
	if not Settings.Misc.FpsCounter then FpsValueLabel.Text = "Disabled" end
end)

local lastTick = os.clock()
local frameCount = 0
trackConnection(RunService.Heartbeat:Connect(function()
	if not scriptActive or not Settings.Misc.FpsCounter then return end
	frameCount = frameCount + 1
	local currentTick = os.clock()
	local delta = currentTick - lastTick
	if delta >= 0.5 then
		FpsValueLabel.Text = tostring(math.floor(frameCount / delta)) .. " FPS"
		frameCount = 0
		lastTick = currentTick
	end
end))

createToggle("Misc", "Top Most UI", {"Misc", "TopMostUI"}, function()
	applyTopMostUI(menuGui)
end, "Keeps the menu above in-game UI layers. Uses gethui when your executor supports it.")
createToggle("Misc", "Unlock Mouse On Menu", {"Misc", "UnlockMouseOnMenu"}, function(enabled)
	if not enabled then
		restoreMouseState()
	end
end, "Frees your cursor while the menu is open. Helpful in games that lock the mouse.")
createDisclaimer("Misc",
	"Custom logo: place ONICheats_Logo.png in your executor workspace, or set a Roblox image asset ID in settings.")
createToggle("Misc", "Fullbright", {"Misc", "Fullbright"}, function() updateLightingState() end,
	"Brightens lighting locally. Map scripts may override lighting every frame.")
createToggle("Misc", "Remove Fog", {"Misc", "NoFog"}, function() updateLightingState() end,
	"Removes fog locally. Custom Atmosphere effects may still appear hazy.")
createToggle("Misc", "Anti AFK", {"Misc", "AntiAFK"}, function() end,
	"Prevents idle kick using VirtualUser. Not supported or effective in every game.")

createToggle("Misc", "Stream Proof Mode", {"Misc", "StreamProof"}, function()
	applyTopMostUI(menuGui)
	if EspScreen and EspScreen.Parent then
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui then
			EspScreen.Parent = playerGui
		end
	end
	if updateESP then updateESP() end
	if updateCrosshairOverlay then updateCrosshairOverlay() end
	if fovCircle then
		fovCircle.Visible = not isStreamProofActive() and Settings.Aim.Enabled and Settings.Aim.ShowFOV
	end
	if lockIndicator then
		lockIndicator.Visible = false
	end
end, "Hides Drawing overlays and parents UI to PlayerGui only (not gethui) for stream capture tools.")

local MenuKeyRow = Instance.new("Frame")
MenuKeyRow.Size = UDim2.new(1, 0, 0, 42)
MenuKeyRow.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MenuKeyRow.Parent = Containers.Misc
Instance.new("UICorner", MenuKeyRow).CornerRadius = UDim.new(0, 4)

local MenuKeyText = Instance.new("TextLabel")
MenuKeyText.Size = UDim2.new(0.5, 0, 1, 0)
MenuKeyText.Position = UDim2.new(0, 12, 0, 0)
MenuKeyText.BackgroundTransparency = 1
MenuKeyText.Text = "Menu Toggle Key"
MenuKeyText.TextColor3 = Color3.fromRGB(230, 230, 235)
MenuKeyText.Font = Enum.Font.GothamMedium
MenuKeyText.TextSize = 12
MenuKeyText.TextXAlignment = Enum.TextXAlignment.Left
MenuKeyText.Parent = MenuKeyRow

MenuKeyBtnRef = Instance.new("TextButton")
local MenuKeyBtn = MenuKeyBtnRef
MenuKeyBtn.Size = UDim2.new(0, 120, 0, 26)
MenuKeyBtn.Position = UDim2.new(1, -132, 0.5, -13)
MenuKeyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
MenuKeyBtn.Text = Settings.Misc.MenuKeybind.Name
MenuKeyBtn.TextColor3 = Color3.fromRGB(220, 20, 40)
MenuKeyBtn.Font = Enum.Font.Code
MenuKeyBtn.TextSize = 11
MenuKeyBtn.Parent = MenuKeyRow
Instance.new("UICorner", MenuKeyBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", MenuKeyBtn).Color = Color3.fromRGB(45, 45, 50)

local parsingMenuKey = false
MenuKeyBtn.MouseButton1Click:Connect(function()
	parsingMenuKey = true
	KeybindCaptureActive = true
	MenuKeyBtn.Text = "..."
	MenuKeyBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
end)

UserInputService.InputBegan:Connect(function(input)
	if parsingMenuKey and input.UserInputType == Enum.UserInputType.Keyboard then
		parsingMenuKey = false
		KeybindCaptureActive = false
		Settings.Misc.MenuKeybind = input.KeyCode
		MenuKeyBtn.Text = input.KeyCode.Name
		MenuKeyBtn.TextColor3 = Color3.fromRGB(220, 20, 40)
	end
end)

local KeybindsHeader = Instance.new("TextLabel")
KeybindsHeader.Size = UDim2.new(1, 0, 0, 25)
KeybindsHeader.BackgroundTransparency = 1
KeybindsHeader.Text = "  TOGGLE KEYBINDS"
KeybindsHeader.TextColor3 = Color3.fromRGB(130, 130, 135)
KeybindsHeader.Font = Enum.Font.GothamBold
KeybindsHeader.TextSize = 10
KeybindsHeader.TextXAlignment = Enum.TextXAlignment.Left
KeybindsHeader.Parent = Containers.Misc

createDisclaimer("Misc",
	"Hotkeys start unbound. Click a bind box to set a key, right-click or Escape to clear. Binds save with your profile.")

createBindKeybinder("Misc", "Toggle Aimbot", {"Binds", "AimToggle"},
	"Toggles aimbot on/off without opening the menu.")

createBindKeybinder("Misc", "Toggle Noclip", {"Binds", "NoclipToggle"},
	"Toggles noclip on/off.")

createBindKeybinder("Misc", "Toggle Fly", {"Binds", "FlyToggle"},
	"Toggles fly mode on/off.")

createBindKeybinder("Misc", "Toggle Charms ESP", {"Binds", "EspToggle"},
	"Toggles charms ESP on/off.")

createBindKeybinder("Misc", "Toggle Triggerbot", {"Binds", "TriggerbotToggle"},
	"Toggles triggerbot on/off without opening the menu.")

createBindKeybinder("Misc", "Panic Key", {"Binds", "PanicKey"},
	"Instantly disables all features on press. Action key, not a toggle.")

createActionButton("Misc", "RESPAWN CHARACTER", function()
	if LocalPlayer.Character then
		LocalPlayer.Character:BreakJoints()
	end
end, "Forces a local respawn. Custom spawn systems may ignore this.")

createActionButton("Misc", "REJOIN SERVER", function()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end, "Rejoins the current server. Requires TeleportService support from your executor.")

createToggle("Misc", "Auto Load Config", {"Misc", "AutoLoadConfig"}, function(enabled)
	setAutoLoadEnabled(enabled)
end, "Automatically loads your active profile each time you execute the script.")

local ConfigHeader = Instance.new("TextLabel")
ConfigHeader.Size = UDim2.new(1, 0, 0, 25)
ConfigHeader.BackgroundTransparency = 1
ConfigHeader.Text = "  NAMED CONFIG PROFILES"
ConfigHeader.TextColor3 = Color3.fromRGB(130, 130, 135)
ConfigHeader.Font = Enum.Font.GothamBold
ConfigHeader.TextSize = 10
ConfigHeader.TextXAlignment = Enum.TextXAlignment.Left
ConfigHeader.Parent = Containers.Misc

local ConfigPanel = Instance.new("Frame")
ConfigPanel.Size = UDim2.new(1, 0, 0, 168)
ConfigPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ConfigPanel.ClipsDescendants = true
ConfigPanel.Parent = Containers.Misc
Instance.new("UICorner", ConfigPanel).CornerRadius = UDim.new(0, 4)

ConfigStatusLabelRef = Instance.new("TextLabel")
ConfigStatusLabelRef.Size = UDim2.new(1, -24, 0, 16)
ConfigStatusLabelRef.Position = UDim2.new(0, 12, 0, 6)
ConfigStatusLabelRef.BackgroundTransparency = 1
ConfigStatusLabelRef.Text = hasFileSystem and "Name a profile and save per game" or "Unsupported File Engine"
ConfigStatusLabelRef.TextColor3 = Color3.fromRGB(150, 150, 155)
ConfigStatusLabelRef.Font = Enum.Font.GothamMedium
ConfigStatusLabelRef.TextSize = 11
ConfigStatusLabelRef.TextXAlignment = Enum.TextXAlignment.Left
ConfigStatusLabelRef.Parent = ConfigPanel

ConfigNameInputRef = Instance.new("TextBox")
ConfigNameInputRef.Size = UDim2.new(1, -24, 0, 26)
ConfigNameInputRef.Position = UDim2.new(0, 12, 0, 24)
ConfigNameInputRef.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ConfigNameInputRef.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigNameInputRef.PlaceholderText = "Config name (e.g. Jailbird, Arsenal)"
ConfigNameInputRef.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
ConfigNameInputRef.Font = Enum.Font.GothamMedium
ConfigNameInputRef.TextSize = 12
ConfigNameInputRef.ClearTextOnFocus = false
ConfigNameInputRef.Text = ""
ConfigNameInputRef.Parent = ConfigPanel
Instance.new("UICorner", ConfigNameInputRef).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", ConfigNameInputRef).PaddingLeft = UDim.new(0, 8)

ConfigListLabelRef = Instance.new("TextLabel")
ConfigListLabelRef.Size = UDim2.new(1, -24, 0, 14)
ConfigListLabelRef.Position = UDim2.new(0, 12, 0, 52)
ConfigListLabelRef.BackgroundTransparency = 1
ConfigListLabelRef.Text = "Saved profiles"
ConfigListLabelRef.TextColor3 = Color3.fromRGB(120, 120, 125)
ConfigListLabelRef.Font = Enum.Font.Gotham
ConfigListLabelRef.TextSize = 10
ConfigListLabelRef.TextXAlignment = Enum.TextXAlignment.Left
ConfigListLabelRef.Parent = ConfigPanel

ConfigDropdownBtnRef = Instance.new("TextButton")
ConfigDropdownBtnRef.Size = UDim2.new(1, -24, 0, 26)
ConfigDropdownBtnRef.Position = UDim2.new(0, 12, 0, 66)
ConfigDropdownBtnRef.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ConfigDropdownBtnRef.Text = "Select profile..."
ConfigDropdownBtnRef.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigDropdownBtnRef.Font = Enum.Font.GothamMedium
ConfigDropdownBtnRef.TextSize = 11
ConfigDropdownBtnRef.TextXAlignment = Enum.TextXAlignment.Left
ConfigDropdownBtnRef.Parent = ConfigPanel
Instance.new("UICorner", ConfigDropdownBtnRef).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", ConfigDropdownBtnRef).Color = Color3.fromRGB(45, 45, 50)
Instance.new("UIPadding", ConfigDropdownBtnRef).PaddingLeft = UDim.new(0, 8)

local DropdownArrow = Instance.new("TextLabel")
DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
DropdownArrow.Position = UDim2.new(1, -24, 0, 0)
DropdownArrow.BackgroundTransparency = 1
DropdownArrow.Text = "▼"
DropdownArrow.TextColor3 = Color3.fromRGB(180, 180, 185)
DropdownArrow.Font = Enum.Font.GothamBold
DropdownArrow.TextSize = 10
DropdownArrow.Parent = ConfigDropdownBtnRef

ConfigDropdownListRef = Instance.new("ScrollingFrame")
ConfigDropdownListRef.Size = UDim2.new(1, -24, 0, 0)
ConfigDropdownListRef.Position = UDim2.new(0, 12, 0, 94)
ConfigDropdownListRef.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ConfigDropdownListRef.BorderSizePixel = 0
ConfigDropdownListRef.ScrollBarThickness = 4
ConfigDropdownListRef.Visible = false
ConfigDropdownListRef.ZIndex = 5
ConfigDropdownListRef.CanvasSize = UDim2.new(0, 0, 0, 0)
ConfigDropdownListRef.Parent = ConfigPanel
Instance.new("UICorner", ConfigDropdownListRef).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", ConfigDropdownListRef).Color = Color3.fromRGB(45, 45, 50)

local ConfigDropdownLayout = Instance.new("UIListLayout")
ConfigDropdownLayout.Padding = UDim.new(0, 2)
ConfigDropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigDropdownLayout.Parent = ConfigDropdownListRef
ConfigDropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	if ConfigDropdownListRef then
		ConfigDropdownListRef.CanvasSize = UDim2.new(0, 0, 0, ConfigDropdownLayout.AbsoluteContentSize.Y + 4)
	end
end)

ConfigNameInputRef.FocusLost:Connect(function()
	if ConfigNameInputRef.Text ~= "" and ConfigDropdownBtnRef then
		ConfigDropdownBtnRef.Text = ConfigNameInputRef.Text
	end
end)

local SaveNamedBtn = Instance.new("TextButton")
SaveNamedBtn.Size = UDim2.new(0.32, -6, 0, 24)
SaveNamedBtn.Position = UDim2.new(0, 12, 0, 98)
SaveNamedBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
SaveNamedBtn.Text = "SAVE"
SaveNamedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveNamedBtn.Font = Enum.Font.GothamBold
SaveNamedBtn.TextSize = 10
SaveNamedBtn.Parent = ConfigPanel
Instance.new("UICorner", SaveNamedBtn).CornerRadius = UDim.new(0, 4)

local LoadNamedBtn = Instance.new("TextButton")
LoadNamedBtn.Size = UDim2.new(0.32, -6, 0, 24)
LoadNamedBtn.Position = UDim2.new(0.34, 0, 0, 98)
LoadNamedBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
LoadNamedBtn.Text = "LOAD"
LoadNamedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadNamedBtn.Font = Enum.Font.GothamBold
LoadNamedBtn.TextSize = 10
LoadNamedBtn.Parent = ConfigPanel
Instance.new("UICorner", LoadNamedBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", LoadNamedBtn).Color = Color3.fromRGB(45, 45, 50)

local DeleteNamedBtn = Instance.new("TextButton")
DeleteNamedBtn.Size = UDim2.new(0.32, -6, 0, 24)
DeleteNamedBtn.Position = UDim2.new(0.68, -6, 0, 98)
DeleteNamedBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
DeleteNamedBtn.Text = "DELETE"
DeleteNamedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteNamedBtn.Font = Enum.Font.GothamBold
DeleteNamedBtn.TextSize = 10
DeleteNamedBtn.Parent = ConfigPanel
Instance.new("UICorner", DeleteNamedBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", DeleteNamedBtn).Color = Color3.fromRGB(45, 45, 50)

local LinkGameBtn = Instance.new("TextButton")
LinkGameBtn.Size = UDim2.new(1, -24, 0, 24)
LinkGameBtn.Position = UDim2.new(0, 12, 0, 128)
LinkGameBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
LinkGameBtn.Text = "LINK TO THIS GAME (auto-load on execute)"
LinkGameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LinkGameBtn.Font = Enum.Font.GothamBold
LinkGameBtn.TextSize = 10
LinkGameBtn.Parent = ConfigPanel
Instance.new("UICorner", LinkGameBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", LinkGameBtn).Color = Color3.fromRGB(45, 45, 50)

local function setConfigDropdownOpen(open)
	configDropdownOpen = open
	if ConfigDropdownListRef then
		ConfigDropdownListRef.Visible = open
		ConfigDropdownListRef.Size = open and UDim2.new(1, -24, 0, 80) or UDim2.new(1, -24, 0, 0)
	end
	if DropdownArrow then
		DropdownArrow.Text = open and "▲" or "▼"
	end
	local actionY = open and 180 or 98
	SaveNamedBtn.Position = UDim2.new(0, 12, 0, actionY)
	LoadNamedBtn.Position = UDim2.new(0.34, 0, 0, actionY)
	DeleteNamedBtn.Position = UDim2.new(0.68, -6, 0, actionY)
	LinkGameBtn.Position = UDim2.new(0, 12, 0, actionY + 30)
	ConfigPanel.Size = UDim2.new(1, 0, 0, open and 244 or 168)
end
ConfigDropdownLayoutFn = setConfigDropdownOpen

local function flashConfigStatus(msg, color)
	setConfigStatus(msg, color)
	task.delay(2, function()
		if ConfigStatusLabelRef then
			ConfigStatusLabelRef.TextColor3 = Color3.fromRGB(150, 150, 155)
			ConfigStatusLabelRef.Text = hasFileSystem and "Name a profile and save per game" or "Unsupported File Engine"
		end
	end)
end

ConfigDropdownBtnRef.MouseButton1Click:Connect(function()
	if #listSavedConfigs() == 0 then
		flashConfigStatus("No saved profiles yet — type a name and SAVE", Color3.fromRGB(255, 170, 80))
		return
	end
	setConfigDropdownOpen(not configDropdownOpen)
	if configDropdownOpen then
		populateConfigDropdown()
	end
end)

SaveNamedBtn.MouseButton1Click:Connect(function()
	setConfigDropdownOpen(false)
	local msg = saveNamedConfiguration(getConfigNameFromInput())
	flashConfigStatus(msg, msg:find("^Saved:") and Color3.fromRGB(0, 230, 120) or Color3.fromRGB(255, 120, 80))
end)

LoadNamedBtn.MouseButton1Click:Connect(function()
	setConfigDropdownOpen(false)
	local msg = loadNamedConfiguration(getConfigNameFromInput())
	flashConfigStatus(msg, msg:find("^Loaded:") and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(255, 120, 80))
end)

DeleteNamedBtn.MouseButton1Click:Connect(function()
	setConfigDropdownOpen(false)
	local msg = deleteNamedConfiguration(getConfigNameFromInput())
	flashConfigStatus(msg, msg:find("^Deleted:") and Color3.fromRGB(255, 170, 80) or Color3.fromRGB(255, 120, 80))
end)

LinkGameBtn.MouseButton1Click:Connect(function()
	local name = getConfigNameFromInput()
	local saveMsg = saveNamedConfiguration(name)
	if not saveMsg:find("^Saved:") then
		flashConfigStatus(saveMsg, Color3.fromRGB(255, 120, 80))
		return
	end
	local msg = linkConfigToCurrentGame(name)
	flashConfigStatus(msg, Color3.fromRGB(0, 230, 120))
end)

task.defer(function()
	local index = getConfigIndex()
	if ConfigNameInputRef and index.active then
		ConfigNameInputRef.Text = index.active
	end
	refreshSavedConfigList(index.active)
end)

createDisclaimer("Misc",
	"Profiles save to ONICheats_Configs in your executor workspace. LINK TO THIS GAME auto-loads that profile when you join.")

end

local function buildUserInterface()

local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 15)
if not playerGui then
	warn("[ONICheats] PlayerGui not found - menu cannot load.")
	return nil
end

for _, name in ipairs(ONI_GUI_NAMES) do
	local old = playerGui:FindFirstChild(name)
	if old then old:Destroy() end
	if gethui then
		pcall(function()
			local hui = gethui()
			local oldHui = hui and hui:FindFirstChild(name)
			if oldHui then oldHui:Destroy() end
		end)
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "ONICheatsUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Enabled = true
gui.Parent = playerGui

MenuShell = Instance.new("Frame")
MenuShell.Name = "MenuShell"
MenuShell.Size = UDim2.new(0, 480, 0, 600)
MenuShell.Position = UDim2.new(0.5, -240, 0.5, -300)
MenuShell.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MenuShell.BackgroundTransparency = 0
MenuShell.BorderSizePixel = 0
MenuShell.ClipsDescendants = true
MenuShell.Visible = false
MenuShell.Parent = gui

local ShellCorner = Instance.new("UICorner")
ShellCorner.CornerRadius = UDim.new(0, 10)
ShellCorner.Parent = MenuShell

local ShellStroke = Instance.new("UIStroke")
ShellStroke.Color = Color3.fromRGB(220, 20, 40)
ShellStroke.Thickness = 1.5
ShellStroke.Transparency = 0.12
pcall(function()
	ShellStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end)
ShellStroke.Parent = MenuShell

MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, -3, 1, -3)
MainFrame.Position = UDim2.new(0, 1.5, 0, 1.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MenuShell

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 20)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(12, 12, 15)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10)),
})
MainGradient.Rotation = 100
MainGradient.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Header.ClipsDescendants = true
Header.ZIndex = 2
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local HeaderBottomFill = Instance.new("Frame")
HeaderBottomFill.Name = "HeaderBottomFill"
HeaderBottomFill.Size = UDim2.new(1, 0, 0, 10)
HeaderBottomFill.Position = UDim2.new(0, 0, 1, -10)
HeaderBottomFill.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
HeaderBottomFill.BorderSizePixel = 0
HeaderBottomFill.ZIndex = 0
HeaderBottomFill.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 17)),
})
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
HeaderDivider.BackgroundTransparency = 0.55
HeaderDivider.BorderSizePixel = 0
HeaderDivider.ZIndex = 2
HeaderDivider.Parent = Header

LogoImageRef = Instance.new("ImageLabel")
LogoImageRef.Name = "ONILogo"
LogoImageRef.Size = UDim2.new(0, 40, 0, 40)
LogoImageRef.Position = UDim2.new(0, 10, 0.5, -20)
LogoImageRef.BackgroundTransparency = 1
LogoImageRef.ScaleType = Enum.ScaleType.Fit
LogoImageRef.ImageTransparency = 0
LogoImageRef.Parent = Header

local logoLoaded = applyLogoImage(LogoImageRef)
if not logoLoaded and not logoWarnShown then
	logoWarnShown = true
	notify("ONICheats", "Logo not found. Place ONICheats_Logo.png in your executor workspace.")
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, logoLoaded and 56 or 15, 0, 0)
Title.BackgroundTransparency = 1
Title.RichText = true
Title.Text = '<font color="rgb(220,20,40)">ONI</font><font color="rgb(255,255,255)">Cheats</font>'
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(0, 250, 1, 0)
Credit.Position = UDim2.new(1, -46, 0, 0)
Credit.AnchorPoint = Vector2.new(1, 0)
Credit.BackgroundTransparency = 1
Credit.Text = "Cracked and key removed by EvolEzod"
Credit.TextColor3 = Color3.fromRGB(130, 130, 135)
Credit.Font = Enum.Font.GothamMedium
Credit.TextSize = 11
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -10, 0.5, -14)
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(210, 210, 215)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 17
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 4
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(55, 55, 62)
closeStroke.Thickness = 1
closeStroke.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
	CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
	CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
CloseBtn.MouseLeave:Connect(function()
	CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	CloseBtn.TextColor3 = Color3.fromRGB(210, 210, 215)
end)
CloseBtn.MouseButton1Click:Connect(function()
	if unloadONICheats then
		unloadONICheats()
	end
end)

local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, -100, 1, 0)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.ZIndex = 3
DragHandle.Parent = Header

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 38)
TabBar.Position = UDim2.new(0, 0, 0, 54)
TabBar.BackgroundColor3 = Color3.fromRGB(16, 16, 19)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 2
TabBar.Parent = MainFrame

local TabBarDivider = Instance.new("Frame")
TabBarDivider.Size = UDim2.new(1, 0, 0, 1)
TabBarDivider.Position = UDim2.new(0, 0, 1, -1)
TabBarDivider.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
TabBarDivider.BorderSizePixel = 0
TabBarDivider.ZIndex = 1
TabBarDivider.Parent = TabBar

Containers = {
	Aim = Instance.new("ScrollingFrame"),
	Visuals = Instance.new("ScrollingFrame"),
	Movement = Instance.new("ScrollingFrame"),
	Players = Instance.new("ScrollingFrame"),
	Troll = Instance.new("ScrollingFrame"),
	Misc = Instance.new("ScrollingFrame"),
}

for name, scroller in pairs(Containers) do
	scroller.Size = UDim2.new(1, -28, 1, -112)
	scroller.Position = UDim2.new(0, 14, 0, 98)
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 3
	scroller.ScrollBarImageColor3 = Color3.fromRGB(220, 20, 40)
	scroller.Visible = false
	scroller.Parent = MainFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroller

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)
end

local activeTab = "Aim"
Containers[activeTab].Visible = true

local tabIndicators = {}

local function setActiveTabVisual(name)
	for tabName, parts in pairs(tabIndicators) do
		local active = tabName == name
		parts.Btn.TextColor3 = active and Color3.fromRGB(220, 20, 40) or Color3.fromRGB(165, 165, 172)
		parts.Indicator.Visible = active
		parts.Indicator.BackgroundTransparency = active and 0 or 1
	end
end

local TAB_COUNT = 6

local function createTabButton(name, order)
	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(1 / TAB_COUNT, 0, 1, 0)
	TabBtn.Position = UDim2.new((order - 1) / TAB_COUNT, 0, 0, 0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.Text = string.upper(name)
	TabBtn.Font = Enum.Font.GothamBold
	TabBtn.TextSize = 11
	TabBtn.ZIndex = 3
	TabBtn.AutoButtonColor = false
	TabBtn.TextColor3 = (name == activeTab) and Color3.fromRGB(220, 20, 40) or Color3.fromRGB(165, 165, 172)
	TabBtn.Parent = TabBar

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0.72, 0, 0, 2)
	Indicator.Position = UDim2.new(0.14, 0, 1, -3)
	Indicator.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
	Indicator.BorderSizePixel = 0
	Indicator.Visible = name == activeTab
	Indicator.ZIndex = 4
	Indicator.Parent = TabBtn
	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

	tabIndicators[name] = {Btn = TabBtn, Indicator = Indicator}

	TabBtn.MouseButton1Click:Connect(function()
		for _, scroller in pairs(Containers) do scroller.Visible = false end
		activeTab = name
		Containers[name].Visible = true
		setActiveTabVisual(name)
	end)
end

createTabButton("Aim", 1)
createTabButton("Visuals", 2)
createTabButton("Movement", 3)
createTabButton("Players", 4)
createTabButton("Troll", 5)
createTabButton("Misc", 6)

local dragging = false
local dragStart, startPos

DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MenuShell.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MenuShell.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)


populateAimTab()
populateVisualsTab()
populateMovementTab()
populatePlayersTab()
populateTrollTab()
populateMiscTab(gui)

return gui
end

return buildUserInterface()
end

local function launchONICheats()
local startupOk, startupErr = pcall(function()
initGameplaySystems()

trackConnection(LocalPlayer.Idled:Connect(function()
	if not scriptActive then return end
	if Settings.Misc.AntiAFK then
		VirtualUser:CaptureFocus()
		VirtualUser:ClickButton2(Vector2.new(0, 0))
	end
end))



ScreenGui = loadUI()
if not ScreenGui then
	warn("[ONICheats] UI build failed.")
	return
end

applyTopMostUI(ScreenGui)


local function toggleMenu()
	menuOpen = not menuOpen
	applyTopMostUI(ScreenGui)
	setMenuMouseState(menuOpen)
	if menuOpen then
		if MenuShell then
			MenuShell.Visible = true
			MenuShell.Size = UDim2.new(0, 480, 0, 600)
		end
		for _, scroller in pairs(Containers) do
			if scroller.Visible then
				scroller.CanvasPosition = Vector2.new(0, 0)
			end
		end
	else
		if MenuShell then
			MenuShell.Visible = false
		end
	end
end

local function matchesMenuKey(input)
	local bind = Settings.Misc.MenuKeybind
	return bind and bind.EnumType == Enum.KeyCode and input.KeyCode == bind
end

trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
	if not scriptActive then return end
	if matchesMenuKey(input) then
		toggleMenu()
	end

	if not KeybindCaptureActive and inputMatchesBind(input, Settings.Binds.PanicKey) then
		if disableAllFeatures then
			disableAllFeatures()
		end
		return
	end

	handleFeatureBindToggles(input)

	if Settings.Movement.InfiniteJump and not processed and input.KeyCode == Enum.KeyCode.Space then
		local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and not menuOpen then
		isShooting = true
		if Settings.Aim.AimWhileShooting and Settings.Aim.LockMode == "Hold" then
			isAming = true
		end
		cacheShotTarget()
	end

	if typeof(Settings.Aim.Keybind) == "EnumItem" then
		local keyMatch = Settings.Aim.Keybind.EnumType == Enum.KeyCode and input.KeyCode == Settings.Aim.Keybind
		local mouseMatch = Settings.Aim.Keybind.EnumType == Enum.UserInputType and input.UserInputType == Settings.Aim.Keybind
		if (keyMatch or mouseMatch) and not menuOpen then
			isAming = true
			if Settings.Aim.LockMode == "Toggle" then
				toggleActive = not toggleActive
				if toggleActive then acquireAimTarget() end
			else
				acquireAimTarget()
				cacheShotTarget()
			end
		end
	end
end))

trackConnection(UserInputService.InputEnded:Connect(function(input)
	if not scriptActive then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isShooting = false
	end

	if typeof(Settings.Aim.Keybind) == "EnumItem" then
		local keyMatch = Settings.Aim.Keybind.EnumType == Enum.KeyCode and input.KeyCode == Settings.Aim.Keybind
		local mouseMatch = Settings.Aim.Keybind.EnumType == Enum.UserInputType and input.UserInputType == Settings.Aim.Keybind
		if keyMatch or mouseMatch then isAming = false end
	end
end))

local function finalizeStartup()
	initLockHud()

	if hasFileSystem and isfile(AUTOLOAD_FLAG_FILE) then
		Settings.Misc.AutoLoadConfig = readfile(AUTOLOAD_FLAG_FILE) == "true"
	end
	autoLoadConfiguration()

	refreshLockHud()
	refreshMouseDriver()
end

finalizeStartup()

	local menuKeyName = "Insert"
	if typeof(Settings.Misc.MenuKeybind) == "EnumItem" and Settings.Misc.MenuKeybind.EnumType == Enum.KeyCode then
		menuKeyName = Settings.Misc.MenuKeybind.Name
	end
	notify("ONICheats", "Ready — press " .. menuKeyName .. " for menu.\nCracked and key removed by EvolEzod", 5)
end)

if not startupOk then
	warn("[ONICheats] Startup failed: " .. tostring(startupErr))
	notify("ONICheats", "Startup failed. Re-execute the script.", 5)
end
end

local function safeLaunchONICheats()
	local ok, err = pcall(launchONICheats)
	if not ok then
		warn("[ONICheats] Launch failed: " .. tostring(err))
		notify("ONICheats", "Launch failed. Re-execute the script.", 5)
	end
end

safeLaunchONICheats()
