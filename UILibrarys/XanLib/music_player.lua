--[[
    Xan Music Player 

    A media player tool for playing local audio files and user-configured streams.
    
    QUICK START:
    ------------
    local player = MusicPlayer:CreateUI()
    
    OPTIONS:
    --------
    MusicPlayer:CreateUI({
        DemoMode = false,     -- Use demo API for testing
        SkipTOS = false,      -- Skip the first-run TOS popup (for devs)
        ShowTOS = true,       -- Same as above (set false to skip)
        Theme = {...}         -- Custom theme colors
    })
    
    The TOS popup only shows ONCE on first run, then saves acceptance to JSON.
    Devs integrating into their own scripts can skip it with SkipTOS = true.
    
    LEGAL NOTICE:
    -------------
    This software is provided for legitimate, non-infringing uses including:
    - Playing your own local audio files
    - Streaming from servers you have authorization to access
    - Personal music backups
    - Royalty-free / Creative Commons content
    
    By using this software, you agree:
    - Not to use it to infringe third-party copyrights
    - That you are responsible for your own API sources and content
    - That Xan UI provides the tool, not the content
    
    SETTING UP YOUR OWN STREAMING SERVER:
    -------------------------------------
    Host your own personal media server and add the URL in Settings.
    See server/music_server_dist.py for a ready-to-use implementation.
    
    Required endpoint: GET /api/browse?limit=100&offset=0
    
    Expected JSON response:
    {
        "success": true,
        "tracks": [
            {
                "song_title": "Song Name",
                "artist_name": "Artist Name",
                "album_name": "Album Name",
                "genre": "Genre",
                "file_url": "https://your-server.com/song.mp3",
                "image_asset_id": "123456789"
            }
        ],
        "total_count": 100
    }
    
    TRACK FIELDS:
    - song_title / title / name - Track name
    - artist_name / artist - Artist  
    - album_name / album - Album
    - genre - Genre tag
    - file_url / url / stream_url - Direct audio URL from your server
    - image_asset_id / icon_id - Roblox asset ID for artwork (optional)
    - image_url - Or full "rbxassetid://123" string (optional)
]]

