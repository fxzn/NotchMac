//
//  MediaTrack.swift
//  NotchMac
//

import Foundation

/// Domain model representing the currently playing track in Spotify.
nonisolated struct MediaTrack: Equatable, Sendable {
    let title: String
    let artist: String
    let album: String
    let artworkURL: URL?
    let isPlaying: Bool
    let isSpotifyRunning: Bool

    static let idle = MediaTrack(
        title: "Not Playing",
        artist: "Open Spotify to play music",
        album: "",
        artworkURL: nil,
        isPlaying: false,
        isSpotifyRunning: false
    )
}
