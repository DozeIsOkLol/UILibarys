#!/usr/bin/env python3
"""
Xan Personal Media Server
=========================

A lightweight personal media server for streaming your own music files.
Designed for use with the Xan Music Player.

IMPORTANT LEGAL NOTICE:
-----------------------
This software is provided for personal, non-commercial use only.
It is intended for streaming your own legally obtained music files
(personal backups, royalty-free music, or content you have rights to).

By using this software, you agree:
  - To only stream content you have the legal right to access
  - That you are solely responsible for the content you host
  - That Xan UI / xan.bar provides the tool, not the content
  - To comply with all applicable copyright laws in your jurisdiction

The developers of Xan UI are not responsible for any misuse of this software.
This tool has substantial non-infringing uses including personal music backups,
streaming royalty-free/Creative Commons music, and original content.

SETUP:
------
1. Install dependencies: pip install aiohttp
2. Place your MP3 files in the ./music folder
3. Run: python music_server_dist.py
4. Add http://localhost:8080 as an API source in Xan Music Player

Your music files should be named: Artist - Song Title.mp3
The server will automatically parse the filename for metadata.

For album artwork, you can optionally create a file: Artist - Song Title.jpg
in the same folder, or set up your own asset IDs in the config.
"""

import asyncio
import os
import json
import hashlib
import mimetypes
from pathlib import Path
from datetime import datetime

try:
    from aiohttp import web
except ImportError:
    print("Please install aiohttp: pip install aiohttp")
    exit(1)

CONFIG = {
    "host": "127.0.0.1",
    "port": 8080,
    "music_folder": "./music",
    "allowed_extensions": [".mp3", ".ogg", ".wav", ".flac", ".m4a"],
    "scan_on_startup": True
}

LIBRARY = []
LIBRARY_INDEX = {}


def parse_filename(filepath):
    """Parse artist and title from filename: 'Artist - Title.mp3'"""
    name = Path(filepath).stem
    
    if " - " in name:
        parts = name.split(" - ", 1)
        artist = parts[0].strip()
        title = parts[1].strip()
    else:
        artist = "Unknown Artist"
        title = name.strip()
    
    return artist, title


def generate_id(filepath):
    """Generate a unique ID for a track based on filepath"""
    return hashlib.md5(filepath.encode()).hexdigest()[:12]


def scan_music_folder():
    """Scan the music folder and build the library"""
    global LIBRARY, LIBRARY_INDEX
    LIBRARY = []
    LIBRARY_INDEX = {}
    
    music_path = Path(CONFIG["music_folder"])
    if not music_path.exists():
        music_path.mkdir(parents=True, exist_ok=True)
        print(f"Created music folder: {music_path.absolute()}")
        return
    
    for ext in CONFIG["allowed_extensions"]:
        for filepath in music_path.glob(f"*{ext}"):
            artist, title = parse_filename(filepath)
            track_id = generate_id(str(filepath))
            
            track = {
                "id": track_id,
                "song_title": title,
                "title": title,
                "artist_name": artist,
                "artist": artist,
                "album_name": "",
                "album": "",
                "genre": "",
                "duration": 0,
                "file_path": str(filepath),
                "file_url": f"/stream/{track_id}",
                "image_asset_id": "",
                "image_url": "",
                "streams": 0,
                "plays": 0,
                "added_at": datetime.now().isoformat()
            }
            
            LIBRARY.append(track)
            LIBRARY_INDEX[track_id] = track
    
    print(f"Scanned {len(LIBRARY)} tracks from {music_path.absolute()}")


