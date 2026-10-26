//
//  SpotifyService.swift
//  NotchMac
//

import Foundation

/// Protocol for abstracting media playback operations.
nonisolated protocol SpotifyServiceProtocol: Sendable {
    func fetchCurrentTrack() async -> MediaTrack
    func playPause() async
    func nextTrack() async
    func previousTrack() async
}

/// Service that bridges with Spotify via NSAppleScript on a background queue.
nonisolated final class SpotifyService: SpotifyServiceProtocol, Sendable {
    init() {}

    /// Fetches the current track metadata from Spotify using AppleScript on a background queue.
    func fetchCurrentTrack() async -> MediaTrack {
        let scriptSource = """
        if application "Spotify" is running then
            tell application "Spotify"
                set currentState to player state as string
                if currentState is "playing" or currentState is "paused" then
                    set trackName to name of current track
                    set trackArtist to artist of current track
                    set trackAlbum to album of current track
                    set artUrl to artwork url of current track
                    return "RUNNING||" & currentState & "||" & trackName & "||" & trackArtist & "||" & trackAlbum & "||" & artUrl
                else
                    return "RUNNING||stopped||||||"
                end if
            end tell
        else
            return "NOT_RUNNING"
        end if
        """

        guard let output = await runAppleScript(scriptSource) else {
            return .idle
        }

        if output == "NOT_RUNNING" {
            return .idle
        }

        let parts = output.components(separatedBy: "||")
        guard parts.count >= 6 else {
            return MediaTrack(
                title: "Spotify Ready",
                artist: "Select a track to play",
                album: "",
                artworkURL: nil,
                isPlaying: false,
                isSpotifyRunning: true
            )
        }

        let state = parts[1].lowercased()
        let title = parts[2].isEmpty ? "Spotify" : parts[2]
        let artist = parts[3].isEmpty ? "Unknown Artist" : parts[3]
        let album = parts[4]
        let artworkURLString = parts[5]
        let artworkURL = artworkURLString.isEmpty ? nil : URL(string: artworkURLString)

        return MediaTrack(
            title: title,
            artist: artist,
            album: album,
            artworkURL: artworkURL,
            isPlaying: state == "playing",
            isSpotifyRunning: true
        )
    }

    func playPause() async {
        _ = await runAppleScript("""
        if application "Spotify" is running then
            tell application "Spotify" to playpause
        end if
        """)
    }

    func nextTrack() async {
        _ = await runAppleScript("""
        if application "Spotify" is running then
            tell application "Spotify" to next track
        end if
        """)
    }

    func previousTrack() async {
        _ = await runAppleScript("""
        if application "Spotify" is running then
            tell application "Spotify" to previous track
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