local function MusicPlayerInit(Xan)

    Xan = Xan or rawget(_G, "Xan") or _G.Xan
    
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local SoundService = game:GetService("SoundService")
    
    local LocalPlayer = Players.LocalPlayer
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    local Util = Xan and Xan.Util or nil
    local RenderManager = Xan and Xan.RenderManager or nil
    
    local function Create(class, props, children)
        if Util and Util.Create then
            return Util.Create(class, props, children)
        end
        local inst = Instance.new(class)
        for k, v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() inst[k] = v end)
            end
        end
        if children then
            for _, child in ipairs(children) do
                child.Parent = inst
            end
        end
        if props.Parent then
            inst.Parent = props.Parent
        end
        return inst
    end
    
    local function Tween(obj, duration, props)
        if Util and Util.Tween then
            return Util.Tween(obj, duration, props)
        end
        local info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(obj, info, props):Play()
    end
    
    local function GetGhostFolderName(baseName)
        if Xan and Xan.GhostMode and Util and Util.GenerateGhostName then
            return Util.GenerateGhostName(baseName)
        end
        return baseName
    end
    
    local _renderTaskCounter = 0
    local _fallbackConnections = {}
    
    local function AddRenderTask(taskId, callback, options)
        options = options or {}
        if RenderManager and RenderManager.AddTask then
            RenderManager.AddTask(taskId, callback, options)
            return taskId
        else
            local conn = RunService.Heartbeat:Connect(function(dt)
                local now = os.clock()
                callback(dt, now)
            end)
            _fallbackConnections[taskId] = conn
            return taskId
        end
    end
    
    local function RemoveRenderTask(taskId)
        if RenderManager and RenderManager.RemoveTask then
            RenderManager.RemoveTask(taskId)
        end
        if _fallbackConnections[taskId] then
            pcall(function() _fallbackConnections[taskId]:Disconnect() end)
            _fallbackConnections[taskId] = nil
        end
    end
    
    local function GenerateTaskId(prefix)
        _renderTaskCounter = _renderTaskCounter + 1
        return "MusicPlayer_" .. prefix .. "_" .. _renderTaskCounter
    end
    
    local STORAGE_FOLDER = GetGhostFolderName("xanbar") .. "/music"
    local CACHE_FOLDER = GetGhostFolderName("xanbar") .. "/music_cache"
    local LIBRARY_FILE = GetGhostFolderName("xanbar") .. "/music_library.json"
    local API_SOURCES_FILE = GetGhostFolderName("xanbar") .. "/api_sources.json"
    
    local MusicPlayer = {
        Version = "2.1.0-open",
        Tracks = {},
        Queue = {},
        UpNext = {},
        QueueIndex = 1,
        CurrentSound = nil,
        CurrentTrack = nil,
        IsPlaying = false,
        IsShuffled = false,
        IsRepeating = false,
        LoopEnabled = false,
        Volume = 0.5,
        CachedSongs = {},
        ApiSources = {},
        LibraryTracks = {},
        ActiveApiSource = nil,
        LibraryPlaybackList = {},
        LibraryPlaybackIndex = 0,
        IsLibraryPlayback = false,
        OnLibraryTrackEnded = nil,
        CuteVisualizer = nil,
        CuteVisualizerEnabled = false,
        VisualizerMode = "Reactive",
        KeepVisibleOnHide = false,
        _RenderTaskIds = {},
        DemoMode = false,
        DemoTracks = {},
        FeaturedCount = 0,
        Config = {
            StorageFolder = STORAGE_FOLDER,
            CacheFolder = CACHE_FOLDER,
            LibraryFile = LIBRARY_FILE,
            ApiSourcesFile = API_SOURCES_FILE,
            ApiUrl = nil,
            CustomApiHandler = nil,
            DemoApiUrl = "https://api.xan.bar"
        }
    }
    
    MusicPlayer.ApiSources = {}
    
    local function GetHttpRequest()
       
        if http and http.request then return http.request end
        if http_request then return http_request end
     
        if request then return request end
        return nil
    end
    
    function MusicPlayer:LoadApiSources()
        self.ApiSources = {}
        
        pcall(function()
            EnsureStorageFolders()
            if isfile(self.Config.ApiSourcesFile) then
                local data = readfile(self.Config.ApiSourcesFile)
                if data and data ~= "" then
                    local sources = HttpService:JSONDecode(data)
                    for _, src in ipairs(sources) do
                        table.insert(self.ApiSources, src)
                    end
                end
            end
        end)
        
        return self.ApiSources
    end
    
    function MusicPlayer:SaveApiSources()
        pcall(function()
            EnsureStorageFolders()
            writefile(self.Config.ApiSourcesFile, HttpService:JSONEncode(self.ApiSources))
        end)
    end
    
    function MusicPlayer:AddApiSource(name, url)
        if not name or name == "" or not url or url == "" then return false end
        
        for _, src in ipairs(self.ApiSources) do
            if src.name == name then return false end
        end
        
        table.insert(self.ApiSources, {
            name = name,
            url = url,
            enabled = true,
            isDefault = false
        })
        self:SaveApiSources()
        return true
    end
    
    function MusicPlayer:RemoveApiSource(name)
        for i, src in ipairs(self.ApiSources) do
            if src.name == name then
                table.remove(self.ApiSources, i)
                self:SaveApiSources()
                return true
            end
        end
        return false
    end
    
    function MusicPlayer:ToggleApiSource(name)
        for _, src in ipairs(self.ApiSources) do
            if src.name == name then
                src.enabled = not src.enabled
                self:SaveApiSources()
                return src.enabled
            end
        end
        return nil
    end
    
    function MusicPlayer:FetchLibraryFromApi(source, options)
        if not source or not source.url then return {}, "Invalid source" end
        
        options = options or {}
        local apiFilter = options.filter or "all"
        local genreFilter = options.genre or ""
        local searchQuery = options.search or ""
        
        local tracks = {}
        local httpRequest = GetHttpRequest()
        if not httpRequest then 
            return tracks, "HTTP not available"
        end
        
        local limit = 1000
        local offset = 0
        local hasMore = true
        local currentPage = 0
        local lastError = nil
        local serverTotal = 0
        local maxPages = 50
        
        while hasMore do
            local success, err = pcall(function()
                local apiUrl = source.url .. "/api/browse?limit=" .. limit .. "&offset=" .. offset
                
                if apiFilter == "trending" then
                    apiUrl = apiUrl .. "&filter=trending&sort=trending"
                elseif apiFilter == "featured" then
                    apiUrl = apiUrl .. "&filter=featured"
                elseif apiFilter == "newest" then
                    apiUrl = apiUrl .. "&sort=newest"
                end
                
                if genreFilter and genreFilter ~= "" then
                    apiUrl = apiUrl .. "&genre=" .. HttpService:UrlEncode(genreFilter)
                end
                
                if searchQuery and searchQuery ~= "" then
                    apiUrl = apiUrl .. "&search=" .. HttpService:UrlEncode(searchQuery)
                end
                
                local response = httpRequest({
                    Url = apiUrl,
                    Method = "GET",
                    Headers = { ["Content-Type"] = "application/json" }
                })
                
                if response and response.Body then
                    local decodeSuccess, data = pcall(function()
                        return HttpService:JSONDecode(response.Body)
                    end)
                    
                    if not decodeSuccess then
                        lastError = "Invalid JSON response"
                        hasMore = false
                        return
                    end
                    
                    if type(data) ~= "table" then
                        lastError = "Unexpected API response format"
                        hasMore = false
                        return
                    end
                    
                    if decodeSuccess and data then
                        if data.available_genres and currentPage == 0 then
                            self.AvailableGenres = data.available_genres
                        end
                        if data.data and data.data.available_genres and currentPage == 0 then
                            self.AvailableGenres = data.data.available_genres
                        end
                        
                        if currentPage == 0 then
                            local fc = data.leets_picks_count or (data.data and data.data.leets_picks_count)
                            if fc and fc > 0 then
                                self.FeaturedCount = fc
                            end
                        end
                        
                        if currentPage == 0 then
                            serverTotal = data.total or data.total_count or (data.data and (data.data.total or data.data.total_count)) or 0
                        end
                        
                        local songList = nil
                        if data.success and data.tracks then
                            songList = data.tracks
                        elseif data.data and data.data.songs then
                            songList = data.data.songs
                        elseif data.data and data.data.tracks then
                            songList = data.data.tracks
                        elseif data.data and type(data.data) == "table" and #data.data > 0 then
                            songList = data.data
                        elseif type(data) == "table" and data.songs then
                            songList = data.songs
                        elseif type(data) == "table" and #data > 0 then
                            songList = data
                        elseif data.error then
                            lastError = data.error
                            hasMore = false
                            return
                        end
                        
                        if songList and #songList > 0 then
                            for _, song in ipairs(songList) do
                                local fileUrl = song.file_url or song.url or song.stream_url or song.audio_url
                                
                                local imageAssetId = song.image_asset_id or song.icon_id or ""
                                local imageUrl = song.image_url or ""
                                if (not imageUrl or imageUrl == "") and imageAssetId and imageAssetId ~= "" then
                                    imageUrl = "rbxassetid://" .. tostring(imageAssetId)
                                end
                                
                                if fileUrl then
                                    table.insert(tracks, {
                                        name = song.song_title or song.title or song.name or "Unknown",
                                        artist = song.artist_name or song.artist or "Unknown Artist",
                                        album = song.album_name or song.album,
                                        genre = song.genre,
                                        path = fileUrl,
                                        source = source.name,
                                        id = song.id,
                                        generated_name = song.generated_name or song.file_url,
                                        image_url = imageUrl,
                                        image_asset_id = imageAssetId,
                                        streams = song.streams or song.plays or 0,
                                        featured = song.demo_pick or song.leets_pick or false
                                    })
                                end
                            end
                            
                            offset = offset + #songList
                            if serverTotal > 0 then
                                hasMore = #tracks < serverTotal and currentPage < maxPages
                            else
                                hasMore = #songList >= limit and currentPage < maxPages
                            end
                        else
                            hasMore = false
                        end
                    end
                else
                    lastError = "No response from server"
                    hasMore = false
                end
            end)
            
            if not success then
                lastError = err or "Request failed"
                hasMore = false
            end
            
            currentPage = currentPage + 1
        end
        
        self.ServerTotalTracks = serverTotal > 0 and serverTotal or #tracks
        return tracks, lastError
    end
    
    function MusicPlayer:FetchDemoTracks()
        local tracks = {}
        local httpRequest = GetHttpRequest()
        if not httpRequest then 
            return tracks, "HTTP not available"
        end
        
        local lastError = nil
        local demoUrl = self.Config.DemoApiUrl or "https://api.xan.bar"
        
        local success, err = pcall(function()
            local apiUrl = demoUrl .. "/api/demo/leets?limit=50"
            
            local response = httpRequest({
                Url = apiUrl,
                Method = "GET",
                Headers = { ["Content-Type"] = "application/json" }
            })
            
            if response and response.Body then
                local decodeSuccess, data = pcall(function()
                    return HttpService:JSONDecode(response.Body)
                end)
                
                if not decodeSuccess then
                    lastError = "Invalid JSON response"
                    return
                end
                
                if type(data) ~= "table" then
                    lastError = "Unexpected API response format"
                    return
                end
                
                if data.success and data.tracks then
                    self.FeaturedCount = data.leets_picks_count or data.total_count or #data.tracks
                    
                    if data.available_genres then
                        self.AvailableGenres = data.available_genres
                    end
                    
                    for _, song in ipairs(data.tracks) do
                        local fileUrl = song.file_url or song.url or song.stream_url
                        
                        local imageAssetId = song.image_asset_id or song.icon_id or ""
                        local imageUrl = song.image_url or ""
                        if (not imageUrl or imageUrl == "") and imageAssetId and imageAssetId ~= "" then
                            imageUrl = "rbxassetid://" .. tostring(imageAssetId)
                        end
                        
                        if fileUrl then
                            table.insert(tracks, {
                                name = song.song_title or song.title or song.name or "Unknown",
                                artist = song.artist_name or song.artist or "Unknown Artist",
                                album = song.album_name or song.album,
                                genre = song.genre,
                                path = fileUrl,
                                source = source.name,
                                id = song.id,
                                generated_name = song.generated_name or song.file_url,
                                image_url = imageUrl,
                                image_asset_id = imageAssetId,
                                streams = song.streams or song.plays or 0,
                                featured = true,
                                isDemo = true
                            })
                        end
                    end
                elseif data.error then
                    lastError = data.error
                end
            else
                lastError = "No response from server"
            end
        end)
        
        if not success then
            lastError = err or "Request failed"
        end
        
        self.DemoTracks = tracks
        return tracks, lastError
    end
    
    function MusicPlayer:EnableDemoMode()
        self.DemoMode = true
        
        local demoSourceExists = false
        for _, src in ipairs(self.ApiSources) do
            if src.isDemo then
                demoSourceExists = true
                src.enabled = true
                break
            end
        end
        
        if not demoSourceExists then
            table.insert(self.ApiSources, 1, {
                name = "Featured",
                url = self.Config.DemoApiUrl or "https://api.xan.bar",
                enabled = true,
                isDefault = false,
                isDemo = true
            })
        end
        
        return self
    end
    
    function MusicPlayer:DisableDemoMode()
        self.DemoMode = false
        self.DemoTracks = {}
        
        for i = #self.ApiSources, 1, -1 do
            if self.ApiSources[i].isDemo then
                table.remove(self.ApiSources, i)
            end
        end
        
        return self
    end
    
    local function shuffleArray(arr)
        for i = #arr, 2, -1 do
            local j = math.random(1, i)
            arr[i], arr[j] = arr[j], arr[i]
        end
        return arr
    end
    
    local function normalizeString(str)
        if not str then return "" end
        str = str:lower()
        str = str:gsub("[%p%c]", " ")
        str = str:gsub("%s+", " ")
        str = str:gsub("^%s+", ""):gsub("%s+$", "")
        return str
    end
    
    local function fuzzyMatch(searchQuery, targetText)
        if not searchQuery or searchQuery == "" then return true, 100 end
        if not targetText or targetText == "" then return false, 0 end
        
        local query = normalizeString(searchQuery)
        local target = normalizeString(targetText)
        
        if query == "" then return true, 100 end
        if target == "" then return false, 0 end
        
        if target:find(query, 1, true) then
            local ratio = #query / #target
            return true, 90 + (ratio * 10)
        end
        
        if target:find("^" .. query) then
            return true, 95
        end
        
        local queryWords = {}
        for word in query:gmatch("%S+") do
            table.insert(queryWords, word)
        end
        
        local matchedWords = 0
        for _, word in ipairs(queryWords) do
            if #word >= 2 and target:find(word, 1, true) then
                matchedWords = matchedWords + 1
            end
        end
        
        if matchedWords > 0 then
            local wordScore = (matchedWords / #queryWords) * 80
            return true, wordScore
        end
        
        local qi, ti = 1, 1
        local matched = 0
        while qi <= #query and ti <= #target do
            if query:sub(qi, qi) == target:sub(ti, ti) then
                matched = matched + 1
                qi = qi + 1
            end
            ti = ti + 1
        end
        
        local seqRatio = matched / #query
        if seqRatio >= 0.7 then
            return true, seqRatio * 60
        end
        
        for _, word in ipairs(queryWords) do
            if #word >= 3 then
                for targetWord in target:gmatch("%S+") do
                    if #targetWord >= 3 then
                        local shorter = #word < #targetWord and word or targetWord
                        local longer = #word >= #targetWord and word or targetWord
                        
                        if longer:find(shorter:sub(1, math.min(3, #shorter)), 1, true) then
                            local lenDiff = math.abs(#word - #targetWord)
                            if lenDiff <= 2 then
                                return true, 50 - (lenDiff * 5)
                            end
                        end
                    end
                end
            end
        end
        
        return false, 0
    end
    
    local function fuzzySearchTrack(query, track)
        if not query or query == "" then return true, 100 end
        
        local bestScore = 0
        
        local nameMatch, nameScore = fuzzyMatch(query, track.name)
        if nameMatch then bestScore = math.max(bestScore, nameScore + 10) end
        
        local artistMatch, artistScore = fuzzyMatch(query, track.artist)
        if artistMatch then bestScore = math.max(bestScore, artistScore + 5) end
        
        local albumMatch, albumScore = fuzzyMatch(query, track.album)
        if albumMatch then bestScore = math.max(bestScore, albumScore) end
        
        local combined = (track.name or "") .. " " .. (track.artist or "")
        local combinedMatch, combinedScore = fuzzyMatch(query, combined)
        if combinedMatch then bestScore = math.max(bestScore, combinedScore) end
        
        return bestScore > 0, bestScore
    end
    
    function MusicPlayer:FetchAllLibraries(forceRefresh, options)
        options = options or {}
        
        if #self.LibraryTracks > 0 and not forceRefresh then
            return self.LibraryTracks, nil
        end
        
        self.LibraryTracks = {}
        self.AvailableGenres = self.AvailableGenres or {}
        local errors = {}
        local seenTracks = {}
        local apiFilter = options.filter or "all"
        
        if self.DemoMode then
            local tracks, err = self:FetchDemoTracks()
            if err then
                table.insert(errors, "Demo: " .. err)
            end
            for _, track in ipairs(tracks) do
                local key = (track.path or "") .. "|" .. (track.name or "")
                if not seenTracks[key] then
                    seenTracks[key] = true
                    table.insert(self.LibraryTracks, track)
                end
            end
        else
            for _, source in ipairs(self.ApiSources) do
                if source.enabled and not source.isDemo then
                    local tracks, err = self:FetchLibraryFromApi(source, options)
                    if err then
                        table.insert(errors, source.name .. ": " .. err)
                    end
                    for _, track in ipairs(tracks) do
                        local key = (track.path or "") .. "|" .. (track.name or "")
                        if not seenTracks[key] then
                            seenTracks[key] = true
                            table.insert(self.LibraryTracks, track)
                        end
                    end
                end
            end
        end
        
        local shouldShuffle = apiFilter == "all" or apiFilter == ""
        if shouldShuffle and not self.DemoMode then
            shuffleArray(self.LibraryTracks)
        end
        
        local errorMsg = #errors > 0 and table.concat(errors, "\n") or nil
        return self.LibraryTracks, errorMsg
    end
    
    function MusicPlayer:RecordStream(track)
        if not track or not track.id then return end
        
        local httpRequest = GetHttpRequest()
        if not httpRequest then return end
        
        task.spawn(function()
            pcall(function()
                for _, source in ipairs(self.ApiSources) do
                    if source.enabled and source.url then
                        httpRequest({
                            Url = source.url .. "/api/play/" .. tostring(track.id),
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" }
                        })
                        break
                    end
                end
            end)
        end)
    end
    
    function MusicPlayer:GetCacheStats()
        local totalOnline = 0
        local cachedCount = 0
        
        for _, track in ipairs(self.Tracks) do
            if track.path and track.path:match("^https?://") then
                totalOnline = totalOnline + 1
                if self:IsCached(track) then
                    cachedCount = cachedCount + 1
                end
            end
        end
        
        local percent = totalOnline > 0 and math.floor((cachedCount / totalOnline) * 100) or 0
        return { total = totalOnline, cached = cachedCount, percent = percent }
    end
    
    function MusicPlayer:AddToMyLibrary(track, onCacheStart, onCacheComplete)
        for _, t in ipairs(self.Tracks) do
            if t.name == track.name and t.path == track.path then
                return false
            end
        end
        
        local newTrack = {
            name = track.name,
            artist = track.artist,
            album = track.album,
            genre = track.genre,
            path = track.path,
            source = track.source,
            id = track.id,
            image_url = track.image_url,
            image_asset_id = track.image_asset_id,
            isLocal = false,
            order = #self.Tracks + 1
        }
        
        table.insert(self.Tracks, newTrack)
        self:SaveLibrary()
        
        if onCacheStart then onCacheStart() end
        
        task.spawn(function()
            self:CacheTrack(newTrack, function(success)
                if success then
                    self:SaveLibrary()
                end
                if onCacheComplete then onCacheComplete(success) end
                if self.OnCacheUpdate then self.OnCacheUpdate() end
            end)
        end)
        
        return true
    end
    
    function MusicPlayer:CacheAllTracks(onProgress)
        local uncached = {}
        for _, track in ipairs(self.Tracks) do
            if track.path and track.path:match("^https?://") and not self:IsCached(track) then
                table.insert(uncached, track)
            end
        end
        
        if #uncached == 0 then
            if onProgress then onProgress(100, 0, 0) end
            return
        end
        
        local total = #uncached
        local completed = 0
        
        for _, track in ipairs(uncached) do
            task.spawn(function()
                self:CacheTrack(track, function(success)
                    completed = completed + 1
                    local percent = math.floor((completed / total) * 100)
                    if onProgress then
                        onProgress(percent, completed, total)
                    end
                end)
            end)
            task.wait(0.1)
        end
    end
    
    local function EnsureFolder(path)
        pcall(function()
            if not isfolder(path) then
                makefolder(path)
            end
        end)
    end
    
    local function EnsureStorageFolders()
        local baseFolder = GetGhostFolderName("xanbar")
        EnsureFolder(baseFolder)
        EnsureFolder(MusicPlayer.Config.StorageFolder)
        EnsureFolder(MusicPlayer.Config.CacheFolder)
    end
    
    local function FormatTime(seconds)
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%d:%02d", mins, secs)
    end
    
    local function GetCacheBarColor(percent)
        if percent <= 50 then
            local t = percent / 50
            return Color3.fromRGB(
                220,
                math.floor(60 + (180 * t)),
                60
            )
        else
            local t = (percent - 50) / 50
            return Color3.fromRGB(
                math.floor(220 - (160 * t)),
                math.floor(240 - (40 * t)),
                math.floor(60 + (60 * t))
            )
        end
    end
    
    function MusicPlayer:SetApi(config)
        if type(config) == "string" then
            if config == "demo" or config == "DEMO" then
                self:EnableDemoMode()
            else
                self.Config.ApiUrl = config
            end
        elseif type(config) == "table" then
            if config.Url then self.Config.ApiUrl = config.Url end
            if config.Handler then self.Config.CustomApiHandler = config.Handler end
            if config.StorageFolder then self.Config.StorageFolder = config.StorageFolder end
            if config.CacheFolder then self.Config.CacheFolder = config.CacheFolder end
            if config.DemoMode or config.Demo then
                self:EnableDemoMode()
            end
        end
    end
    
    function MusicPlayer:LoadLibrary(forceRefresh)
        self.Tracks = {}
        self.LastApiError = nil
        
        EnsureStorageFolders()
        
        local savedTracks = {}
        local savedPaths = {}
        
        pcall(function()
            if isfile(self.Config.LibraryFile) then
                local data = readfile(self.Config.LibraryFile)
                if data and data ~= "" then
                    local library = HttpService:JSONDecode(data)
                    for _, track in ipairs(library) do
                        local url = track.file_url or track.url or track.path
                        if not url and track.generated_name then
                            url = (self.Config.ApiUrl or "") .. "/" .. track.generated_name
                        end
                        if url then
                            local t = {
                                name = track.song_title or track.name or "Unknown",
                                artist = track.artist_name or track.artist or "Unknown",
                                album = track.album,
                                genre = track.genre,
                                path = url,
                                id = track.id,
                                source = track.source,
                                image_url = track.image_url,
                                image_asset_id = track.image_asset_id,
                                isLocal = track.isLocal or false,
                                order = track.order or 9999
                            }
                            table.insert(savedTracks, t)
                            savedPaths[url] = true
                        end
                    end
                end
            end
        end)
        
        table.sort(savedTracks, function(a, b)
            return (a.order or 9999) < (b.order or 9999)
        end)
        
        for _, track in ipairs(savedTracks) do
            table.insert(self.Tracks, track)
        end
        
        pcall(function()
            if isfolder(self.Config.StorageFolder) then
                local files = listfiles(self.Config.StorageFolder)
                for _, file in pairs(files) do
                    local name = file:match("([^/\\]+)$")
                    if name and (name:match("%.mp3$") or name:match("%.ogg$") or name:match("%.wav$")) then
                        if isfile(file) and not savedPaths[file] then
                            table.insert(self.Tracks, {
                                name = name:gsub("%.%w+$", ""),
                                artist = "Local",
                                path = file,
                                isLocal = true
                            })
                        end
                    end
                end
            end
        end)
        
        return self.Tracks
    end
    
    function MusicPlayer:SaveLibrary()
        local savedTracks = {}
        for i, track in ipairs(self.Tracks) do
            table.insert(savedTracks, {
                name = track.name,
                artist = track.artist,
                album = track.album,
                genre = track.genre,
                url = track.path,
                id = track.id,
                source = track.source,
                image_url = track.image_url,
                image_asset_id = track.image_asset_id,
                isLocal = track.isLocal,
                order = i
            })
        end
        pcall(function()
            EnsureStorageFolders()
            writefile(self.Config.LibraryFile, HttpService:JSONEncode(savedTracks))
        end)
    end
    
    function MusicPlayer:AddTrack(track)
        table.insert(self.Tracks, track)
        self:SaveLibrary()
        return #self.Tracks
    end
    
    function MusicPlayer:RemoveTrack(index)
        if self.Tracks[index] then
            table.remove(self.Tracks, index)
            self:SaveLibrary()
        end
    end
    
    function MusicPlayer:IsCached(track)
        if not track or not track.path then return false end
        if track.isLocal then return true end
        local fileName = track.path:match("([^/]+)$") or (track.name .. ".mp3")
        local filePath = self.Config.CacheFolder .. "/" .. fileName
        local success, result = pcall(function()
            return isfile(filePath)
        end)
        return success and result
    end
    
    function MusicPlayer:GetCachedFiles()
        local files = {}
        pcall(function()
            if isfolder(self.Config.CacheFolder) then
                local allFiles = listfiles(self.Config.CacheFolder)
                for _, file in ipairs(allFiles) do
                    table.insert(files, file)
                end
            end
        end)
        return files
    end
    
    function MusicPlayer:PurgeCache()
        local count = 0
        pcall(function()
            if isfolder(self.Config.CacheFolder) then
                local files = listfiles(self.Config.CacheFolder)
                for _, file in ipairs(files) do
                    pcall(function()
                        delfile(file)
                        count = count + 1
                    end)
                end
            end
        end)
        return count
    end
    
    function MusicPlayer:CleanupPreviewCache()
        local count = 0
        pcall(function()
            if not isfolder(self.Config.CacheFolder) then return end
            
            local libraryFileNames = {}
            for _, track in ipairs(self.Tracks) do
                if track.path and track.path:match("^https?://") then
                    local fileName = track.path:match("([^/]+)$") or (track.name .. ".mp3")
                    libraryFileNames[fileName:lower()] = true
                end
            end
            
            local allFiles = listfiles(self.Config.CacheFolder)
            for _, filePath in ipairs(allFiles) do
                local fileName = filePath:match("([^/\\]+)$")
                if fileName and not libraryFileNames[fileName:lower()] then
                    pcall(function()
                        delfile(filePath)
                        count = count + 1
                    end)
                end
            end
        end)
        return count
    end
    
    function MusicPlayer:GetCachedPath(track)
        if track.isLocal then return track.path end
        local fileName = track.path:match("([^/]+)$") or (track.name .. ".mp3")
        return self.Config.CacheFolder .. "/" .. fileName
    end
    
    function MusicPlayer:CacheTrack(track, callback)
        if track.isLocal or self:IsCached(track) then
            if callback then callback(true) end
            return
        end
        
        local httpRequest = GetHttpRequest()
        if not httpRequest then
            if callback then callback(false, "No HTTP function") end
            return
        end
        
        task.spawn(function()
            local success, result = pcall(function()
                return httpRequest({
                    Url = track.path,
                    Method = "GET"
                })
            end)
            
            if success and result and result.Body and #result.Body > 1024 then
                pcall(function()
                    EnsureFolder(self.Config.CacheFolder)
                    local filePath = self:GetCachedPath(track)
                    writefile(filePath, result.Body)
                end)
                if callback then callback(true) end
            else
                if callback then callback(false, "Download failed") end
            end
        end)
    end
    
    function MusicPlayer:Play(track, index)
        if self.CurrentSound then
            self.CurrentSound:Stop()
            self.CurrentSound:Destroy()
            self.CurrentSound = nil
        end
        
        self.CurrentTrack = track
        self.QueueIndex = index or 1
        
        local soundId
        if track.isLocal or self:IsCached(track) then
            local path = track.isLocal and track.path or self:GetCachedPath(track)
            pcall(function()
                soundId = getcustomasset(path)
            end)
        end
        
        if not soundId and not track.isLocal then
            self:CacheTrack(track, function(cached)
                if cached then
                    self:Play(track, index)
                end
            end)
            return
        end
        
        if soundId then
            self.CurrentSound = Create("Sound", {
                SoundId = soundId,
                Volume = self.Volume,
                Looped = self.LoopEnabled,
                Parent = SoundService
            })
            
            self.CurrentSound.Loaded:Wait()
            self.CurrentSound:Play()
            self.IsPlaying = true
            
            self:RecordStream(track)
            
            if self.OnPlayStateChanged then
                self.OnPlayStateChanged(true)
            end
            
            self.CurrentSound.Ended:Connect(function()
                if self.IsRepeating then
                    self.CurrentSound.TimePosition = 0
                    self.CurrentSound:Play()
                elseif #self.UpNext > 0 then
                    local nextTrack = table.remove(self.UpNext, 1)
                    self.IsLibraryPlayback = false
                    self:Play(nextTrack, 0)
                    if self.OnQueueChanged then self.OnQueueChanged() end
                elseif self.IsLibraryPlayback and #self.LibraryPlaybackList > 0 then
                    local nextIdx
                    if self.IsShuffled then
                        if #self.LibraryPlaybackList == 1 then
                            nextIdx = 1
                        else
                            repeat
                                nextIdx = math.random(1, #self.LibraryPlaybackList)
                            until nextIdx ~= self.LibraryPlaybackIndex
                        end
                    else
                        nextIdx = self.LibraryPlaybackIndex + 1
                        if nextIdx > #self.LibraryPlaybackList then
                            self.IsPlaying = false
                            self.IsLibraryPlayback = false
                            if self.OnLibraryTrackEnded then
                                self.OnLibraryTrackEnded(nil, nil)
                            end
                            if self.OnPlayStateChanged then
                                self.OnPlayStateChanged(false)
                            end
                            return
                        end
                    end
                    
                    self.LibraryPlaybackIndex = nextIdx
                    local nextTrack = self.LibraryPlaybackList[nextIdx]
                    if nextTrack then
                        local tempTrack = {
                            name = nextTrack.name,
                            artist = nextTrack.artist,
                            path = nextTrack.path,
                            isLocal = false,
                            image_url = nextTrack.image_url,
                            image_asset_id = nextTrack.image_asset_id
                        }
                        if self.OnLibraryTrackEnded then
                            self.OnLibraryTrackEnded(nextIdx, nextTrack)
                        end
                        self:Play(tempTrack, 0)
                    else
                        self.IsPlaying = false
                        self.IsLibraryPlayback = false
                        if self.OnPlayStateChanged then
                            self.OnPlayStateChanged(false)
                        end
                    end
                elseif #self.Tracks <= 1 then
                    self.IsPlaying = false
                    if self.OnPlayStateChanged then
                        self.OnPlayStateChanged(false)
                    end
                elseif self.QueueIndex >= #self.Tracks and not self.IsShuffled then
                    self.IsPlaying = false
                    if self.OnPlayStateChanged then
                        self.OnPlayStateChanged(false)
                    end
                else
                    self:Next()
                end
            end)
            
            if self.OnTrackChanged then
                self.OnTrackChanged(track)
            end
        end
    end
    
    function MusicPlayer:Pause()
        if self.CurrentSound then
            self.CurrentSound:Pause()
            self.IsPlaying = false
            if self.OnPlayStateChanged then
                self.OnPlayStateChanged(false)
            end
        end
    end
    
    function MusicPlayer:Resume()
        if self.CurrentSound then
            self.CurrentSound:Resume()
            self.IsPlaying = true
            if self.OnPlayStateChanged then
                self.OnPlayStateChanged(true)
            end
        end
    end
    
    function MusicPlayer:Toggle()
        if self.IsPlaying then
            self:Pause()
        elseif self.CurrentSound then
            self:Resume()
        elseif #self.Tracks > 0 then
            self:Play(self.Tracks[1], 1)
        end
    end
    
    function MusicPlayer:Stop()
        if self.CurrentSound then
            self.CurrentSound:Stop()
            self.CurrentSound:Destroy()
            self.CurrentSound = nil
        end
        self.IsPlaying = false
        local wasLibraryPlayback = self.IsLibraryPlayback
        self.CurrentTrack = nil
        self.IsLibraryPlayback = false
        if self.OnPlayStateChanged then
            self.OnPlayStateChanged(false)
        end
        if wasLibraryPlayback then
            task.delay(1, function()
                self:CleanupPreviewCache()
            end)
        end
    end
    
    function MusicPlayer:Next()
        if #self.UpNext > 0 then
            local nextTrack = table.remove(self.UpNext, 1)
            self.IsLibraryPlayback = false
            self:Play(nextTrack, 0)
            if self.OnQueueChanged then self.OnQueueChanged() end
            return
        end
        
        if self.IsLibraryPlayback and self.LibraryPlaybackList and #self.LibraryPlaybackList > 0 then
            local nextIdx
            if self.IsShuffled then
                if #self.LibraryPlaybackList == 1 then
                    nextIdx = 1
                else
                    repeat
                        nextIdx = math.random(1, #self.LibraryPlaybackList)
                    until nextIdx ~= self.LibraryPlaybackIndex
                end
            else
                nextIdx = self.LibraryPlaybackIndex + 1
                if nextIdx > #self.LibraryPlaybackList then
                    return
                end
            end
            
            self.LibraryPlaybackIndex = nextIdx
            local nextTrack = self.LibraryPlaybackList[nextIdx]
            if nextTrack then
                local tempTrack = {
                    name = nextTrack.name,
                    artist = nextTrack.artist,
                    path = nextTrack.path,
                    isLocal = false,
                    image_url = nextTrack.image_url,
                    image_asset_id = nextTrack.image_asset_id
                }
                if self.OnLibraryTrackEnded then
                    self.OnLibraryTrackEnded(nextIdx, nextTrack)
                end
                self:Play(tempTrack, 0)
                return
            end
            return
        end
        
        if #self.Tracks == 0 then return end
        if #self.Tracks == 1 then return end
        
        local nextIndex
        if self.IsShuffled then
            repeat
                nextIndex = math.random(1, #self.Tracks)
            until nextIndex ~= self.QueueIndex or #self.Tracks == 1
        else
            nextIndex = self.QueueIndex + 1
            if nextIndex > #self.Tracks then
                return
            end
        end
        
        self:Play(self.Tracks[nextIndex], nextIndex)
    end
    
    function MusicPlayer:AddToQueue(track)
        local queueTrack = {
            name = track.name,
            artist = track.artist,
            path = track.path,
            isLocal = track.isLocal or false,
            image_url = track.image_url,
            image_asset_id = track.image_asset_id,
            source = track.source
        }
        table.insert(self.UpNext, queueTrack)
        if self.OnQueueChanged then self.OnQueueChanged() end
        return #self.UpNext
    end
    
    function MusicPlayer:RemoveFromQueue(index)
        if index >= 1 and index <= #self.UpNext then
            table.remove(self.UpNext, index)
            if self.OnQueueChanged then self.OnQueueChanged() end
            return true
        end
        return false
    end
    
    function MusicPlayer:ClearQueue()
        self.UpNext = {}
        if self.OnQueueChanged then self.OnQueueChanged() end
    end
    
    function MusicPlayer:MoveInQueue(fromIndex, toIndex)
        if fromIndex < 1 or fromIndex > #self.UpNext then return false end
        if toIndex < 1 or toIndex > #self.UpNext then return false end
        if fromIndex == toIndex then return true end
        
        local track = table.remove(self.UpNext, fromIndex)
        table.insert(self.UpNext, toIndex, track)
        if self.OnQueueChanged then self.OnQueueChanged() end
        return true
    end
    
    function MusicPlayer:GetQueueLength()
        return #self.UpNext
    end
    
    function MusicPlayer:Previous()
        if self.IsLibraryPlayback and self.LibraryPlaybackList and #self.LibraryPlaybackList > 0 then
            local prevIdx = self.LibraryPlaybackIndex - 1
            if prevIdx >= 1 then
                self.LibraryPlaybackIndex = prevIdx
                local prevTrack = self.LibraryPlaybackList[prevIdx]
                if prevTrack then
                    local tempTrack = {
                        name = prevTrack.name,
                        artist = prevTrack.artist,
                        path = prevTrack.path,
                        isLocal = false,
                        image_url = prevTrack.image_url,
                        image_asset_id = prevTrack.image_asset_id
                    }
                    if self.OnLibraryTrackEnded then
                        self.OnLibraryTrackEnded(prevIdx, prevTrack)
                    end
                    self:Play(tempTrack, 0)
                    return
                end
            end
            return
        end
        
        if #self.Tracks == 0 then return end
        if #self.Tracks == 1 then return end
        
        local prevIndex = self.QueueIndex - 1
        if prevIndex < 1 then
            return
        end
        
        self:Play(self.Tracks[prevIndex], prevIndex)
    end
    
    function MusicPlayer:Seek(percent)
        if self.CurrentSound and self.CurrentSound.IsLoaded then
            self.CurrentSound.TimePosition = percent * self.CurrentSound.TimeLength
        end
    end
    
    function MusicPlayer:SetVolume(vol)
        self.Volume = math.clamp(vol, 0, 1)
        if self.CurrentSound then
            self.CurrentSound.Volume = self.Volume
        end
    end
    
    function MusicPlayer:GetProgress()
        if self.CurrentSound and self.CurrentSound.IsLoaded then
            return self.CurrentSound.TimePosition / self.CurrentSound.TimeLength
        end
        return 0
    end
    
    function MusicPlayer:GetTimeInfo()
        if self.CurrentSound and self.CurrentSound.IsLoaded then
            return {
                current = self.CurrentSound.TimePosition,
                total = self.CurrentSound.TimeLength,
                currentFormatted = FormatTime(self.CurrentSound.TimePosition),
                totalFormatted = FormatTime(self.CurrentSound.TimeLength)
            }
        end
        return { current = 0, total = 0, currentFormatted = "0:00", totalFormatted = "0:00" }
    end
    
    function MusicPlayer:GetXanInstance()
        if rawget(_G, "Xan") and rawget(_G, "Xan").CurrentTheme then 
            return rawget(_G, "Xan") 
        end
        if _G.Xan and _G.Xan.CurrentTheme then 
            return _G.Xan 
        end
        if Xan and Xan.CurrentTheme then 
            return Xan 
        end
        
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            for _, gui in pairs(coreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:find("XanBar") then
                    if gui:GetAttribute("XanInstance") then
                        return gui:GetAttribute("XanInstance")
                    end
                end
            end
        end)
        
        return nil
    end
    
    function MusicPlayer:GetXanTheme()
        local xan = self:GetXanInstance()
        if xan and xan.CurrentTheme then
            local t = xan.CurrentTheme
            return {
                Background = t.Background or Color3.fromRGB(18, 18, 22),
                Surface = t.Card or t.Surface or t.Secondary or Color3.fromRGB(25, 25, 32),
                Accent = t.Accent or Color3.fromRGB(220, 60, 85),
                Text = t.Text or Color3.fromRGB(240, 240, 245),
                TextMuted = t.TextDim or t.TextSecondary or t.TextDark or t.SubText or Color3.fromRGB(120, 120, 130),
                Border = t.CardBorder or t.Border or t.Stroke or Color3.fromRGB(45, 45, 55),
                Error = t.Error or Color3.fromRGB(255, 95, 87),
                ThemeName = t.Name or "Unknown"
            }
        end
        
        if _G.AnbuWinTheme then
            local themeName = _G.AnbuWinCurrentTheme or "DARK"
            local t = _G.AnbuWinTheme[themeName]
            if t then
                return {
                    Background = t.BACKGROUND or Color3.fromRGB(18, 18, 22),
                    Surface = t.BACKGROUND_SECONDARY or Color3.fromRGB(25, 25, 32),
                    Accent = t.ACCENT or Color3.fromRGB(220, 60, 85),
                    Text = t.FOREGROUND or Color3.fromRGB(240, 240, 245),
                    TextMuted = Color3.fromRGB(120, 120, 130),
                    Border = t.BORDER or Color3.fromRGB(45, 45, 55),
                    Error = Color3.fromRGB(255, 95, 87),
                    ThemeName = themeName
                }
            end
        end
        
        return nil
    end
    
    function MusicPlayer:GetWindowButtonStyle()
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
        
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            for _, gui in pairs(coreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:find("XanBar") then
                    local macClose = gui:FindFirstChild("MacClose", true)
                    local iconClose = gui:FindFirstChild("IconClose", true)
                    if macClose and macClose.Visible then
                        return "macOS"
                    elseif iconClose and iconClose.Visible then
                        return "Default"
                    end
                end
            end
        end)
        
        return "Default"
    end
    
    function MusicPlayer:GetCurrentThemeLive()
        local xan = self:GetXanInstance()
        if xan and xan.CurrentTheme then
            local t = xan.CurrentTheme
            return {
                Background = t.Background or Color3.fromRGB(18, 18, 22),
                Surface = t.Card or t.Surface or t.Secondary or Color3.fromRGB(25, 25, 32),
                Accent = t.Accent or Color3.fromRGB(220, 60, 85),
                Text = t.Text or Color3.fromRGB(240, 240, 245),
                TextMuted = t.TextDim or t.TextSecondary or t.TextDark or t.SubText or Color3.fromRGB(120, 120, 130),
                Border = t.CardBorder or t.Border or t.Stroke or Color3.fromRGB(45, 45, 55),
                Error = t.Error or Color3.fromRGB(255, 95, 87),
                ThemeName = t.Name or "Unknown"
            }
        end
        return self:GetXanTheme()
    end
    
    function MusicPlayer:CreateCuteVisualizer(options)
        options = options or {}
        
        if self.CuteVisualizer and self.CuteVisualizer.gui and self.CuteVisualizer.gui.Parent then
            return self.CuteVisualizer
        end
        
        local ContentProvider = game:GetService("ContentProvider")
        local girlSize = options.Size or 120
        local startPos = options.Position or UDim2.new(0.5, -girlSize/2, 1, -girlSize - 20)
        
        local frames = {
            idle = "rbxassetid://121496501518579",
            handsHalfway = "rbxassetid://131207766460819",
            handsOnHeadphones = "rbxassetid://95413649910516",
            enjoying = "rbxassetid://140440210208195",
            bob1 = "rbxassetid://98540025366564",
            bob2 = "rbxassetid://130771881213267"
        }
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "XanCuteVisualizer"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 150
        gui.IgnoreGuiInset = true
        
        local success = pcall(function()
            gui.Parent = CoreGui
        end)
        if not success then
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local container = Instance.new("Frame")
        container.Name = "CuteGirlContainer"
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(0, girlSize, 0, girlSize)
        container.Position = startPos
        container.Parent = gui
        
        local loadingLabel = Instance.new("TextLabel")
        loadingLabel.Name = "LoadingLabel"
        loadingLabel.BackgroundTransparency = 1
        loadingLabel.Size = UDim2.new(1, 0, 1, 0)
        loadingLabel.Font = Enum.Font.GothamBold
        loadingLabel.Text = "Loading"
        loadingLabel.TextColor3 = Color3.fromRGB(255, 182, 193)
        loadingLabel.TextSize = 14
        loadingLabel.Parent = container
        
        local girlImage = Instance.new("ImageLabel")
        girlImage.Name = "CuteGirl"
        girlImage.BackgroundTransparency = 1
        girlImage.Size = UDim2.new(1, 0, 1, 0)
        girlImage.Image = ""
        girlImage.ImageTransparency = 1
        girlImage.ScaleType = Enum.ScaleType.Fit
        girlImage.Parent = container
        
        local preloadImages = {}
        for name, frameId in pairs(frames) do
            local img = Instance.new("ImageLabel")
            img.Name = "Preload_" .. name
            img.BackgroundTransparency = 1
            img.Size = UDim2.new(0, 1, 0, 1)
            img.Position = UDim2.new(0, -100, 0, -100)
            img.Image = frameId
            img.Parent = gui
            table.insert(preloadImages, img)
        end
        
        local isDragging = false
        local dragStart = nil
        local startPosOffset = nil
        local isLoaded = false
        local pendingPlayState = nil
        
        container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = input.Position
                startPosOffset = container.Position
            end
        end)
        
        container.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                container.Position = UDim2.new(
                    startPosOffset.X.Scale,
                    startPosOffset.X.Offset + delta.X,
                    startPosOffset.Y.Scale,
                    startPosOffset.Y.Offset + delta.Y
                )
            end
        end)
        
        local loadingTaskId = GenerateTaskId("CuteVizLoad")
        local bobbingTaskId = GenerateTaskId("CuteVizBob")
        
        local visualizer = {
            gui = gui,
            container = container,
            girlImage = girlImage,
            loadingLabel = loadingLabel,
            frames = frames,
            state = "loading",
            bobPhase = 0,
            loadingTaskId = loadingTaskId,
            bobbingTaskId = bobbingTaskId,
            transitionThread = nil,
            isLoaded = false
        }
        
        local loadingDots = 0
        AddRenderTask(loadingTaskId, function(dt)
            if visualizer.isLoaded then
                RemoveRenderTask(loadingTaskId)
                return
            end
            loadingDots = (loadingDots + dt * 3) % 4
            local dots = string.rep(".", math.floor(loadingDots))
            loadingLabel.Text = "Loading" .. dots
        end, { frameSkip = 2 })
        
        task.spawn(function()
            local assetsToPreload = {}
            for _, frameId in pairs(frames) do
                table.insert(assetsToPreload, frameId)
            end
            
            pcall(function()
                ContentProvider:PreloadAsync(assetsToPreload)
            end)
            
            task.wait(0.3)
            
            for _, img in ipairs(preloadImages) do
                img:Destroy()
            end
            
            visualizer.isLoaded = true
            isLoaded = true
            
            RemoveRenderTask(loadingTaskId)
            loadingLabel.Visible = false
            
            girlImage.Image = frames.idle
            girlImage.ImageTransparency = 0
            visualizer.state = "idle"
            
            if pendingPlayState ~= nil then
                visualizer:SetPlaying(pendingPlayState)
                pendingPlayState = nil
            elseif self.IsPlaying then
                visualizer:SetPlaying(true)
            end
        end)
        
        local function startBobbing()
            RemoveRenderTask(bobbingTaskId)
            
            local currentBobState = 1
            local beatCooldown = 0
            local bobDownTimer = 0
            local bobDownDuration = IsMobile and 0.18 or 0.12
            local minCooldownBase = IsMobile and 0.28 or 0.2
            local frameChangeDebounce = 0
            
            local shortAvg = 0
            local longAvg = 0
            local lastLoudness = 0
            local peakLoudness = 1
            local minLoudness = 999
            
            local lastBeatTime = 0
            local beatIntervals = {}
            local maxIntervals = 6
            local estimatedBPM = 0
            local timeSinceLastBob = 0
            local totalTime = 0
            
            girlImage.Image = frames.bob1
            girlImage.ImageTransparency = 0
            
            AddRenderTask(bobbingTaskId, function(dt)
                if visualizer.state ~= "bobbing" then
                    RemoveRenderTask(bobbingTaskId)
                    return
                end
                
                beatCooldown = math.max(0, beatCooldown - dt)
                bobDownTimer = math.max(0, bobDownTimer - dt)
                frameChangeDebounce = math.max(0, frameChangeDebounce - dt)
                timeSinceLastBob = timeSinceLastBob + dt
                totalTime = totalTime + dt
                
                local currentLoudness = 0
                if self.CurrentSound and self.CurrentSound.IsPlaying then
                    currentLoudness = self.CurrentSound.PlaybackLoudness or 0
                end
                
                shortAvg = shortAvg * 0.85 + currentLoudness * 0.15
                longAvg = longAvg * 0.97 + currentLoudness * 0.03
                
                if totalTime > 0.5 then
                    peakLoudness = math.max(peakLoudness * 0.9995, currentLoudness)
                    minLoudness = math.min(minLoudness * 1.001, currentLoudness + 1)
                else
                    peakLoudness = math.max(peakLoudness, currentLoudness)
                    minLoudness = math.min(minLoudness, currentLoudness + 1)
                end
                
                local dynamicRange = math.max(peakLoudness - minLoudness, 50)
                local normalizedLoudness = (currentLoudness - minLoudness) / dynamicRange
                local loudnessRise = currentLoudness - lastLoudness
                local aboveAvg = shortAvg > longAvg * 1.05
                
                local adaptiveThreshold = dynamicRange * 0.15
                local onsetDetected = loudnessRise > adaptiveThreshold and normalizedLoudness > 0.4
                local peakDetected = currentLoudness > longAvg * 1.2 and currentLoudness > peakLoudness * 0.6
                local rhythmHit = aboveAvg and loudnessRise > 20 and normalizedLoudness > 0.35
                
                local beatDetected = false
                
                if (onsetDetected or peakDetected or rhythmHit) and beatCooldown <= 0 then
                    beatDetected = true
                    
                    local interval = totalTime - lastBeatTime
                    if interval > 0.15 and interval < 1.5 then
                        table.insert(beatIntervals, interval)
                        if #beatIntervals > maxIntervals then
                            table.remove(beatIntervals, 1)
                        end
                        
                        if #beatIntervals >= 3 then
                            local sum = 0
                            for _, v in ipairs(beatIntervals) do sum = sum + v end
                            local avgInterval = sum / #beatIntervals
                            estimatedBPM = 60 / avgInterval
                            
                            local minCooldown = math.max(minCooldownBase, avgInterval * 0.7)
                            beatCooldown = minCooldown
                        else
                            beatCooldown = minCooldownBase
                        end
                    else
                        beatCooldown = minCooldownBase
                    end
                    
                    lastBeatTime = totalTime
                    timeSinceLastBob = 0
                end
                
                if not beatDetected and timeSinceLastBob > (IsMobile and 1.0 or 0.8) and currentLoudness > 30 then
                    local fallbackInterval = estimatedBPM > 0 and (60 / estimatedBPM) or 0.5
                    if timeSinceLastBob > fallbackInterval * 1.5 then
                        beatDetected = true
                        beatCooldown = minCooldownBase + 0.05
                        timeSinceLastBob = 0
                    end
                end
                
                lastLoudness = currentLoudness
                
                if beatDetected and currentBobState == 1 and frameChangeDebounce <= 0 then
                    currentBobState = 2
                    girlImage.Image = frames.bob2
                    bobDownTimer = bobDownDuration
                    frameChangeDebounce = IsMobile and 0.08 or 0.04
                elseif bobDownTimer <= 0 and currentBobState == 2 and frameChangeDebounce <= 0 then
                    currentBobState = 1
                    girlImage.Image = frames.bob1
                    frameChangeDebounce = IsMobile and 0.08 or 0.04
                end
            end, { frameSkip = IsMobile and 2 or 1 })
        end
        
        local function stopBobbing()
            RemoveRenderTask(bobbingTaskId)
        end
        
        function visualizer:TransitionToPlaying()
            if not self.isLoaded then
                pendingPlayState = true
                return
            end
            
            if self.transitionThread then
                pcall(function() task.cancel(self.transitionThread) end)
            end
            
            stopBobbing()
            self.state = "transitioning"
            
            self.transitionThread = task.spawn(function()
                girlImage.Image = frames.handsHalfway
                task.wait(0.18)
                
                girlImage.Image = frames.handsOnHeadphones
                task.wait(0.22)
                
                girlImage.Image = frames.enjoying
                task.wait(0.28)
                
                self.state = "bobbing"
                startBobbing()
            end)
        end
        
        function visualizer:TransitionToIdle()
            if not self.isLoaded then
                pendingPlayState = false
                return
            end
            
            if self.transitionThread then
                pcall(function() task.cancel(self.transitionThread) end)
            end
            
            stopBobbing()
            self.state = "transitioning"
            
            self.transitionThread = task.spawn(function()
                girlImage.Image = frames.handsOnHeadphones
                task.wait(0.2)
                
                girlImage.Image = frames.handsHalfway
                task.wait(0.18)
                
                girlImage.Image = frames.idle
                self.state = "idle"
            end)
        end
        
        function visualizer:SetPlaying(isPlaying)
            if not self.isLoaded then
                pendingPlayState = isPlaying
                return
            end
            
            if isPlaying then
                if self.state ~= "bobbing" then
                    if self.transitionThread then
                        pcall(function() task.cancel(self.transitionThread) end)
                        self.transitionThread = nil
                    end
                    self:TransitionToPlaying()
                end
            else
                if self.state ~= "idle" and self.state ~= "loading" then
                    self:TransitionToIdle()
                end
            end
        end
        
        function visualizer:OnTrackChange()
            if not self.isLoaded then return end
            if self.state ~= "bobbing" then return end
            
            if self.transitionThread then
                pcall(function() task.cancel(self.transitionThread) end)
            end
            
            stopBobbing()
            self.state = "transitioning"
            
            self.transitionThread = task.spawn(function()
                girlImage.Image = frames.handsOnHeadphones
                task.wait(0.4)
                
                girlImage.Image = frames.enjoying
                task.wait(0.5)
                
                self.state = "bobbing"
                startBobbing()
            end)
        end
        
        function visualizer:Show()
            gui.Enabled = true
        end
        
        function visualizer:Hide()
            gui.Enabled = false
        end
        
        function visualizer:Toggle()
            gui.Enabled = not gui.Enabled
        end
        
        function visualizer:IsVisible()
            return gui.Enabled
        end
        
        function visualizer:Destroy()
            stopBobbing()
            RemoveRenderTask(loadingTaskId)
            RemoveRenderTask(bobbingTaskId)
            if self.transitionThread then
                pcall(function() task.cancel(self.transitionThread) end)
            end
            gui:Destroy()
        end
        
        self.CuteVisualizer = visualizer
        return visualizer
    end
    
    function MusicPlayer:ToggleCuteVisualizer()
        if self.CuteVisualizer then
            self.CuteVisualizer:Toggle()
            self.CuteVisualizerEnabled = self.CuteVisualizer:IsVisible()
        else
            self:CreateCuteVisualizer()
            self.CuteVisualizerEnabled = true
        end
        return self.CuteVisualizerEnabled
    end
    
    function MusicPlayer:ShowCuteVisualizer()
        if not self.CuteVisualizer then
            self:CreateCuteVisualizer()
        end
        self.CuteVisualizer:Show()
        self.CuteVisualizerEnabled = true
        
        if self.IsPlaying then
            self.CuteVisualizer:SetPlaying(true)
        end
    end
    
    function MusicPlayer:HideCuteVisualizer()
        if self.CuteVisualizer then
            self.CuteVisualizer:Hide()
            self.CuteVisualizerEnabled = false
        end
    end
    
    local TOS_FILE = GetGhostFolderName("xanbar") .. "/music_tos.json"
    
    local function CheckTOSAccepted()
        local accepted = false
        pcall(function()
            if isfile and isfile(TOS_FILE) then
                local data = readfile(TOS_FILE)
                if data and data ~= "" then
                    local parsed = HttpService:JSONDecode(data)
                    if parsed and parsed.accepted == true then
                        accepted = true
                    end
                end
            end
        end)
        return accepted
    end
    
    local function SetTOSAccepted()
        pcall(function()
            EnsureStorageFolders()
            if writefile then
                local data = HttpService:JSONEncode({
                    accepted = true,
                    accepted_at = os.date("%Y-%m-%d %H:%M:%S"),
                    version = MusicPlayer.Version
                })
                writefile(TOS_FILE, data)
            end
        end)
    end
    
    local function ShowTOSModal(onAccept, onDecline)
        local tosGui = Create("ScreenGui", {
            Name = "XanMusicTOS",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 9999,
            IgnoreGuiInset = true
        })
        
        pcall(function() tosGui.Parent = CoreGui end)
        if not tosGui.Parent then
            tosGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local overlay = Create("Frame", {
            Name = "Overlay",
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1,
            Parent = tosGui
        })
        
        local modalWidth = IsMobile and 300 or 380
        local modalHeight = IsMobile and 280 or 300
        
        local modal = Create("Frame", {
            Name = "Modal",
            BackgroundColor3 = Color3.fromRGB(18, 18, 22),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, modalWidth, 0, modalHeight),
            ZIndex = 10,
            Parent = tosGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
            Create("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1 })
        })
        
        Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(1, -40, 0, 28),
            Font = Enum.Font.GothamBold,
            Text = "Xan Music Player",
            TextColor3 = Color3.fromRGB(240, 240, 245),
            TextSize = IsMobile and 18 or 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = modal
        })
        
        Create("TextLabel", {
            Name = "Body",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 55),
            Size = UDim2.new(1, -40, 0, IsMobile and 130 or 140),
            Font = Enum.Font.Gotham,
            Text = "This tool plays local audio files and authorized streams from user-configured sources.\n\nBy using this software, you agree:\n• Not to use it to infringe third-party copyrights\n• That you are responsible for your own API sources\n• Xan UI provides the tool, not the content",
            TextColor3 = Color3.fromRGB(160, 160, 175),
            TextSize = IsMobile and 12 or 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 11,
            Parent = modal
        })
        
        local btnY = IsMobile and 200 or 215
        local btnHeight = IsMobile and 40 or 42
        
        local acceptBtn = Create("TextButton", {
            Name = "Accept",
            BackgroundColor3 = Color3.fromRGB(220, 60, 85),
            Position = UDim2.new(0, 20, 0, btnY),
            Size = UDim2.new(0.5, -25, 0, btnHeight),
            Font = Enum.Font.GothamBold,
            Text = "Accept",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            AutoButtonColor = false,
            ZIndex = 12,
            Parent = modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        local declineBtn = Create("TextButton", {
            Name = "Decline",
            BackgroundColor3 = Color3.fromRGB(35, 35, 42),
            Position = UDim2.new(0.5, 5, 0, btnY),
            Size = UDim2.new(0.5, -25, 0, btnHeight),
            Font = Enum.Font.GothamMedium,
            Text = "Decline",
            TextColor3 = Color3.fromRGB(160, 160, 175),
            TextSize = 14,
            AutoButtonColor = false,
            ZIndex = 12,
            Parent = modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = Color3.fromRGB(55, 55, 65), Thickness = 1 })
        })
        
        acceptBtn.MouseEnter:Connect(function()
            Tween(acceptBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(240, 80, 105) })
        end)
        acceptBtn.MouseLeave:Connect(function()
            Tween(acceptBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(220, 60, 85) })
        end)
        
        declineBtn.MouseEnter:Connect(function()
            Tween(declineBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
        end)
        declineBtn.MouseLeave:Connect(function()
            Tween(declineBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(35, 35, 42) })
        end)
        
        acceptBtn.MouseButton1Click:Connect(function()
            SetTOSAccepted()
            tosGui:Destroy()
            if onAccept then onAccept() end
        end)
        
        declineBtn.MouseButton1Click:Connect(function()
            tosGui:Destroy()
            if onDecline then onDecline() end
        end)
    end
    
    function MusicPlayer:CreateUI(options)
        options = options or {}
        
        local showTOS = true
        if options.SkipTOS == true or options.ShowTOS == false or options.NoTOS == true then
            showTOS = false
        end
        
        if showTOS and not CheckTOSAccepted() then
            ShowTOSModal(
                function()
                    self:CreateUI(options)
                end,
                function()
                    return nil
                end
            )
            return nil
        end
        
        if options.DemoMode or options.Demo then
            self:EnableDemoMode()
        end
        
        local defaultTheme = {
            Background = Color3.fromRGB(18, 18, 22),
            Surface = Color3.fromRGB(25, 25, 32),
            Accent = Color3.fromRGB(220, 60, 85),
            Text = Color3.fromRGB(240, 240, 245),
            TextMuted = Color3.fromRGB(120, 120, 130),
            Border = Color3.fromRGB(45, 45, 55),
            Error = Color3.fromRGB(255, 95, 87),
            ThemeName = "Default"
        }
        
        local function getActiveTheme()
            local xan = self:GetXanInstance()
            if xan and xan.CurrentTheme then
                local t = xan.CurrentTheme
                return {
                    Background = t.Background or defaultTheme.Background,
                    Surface = t.Card or t.BackgroundSecondary or defaultTheme.Surface,
                    Accent = t.Accent or defaultTheme.Accent,
                    Text = t.Text or defaultTheme.Text,
                    TextMuted = t.TextDim or t.TextSecondary or defaultTheme.TextMuted,
                    Border = t.CardBorder or t.Border or defaultTheme.Border,
                    Error = t.Error or defaultTheme.Error,
                    ThemeName = t.Name or "Unknown"
                }
            end
            return defaultTheme
        end
        
        local theme = options.Theme or getActiveTheme()
        local lastAccentColor = theme.Accent
        local windowButtonStyle = options.WindowButtonStyle or self:GetWindowButtonStyle()
        
        local themedElements = {}
        
        self:LoadApiSources()
        
        local width = IsMobile and 300 or 360
        local height = IsMobile and 360 or 480
        local currentView = "player"
        local refreshSettingsPage, refreshLibrariesPage, refreshTrackList
        
        local screenGui = Create("ScreenGui", {
            Name = "Xan_MusicPlayer",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 100
        })
        
        pcall(function() screenGui.Parent = CoreGui end)
        if not screenGui.Parent then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local desktopPosition = UDim2.new(1, -width - 20, 0.5, -height/2)
        local mobilePosition = UDim2.new(0.5, -width/2, 0.5, -height/2)
        local startPosition = IsMobile and mobilePosition or desktopPosition
        
        local main = Create("Frame", {
            Name = "Main",
            BackgroundColor3 = theme.Background,
            Size = UDim2.new(0, width, 0, height),
            Position = startPosition,
            Visible = not IsMobile,
            ClipsDescendants = true,
            Parent = screenGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.5 })
        })
        
        local mainBgImage = nil
        local mainBgOverlay = nil
        if theme.BackgroundImage then
            mainBgImage = Create("ImageLabel", {
                Name = "BgImage",
                BackgroundTransparency = 1,
                Image = theme.BackgroundImage,
                ImageTransparency = theme.BackgroundImageTransparency or 0.15,
                ImageColor3 = Color3.new(1, 1, 1),
                ScaleType = Enum.ScaleType.Crop,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 0,
                Parent = main
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 12) })
            })
        end
        mainBgOverlay = Create("Frame", {
            Name = "BgOverlay",
            BackgroundColor3 = theme.BackgroundOverlay or theme.Background,
            BackgroundTransparency = theme.BackgroundImage and (theme.BackgroundOverlayTransparency or 0.4) or 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1,
            Parent = main
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 12) })
        })
        
        local mini = {
            width = IsMobile and 280 or 320,
            height = IsMobile and 56 or 64,
            btnSize = IsMobile and 28 or 28,
            playBtnSize = IsMobile and 38 or 36,
            bars = {}
        }
        
        local miniDesktopPos = UDim2.new(1, -mini.width - 20, 1, -mini.height - 20)
        local miniMobilePos = UDim2.new(0.5, -mini.width/2, 1, -mini.height - 20)
        
        local miniPlayer = Create("Frame", {
            Name = "MiniPlayer",
            BackgroundColor3 = theme.Background,
            Size = UDim2.new(0, mini.width, 0, mini.height),
            Position = IsMobile and miniMobilePos or miniDesktopPos,
            Visible = false,
            ClipsDescendants = true,
            Parent = screenGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.5 })
        })
        
        mini.barsContainer = Create("Frame", {
            Name = "MiniVisBars",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -140, 0, 24),
            Position = UDim2.new(0, 12, 0.5, -12),
            ClipsDescendants = true,
            ZIndex = 0,
            Parent = miniPlayer
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 2)
            })
        })
        
        for i = 1, (IsMobile and 20 or 28) do
            mini.bars[i] = Create("Frame", {
                Name = "Bar" .. i,
                BackgroundColor3 = theme.Accent,
                BackgroundTransparency = 0.75,
                Size = UDim2.new(0, 4, 0, 3),
                LayoutOrder = i,
                Parent = mini.barsContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 1) })
            })
        end
        
        local miniThumbSize = IsMobile and 36 or 40
        mini.thumbContainer = Create("Frame", {
            Name = "Thumb",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(0, miniThumbSize, 0, miniThumbSize),
            Position = UDim2.new(0, 8, 0.5, -miniThumbSize/2 - 2),
            Parent = miniPlayer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) })
        })
        
        mini.thumbImage = Create("ImageLabel", {
            Name = "Image",
            BackgroundTransparency = 1,
            Image = "",
            Visible = false,
            Size = UDim2.new(1, 0, 1, 0),
            ScaleType = Enum.ScaleType.Crop,
            Parent = mini.thumbContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) })
        })
        
        mini.thumbIcon = Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102923134853209",
            ImageColor3 = theme.TextMuted,
            ImageTransparency = 0.5,
            Visible = true,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            Parent = mini.thumbContainer
        })
        
        local miniTextOffset = 8 + miniThumbSize + 8
        mini.trackName = Create("TextLabel", {
            Name = "TrackName",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "No track",
            TextColor3 = theme.Text,
            TextSize = IsMobile and 11 or 12,
            Size = UDim2.new(1, -(miniTextOffset + 130), 0, 16),
            Position = UDim2.new(0, miniTextOffset, 0, IsMobile and 10 or 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = miniPlayer
        })
        
        mini.artistName = Create("TextLabel", {
            Name = "ArtistName",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "Unknown Artist",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 9 or 10,
            Size = UDim2.new(1, -(miniTextOffset + 130), 0, 12),
            Position = UDim2.new(0, miniTextOffset, 0, IsMobile and 26 or 28),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = miniPlayer
        })
        
        mini.progressBg = Create("Frame", {
            Name = "ProgressBg",
            BackgroundColor3 = theme.Border,
            Size = UDim2.new(1, -24, 0, IsMobile and 6 or 5),
            Position = UDim2.new(0, 12, 1, IsMobile and -10 or -9),
            Parent = miniPlayer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        
        mini.progressFill = Create("Frame", {
            Name = "Fill",
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = mini.progressBg
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        
        mini.progressClickArea = Create("TextButton", {
            Name = "ClickArea",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            ZIndex = 5,
            Parent = mini.progressBg
        })
        
        mini.prevBtn = Create("ImageButton", {
            Name = "Prev",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102599517618670",
            ImageColor3 = theme.Text,
            Size = UDim2.new(0, mini.btnSize - 4, 0, mini.btnSize - 4),
            Position = UDim2.new(1, IsMobile and -168 or -158, 0.5, -(mini.btnSize - 4)/2 - 2),
            Parent = miniPlayer
        })
        
        mini.playBtn = Create("ImageButton", {
            Name = "Play",
            BackgroundColor3 = theme.Accent,
            Image = "rbxassetid://81811408640078",
            ImageColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(0, mini.playBtnSize, 0, mini.playBtnSize),
            Position = UDim2.new(1, IsMobile and -130 or -120, 0.5, -mini.playBtnSize/2 - 2),
            Parent = miniPlayer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        mini.nextBtn = Create("ImageButton", {
            Name = "Next",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102599517618670",
            ImageColor3 = theme.Text,
            Rotation = 180,
            Size = UDim2.new(0, mini.btnSize - 4, 0, mini.btnSize - 4),
            Position = UDim2.new(1, IsMobile and -82 or -72, 0.5, -(mini.btnSize - 4)/2 - 2),
            Parent = miniPlayer
        })
        
        mini.macExpandBtn = Create("Frame", {
            Name = "MacExpand",
            BackgroundColor3 = Color3.fromRGB(39, 201, 63),
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -24, 0, 8),
            Visible = windowButtonStyle == "macOS",
            Parent = miniPlayer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        mini.macExpandClickArea = Create("TextButton", {
            Name = "ClickArea",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 8, 1, 8),
            Position = UDim2.new(0, -4, 0, -4),
            ZIndex = 5,
            Parent = mini.macExpandBtn
        })
        
        mini.iconExpandBtn = Create("ImageButton", {
            Name = "IconExpand",
            BackgroundTransparency = 1,
            Image = "rbxassetid://114251372753378",
            ImageColor3 = theme.TextMuted,
            ImageTransparency = 0.3,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -26, 0, 6),
            AutoButtonColor = false,
            Visible = windowButtonStyle ~= "macOS",
            Parent = miniPlayer
        })
        
        local isMinimized = false
        
        local headerHeight = IsMobile and 38 or 44
        local header = Create("Frame", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, headerHeight),
            Parent = main
        })
        
        local iconSize = IsMobile and 24 or 24
        local musicIcon = Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102923134853209",
            ImageColor3 = theme.Accent,
            Size = UDim2.new(0, iconSize, 0, iconSize),
            Position = UDim2.new(0, 10, 0.5, -iconSize/2),
            Parent = header
        })
        
        local title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "Music",
            TextColor3 = theme.Text,
            TextSize = IsMobile and 14 or 16,
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(0, IsMobile and 34 or 42, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header
        })
        
        local navSizes = {
            close = IsMobile and 14 or 14,
            iconBtn = IsMobile and 22 or 20,
            settings = IsMobile and 24 or 22,
            libIcon = IsMobile and 24 or 20,
            libBtn = IsMobile and 48 or 45,
            gap = IsMobile and 8 or 10,
            pad = IsMobile and 10 or 12
        }
        
        local macCloseBtn = Create("Frame", {
            Name = "MacClose",
            BackgroundColor3 = Color3.fromRGB(255, 95, 87),
            Size = UDim2.new(0, navSizes.close, 0, navSizes.close),
            Position = UDim2.new(1, -(navSizes.close + navSizes.pad), 0.5, -navSizes.close/2),
            Visible = windowButtonStyle == "macOS",
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
            TextSize = IsMobile and 12 or 9,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = macCloseBtn
        })
        
        local macCloseClickArea = Create("TextButton", {
            Name = "ClickArea",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 8, 1, 8),
            Position = UDim2.new(0, -4, 0, -4),
            ZIndex = 5,
            Parent = macCloseBtn
        })
        
        local macMinBtn = Create("Frame", {
            Name = "MacMin",
            BackgroundColor3 = Color3.fromRGB(255, 189, 46),
            Size = UDim2.new(0, navSizes.close, 0, navSizes.close),
            Position = UDim2.new(1, -(navSizes.close * 2 + navSizes.pad + navSizes.gap), 0.5, -navSizes.close/2),
            Visible = windowButtonStyle == "macOS",
            Parent = header
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        local macMinDash = Create("TextLabel", {
            Name = "Dash",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = Color3.fromRGB(120, 90, 20),
            TextSize = IsMobile and 12 or 10,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = macMinBtn
        })
        
        local macMinClickArea = Create("TextButton", {
            Name = "ClickArea",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 8, 1, 8),
            Position = UDim2.new(0, -4, 0, -4),
            ZIndex = 5,
            Parent = macMinBtn
        })
        
        local iconCloseBtn = Create("ImageButton", {
            Name = "IconClose",
            BackgroundTransparency = 1,
            Image = "rbxassetid://7743878857",
            ImageColor3 = theme.TextMuted,
            ImageTransparency = 0.3,
            Size = UDim2.new(0, navSizes.iconBtn, 0, navSizes.iconBtn),
            Position = UDim2.new(1, -(navSizes.iconBtn + navSizes.pad), 0.5, -navSizes.iconBtn/2),
            AutoButtonColor = false,
            Visible = windowButtonStyle ~= "macOS",
            Parent = header
        })
        
        local iconMinBtn = Create("ImageButton", {
            Name = "IconMin",
            BackgroundTransparency = 1,
            Image = "rbxassetid://88679699501643",
            ImageColor3 = theme.TextMuted,
            ImageTransparency = 0.3,
            Size = UDim2.new(0, navSizes.iconBtn, 0, navSizes.iconBtn),
            Position = UDim2.new(1, -(navSizes.iconBtn * 2 + navSizes.pad + navSizes.gap), 0.5, -navSizes.iconBtn/2),
            AutoButtonColor = false,
            Visible = windowButtonStyle ~= "macOS",
            Parent = header
        })
        
        table.insert(themedElements, { element = iconCloseBtn, property = "ImageColor3", themeKey = "TextMuted", defaultTransparency = 0.3 })
        table.insert(themedElements, { element = iconMinBtn, property = "ImageColor3", themeKey = "TextMuted", defaultTransparency = 0.3 })
        
        local closeBtn = windowButtonStyle == "macOS" and macCloseClickArea or iconCloseBtn
        local minBtn = windowButtonStyle == "macOS" and macMinClickArea or iconMinBtn
        
        navSizes.queue = IsMobile and 24 or 20
        local navOff1 = navSizes.pad + navSizes.iconBtn * 2 + navSizes.gap * 2
        local navOff2 = navOff1 + navSizes.settings + navSizes.gap
        local navOff3 = navOff2 + navSizes.queue + navSizes.gap
        local navOff4 = navOff3 + navSizes.libBtn + navSizes.gap
        
        local settingsBtn = Create("ImageButton", {
            Name = "Settings",
            BackgroundTransparency = 1,
            Image = "rbxassetid://125073691585855",
            ImageColor3 = theme.TextMuted,
            Size = UDim2.new(0, navSizes.settings, 0, navSizes.settings),
            Position = UDim2.new(1, -(navOff1 + navSizes.settings), 0.5, -navSizes.settings/2),
            Parent = header
        })
        
        local queueBtn = Create("ImageButton", {
            Name = "Queue",
            BackgroundTransparency = 1,
            Image = "rbxassetid://138147964072876",
            ImageColor3 = theme.TextMuted,
            Size = UDim2.new(0, navSizes.queue, 0, navSizes.queue),
            Position = UDim2.new(1, -(navOff2 + navSizes.queue), 0.5, -navSizes.queue/2),
            Parent = header
        })
        
        local queueBadge = Create("Frame", {
            Name = "Badge",
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new(0, IsMobile and 12 or 14, 0, IsMobile and 12 or 14),
            Position = UDim2.new(1, IsMobile and -3 or -4, 0, IsMobile and -3 or -4),
            Visible = false,
            ZIndex = 10,
            Parent = queueBtn
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        local queueBadgeText = Create("TextLabel", {
            Name = "Count",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "0",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = IsMobile and 8 or 9,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 11,
            Parent = queueBadge
        })
        
        local librariesBtn = Create("TextButton", {
            Name = "Libraries",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = "Library",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 11 or 12,
            Size = UDim2.new(0, navSizes.libBtn, 0, IsMobile and 20 or 22),
            Position = UDim2.new(1, -(navOff3 + navSizes.libBtn), 0.5, -(IsMobile and 10 or 11)),
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = header
        })
        
        local librariesIcon = Create("ImageLabel", {
            Name = "LibrariesIcon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://89307972430003",
            ImageColor3 = theme.TextMuted,
            Size = UDim2.new(0, navSizes.libIcon, 0, navSizes.libIcon),
            Position = UDim2.new(1, -(navOff4 + navSizes.libIcon), 0.5, -navSizes.libIcon/2),
            Parent = header
        })
        
        local playerView = Create("Frame", {
            Name = "PlayerView",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -headerHeight),
            Position = UDim2.new(0, 0, 0, headerHeight),
            Parent = main
        })
        
        local settingsView = Create("Frame", {
            Name = "SettingsView",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -headerHeight),
            Position = UDim2.new(0, 0, 0, headerHeight),
            Visible = false,
            Parent = main
        })
        
        local librariesView = Create("Frame", {
            Name = "LibrariesView",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -headerHeight),
            Position = UDim2.new(0, 0, 0, headerHeight),
            Visible = false,
            Parent = main
        })
        
        local queueView = Create("Frame", {
            Name = "QueueView",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -headerHeight),
            Position = UDim2.new(0, 0, 0, headerHeight),
            Visible = false,
            Parent = main
        })
        
        local function updateQueueBadge()
            local count = #self.UpNext
            if queueBadge and queueBadge.Parent then
                queueBadge.Visible = count > 0
            end
            if queueBadgeText and queueBadgeText.Parent then
                queueBadgeText.Text = count > 9 and "9+" or tostring(count)
            end
        end
        
        local closeVizModeDropdownFn = nil
        
        local function switchView(viewName)
            local previousView = currentView
            currentView = viewName
            playerView.Visible = viewName == "player"
            settingsView.Visible = viewName == "settings"
            librariesView.Visible = viewName == "libraries"
            queueView.Visible = viewName == "queue"
            
            if closeVizModeDropdownFn then
                closeVizModeDropdownFn()
            end
            
            if previousView == "libraries" and viewName ~= "libraries" then
                task.spawn(function()
                    self:CleanupPreviewCache()
                end)
            end
            
            if viewName == "player" and albumArtModal and albumArtModal.Parent then
                if albumArtModalState.revertTimer then
                    task.cancel(albumArtModalState.revertTimer)
                    albumArtModalState.revertTimer = nil
                end
                if self._updateAlbumArtModal then
                    self._updateAlbumArtModal()
                end
            end
            
            local t = self:GetCurrentThemeLive() or theme
            
            if viewName == "player" then
                title.Text = "Music"
                musicIcon.Image = "rbxassetid://102923134853209"
                musicIcon.Visible = true
                librariesBtn.Text = "Library"
                librariesBtn.TextColor3 = t.TextMuted
                librariesIcon.ImageColor3 = t.TextMuted
                librariesIcon.Visible = true
            elseif viewName == "libraries" then
                title.Text = "Library"
                musicIcon.Image = "rbxassetid://89307972430003"
                musicIcon.Visible = true
                librariesBtn.Text = "Back"
                librariesBtn.TextColor3 = t.Accent
                librariesIcon.Visible = false
            elseif viewName == "queue" then
                title.Text = "Queue"
                musicIcon.Image = "rbxassetid://7733658504"
                musicIcon.Visible = true
                librariesBtn.Text = "Back"
                librariesBtn.TextColor3 = t.Accent
                librariesIcon.Visible = false
            else
                title.Text = "Settings"
                musicIcon.Visible = false
                librariesBtn.Text = "Back"
                librariesBtn.TextColor3 = t.Accent
                librariesIcon.Visible = false
            end
            
            settingsBtn.ImageColor3 = viewName == "settings" and t.Accent or t.TextMuted
            queueBtn.ImageColor3 = viewName == "queue" and t.Accent or t.TextMuted
            
            if viewName == "settings" then
                refreshSettingsPage()
            elseif viewName == "libraries" then
                refreshLibrariesPage()
            end
        end
        
        local nowPlayingHeight = IsMobile and 90 or 100
        local albumArtSize = IsMobile and 70 or 80
        local nowPlaying = Create("Frame", {
            Name = "NowPlaying",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(1, -24, 0, nowPlayingHeight),
            Position = UDim2.new(0, 12, 0, 6),
            Parent = playerView
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, IsMobile and 8 or 10) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
        })
        
        local albumArtContainer = Create("Frame", {
            Name = "AlbumArt",
            BackgroundColor3 = theme.Background,
            Size = UDim2.new(0, albumArtSize, 0, albumArtSize),
            Position = UDim2.new(0, 10, 0.5, -albumArtSize/2),
            Parent = nowPlaying
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        local albumArtImage = Create("ImageLabel", {
            Name = "Image",
            BackgroundTransparency = 1,
            Image = "",
            Size = UDim2.new(1, 0, 1, 0),
            ScaleType = Enum.ScaleType.Crop,
            Parent = albumArtContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) })
        })
        
        local albumArtIcon = Create("ImageLabel", {
            Name = "PlaceholderIcon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102923134853209",
            ImageColor3 = theme.TextMuted,
            ImageTransparency = 0.5,
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0.5, -16, 0.5, -16),
            Parent = albumArtContainer
        })
        
        local albumArtModal = nil
        local albumArtModalState = {
            baseSize = IsMobile and 180 or 220,
            minSize = 120,
            maxSize = 400,
            revertTimer = nil,
            currentArtUrl = nil
        }
        
        local function updateAlbumArtModal()
            if not albumArtModal or not albumArtModal.Parent then return end
            
            local track = self.CurrentTrack
            if not track or not track.image_url or track.image_url == "" then return end
            
            local artImage = albumArtModal:FindFirstChild("ArtImage")
            local trackLabel = albumArtModal:FindFirstChild("TrackName")
            local artistLabel = albumArtModal:FindFirstChild("Artist")
            
            if artImage then
                artImage.Image = track.image_url or ""
            end
            if trackLabel then
                trackLabel.Text = track.name or "Unknown"
            end
            if artistLabel then
                artistLabel.Text = track.artist or "Unknown Artist"
            end
        end
        
        local function showTempTrackInModal(track)
            if not albumArtModal or not albumArtModal.Parent then return end
            if not track or not track.image_url or track.image_url == "" then return end
            
            if albumArtModalState.revertTimer then
                task.cancel(albumArtModalState.revertTimer)
                albumArtModalState.revertTimer = nil
            end
            
            local artImage = albumArtModal:FindFirstChild("ArtImage")
            local trackLabel = albumArtModal:FindFirstChild("TrackName")
            local artistLabel = albumArtModal:FindFirstChild("Artist")
            
            if artImage then
                artImage.Image = track.image_url or ""
            end
            if trackLabel then
                trackLabel.Text = track.name or "Unknown"
            end
            if artistLabel then
                artistLabel.Text = track.artist or "Unknown Artist"
            end
            
            albumArtModalState.revertTimer = task.delay(4, function()
                albumArtModalState.revertTimer = nil
                updateAlbumArtModal()
            end)
        end
        
        local function showAlbumArtModal(clickPosition, tempTrack)
            local track = tempTrack or self.CurrentTrack
            if not track or not track.image_url or track.image_url == "" then
                return
            end
            
            if albumArtModal and albumArtModal.Parent then
                if tempTrack then
                    showTempTrackInModal(tempTrack)
                    albumArtModalState.currentArtUrl = tempTrack.image_url
                else
                    updateAlbumArtModal()
                    albumArtModalState.currentArtUrl = self.CurrentTrack and self.CurrentTrack.image_url or nil
                end
                return
            end
            
            albumArtModalState.currentArtUrl = track.image_url
            local artSize = albumArtModalState.baseSize
            local modalWidth = artSize + 16
            local modalHeight = artSize + 56
            
            local screenSize = screenGui.AbsoluteSize
            local posX = clickPosition and (clickPosition.X + 20) or (screenSize.X / 2)
            local posY = clickPosition and (clickPosition.Y - modalHeight / 2) or (screenSize.Y / 2)
            
            posX = math.clamp(posX, 10, screenSize.X - modalWidth - 10)
            posY = math.clamp(posY, 10, screenSize.Y - modalHeight - 10)
            
            albumArtModal = Create("Frame", {
                Name = "AlbumArtModal",
                BackgroundColor3 = theme.Background,
                Size = UDim2.new(0, modalWidth, 0, modalHeight),
                Position = UDim2.new(0, posX, 0, posY),
                ZIndex = 150,
                Parent = screenGui
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                Create("UIStroke", { Color = theme.Border, Thickness = 1 })
            })
            
            Create("ImageLabel", {
                Name = "Shadow",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 3),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, 16, 1, 16),
                Image = "rbxassetid://5554236805",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = 0.5,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(23, 23, 277, 277),
                ZIndex = -1,
                Parent = albumArtModal
            })
            
            local header = Create("Frame", {
                Name = "Header",
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 151,
                Parent = albumArtModal
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) })
            })
            
            Create("Frame", {
                Name = "HeaderCover",
                BackgroundColor3 = theme.Surface,
                Position = UDim2.new(0, 0, 1, -10),
                Size = UDim2.new(1, 0, 0, 10),
                BorderSizePixel = 0,
                ZIndex = 151,
                Parent = header
            })
            
            Create("TextLabel", {
                Name = "HeaderTitle",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = "Album Art",
                TextColor3 = theme.TextMuted,
                TextSize = 10,
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 152,
                Parent = header
            })
            
            local closeBtn = Create("ImageButton", {
                Name = "Close",
                BackgroundTransparency = 1,
                Image = "rbxassetid://115983297861228",
                ImageColor3 = theme.TextMuted,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                ZIndex = 152,
                Parent = header
            })
            
            closeBtn.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(closeBtn, 0.1, { ImageColor3 = t.Error or Color3.fromRGB(255, 80, 80) })
            end)
            closeBtn.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(closeBtn, 0.1, { ImageColor3 = t.TextMuted })
            end)
            closeBtn.MouseButton1Click:Connect(function()
                if albumArtModal then
                    albumArtModal:Destroy()
                    albumArtModal = nil
                    albumArtModalState.currentArtUrl = nil
                end
            end)
            
            local artImage = Create("ImageLabel", {
                Name = "ArtImage",
                BackgroundColor3 = theme.Surface,
                Image = track.image_url,
                Size = UDim2.new(1, -16, 1, -72),
                Position = UDim2.new(0, 8, 0, 28),
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = 151,
                Parent = albumArtModal
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local artDragOverlay = Create("TextButton", {
                Name = "ArtDragOverlay",
                BackgroundTransparency = 1,
                Text = "",
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 152,
                AutoButtonColor = false,
                Parent = artImage
            })
            
            Create("TextLabel", {
                Name = "TrackName",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = track.name or "Unknown",
                TextColor3 = theme.Text,
                TextSize = 12,
                Size = UDim2.new(1, -16, 0, 16),
                Position = UDim2.new(0, 8, 1, -40),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 151,
                Parent = albumArtModal
            })
            
            Create("TextLabel", {
                Name = "Artist",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = track.artist or "Unknown Artist",
                TextColor3 = theme.TextMuted,
                TextSize = 10,
                Size = UDim2.new(1, -16, 0, 14),
                Position = UDim2.new(0, 8, 1, -22),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 151,
                Parent = albumArtModal
            })
            
            local resizeHandle = Create("TextButton", {
                Name = "ResizeHandle",
                BackgroundColor3 = theme.TextMuted,
                BackgroundTransparency = 0.6,
                Text = "",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -22, 1, -22),
                ZIndex = 153,
                AutoButtonColor = false,
                Parent = albumArtModal
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            Create("ImageLabel", {
                Name = "ResizeIcon",
                BackgroundTransparency = 1,
                Image = "rbxassetid://95433882508761",
                ImageColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0.5, -9, 0.5, -9),
                ZIndex = 154,
                Parent = resizeHandle
            })
            
            local dragging = false
            local dragStart, startPos
            
            header.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = albumArtModal.Position
                end
            end)
            
            header.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            artDragOverlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = albumArtModal.Position
                end
            end)
            
            artDragOverlay.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            local resizing = false
            local resizeStart, startSize
            
            resizeHandle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    resizing = true
                    resizeStart = input.Position
                    startSize = albumArtModal.AbsoluteSize
                end
            end)
            
            resizeHandle.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    resizing = false
                end
            end)
            
            local inputConnection
            inputConnection = UserInputService.InputChanged:Connect(function(input)
                if not albumArtModal or not albumArtModal.Parent then
                    if inputConnection then inputConnection:Disconnect() end
                    return
                end
                
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    albumArtModal.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
                
                if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - resizeStart
                    local newWidth = math.clamp(startSize.X + delta.X, albumArtModalState.minSize + 16, albumArtModalState.maxSize + 16)
                    local newArtSize = newWidth - 16
                    local newHeight = newArtSize + 56
                    
                    albumArtModal.Size = UDim2.new(0, newWidth, 0, newHeight)
                    artImage.Size = UDim2.new(1, -16, 1, -72)
                    albumArtModalState.baseSize = newArtSize
                end
            end)
        end
        
        local function showFullAlbumArt(clickPos)
            if not self.CurrentTrack or not self.CurrentTrack.image_url or self.CurrentTrack.image_url == "" then
                return
            end
            
            if albumArtModal and albumArtModal.Parent then
                if albumArtModalState.currentArtUrl == self.CurrentTrack.image_url then
                    albumArtModal:Destroy()
                    albumArtModal = nil
                    albumArtModalState.currentArtUrl = nil
                    return
                end
            end
            
            showAlbumArtModal(clickPos, nil)
        end
        
        local function showFullArtForTrack(track, clickPos)
            if not track or not track.image_url or track.image_url == "" then
                return
            end
            
            if albumArtModal and albumArtModal.Parent then
                if albumArtModalState.currentArtUrl == track.image_url then
                    albumArtModal:Destroy()
                    albumArtModal = nil
                    albumArtModalState.currentArtUrl = nil
                    return
                end
            end
            
            showAlbumArtModal(clickPos, track)
        end
        
        self._updateAlbumArtModal = updateAlbumArtModal
        
        local albumArtClickArea = Create("TextButton", {
            Name = "ClickArea",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 5,
            Parent = albumArtContainer
        })
        albumArtClickArea.MouseButton1Click:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            showFullAlbumArt(Vector2.new(mousePos.X, mousePos.Y))
        end)
        
        local miniThumbClickArea = Create("TextButton", {
            Name = "ClickArea",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 5,
            Parent = mini.thumbContainer
        })
        miniThumbClickArea.MouseButton1Click:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            showFullAlbumArt(Vector2.new(mousePos.X, mousePos.Y))
        end)
        
        local textOffsetX = albumArtSize + 20
        
        local trackName = Create("TextLabel", {
            Name = "TrackName",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "No track",
            TextColor3 = theme.Text,
            TextSize = IsMobile and 13 or 14,
            Size = UDim2.new(1, -(textOffsetX + 12), 0, 20),
            Position = UDim2.new(0, textOffsetX, 0, IsMobile and 10 or 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = nowPlaying
        })
        
        local artistName = Create("TextLabel", {
            Name = "ArtistName",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "Unknown Artist",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 10 or 11,
            Size = UDim2.new(1, -(textOffsetX + 12), 0, 16),
            Position = UDim2.new(0, textOffsetX, 0, IsMobile and 28 or 32),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = nowPlaying
        })
        
        local progressBg = Create("Frame", {
            Name = "ProgressBg",
            BackgroundColor3 = theme.Border,
            Size = UDim2.new(1, -(textOffsetX + 12), 0, IsMobile and 5 or 6),
            Position = UDim2.new(0, textOffsetX, 0, IsMobile and 54 or 55),
            Parent = nowPlaying
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        
        local progressFill = Create("Frame", {
            Name = "Fill",
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            ClipsDescendants = false,
            Parent = progressBg
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        
        local progressHandle = Create("Frame", {
            Name = "Handle",
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, -7, 0.5, -7),
            ZIndex = 5,
            Parent = progressFill
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("UIStroke", { Color = theme.Accent, Thickness = 2 })
        })
        
        local timeY = IsMobile and 64 or 66
        local timeLeft = Create("TextLabel", {
            Name = "TimeLeft",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "0:00",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 9 or 10,
            Size = UDim2.new(0, 35, 0, 14),
            Position = UDim2.new(0, textOffsetX, 0, timeY),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = nowPlaying
        })
        
        local timeRight = Create("TextLabel", {
            Name = "TimeRight",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "0:00",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 9 or 10,
            Size = UDim2.new(0, 35, 0, 14),
            Position = UDim2.new(1, -47, 0, timeY),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = nowPlaying
        })
        
        local addToLibBtn = Create("TextButton", {
            Name = "AddToLib",
            BackgroundColor3 = theme.Accent,
            Font = Enum.Font.GothamMedium,
            Text = "+",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(1, -38, 0, 10),
            AutoButtonColor = false,
            Visible = false,
            ZIndex = 3,
            Parent = nowPlaying
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        addToLibBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(addToLibBtn, 0.1, { BackgroundColor3 = Color3.fromRGB(
                math.min(255, t.Accent.R * 255 * 1.2),
                math.min(255, t.Accent.G * 255 * 1.2),
                math.min(255, t.Accent.B * 255 * 1.2)
            )})
        end)
        addToLibBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(addToLibBtn, 0.1, { BackgroundColor3 = t.Accent })
        end)
        
        local controlsY = IsMobile and 102 or 120
        local controlsHeight = IsMobile and 40 or 48
        local controls = Create("Frame", {
            Name = "Controls",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 0, controlsHeight),
            Position = UDim2.new(0, 12, 0, controlsY),
            Parent = playerView
        })
        
        local controlLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 16),
            Parent = controls
        })
        
        local skipBtnSize = IsMobile and 24 or 28
        local playBtnSize = IsMobile and 40 or 48
        local shuffleBtnSize = IsMobile and 18 or 22
        local loopBtnSize = IsMobile and 18 or 22
        
        local loopBtn = Create("ImageButton", {
            Name = "Loop",
            BackgroundTransparency = 1,
            Image = "rbxassetid://95626307284732",
            ImageColor3 = self.LoopEnabled and theme.Accent or theme.Text,
            Size = UDim2.new(0, loopBtnSize, 0, loopBtnSize),
            LayoutOrder = 0,
            Parent = controls
        })
        
        local prevBtn = Create("ImageButton", {
            Name = "Prev",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102599517618670",
            ImageColor3 = theme.Text,
            Size = UDim2.new(0, skipBtnSize, 0, skipBtnSize),
            LayoutOrder = 1,
            Parent = controls
        })
        
        local playBtn = Create("ImageButton", {
            Name = "Play",
            BackgroundColor3 = theme.Accent,
            Image = "rbxassetid://81811408640078",
            ImageColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(0, playBtnSize, 0, playBtnSize),
            LayoutOrder = 2,
            Parent = controls
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        local nextBtnWrapper = Create("Frame", {
            Name = "NextWrapper",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, skipBtnSize, 0, skipBtnSize),
            LayoutOrder = 3,
            Parent = controls
        })
        local nextBtn = Create("ImageButton", {
            Name = "Next",
            BackgroundTransparency = 1,
            Image = "rbxassetid://102599517618670",
            ImageColor3 = theme.Text,
            Size = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = 180,
            Parent = nextBtnWrapper
        })
        
        local shuffleBtn = Create("ImageButton", {
            Name = "Shuffle",
            BackgroundTransparency = 1,
            Image = "rbxassetid://104121101712692",
            ImageColor3 = self.IsShuffled and theme.Accent or theme.Text,
            Size = UDim2.new(0, shuffleBtnSize, 0, shuffleBtnSize),
            LayoutOrder = 4,
            Parent = controls
        })
        
        local vizY = IsMobile and 146 or 174
        local vizHeight = IsMobile and 38 or 50
        local visualizerFrame = Create("Frame", {
            Name = "Visualizer",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(1, -24, 0, vizHeight),
            Position = UDim2.new(0, 12, 0, vizY),
            Parent = playerView
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, IsMobile and 6 or 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
        })
        
        local visualizerLabel = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "Audio Visualizer",
            TextColor3 = theme.Text,
            TextSize = IsMobile and 9 or 10,
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, IsMobile and 2 or 4),
            Parent = visualizerFrame
        })
        
        local barsHeight = IsMobile and 20 or 26
        local barsContainer = Create("Frame", {
            Name = "Bars",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, barsHeight),
            Position = UDim2.new(0, 8, 0, IsMobile and 16 or 20),
            Parent = visualizerFrame
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, IsMobile and 2 or 3)
            })
        })
        
        local barCount = IsMobile and 16 or 20
        local barWidth = IsMobile and 8 or 10
        local visualizerBars = {}
        local vizBarState = {}
        
        local vizBands = {
            { name = "subBass", startPct = 0, endPct = 0.1, baseSpeed = 3.5, reactivity = 1.6, decay = 0.88, minHeight = 0.4 },
            { name = "bass", startPct = 0.1, endPct = 0.25, baseSpeed = 4.2, reactivity = 1.4, decay = 0.85, minHeight = 0.35 },
            { name = "lowMid", startPct = 0.25, endPct = 0.4, baseSpeed = 5.5, reactivity = 1.1, decay = 0.82, minHeight = 0.25 },
            { name = "mid", startPct = 0.4, endPct = 0.6, baseSpeed = 7.0, reactivity = 1.0, decay = 0.78, minHeight = 0.2 },
            { name = "highMid", startPct = 0.6, endPct = 0.8, baseSpeed = 9.0, reactivity = 0.9, decay = 0.75, minHeight = 0.15 },
            { name = "treble", startPct = 0.8, endPct = 1.0, baseSpeed = 12.0, reactivity = 0.7, decay = 0.72, minHeight = 0.1 }
        }
        
        local function getBarBand(barIndex, totalBars)
            local pct = (barIndex - 1) / (totalBars - 1)
            for _, band in ipairs(vizBands) do
                if pct >= band.startPct and pct < band.endPct then
                    return band
                end
            end
            return vizBands[#vizBands]
        end
        
        for i = 1, barCount do
            local bar = Create("Frame", {
                Name = "Bar" .. i,
                BackgroundColor3 = theme.Accent,
                Size = UDim2.new(0, barWidth, 0, 4),
                LayoutOrder = i,
                Parent = barsContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 2) })
            })
            visualizerBars[i] = bar
            
            local band = getBarBand(i, barCount)
            vizBarState[i] = {
                current = 0,
                target = 0,
                velocity = 0,
                phase = math.random() * math.pi * 2,
                noiseOffset = math.random() * 1000,
                band = band,
                lastPeak = 0,
                peakHold = 0
            }
        end
        
        local qSec = {
            y = IsMobile and 190 or 230,
            headerH = IsMobile and 28 or 32,
            itemH = IsMobile and 36 or 40,
            expanded = false
        }
        
        qSec.frame = Create("Frame", {
            Name = "QueueSection",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(1, -24, 0, qSec.headerH),
            Position = UDim2.new(0, 12, 0, qSec.y),
            ClipsDescendants = true,
            Visible = false,
            Parent = playerView
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
        })
        
        qSec.header = Create("TextButton", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, qSec.headerH),
            AutoButtonColor = false,
            Text = "",
            Parent = qSec.frame
        })
        
        qSec.title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "Up Next",
            TextColor3 = theme.Text,
            TextSize = IsMobile and 11 or 12,
            Size = UDim2.new(0.5, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = qSec.header
        })
        
        qSec.count = Create("TextLabel", {
            Name = "Count",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "0 songs",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 10 or 11,
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = qSec.header
        })
        
        qSec.expandIcon = Create("TextLabel", {
            Name = "ExpandIcon",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "▼",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 10 or 11,
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            Parent = qSec.header
        })
        
        qSec.clearBtn = Create("TextButton", {
            Name = "Clear",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "Clear",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 9 or 10,
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(1, -75, 0, 0),
            AutoButtonColor = false,
            Visible = false,
            Parent = qSec.header
        })
        
        qSec.list = Create("Frame", {
            Name = "List",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 0, 0),
            Position = UDim2.new(0, 4, 0, qSec.headerH),
            Parent = qSec.frame
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
        })
        
        local function refreshQueueDisplay()
            for _, child in pairs(qSec.list:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            local queueLen = #self.UpNext
            qSec.frame.Visible = queueLen > 0
            qSec.count.Text = queueLen .. (queueLen == 1 and " song" or " songs")
            qSec.clearBtn.Visible = qSec.expanded and queueLen > 0
            
            if queueLen == 0 then
                qSec.expanded = false
                qSec.expandIcon.Text = "▼"
            end
            
            local listHeight = 0
            if qSec.expanded then
                for i, track in ipairs(self.UpNext) do
                    local qItem = Create("Frame", {
                        Name = "QueueItem" .. i,
                        BackgroundColor3 = theme.Background,
                        Size = UDim2.new(1, 0, 0, qSec.itemH),
                        LayoutOrder = i,
                        Parent = qSec.list
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
                    })
                    
                    Create("TextLabel", {
                        Name = "Number",
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = tostring(i),
                        TextColor3 = theme.TextMuted,
                        TextSize = IsMobile and 9 or 10,
                        Size = UDim2.new(0, 20, 1, 0),
                        Position = UDim2.new(0, 6, 0, 0),
                        Parent = qItem
                    })
                    
                    Create("TextLabel", {
                        Name = "Name",
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamMedium,
                        Text = track.name,
                        TextColor3 = theme.Text,
                        TextSize = IsMobile and 10 or 11,
                        Size = UDim2.new(1, -90, 0, 16),
                        Position = UDim2.new(0, 28, 0, IsMobile and 4 or 5),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = qItem
                    })
                    
                    Create("TextLabel", {
                        Name = "Artist",
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = track.artist or "Unknown",
                        TextColor3 = theme.TextMuted,
                        TextSize = IsMobile and 9 or 10,
                        Size = UDim2.new(1, -90, 0, 14),
                        Position = UDim2.new(0, 28, 0, IsMobile and 18 or 20),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = qItem
                    })
                    
                    local removeBtn = Create("TextButton", {
                        Name = "Remove",
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = "×",
                        TextColor3 = theme.TextMuted,
                        TextSize = IsMobile and 14 or 16,
                        Size = UDim2.new(0, 28, 0, 28),
                        Position = UDim2.new(1, -32, 0.5, -14),
                        AutoButtonColor = false,
                        Parent = qItem
                    })
                    
                    removeBtn.MouseEnter:Connect(function()
                        Tween(removeBtn, 0.1, { TextColor3 = Color3.fromRGB(220, 80, 80) })
                    end)
                    removeBtn.MouseLeave:Connect(function()
                        local t = self:GetCurrentThemeLive() or theme
                        Tween(removeBtn, 0.1, { TextColor3 = t.TextMuted })
                    end)
                    removeBtn.MouseButton1Click:Connect(function()
                        self:RemoveFromQueue(i)
                    end)
                    
                    qItem.MouseEnter:Connect(function()
                        local t = self:GetCurrentThemeLive() or theme
                        Tween(qItem, 0.1, { BackgroundColor3 = t.Surface })
                    end)
                    qItem.MouseLeave:Connect(function()
                        local t = self:GetCurrentThemeLive() or theme
                        Tween(qItem, 0.1, { BackgroundColor3 = t.Background })
                    end)
                    
                    listHeight = listHeight + qSec.itemH + 2
                end
            end
            
            qSec.list.Size = UDim2.new(1, -8, 0, listHeight)
            local totalHeight = qSec.headerH + (qSec.expanded and listHeight + 4 or 0)
            Tween(qSec.frame, 0.2, { Size = UDim2.new(1, -24, 0, totalHeight) })
            
            local trackListOffset = queueLen > 0 and (totalHeight + 6) or 0
            Tween(trackList, 0.2, { Position = UDim2.new(0, 12, 0, qSec.frameY + trackListOffset) })
        end
        
        qSec.header.MouseButton1Click:Connect(function()
            if #self.UpNext == 0 then return end
            qSec.expanded = not qSec.expanded
            qSec.expandIcon.Text = qSec.expanded and "▲" or "▼"
            refreshQueueDisplay()
        end)
        
        qSec.clearBtn.MouseEnter:Connect(function()
            Tween(qSec.clearBtn, 0.1, { TextColor3 = Color3.fromRGB(220, 80, 80) })
        end)
        qSec.clearBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(qSec.clearBtn, 0.1, { TextColor3 = t.TextMuted })
        end)
        qSec.clearBtn.MouseButton1Click:Connect(function()
            self:ClearQueue()
        end)
        
        self.OnQueueChanged = function()
            refreshQueueDisplay()
            updateQueueBadge()
            if currentView == "queue" then
                refreshQueueView()
            end
        end
        
        local trackListY = IsMobile and 190 or 230
        local trackListHeight = IsMobile and math.min(height - 198, 140) or (height - 290)
        local trackList = Create("ScrollingFrame", {
            Name = "TrackList",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(1, -24, 0, trackListHeight),
            Position = UDim2.new(0, 12, 0, trackListY),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = playerView
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 }),
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 2)
            }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) })
        })
        
        local settingsScroll = Create("ScrollingFrame", {
            Name = "SettingsScroll",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, -12),
            Position = UDim2.new(0, 12, 0, 6),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = settingsView
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8)
            }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) })
        })
        
        local queueHeader = Create("Frame", {
            Name = "QueueHeader",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.new(0, 12, 0, 6),
            Parent = queueView
        })
        
        qSec.titleLabel = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "Up Next",
            TextColor3 = theme.Text,
            TextSize = IsMobile and 14 or 16,
            Size = UDim2.new(0.5, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = queueHeader
        })
        
        qSec.countLabel = Create("TextLabel", {
            Name = "Count",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "0 songs queued",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 11 or 12,
            Size = UDim2.new(0.5, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = queueHeader
        })
        
        local queueClearAllBtn = Create("TextButton", {
            Name = "ClearAll",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "Clear",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 10 or 11,
            Size = UDim2.new(0, IsMobile and 40 or 50, 0, IsMobile and 24 or 26),
            Position = UDim2.new(1, IsMobile and -40 or -50, 0, 6),
            AutoButtonColor = false,
            Parent = queueHeader
        })
        
        local queueScroll = Create("ScrollingFrame", {
            Name = "QueueScroll",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(1, -24, 1, -56),
            Position = UDim2.new(0, 12, 0, 50),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = queueView
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 }),
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 4)
            }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
        })
        
        local queueEmptyLabel = Create("TextLabel", {
            Name = "Empty",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "Queue is empty\n\nUse the ••• menu on songs\nto add them to queue",
            TextColor3 = theme.TextMuted,
            TextSize = IsMobile and 12 or 13,
            Size = UDim2.new(1, -24, 0, 100),
            Position = UDim2.new(0, 12, 0.5, -50),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Visible = true,
            Parent = queueView
        })
        
        local refreshQueueView
        
        local function createQueueItem(track, index)
            local itemHeight = IsMobile and 52 or 60
            local thumbSize = IsMobile and 40 or 46
            local item = Create("Frame", {
                Name = "QueueItem_" .. index,
                BackgroundColor3 = theme.Background,
                Size = UDim2.new(1, -8, 0, itemHeight),
                LayoutOrder = index,
                Parent = queueScroll
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) })
            })
            
            local dragHandle = Create("TextLabel", {
                Name = "DragHandle",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "≡",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 16 or 18,
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                Parent = item
            })
            
            local thumbContainer = Create("Frame", {
                Name = "Thumb",
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(0, thumbSize, 0, thumbSize),
                Position = UDim2.new(0, 26, 0.5, -thumbSize/2),
                Parent = item
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local thumbImage = Create("ImageLabel", {
                Name = "Image",
                BackgroundTransparency = 1,
                Image = track.image_url or "",
                Visible = track.image_url and track.image_url ~= "",
                Size = UDim2.new(1, 0, 1, 0),
                ScaleType = Enum.ScaleType.Crop,
                Parent = thumbContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local thumbIcon = Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Image = "rbxassetid://102923134853209",
                ImageColor3 = theme.TextMuted,
                ImageTransparency = 0.6,
                Visible = not (track.image_url and track.image_url ~= ""),
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0.5, -9, 0.5, -9),
                Parent = thumbContainer
            })
            
            local numberLabel = Create("TextLabel", {
                Name = "Number",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = tostring(index),
                TextColor3 = theme.Accent,
                TextSize = IsMobile and 9 or 10,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Visible = not (track.image_url and track.image_url ~= ""),
                Parent = thumbContainer
            })
            
            local textOffset = 26 + thumbSize + 8
            local trackNameLabel = Create("TextLabel", {
                Name = "Name",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = track.name or "Unknown",
                TextColor3 = theme.Text,
                TextSize = IsMobile and 12 or 13,
                Size = UDim2.new(1, -(textOffset + 100), 0, 18),
                Position = UDim2.new(0, textOffset, 0, IsMobile and 8 or 10),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            local artistLabel = Create("TextLabel", {
                Name = "Artist",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = track.artist or "Unknown Artist",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 10 or 11,
                Size = UDim2.new(1, -(textOffset + 100), 0, 16),
                Position = UDim2.new(0, textOffset, 0, IsMobile and 26 or 30),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            local moveUpBtn = Create("TextButton", {
                Name = "MoveUp",
                BackgroundColor3 = theme.Surface,
                BackgroundTransparency = 0.5,
                Font = Enum.Font.GothamBold,
                Text = "▲",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 12 or 14,
                Size = UDim2.new(0, IsMobile and 24 or 26, 0, IsMobile and 24 or 26),
                Position = UDim2.new(1, -92, 0.5, IsMobile and -12 or -13),
                AutoButtonColor = false,
                Visible = index > 1,
                Parent = item
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local moveDownBtn = Create("TextButton", {
                Name = "MoveDown",
                BackgroundColor3 = theme.Surface,
                BackgroundTransparency = 0.5,
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 12 or 14,
                Size = UDim2.new(0, IsMobile and 24 or 26, 0, IsMobile and 24 or 26),
                Position = UDim2.new(1, -62, 0.5, IsMobile and -12 or -13),
                AutoButtonColor = false,
                Visible = index < #self.UpNext,
                Parent = item
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local removeBtn = Create("TextButton", {
                Name = "Remove",
                BackgroundColor3 = Color3.fromRGB(80, 40, 40),
                BackgroundTransparency = 0.6,
                Font = Enum.Font.GothamBold,
                Text = "×",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 14 or 16,
                Size = UDim2.new(0, IsMobile and 24 or 26, 0, IsMobile and 24 or 26),
                Position = UDim2.new(1, -32, 0.5, IsMobile and -12 or -13),
                AutoButtonColor = false,
                Parent = item
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local function findTrackIndex()
                for i, t in ipairs(self.UpNext) do
                    if t == track or (t.name == track.name and t.path == track.path) then
                        return i
                    end
                end
                return nil
            end
            
            moveUpBtn.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(moveUpBtn, 0.1, { TextColor3 = t.Accent, BackgroundTransparency = 0.3 })
            end)
            moveUpBtn.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(moveUpBtn, 0.1, { TextColor3 = t.TextMuted, BackgroundTransparency = 0.5 })
            end)
            moveUpBtn.Activated:Connect(function()
                local currentIdx = findTrackIndex()
                if currentIdx and currentIdx > 1 then
                    local t = table.remove(self.UpNext, currentIdx)
                    if t then
                        table.insert(self.UpNext, currentIdx - 1, t)
                        refreshQueueView()
                        updateQueueBadge()
                    end
                end
            end)
            
            moveDownBtn.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(moveDownBtn, 0.1, { TextColor3 = t.Accent, BackgroundTransparency = 0.3 })
            end)
            moveDownBtn.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(moveDownBtn, 0.1, { TextColor3 = t.TextMuted, BackgroundTransparency = 0.5 })
            end)
            moveDownBtn.Activated:Connect(function()
                local currentIdx = findTrackIndex()
                if currentIdx and currentIdx < #self.UpNext then
                    local t = table.remove(self.UpNext, currentIdx)
                    if t then
                        table.insert(self.UpNext, currentIdx + 1, t)
                        refreshQueueView()
                        updateQueueBadge()
                    end
                end
            end)
            
            removeBtn.MouseEnter:Connect(function()
                Tween(removeBtn, 0.1, { TextColor3 = Color3.fromRGB(255, 100, 100), BackgroundTransparency = 0.3 })
            end)
            removeBtn.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(removeBtn, 0.1, { TextColor3 = t.TextMuted, BackgroundTransparency = 0.6 })
            end)
            removeBtn.Activated:Connect(function()
                local currentIdx = findTrackIndex()
                if currentIdx then
                    table.remove(self.UpNext, currentIdx)
                    refreshQueueView()
                    updateQueueBadge()
                end
            end)
            
            item.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(item, 0.1, { BackgroundColor3 = t.Surface })
            end)
            item.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(item, 0.1, { BackgroundColor3 = t.Background })
            end)
            
            return item
        end
        
        refreshQueueView = function()
            for _, child in pairs(queueScroll:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            local count = #self.UpNext
            qSec.countLabel.Text = count .. (count == 1 and " song" or " songs") .. " queued"
            queueEmptyLabel.Visible = count == 0
            queueClearAllBtn.Visible = count > 0
            updateQueueBadge()
            
            for i, track in ipairs(self.UpNext) do
                createQueueItem(track, i)
            end
        end
        
        queueClearAllBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(queueClearAllBtn, 0.1, { TextColor3 = t.Accent })
        end)
        queueClearAllBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(queueClearAllBtn, 0.1, { TextColor3 = t.TextMuted })
        end)
        queueClearAllBtn.Activated:Connect(function()
            self.UpNext = {}
            refreshQueueView()
            updateQueueBadge()
            refreshQueueDisplay()
        end)
        
        local libState = {
            filter = nil,
            search = "",
            artistFilter = "",
            genreFilter = "",
            keywordFilter = "",
            apiFilter = self.DemoMode and "featured" or "all",
            refreshVersion = 0,
            pageSize = 20,
            currentPage = 0,
            filteredTracks = {},
            isLoading = false,
            dataLoaded = false,
            refreshInProgress = false,
            filterPopupVisible = false
        }
        
        local libSearchContainer = Create("Frame", {
            Name = "SearchContainer",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 0, 44),
            Position = UDim2.new(0, 12, 0, 4),
            Parent = librariesView
        })
        
        local libSearchBar = Create("Frame", {
            Name = "SearchBar",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(1, -88, 0, 36),
            Parent = libSearchContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
        })
        
        Create("ImageLabel", {
            Name = "SearchIcon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://7734040642",
            ImageColor3 = theme.TextMuted,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0.5, -8),
            Parent = libSearchBar
        })
        
        local libSearchInput = Create("TextBox", {
            Name = "SearchInput",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "",
            PlaceholderText = "Search songs, albums, artists...",
            PlaceholderColor3 = theme.TextMuted,
            TextColor3 = theme.Text,
            TextSize = 12,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = libSearchBar
        })
        
        local libSearchClearBtn = Create("TextButton", {
            Name = "ClearBtn",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = theme.TextMuted,
            TextSize = 16,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -28, 0.5, -12),
            Visible = false,
            Parent = libSearchBar
        })
        
        libSearchClearBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(libSearchClearBtn, 0.1, { TextColor3 = t.Accent })
        end)
        
        libSearchClearBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(libSearchClearBtn, 0.1, { TextColor3 = t.TextMuted })
        end)
        
        libSearchClearBtn.MouseButton1Click:Connect(function()
            libSearchInput.Text = ""
            libState.search = ""
            libSearchClearBtn.Visible = false
            refreshLibrariesPage()
        end)
        
        local libFilterBtn = Create("ImageButton", {
            Name = "FilterBtn",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(0, 36, 0, 36),
            Position = UDim2.new(1, -78, 0, 0),
            AutoButtonColor = false,
            Image = "rbxassetid://97176217584366",
            ImageColor3 = theme.TextMuted,
            Parent = libSearchContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
        })
        
        local libRefreshBtn = Create("Frame", {
            Name = "RefreshBtn",
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(0, 36, 0, 36),
            Position = UDim2.new(1, -36, 0, 0),
            Parent = libSearchContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
        })
        
        local libRefreshIcon = Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = "rbxassetid://125800627486024",
            ImageColor3 = theme.TextMuted,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0.5, -12, 0.5, -12),
            Parent = libRefreshBtn
        })
        
        local libRefreshHitbox = Create("TextButton", {
            Name = "Hitbox",
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            Parent = libRefreshBtn
        })
        
        local refreshSpinTaskId = GenerateTaskId("RefreshSpin")
        local refreshSpinActive = false
        local refreshSpinStartTime = 0
        
        local function startRefreshSpin()
            if refreshSpinActive then return end
            refreshSpinActive = true
            refreshSpinStartTime = tick()
            AddRenderTask(refreshSpinTaskId, function()
                if not refreshSpinActive or not libRefreshIcon or not libRefreshIcon.Parent then
                    RemoveRenderTask(refreshSpinTaskId)
                    return
                end
                libRefreshIcon.Rotation = ((tick() - refreshSpinStartTime) * 360) % 360
            end, { frameSkip = 1 })
        end
        
        local function stopRefreshSpin()
            refreshSpinActive = false
            RemoveRenderTask(refreshSpinTaskId)
            Tween(libRefreshIcon, 0.2, { Rotation = 0 })
        end
        
        libFilterBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(libFilterBtn, 0.12, { ImageColor3 = t.Accent, BackgroundColor3 = t.CardHover or t.Surface })
        end)
        libFilterBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            local hasFilters = (libState.artistFilter and libState.artistFilter ~= "") or 
                              (libState.genreFilter and libState.genreFilter ~= "") or 
                              (libState.keywordFilter and libState.keywordFilter ~= "")
            Tween(libFilterBtn, 0.12, { 
                ImageColor3 = hasFilters and t.Accent or t.TextMuted, 
                BackgroundColor3 = t.Surface 
            })
        end)
        
        libRefreshHitbox.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(libRefreshIcon, 0.12, { ImageColor3 = t.Accent })
            Tween(libRefreshBtn, 0.12, { BackgroundColor3 = t.CardHover or t.Surface })
        end)
        libRefreshHitbox.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(libRefreshIcon, 0.12, { ImageColor3 = t.TextMuted })
            Tween(libRefreshBtn, 0.12, { BackgroundColor3 = t.Surface })
        end)
        libRefreshHitbox.MouseButton1Click:Connect(function()
            if refreshSpinActive then return end
            startRefreshSpin()
            self:LoadLibrary(true)
            refreshLibrariesPage(true)
        end)
        
        local filterPopup = nil
        
        local function showFilterPopup()
            if filterPopup and filterPopup.Parent then
                filterPopup:Destroy()
                filterPopup = nil
                libState.filterPopupVisible = false
                return
            end
            
            libState.filterPopupVisible = true
            local t = self:GetCurrentThemeLive() or theme
            
            filterPopup = Create("Frame", {
                Name = "FilterPopup",
                BackgroundColor3 = t.Surface,
                Size = UDim2.new(1, -24, 0, 180),
                Position = UDim2.new(0, 12, 0, 52),
                ZIndex = 50,
                Parent = librariesView
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Create("UIStroke", { Color = t.Border, Thickness = 1, Transparency = 0.5 }),
                Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
            })
            
            Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Filter Library",
                TextColor3 = t.Text,
                TextSize = 13,
                Size = UDim2.new(1, -30, 0, 18),
                Position = UDim2.new(0, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 51,
                Parent = filterPopup
            })
            
            local closeFilterBtn = Create("TextButton", {
                Name = "Close",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "×",
                TextColor3 = t.TextMuted,
                TextSize = 18,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -12, 0, -2),
                ZIndex = 51,
                Parent = filterPopup
            })
            
            closeFilterBtn.MouseButton1Click:Connect(function()
                if filterPopup then
                    filterPopup:Destroy()
                    filterPopup = nil
                    libState.filterPopupVisible = false
                end
            end)
            
            local function createFilterRow(name, placeholder, currentValue, yPos, onChange)
                Create("TextLabel", {
                    Name = name .. "Label",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = t.TextMuted,
                    TextSize = 11,
                    Size = UDim2.new(0, 60, 0, 28),
                    Position = UDim2.new(0, 0, 0, yPos),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 51,
                    Parent = filterPopup
                })
                
                local input = Create("TextBox", {
                    Name = name .. "Input",
                    BackgroundColor3 = t.Background,
                    Font = Enum.Font.Gotham,
                    Text = currentValue or "",
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = t.TextMuted,
                    TextColor3 = t.Text,
                    TextSize = 11,
                    Size = UDim2.new(1, -70, 0, 28),
                    Position = UDim2.new(0, 65, 0, yPos),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 51,
                    Parent = filterPopup
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
                })
                
                input.FocusLost:Connect(function()
                    onChange(input.Text)
                end)
                
                return input
            end
            
            local artistInput = createFilterRow("Artist", "e.g. Drake, Kanye...", libState.artistFilter, 26, function(val)
                libState.artistFilter = val
            end)
            
            local genreInput = createFilterRow("Genre", "e.g. Rap, Pop, Rock...", libState.genreFilter, 60, function(val)
                libState.genreFilter = val
            end)
            
            local keywordInput = createFilterRow("Keywords", "e.g. remix, feat...", libState.keywordFilter, 94, function(val)
                libState.keywordFilter = val
            end)
            
            local applyBtn = Create("TextButton", {
                Name = "Apply",
                BackgroundColor3 = t.Accent,
                Font = Enum.Font.GothamBold,
                Text = "Apply Filters",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Size = UDim2.new(0.48, 0, 0, 32),
                Position = UDim2.new(0, 0, 0, 132),
                AutoButtonColor = false,
                ZIndex = 51,
                Parent = filterPopup
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local clearBtn = Create("TextButton", {
                Name = "Clear",
                BackgroundColor3 = t.Background,
                Font = Enum.Font.GothamMedium,
                Text = "Clear All",
                TextColor3 = t.TextMuted,
                TextSize = 12,
                Size = UDim2.new(0.48, 0, 0, 32),
                Position = UDim2.new(0.52, 0, 0, 132),
                AutoButtonColor = false,
                ZIndex = 51,
                Parent = filterPopup
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            applyBtn.MouseButton1Click:Connect(function()
                libState.artistFilter = artistInput.Text
                libState.genreFilter = genreInput.Text
                libState.keywordFilter = keywordInput.Text
                
                if filterPopup then
                    filterPopup:Destroy()
                    filterPopup = nil
                    libState.filterPopupVisible = false
                end
                
                local hasFilters = (libState.artistFilter ~= "") or (libState.genreFilter ~= "") or (libState.keywordFilter ~= "")
                libFilterBtn.ImageColor3 = hasFilters and t.Accent or t.TextMuted
                
                refreshLibrariesPage()
            end)
            
            clearBtn.MouseButton1Click:Connect(function()
                libState.artistFilter = ""
                libState.genreFilter = ""
                libState.keywordFilter = ""
                artistInput.Text = ""
                genreInput.Text = ""
                keywordInput.Text = ""
                
                libFilterBtn.ImageColor3 = t.TextMuted
                
                if filterPopup then
                    filterPopup:Destroy()
                    filterPopup = nil
                    libState.filterPopupVisible = false
                end
                
                refreshLibrariesPage()
            end)
        end
        
        libFilterBtn.MouseButton1Click:Connect(showFilterPopup)
        
        local librariesScroll = Create("ScrollingFrame", {
            Name = "LibrariesScroll",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, -56),
            Position = UDim2.new(0, 12, 0, 50),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = librariesView
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 4)
            }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) })
        })
        
        local function createSettingsSection(parent, titleText)
            local section = Create("Frame", {
                Name = titleText,
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = parent
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 }),
                Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
                Create("UIListLayout", { Padding = UDim.new(0, 8) })
            })
            
            Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = titleText,
                TextColor3 = theme.Text,
                TextSize = 13,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 0,
                Parent = section
            })
            
            return section
        end
        
        local function createApiSourceRow(parent, source, layoutOrder)
            local row = Create("Frame", {
                Name = "Source_" .. source.name,
                BackgroundColor3 = theme.Background,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = layoutOrder,
                Parent = parent
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local enabledBtn = Create("TextButton", {
                Name = "Toggle",
                BackgroundColor3 = source.enabled and theme.Accent or theme.Border,
                Text = "",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 8, 0.5, -7),
                AutoButtonColor = false,
                Parent = row
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })
            
            if source.enabled then
                Create("TextLabel", {
                    Name = "Check",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "✓",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 10,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = enabledBtn
                })
            end
            
            Create("TextLabel", {
                Name = "Name",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = source.name,
                TextColor3 = theme.Text,
                TextSize = 12,
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row
            })
            
            if source.isDefault then
                Create("TextLabel", {
                    Name = "Default",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = "Default",
                    TextColor3 = theme.TextMuted,
                    TextSize = 10,
                    Size = UDim2.new(0, 45, 1, 0),
                    Position = UDim2.new(1, -50, 0, 0),
                    Parent = row
                })
            else
                local removeBtn = Create("TextButton", {
                    Name = "Remove",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "×",
                    TextColor3 = Color3.fromRGB(255, 100, 100),
                    TextSize = 16,
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -35, 0, 0),
                    AutoButtonColor = false,
                    Parent = row
                })
                
                removeBtn.MouseButton1Click:Connect(function()
                    self:RemoveApiSource(source.name)
                    refreshSettingsPage()
                end)
            end
            
            enabledBtn.MouseButton1Click:Connect(function()
                self:ToggleApiSource(source.name)
                refreshSettingsPage()
            end)
            
            return row
        end
        
        local addApiNameInput, addApiUrlInput
        local settingsRefreshVersion = 0
        
        refreshSettingsPage = function()
            settingsRefreshVersion = settingsRefreshVersion + 1
            
            for _, child in pairs(settingsScroll:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then 
                    child:Destroy() 
                end
            end
            
            local apiSection = createSettingsSection(settingsScroll, "API Sources")
            apiSection.LayoutOrder = 1
            
            for i, source in ipairs(self.ApiSources) do
                createApiSourceRow(apiSection, source, i)
            end
            
            local addSection = createSettingsSection(settingsScroll, "Add New Source")
            addSection.LayoutOrder = 2
            
            local nameRow = Create("Frame", {
                Name = "NameRow",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = 1,
                Parent = addSection
            })
            
            Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "Name",
                TextColor3 = theme.TextMuted,
                TextSize = 11,
                Size = UDim2.new(0, 50, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = nameRow
            })
            
            addApiNameInput = Create("TextBox", {
                Name = "Input",
                BackgroundColor3 = theme.Background,
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = "Source name...",
                PlaceholderColor3 = theme.TextMuted,
                TextColor3 = theme.Text,
                TextSize = 11,
                Size = UDim2.new(1, -55, 1, 0),
                Position = UDim2.new(0, 55, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = nameRow
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
            })
            
            local urlRow = Create("Frame", {
                Name = "UrlRow",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = 2,
                Parent = addSection
            })
            
            Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "URL",
                TextColor3 = theme.TextMuted,
                TextSize = 11,
                Size = UDim2.new(0, 50, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = urlRow
            })
            
            addApiUrlInput = Create("TextBox", {
                Name = "Input",
                BackgroundColor3 = theme.Background,
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = "https://api.example.com",
                PlaceholderColor3 = theme.TextMuted,
                TextColor3 = theme.Text,
                TextSize = 11,
                Size = UDim2.new(1, -55, 1, 0),
                Position = UDim2.new(0, 55, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = urlRow
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
            })
            
            local addBtn = Create("TextButton", {
                Name = "AddBtn",
                BackgroundColor3 = theme.Accent,
                Font = Enum.Font.GothamBold,
                Text = "Add Source",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = 3,
                AutoButtonColor = false,
                Parent = addSection
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            addBtn.MouseButton1Click:Connect(function()
                local name = addApiNameInput.Text
                local url = addApiUrlInput.Text
                if self:AddApiSource(name, url) then
                    addApiNameInput.Text = ""
                    addApiUrlInput.Text = ""
                    refreshSettingsPage()
                end
            end)
            
            local actionsSection = createSettingsSection(settingsScroll, "Actions")
            actionsSection.LayoutOrder = 3
            
            local refreshBtn = Create("TextButton", {
                Name = "RefreshBtn",
                BackgroundColor3 = theme.Background,
                Font = Enum.Font.GothamMedium,
                Text = "Refresh Music from Folder",
                TextColor3 = theme.Text,
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = 1,
                AutoButtonColor = false,
                Parent = actionsSection
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            refreshBtn.MouseButton1Click:Connect(function()
                self:LoadLibrary()
                if refreshTrackList then refreshTrackList() end
                switchView("player")
            end)
            
            local refreshApiBtn = Create("TextButton", {
                Name = "RefreshApiBtn",
                BackgroundColor3 = theme.Accent,
                Font = Enum.Font.GothamMedium,
                Text = "Refresh Library from APIs",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = 2,
                AutoButtonColor = false,
                Parent = actionsSection
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            refreshApiBtn.MouseButton1Click:Connect(function()
                libState.dataLoaded = false
                self.LibraryTracks = {}
                switchView("libraries")
                refreshLibrariesPage(true)
            end)
            
            local purgeBtn = Create("TextButton", {
                Name = "PurgeCacheBtn",
                BackgroundColor3 = Color3.fromRGB(180, 60, 60),
                Font = Enum.Font.GothamMedium,
                Text = "Purge All Cache",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = 3,
                AutoButtonColor = false,
                Parent = actionsSection
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            purgeBtn.MouseButton1Click:Connect(function()
                local count = self:PurgeCache()
                purgeBtn.Text = "Purged " .. count .. " files"
                task.wait(1.5)
                purgeBtn.Text = "Purge All Cache"
            end)
            
            local cacheSection = createSettingsSection(settingsScroll, "Cache Management")
            cacheSection.LayoutOrder = 4
            
            local cacheStats = self:GetCacheStats()
            
            local cacheInfoRow = Create("Frame", {
                Name = "CacheInfo",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = 1,
                Parent = cacheSection
            })
            
            local settingsCacheLabel = Create("TextLabel", {
                Name = "CacheLabel",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Cache: " .. cacheStats.percent .. "%",
                TextColor3 = theme.Accent,
                TextSize = 14,
                Size = UDim2.new(0.5, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cacheInfoRow
            })
            
            local settingsCachedCount = Create("TextLabel", {
                Name = "CachedCount",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = cacheStats.cached .. " / " .. cacheStats.total .. " songs cached",
                TextColor3 = theme.TextMuted,
                TextSize = 11,
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0, 22),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cacheInfoRow
            })
            
            local settingsCacheProg = Create("Frame", {
                Name = "CacheProgress",
                BackgroundColor3 = theme.Border,
                Size = UDim2.new(1, 0, 0, 8),
                Position = UDim2.new(0, 0, 0, 42),
                Parent = cacheInfoRow
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local settingsCacheFill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = GetCacheBarColor(cacheStats.percent),
                Size = UDim2.new(cacheStats.percent / 100, 0, 1, 0),
                Parent = settingsCacheProg
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local cacheButtonsRow = Create("Frame", {
                Name = "CacheButtons",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = 2,
                Parent = cacheSection
            })
            
            local cacheAllSettingsBtn = Create("TextButton", {
                Name = "CacheAll",
                BackgroundColor3 = theme.Accent,
                Font = Enum.Font.GothamMedium,
                Text = "Cache All Songs",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Size = UDim2.new(0.48, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                AutoButtonColor = false,
                Parent = cacheButtonsRow
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local purgeSettingsBtn = Create("TextButton", {
                Name = "PurgeCache",
                BackgroundColor3 = Color3.fromRGB(180, 60, 60),
                Font = Enum.Font.GothamMedium,
                Text = "Purge Cache",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Size = UDim2.new(0.48, 0, 1, 0),
                Position = UDim2.new(0.52, 0, 0, 0),
                AutoButtonColor = false,
                Parent = cacheButtonsRow
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local function updateSettingsCacheDisplay()
                local newStats = self:GetCacheStats()
                settingsCacheLabel.Text = "Cache: " .. newStats.percent .. "%"
                settingsCachedCount.Text = newStats.cached .. " / " .. newStats.total .. " songs cached"
                Tween(settingsCacheFill, 0.4, { 
                    Size = UDim2.new(newStats.percent / 100, 0, 1, 0),
                    BackgroundColor3 = GetCacheBarColor(newStats.percent)
                })
            end
            
            cacheAllSettingsBtn.MouseButton1Click:Connect(function()
                cacheAllSettingsBtn.Text = "Caching..."
                cacheAllSettingsBtn.BackgroundColor3 = theme.Border
                
                self:CacheAllTracks(function(percent, completed, total)
                    updateSettingsCacheDisplay()
                    if percent >= 100 then
                        cacheAllSettingsBtn.Text = "Cache All Songs"
                        cacheAllSettingsBtn.BackgroundColor3 = theme.Accent
                    end
                end)
            end)
            
            purgeSettingsBtn.MouseButton1Click:Connect(function()
                self:PurgeCache()
                updateSettingsCacheDisplay()
                purgeSettingsBtn.Text = "Purged!"
                task.wait(1)
                purgeSettingsBtn.Text = "Purge Cache"
            end)
            
            self.OnCacheUpdate = updateSettingsCacheDisplay
            
            local visualizerSection = createSettingsSection(settingsScroll, "Extras")
            visualizerSection.LayoutOrder = 5
            
            local keepVisibleFrame = Create("Frame", {
                Name = "KeepVisibleOnHide",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsMobile and 44 or 40),
                LayoutOrder = -1,
                Parent = visualizerSection
            })
            
            Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = "Keep player visible when hiding GUIs",
                TextColor3 = theme.Text,
                TextSize = IsMobile and 12 or 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = keepVisibleFrame
            })
            
            local keepVisibleToggleBg = Create("Frame", {
                Name = "ToggleBg",
                BackgroundColor3 = self.KeepVisibleOnHide and theme.Accent or theme.Surface,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 22),
                Parent = keepVisibleFrame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Create("UIStroke", { Color = self.KeepVisibleOnHide and theme.Accent or theme.Border, Thickness = 1 })
            })
            
            local keepVisibleToggleKnob = Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = self.KeepVisibleOnHide and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = keepVisibleToggleBg
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            
            local keepVisibleToggleBtn = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = keepVisibleToggleBg
            })
            
            keepVisibleToggleBtn.MouseButton1Click:Connect(function()
                self.KeepVisibleOnHide = not self.KeepVisibleOnHide
                local t = self:GetCurrentThemeLive() or theme
                
                Tween(keepVisibleToggleBg, 0.2, { 
                    BackgroundColor3 = self.KeepVisibleOnHide and t.Accent or t.Surface 
                })
                local stroke = keepVisibleToggleBg:FindFirstChildOfClass("UIStroke")
                if stroke then
                    Tween(stroke, 0.2, { Color = self.KeepVisibleOnHide and t.Accent or t.Border })
                end
                Tween(keepVisibleToggleKnob, 0.2, { 
                    Position = self.KeepVisibleOnHide and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) 
                })
                
                if ui and ui.SetSyncWithMainGui then
                    ui.SetSyncWithMainGui(not self.KeepVisibleOnHide)
                end
            end)
            
            local vizModeFrame = Create("Frame", {
                Name = "VisualizerMode",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsMobile and 44 or 40),
                LayoutOrder = 0,
                Parent = visualizerSection
            })
            
            Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = "Visualizer Style",
                TextColor3 = theme.Text,
                TextSize = IsMobile and 13 or 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = vizModeFrame
            })
            
            local vizModeDropContainer = Create("Frame", {
                Name = "DropdownContainer",
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, IsMobile and 120 or 130, 0, IsMobile and 32 or 30),
                Parent = vizModeFrame
            })
            
            local xan = self:GetXanInstance()
            local vizModeDropdown
            
            if xan and xan.Components and xan.Components.Dropdown then
                vizModeDropdown = xan.Components.Dropdown({
                    Parent = vizModeDropContainer,
                    Name = "VizModeDropdown",
                    Options = {"Reactive", "Wave", "Pulse"},
                    Default = self.VisualizerMode or "Reactive",
                    Compact = true,
                    Floating = true,
                    FloatingParent = screenGui,
                    GetTheme = function() return self:GetCurrentThemeLive() or theme end,
                    Callback = function(value)
                        self.VisualizerMode = value
                    end
                })
                closeVizModeDropdownFn = function()
                    if vizModeDropdown then vizModeDropdown:Close() end
                end
            else
                local fallbackBtn = Create("TextButton", {
                    Name = "FallbackBtn",
                    BackgroundColor3 = theme.Surface,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = self.VisualizerMode or "Reactive",
                    TextColor3 = theme.Text,
                    TextSize = IsMobile and 11 or 10,
                    AutoButtonColor = false,
                    Parent = vizModeDropContainer
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Create("UIStroke", { Color = theme.Border, Thickness = 1 })
                })
                
                local modes = {"Reactive", "Wave", "Pulse"}
                local currentIdx = table.find(modes, self.VisualizerMode) or 1
                fallbackBtn.MouseButton1Click:Connect(function()
                    currentIdx = currentIdx % #modes + 1
                    self.VisualizerMode = modes[currentIdx]
                    fallbackBtn.Text = modes[currentIdx]
                end)
                closeVizModeDropdownFn = function() end
            end
            
            local cuteVisualizerBtnFrame = Create("Frame", {
                Name = "CuteVisualizerBtn",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsMobile and 44 or 40),
                ClipsDescendants = false,
                LayoutOrder = 1,
                Parent = visualizerSection
            })
            
            local cuteVisualizerBtn = Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = Color3.fromRGB(255, 182, 193),
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "",
                AutoButtonColor = false,
                ClipsDescendants = true,
                Parent = cuteVisualizerBtnFrame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                Create("UIStroke", {
                    Name = "Border",
                    Color = Color3.fromRGB(255, 130, 150),
                    Thickness = 2
                })
            })
            
            local cuteVisualizerText = Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "Cute Visualizer",
                TextColor3 = Color3.fromRGB(100, 50, 70),
                TextSize = IsMobile and 14 or 13,
                Parent = cuteVisualizerBtn
            })
            
            local cuteAnimeGirl = Create("ImageLabel", {
                Name = "AnimeGirl",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -18, 1, 0),
                AnchorPoint = Vector2.new(1, 1),
                Size = UDim2.new(0, IsMobile and 44 or 40, 0, IsMobile and 44 or 40),
                Image = "rbxassetid://133781880642114",
                ZIndex = 3,
                Parent = cuteVisualizerBtn
            })
            
            cuteVisualizerBtn.MouseEnter:Connect(function()
                Tween(cuteVisualizerBtn, 0.2, { BackgroundColor3 = Color3.fromRGB(255, 200, 210) })
                Tween(cuteAnimeGirl, 0.15, { ImageTransparency = 1 })
                task.delay(0.15, function()
                    cuteAnimeGirl.Image = "rbxassetid://96291759939890"
                    Tween(cuteAnimeGirl, 0.15, { ImageTransparency = 0 })
                end)
                local border = cuteVisualizerBtn:FindFirstChild("Border")
                if border then Tween(border, 0.2, { Color = Color3.fromRGB(255, 150, 170) }) end
            end)
            
            cuteVisualizerBtn.MouseLeave:Connect(function()
                Tween(cuteVisualizerBtn, 0.2, { BackgroundColor3 = Color3.fromRGB(255, 182, 193) })
                Tween(cuteAnimeGirl, 0.15, { ImageTransparency = 1 })
                task.delay(0.15, function()
                    cuteAnimeGirl.Image = "rbxassetid://133781880642114"
                    Tween(cuteAnimeGirl, 0.15, { ImageTransparency = 0 })
                end)
                local border = cuteVisualizerBtn:FindFirstChild("Border")
                if border then Tween(border, 0.2, { Color = Color3.fromRGB(255, 130, 150) }) end
            end)
            
            cuteVisualizerBtn.MouseButton1Click:Connect(function()
                Tween(cuteVisualizerBtn, 0.08, { BackgroundColor3 = Color3.fromRGB(255, 160, 180) })
                task.delay(0.1, function()
                    Tween(cuteVisualizerBtn, 0.2, { BackgroundColor3 = Color3.fromRGB(255, 182, 193) })
                end)
                
                local isNowEnabled = self:ToggleCuteVisualizer()
                if isNowEnabled then
                    cuteVisualizerText.Text = "Cute Visualizer ✓"
                else
                    cuteVisualizerText.Text = "Cute Visualizer"
                end
            end)
            
            if self.CuteVisualizerEnabled then
                cuteVisualizerText.Text = "Cute Visualizer ✓"
            end
            
            local infoSection = Create("Frame", {
                Name = "PluginInfo",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = 99,
                Parent = settingsScroll
            })
            
            Create("TextLabel", {
                Name = "Version",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "Music Player v" .. self.Version,
                TextColor3 = theme.TextMuted,
                TextSize = 11,
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0, 8),
                Parent = infoSection
            })
            
            Create("TextLabel", {
                Name = "Author",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "Made by leet for Xan UI",
                TextColor3 = theme.TextMuted,
                TextTransparency = 0.3,
                TextSize = 10,
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 0, 0, 26),
                Parent = infoSection
            })
        end
        
        local function updateCacheDisplay(statsBar, cacheLabel, cachedCount, cacheProg, cacheFill)
            local stats = self:GetCacheStats()
            if cacheLabel and cacheLabel.Parent then
                cacheLabel.Text = "Cache: " .. stats.percent .. "%"
            end
            if cachedCount and cachedCount.Parent then
                cachedCount.Text = stats.cached .. " / " .. stats.total .. " songs cached"
            end
            if cacheFill and cacheFill.Parent then
                Tween(cacheFill, 0.4, { 
                    Size = UDim2.new(stats.percent / 100, 0, 1, 0),
                    BackgroundColor3 = GetCacheBarColor(stats.percent)
                })
            end
        end
        
        local activeStateVizTaskId = GenerateTaskId("ActiveStateViz")
        local activeState = {
            previewBtn = nil,
            previewReset = nil,
            contextMenu = nil,
            playingItem = nil,
            visualizerActive = false
        }
        
        local function createLibraryTrackItem(track, index, parent)
            local isCached = self:IsCached(track)
            local inLibrary = false
            for _, t in ipairs(self.Tracks) do
                if t.name == track.name and t.path == track.path then
                    inLibrary = true
                    break
                end
            end
            
            local itemHeight = IsMobile and 56 or 70
            local thumbSize = IsMobile and 44 or 54
            local item = Create("Frame", {
                Name = "LibTrack_" .. index,
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, itemHeight),
                LayoutOrder = index + 100,
                Parent = parent
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, IsMobile and 6 or 8) }),
                Create("UIStroke", { Color = inLibrary and theme.Accent or theme.Border, Thickness = 1, Transparency = inLibrary and 0.5 or 0.7 })
            })
            
            local thumbContainer = Create("Frame", {
                Name = "Thumb",
                BackgroundColor3 = theme.Background,
                Size = UDim2.new(0, thumbSize, 0, thumbSize),
                Position = UDim2.new(0, 8, 0.5, -thumbSize/2),
                Parent = item
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local thumbImage = Create("ImageLabel", {
                Name = "Image",
                BackgroundTransparency = 1,
                Image = track.image_url or "",
                Visible = track.image_url and track.image_url ~= "",
                Size = UDim2.new(1, 0, 1, 0),
                ScaleType = Enum.ScaleType.Crop,
                Parent = thumbContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local thumbIcon = Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Image = "rbxassetid://102923134853209",
                ImageColor3 = theme.TextMuted,
                ImageTransparency = 0.6,
                Visible = not (track.image_url and track.image_url ~= ""),
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0.5, -10, 0.5, -10),
                Parent = thumbContainer
            })
            
            if track.image_url and track.image_url ~= "" then
                local thumbClickArea = Create("TextButton", {
                    Name = "ThumbClick",
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5,
                    Parent = thumbContainer
                })
                
                thumbClickArea.MouseButton1Click:Connect(function()
                    local mousePos = UserInputService:GetMouseLocation()
                    showFullArtForTrack(track, Vector2.new(mousePos.X, mousePos.Y))
                end)
                
                thumbContainer.MouseEnter:Connect(function()
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(thumbContainer, 0.15, { BackgroundColor3 = t.Surface })
                end)
                thumbContainer.MouseLeave:Connect(function()
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(thumbContainer, 0.15, { BackgroundColor3 = t.Background })
                end)
            end
            
            if inLibrary then
                Create("Frame", {
                    Name = "InLibBadge",
                    BackgroundColor3 = theme.Accent,
                    Size = UDim2.new(0, IsMobile and 14 or 16, 0, IsMobile and 14 or 16),
                    Position = UDim2.new(1, IsMobile and -15 or -17, 1, IsMobile and -15 or -17),
                    ZIndex = 3,
                    Parent = thumbContainer
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = "✓",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = IsMobile and 9 or 10,
                        Size = UDim2.new(1, 0, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        ZIndex = 4
                    })
                })
            end
            
            local textOffsetX = thumbSize + 16
            local rightPad = IsMobile and 85 or 100
            Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = track.name or "Unknown Song",
                TextColor3 = theme.Text,
                TextSize = IsMobile and 11 or 13,
                Size = UDim2.new(1, -(textOffsetX + rightPad), 0, 16),
                Position = UDim2.new(0, textOffsetX, 0, IsMobile and 6 or 8),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            Create("TextLabel", {
                Name = "Artist",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "by " .. (track.artist or "Unknown Artist"),
                TextColor3 = theme.Accent,
                TextSize = IsMobile and 10 or 11,
                Size = UDim2.new(1, -(textOffsetX + rightPad), 0, 14),
                Position = UDim2.new(0, textOffsetX, 0, IsMobile and 22 or 28),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            local albumGenre = isCached and "Cached" or (track.genre or "Unknown")
            if not IsMobile then
                albumGenre = (track.genre or "Unknown") .. " • " .. (track.album or "Unknown Album")
                if isCached then albumGenre = albumGenre .. " • Cached" end
            end
            if inLibrary then
                albumGenre = albumGenre .. " • In Library"
            end
            
            Create("TextLabel", {
                Name = "AlbumGenre",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = albumGenre,
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 9 or 10,
                Size = UDim2.new(1, -(textOffsetX + rightPad), 0, 12),
                Position = UDim2.new(0, textOffsetX, 0, IsMobile and 36 or 46),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            local menuBtnSize = IsMobile and 28 or 32
            local menuBtnX = IsMobile and -32 or -38
            
            local menuBtn = Create("TextButton", {
                Name = "Menu",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "•••",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 14 or 16,
                Size = UDim2.new(0, menuBtnSize, 0, menuBtnSize),
                Position = UDim2.new(1, menuBtnX, 0.5, -menuBtnSize/2),
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = item
            })
            
            local previewBtnSize = IsMobile and 28 or 32
            local previewBtnX = menuBtnX - previewBtnSize - 8
            
            local previewContainer = Create("Frame", {
                Name = "PreviewContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, previewBtnSize, 0, previewBtnSize),
                Position = UDim2.new(1, previewBtnX, 0.5, -previewBtnSize/2),
                ZIndex = 5,
                Parent = item
            })
            
            local playBtn = Create("ImageButton", {
                Name = "PlayBtn",
                BackgroundTransparency = 1,
                Image = "rbxassetid://81811408640078",
                ImageColor3 = theme.Accent,
                Size = UDim2.new(0, IsMobile and 20 or 24, 0, IsMobile and 20 or 24),
                Position = UDim2.new(0.5, IsMobile and -10 or -12, 0.5, IsMobile and -10 or -12),
                Visible = true,
                ZIndex = 6,
                Parent = previewContainer
            })
            
            local visualizerFrame = Create("Frame", {
                Name = "Visualizer",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, IsMobile and 16 or 20, 0, IsMobile and 16 or 20),
                Position = UDim2.new(0.5, IsMobile and -8 or -10, 0.5, IsMobile and -8 or -10),
                Visible = false,
                ZIndex = 6,
                Parent = previewContainer
            })
            
            local barWidth = IsMobile and 5 or 6
            local barGap = IsMobile and 2 or 3
            local totalWidth = barWidth * 2 + barGap
            local startX = (IsMobile and 16 or 20) / 2 - totalWidth / 2
            
            local bar1 = Create("Frame", {
                Name = "Bar1",
                BackgroundColor3 = theme.Accent,
                Size = UDim2.new(0, barWidth, 0.4, 0),
                Position = UDim2.new(0, startX, 1, 0),
                AnchorPoint = Vector2.new(0, 1),
                ZIndex = 7,
                Parent = visualizerFrame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 2) })
            })
            
            local bar2 = Create("Frame", {
                Name = "Bar2",
                BackgroundColor3 = theme.Accent,
                Size = UDim2.new(0, barWidth, 0.6, 0),
                Position = UDim2.new(0, startX + barWidth + barGap, 1, 0),
                AnchorPoint = Vector2.new(0, 1),
                ZIndex = 7,
                Parent = visualizerFrame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 2) })
            })
            
            local stopBtn = Create("TextButton", {
                Name = "StopBtn",
                BackgroundColor3 = Color3.fromRGB(220, 70, 70),
                Font = Enum.Font.GothamBold,
                Text = "Stop",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = IsMobile and 9 or 10,
                Size = UDim2.new(0, IsMobile and 32 or 38, 0, IsMobile and 18 or 20),
                Position = UDim2.new(0.5, IsMobile and -16 or -19, 0.5, IsMobile and -9 or -10),
                Visible = false,
                AutoButtonColor = false,
                ZIndex = 6,
                Parent = previewContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local isPreviewPlaying = false
            local isHovering = false
            local vizTaskId = GenerateTaskId("LibPreviewViz_" .. index)
            local vizActive = false
            local bar1Phase = 0
            local bar2Phase = math.pi / 2
            
            local function startVisualizerAnim()
                if vizActive then return end
                vizActive = true
                AddRenderTask(vizTaskId, function(dt)
                    if not visualizerFrame or not visualizerFrame.Parent or not visualizerFrame.Visible then return end
                    bar1Phase = bar1Phase + dt * 2.5
                    bar2Phase = bar2Phase + dt * 3.2
                    local h1 = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(bar1Phase))
                    local h2 = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(bar2Phase))
                    bar1.Size = UDim2.new(0, barWidth, h1, 0)
                    bar2.Size = UDim2.new(0, barWidth, h2, 0)
                end, { frameSkip = 2 })
            end
            
            local function stopVisualizerAnim()
                vizActive = false
                RemoveRenderTask(vizTaskId)
            end
            
            local function showPlayState()
                playBtn.Visible = false
                if isHovering then
                    visualizerFrame.Visible = false
                    stopBtn.Visible = true
                    stopVisualizerAnim()
                else
                    visualizerFrame.Visible = true
                    stopBtn.Visible = false
                    startVisualizerAnim()
                end
            end
            
            local function showIdleState()
                playBtn.Visible = true
                visualizerFrame.Visible = false
                stopBtn.Visible = false
                stopVisualizerAnim()
            end
            
            local function resetPreviewBtn()
                isPreviewPlaying = false
                showIdleState()
                if activeState.playingItem == item then
                    activeState.playingItem = nil
                end
            end
            
            local function handleClick()
                if isPreviewPlaying then
                    self:Stop()
                    resetPreviewBtn()
                    self.IsLibraryPlayback = false
                    activeState.previewBtn = nil
                    activeState.previewReset = nil
                else
                    if activeState.previewReset and activeState.previewBtn then
                        activeState.previewReset()
                    end
                    
                    self:Stop()
                    
                    self.LibraryPlaybackList = {}
                    for i, t in ipairs(libState.filteredTracks) do
                        table.insert(self.LibraryPlaybackList, t)
                    end
                    self.LibraryPlaybackIndex = index
                    self.IsLibraryPlayback = true
                    
                    local tempTrack = {
                        name = track.name,
                        artist = track.artist,
                        path = track.path,
                        isLocal = false,
                        image_url = track.image_url,
                        image_asset_id = track.image_asset_id
                    }
                    self:Play(tempTrack, 0)
                    
                    isPreviewPlaying = true
                    showPlayState()
                    activeState.previewBtn = previewContainer
                    activeState.previewReset = resetPreviewBtn
                    activeState.playingItem = item
                end
            end
            
            playBtn.MouseButton1Click:Connect(handleClick)
            stopBtn.MouseButton1Click:Connect(handleClick)
            
            local clickArea = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Text = "",
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 8,
                Parent = previewContainer
            })
            clickArea.MouseButton1Click:Connect(handleClick)
            
            clickArea.MouseEnter:Connect(function()
                isHovering = true
                if isPreviewPlaying then
                    showPlayState()
                else
                    Tween(playBtn, 0.15, { ImageColor3 = Color3.new(1, 1, 1) })
                end
            end)
            
            clickArea.MouseLeave:Connect(function()
                isHovering = false
                if isPreviewPlaying then
                    showPlayState()
                else
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(playBtn, 0.15, { ImageColor3 = t.Accent })
                end
            end)
            
            if self.IsLibraryPlayback and self.CurrentTrack and self.IsPlaying then
                local isThisTrack = (self.CurrentTrack.name == track.name and self.CurrentTrack.path == track.path)
                if isThisTrack then
                    isPreviewPlaying = true
                    showPlayState()
                    activeState.previewBtn = previewContainer
                    activeState.previewReset = resetPreviewBtn
                    activeState.playingItem = item
                end
            end
            
            menuBtn.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(menuBtn, 0.1, { TextColor3 = t.Accent })
            end)
            menuBtn.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(menuBtn, 0.1, { TextColor3 = t.TextMuted })
            end)
            
            menuBtn.MouseButton1Click:Connect(function()
                if activeState.contextMenu and activeState.contextMenu.Parent then
                    activeState.contextMenu:Destroy()
                    activeState.contextMenu = nil
                    return
                end
                
                local menuWidth = IsMobile and 150 or 170
                local menuItemHeight = IsMobile and 36 or 40
                local menuItems = {}
                
                if not inLibrary then
                    table.insert(menuItems, { text = "Add to Library", action = "add" })
                end
                table.insert(menuItems, { text = "Play Next", action = "playNext" })
                table.insert(menuItems, { text = "Add to Queue", action = "addQueue" })
                
                local menuHeight = #menuItems * menuItemHeight + 12
                
                local itemAbsPos = item.AbsolutePosition
                local itemAbsSize = item.AbsoluteSize
                local screenSize = workspace.CurrentCamera.ViewportSize
                
                local menuX = math.clamp(itemAbsPos.X + itemAbsSize.X - menuWidth - 8, 10, screenSize.X - menuWidth - 10)
                local menuY = math.clamp(itemAbsPos.Y + itemAbsSize.Y/2 - menuHeight/2, 10, screenSize.Y - menuHeight - 10)
                
                local currentT = self:GetCurrentThemeLive() or theme
                local contextMenu = Create("Frame", {
                    Name = "ContextMenu",
                    BackgroundColor3 = currentT.Background,
                    Size = UDim2.new(0, menuWidth, 0, menuHeight),
                    Position = UDim2.new(0, menuX, 0, menuY),
                    ZIndex = 100,
                    Parent = screenGui
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                    Create("UIStroke", { Color = currentT.Border, Thickness = 1 }),
                    Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }),
                    Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2) })
                })
                
                activeState.contextMenu = contextMenu
                
                local function doAction(action)
                    if contextMenu and contextMenu.Parent then
                        contextMenu:Destroy()
                    end
                    activeState.contextMenu = nil
                    
                    local trackCopy = {
                        name = track.name,
                        artist = track.artist,
                        album = track.album,
                        genre = track.genre,
                        path = track.path,
                        source = track.source,
                        id = track.id,
                        image_url = track.image_url,
                        image_asset_id = track.image_asset_id,
                        isLocal = track.isLocal or false
                    }
                    
                    if action == "add" then
                        local success = self:AddToMyLibrary(trackCopy, nil, function()
                            if refreshTrackList then 
                                task.spawn(refreshTrackList) 
                            end
                        end)
                        local xan = self:GetXanInstance()
                        if success then
                            if xan and xan.Toast then xan.Toast("Added", trackCopy.name) end
                            local badge = thumbContainer:FindFirstChild("InLibBadge")
                            local liveT = self:GetCurrentThemeLive() or theme
                            if not badge then
                                local newBadge = Create("Frame", {
                                    Name = "InLibBadge",
                                    BackgroundColor3 = liveT.Accent,
                                    Size = UDim2.new(0, 0, 0, 0),
                                    Position = UDim2.new(1, IsMobile and -15 or -17, 1, IsMobile and -15 or -17),
                                    ZIndex = 3,
                                    Parent = thumbContainer
                                }, {
                                    Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                                    Create("TextLabel", {
                                        BackgroundTransparency = 1,
                                        Font = Enum.Font.GothamBold,
                                        Text = "✓",
                                        TextColor3 = Color3.new(1, 1, 1),
                                        TextSize = IsMobile and 9 or 10,
                                        Size = UDim2.new(1, 0, 1, 0),
                                        TextXAlignment = Enum.TextXAlignment.Center,
                                        TextYAlignment = Enum.TextYAlignment.Center,
                                        ZIndex = 4
                                    })
                                })
                                Tween(newBadge, 0.2, { Size = UDim2.new(0, IsMobile and 14 or 16, 0, IsMobile and 14 or 16) })
                            end
                            local stroke = item:FindFirstChildOfClass("UIStroke")
                            if stroke then
                                Tween(stroke, 0.2, { Color = liveT.Accent, Transparency = 0.5 })
                            end
                            local albumLabel = item:FindFirstChild("AlbumGenre")
                            if albumLabel then
                                albumLabel.Text = albumLabel.Text .. " • In Library"
                            end
                            inLibrary = true
                        else
                            if xan and xan.Toast then xan.Toast("Exists", "Already in library") end
                        end
                    elseif action == "playNext" then
                        table.insert(self.UpNext, 1, trackCopy)
                        local count = #self.UpNext
                        if queueBadge then
                            queueBadge.Visible = true
                            queueBadge.Size = UDim2.new(0, IsMobile and 16 or 18, 0, IsMobile and 16 or 18)
                            task.delay(0.12, function()
                                if queueBadge and queueBadge.Parent then
                                    Tween(queueBadge, 0.15, { Size = UDim2.new(0, IsMobile and 12 or 14, 0, IsMobile and 12 or 14) })
                                end
                            end)
                        end
                        if queueBadgeText then
                            queueBadgeText.Text = count > 9 and "9+" or tostring(count)
                        end
                        if self.OnQueueChanged then pcall(self.OnQueueChanged) end
                        local xan = self:GetXanInstance()
                        if xan and xan.Toast then xan.Toast("Playing Next", trackCopy.name) end
                    elseif action == "addQueue" then
                        table.insert(self.UpNext, trackCopy)
                        local count = #self.UpNext
                        if queueBadge then
                            queueBadge.Visible = true
                            queueBadge.Size = UDim2.new(0, IsMobile and 16 or 18, 0, IsMobile and 16 or 18)
                            task.delay(0.12, function()
                                if queueBadge and queueBadge.Parent then
                                    Tween(queueBadge, 0.15, { Size = UDim2.new(0, IsMobile and 12 or 14, 0, IsMobile and 12 or 14) })
                                end
                            end)
                        end
                        if queueBadgeText then
                            queueBadgeText.Text = count > 9 and "9+" or tostring(count)
                        end
                        if self.OnQueueChanged then pcall(self.OnQueueChanged) end
                        local xan = self:GetXanInstance()
                        if xan and xan.Toast then xan.Toast("Added to Queue", trackCopy.name) end
                    end
                end
                
                for i, menuItem in ipairs(menuItems) do
                    local btn = Create("TextButton", {
                        Name = menuItem.action,
                        BackgroundColor3 = currentT.Surface,
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamMedium,
                        Text = menuItem.text,
                        TextColor3 = currentT.Text,
                        TextSize = IsMobile and 12 or 14,
                        Size = UDim2.new(1, -12, 0, menuItemHeight - 4),
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex = 101,
                        Parent = contextMenu
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                        Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
                    })
                    
                    btn.MouseEnter:Connect(function()
                        Tween(btn, 0.1, { BackgroundTransparency = 0 })
                    end)
                    btn.MouseLeave:Connect(function()
                        Tween(btn, 0.1, { BackgroundTransparency = 1 })
                    end)
                    
                    btn.Activated:Connect(function()
                        doAction(menuItem.action)
                    end)
                end
                
                local backdrop = Create("TextButton", {
                    Name = "Backdrop",
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 99,
                    Parent = screenGui
                })
                
                backdrop.Activated:Connect(function()
                    if contextMenu and contextMenu.Parent then contextMenu:Destroy() end
                    if backdrop and backdrop.Parent then backdrop:Destroy() end
                    activeState.contextMenu = nil
                end)
                
                contextMenu.Destroying:Connect(function()
                    if backdrop and backdrop.Parent then backdrop:Destroy() end
                end)
            end)
            
            item.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(item, 0.12, { BackgroundColor3 = Color3.fromRGB(
                    math.min(255, t.Surface.R * 255 * 1.15),
                    math.min(255, t.Surface.G * 255 * 1.15),
                    math.min(255, t.Surface.B * 255 * 1.15)
                )})
            end)
            item.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(item, 0.12, { BackgroundColor3 = t.Surface })
            end)
            
            return item
        end
        
        libSearchInput.Text = libState.search or ""
        local lastSearchText = libState.search or ""
        
        libSearchInput.FocusLost:Connect(function(enterPressed)
            local newText = libSearchInput.Text
            if newText ~= lastSearchText then
                libState.search = newText
                lastSearchText = newText
                libState.dataLoaded = false
                refreshLibrariesPage(true)
            elseif enterPressed and newText ~= "" then
                libState.dataLoaded = false
                refreshLibrariesPage(true)
            end
        end)
        
        libSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            libSearchClearBtn.Visible = libSearchInput.Text ~= ""
            if libSearchInput.Text == "" and lastSearchText ~= "" then
                libState.search = ""
                lastSearchText = ""
                libState.dataLoaded = false
                refreshLibrariesPage(true)
            end
        end)
        
        refreshLibrariesPage = function(forceRefresh)
            if libState.refreshInProgress and not forceRefresh then
                return
            end
            
            libState.refreshInProgress = true
            libState.refreshVersion = libState.refreshVersion + 1
            local thisVersion = libState.refreshVersion
            libState.currentPage = 0
            libState.filteredTracks = {}
            libState.isLoading = false
            
            if filterPopup and filterPopup.Parent then
                filterPopup:Destroy()
                filterPopup = nil
                libState.filterPopupVisible = false
            end
            
            for _, child in pairs(librariesScroll:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("ScrollingFrame") then 
                    child:Destroy() 
                end
            end
            
            task.wait()
            
            if thisVersion ~= libState.refreshVersion then
                libState.refreshInProgress = false
                stopRefreshSpin()
                return
            end
            
            libSearchInput.Text = libState.search or ""
            
            local needsFetch = forceRefresh or not libState.dataLoaded or #self.LibraryTracks == 0
            
            local loadingFrame
            local loadingSpinnerTaskId = GenerateTaskId("LibLoadSpinner")
            if needsFetch then
                loadingFrame = Create("Frame", {
                    Name = "LoadingFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 70),
                    LayoutOrder = 2,
                    Parent = librariesScroll
                })
                
                local spinnerContainer = Create("Frame", {
                    Name = "SpinnerContainer",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 40, 0, 40),
                    Position = UDim2.new(0.5, -20, 0, 10),
                    Parent = loadingFrame
                })
                
                local spinnerDots = {}
                for i = 1, 8 do
                    local angle = (i - 1) * (math.pi * 2 / 8)
                    local x = math.cos(angle) * 14
                    local y = math.sin(angle) * 14
                    local dot = Create("Frame", {
                        Name = "Dot" .. i,
                        BackgroundColor3 = theme.Accent,
                        Size = UDim2.new(0, 6, 0, 6),
                        Position = UDim2.new(0.5, x - 3, 0.5, y - 3),
                        BackgroundTransparency = 0.7,
                        Parent = spinnerContainer
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                    })
                    spinnerDots[i] = dot
                end
                
                Create("TextLabel", {
                    Name = "LoadingText",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = "Loading library...",
                    TextColor3 = theme.TextMuted,
                    TextSize = 11,
                    Size = UDim2.new(1, 0, 0, 16),
                    Position = UDim2.new(0, 0, 1, -12),
                    Parent = loadingFrame
                })
                
                local activeDot = 1
                local lastUpdate = 0
                AddRenderTask(loadingSpinnerTaskId, function()
                    if not loadingFrame or not loadingFrame.Parent then
                        RemoveRenderTask(loadingSpinnerTaskId)
                        return
                    end
                    
                    local now = tick()
                    if now - lastUpdate < 0.08 then return end
                    lastUpdate = now
                    
                    for i, dot in ipairs(spinnerDots) do
                        local dist = (i - activeDot) % 8
                        local alpha = 1 - (dist / 8)
                        dot.BackgroundTransparency = 1 - (alpha * 0.8)
                    end
                    
                    activeDot = (activeDot % 8) + 1
                end, { throttle = 0.08 })
            end
            
            task.spawn(function()
                local apiError = nil
                if needsFetch then
                    local fetchOptions = {
                        filter = libState.apiFilter or "all",
                        genre = libState.genreFilter or "",
                        search = libState.search or ""
                    }
                    local _, err = self:FetchAllLibraries(forceRefresh, fetchOptions)
                    apiError = err
                    libState.dataLoaded = true
                end
                
                if thisVersion ~= libState.refreshVersion then 
                    RemoveRenderTask(loadingSpinnerTaskId)
                    libState.refreshInProgress = false
                    stopRefreshSpin()
                    return 
                end
                
                RemoveRenderTask(loadingSpinnerTaskId)
                if loadingFrame and loadingFrame.Parent then
                    loadingFrame:Destroy()
                    loadingFrame = nil
                end
                
                stopRefreshSpin()
                
                if apiError then
                    local xan = self:GetXanInstance()
                    if xan and xan.Toast then
                        xan.Toast("API Error", apiError)
                    elseif xan and xan.Notify then
                        xan.Notify({ Title = "API Error", Content = apiError, Style = "Error" })
                    end
                end
                
                local filterWrapper = Create("Frame", {
                    Name = "FilterWrapper",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, IsMobile and 36 or 40),
                    LayoutOrder = 1,
                    Parent = librariesScroll
                })
                
                local arrowSize = IsMobile and 24 or 28
                local arrowPadding = 4
                
                local leftArrow = Create("TextButton", {
                    Name = "LeftArrow",
                    BackgroundColor3 = theme.Surface,
                    Font = Enum.Font.GothamBold,
                    Text = "‹",
                    TextColor3 = theme.TextMuted,
                    TextSize = IsMobile and 16 or 18,
                    Size = UDim2.new(0, arrowSize, 0, IsMobile and 28 or 32),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    AutoButtonColor = false,
                    ZIndex = 2,
                    Parent = filterWrapper
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.5 })
                })
                
                local rightArrow = Create("TextButton", {
                    Name = "RightArrow",
                    BackgroundColor3 = theme.Surface,
                    Font = Enum.Font.GothamBold,
                    Text = "›",
                    TextColor3 = theme.TextMuted,
                    TextSize = IsMobile and 16 or 18,
                    Size = UDim2.new(0, arrowSize, 0, IsMobile and 28 or 32),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    AutoButtonColor = false,
                    ZIndex = 2,
                    Parent = filterWrapper
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.5 })
                })
                
                local filterPillsContainer = Create("ScrollingFrame", {
                    Name = "FilterPills",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -(arrowSize * 2 + arrowPadding * 2), 1, 0),
                    Position = UDim2.new(0, arrowSize + arrowPadding, 0, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 0,
                    ScrollingDirection = Enum.ScrollingDirection.X,
                    AutomaticCanvasSize = Enum.AutomaticSize.X,
                    ClipsDescendants = true,
                    Parent = filterWrapper
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    }),
                    Create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
                })
                
                local scrollAmount = IsMobile and 100 or 150
                
                leftArrow.MouseButton1Click:Connect(function()
                    local newPos = math.max(0, filterPillsContainer.CanvasPosition.X - scrollAmount)
                    Tween(filterPillsContainer, 0.2, { CanvasPosition = Vector2.new(newPos, 0) })
                end)
                
                rightArrow.MouseButton1Click:Connect(function()
                    local maxScroll = filterPillsContainer.AbsoluteCanvasSize.X - filterPillsContainer.AbsoluteSize.X
                    local newPos = math.min(maxScroll, filterPillsContainer.CanvasPosition.X + scrollAmount)
                    Tween(filterPillsContainer, 0.2, { CanvasPosition = Vector2.new(newPos, 0) })
                end)
                
                leftArrow.MouseEnter:Connect(function()
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(leftArrow, 0.15, { BackgroundColor3 = t.CardHover or t.Surface, TextColor3 = t.Text })
                end)
                leftArrow.MouseLeave:Connect(function()
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(leftArrow, 0.15, { BackgroundColor3 = t.Surface, TextColor3 = t.TextMuted })
                end)
                rightArrow.MouseEnter:Connect(function()
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(rightArrow, 0.15, { BackgroundColor3 = t.CardHover or t.Surface, TextColor3 = t.Text })
                end)
                rightArrow.MouseLeave:Connect(function()
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(rightArrow, 0.15, { BackgroundColor3 = t.Surface, TextColor3 = t.TextMuted })
                end)
                
                local activeFilter = libState.apiFilter or "all"
                local filterPills = {}
                
                local function createFilterPill(name, filterValue, layoutOrder, isGenre)
                    local isActive = (not isGenre and activeFilter == filterValue) or (isGenre and libState.genreFilter == filterValue)
                    
                    local pill = Create("TextButton", {
                        Name = "Filter_" .. name,
                        BackgroundColor3 = isActive and theme.Accent or theme.Surface,
                        Font = Enum.Font.GothamMedium,
                        Text = name,
                        TextColor3 = isActive and Color3.new(1, 1, 1) or theme.Text,
                        TextSize = IsMobile and 11 or 12,
                        Size = UDim2.new(0, 0, 0, IsMobile and 28 or 32),
                        AutomaticSize = Enum.AutomaticSize.X,
                        AutoButtonColor = false,
                        LayoutOrder = layoutOrder,
                        Parent = filterPillsContainer
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                        Create("UIStroke", { 
                            Color = isActive and theme.Accent or theme.Border, 
                            Thickness = 1,
                            Transparency = isActive and 0 or 0.5
                        }),
                        Create("UIPadding", { 
                            PaddingLeft = UDim.new(0, IsMobile and 12 or 14), 
                            PaddingRight = UDim.new(0, IsMobile and 12 or 14) 
                        })
                    })
                    
                    pill.MouseEnter:Connect(function()
                        if not isActive then
                            local t = self:GetCurrentThemeLive() or theme
                            Tween(pill, 0.15, { BackgroundColor3 = t.CardHover or t.Surface })
                        end
                    end)
                    
                    pill.MouseLeave:Connect(function()
                        local stillActive = (not isGenre and activeFilter == filterValue) or (isGenre and libState.genreFilter == filterValue)
                        if not stillActive then
                            local t = self:GetCurrentThemeLive() or theme
                            Tween(pill, 0.15, { BackgroundColor3 = t.Surface })
                        end
                    end)
                    
                    pill.MouseButton1Click:Connect(function()
                        if isGenre then
                            if libState.genreFilter == filterValue then
                                libState.genreFilter = ""
                            else
                                libState.genreFilter = filterValue
                            end
                            libState.apiFilter = "all"
                        else
                            libState.apiFilter = filterValue
                            libState.genreFilter = ""
                        end
                        
                        local currentT = self:GetCurrentThemeLive() or theme
                        for _, p in pairs(filterPills) do
                            local pIsGenre = p.isGenre
                            local pValue = p.value
                            local pActive = (not pIsGenre and libState.apiFilter == pValue) or (pIsGenre and libState.genreFilter == pValue)
                            
                            Tween(p.pill, 0.2, { 
                                BackgroundColor3 = pActive and currentT.Accent or currentT.Surface,
                                TextColor3 = pActive and Color3.new(1, 1, 1) or currentT.Text
                            })
                            local stroke = p.pill:FindFirstChildOfClass("UIStroke")
                            if stroke then
                                Tween(stroke, 0.2, { 
                                    Color = pActive and currentT.Accent or currentT.Border,
                                    Transparency = pActive and 0 or 0.5
                                })
                            end
                        end
                        
                        libState.dataLoaded = false
                        refreshLibrariesPage(true)
                    end)
                    
                    table.insert(filterPills, { pill = pill, value = filterValue, isGenre = isGenre })
                    return pill
                end
                
                createFilterPill("All", "all", 1, false)
                
                local showFeatured = self.DemoMode or (self.FeaturedCount and self.FeaturedCount > 0)
                if showFeatured then
                    createFilterPill("Featured", "featured", 2, false)
                end
                
                if not self.DemoMode then
                    createFilterPill("Newest", "newest", 3, false)
                end
                
                local availableGenres = self.AvailableGenres or {}
                for i, genre in ipairs(availableGenres) do
                    if genre and genre ~= "" and genre ~= "Unknown" then
                        createFilterPill(genre, genre, 10 + i, true)
                    end
                end
                
                local searchQuery = libState.search or ""
                local artistFilterLower = libState.artistFilter and libState.artistFilter:lower() or ""
                local genreFilterLower = libState.genreFilter and libState.genreFilter:lower() or ""
                local keywordFilterLower = libState.keywordFilter and libState.keywordFilter:lower() or ""
                
                local seenInFilter = {}
                local scoredTracks = {}
                
                for _, track in ipairs(self.LibraryTracks) do
                    local matchesSource = libState.filter == nil or track.source == libState.filter
                    
                    local matchesSearch, searchScore = true, 100
                    if searchQuery ~= "" then
                        matchesSearch, searchScore = fuzzySearchTrack(searchQuery, track)
                    end
                    
                    local matchesArtist = artistFilterLower == "" or 
                        (track.artist and track.artist:lower():find(artistFilterLower, 1, true))
                    
                    local matchesGenre = genreFilterLower == "" or 
                        (track.genre and track.genre:lower():find(genreFilterLower, 1, true))
                    
                    local matchesKeyword = keywordFilterLower == "" or
                        (track.name and track.name:lower():find(keywordFilterLower, 1, true)) or
                        (track.album and track.album:lower():find(keywordFilterLower, 1, true))
                    
                    if matchesSource and matchesSearch and matchesArtist and matchesGenre and matchesKeyword then
                        local key = (track.path or "") .. "|" .. (track.name or "")
                        if not seenInFilter[key] then
                            seenInFilter[key] = true
                            table.insert(scoredTracks, { track = track, score = searchScore })
                        end
                    end
                end
                
                if searchQuery ~= "" then
                    table.sort(scoredTracks, function(a, b) return a.score > b.score end)
                end
                
                for _, item in ipairs(scoredTracks) do
                    table.insert(libState.filteredTracks, item.track)
                end
                
                local totalTracks = #libState.filteredTracks
                local loadedCount = 0
                
                if totalTracks == 0 then
                    local noResultsText = "No songs found."
                    if libState.artistFilter ~= "" or libState.genreFilter ~= "" or libState.keywordFilter ~= "" then
                        noResultsText = "No songs match your filters.\nTry adjusting your filter settings."
                    elseif self.DemoMode then
                        noResultsText = "Loading Featured tracks...\n\nSelect 'Featured' filter to browse\nthe demo playlist."
                    else
                        noResultsText = "No songs found.\n\nAdd an API source in Settings,\nor add music files to your\nworkspace folder: xanbar/music"
                    end
                    
                    Create("TextLabel", {
                        Name = "Info",
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = noResultsText,
                        TextColor3 = theme.TextMuted,
                        TextSize = 11,
                        Size = UDim2.new(1, 0, 0, 80),
                        TextWrapped = true,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        LayoutOrder = 10,
                        Parent = librariesScroll
                    })
                    
                    libState.refreshInProgress = false
                else
                    local function loadMoreTracks()
                        if libState.isLoading then return false end
                        if thisVersion ~= libState.refreshVersion then return false end
                        
                        libState.isLoading = true
                        
                        local startIdx = loadedCount + 1
                        local endIdx = math.min(loadedCount + libState.pageSize, totalTracks)
                        
                        for i = startIdx, endIdx do
                            if thisVersion ~= libState.refreshVersion then 
                                libState.isLoading = false
                                return false
                            end
                            local track = libState.filteredTracks[i]
                            if track then
                                local existingItem = librariesScroll:FindFirstChild("LibTrack_" .. i)
                                if not existingItem then
                                    createLibraryTrackItem(track, i, librariesScroll)
                                end
                                loadedCount = loadedCount + 1
                            end
                        end
                        
                        libState.isLoading = false
                        return true
                    end
                    
                    loadMoreTracks()
                    
                    local loadMoreBtn = nil
                    if totalTracks > libState.pageSize then
                        loadMoreBtn = Create("TextButton", {
                            Name = "LoadMore",
                            BackgroundColor3 = theme.Surface,
                            Font = Enum.Font.GothamMedium,
                            Text = "Load More (" .. (totalTracks - loadedCount) .. " remaining)",
                            TextColor3 = theme.Accent,
                            TextSize = 12,
                            Size = UDim2.new(1, 0, 0, 36),
                            LayoutOrder = 9998,
                            AutoButtonColor = false,
                            Parent = librariesScroll
                        }, {
                            Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.7 })
                        })
                        
                        loadMoreBtn.MouseButton1Click:Connect(function()
                            loadMoreTracks()
                            if loadedCount >= totalTracks then
                                loadMoreBtn:Destroy()
                            else
                                loadMoreBtn.Text = "Load More (" .. (totalTracks - loadedCount) .. " remaining)"
                            end
                        end)
                    end
                    
                    librariesScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                        if thisVersion ~= libState.refreshVersion then return end
                        local scrollPos = librariesScroll.CanvasPosition.Y
                        local contentHeight = librariesScroll.AbsoluteCanvasSize.Y
                        local viewHeight = librariesScroll.AbsoluteSize.Y
                        
                        if scrollPos + viewHeight >= contentHeight - 100 and loadedCount < totalTracks then
                            loadMoreTracks()
                            if loadMoreBtn and loadedCount >= totalTracks then
                                loadMoreBtn:Destroy()
                            elseif loadMoreBtn then
                                loadMoreBtn.Text = "Load More (" .. (totalTracks - loadedCount) .. " remaining)"
                            end
                        end
                    end)
                end
                
                local filterInfo = ""
                local serverTotal = self.ServerTotalTracks or totalTracks
                local countText = ""
                
                if libState.artistFilter ~= "" or libState.genreFilter ~= "" or libState.keywordFilter ~= "" or (libState.search and libState.search ~= "") then
                    local filters = {}
                    if libState.search and libState.search ~= "" then table.insert(filters, "search: " .. libState.search) end
                    if libState.artistFilter ~= "" then table.insert(filters, "artist: " .. libState.artistFilter) end
                    if libState.genreFilter ~= "" then table.insert(filters, "genre: " .. libState.genreFilter) end
                    if libState.keywordFilter ~= "" then table.insert(filters, "keyword: " .. libState.keywordFilter) end
                    filterInfo = " (filtered by " .. table.concat(filters, ", ") .. ")"
                    countText = totalTracks .. " songs found" .. filterInfo
                else
                    countText = serverTotal .. " songs in library"
                end
                
                Create("TextLabel", {
                    Name = "TrackCount",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = countText,
                    TextColor3 = theme.TextMuted,
                    TextSize = 10,
                    Size = UDim2.new(1, 0, 0, 20),
                    LayoutOrder = 4,
                    Parent = librariesScroll
                })
                
                libState.refreshInProgress = false
            end)
        end
        
        local ui = {
            ScreenGui = screenGui,
            Main = main,
            TrackName = trackName,
            ArtistName = artistName,
            ProgressBg = progressBg,
            ProgressFill = progressFill,
            TimeLeft = timeLeft,
            TimeRight = timeRight,
            PlayBtn = playBtn,
            TrackList = trackList,
            Theme = theme
        }
        
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
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
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        local function showCloseConfirmPopup()
            local currentTheme = self:GetCurrentThemeLive() or theme
            
            local popupOverlay = Create("Frame", {
                Name = "CloseConfirmPopup",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 200,
                Parent = screenGui
            })
            
            local popupCard = Create("Frame", {
                Name = "Card",
                BackgroundColor3 = currentTheme.Surface,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 280, 0, 150),
                ZIndex = 201,
                Parent = popupOverlay
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                Create("UIStroke", { Color = currentTheme.Border, Thickness = 1 })
            })
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 20, 0, 16),
                Size = UDim2.new(1, -40, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = "Close Music Player?",
                TextColor3 = currentTheme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 202,
                Parent = popupCard
            })
            
            local descLabel = Create("TextLabel", {
                Name = "Desc",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 20, 0, 44),
                Size = UDim2.new(1, -40, 0, 40),
                Font = Enum.Font.Gotham,
                Text = "This will unload the music player.\nYou'll need to reload it to use it again.",
                TextColor3 = currentTheme.TextMuted,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = 202,
                Parent = popupCard
            })
            
            local cancelBtn = Create("TextButton", {
                Name = "Cancel",
                BackgroundColor3 = currentTheme.Surface,
                Position = UDim2.new(0, 20, 1, -50),
                Size = UDim2.new(0.5, -25, 0, 36),
                Font = Enum.Font.GothamMedium,
                Text = "Cancel",
                TextColor3 = currentTheme.Text,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex = 202,
                Parent = popupCard
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Create("UIStroke", { Color = currentTheme.Border, Thickness = 1 })
            })
            
            local confirmBtn = Create("TextButton", {
                Name = "Confirm",
                BackgroundColor3 = currentTheme.Error or Color3.fromRGB(220, 60, 60),
                Position = UDim2.new(0.5, 5, 1, -50),
                Size = UDim2.new(0.5, -25, 0, 36),
                Font = Enum.Font.GothamBold,
                Text = "Yes, Close",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex = 202,
                Parent = popupCard
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 8) })
            })
            
            local function closePopup()
                popupOverlay:Destroy()
            end
            
            cancelBtn.MouseEnter:Connect(function()
                Tween(cancelBtn, 0.1, { BackgroundColor3 = currentTheme.SurfaceHover or Color3.fromRGB(50, 50, 55) })
            end)
            cancelBtn.MouseLeave:Connect(function()
                Tween(cancelBtn, 0.1, { BackgroundColor3 = currentTheme.Surface })
            end)
            
            confirmBtn.MouseEnter:Connect(function()
                Tween(confirmBtn, 0.1, { BackgroundColor3 = Color3.fromRGB(255, 80, 80) })
            end)
            confirmBtn.MouseLeave:Connect(function()
                Tween(confirmBtn, 0.1, { BackgroundColor3 = currentTheme.Error or Color3.fromRGB(220, 60, 60) })
            end)
            
            cancelBtn.MouseButton1Click:Connect(closePopup)
            
            popupOverlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if input.Target == popupOverlay then
                        closePopup()
                    end
                end
            end)
            
            confirmBtn.MouseButton1Click:Connect(function()
                closePopup()
                self:Destroy()
            end)
            
            popupCard.BackgroundTransparency = 1
            popupOverlay.BackgroundTransparency = 1
            titleLabel.TextTransparency = 1
            descLabel.TextTransparency = 1
            cancelBtn.BackgroundTransparency = 1
            cancelBtn.TextTransparency = 1
            confirmBtn.BackgroundTransparency = 1
            confirmBtn.TextTransparency = 1
            
            Tween(popupOverlay, 0.2, { BackgroundTransparency = 0.5 })
            Tween(popupCard, 0.2, { BackgroundTransparency = 0 })
            Tween(titleLabel, 0.2, { TextTransparency = 0 })
            Tween(descLabel, 0.2, { TextTransparency = 0 })
            Tween(cancelBtn, 0.2, { BackgroundTransparency = 0, TextTransparency = 0 })
            Tween(confirmBtn, 0.2, { BackgroundTransparency = 0, TextTransparency = 0 })
        end
        
        local function handleCloseClick()
            if IsMobile then
                screenGui.Enabled = false
            else
                showCloseConfirmPopup()
            end
        end
        
        macCloseClickArea.MouseButton1Click:Connect(handleCloseClick)
        
        iconCloseBtn.MouseButton1Click:Connect(handleCloseClick)
        
        macCloseBtn.MouseEnter:Connect(function()
            macCloseX.Text = "×"
            Tween(macCloseBtn, 0.1, { Size = UDim2.new(0, navSizes.close + 3, 0, navSizes.close + 3) })
        end)
        macCloseBtn.MouseLeave:Connect(function()
            macCloseX.Text = ""
            Tween(macCloseBtn, 0.1, { Size = UDim2.new(0, navSizes.close, 0, navSizes.close) })
        end)
        
        iconCloseBtn.MouseEnter:Connect(function()
            local currentTheme = self:GetCurrentThemeLive() or theme
            Tween(iconCloseBtn, 0.15, { ImageColor3 = currentTheme.Error, ImageTransparency = 0 })
        end)
        iconCloseBtn.MouseLeave:Connect(function()
            local currentTheme = self:GetCurrentThemeLive() or theme
            Tween(iconCloseBtn, 0.15, { ImageColor3 = currentTheme.TextMuted, ImageTransparency = 0.3 })
        end)
        
        local function toggleMinimize()
            isMinimized = not isMinimized
            if isMinimized then
                main.Visible = false
                miniPlayer.Visible = true
                miniPlayer.Position = main.Position + UDim2.new(0, 0, 0, height - mini.height)
            else
                main.Visible = true
                miniPlayer.Visible = false
            end
        end
        
        macMinClickArea.MouseButton1Click:Connect(toggleMinimize)
        iconMinBtn.MouseButton1Click:Connect(toggleMinimize)
        
        macMinBtn.MouseEnter:Connect(function()
            macMinDash.Text = "–"
            Tween(macMinBtn, 0.1, { Size = UDim2.new(0, navSizes.close + 3, 0, navSizes.close + 3) })
        end)
        macMinBtn.MouseLeave:Connect(function()
            macMinDash.Text = ""
            Tween(macMinBtn, 0.1, { Size = UDim2.new(0, navSizes.close, 0, navSizes.close) })
        end)
        
        iconMinBtn.MouseEnter:Connect(function()
            local currentTheme = self:GetCurrentThemeLive() or theme
            Tween(iconMinBtn, 0.15, { ImageColor3 = currentTheme.Accent, ImageTransparency = 0 })
        end)
        iconMinBtn.MouseLeave:Connect(function()
            local currentTheme = self:GetCurrentThemeLive() or theme
            Tween(iconMinBtn, 0.15, { ImageColor3 = currentTheme.TextMuted, ImageTransparency = 0.3 })
        end)
        
        settingsBtn.MouseButton1Click:Connect(function()
            if currentView == "settings" then
                switchView("player")
            else
                switchView("settings")
            end
        end)
        
        queueBtn.MouseButton1Click:Connect(function()
            if currentView == "queue" then
                switchView("player")
            else
                refreshQueueView()
                switchView("queue")
            end
        end)
        
        queueBtn.MouseEnter:Connect(function()
            if currentView ~= "queue" then
                local t = self:GetCurrentThemeLive() or theme
                Tween(queueBtn, 0.1, { ImageColor3 = t.Text })
            end
        end)
        queueBtn.MouseLeave:Connect(function()
            if currentView ~= "queue" then
                local t = self:GetCurrentThemeLive() or theme
                Tween(queueBtn, 0.1, { ImageColor3 = t.TextMuted })
            end
        end)
        
        librariesBtn.MouseButton1Click:Connect(function()
            if currentView == "player" then
                switchView("libraries")
            else
                switchView("player")
            end
        end)
        
        librariesIcon.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if currentView == "player" then
                    switchView("libraries")
                else
                    switchView("player")
                end
            end
        end)
        
        settingsBtn.MouseEnter:Connect(function()
            if currentView ~= "settings" then
                local t = self:GetCurrentThemeLive() or theme
                Tween(settingsBtn, 0.1, { ImageColor3 = t.Text })
            end
        end)
        settingsBtn.MouseLeave:Connect(function()
            if currentView ~= "settings" then
                local t = self:GetCurrentThemeLive() or theme
                Tween(settingsBtn, 0.1, { ImageColor3 = t.TextMuted })
            end
        end)
        
        librariesBtn.MouseEnter:Connect(function()
            if currentView == "player" then
                local t = self:GetCurrentThemeLive() or theme
                Tween(librariesBtn, 0.1, { TextColor3 = t.Text })
                Tween(librariesIcon, 0.1, { ImageColor3 = t.Text })
            end
        end)
        librariesBtn.MouseLeave:Connect(function()
            if currentView == "player" then
                local t = self:GetCurrentThemeLive() or theme
                Tween(librariesBtn, 0.1, { TextColor3 = t.TextMuted })
                Tween(librariesIcon, 0.1, { ImageColor3 = t.TextMuted })
            end
        end)
        
        playBtn.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        
        prevBtn.MouseButton1Click:Connect(function()
            self:Previous()
        end)
        
        nextBtn.MouseButton1Click:Connect(function()
            self:Next()
        end)
        
        mini.playBtn.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        
        mini.prevBtn.MouseButton1Click:Connect(function()
            self:Previous()
        end)
        
        mini.nextBtn.MouseButton1Click:Connect(function()
            self:Next()
        end)
        
        local function doExpand()
            isMinimized = false
            main.Visible = true
            miniPlayer.Visible = false
        end
        
        mini.macExpandClickArea.MouseButton1Click:Connect(doExpand)
        mini.iconExpandBtn.MouseButton1Click:Connect(doExpand)
        
        mini.macExpandBtn.MouseEnter:Connect(function()
            Tween(mini.macExpandBtn, 0.1, { Size = UDim2.new(0, 17, 0, 17) })
        end)
        mini.macExpandBtn.MouseLeave:Connect(function()
            Tween(mini.macExpandBtn, 0.1, { Size = UDim2.new(0, 14, 0, 14) })
        end)
        
        mini.iconExpandBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.iconExpandBtn, 0.15, { ImageColor3 = t.Accent, ImageTransparency = 0 })
        end)
        mini.iconExpandBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.iconExpandBtn, 0.15, { ImageColor3 = t.TextMuted, ImageTransparency = 0.3 })
        end)
        
        mini.prevBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.prevBtn, 0.1, { ImageColor3 = t.Accent })
        end)
        mini.prevBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.prevBtn, 0.1, { ImageColor3 = t.Text })
        end)
        
        mini.nextBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.nextBtn, 0.1, { ImageColor3 = t.Accent })
        end)
        mini.nextBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.nextBtn, 0.1, { ImageColor3 = t.Text })
        end)
        
        local miniSeekDragging = false
        
        mini.progressClickArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                miniSeekDragging = true
                local relX = (input.Position.X - mini.progressBg.AbsolutePosition.X) / mini.progressBg.AbsoluteSize.X
                self:Seek(math.clamp(relX, 0, 1))
            end
        end)
        
        mini.progressBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                miniSeekDragging = true
                local relX = (input.Position.X - mini.progressBg.AbsolutePosition.X) / mini.progressBg.AbsoluteSize.X
                self:Seek(math.clamp(relX, 0, 1))
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if miniSeekDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = (input.Position.X - mini.progressBg.AbsolutePosition.X) / mini.progressBg.AbsoluteSize.X
                self:Seek(math.clamp(relX, 0, 1))
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                miniSeekDragging = false
            end
        end)
        
        mini.progressBg.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(mini.progressBg, 0.15, { Size = UDim2.new(1, -24, 0, IsMobile and 8 or 7) })
        end)
        mini.progressBg.MouseLeave:Connect(function()
            if not miniSeekDragging then
                Tween(mini.progressBg, 0.15, { Size = UDim2.new(1, -24, 0, IsMobile and 6 or 5) })
            end
        end)
        
        local miniDragging, miniDragStart, miniStartPos
        miniPlayer.InputBegan:Connect(function(input)
            if miniSeekDragging then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                miniDragging = true
                miniDragStart = input.Position
                miniStartPos = miniPlayer.Position
            end
        end)
        
        miniPlayer.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                miniDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if miniSeekDragging then return end
            if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - miniDragStart
                miniPlayer.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                miniDragging = false
            end
        end)
        
        shuffleBtn.MouseButton1Click:Connect(function()
            self.IsShuffled = not self.IsShuffled
            local t = self:GetCurrentThemeLive() or theme
            Tween(shuffleBtn, 0.15, { ImageColor3 = self.IsShuffled and t.Accent or t.Text })
        end)
        shuffleBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            if not self.IsShuffled then
                Tween(shuffleBtn, 0.1, { ImageColor3 = t.Accent })
            end
        end)
        shuffleBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            if not self.IsShuffled then
                Tween(shuffleBtn, 0.1, { ImageColor3 = t.Text })
            end
        end)
        
        loopBtn.MouseButton1Click:Connect(function()
            self.LoopEnabled = not self.LoopEnabled
            local t = self:GetCurrentThemeLive() or theme
            if self.LoopEnabled then
                Tween(loopBtn, 0.15, { ImageColor3 = t.Accent })
            else
                Tween(loopBtn, 0.15, { ImageColor3 = t.Text })
            end
            if self.CurrentSound then
                self.CurrentSound.Looped = self.LoopEnabled
            end
        end)
        
        loopBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            if not self.LoopEnabled then
                Tween(loopBtn, 0.1, { ImageColor3 = t.Accent })
            end
        end)
        loopBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            if not self.LoopEnabled then
                Tween(loopBtn, 0.1, { ImageColor3 = t.Text })
            end
        end)
        
        local playBtnHoverSize = IsMobile and 44 or 52
        playBtn.MouseEnter:Connect(function()
            Tween(playBtn, 0.15, { Size = UDim2.new(0, playBtnHoverSize, 0, playBtnHoverSize) })
        end)
        playBtn.MouseLeave:Connect(function()
            Tween(playBtn, 0.15, { Size = UDim2.new(0, playBtnSize, 0, playBtnSize) })
        end)
        
        prevBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(prevBtn, 0.1, { ImageColor3 = t.Accent })
        end)
        prevBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(prevBtn, 0.1, { ImageColor3 = t.Text })
        end)
        
        nextBtn.MouseEnter:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(nextBtn, 0.1, { ImageColor3 = t.Accent })
        end)
        nextBtn.MouseLeave:Connect(function()
            local t = self:GetCurrentThemeLive() or theme
            Tween(nextBtn, 0.1, { ImageColor3 = t.Text })
        end)
        
        local seekDragging = false
        
        progressBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                seekDragging = true
                local relX = (input.Position.X - progressBg.AbsolutePosition.X) / progressBg.AbsoluteSize.X
                self:Seek(math.clamp(relX, 0, 1))
                Tween(progressHandle, 0.1, { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9) })
            end
        end)
        
        progressHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                seekDragging = true
                Tween(progressHandle, 0.1, { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9) })
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if seekDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = (input.Position.X - progressBg.AbsolutePosition.X) / progressBg.AbsoluteSize.X
                self:Seek(math.clamp(relX, 0, 1))
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if seekDragging then
                    seekDragging = false
                    Tween(progressHandle, 0.1, { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7) })
                end
            end
        end)
        
        local function updatePlayBtn()
            if self.IsPlaying and self.CurrentSound then
                playBtn.Image = "rbxassetid://71138552974135"
                mini.playBtn.Image = "rbxassetid://71138552974135"
            else
                playBtn.Image = "rbxassetid://81811408640078"
                mini.playBtn.Image = "rbxassetid://81811408640078"
            end
        end
        
        local function updateTrackDisplay()
            if self.CurrentTrack then
                trackName.Text = self.CurrentTrack.name
                artistName.Text = self.CurrentTrack.artist or "Unknown Artist"
                mini.trackName.Text = self.CurrentTrack.name
                mini.artistName.Text = self.CurrentTrack.artist or "Unknown Artist"
                
                if self.CurrentTrack.image_url and self.CurrentTrack.image_url ~= "" then
                    albumArtImage.Image = self.CurrentTrack.image_url
                    albumArtImage.Visible = true
                    albumArtIcon.Visible = false
                    mini.thumbImage.Image = self.CurrentTrack.image_url
                    mini.thumbImage.Visible = true
                    mini.thumbIcon.Visible = false
                else
                    albumArtImage.Image = ""
                    albumArtImage.Visible = false
                    albumArtIcon.Visible = true
                    mini.thumbImage.Image = ""
                    mini.thumbImage.Visible = false
                    mini.thumbIcon.Visible = true
                end
                
                local isInLibrary = false
                for _, t in ipairs(self.Tracks) do
                    if t.name == self.CurrentTrack.name and t.artist == self.CurrentTrack.artist then
                        isInLibrary = true
                        break
                    end
                end
                addToLibBtn.Visible = not isInLibrary
                addToLibBtn.Text = "+"
                local t = self:GetCurrentThemeLive() or theme
                addToLibBtn.BackgroundColor3 = t.Accent
                
                if self._updateAlbumArtModal then
                    self._updateAlbumArtModal()
                end
            else
                trackName.Text = "No track"
                artistName.Text = "Unknown Artist"
                mini.trackName.Text = "No track"
                mini.artistName.Text = "Unknown Artist"
                albumArtImage.Image = ""
                albumArtImage.Visible = false
                albumArtIcon.Visible = true
                mini.thumbImage.Image = ""
                mini.thumbImage.Visible = false
                mini.thumbIcon.Visible = true
                addToLibBtn.Visible = false
            end
            updatePlayBtn()
        end
        
        local function showAlbumArtDialog(track, trackIndex)
            local dialogOverlay = Create("Frame", {
                Name = "AlbumArtDialog",
                BackgroundColor3 = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 100,
                Parent = main
            })
            
            local dialogBox = Create("Frame", {
                Name = "DialogBox",
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(0, IsMobile and 260 or 300, 0, IsMobile and 140 or 160),
                Position = UDim2.new(0.5, IsMobile and -130 or -150, 0.5, IsMobile and -70 or -80),
                ZIndex = 101,
                Parent = dialogOverlay
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                Create("UIStroke", { Color = theme.Border, Thickness = 1 })
            })
            
            Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Set Album Art",
                TextColor3 = theme.Text,
                TextSize = IsMobile and 13 or 14,
                Size = UDim2.new(1, -20, 0, 24),
                Position = UDim2.new(0, 10, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 102,
                Parent = dialogBox
            })
            
            Create("TextLabel", {
                Name = "Subtitle",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "Enter Roblox Asset ID",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 10 or 11,
                Size = UDim2.new(1, -20, 0, 16),
                Position = UDim2.new(0, 10, 0, 34),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 102,
                Parent = dialogBox
            })
            
            local inputBox = Create("TextBox", {
                Name = "Input",
                BackgroundColor3 = theme.Background,
                Font = Enum.Font.Gotham,
                Text = track.image_asset_id or "",
                PlaceholderText = "e.g. 12345678901234",
                PlaceholderColor3 = theme.TextMuted,
                TextColor3 = theme.Text,
                TextSize = IsMobile and 12 or 13,
                Size = UDim2.new(1, -20, 0, IsMobile and 32 or 36),
                Position = UDim2.new(0, 10, 0, IsMobile and 56 or 58),
                ClearTextOnFocus = false,
                ZIndex = 102,
                Parent = dialogBox
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
                Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
            })
            
            local btnY = IsMobile and 100 or 108
            local btnWidth = IsMobile and 70 or 80
            local btnHeight = IsMobile and 28 or 32
            
            local cancelBtn = Create("TextButton", {
                Name = "Cancel",
                BackgroundColor3 = theme.Background,
                Font = Enum.Font.Gotham,
                Text = "Cancel",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 11 or 12,
                Size = UDim2.new(0, btnWidth, 0, btnHeight),
                Position = UDim2.new(1, -(btnWidth * 2 + 18), 0, btnY),
                AutoButtonColor = false,
                ZIndex = 102,
                Parent = dialogBox
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local saveBtn = Create("TextButton", {
                Name = "Save",
                BackgroundColor3 = theme.Accent,
                Font = Enum.Font.GothamBold,
                Text = "Save",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = IsMobile and 11 or 12,
                Size = UDim2.new(0, btnWidth, 0, btnHeight),
                Position = UDim2.new(1, -(btnWidth + 10), 0, btnY),
                AutoButtonColor = false,
                ZIndex = 102,
                Parent = dialogBox
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local function closeDialog()
                dialogOverlay:Destroy()
            end
            
            cancelBtn.MouseButton1Click:Connect(closeDialog)
            dialogOverlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if input.Target == dialogOverlay then
                        closeDialog()
                    end
                end
            end)
            
            saveBtn.MouseButton1Click:Connect(function()
                local assetId = inputBox.Text:gsub("%s+", "")
                if assetId ~= "" then
                    track.image_asset_id = assetId
                    track.image_url = "rbxassetid://" .. assetId
                    self.Tracks[trackIndex] = track
                    self:SaveLibrary()
                    if refreshTrackList then refreshTrackList() end
                    updateNowPlaying()
                end
                closeDialog()
            end)
            
            inputBox:CaptureFocus()
        end
        
        local function createTrackItem(track, index)
            local isCurrentTrack = self.CurrentTrack and self.CurrentTrack.name == track.name
            local isPlaying = isCurrentTrack and self.IsPlaying
            
            local itemHeight = IsMobile and 48 or 52
            local thumbSize = IsMobile and 36 or 40
            local numWidth = IsMobile and 20 or 24
            local item = Create("Frame", {
                Name = "Track_" .. index,
                BackgroundColor3 = isCurrentTrack and theme.Surface or theme.Background,
                Size = UDim2.new(1, -8, 0, itemHeight),
                LayoutOrder = index,
                Parent = trackList
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            if isCurrentTrack then
                Create("Frame", {
                    Name = "Indicator",
                    BackgroundColor3 = theme.Accent,
                    Size = UDim2.new(0, 3, 0.6, 0),
                    Position = UDim2.new(0, 0, 0.2, 0),
                    Parent = item
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 2) })
                })
            end
            
            local trackNum = Create("TextLabel", {
                Name = "Number",
                BackgroundTransparency = 1,
                Font = isCurrentTrack and Enum.Font.GothamBold or Enum.Font.Gotham,
                Text = tostring(index),
                TextColor3 = isCurrentTrack and theme.Accent or theme.TextMuted,
                TextSize = IsMobile and 11 or 12,
                Size = UDim2.new(0, numWidth, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                Parent = item
            })
            
            local thumbContainer = Create("Frame", {
                Name = "Thumb",
                BackgroundColor3 = theme.Border,
                Size = UDim2.new(0, thumbSize, 0, thumbSize),
                Position = UDim2.new(0, numWidth + 8, 0.5, -thumbSize/2),
                ClipsDescendants = true,
                Parent = item
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local hasImage = track.image_url and track.image_url ~= ""
            local thumbImage = Create("ImageLabel", {
                Name = "Image",
                BackgroundTransparency = 1,
                Image = track.image_url or "",
                Size = UDim2.new(1, 0, 1, 0),
                ScaleType = Enum.ScaleType.Crop,
                Parent = thumbContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            
            local thumbPlaceholder = Create("ImageLabel", {
                Name = "Placeholder",
                BackgroundTransparency = 1,
                Image = "rbxassetid://102923134853209",
                ImageColor3 = theme.TextMuted,
                ImageTransparency = 0.5,
                Visible = not hasImage,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0.5, -9, 0.5, -9),
                Parent = thumbContainer
            })
            
            if isCurrentTrack then
                local playingOverlay = Create("Frame", {
                    Name = "PlayingOverlay",
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 2,
                    Parent = thumbContainer
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) })
                })
                
                Create("TextLabel", {
                    Name = "PlayingIcon",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "♪",
                    TextColor3 = theme.Accent,
                    TextSize = IsMobile and 18 or 20,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3,
                    Parent = thumbContainer
                })
            end
            
            if track.isLocal then
                local editOverlay = Create("Frame", {
                    Name = "EditOverlay",
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 0.6,
                    Size = UDim2.new(1, 0, 1, 0),
                    Visible = false,
                    ZIndex = 4,
                    Parent = thumbContainer
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) })
                })
                
                local editBtn = Create("ImageButton", {
                    Name = "EditBtn",
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://105573988850154",
                    ImageColor3 = Color3.new(1, 1, 1),
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0.5, -9, 0.5, -9),
                    ZIndex = 5,
                    Parent = editOverlay
                })
                
                thumbContainer.MouseEnter:Connect(function()
                    if not isCurrentTrack then
                        editOverlay.Visible = true
                    end
                end)
                
                thumbContainer.MouseLeave:Connect(function()
                    editOverlay.Visible = false
                end)
                
                editBtn.MouseButton1Click:Connect(function()
                    showAlbumArtDialog(track, index)
                end)
            end
            
            local textOffsetX = numWidth + thumbSize + 16
            local name = Create("TextLabel", {
                Name = "Name",
                BackgroundTransparency = 1,
                Font = isCurrentTrack and Enum.Font.GothamBold or Enum.Font.Gotham,
                Text = track.name,
                TextColor3 = isCurrentTrack and theme.Accent or theme.Text,
                TextSize = IsMobile and 11 or 12,
                Size = UDim2.new(1, -(textOffsetX + 90), 0, 16),
                Position = UDim2.new(0, textOffsetX, 0, IsMobile and 8 or 10),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            local artist = Create("TextLabel", {
                Name = "Artist",
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = track.artist or "Local",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 9 or 10,
                Size = UDim2.new(1, -(textOffsetX + 90), 0, 14),
                Position = UDim2.new(0, textOffsetX, 0, IsMobile and 24 or 28),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = item
            })
            
            local menuBtn = Create("TextButton", {
                Name = "MenuBtn",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "•••",
                TextColor3 = theme.TextMuted,
                TextSize = IsMobile and 14 or 16,
                Size = UDim2.new(0, 28, 1, 0),
                Position = UDim2.new(1, -28, 0, 0),
                AutoButtonColor = false,
                Parent = item
            })
            
            menuBtn.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(menuBtn, 0.1, { TextColor3 = t.Text })
            end)
            menuBtn.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(menuBtn, 0.1, { TextColor3 = t.TextMuted })
            end)
            
            menuBtn.MouseButton1Click:Connect(function()
                if activeState.contextMenu and activeState.contextMenu.Parent then
                    activeState.contextMenu:Destroy()
                    activeState.contextMenu = nil
                    return
                end
                
                local menuWidth = IsMobile and 160 or 180
                local menuItemHeight = IsMobile and 36 or 40
                local menuItems = {
                    { text = "Play Next", action = "playNext", color = theme.Text },
                    { text = "Add to Queue", action = "addQueue", color = theme.Text },
                    { text = "Remove from Library", action = "remove", color = Color3.fromRGB(220, 80, 80) }
                }
                
                local menuHeight = #menuItems * menuItemHeight + 12
                
                local itemAbsPos = item.AbsolutePosition
                local itemAbsSize = item.AbsoluteSize
                local screenSize = workspace.CurrentCamera.ViewportSize
                
                local menuX = math.clamp(itemAbsPos.X + itemAbsSize.X - menuWidth - 8, 10, screenSize.X - menuWidth - 10)
                local menuY = math.clamp(itemAbsPos.Y + itemAbsSize.Y/2 - menuHeight/2, 10, screenSize.Y - menuHeight - 10)
                
                local currentT = self:GetCurrentThemeLive() or theme
                local contextMenu = Create("Frame", {
                    Name = "TrackContextMenu",
                    BackgroundColor3 = currentT.Background,
                    Size = UDim2.new(0, menuWidth, 0, menuHeight),
                    Position = UDim2.new(0, menuX, 0, menuY),
                    ZIndex = 100,
                    Parent = screenGui
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                    Create("UIStroke", { Color = currentT.Border, Thickness = 1 }),
                    Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }),
                    Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2) })
                })
                
                activeState.contextMenu = contextMenu
                
                local function doTrackAction(action)
                    if contextMenu and contextMenu.Parent then
                        contextMenu:Destroy()
                    end
                    activeState.contextMenu = nil
                    
                    local trackCopy = {
                        name = track.name,
                        artist = track.artist,
                        album = track.album,
                        genre = track.genre,
                        path = track.path,
                        source = track.source,
                        id = track.id,
                        image_url = track.image_url,
                        image_asset_id = track.image_asset_id,
                        isLocal = track.isLocal or false
                    }
                    
                    if action == "playNext" then
                        table.insert(self.UpNext, 1, trackCopy)
                        if self.OnQueueChanged then pcall(self.OnQueueChanged) end
                        local xan = self:GetXanInstance()
                        if xan and xan.Toast then xan.Toast("Playing Next", trackCopy.name) end
                        updateQueueBadge()
                    elseif action == "addQueue" then
                        table.insert(self.UpNext, trackCopy)
                        if self.OnQueueChanged then pcall(self.OnQueueChanged) end
                        local xan = self:GetXanInstance()
                        if xan and xan.Toast then xan.Toast("Added to Queue", trackCopy.name) end
                        updateQueueBadge()
                    elseif action == "remove" then
                        if isCurrentTrack then
                            self:Stop()
                        end
                        self:RemoveTrack(index)
                        refreshTrackList()
                    end
                end
                
                for i, menuItem in ipairs(menuItems) do
                    local btn = Create("TextButton", {
                        Name = menuItem.action,
                        BackgroundColor3 = currentT.Surface,
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamMedium,
                        Text = menuItem.text,
                        TextColor3 = menuItem.color,
                        TextSize = IsMobile and 12 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, -12, 0, menuItemHeight - 4),
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex = 101,
                        Parent = contextMenu
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                        Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
                    })
                    
                    btn.MouseEnter:Connect(function()
                        Tween(btn, 0.1, { BackgroundTransparency = 0 })
                    end)
                    btn.MouseLeave:Connect(function()
                        Tween(btn, 0.1, { BackgroundTransparency = 1 })
                    end)
                    
                    btn.Activated:Connect(function()
                        doTrackAction(menuItem.action)
                    end)
                end
                
                local backdrop = Create("TextButton", {
                    Name = "TrackMenuBackdrop",
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 99,
                    Parent = screenGui
                })
                
                backdrop.Activated:Connect(function()
                    if contextMenu and contextMenu.Parent then contextMenu:Destroy() end
                    if backdrop and backdrop.Parent then backdrop:Destroy() end
                    activeState.contextMenu = nil
                end)
                
                contextMenu.Destroying:Connect(function()
                    if backdrop and backdrop.Parent then backdrop:Destroy() end
                end)
            end)
            
            local actionBtn = Create("TextButton", {
                Name = "Action",
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = isPlaying and "Playing" or "Play",
                TextColor3 = isPlaying and theme.Accent or Color3.fromRGB(100, 200, 120),
                TextSize = IsMobile and 10 or 12,
                Size = UDim2.new(0, 50, 1, 0),
                Position = UDim2.new(1, -78, 0, 0),
                AutoButtonColor = false,
                Parent = item
            })
            
            actionBtn.MouseButton1Click:Connect(function()
                if isCurrentTrack and self.IsPlaying then
                    self:Pause()
                elseif isCurrentTrack then
                    self:Resume()
                else
                    self:Play(track, index)
                end
                refreshTrackList()
            end)
            
            actionBtn.MouseEnter:Connect(function()
                if not isPlaying then
                    local t = self:GetCurrentThemeLive() or theme
                    Tween(actionBtn, 0.1, { TextColor3 = t.Accent })
                end
            end)
            actionBtn.MouseLeave:Connect(function()
                if not isPlaying then
                    Tween(actionBtn, 0.1, { TextColor3 = Color3.fromRGB(100, 200, 120) })
                end
            end)
            
            item.MouseEnter:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(item, 0.12, { BackgroundColor3 = t.Surface })
            end)
            item.MouseLeave:Connect(function()
                local t = self:GetCurrentThemeLive() or theme
                Tween(item, 0.12, { BackgroundColor3 = isCurrentTrack and t.Surface or t.Background })
            end)
            
            return item
        end
        
        refreshTrackList = function()
            for _, child in pairs(trackList:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
            
            if #self.Tracks == 0 then
                Create("TextLabel", {
                    Name = "Empty",
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = "No tracks\n\nAdd music files to:\nxanbar/music",
                    TextColor3 = theme.TextMuted,
                    TextSize = 12,
                    Size = UDim2.new(1, -20, 0, 80),
                    Position = UDim2.new(0, 10, 0, 20),
                    TextWrapped = true,
                    Parent = trackList
                })
                return
            end
            
            for i, track in ipairs(self.Tracks) do
                createTrackItem(track, i)
            end
        end
        
        addToLibBtn.MouseButton1Click:Connect(function()
            if not self.CurrentTrack then return end
            
            local track = self.CurrentTrack
            local t = self:GetCurrentThemeLive() or theme
            
            addToLibBtn.Text = "..."
            addToLibBtn.BackgroundColor3 = t.Border
            
            local added = self:AddToMyLibrary(track, 
                function()
                    addToLibBtn.Text = "..."
                end,
                function(success)
                    if success then
                        addToLibBtn.Text = "✓"
                        Tween(addToLibBtn, 0.2, { BackgroundColor3 = Color3.fromRGB(60, 160, 80) })
                        task.wait(1)
                        addToLibBtn.Visible = false
                    else
                        addToLibBtn.Visible = false
                    end
                    refreshTrackList()
                end
            )
            
            if not added then
                addToLibBtn.Text = "✓"
                task.wait(0.5)
                addToLibBtn.Visible = false
                refreshTrackList()
            end
        end)
        
        self.OnTrackChanged = function(track)
            updateTrackDisplay()
            refreshTrackList()
            
            if self.CuteVisualizer and self.CuteVisualizerEnabled then
                self.CuteVisualizer:OnTrackChange()
            end
        end
        
        self.OnPlayStateChanged = function(playing)
            updatePlayBtn()
            refreshTrackList()
            
            if self.CuteVisualizer and self.CuteVisualizerEnabled then
                self.CuteVisualizer:SetPlaying(playing)
            end
            
            if self._updateAlbumArtModal then
                self._updateAlbumArtModal()
            end
        end
        
        self.OnLibraryTrackEnded = function(nextIdx, nextTrack)
            if activeState.previewReset then
                activeState.previewReset()
            end
            activeState.previewBtn = nil
            activeState.previewReset = nil
            activeState.playingItem = nil
            
            if nextIdx and nextTrack and librariesScroll then
                local nextItem = librariesScroll:FindFirstChild("LibTrack_" .. nextIdx)
                if nextItem then
                    local container = nextItem:FindFirstChild("PreviewContainer")
                    if container then
                        local playBtnInner = container:FindFirstChild("PlayBtn")
                        local vizFrame = container:FindFirstChild("Visualizer")
                        local stopBtnInner = container:FindFirstChild("StopBtn")
                        
                        if playBtnInner then playBtnInner.Visible = false end
                        if vizFrame then
                            vizFrame.Visible = true
                            local bar1 = vizFrame:FindFirstChild("Bar1")
                            local bar2 = vizFrame:FindFirstChild("Bar2")
                            if bar1 and bar2 then
                                local barWidth = IsMobile and 5 or 6
                                local bar1Phase = 0
                                local bar2Phase = math.pi / 2
                                RemoveRenderTask(activeStateVizTaskId)
                                activeState.visualizerActive = true
                                AddRenderTask(activeStateVizTaskId, function(dt)
                                    if not vizFrame or not vizFrame.Parent or not vizFrame.Visible then
                                        RemoveRenderTask(activeStateVizTaskId)
                                        activeState.visualizerActive = false
                                        return
                                    end
                                    bar1Phase = bar1Phase + dt * 2.5
                                    bar2Phase = bar2Phase + dt * 3.2
                                    local h1 = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(bar1Phase))
                                    local h2 = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(bar2Phase))
                                    bar1.Size = UDim2.new(0, barWidth, h1, 0)
                                    bar2.Size = UDim2.new(0, barWidth, h2, 0)
                                end, { frameSkip = 2 })
                            end
                        end
                        if stopBtnInner then stopBtnInner.Visible = false end
                        
                        activeState.playingItem = nextItem
                        activeState.previewReset = function()
                            if playBtnInner then playBtnInner.Visible = true end
                            if vizFrame then vizFrame.Visible = false end
                            if stopBtnInner then stopBtnInner.Visible = false end
                            RemoveRenderTask(activeStateVizTaskId)
                            activeState.visualizerActive = false
                        end
                        activeState.previewBtn = container
                    end
                end
            else
                RemoveRenderTask(activeStateVizTaskId)
                activeState.visualizerActive = false
            end
        end
        
        local mainVizTaskId = GenerateTaskId("MainUIViz")
        local vizState = { resetDone = false, lastUpdate = 0, interval = 0.05 }
        AddRenderTask(mainVizTaskId, function()
            if not screenGui.Parent then
                RemoveRenderTask(mainVizTaskId)
                return
            end
            
            if self.CurrentSound and self.IsPlaying then
                vizState.resetDone = false
                
                local now = tick()
                if now - vizState.lastUpdate >= vizState.interval then
                    vizState.lastUpdate = now
                    local progress = self:GetProgress()
                    local time = self:GetTimeInfo()
                    
                    progressFill.Size = UDim2.new(progress, 0, 1, 0)
                    mini.progressFill.Size = UDim2.new(progress, 0, 1, 0)
                    progressHandle.Position = UDim2.new(1, -7, 0.5, -7)
                    progressHandle.Visible = true
                    timeLeft.Text = time.currentFormatted
                    timeRight.Text = time.totalFormatted
                    updatePlayBtn()
                end
                
                local loudness = self.CurrentSound.PlaybackLoudness or 0
                local rawIntensity = math.clamp(loudness / 280, 0, 1)
                local t = tick()
                local dt = 0.016
                
                local maxBarHeight = IsMobile and 20 or 26
                local minBarHeight = 4
                local miniMaxH = IsMobile and 14 or 17
                local miniMinH = 3
                
                local vizMode = self.VisualizerMode or "Reactive"
                
                if vizMode == "Wave" then
                    local intensity = math.clamp(loudness / 300, 0, 1)
                    for i, bar in ipairs(visualizerBars) do
                        local wave = math.sin(t * 8 + i * 0.5) * 0.3 + 0.7
                        local bass = i <= 6 and 1.3 or (i >= 15 and 0.8 or 1)
                        local h = minBarHeight + (intensity * wave * bass * (maxBarHeight - minBarHeight))
                        bar.Size = UDim2.new(0, barWidth, 0, math.max(minBarHeight, h))
                    end
                    for i, bar in ipairs(mini.bars) do
                        local wave = math.sin(t * 10 + i * 0.4) * 0.3 + 0.7
                        local bass = i <= 5 and 1.2 or (i >= 20 and 0.85 or 1)
                        local h = miniMinH + (intensity * wave * bass * (miniMaxH - miniMinH))
                        bar.Size = UDim2.new(0, 4, 0, math.max(miniMinH, h))
                    end
                    
                elseif vizMode == "Pulse" then
                    local intensity = math.clamp(loudness / 250, 0, 1)
                    local pulse = (math.sin(t * 6) * 0.5 + 0.5) * intensity
                    local basePulse = (math.sin(t * 3) * 0.3 + 0.7) * intensity
                    
                    for i, bar in ipairs(visualizerBars) do
                        local centerDist = math.abs(i - barCount / 2) / (barCount / 2)
                        local h = minBarHeight + (basePulse * (1 - centerDist * 0.5) + pulse * 0.3) * (maxBarHeight - minBarHeight)
                        bar.Size = UDim2.new(0, barWidth, 0, math.max(minBarHeight, h))
                    end
                    for i, bar in ipairs(mini.bars) do
                        local centerDist = math.abs(i - #mini.bars / 2) / (#mini.bars / 2)
                        local h = miniMinH + (basePulse * (1 - centerDist * 0.5) + pulse * 0.3) * (miniMaxH - miniMinH)
                        bar.Size = UDim2.new(0, 4, 0, math.max(miniMinH, h))
                    end
                    
                else
                    local bassBoost = math.clamp(loudness / 200, 0, 1.5)
                    local midBoost = math.clamp(loudness / 300, 0, 1.2)
                    local trebleBoost = math.clamp(loudness / 400, 0, 1)
                    
                    for i, bar in ipairs(visualizerBars) do
                        local state = vizBarState[i]
                        local band = state.band
                        
                        local bandIntensity = rawIntensity
                        if band.name == "subBass" or band.name == "bass" then
                            bandIntensity = bandIntensity * bassBoost
                        elseif band.name == "lowMid" or band.name == "mid" then
                            bandIntensity = bandIntensity * midBoost
                        else
                            bandIntensity = bandIntensity * trebleBoost
                        end
                        
                        local noise1 = math.sin(t * band.baseSpeed + state.phase) * 0.5 + 0.5
                        local noise2 = math.sin(t * band.baseSpeed * 0.7 + state.noiseOffset) * 0.3 + 0.5
                        local noise3 = math.sin(t * band.baseSpeed * 1.3 + state.phase * 2) * 0.2 + 0.5
                        local combinedNoise = (noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2)
                        
                        local targetHeight = band.minHeight + (bandIntensity * band.reactivity * combinedNoise * (1 - band.minHeight))
                        targetHeight = math.clamp(targetHeight, 0, 1)
                        
                        if targetHeight > state.target then
                            state.target = state.target + (targetHeight - state.target) * 0.6
                        else
                            state.target = state.target * band.decay + targetHeight * (1 - band.decay)
                        end
                        
                        local diff = state.target - state.current
                        state.velocity = state.velocity * 0.7 + diff * 0.5
                        state.current = state.current + state.velocity
                        state.current = math.clamp(state.current, 0, 1)
                        
                        local h = minBarHeight + state.current * (maxBarHeight - minBarHeight)
                        bar.Size = UDim2.new(0, barWidth, 0, math.max(minBarHeight, h))
                    end
                    
                    for i, bar in ipairs(mini.bars) do
                        local pct = (i - 1) / (#mini.bars - 1)
                        local bandIdx = math.floor(pct * #vizBands) + 1
                        bandIdx = math.clamp(bandIdx, 1, #vizBands)
                        local band = vizBands[bandIdx]
                        
                        local bandIntensity = rawIntensity
                        if band.name == "subBass" or band.name == "bass" then
                            bandIntensity = bandIntensity * bassBoost * 0.9
                        elseif band.name == "lowMid" or band.name == "mid" then
                            bandIntensity = bandIntensity * midBoost * 0.85
                        else
                            bandIntensity = bandIntensity * trebleBoost * 0.8
                        end
                        
                        local noise = math.sin(t * band.baseSpeed * 1.2 + i * 0.8) * 0.4 + 0.6
                        local h = miniMinH + bandIntensity * band.reactivity * noise * (miniMaxH - miniMinH)
                        bar.Size = UDim2.new(0, 4, 0, math.max(miniMinH, h))
                    end
                end
            elseif not vizState.resetDone then
                for i, bar in ipairs(visualizerBars) do
                    if vizBarState[i] then
                        vizBarState[i].current = 0
                        vizBarState[i].target = 0
                        vizBarState[i].velocity = 0
                    end
                    Tween(bar, 0.3, { Size = UDim2.new(0, barWidth, 0, 4) })
                end
                for i, bar in ipairs(mini.bars) do
                    Tween(bar, 0.3, { Size = UDim2.new(0, 4, 0, 3) })
                end
                updatePlayBtn()
                vizState.resetDone = true
            end
        end, { throttle = 0.05 })
        
        local function updateTheme(newTheme)
            theme = newTheme
            lastAccentColor = newTheme.Accent
            
            main.BackgroundColor3 = newTheme.Background
            local mainStroke = main:FindFirstChildOfClass("UIStroke")
            if mainStroke then mainStroke.Color = newTheme.Border end
            
            if mainBgImage then
                if newTheme.BackgroundImage then
                    mainBgImage.Image = newTheme.BackgroundImage
                    mainBgImage.ImageTransparency = newTheme.BackgroundImageTransparency or 0.15
                    mainBgImage.ImageColor3 = Color3.new(1, 1, 1)
                    mainBgImage.Visible = true
                else
                    mainBgImage.Visible = false
                end
            elseif newTheme.BackgroundImage then
                mainBgImage = Create("ImageLabel", {
                    Name = "BgImage",
                    BackgroundTransparency = 1,
                    Image = newTheme.BackgroundImage,
                    ImageTransparency = newTheme.BackgroundImageTransparency or 0.15,
                    ImageColor3 = Color3.new(1, 1, 1),
                    ScaleType = Enum.ScaleType.Crop,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 0,
                    Parent = main
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 12) })
                })
            end
            
            if mainBgOverlay then
                mainBgOverlay.BackgroundColor3 = newTheme.BackgroundOverlay or newTheme.Background
                mainBgOverlay.BackgroundTransparency = newTheme.BackgroundImage and (newTheme.BackgroundOverlayTransparency or 0.4) or 1
            end
            
            musicIcon.ImageColor3 = newTheme.Accent
            title.TextColor3 = newTheme.Text
            
            iconCloseBtn.ImageColor3 = newTheme.TextMuted
            settingsBtn.ImageColor3 = currentView == "settings" and newTheme.Accent or newTheme.TextMuted
            librariesIcon.ImageColor3 = currentView == "player" and newTheme.TextMuted or newTheme.Accent
            librariesBtn.TextColor3 = currentView == "player" and newTheme.TextMuted or newTheme.Accent
            
            nowPlaying.BackgroundColor3 = newTheme.Surface
            local npStroke = nowPlaying:FindFirstChildOfClass("UIStroke")
            if npStroke then npStroke.Color = newTheme.Border end
            albumArtContainer.BackgroundColor3 = newTheme.Background
            albumArtIcon.ImageColor3 = newTheme.TextMuted
            trackName.TextColor3 = newTheme.Text
            artistName.TextColor3 = newTheme.TextMuted
            progressBg.BackgroundColor3 = newTheme.Border
            progressFill.BackgroundColor3 = newTheme.Accent
            local handleStroke = progressHandle:FindFirstChildOfClass("UIStroke")
            if handleStroke then handleStroke.Color = newTheme.Accent end
            timeLeft.TextColor3 = newTheme.TextMuted
            timeRight.TextColor3 = newTheme.TextMuted
            
            prevBtn.ImageColor3 = newTheme.Text
            playBtn.BackgroundColor3 = newTheme.Accent
            nextBtn.ImageColor3 = newTheme.Text
            shuffleBtn.ImageColor3 = self.IsShuffled and newTheme.Accent or newTheme.Text
            loopBtn.ImageColor3 = self.LoopEnabled and newTheme.Accent or newTheme.Text
            if addToLibBtn.Visible then
                addToLibBtn.BackgroundColor3 = newTheme.Accent
            end
            
            visualizerFrame.BackgroundColor3 = newTheme.Surface
            local vizStroke = visualizerFrame:FindFirstChildOfClass("UIStroke")
            if vizStroke then vizStroke.Color = newTheme.Border end
            local vizLabel = visualizerFrame:FindFirstChild("Label")
            if vizLabel then vizLabel.TextColor3 = newTheme.Text end
            
            for _, bar in ipairs(visualizerBars) do
                bar.BackgroundColor3 = newTheme.Accent
            end
            
            for _, bar in ipairs(mini.bars) do
                bar.BackgroundColor3 = newTheme.Accent
            end
            
            trackList.BackgroundColor3 = newTheme.Surface
            trackList.ScrollBarImageColor3 = newTheme.Accent
            local tlStroke = trackList:FindFirstChildOfClass("UIStroke")
            if tlStroke then tlStroke.Color = newTheme.Border end
            
            qSec.frame.BackgroundColor3 = newTheme.Surface
            local qsStroke = qSec.frame:FindFirstChildOfClass("UIStroke")
            if qsStroke then qsStroke.Color = newTheme.Border end
            qSec.title.TextColor3 = newTheme.Text
            qSec.count.TextColor3 = newTheme.TextMuted
            qSec.expandIcon.TextColor3 = newTheme.TextMuted
            qSec.clearBtn.TextColor3 = newTheme.TextMuted
            
            settingsScroll.ScrollBarImageColor3 = newTheme.Accent
            librariesScroll.ScrollBarImageColor3 = newTheme.Accent
            
            queueBtn.ImageColor3 = currentView == "queue" and newTheme.Accent or newTheme.TextMuted
            queueBadge.BackgroundColor3 = newTheme.Accent
            qSec.titleLabel.TextColor3 = newTheme.Text
            qSec.countLabel.TextColor3 = newTheme.TextMuted
            queueScroll.BackgroundColor3 = newTheme.Surface
            queueScroll.ScrollBarImageColor3 = newTheme.Accent
            local qsStroke = queueScroll:FindFirstChildOfClass("UIStroke")
            if qsStroke then qsStroke.Color = newTheme.Border end
            queueEmptyLabel.TextColor3 = newTheme.TextMuted
            
            libSearchBar.BackgroundColor3 = newTheme.Surface
            local searchStroke = libSearchBar:FindFirstChildOfClass("UIStroke")
            if searchStroke then searchStroke.Color = newTheme.Border end
            local searchIcon = libSearchBar:FindFirstChild("SearchIcon")
            if searchIcon then searchIcon.ImageColor3 = newTheme.TextMuted end
            libSearchInput.TextColor3 = newTheme.Text
            libSearchInput.PlaceholderColor3 = newTheme.TextMuted
            libSearchClearBtn.TextColor3 = newTheme.TextMuted
            
            libRefreshBtn.BackgroundColor3 = newTheme.Surface
            libRefreshIcon.ImageColor3 = newTheme.TextMuted
            local refreshStroke = libRefreshBtn:FindFirstChildOfClass("UIStroke")
            if refreshStroke then refreshStroke.Color = newTheme.Border end
            
            local hasFilters = (libState.artistFilter and libState.artistFilter ~= "") or 
                              (libState.genreFilter and libState.genreFilter ~= "") or 
                              (libState.keywordFilter and libState.keywordFilter ~= "")
            libFilterBtn.BackgroundColor3 = newTheme.Surface
            libFilterBtn.ImageColor3 = hasFilters and newTheme.Accent or newTheme.TextMuted
            local filterStroke = libFilterBtn:FindFirstChildOfClass("UIStroke")
            if filterStroke then filterStroke.Color = newTheme.Border end
            
            iconMinBtn.ImageColor3 = newTheme.TextMuted
            
            miniPlayer.BackgroundColor3 = newTheme.Background
            local miniStroke = miniPlayer:FindFirstChildOfClass("UIStroke")
            if miniStroke then miniStroke.Color = newTheme.Border end
            mini.thumbContainer.BackgroundColor3 = newTheme.Surface
            mini.thumbIcon.ImageColor3 = newTheme.TextMuted
            mini.trackName.TextColor3 = newTheme.Text
            mini.artistName.TextColor3 = newTheme.TextMuted
            mini.progressBg.BackgroundColor3 = newTheme.Border
            mini.progressFill.BackgroundColor3 = newTheme.Accent
            mini.prevBtn.ImageColor3 = newTheme.Text
            mini.playBtn.BackgroundColor3 = newTheme.Accent
            mini.nextBtn.ImageColor3 = newTheme.Text
            mini.iconExpandBtn.ImageColor3 = newTheme.TextMuted
            
            if currentView == "player" then
                refreshTrackList()
            elseif currentView == "settings" then
                refreshSettingsPage()
            elseif currentView == "libraries" then
                refreshLibrariesPage()
            end
            
            if albumArtModal and albumArtModal.Parent then
                albumArtModal.BackgroundColor3 = newTheme.Background
                local modalStroke = albumArtModal:FindFirstChildOfClass("UIStroke")
                if modalStroke then modalStroke.Color = newTheme.Border end
                
                local header = albumArtModal:FindFirstChild("Header")
                if header then
                    header.BackgroundColor3 = newTheme.Surface
                    local headerCover = albumArtModal:FindFirstChild("HeaderCover")
                    if headerCover then headerCover.BackgroundColor3 = newTheme.Surface end
                end
                
                local closeBtn = albumArtModal:FindFirstChild("CloseBtn")
                if closeBtn then
                    closeBtn.ImageColor3 = newTheme.TextMuted
                end
                
                local trackLabel = albumArtModal:FindFirstChild("TrackName")
                if trackLabel then trackLabel.TextColor3 = newTheme.Text end
                
                local artistLabel = albumArtModal:FindFirstChild("Artist")
                if artistLabel then artistLabel.TextColor3 = newTheme.TextMuted end
                
                local resizeHandle = albumArtModal:FindFirstChild("ResizeHandle")
                if resizeHandle then resizeHandle.BackgroundColor3 = newTheme.TextMuted end
            end
        end
        
        local function setWindowButtonStyle(style)
            if style == "macOS" then
                macCloseBtn.Visible = true
                macMinBtn.Visible = true
                iconCloseBtn.Visible = false
                iconMinBtn.Visible = false
                mini.macExpandBtn.Visible = true
                mini.iconExpandBtn.Visible = false
                closeBtn = macCloseClickArea
                minBtn = macMinClickArea
            else
                macCloseBtn.Visible = false
                macMinBtn.Visible = false
                iconCloseBtn.Visible = true
                iconMinBtn.Visible = true
                mini.macExpandBtn.Visible = false
                mini.iconExpandBtn.Visible = true
                closeBtn = iconCloseBtn
                minBtn = iconMinBtn
            end
            windowButtonStyle = style
        end
        
        local lastThemeName = theme.ThemeName or "Unknown"
        local registeredXanInstance = nil
        
        task.spawn(function()
            while screenGui and screenGui.Parent do
                local xan = self:GetXanInstance()
                
                if xan and xan.CurrentTheme then
                    local newTheme = getActiveTheme()
                    if newTheme.ThemeName ~= lastThemeName or newTheme.Accent ~= lastAccentColor then
                        updateTheme(newTheme)
                        lastAccentColor = newTheme.Accent
                        lastThemeName = newTheme.ThemeName
                    end
                    
                    if xan.OnThemeChanged and xan ~= registeredXanInstance then
                        registeredXanInstance = xan
                        xan:OnThemeChanged(function(newXanTheme)
                            if screenGui and screenGui.Parent then
                                local newTheme = getActiveTheme()
                                updateTheme(newTheme)
                                lastAccentColor = newTheme.Accent
                                lastThemeName = newTheme.ThemeName
                            end
                        end)
                    end
                end
                
                task.wait(0.5)
            end
        end)
        
        task.spawn(function()
            task.wait(1)
            local newStyle = self:GetWindowButtonStyle()
            if newStyle ~= windowButtonStyle then
                setWindowButtonStyle(newStyle)
            end
        end)
        
        self:LoadLibrary()
        refreshTrackList()
        updateTrackDisplay()
        updateQueueBadge()
        
        local syncWithMainGui = not self.KeepVisibleOnHide
        local cachedMainFrame = nil
        local cachedMainGui = nil
        local visibilityConnection = nil
        local guiEnabledConnection = nil
        
        local function setupVisibilitySync()
            if visibilityConnection and guiEnabledConnection then return end
            
            local mainFrame = nil
            local mainGui = nil
            local xan = self:GetXanInstance()
            if xan and xan._windows then
                for _, win in pairs(xan._windows) do
                    if win.Main and win.Main.Parent then
                        mainFrame = win.Main
                        mainGui = win.Main:FindFirstAncestorOfClass("ScreenGui")
                        break
                    end
                end
            end
            
            if not mainFrame then
                pcall(function()
                    for _, gui in pairs(CoreGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name:find("XanBar") and gui ~= screenGui then
                            mainFrame = gui:FindFirstChild("Main")
                            if mainFrame then 
                                mainGui = gui
                                break 
                            end
                        end
                    end
                end)
            end
            
            local lastSyncTime = 0
            local syncDebounce = 0.15
            
            local function syncVisibility(targetVisible)
                local now = tick()
                if now - lastSyncTime < syncDebounce then
                    return
                end
                lastSyncTime = now
                
                if syncWithMainGui and screenGui and screenGui.Parent then
                    screenGui.Enabled = targetVisible
                end
            end
            
            if mainFrame and not visibilityConnection then
                cachedMainFrame = mainFrame
                visibilityConnection = mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                    syncVisibility(mainFrame.Visible)
                end)
            end
            
            if mainGui and not guiEnabledConnection then
                cachedMainGui = mainGui
                guiEnabledConnection = mainGui:GetPropertyChangedSignal("Enabled"):Connect(function()
                    syncVisibility(mainGui.Enabled)
                end)
            end
        end
        
        task.spawn(function()
            task.wait(0.3)
            setupVisibilitySync()
            
            local attempts = 0
            while (not cachedMainFrame or not cachedMainGui) and attempts < 15 and screenGui and screenGui.Parent do
                task.wait(0.5)
                setupVisibilitySync()
                attempts = attempts + 1
            end
        end)
        
        ui.Refresh = refreshTrackList
        ui.Show = function() 
            screenGui.Enabled = true 
            main.Visible = true
        end
        ui.Hide = function() 
            screenGui.Enabled = false 
            main.Visible = false
        end
        ui.Toggle = function() 
            main.Visible = not main.Visible
            screenGui.Enabled = main.Visible
        end
        ui.Destroy = function() 
            self:Stop()
            self:CleanupPreviewCache()
            if vizState.conn then
                vizState.conn:Disconnect()
                vizState.conn = nil
            end
            if visibilityConnection then 
                visibilityConnection:Disconnect() 
                visibilityConnection = nil
            end
            if guiEnabledConnection then
                guiEnabledConnection:Disconnect()
                guiEnabledConnection = nil
            end
            screenGui:Destroy() 
        end
        ui.UpdateTheme = updateTheme
        ui.SetButtonStyle = setWindowButtonStyle
        ui.GetCurrentTheme = function() return theme end
        ui.SetSyncWithMainGui = function(sync) syncWithMainGui = sync end
        
        screenGui.Destroying:Connect(function()
            pcall(function() self:Stop() end)
            pcall(function() self:CleanupPreviewCache() end)
            if vizState.conn then
                pcall(function() vizState.conn:Disconnect() end)
                vizState.conn = nil
            end
            if visibilityConnection then 
                pcall(function() visibilityConnection:Disconnect() end)
                visibilityConnection = nil
            end
            if guiEnabledConnection then
                pcall(function() guiEnabledConnection:Disconnect() end)
                guiEnabledConnection = nil
            end
        end)
        
        return ui
    end
    
    function MusicPlayer:CreateFloatingButton(options)
        options = options or {}
        local size = options.Size or 56
        local pos = options.Position or UDim2.new(1, -50, 0, 60)
        
        local offBg = Color3.fromRGB(0, 0, 0)
        local offBgTransparency = 0.45
        local onBg = Color3.fromRGB(255, 255, 255)
        local onBgTransparency = 0.15
        local iconColor = Color3.new(1, 1, 1)
        local iconColorOn = Color3.fromRGB(30, 30, 30)
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "XanMusicMobileBtn"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 160
        screenGui.IgnoreGuiInset = true
        pcall(function() screenGui.Parent = CoreGui end)
        if not screenGui.Parent then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local isOpen = false
        
        local btn = Create("TextButton", {
            Name = "MusicButton",
            BackgroundColor3 = offBg,
            BackgroundTransparency = offBgTransparency,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = pos,
            Size = UDim2.new(0, size, 0, size),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 100,
            Parent = screenGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, size * 0.5, 0, size * 0.5),
                Image = "rbxassetid://102923134853209",
                ImageColor3 = iconColor,
                ZIndex = 101
            })
        })
        
        local repositionIndicator = Create("Frame", {
            Name = "RepositionIndicator",
            BackgroundColor3 = Color3.fromRGB(255, 180, 80),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, -16),
            Size = UDim2.new(0, 6, 0, 6),
            Visible = false,
            ZIndex = 102,
            Parent = btn
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        
        local function updateVisual()
            btn.BackgroundColor3 = isOpen and onBg or offBg
            btn.BackgroundTransparency = isOpen and onBgTransparency or offBgTransparency
            local iconObj = btn:FindFirstChild("Icon")
            if iconObj then
                iconObj.ImageColor3 = isOpen and iconColorOn or iconColor
            end
        end
        
        local ui = nil
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local dragThreshold = 8
        local hasDragged = false
        
        local connections = {}
        
        table.insert(connections, btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                hasDragged = false
                dragStart = input.Position
                startPos = btn.Position
            end
        end))
        
        table.insert(connections, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                if delta.Magnitude > dragThreshold then
                    hasDragged = true
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end))
        
        table.insert(connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragging and not hasDragged then
                    if self._ui then
                        self._ui.Toggle()
                        isOpen = not isOpen
                        updateVisual()
                    elseif not ui then
                        ui = self:CreateUI(options)
                        if ui then 
                            ui.SetSyncWithMainGui(false)
                            isOpen = true
                            updateVisual()
                        end
                    else
                        ui.Toggle()
                        isOpen = not isOpen
                        updateVisual()
                    end
                end
                dragging = false
            end
        end))
        
        return {
            ScreenGui = screenGui,
            Button = btn,
            GetUI = function() return ui end,
            Destroy = function()
                for _, conn in ipairs(connections) do
                    pcall(function() conn:Disconnect() end)
                end
                connections = {}
                if ui then pcall(function() ui.Destroy() end) end
                pcall(function() screenGui:Destroy() end)
            end,
            Show = function() screenGui.Enabled = true end,
            Hide = function() screenGui.Enabled = false end,
            Toggle = function() screenGui.Enabled = not screenGui.Enabled end,
            SetOpen = function(open)
                isOpen = open
                updateVisual()
            end
        }
    end
    
    if Xan and Xan.RegisterPlugin then
        Xan.RegisterPlugin("MusicPlayer", MusicPlayer)
        Xan.RegisterPlugin("music_player", MusicPlayer)
    end
    
    _G.XanMusicPlayerInstance = MusicPlayer
    
    MusicPlayer:LoadLibrary()
    
    task.spawn(function()
        task.wait(0.1)
        
        MusicPlayer._ui = MusicPlayer:CreateUI()
        _G.XanMusicPlayerUI = MusicPlayer._ui
        
        if IsMobile then
            if MusicPlayer._ui then
                if MusicPlayer._ui.SetSyncWithMainGui then
                    MusicPlayer._ui.SetSyncWithMainGui(false)
                end
                if MusicPlayer._ui.Hide then
                    MusicPlayer._ui.Hide()
                end
            end
            
            MusicPlayer._floatingBtn = MusicPlayer:CreateFloatingButton({
                Position = UDim2.new(1, -50, 0, 50),
                Size = 48
            })
        end
    end)
    
    function MusicPlayer:Show()
        if self._ui then
            self._ui.Show()
        end
    end
    
    function MusicPlayer:Hide()
        if self._ui then
            self._ui.Hide()
        end
    end
    
    function MusicPlayer:ToggleUI()
        if self._ui then
            self._ui.Toggle()
        end
    end
    
    function MusicPlayer:Destroy()
        self:Stop()
        self:CleanupPreviewCache()
        
        for taskId, conn in pairs(_fallbackConnections) do
            pcall(function() conn:Disconnect() end)
        end
        _fallbackConnections = {}
        
        if self._unloadConnection then
            pcall(function() self._unloadConnection:Disconnect() end)
            self._unloadConnection = nil
        end
        
        if self._toggleConnection then
            pcall(function() self._toggleConnection:Disconnect() end)
            self._toggleConnection = nil
        end
        
        if self.CuteVisualizer then
            pcall(function() self.CuteVisualizer:Destroy() end)
            self.CuteVisualizer = nil
            self.CuteVisualizerEnabled = false
        end
        
        if self._floatingBtn then
            pcall(function() self._floatingBtn.Destroy() end)
            self._floatingBtn = nil
        end
        
        if self._ui then
            pcall(function() self._ui.Destroy() end)
            self._ui = nil
        end
        
        _G.XanMusicPlayerUI = nil
        
        if Xan and Xan.Plugins then
            Xan.Plugins["music_player"] = nil
            Xan.Plugins["MusicPlayer"] = nil
        end
    end
    
    function MusicPlayer:Unload()
        self:Destroy()
    end
    
    local function setupKeyListeners()
        local unloadKey = (Xan and Xan.UnloadKey) or Enum.KeyCode.End
        
        if MusicPlayer._unloadConnection then
            pcall(function() MusicPlayer._unloadConnection:Disconnect() end)
        end
        
        if MusicPlayer._toggleConnection then
            pcall(function() MusicPlayer._toggleConnection:Disconnect() end)
        end
        
        MusicPlayer._unloadConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == unloadKey then
                MusicPlayer:Destroy()
            end
        end)
        
        if not IsMobile then
            MusicPlayer._toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                local toggleKey = (Xan and Xan.ToggleKey) or Enum.KeyCode.RightShift
                if input.KeyCode == toggleKey then
                    MusicPlayer:ToggleUI()
                end
            end)
        end
    end
    
    task.spawn(function()
        task.wait(0.5)
        setupKeyListeners()
    end)
    
    return MusicPlayer
end

pcall(function()
    if _G.XanMusicPlayerInstance and _G.XanMusicPlayerInstance.Destroy then
        _G.XanMusicPlayerInstance:Destroy()
    end
end)
_G.XanMusicPlayerInstance = nil
_G.XanMusicPlayerUI = nil

local XanGlobal = rawget(_G, "Xan") or _G.Xan
if XanGlobal then
    return MusicPlayerInit(XanGlobal)
end
return MusicPlayerInit