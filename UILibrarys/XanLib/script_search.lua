local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local ScriptSearch = {
    Version = "1.1.0",
    IsOpen = false,
    IsMinimized = false,
    CurrentAPI = "scriptblox",
    CurrentView = "trending",
    SearchResults = {},
    Favorites = {},
    IsLoading = false,
    GUI = nil,
    MainFrame = nil,
    ContentFrame = nil,
    MinimizedBar = nil,
    MobileToggleBtn = nil,
    ResultsFrame = nil,
    LoadingLabel = nil,
    Theme = nil,
    TrendingLoaded = {},
    GameIconCache = {},
    _requestId = 0,
    _themeCallbackRegistered = false,
    _unloadConnection = nil,
    _toggleConnection = nil,
    _xanVisibilityConnection = nil,
    _animating = false,
    _wasOpenBeforeXanHide = false,
    _wasMinimizedBeforeXanHide = false,
    _hiddenByXanToggle = false,
    Config = {
        MaxResults = 100,
        FavoritesFile = "xanbar/script_favorites.json",
        GameIconsAPI = "https://api.xan.bar/api/games/lookup",
        GameIconsCacheFile = "xanbar/game_icons_cache.json"
    }
}

local APIs = {
    scriptblox = {
        name = "ScriptBlox",
        searchUrl = "https://scriptblox.com/api/script/search?q=%s&max=%d",
        trendingUrl = "https://scriptblox.com/api/script/trending?max=%d",
        parseResults = function(data)
            if data and data.result and data.result.scripts then
                return data.result.scripts
            end
            return {}
        end,
        getTitle = function(s) return s.title or "Unknown" end,
        getGame = function(s) return (s.game and s.game.name) or "Universal" end,
        getGameImage = function(s)
            if s.game then
                if s.game.imageUrl then return s.game.imageUrl end
                if s.game.imgUrl then return s.game.imgUrl end
                if s.game.image then return s.game.image end
            end
            return nil
        end,
        getPlaceId = function(s)
            if s.game then
                if s.game.gameId then return s.game.gameId end
                if s.game.placeId then return s.game.placeId end
                if s.game.id then return s.game.id end
            end
            return nil
        end,
        getViews = function(s) return s.views or 0 end,
        getScript = function(s) return s.script or "" end,
        getId = function(s) return s._id or s.slug or "" end
    },
    rscripts = {
        name = "RScripts",
        searchUrl = "https://rscripts.net/api/v2/scripts?q=%s&orderBy=views&sort=desc&page=1&limit=%d",
        trendingUrl = "https://rscripts.net/api/v2/scripts?orderBy=views&sort=desc&page=1&limit=%d",
        scriptUrl = "https://rscripts.net/api/v2/scripts/%s",
        parseResults = function(data)
            if data and data.scripts then
                return data.scripts
            end
            return {}
        end,
        parseTrending = function(data)
            if data and data.scripts then
                return data.scripts
            elseif data and data.success and type(data.success) == "table" then
                local results = {}
                for _, item in ipairs(data.success) do
                    local script = item.script or item
                    table.insert(results, script)
                end
                return results
            end
            return {}
        end,
        getTitle = function(s) return s.title or "Unknown" end,
        getGame = function(s)
            if s.game then
                return s.game.title or s.game.name or "Universal"
            end
            return "Universal"
        end,
        getGameImage = function(s)
            if s.game then
                if s.game.imageUrl then return s.game.imageUrl end
                if s.game.imgurl then return s.game.imgurl end
                if s.game.imgUrl then return s.game.imgUrl end
                if s.game.image then return s.game.image end
                if s.game.icon then return s.game.icon end
                if s.game.thumbnail then return s.game.thumbnail end
            end
            if s.image then return s.image end
            if s.imageUrl then return s.imageUrl end
            if s.thumbnail then return s.thumbnail end
            return nil
        end,
        getPlaceId = function(s)
            if s.game then
                if s.game.placeId then return s.game.placeId end
                if s.game.gameId then return s.game.gameId end
                if s.game.id then return s.game.id end
            end
            if s.placeId then return s.placeId end
            if s.gameId then return s.gameId end
            return nil
        end,
        getViews = function(s) return s.views or 0 end,
        getScript = function(s) return s.script or s.rawScript or "" end,
        getId = function(s) return s.slug or s._id or s.id or "" end
    }
}

local function GetHttpRequest()
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    return nil
end

local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    end
    return tostring(num)
end

local function Tween(obj, duration, props)
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function Create(class, props, children)
    local instance = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    if props and props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

function ScriptSearch:GetXanInstance()
    if rawget(_G, "Xan") and rawget(_G, "Xan").CurrentTheme then 
        return rawget(_G, "Xan") 
    end
    if _G.Xan and _G.Xan.CurrentTheme then 
        return _G.Xan 
    end
    return nil
end

function ScriptSearch:GetXanTheme()
    local xan = self:GetXanInstance()
    if xan and xan.CurrentTheme then
        local t = xan.CurrentTheme
        return {
            Background = t.Background or Color3.fromRGB(18, 18, 22),
            BackgroundSecondary = t.BackgroundSecondary or t.Card or Color3.fromRGB(24, 24, 30),
            Card = t.Card or Color3.fromRGB(30, 30, 38),
            CardHover = t.CardHover or Color3.fromRGB(38, 38, 48),
            CardBorder = t.CardBorder or Color3.fromRGB(45, 45, 55),
            Accent = t.Accent or Color3.fromRGB(230, 57, 70),
            AccentDark = t.AccentDark or Color3.fromRGB(180, 40, 50),
            Text = t.Text or Color3.fromRGB(255, 255, 255),
            TextSecondary = t.TextSecondary or Color3.fromRGB(180, 180, 190),
            TextDim = t.TextDim or Color3.fromRGB(120, 120, 130),
            Input = t.Input or Color3.fromRGB(22, 22, 28),
            InputBorder = t.InputBorder or Color3.fromRGB(50, 50, 60),
            Success = t.Success or Color3.fromRGB(60, 180, 90),
            Error = t.Error or Color3.fromRGB(230, 70, 70)
        }
    end
    return nil
end