class PersonalMusicServer:
    def __init__(self):
        self.app = web.Application(middlewares=[self.cors_middleware])
        self.setup_routes()
    
    @web.middleware
    async def cors_middleware(self, request, handler):
        if request.method == "OPTIONS":
            return web.Response(headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization"
            })
        response = await handler(request)
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    
    def setup_routes(self):
        self.app.router.add_get("/", self.health)
        self.app.router.add_get("/api/browse", self.browse)
        self.app.router.add_get("/api/search", self.search)
        self.app.router.add_get("/api/song/{id}", self.get_song)
        self.app.router.add_get("/api/genres", self.get_genres)
        self.app.router.add_get("/api/artists", self.get_artists)
        self.app.router.add_get("/api/rescan", self.rescan)
        self.app.router.add_get("/stream/{id}", self.stream)
        self.app.router.add_post("/api/play/{id}", self.play)
        self.app.router.add_get("/api/play/{id}", self.play)
        self.app.router.add_route("*", "/api", self.universal_api)
    
    def resp(self, data, error=None):
        result = {
            "_meta": {
                "service": "Xan Personal Media Server",
                "legal": "Personal use only. User is responsible for content.",
                "version": "1.0.0"
            },
            "data": data,
            "error": error
        }
        return web.json_response(result)
    
    def browse_resp(self, tracks, total, limit, offset, extra=None):
        result = {
            "_meta": {
                "service": "Xan Personal Media Server",
                "legal": "Personal use only. User is responsible for content."
            },
            "success": True,
            "tracks": tracks,
            "total_count": total,
            "current_count": len(tracks),
            "limit": limit,
            "offset": offset,
            "available_genres": self.get_genre_list(),
            "leets_picks_count": 0,
            "trending_count": 0
        }
        if extra:
            result.update(extra)
        return web.json_response(result)
    
    def get_genre_list(self):
        genres = set()
        for track in LIBRARY:
            if track.get("genre"):
                genres.add(track["genre"])
        return sorted(list(genres))
    
    async def health(self, r):
        return web.json_response({
            "status": "ok",
            "server": "Xan Personal Media Server",
            "tracks": len(LIBRARY),
            "legal": "For personal use only. Stream your own music files."
        })
    
    async def browse(self, r):
        limit = min(500, max(1, int(r.query.get("limit", 100))))
        offset = max(0, int(r.query.get("offset", 0)))
        search = r.query.get("search", "").lower()
        genre = r.query.get("genre", "").lower()
        
        filtered = LIBRARY
        
        if search:
            filtered = [t for t in filtered if 
                search in t["title"].lower() or 
                search in t["artist"].lower() or
                search in t.get("album", "").lower()]
        
        if genre:
            filtered = [t for t in filtered if genre in t.get("genre", "").lower()]
        
        total = len(filtered)
        tracks = filtered[offset:offset + limit]
        
        return self.browse_resp(tracks, total, limit, offset)
    
    async def search(self, r):
        q = r.query.get("q", r.query.get("query", "")).lower()
        if not q:
            return self.resp(None, "missing query")
        
        limit = min(500, max(1, int(r.query.get("limit", 100))))
        offset = max(0, int(r.query.get("offset", 0)))
        
        results = [t for t in LIBRARY if 
            q in t["title"].lower() or 
            q in t["artist"].lower() or
            q in t.get("album", "").lower() or
            q in t.get("genre", "").lower()]
        
        total = len(results)
        tracks = results[offset:offset + limit]
        
        return self.resp({
            "songs": tracks,
            "tracks": tracks,
            "total": total,
            "query": q
        })
    
    async def get_song(self, r):
        track_id = r.match_info.get("id", "")
        if track_id in LIBRARY_INDEX:
            return self.resp(LIBRARY_INDEX[track_id])
        return self.resp(None, "not found")
    
    async def get_genres(self, r):
        return self.resp(self.get_genre_list())
    
    async def get_artists(self, r):
        artists = {}
        for track in LIBRARY:
            artist = track["artist"]
            if artist not in artists:
                artists[artist] = 0
            artists[artist] += 1
        
        result = [{"artist": k, "songs": v} for k, v in sorted(artists.items())]
        return self.resp(result)
    
    async def rescan(self, r):
        scan_music_folder()
        return self.resp({"success": True, "tracks": len(LIBRARY)})
    
    async def stream(self, r):
        track_id = r.match_info.get("id", "")
        if track_id not in LIBRARY_INDEX:
            return web.Response(status=404, text="Track not found")
        
        track = LIBRARY_INDEX[track_id]
        filepath = track["file_path"]
        
        if not os.path.exists(filepath):
            return web.Response(status=404, text="File not found")
        
        content_type, _ = mimetypes.guess_type(filepath)
        if not content_type:
            content_type = "audio/mpeg"
        
        return web.FileResponse(filepath, headers={
            "Content-Type": content_type,
            "Accept-Ranges": "bytes"
        })
    
    async def play(self, r):
        track_id = r.match_info.get("id", "")
        if track_id in LIBRARY_INDEX:
            LIBRARY_INDEX[track_id]["plays"] = LIBRARY_INDEX[track_id].get("plays", 0) + 1
            LIBRARY_INDEX[track_id]["streams"] = LIBRARY_INDEX[track_id].get("streams", 0) + 1
        return self.resp({"success": True})
    
    async def universal_api(self, r):
        try:
            if r.method == "POST":
                try:
                    body = await r.json()
                except:
                    body = dict(r.query)
            else:
                body = dict(r.query)
            
            action = body.get("action", "")
            
            class FakeReq:
                query = body
                match_info = {}
            
            fake = FakeReq()
            
            if action == "get_songs" or action == "browse":
                return await self.browse(fake)
            elif action == "search":
                return await self.search(fake)
            elif action == "get_genres":
                return await self.get_genres(fake)
            elif action == "get_artists":
                return await self.get_artists(fake)
            elif action == "rescan":
                return await self.rescan(fake)
            elif action == "ping":
                return self.resp({"pong": True})
            else:
                return self.resp(None, f"unknown action: {action}")
        except Exception as e:
            return self.resp(None, str(e))


async def main():
    if CONFIG["scan_on_startup"]:
        scan_music_folder()
    
    server = PersonalMusicServer()
    runner = web.AppRunner(server.app)
    await runner.setup()
    site = web.TCPSite(runner, CONFIG["host"], CONFIG["port"])
    await site.start()
    
    print("=" * 60)
    print("Xan Personal Media Server")
    print("=" * 60)
    print("")
    print("LEGAL NOTICE:")
    print("  This server is for personal use with your own music files.")
    print("  You are responsible for ensuring you have rights to stream")
    print("  any content you add to the music folder.")
    print("")
    print(f"Server running at: http://{CONFIG['host']}:{CONFIG['port']}")
    print(f"Music folder: {Path(CONFIG['music_folder']).absolute()}")
    print(f"Tracks loaded: {len(LIBRARY)}")
    print("")
    print("ENDPOINTS:")
    print("  GET /api/browse      - List all tracks")
    print("  GET /api/search?q=   - Search tracks")
    print("  GET /api/genres      - List genres")
    print("  GET /api/artists     - List artists")
    print("  GET /api/rescan      - Rescan music folder")
    print("  GET /stream/{id}     - Stream a track")
    print("")
    print("SETUP:")
    print(f"  1. Add MP3 files to: {Path(CONFIG['music_folder']).absolute()}")
    print("  2. Name files as: Artist - Song Title.mp3")
    print("  3. In Xan Music Player, add this URL as an API source")
    print("")
    print("=" * 60)
    
    await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())

