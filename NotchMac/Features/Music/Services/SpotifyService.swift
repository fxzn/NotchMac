//
//  SpotifyService.swift
//  NotchMac
//

import Foundation

/// Protocol for abstracting multi-platform media playback operations (Spotify, Apple Music, YouTube, Netflix, Browser).
nonisolated protocol SpotifyServiceProtocol: Sendable {
    func fetchCurrentTrack() async -> MediaTrack
    func playPause() async
    func nextTrack() async
    func previousTrack() async
}

/// Service that detects and controls media across Spotify, Apple Music, and Web Browsers (YouTube, Netflix, Web Video) on a background queue.
nonisolated final class SpotifyService: SpotifyServiceProtocol, Sendable {
    init() {}

    /// Fetches the current active media track across Spotify, Apple Music, and Browsers (Chrome, Arc, Brave, Safari, Edge).
    func fetchCurrentTrack() async -> MediaTrack {
        // 1. Check Spotify & Apple Music first
        if let nativeTrack = await fetchNativeMusicApps(), nativeTrack.isPlaying {
            return nativeTrack
        }

        // 2. Check Web Browsers (YouTube, Netflix, Web Video)
        if let browserTrack = await fetchBrowserMedia() {
            return browserTrack
        }

        // 3. Fallback to paused Spotify/Apple Music if available
        if let pausedNative = await fetchNativeMusicApps() {
            return pausedNative
        }

        return .idle
    }

    private func fetchNativeMusicApps() async -> MediaTrack? {
        let scriptSource = """
        if application "Spotify" is running then
            tell application "Spotify"
                set currentState to player state as string
                if currentState is "playing" or currentState is "paused" then
                    set trackName to name of current track
                    set trackArtist to artist of current track
                    set trackAlbum to album of current track
                    set artUrl to artwork url of current track
                    return "SPOTIFY||" & currentState & "||" & trackName & "||" & trackArtist & "||" & trackAlbum & "||" & artUrl
                end if
            end tell
        end if

        if application "Music" is running then
            tell application "Music"
                set currentState to player state as string
                if currentState is "playing" or currentState is "paused" then
                    set trackName to name of current track
                    set trackArtist to artist of current track
                    set trackAlbum to album of current track
                    return "MUSIC||" & currentState & "||" & trackName & "||" & trackArtist & "||" & trackAlbum & "||"
                end if
            end tell
        end if

        return "NONE"
        """

        guard let output = await runAppleScript(scriptSource), output != "NONE" else {
            return nil
        }

        let parts = output.components(separatedBy: "||")
        guard parts.count >= 6 else { return nil }

        let sourceTag = parts[0]
        let state = parts[1].lowercased()
        let title = parts[2].isEmpty ? "Unknown Title" : parts[2]
        let artist = parts[3].isEmpty ? "Unknown Artist" : parts[3]
        let album = parts[4]
        let artworkURLString = parts[5]
        let artworkURL = artworkURLString.isEmpty ? nil : URL(string: artworkURLString)

        if sourceTag == "SPOTIFY" {
            return MediaTrack(
                title: title,
                artist: artist,
                album: album,
                artworkURL: artworkURL,
                isPlaying: state == "playing",
                platform: .spotify,
                sourceAppName: "Spotify",
                bundleIdentifier: "com.spotify.client"
            )
        } else {
            return MediaTrack(
                title: title,
                artist: artist,
                album: album,
                artworkURL: nil,
                isPlaying: state == "playing",
                platform: .appleMusic,
                sourceAppName: "Apple Music",
                bundleIdentifier: "com.apple.Music"
            )
        }
    }

    private func fetchBrowserMedia() async -> MediaTrack? {
        let scriptSource = """
        set browserCandidates to {¬
            {"Google Chrome", "com.google.Chrome"}, ¬
            {"Arc", "company.thebrowser.Browser"}, ¬
            {"Brave Browser", "com.brave.Browser"}, ¬
            {"Microsoft Edge", "com.microsoft.edgemac"} ¬
        }

        repeat with candidate in browserCandidates
            set appName to item 1 of candidate
            set bundleID to item 2 of candidate
            if application appName is running then
                try
                    using terms from application "Google Chrome"
                        tell application appName
                            if (count of windows) > 0 then
                                set tabTitle to title of active tab of front window
                                set tabURL to URL of active tab of front window
                                if tabURL contains "youtube.com/watch" or tabURL contains "youtu.be/" or tabURL contains "music.youtube.com" or tabURL contains "netflix.com/watch" or tabURL contains "twitch.tv/" or tabURL contains "bilibili.com/video" or tabURL contains "vimeo.com/" then
                                    return appName & "||" & bundleID & "||" & tabTitle & "||" & tabURL
                                end if
                            end if
                        end tell
                    end using terms from
                end try
            end if
        end repeat

        if application "Safari" is running then
            try
                tell application "Safari"
                    if (count of windows) > 0 then
                        set tabTitle to name of current tab of front window
                        set tabURL to URL of current tab of front window
                        if tabURL contains "youtube.com/watch" or tabURL contains "youtu.be/" or tabURL contains "music.youtube.com" or tabURL contains "netflix.com/watch" or tabURL contains "twitch.tv/" or tabURL contains "bilibili.com/video" or tabURL contains "vimeo.com/" then
                            return "Safari||com.apple.Safari||" & tabTitle & "||" & tabURL
                        end if
                    end if
                end tell
            end try
        end if

        return "NONE"
        """

        guard let output = await runAppleScript(scriptSource), output != "NONE" else {
            return nil
        }

        let parts = output.components(separatedBy: "||")
        guard parts.count >= 4 else { return nil }

        let browserName = parts[0]
        let bundleID = parts[1]
        let rawTitle = parts[2]
        let tabURL = parts[3]

        let lowerURL = tabURL.lowercased()
        let platform: MediaPlatform
        let cleanedTitle: String
        let subtitle: String
        var artworkURL: URL? = nil

        if lowerURL.contains("youtube.com") || lowerURL.contains("youtu.be") {
            platform = .youtube
            cleanedTitle = rawTitle
                .replacingOccurrences(of: " - YouTube Music", with: "")
                .replacingOccurrences(of: " - YouTube", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            subtitle = "YouTube • \(browserName)"
            if let videoID = extractYouTubeVideoID(from: tabURL) {
                artworkURL = URL(string: "https://i.ytimg.com/vi/\(videoID)/mqdefault.jpg")
            }
        } else if lowerURL.contains("netflix.com") {
            platform = .netflix
            cleanedTitle = rawTitle
                .replacingOccurrences(of: " - Netflix", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            subtitle = "Netflix • \(browserName)"
        } else {
            platform = .browser
            cleanedTitle = rawTitle
            subtitle = "Web Stream • \(browserName)"
        }

        return MediaTrack(
            title: cleanedTitle.isEmpty ? platform.rawValue : cleanedTitle,
            artist: subtitle,
            album: browserName,
            artworkURL: artworkURL,
            isPlaying: true,
            platform: platform,
            sourceAppName: browserName,
            bundleIdentifier: bundleID
        )
    }

    private func extractYouTubeVideoID(from urlString: String) -> String? {
        guard let components = URLComponents(string: urlString) else { return nil }
        if let vParam = components.queryItems?.first(where: { $0.name == "v" })?.value, !vParam.isEmpty {
            return vParam
        }
        if components.host?.contains("youtu.be") == true {
            let pathID = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return pathID.isEmpty ? nil : pathID
        }
        return nil
    }

    func playPause() async {
        _ = await runAppleScript("""
        if application "Spotify" is running then
            tell application "Spotify"
                if (player state as string) is "playing" or (player state as string) is "paused" then
                    playpause
                    return
                end if
            end tell
        end if
        if application "Music" is running then
            tell application "Music"
                if (player state as string) is "playing" or (player state as string) is "paused" then
                    playpause
                    return
                end if
            end tell
        end if
        """)
    }

    func nextTrack() async {
        _ = await runAppleScript("""
        if application "Spotify" is running then
            tell application "Spotify"
                if (player state as string) is "playing" or (player state as string) is "paused" then
                    next track
                    return
                end if
            end tell
        end if
        if application "Music" is running then
            tell application "Music"
                if (player state as string) is "playing" or (player state as string) is "paused" then
                    next track
                    return
                end if
            end tell
        end if
        """)
    }

    func previousTrack() async {
        _ = await runAppleScript("""
        if application "Spotify" is running then
            tell application "Spotify"
                if (player state as string) is "playing" or (player state as string) is "paused" then
                    previous track
                    return
                end if
            end tell
        end if
        if application "Music" is running then
            tell application "Music"
                if (player state as string) is "playing" or (player state as string) is "paused" then
                    previous track
                    return
                end if
            end tell
        end if
        """)
    }

    /// Executes an AppleScript strictly on DispatchQueue.global(qos: .userInitiated) to avoid main thread stutter.
    private func runAppleScript(_ source: String) async -> String? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var errorDict: NSDictionary?
                let script = NSAppleScript(source: source)
                let descriptor = script?.executeAndReturnError(&errorDict)
                if errorDict != nil {
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: descriptor?.stringValue)
                }
            }
        }
    }
}