function ScriptSearch:GetDefaultTheme()
    return {
        Background = Color3.fromRGB(18, 18, 22),
        BackgroundSecondary = Color3.fromRGB(24, 24, 30),
        Card = Color3.fromRGB(30, 30, 38),
        CardHover = Color3.fromRGB(38, 38, 48),
        CardBorder = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(230, 57, 70),
        AccentDark = Color3.fromRGB(180, 40, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        TextDim = Color3.fromRGB(120, 120, 130),
        Input = Color3.fromRGB(22, 22, 28),
        InputBorder = Color3.fromRGB(50, 50, 60),
        Success = Color3.fromRGB(60, 180, 90),
        Error = Color3.fromRGB(230, 70, 70)
    }
end

function ScriptSearch:GetActiveTheme()
    return self:GetXanTheme() or self.Theme or self:GetDefaultTheme()
end

function ScriptSearch:GetWindowButtonStyle()
    local xan = self:GetXanInstance()
    
    if xan and xan.WindowButtonStyle then
        return xan.WindowButtonStyle
    end
    
    if xan and xan._windows then
        for _, win in pairs(xan._windows) do
            if win.WindowButtonStyle then
                return win.WindowButtonStyle
            end
        end
    end
    
    local detectedStyle = "Default"
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        for _, gui in pairs(coreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:find("XanBar") then
                local macClose = gui:FindFirstChild("MacClose", true)
                if macClose and macClose.Visible then
                    detectedStyle = "macOS"
                    break
                end
            end
        end
    end)
    
    return detectedStyle
end

function ScriptSearch:LoadFavorites()
    self.Favorites = {}
    pcall(function()
        if isfile and isfile(self.Config.FavoritesFile) then
            local data = readfile(self.Config.FavoritesFile)
            if data and data ~= "" then
                self.Favorites = HttpService:JSONDecode(data) or {}
            end
        end
    end)
end

function ScriptSearch:SaveFavorites()
    pcall(function()
        if writefile and isfile then
            local folder = self.Config.FavoritesFile:match("(.+)/")
            if folder and isfolder and not isfolder(folder) then
                makefolder(folder)
            end
            writefile(self.Config.FavoritesFile, HttpService:JSONEncode(self.Favorites))
        end
    end)
end

function ScriptSearch:LoadGameIconCache()
    self.GameIconCache = {}
    pcall(function()
        if isfile and isfile(self.Config.GameIconsCacheFile) then
            local data = readfile(self.Config.GameIconsCacheFile)
            if data and data ~= "" then
                self.GameIconCache = HttpService:JSONDecode(data) or {}
            end
        end
    end)
end

function ScriptSearch:SaveGameIconCache()
    pcall(function()
        if writefile and isfile then
            local folder = self.Config.GameIconsCacheFile:match("(.+)/")
            if folder and isfolder and not isfolder(folder) then
                makefolder(folder)
            end
            writefile(self.Config.GameIconsCacheFile, HttpService:JSONEncode(self.GameIconCache))
        end
    end)
end

function ScriptSearch:NormalizeGameName(name)
    if not name then return {} end
    
    local variations = {}
    
    local lower = string.lower(name)
    if string.find(lower, "universal") then
        table.insert(variations, "Universal")
        return variations
    end
    
    table.insert(variations, name)
    
    local stripped = name:gsub("%[.-%]", ""):gsub("%(.-%)", ""):gsub("%s+$", ""):gsub("^%s+", "")
    if stripped ~= name and stripped ~= "" then
        table.insert(variations, stripped)
    end
    
    local beforeDash = name:match("^([^%-]+)")
    if beforeDash then
        beforeDash = beforeDash:gsub("%s+$", "")
        if beforeDash ~= name and beforeDash ~= stripped and beforeDash ~= "" then
            table.insert(variations, beforeDash)
        end
    end
    
    local beforeColon = name:match("^([^:]+)")
    if beforeColon then
        beforeColon = beforeColon:gsub("%s+$", "")
        if beforeColon ~= name and beforeColon ~= stripped and beforeColon ~= beforeDash and beforeColon ~= "" then
            table.insert(variations, beforeColon)
        end
    end
    
    local words = {}
    for word in name:gmatch("%S+") do
        if not word:match("^%[") and not word:match("^%(") then
            table.insert(words, word)
        end
    end
    if #words >= 2 and #words <= 4 then
        local firstTwo = words[1] .. " " .. words[2]
        local exists = false
        for _, v in ipairs(variations) do
            if v == firstTwo then exists = true break end
        end
        if not exists and firstTwo ~= "" then
            table.insert(variations, firstTwo)
        end
    end
    
    return variations
end

function ScriptSearch:GetGameIcon(gameName, callback)
    if not gameName or gameName == "" then
        callback(nil, nil)
        return
    end
    
    local cacheKey = gameName:lower():gsub("[^a-z0-9]+", "_")
    
    if self.GameIconCache[cacheKey] then
        local cached = self.GameIconCache[cacheKey]
        if cached.timestamp and (os.time() - cached.timestamp) < 86400 then
            callback(cached.rbxthumb, cached.backup_rbxasset)
            return
        end
    end
    
    local httpRequest = GetHttpRequest()
    if not httpRequest then
        callback(nil, nil)
        return
    end
    
    local variations = self:NormalizeGameName(gameName)
    
    task.spawn(function()
        for _, nameVariation in ipairs(variations) do
            local success, response = pcall(function()
                local url = self.Config.GameIconsAPI .. "?name=" .. HttpService:UrlEncode(nameVariation)
                local res = httpRequest({ Url = url, Method = "GET" })
                if res and res.StatusCode == 200 then
                    return res.Body
                end
                return nil
            end)
            
            if success and response then
                local parseSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response)
                end)
                
                if parseSuccess and data and data.success then
                    local rbxthumb = nil
                    local backupRbxasset = nil
                    local gameData = data.game or data.best
                    
                    if gameData then
                        rbxthumb = gameData.rbxthumb
                        backupRbxasset = gameData.backup_rbxasset
                    end
                    
                    if rbxthumb or backupRbxasset then
                        self.GameIconCache[cacheKey] = {
                            rbxthumb = rbxthumb,
                            backup_rbxasset = backupRbxasset,
                            timestamp = os.time()
                        }
                        self:SaveGameIconCache()
                        callback(rbxthumb, backupRbxasset)
                        return
                    end
                end
            end
        end
        
        callback(nil, nil)
    end)
end

function ScriptSearch:GetGameIconSync(gameName)
    if not gameName or gameName == "" then
        return nil, nil
    end
    
    local cacheKey = gameName:lower():gsub("[^a-z0-9]+", "_")
    
    if self.GameIconCache[cacheKey] then
        return self.GameIconCache[cacheKey].rbxthumb, self.GameIconCache[cacheKey].backup_rbxasset
    end
    
    local variations = self:NormalizeGameName(gameName)
    for _, nameVariation in ipairs(variations) do
        local varKey = nameVariation:lower():gsub("[^a-z0-9]+", "_")
        if varKey ~= cacheKey and self.GameIconCache[varKey] then
            return self.GameIconCache[varKey].rbxthumb, self.GameIconCache[varKey].backup_rbxasset
        end
    end
    
    return nil, nil
end

function ScriptSearch:IsFavorite(id)
    for _, fav in ipairs(self.Favorites) do
        if fav.id == id then return true end
    end
    return false
end

function ScriptSearch:ToggleFavorite(scriptData, apiType)
    local api = APIs[apiType]
    if not api then return false end
    
    local id = api.getId(scriptData)
    
    for i, fav in ipairs(self.Favorites) do
        if fav.id == id then
            table.remove(self.Favorites, i)
            self:SaveFavorites()
            return false
        end
    end
    
    local placeId = api.getPlaceId and api.getPlaceId(scriptData) or nil
    local imageUrl = api.getGameImage and api.getGameImage(scriptData) or nil
    
    table.insert(self.Favorites, {
        id = id,
        title = api.getTitle(scriptData),
        game = api.getGame(scriptData),
        views = api.getViews(scriptData),
        script = api.getScript(scriptData),
        apiType = apiType,
        placeId = placeId,
        imageUrl = imageUrl
    })
    self:SaveFavorites()
    return true
end

function ScriptSearch:Search(query, callback)
    self._requestId = self._requestId + 1
    local thisRequestId = self._requestId
    local thisAPI = self.CurrentAPI
    
    self.IsLoading = true
    
    local httpRequest = GetHttpRequest()
    if not httpRequest then
        self.IsLoading = false
        callback(nil, "HTTP not available")
        return
    end
    
    local api = APIs[thisAPI]
    local url = string.format(api.searchUrl, HttpService:UrlEncode(query), self.Config.MaxResults)
    
    task.spawn(function()
        local success, response = pcall(function()
            local res = httpRequest({ Url = url, Method = "GET" })
            if res and res.StatusCode == 200 then
                return res.Body
            end
            return nil
        end)
        
        if thisRequestId ~= self._requestId then return end
        if self.CurrentAPI ~= thisAPI then return end
        if self.CurrentView ~= "search" then return end
        
        self.IsLoading = false
        
        if success and response then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if parseSuccess and data then
                local results = api.parseResults(data)
                self.SearchResults = results
                callback(results, nil)
            else
                callback(nil, "Failed to parse results")
            end
        else
            callback(nil, "Search failed")
        end
    end)
end

function ScriptSearch:FetchTrending(callback)
    self._requestId = self._requestId + 1
    local thisRequestId = self._requestId
    local thisAPI = self.CurrentAPI
    
    self.IsLoading = true
    
    local httpRequest = GetHttpRequest()
    if not httpRequest then
        self.IsLoading = false
        callback(nil, "HTTP not available")
        return
    end
    
    local api = APIs[thisAPI]
    local url
    url = string.format(api.trendingUrl, self.Config.MaxResults)
    
    task.spawn(function()
        local success, response = pcall(function()
            local res = httpRequest({ Url = url, Method = "GET" })
            if res and res.StatusCode == 200 then
                return res.Body
            end
            return nil
        end)
        
        if thisRequestId ~= self._requestId then return end
        if self.CurrentAPI ~= thisAPI then return end
        if self.CurrentView ~= "trending" then return end
        
        self.IsLoading = false
        
        if success and response then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if parseSuccess and data then
                local results
                if api.parseTrending then
                    results = api.parseTrending(data)
                else
                    results = api.parseResults(data)
                end
                callback(results, nil)
            else
                callback(nil, "Failed to parse results")
            end
        else
            callback(nil, "Fetch failed")
        end
    end)
end

function ScriptSearch:ExecuteScript(scriptContent)
    if not scriptContent or scriptContent == "" then return false end
    
    local success, err = pcall(function()
        loadstring(scriptContent)()
    end)
    
    return success, err
end

function ScriptSearch:FetchScriptContent(apiName, scriptId, callback)
    local httpRequest = GetHttpRequest()
    if not httpRequest then
        callback(nil, "HTTP not available")
        return
    end
    
    local api = APIs[apiName]
    if not api or not api.scriptUrl then
        callback(nil, "No script URL for this API")
        return
    end
    
    local url = string.format(api.scriptUrl, scriptId)
    
    task.spawn(function()
        local success, response = pcall(function()
            local res = httpRequest({ Url = url, Method = "GET" })
            if res and res.StatusCode == 200 then
                return res.Body
            end
            return nil
        end)
        
        if success and response then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if parseSuccess and data then
                local scriptContent = nil
                if data.script then
                    scriptContent = data.script.script or data.script.rawScript or data.script.content
                elseif data.rawScript then
                    scriptContent = data.rawScript
                elseif data.content then
                    scriptContent = data.content
                end
                
                if scriptContent and scriptContent ~= "" then
                    callback(scriptContent, nil)
                else
                    callback(nil, "No script content found")
                end
            else
                callback(nil, "Failed to parse response")
            end
        else
            callback(nil, "Failed to fetch script")
        end
    end)
end

function ScriptSearch:ClearResults()
    if self.ResultsFrame then
        for _, child in ipairs(self.ResultsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
end

function ScriptSearch:LoadTrending()
    if not self.ResultsFrame or not self.LoadingLabel then return end
    
    self.CurrentView = "trending"
    local targetAPI = self.CurrentAPI
    
    self:ClearResults()
    self.LoadingLabel.Text = "Loading trending..."
    self.LoadingLabel.Visible = true
    
    self:FetchTrending(function(results, err)
        if not self.LoadingLabel then return end
        if self.CurrentAPI ~= targetAPI then return end
        if self.CurrentView ~= "trending" then return end
        
        self.LoadingLabel.Visible = false
        
        if err then
            self.LoadingLabel.Text = err
            self.LoadingLabel.Visible = true
            return
        end
        
        if not results or #results == 0 then
            self.LoadingLabel.Text = "No scripts found"
            self.LoadingLabel.Visible = true
            return
        end
        
        self:ClearResults()
        for i, scriptData in ipairs(results) do
            self:CreateScriptCard(scriptData, self.ResultsFrame, i)
        end
        
        self.TrendingLoaded[targetAPI] = true
    end)
end

function ScriptSearch:UpdateTheme(newTheme)
    if newTheme then
        self.Theme = newTheme
    end
    
    local t = self:GetActiveTheme()
    if not self.GUI or not self.MainFrame then return end
    
    self.MainFrame.BackgroundColor3 = t.Background
    
    local header = self.MainFrame:FindFirstChild("Header")
    if header then
        header.BackgroundColor3 = t.BackgroundSecondary
        local headerCover = header:FindFirstChild("HeaderCover")
        if headerCover then headerCover.BackgroundColor3 = t.BackgroundSecondary end
        local icon = header:FindFirstChild("Icon")
        if icon then icon.ImageColor3 = t.Accent end
        local title = header:FindFirstChild("Title")
        if title then title.TextColor3 = t.Text end
        local iconClose = header:FindFirstChild("IconClose")
        if iconClose then iconClose.ImageColor3 = t.TextDim end
        local iconMin = header:FindFirstChild("IconMin")
        if iconMin then iconMin.ImageColor3 = t.TextDim end
    end
    
    if self.MinimizedBar then
        self.MinimizedBar.BackgroundColor3 = t.Background
        local minStroke = self.MinimizedBar:FindFirstChildOfClass("UIStroke")
        if minStroke then minStroke.Color = t.CardBorder end
        local minIcon = self.MinimizedBar:FindFirstChild("MinIcon")
        if minIcon then minIcon.ImageColor3 = t.Accent end
        local minTitle = self.MinimizedBar:FindFirstChild("MinTitle")
        if minTitle then minTitle.TextColor3 = t.Text end
        local iconExpand = self.MinimizedBar:FindFirstChild("IconExpand")
        if iconExpand then iconExpand.ImageColor3 = t.Accent end
    end
    
    if self.MobileToggleBtn then
        self.MobileToggleBtn.BackgroundColor3 = t.Accent
        local btnStroke = self.MobileToggleBtn:FindFirstChildOfClass("UIStroke")
        if btnStroke then btnStroke.Color = t.BackgroundSecondary end
    end
    
    local apiSwitcher = self.MainFrame:FindFirstChild("APISwitcher")
    if apiSwitcher then
        for _, btn in pairs(apiSwitcher:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn.Name == self.CurrentAPI then
                    btn.BackgroundColor3 = t.Accent
                    btn.TextColor3 = Color3.new(1, 1, 1)
                else
                    btn.BackgroundColor3 = t.Card
                    btn.TextColor3 = t.TextSecondary
                end
            end
        end
    end
    
    local searchContainer = self.MainFrame:FindFirstChild("SearchContainer")
    if searchContainer then
        searchContainer.BackgroundColor3 = t.Input
        local stroke = searchContainer:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = t.InputBorder end
        local icon = searchContainer:FindFirstChild("Icon")
        if icon then icon.ImageColor3 = t.TextDim end
        local input = searchContainer:FindFirstChild("Input")
        if input then
            input.TextColor3 = t.Text
            input.PlaceholderColor3 = t.TextDim
        end
        local searchBtn = searchContainer:FindFirstChild("SearchBtn")
        if searchBtn then searchBtn.BackgroundColor3 = t.Accent end
    end
    
    local resultsFrame = self.MainFrame:FindFirstChild("Results")
    if resultsFrame then
        resultsFrame.ScrollBarImageColor3 = t.Accent
        local loadingLabel = resultsFrame:FindFirstChild("Loading")
        if loadingLabel then loadingLabel.TextColor3 = t.TextDim end
        
        for _, card in pairs(resultsFrame:GetChildren()) do
            if card:IsA("Frame") and card.Name:match("^Card_") then
                card.BackgroundColor3 = t.Card
                local cardStroke = card:FindFirstChildOfClass("UIStroke")
                if cardStroke then cardStroke.Color = t.CardBorder end
                local gameBadge = card:FindFirstChild("GameBadge")
                if gameBadge then
                    gameBadge.BackgroundColor3 = t.Accent
                    local gameText = gameBadge:FindFirstChild("GameText")
                    if gameText then gameText.TextColor3 = t.Accent end
                end
                local titleLabel = card:FindFirstChild("Title")
                if titleLabel then titleLabel.TextColor3 = t.Text end
                local viewsLabel = card:FindFirstChild("Views")
                if viewsLabel then viewsLabel.TextColor3 = t.TextDim end
                local loadBtn = card:FindFirstChild("Load")
                if loadBtn then loadBtn.BackgroundColor3 = t.Accent end
                local favBtn = card:FindFirstChild("Favorite")
                if favBtn and favBtn.Text == "☆" then favBtn.TextColor3 = t.TextDim end
            end
        end
    end
    
    local mainStroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    if mainStroke then mainStroke.Color = t.CardBorder end
end

function ScriptSearch:CreateUI()
    if self.GUI then
        self.GUI:Destroy()
    end
    
    local t = self:GetActiveTheme()
    local windowWidth = IsMobile and 340 or 420
    local windowHeight = IsMobile and 400 or 480
    
    local screenGui = Create("ScreenGui", {
        Name = "XanScriptSearch",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.GUI = screenGui
    
    local mainFrame = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = t.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, windowWidth, 0, windowHeight),
        Visible = false,
        Parent = screenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", { Color = t.CardBorder, Thickness = 1 })
    })
    self.MainFrame = mainFrame
    
    local header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = t.BackgroundSecondary,
        Size = UDim2.new(1, 0, 0, IsMobile and 52 or 48),
        Parent = mainFrame
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) })
    })
    
    Create("Frame", {
        Name = "HeaderCover",
        BackgroundColor3 = t.BackgroundSecondary,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BorderSizePixel = 0,
        Parent = header
    })
    
    Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, IsMobile and 22 or 20, 0, IsMobile and 22 or 20),
        Image = "rbxassetid://137128706224920",
        ImageColor3 = t.Accent,
        Parent = header
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, IsMobile and 42 or 40, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Script Search",
        TextColor3 = t.Text,
        TextSize = IsMobile and 16 or 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local windowButtonStyle = self:GetWindowButtonStyle()
    local isMacStyle = windowButtonStyle == "macOS"
    local btnSize = IsMobile and 14 or 12
    local iconBtnSize = IsMobile and 22 or 18
    local btnGap = IsMobile and 8 or 6
    local btnPad = IsMobile and 14 or 12
    
    local macCloseBtn = Create("Frame", {
        Name = "MacClose",
        BackgroundColor3 = Color3.fromRGB(255, 95, 87),
        Size = UDim2.new(0, btnSize, 0, btnSize),
        Position = UDim2.new(1, -(btnSize + btnPad), 0.5, -btnSize/2),
        Visible = isMacStyle,
        Parent = header
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local macCloseX = Create("TextLabel", {
        Name = "X",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Color3.fromRGB(80, 30, 30),
        TextSize = IsMobile and 10 or 8,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = macCloseBtn
    })
    
    local macCloseClickArea = Create("TextButton", {
        Name = "MacCloseClick",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 10,
        Parent = macCloseBtn
    })
    
    local macMinBtn = Create("Frame", {
        Name = "MacMin",
        BackgroundColor3 = Color3.fromRGB(255, 189, 46),
        Size = UDim2.new(0, btnSize, 0, btnSize),
        Position = UDim2.new(1, -(btnSize * 2 + btnGap + btnPad), 0.5, -btnSize/2),
        Visible = isMacStyle,
        Parent = header
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local macMinDash = Create("TextLabel", {
        Name = "Dash",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Color3.fromRGB(120, 80, 20),
        TextSize = IsMobile and 12 or 10,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = macMinBtn
    })
    
    local macMinClickArea = Create("TextButton", {
        Name = "MacMinClick",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 10,
        Parent = macMinBtn
    })
    
    local iconCloseBtn = Create("ImageButton", {
        Name = "IconClose",
        BackgroundTransparency = 1,
        Image = "rbxassetid://115983297861228",
        ImageColor3 = t.TextDim,
        ImageTransparency = 0.3,
        Size = UDim2.new(0, iconBtnSize, 0, iconBtnSize),
        Position = UDim2.new(1, -(iconBtnSize + btnPad), 0.5, -iconBtnSize/2),
        AutoButtonColor = false,
        Visible = not isMacStyle,
        Parent = header
    })
    
    local iconMinBtn = Create("ImageButton", {
        Name = "IconMin",
        BackgroundTransparency = 1,
        Image = "rbxassetid://88679699501643",
        ImageColor3 = t.TextDim,
        ImageTransparency = 0.3,
        Size = UDim2.new(0, iconBtnSize, 0, iconBtnSize),
        Position = UDim2.new(1, -(iconBtnSize * 2 + btnGap + btnPad), 0.5, -iconBtnSize/2),
        AutoButtonColor = false,
        Visible = not isMacStyle,
        Parent = header
    })
    
    local favBtnOffset = isMacStyle and (btnSize * 2 + btnGap + btnPad + 16) or (iconBtnSize * 2 + btnGap + btnPad + 12)
    
    local favBtn = Create("TextButton", {
        Name = "Favorites",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -favBtnOffset, 0.5, 0),
        Size = UDim2.new(0, IsMobile and 70 or 65, 0, IsMobile and 26 or 22),
        Font = Enum.Font.GothamMedium,
        Text = "★ Favs",
        TextColor3 = t.TextDim,
        TextSize = IsMobile and 12 or 11,
        AutoButtonColor = false,
        Parent = header
    })
    
    favBtn.MouseEnter:Connect(function()
        Tween(favBtn, 0.15, { TextColor3 = Color3.fromRGB(255, 200, 50) })
    end)
    favBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        if self.CurrentView == "favorites" then
            favBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            Tween(favBtn, 0.15, { TextColor3 = currentTheme.TextDim })
        end
    end)
    
    local function doClose()
        self:Hide()
    end
    
    local function doMinimize()
        self:Minimize()
    end
    
    macCloseClickArea.MouseButton1Click:Connect(doClose)
    iconCloseBtn.MouseButton1Click:Connect(doClose)
    macMinClickArea.MouseButton1Click:Connect(doMinimize)
    iconMinBtn.MouseButton1Click:Connect(doMinimize)
    
    macCloseBtn.MouseEnter:Connect(function()
        macCloseX.Text = "×"
        Tween(macCloseBtn, 0.1, { Size = UDim2.new(0, btnSize + 3, 0, btnSize + 3) })
    end)
    macCloseBtn.MouseLeave:Connect(function()
        macCloseX.Text = ""
        Tween(macCloseBtn, 0.1, { Size = UDim2.new(0, btnSize, 0, btnSize) })
    end)
    
    iconCloseBtn.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(iconCloseBtn, 0.15, { ImageColor3 = currentTheme.Error, ImageTransparency = 0 })
    end)
    iconCloseBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(iconCloseBtn, 0.15, { ImageColor3 = currentTheme.TextDim, ImageTransparency = 0.3 })
    end)
    
    macMinBtn.MouseEnter:Connect(function()
        macMinDash.Text = "–"
        Tween(macMinBtn, 0.1, { Size = UDim2.new(0, btnSize + 3, 0, btnSize + 3) })
    end)
    macMinBtn.MouseLeave:Connect(function()
        macMinDash.Text = ""
        Tween(macMinBtn, 0.1, { Size = UDim2.new(0, btnSize, 0, btnSize) })
    end)
    
    iconMinBtn.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(iconMinBtn, 0.15, { ImageColor3 = currentTheme.Accent, ImageTransparency = 0 })
    end)
    iconMinBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(iconMinBtn, 0.15, { ImageColor3 = currentTheme.TextDim, ImageTransparency = 0.3 })
    end)
    
    local headerHeight = IsMobile and 52 or 48
    
    local contentContainer = Create("CanvasGroup", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, headerHeight),
        Size = UDim2.new(1, 0, 1, -headerHeight),
        GroupTransparency = 0,
        Parent = mainFrame
    })
    self.ContentFrame = contentContainer
    
    local apiSwitcher = Create("Frame", {
        Name = "APISwitcher",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(1, -24, 0, 28),
        Parent = contentContainer
    })
    
    local apiButtons = {}
    local self_ref = self
    
    local function createAPIButton(name, apiKey, layoutOrder)
        local btn = Create("TextButton", {
            Name = apiKey,
            BackgroundColor3 = self_ref.CurrentAPI == apiKey and t.Accent or t.Card,
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(layoutOrder == 0 and 0 or 0.5, layoutOrder == 0 and 0 or 4, 0, 0),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = self_ref.CurrentAPI == apiKey and Color3.new(1, 1, 1) or t.TextSecondary,
            TextSize = IsMobile and 13 or 12,
            AutoButtonColor = false,
            Parent = apiSwitcher
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        btn.MouseEnter:Connect(function()
            if self_ref.CurrentAPI ~= apiKey then
                local currentTheme = self_ref:GetActiveTheme()
                Tween(btn, 0.15, { BackgroundColor3 = currentTheme.CardHover })
            end
        end)
        btn.MouseLeave:Connect(function()
            if self_ref.CurrentAPI ~= apiKey then
                local currentTheme = self_ref:GetActiveTheme()
                Tween(btn, 0.15, { BackgroundColor3 = currentTheme.Card })
            end
        end)
        btn.MouseButton1Click:Connect(function()
            local currentTheme = self_ref:GetActiveTheme()
            
            self_ref._requestId = self_ref._requestId + 1
            self_ref.IsLoading = false
            self_ref.CurrentView = "trending"
            
            titleLabel.Text = "Script Search"
            Tween(favBtn, 0.15, { TextColor3 = currentTheme.TextDim })
            
            local wasAlreadySelected = (self_ref.CurrentAPI == apiKey)
            self_ref.CurrentAPI = apiKey
            
            for k, b in pairs(apiButtons) do
                if k == apiKey then
                    Tween(b, 0.2, { BackgroundColor3 = currentTheme.Accent })
                    b.TextColor3 = Color3.new(1, 1, 1)
                else
                    Tween(b, 0.2, { BackgroundColor3 = currentTheme.Card })
                    b.TextColor3 = currentTheme.TextSecondary
                end
            end
            
            if not wasAlreadySelected or not self_ref.TrendingLoaded[apiKey] then
                self_ref:LoadTrending()
            end
        end)
        
        apiButtons[apiKey] = btn
        return btn
    end
    
    createAPIButton("ScriptBlox", "scriptblox", 0)
    createAPIButton("RScripts", "rscripts", 1)
    
    local searchContainer = Create("Frame", {
        Name = "SearchContainer",
        BackgroundColor3 = t.Input,
        Position = UDim2.new(0, 12, 0, 48),
        Size = UDim2.new(1, -24, 0, IsMobile and 40 or 36),
        Parent = contentContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = t.InputBorder, Thickness = 1 })
    })
    
    Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://71812909535083",
        ImageColor3 = t.TextDim,
        Parent = searchContainer
    })
    
    local searchInput = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search scripts...",
        PlaceholderColor3 = t.TextDim,
        Text = "",
        TextColor3 = t.Text,
        TextSize = IsMobile and 14 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = searchContainer
    })
    
    local searchBtn = Create("TextButton", {
        Name = "SearchBtn",
        BackgroundColor3 = t.Accent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, IsMobile and 60 or 56, 0, IsMobile and 32 or 28),
        Font = Enum.Font.GothamBold,
        Text = "Search",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = IsMobile and 12 or 11,
        AutoButtonColor = false,
        Parent = searchContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })
    
    searchBtn.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(searchBtn, 0.15, { BackgroundColor3 = currentTheme.AccentDark })
    end)
    searchBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(searchBtn, 0.15, { BackgroundColor3 = currentTheme.Accent })
    end)
    
    searchInput.Focused:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(searchContainer.UIStroke, 0.15, { Color = currentTheme.Accent })
    end)
    searchInput.FocusLost:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(searchContainer.UIStroke, 0.15, { Color = currentTheme.InputBorder })
    end)
    
    local resultsOffset = IsMobile and 98 or 94
    
    local resultsScroll = Create("ScrollingFrame", {
        Name = "Results",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, resultsOffset),
        Size = UDim2.new(1, -24, 1, -resultsOffset - 12),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = t.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = contentContainer
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
    })
    self.ResultsFrame = resultsScroll
    
    local loadingLabel = Create("TextLabel", {
        Name = "Loading",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.Gotham,
        Text = "Loading trending scripts...",
        TextColor3 = t.TextDim,
        TextSize = IsMobile and 14 or 13,
        Visible = true,
        Parent = resultsScroll
    })
    self.LoadingLabel = loadingLabel
    
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local function doSearch()
        local query = searchInput.Text
        if query == "" then
            self.TrendingLoaded[self.CurrentAPI] = false
            self:LoadTrending()
            return
        end
        
        self._requestId = self._requestId + 1
        self.IsLoading = false
        self.CurrentView = "search"
        local targetAPI = self.CurrentAPI
        
        self:ClearResults()
        loadingLabel.Text = "Searching..."
        loadingLabel.Visible = true
        
        self:Search(query, function(results, err)
            if self.CurrentAPI ~= targetAPI then return end
            if self.CurrentView ~= "search" then return end
            
            loadingLabel.Visible = false
            if err then
                loadingLabel.Text = err
                loadingLabel.Visible = true
                return
            end
            
            if not results or #results == 0 then
                loadingLabel.Text = "No results found"
                loadingLabel.Visible = true
                return
            end
            
            self:ClearResults()
            for i, scriptData in ipairs(results) do
                self:CreateScriptCard(scriptData, resultsScroll, i)
            end
        end)
    end
    
    searchBtn.MouseButton1Click:Connect(doSearch)
    searchInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then doSearch() end
    end)
    
    local function showFavorites()
        self._requestId = self._requestId + 1
        self.IsLoading = false
        self.CurrentView = "favorites"
        
        titleLabel.Text = "Favorites"
        favBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        
        local currentTheme = self:GetActiveTheme()
        for k, b in pairs(apiButtons) do
            Tween(b, 0.2, { BackgroundColor3 = currentTheme.Card })
            b.TextColor3 = currentTheme.TextSecondary
        end
        
        self:ClearResults()
        
        if #self.Favorites == 0 then
            loadingLabel.Text = "No favorites yet\nStar scripts to add them here"
            loadingLabel.Visible = true
            return
        end
        
        loadingLabel.Visible = false
        
        for i, fav in ipairs(self.Favorites) do
            self:CreateFavoriteCard(fav, resultsScroll, i)
        end
    end
    
    favBtn.MouseButton1Click:Connect(function()
        if self.CurrentView == "favorites" then
            self._requestId = self._requestId + 1
            self.IsLoading = false
            self.CurrentView = "trending"
            
            titleLabel.Text = "Script Search"
            local currentTheme = self:GetActiveTheme()
            Tween(favBtn, 0.15, { TextColor3 = currentTheme.TextDim })
            for k, b in pairs(apiButtons) do
                if k == self.CurrentAPI then
                    Tween(b, 0.2, { BackgroundColor3 = currentTheme.Accent })
                    b.TextColor3 = Color3.new(1, 1, 1)
                end
            end
            self.TrendingLoaded[self.CurrentAPI] = false
            self:LoadTrending()
        else
            showFavorites()
        end
    end)
    
    local minimizedBar = Create("Frame", {
        Name = "MinimizedBar",
        BackgroundColor3 = t.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, IsMobile and 200 or 220, 0, IsMobile and 42 or 40),
        Visible = false,
        Parent = screenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", { Color = t.CardBorder, Thickness = 1 })
    })
    self.MinimizedBar = minimizedBar
    
    Create("ImageLabel", {
        Name = "MinIcon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 18, 0, 18),
        Image = "rbxassetid://137128706224920",
        ImageColor3 = t.Accent,
        Parent = minimizedBar
    })
    
    Create("TextLabel", {
        Name = "MinTitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Script Search",
        TextColor3 = t.Text,
        TextSize = IsMobile and 13 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = minimizedBar
    })
    
    local macExpandBtn = Create("Frame", {
        Name = "MacExpand",
        BackgroundColor3 = Color3.fromRGB(39, 201, 63),
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -24, 0.5, -7),
        Visible = isMacStyle,
        Parent = minimizedBar
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local macExpandClickArea = Create("TextButton", {
        Name = "MacExpandClick",
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 10,
        Parent = macExpandBtn
    })
    
    local iconExpandBtn = Create("ImageButton", {
        Name = "IconExpand",
        BackgroundTransparency = 1,
        Image = "rbxassetid://114251372753378",
        ImageColor3 = t.Accent,
        ImageTransparency = 0.2,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -26, 0.5, -9),
        AutoButtonColor = false,
        Visible = not isMacStyle,
        Parent = minimizedBar
    })
    
    local function doRestore()
        self:Restore()
    end
    
    macExpandClickArea.MouseButton1Click:Connect(doRestore)
    iconExpandBtn.MouseButton1Click:Connect(doRestore)
    
    macExpandBtn.MouseEnter:Connect(function()
        Tween(macExpandBtn, 0.1, { Size = UDim2.new(0, 17, 0, 17) })
    end)
    macExpandBtn.MouseLeave:Connect(function()
        Tween(macExpandBtn, 0.1, { Size = UDim2.new(0, 14, 0, 14) })
    end)
    
    iconExpandBtn.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(iconExpandBtn, 0.15, { ImageColor3 = currentTheme.Accent, ImageTransparency = 0 })
    end)
    iconExpandBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(iconExpandBtn, 0.15, { ImageTransparency = 0.2 })
    end)
    
    local minDragging = false
    local minDragStart, minStartPos
    
    minimizedBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minDragging = true
            minDragStart = input.Position
            minStartPos = minimizedBar.Position
        end
    end)
    
    minimizedBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if minDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - minDragStart
            minimizedBar.Position = UDim2.new(minStartPos.X.Scale, minStartPos.X.Offset + delta.X, minStartPos.Y.Scale, minStartPos.Y.Offset + delta.Y)
        end
    end)
    
    if IsMobile then
        local mobileToggle = Create("ImageButton", {
            Name = "XanScriptSearchToggle",
            BackgroundColor3 = t.Accent,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -120),
            Size = UDim2.new(0, 50, 0, 50),
            Image = "rbxassetid://137128706224920",
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = screenGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
            Create("UIStroke", { Color = t.BackgroundSecondary, Thickness = 2 })
        })
        self.MobileToggleBtn = mobileToggle
        
        mobileToggle.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        
        local btnDragging = false
        local btnDragStart, btnStartPos
        
        mobileToggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = true
                btnDragStart = input.Position
                btnStartPos = mobileToggle.Position
            end
        end)
        
        mobileToggle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if btnDragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - btnDragStart
                mobileToggle.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    self:SetupXanIntegration()
    
    return screenGui
end

function ScriptSearch:CreateScriptCard(scriptData, parent, index)
    local t = self:GetActiveTheme()
    local api = APIs[self.CurrentAPI]
    
    local title = api.getTitle(scriptData)
    local game = api.getGame(scriptData)
    local views = api.getViews(scriptData)
    local script = api.getScript(scriptData)
    local id = api.getId(scriptData)
    
    local directImageUrl = api.getGameImage and api.getGameImage(scriptData) or nil
    local placeId = api.getPlaceId and api.getPlaceId(scriptData) or nil
    
    local hasIcon = game and game ~= ""
    local iconSize = IsMobile and 52 or 48
    local leftPadding = hasIcon and (iconSize + 16) or 10
    local cardHeight = IsMobile and 80 or 72
    
    local card = Create("Frame", {
        Name = "Card_" .. index,
        BackgroundColor3 = t.Card,
        Size = UDim2.new(1, 0, 0, cardHeight),
        LayoutOrder = index,
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = t.CardBorder, Thickness = 1 })
    })
    
    card.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(card, 0.15, { BackgroundColor3 = currentTheme.CardHover })
    end)
    card.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(card, 0.15, { BackgroundColor3 = currentTheme.Card })
    end)
    
    local gameIcon = nil
    if hasIcon then
        local iconContainer = Create("Frame", {
            Name = "IconContainer",
            BackgroundColor3 = t.BackgroundSecondary,
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, iconSize, 0, iconSize),
            Parent = card
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        gameIcon = Create("ImageLabel", {
            Name = "GameIcon",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = "",
            ScaleType = Enum.ScaleType.Crop,
            Parent = iconContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        local rbxthumbUrl = nil
        if placeId and tonumber(placeId) then
            rbxthumbUrl = string.format("rbxthumb://type=GameIcon&id=%s&w=150&h=150", tostring(placeId))
        end
        
        local cachedIcon, cachedBackup = self:GetGameIconSync(game)
        if cachedBackup then
            gameIcon.Image = cachedBackup
        elseif cachedIcon then
            gameIcon.Image = cachedIcon
        elseif rbxthumbUrl then
            gameIcon.Image = rbxthumbUrl
        end
        
        if not cachedBackup then
            self:GetGameIcon(game, function(rbxthumb, backupRbxasset)
                if gameIcon and gameIcon.Parent then
                    if backupRbxasset then
                        gameIcon.Image = backupRbxasset
                    elseif rbxthumb then
                        gameIcon.Image = rbxthumb
                    end
                end
            end)
        end
    end
    
    local gameBadge = Create("Frame", {
        Name = "GameBadge",
        BackgroundColor3 = t.Accent,
        BackgroundTransparency = 0.85,
        Position = UDim2.new(0, leftPadding, 0, 8),
        Size = UDim2.new(0, 0, 0, 18),
        Parent = card
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 9) })
    })
    
    local gameText = Create("TextLabel", {
        Name = "GameText",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = game,
        TextColor3 = t.Accent,
        TextSize = IsMobile and 10 or 9,
        Parent = gameBadge
    })
    
    task.spawn(function()
        task.wait(0.05)
        if gameText and gameText.Parent then
            local textWidth = gameText.TextBounds.X
            gameBadge.Size = UDim2.new(0, textWidth + 14, 0, 18)
            gameText.Size = UDim2.new(1, 0, 1, 0)
        end
    end)
    
    Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftPadding, 0, 28),
        Size = UDim2.new(1, -leftPadding - 120, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = t.Text,
        TextSize = IsMobile and 14 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card
    })
    
    Create("TextLabel", {
        Name = "Views",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftPadding, 0, IsMobile and 50 or 48),
        Size = UDim2.new(0.5, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = FormatNumber(views) .. " views",
        TextColor3 = t.TextDim,
        TextSize = IsMobile and 11 or 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })
    
    local loadBtn = Create("TextButton", {
        Name = "Load",
        BackgroundColor3 = t.Accent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, IsMobile and 65 or 60, 0, IsMobile and 30 or 26),
        Font = Enum.Font.GothamBold,
        Text = "Load",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = IsMobile and 12 or 11,
        AutoButtonColor = false,
        Parent = card
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })
    
    loadBtn.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(loadBtn, 0.15, { BackgroundColor3 = currentTheme.AccentDark })
    end)
    loadBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(loadBtn, 0.15, { BackgroundColor3 = currentTheme.Accent })
    end)
    
    loadBtn.MouseButton1Click:Connect(function()
        local currentTheme = self:GetActiveTheme()
        loadBtn.Text = "..."
        Tween(loadBtn, 0.1, { BackgroundColor3 = currentTheme.TextDim })
        
        local function executeAndUpdate(content)
            local success, err = self:ExecuteScript(content)
            
            if success then
                loadBtn.Text = "OK"
                Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Success })
            else
                loadBtn.Text = "Fail"
                Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Error })
            end
            
            task.delay(2, function()
                if loadBtn and loadBtn.Parent then
                    local newTheme = self:GetActiveTheme()
                    loadBtn.Text = "Load"
                    Tween(loadBtn, 0.2, { BackgroundColor3 = newTheme.Accent })
                end
            end)
        end
        
        if script and script ~= "" then
            executeAndUpdate(script)
        elseif self.CurrentAPI == "rscripts" and id and id ~= "" then
            self:FetchScriptContent("rscripts", id, function(content, err)
                if content then
                    executeAndUpdate(content)
                else
                    loadBtn.Text = "Fail"
                    Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Error })
                    task.delay(2, function()
                        if loadBtn and loadBtn.Parent then
                            local newTheme = self:GetActiveTheme()
                            loadBtn.Text = "Load"
                            Tween(loadBtn, 0.2, { BackgroundColor3 = newTheme.Accent })
                        end
                    end)
                end
            end)
        else
            loadBtn.Text = "Fail"
            Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Error })
            task.delay(2, function()
                if loadBtn and loadBtn.Parent then
                    local newTheme = self:GetActiveTheme()
                    loadBtn.Text = "Load"
                    Tween(loadBtn, 0.2, { BackgroundColor3 = newTheme.Accent })
                end
            end)
        end
    end)
    
    local favBtn = Create("TextButton", {
        Name = "Favorite",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -(IsMobile and 85 or 78), 0.5, 0),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.Gotham,
        Text = self:IsFavorite(id) and "★" or "☆",
        TextColor3 = self:IsFavorite(id) and Color3.fromRGB(255, 200, 50) or t.TextDim,
        TextSize = IsMobile and 18 or 16,
        AutoButtonColor = false,
        Parent = card
    })
    
    favBtn.MouseButton1Click:Connect(function()
        local currentTheme = self:GetActiveTheme()
        local isFav = self:ToggleFavorite(scriptData, self.CurrentAPI)
        favBtn.Text = isFav and "★" or "☆"
        favBtn.TextColor3 = isFav and Color3.fromRGB(255, 200, 50) or currentTheme.TextDim
    end)
    
    return card
end

function ScriptSearch:CreateFavoriteCard(favData, parent, index)
    local t = self:GetActiveTheme()
    
    local title = favData.title or "Unknown"
    local game = favData.game or "Universal"
    local apiSource = favData.apiType or "scriptblox"
    local script = favData.script
    local scriptId = favData.id
    local placeId = favData.placeId
    local imageUrl = favData.imageUrl
    
    local hasIcon = game and game ~= ""
    local iconSize = IsMobile and 52 or 48
    local leftPadding = hasIcon and (iconSize + 16) or 10
    
    local card = Create("Frame", {
        Name = "FavCard_" .. index,
        BackgroundColor3 = t.Card,
        Size = UDim2.new(1, 0, 0, IsMobile and 78 or 72),
        LayoutOrder = index,
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = t.CardBorder, Thickness = 1 })
    })
    
    card.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(card, 0.15, { BackgroundColor3 = currentTheme.CardHover })
    end)
    card.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(card, 0.15, { BackgroundColor3 = currentTheme.Card })
    end)
    
    if hasIcon then
        local iconContainer = Create("Frame", {
            Name = "IconContainer",
            BackgroundColor3 = t.BackgroundSecondary,
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, iconSize, 0, iconSize),
            Parent = card
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        local gameIcon = Create("ImageLabel", {
            Name = "GameIcon",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = "",
            ScaleType = Enum.ScaleType.Crop,
            Parent = iconContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        local rbxthumbUrl = nil
        if placeId and tonumber(placeId) then
            rbxthumbUrl = string.format("rbxthumb://type=GameIcon&id=%s&w=150&h=150", tostring(placeId))
        end
        
        local cachedIcon, cachedBackup = self:GetGameIconSync(game)
        if cachedBackup then
            gameIcon.Image = cachedBackup
        elseif cachedIcon then
            gameIcon.Image = cachedIcon
        elseif rbxthumbUrl then
            gameIcon.Image = rbxthumbUrl
        end
        
        if not cachedBackup then
            self:GetGameIcon(game, function(rbxthumb, backupRbxasset)
                if gameIcon and gameIcon.Parent then
                    if backupRbxasset then
                        gameIcon.Image = backupRbxasset
                    elseif rbxthumb then
                        gameIcon.Image = rbxthumb
                    end
                end
            end)
        end
    end
    
    local gameBadge = Create("Frame", {
        Name = "GameBadge",
        BackgroundColor3 = t.BackgroundSecondary,
        Position = UDim2.new(0, leftPadding, 0, 8),
        Size = UDim2.new(0, 60, 0, 18),
        Parent = card
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })
    
    local gameText = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = game,
        TextColor3 = t.Accent,
        TextSize = IsMobile and 10 or 9,
        Parent = gameBadge
    })
    
    task.spawn(function()
        task.wait(0.05)
        if gameText and gameText.Parent then
            local textWidth = gameText.TextBounds.X
            gameBadge.Size = UDim2.new(0, textWidth + 14, 0, 18)
            gameText.Size = UDim2.new(1, 0, 1, 0)
        end
    end)
    
    Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftPadding, 0, 28),
        Size = UDim2.new(1, -leftPadding - 120, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = t.Text,
        TextSize = IsMobile and 14 or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card
    })
    
    Create("TextLabel", {
        Name = "FavLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftPadding, 0, IsMobile and 50 or 48),
        Size = UDim2.new(0, 60, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "★ Saved",
        TextColor3 = Color3.fromRGB(255, 200, 50),
        TextSize = IsMobile and 11 or 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })
    
    local apiBadge = Create("Frame", {
        Name = "APIBadge",
        BackgroundColor3 = apiSource == "scriptblox" and Color3.fromRGB(50, 70, 100) or Color3.fromRGB(70, 50, 90),
        Position = UDim2.new(0, leftPadding + (IsMobile and 65 or 60), 0, IsMobile and 50 or 48),
        Size = UDim2.new(0, IsMobile and 56 or 52, 0, 16),
        Parent = card
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })
    
    Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = apiSource == "scriptblox" and "ScriptBlox" or "RScripts",
        TextColor3 = Color3.fromRGB(180, 180, 200),
        TextSize = IsMobile and 9 or 8,
        Parent = apiBadge
    })
    
    local loadBtn = Create("TextButton", {
        Name = "Load",
        BackgroundColor3 = t.Accent,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, IsMobile and 65 or 60, 0, IsMobile and 30 or 26),
        Font = Enum.Font.GothamBold,
        Text = "Load",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = IsMobile and 12 or 11,
        AutoButtonColor = false,
        Parent = card
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })
    
    loadBtn.MouseEnter:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(loadBtn, 0.15, { BackgroundColor3 = currentTheme.AccentDark })
    end)
    loadBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(loadBtn, 0.15, { BackgroundColor3 = currentTheme.Accent })
    end)
    
    loadBtn.MouseButton1Click:Connect(function()
        local currentTheme = self:GetActiveTheme()
        loadBtn.Text = "..."
        Tween(loadBtn, 0.1, { BackgroundColor3 = currentTheme.TextDim })
        
        local function executeAndUpdate(content)
            local success, err = self:ExecuteScript(content)
            
            if success then
                loadBtn.Text = "OK"
                Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Success })
            else
                loadBtn.Text = "Fail"
                Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Error })
            end
            
            task.delay(2, function()
                if loadBtn and loadBtn.Parent then
                    local newTheme = self:GetActiveTheme()
                    loadBtn.Text = "Load"
                    Tween(loadBtn, 0.2, { BackgroundColor3 = newTheme.Accent })
                end
            end)
        end
        
        if script and script ~= "" then
            executeAndUpdate(script)
        elseif apiSource == "rscripts" and scriptId and scriptId ~= "" then
            self:FetchScriptContent("rscripts", scriptId, function(content, err)
                if content then
                    executeAndUpdate(content)
                else
                    loadBtn.Text = "Fail"
                    Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Error })
                    task.delay(2, function()
                        if loadBtn and loadBtn.Parent then
                            local newTheme = self:GetActiveTheme()
                            loadBtn.Text = "Load"
                            Tween(loadBtn, 0.2, { BackgroundColor3 = newTheme.Accent })
                        end
                    end)
                end
            end)
        else
            loadBtn.Text = "Fail"
            Tween(loadBtn, 0.2, { BackgroundColor3 = currentTheme.Error })
            task.delay(2, function()
                if loadBtn and loadBtn.Parent then
                    local newTheme = self:GetActiveTheme()
                    loadBtn.Text = "Load"
                    Tween(loadBtn, 0.2, { BackgroundColor3 = newTheme.Accent })
                end
            end)
        end
    end)
    
    local removeBtn = Create("ImageButton", {
        Name = "Remove",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -(IsMobile and 85 or 78), 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://101835868796103",
        ImageColor3 = t.TextDim,
        AutoButtonColor = false,
        Parent = card
    })
    
    removeBtn.MouseEnter:Connect(function()
        Tween(removeBtn, 0.15, { ImageColor3 = Color3.fromRGB(255, 80, 80) })
    end)
    removeBtn.MouseLeave:Connect(function()
        local currentTheme = self:GetActiveTheme()
        Tween(removeBtn, 0.15, { ImageColor3 = currentTheme.TextDim })
    end)
    
    removeBtn.MouseButton1Click:Connect(function()
        for i, fav in ipairs(self.Favorites) do
            if fav.id == scriptId then
                table.remove(self.Favorites, i)
                break
            end
        end
        self:SaveFavorites()
        
        Tween(card, 0.2, { BackgroundTransparency = 1 })
        task.delay(0.2, function()
            if card and card.Parent then
                card:Destroy()
            end
            if #self.Favorites == 0 and self.LoadingLabel then
                self.LoadingLabel.Text = "No favorites yet\nStar scripts to add them here"
                self.LoadingLabel.Visible = true
            end
        end)
    end)
    
    return card
end

function ScriptSearch:SetupXanIntegration()
    local xan = self:GetXanInstance()
    if not xan then return end
    
    if xan.OnThemeChanged and not self._themeCallbackRegistered then
        self._themeCallbackRegistered = true
        xan:OnThemeChanged(function(newTheme)
            if self.GUI and self.GUI.Parent then
                self:UpdateTheme()
            end
        end)
    end
    
    local toggleKey = (xan.ToggleKey) or Enum.KeyCode.RightControl
    local unloadKey = (xan.UnloadKey) or Enum.KeyCode.End
    
    if self._toggleConnection then
        pcall(function() self._toggleConnection:Disconnect() end)
    end
    if self._unloadConnection then
        pcall(function() self._unloadConnection:Disconnect() end)
    end
    
    self._toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            if self._hiddenByXanToggle then
                self._hiddenByXanToggle = false
                if self._wasOpenBeforeXanHide then
                    if self._wasMinimizedBeforeXanHide then
                        self:ShowMinimized()
                    else
                        self:Show()
                    end
                end
                self._wasOpenBeforeXanHide = false
                self._wasMinimizedBeforeXanHide = false
            elseif self.IsOpen then
                self._wasOpenBeforeXanHide = true
                self._wasMinimizedBeforeXanHide = false
                self._hiddenByXanToggle = true
                self:HideInstant()
            elseif self.IsMinimized then
                self._wasOpenBeforeXanHide = true
                self._wasMinimizedBeforeXanHide = true
                self._hiddenByXanToggle = true
                self:HideInstant()
            else
                self:Show()
            end
        elseif input.KeyCode == unloadKey then
            self:Destroy()
        end
    end)
end

function ScriptSearch:ShowMinimized()
    if not self.GUI then
        self:CreateUI()
    end
    self.IsOpen = false
    self.IsMinimized = true
    
    if self.MainFrame then
        self.MainFrame.Visible = false
    end
    
    if self.MinimizedBar then
        self.MinimizedBar.Visible = true
        self.MinimizedBar.BackgroundTransparency = 0
        
        local minStroke = self.MinimizedBar:FindFirstChildOfClass("UIStroke")
        if minStroke then minStroke.Transparency = 0 end
        
        for _, child in ipairs(self.MinimizedBar:GetChildren()) do
            if child:IsA("GuiObject") then
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    child.ImageTransparency = 0
                elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.TextTransparency = 0
                end
            end
        end
    end
end

function ScriptSearch:HideInstant()
    self.IsOpen = false
    self.IsMinimized = false
    self._animating = false
    
    if self.MainFrame then
        self.MainFrame.Visible = false
    end
    if self.MinimizedBar then
        self.MinimizedBar.Visible = false
    end
end

function ScriptSearch:Show()
    if not self.GUI then
        self:CreateUI()
    end
    self.IsOpen = true
    self.IsMinimized = false
    
    local windowWidth = IsMobile and 340 or 420
    local windowHeight = IsMobile and 400 or 480
    
    self.MainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    self.MainFrame.BackgroundTransparency = 0
    self.MainFrame.Visible = true
    
    if self.MinimizedBar then
        self.MinimizedBar.Visible = false
    end
    
    local contentFrame = self.MainFrame:FindFirstChild("ContentContainer")
    local header = self.MainFrame:FindFirstChild("Header")
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    
    if contentFrame then contentFrame.GroupTransparency = 0 end
    if header then header.BackgroundTransparency = 0 end
    if stroke then stroke.Transparency = 0 end
    
    task.delay(0.1, function()
        if not self.TrendingLoaded[self.CurrentAPI] and self.IsOpen and self.CurrentView == "trending" then
            self:LoadTrending()
        end
    end)
end

function ScriptSearch:ShowFromMinimized()
    self.IsOpen = true
    
    local windowWidth = IsMobile and 340 or 420
    local windowHeight = IsMobile and 400 or 480
    local targetSize = UDim2.new(0, windowWidth, 0, windowHeight)
    
    local contentFrame = self.MainFrame:FindFirstChild("ContentContainer")
    local header = self.MainFrame:FindFirstChild("Header")
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame.Visible = true
    
    if contentFrame then contentFrame.GroupTransparency = 1 end
    if header then header.BackgroundTransparency = 1 end
    if stroke then stroke.Transparency = 1 end
    
    local scaleInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local fadeInInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    TweenService:Create(self.MainFrame, scaleInfo, { Size = targetSize }):Play()
    TweenService:Create(self.MainFrame, fadeInInfo, { BackgroundTransparency = 0 }):Play()
    
    if header then
        TweenService:Create(header, fadeInInfo, { BackgroundTransparency = 0 }):Play()
    end
    if stroke then
        TweenService:Create(stroke, fadeInInfo, { Transparency = 0 }):Play()
    end
    
    task.delay(0.15, function()
        if contentFrame and self.IsOpen then
            TweenService:Create(contentFrame, fadeInInfo, { GroupTransparency = 0 }):Play()
        end
    end)
    
    task.delay(0.35, function()
        self._animating = false
    end)
end

function ScriptSearch:Hide()
    if self._animating then return end
    
    self._animating = true
    self.IsOpen = false
    
    if not self.MainFrame then
        self._animating = false
        return
    end
    
    local contentFrame = self.MainFrame:FindFirstChild("ContentContainer")
    local header = self.MainFrame:FindFirstChild("Header")
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    
    local currentSize = self.MainFrame.Size
    local targetSize = UDim2.new(0, currentSize.X.Offset * 0.95, 0, currentSize.Y.Offset * 0.95)
    
    local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local scaleInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    if contentFrame then
        TweenService:Create(contentFrame, fadeInfo, { GroupTransparency = 1 }):Play()
    end
    if header then
        TweenService:Create(header, fadeInfo, { BackgroundTransparency = 1 }):Play()
    end
    if stroke then
        TweenService:Create(stroke, fadeInfo, { Transparency = 1 }):Play()
    end
    
    TweenService:Create(self.MainFrame, fadeInfo, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(self.MainFrame, scaleInfo, { Size = targetSize }):Play()
    
    task.delay(0.18, function()
        if self.MainFrame and not self.IsOpen then
            self.MainFrame.Visible = false
            
            local windowWidth = IsMobile and 340 or 420
            local windowHeight = IsMobile and 400 or 480
            self.MainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
            self.MainFrame.BackgroundTransparency = 0
            if contentFrame then contentFrame.GroupTransparency = 0 end
            if header then header.BackgroundTransparency = 0 end
            if stroke then stroke.Transparency = 0 end
        end
        self._animating = false
    end)
end

function ScriptSearch:Toggle()
    if self.IsOpen then
        self:Hide()
    else
        self:Show()
    end
end

function ScriptSearch:ToggleUI()
    self:Toggle()
end

function ScriptSearch:Minimize()
    if not self.MainFrame or not self.MinimizedBar or self._animating then return end
    
    self._animating = true
    self.IsMinimized = true
    self.IsOpen = false
    
    local contentFrame = self.MainFrame:FindFirstChild("ContentContainer")
    local header = self.MainFrame:FindFirstChild("Header")
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    local minStroke = self.MinimizedBar:FindFirstChildOfClass("UIStroke")
    
    local minBarWidth = self.MinimizedBar.Size.X.Offset
    local minBarHeight = self.MinimizedBar.Size.Y.Offset
    local targetSize = UDim2.new(0, minBarWidth, 0, minBarHeight)
    
    self.MinimizedBar.Position = self.MainFrame.Position
    self.MinimizedBar.BackgroundTransparency = 1
    self.MinimizedBar.Visible = true
    if minStroke then minStroke.Transparency = 1 end
    
    for _, child in ipairs(self.MinimizedBar:GetChildren()) do
        if child:IsA("GuiObject") then
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                child.ImageTransparency = 1
            elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = 1
            end
        end
    end
    
    local contentFade = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if contentFrame then
        TweenService:Create(contentFrame, contentFade, { GroupTransparency = 1 }):Play()
    end
    
    task.spawn(function()
        task.wait(0.08)
        if not self.IsMinimized then return end
        
        local morphInfo = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0)
        local fadeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        TweenService:Create(self.MainFrame, morphInfo, { Size = targetSize }):Play()
        TweenService:Create(self.MainFrame, fadeInfo, { BackgroundTransparency = 0.5 }):Play()
        
        if header then
            TweenService:Create(header, fadeInfo, { BackgroundTransparency = 1 }):Play()
        end
        if stroke then
            TweenService:Create(stroke, fadeInfo, { Transparency = 0.5 }):Play()
        end
        
        task.wait(0.28)
        if not self.IsMinimized then 
            self._animating = false
            return 
        end
        
        self.MainFrame.Visible = false
        self.MinimizedBar.Position = self.MainFrame.Position
        
        local revealInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        TweenService:Create(self.MinimizedBar, revealInfo, { BackgroundTransparency = 0 }):Play()
        if minStroke then
            TweenService:Create(minStroke, revealInfo, { Transparency = 0 }):Play()
        end
        
        for _, child in ipairs(self.MinimizedBar:GetChildren()) do
            if child:IsA("GuiObject") then
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    TweenService:Create(child, revealInfo, { ImageTransparency = 0 }):Play()
                elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, revealInfo, { TextTransparency = 0 }):Play()
                end
            end
        end
        
        task.wait(0.22)
        self._animating = false
    end)
end

function ScriptSearch:Restore()
    if not self.MainFrame or not self.MinimizedBar or self._animating then return end
    
    self._animating = true
    self.IsMinimized = false
    self.IsOpen = true
    
    local windowWidth = IsMobile and 340 or 420
    local windowHeight = IsMobile and 400 or 480
    local targetSize = UDim2.new(0, windowWidth, 0, windowHeight)
    
    local contentFrame = self.MainFrame:FindFirstChild("ContentContainer")
    local header = self.MainFrame:FindFirstChild("Header")
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    local minStroke = self.MinimizedBar:FindFirstChildOfClass("UIStroke")
    
    self.MainFrame.Size = self.MinimizedBar.Size
    self.MainFrame.Position = self.MinimizedBar.Position
    self.MainFrame.BackgroundTransparency = 0.5
    self.MainFrame.Visible = true
    
    if contentFrame then contentFrame.GroupTransparency = 1 end
    if header then header.BackgroundTransparency = 1 end
    if stroke then stroke.Transparency = 0.5 end
    
    task.spawn(function()
        local fadeOutInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        TweenService:Create(self.MinimizedBar, fadeOutInfo, { BackgroundTransparency = 1 }):Play()
        if minStroke then
            TweenService:Create(minStroke, fadeOutInfo, { Transparency = 1 }):Play()
        end
        
        for _, child in ipairs(self.MinimizedBar:GetChildren()) do
            if child:IsA("GuiObject") then
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    TweenService:Create(child, fadeOutInfo, { ImageTransparency = 1 }):Play()
                elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, fadeOutInfo, { TextTransparency = 1 }):Play()
                end
            end
        end
        
        local expandInfo = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
        local fadeInInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        TweenService:Create(self.MainFrame, expandInfo, { Size = targetSize }):Play()
        TweenService:Create(self.MainFrame, fadeInInfo, { BackgroundTransparency = 0 }):Play()
        
        if stroke then
            TweenService:Create(stroke, fadeInInfo, { Transparency = 0 }):Play()
        end
        
        task.wait(0.1)
        if not self.IsOpen then 
            self._animating = false
            return 
        end
        
        self.MinimizedBar.Visible = false
        self.MinimizedBar.BackgroundTransparency = 0
        if minStroke then minStroke.Transparency = 0 end
        
        for _, child in ipairs(self.MinimizedBar:GetChildren()) do
            if child:IsA("GuiObject") then
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    child.ImageTransparency = 0
                elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.TextTransparency = 0
                end
            end
        end
        
        local headerFade = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if header then
            TweenService:Create(header, headerFade, { BackgroundTransparency = 0 }):Play()
        end
        
        task.wait(0.12)
        if not self.IsOpen then 
            self._animating = false
            return 
        end
        
        local contentReveal = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if contentFrame then
            TweenService:Create(contentFrame, contentReveal, { GroupTransparency = 0 }):Play()
        end
        
        task.wait(0.2)
        self._animating = false
    end)
end

function ScriptSearch:Destroy()
    if self._toggleConnection then
        pcall(function() self._toggleConnection:Disconnect() end)
        self._toggleConnection = nil
    end
    if self._unloadConnection then
        pcall(function() self._unloadConnection:Disconnect() end)
        self._unloadConnection = nil
    end
    if self.GUI then
        self.GUI:Destroy()
        self.GUI = nil
    end
    self.IsOpen = false
    self.IsMinimized = false
    self.IsLoading = false
    self._animating = false
    self._requestId = 0
    self.CurrentView = "trending"
    self.MainFrame = nil
    self.ContentFrame = nil
    self.MinimizedBar = nil
    self.MobileToggleBtn = nil
    self.ResultsFrame = nil
    self.LoadingLabel = nil
    self.TrendingLoaded = {}
    self._themeCallbackRegistered = false
    self._wasOpenBeforeXanHide = false
    self._wasMinimizedBeforeXanHide = false
    self._hiddenByXanToggle = false
end

function ScriptSearch:Unload()
    self:Destroy()
end

function ScriptSearch:Init(xanTheme)
    self:LoadFavorites()
    self:LoadGameIconCache()
    if xanTheme then
        self.Theme = xanTheme
    end
    return self
end

return ScriptSearch
