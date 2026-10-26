//
//  MediaTrack.swift
//  NotchMac
//

import Foundation

/// Supported media platforms for Now Playing detection.
nonisolated enum MediaPlatform: String, Equatable, Sendable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    case youtube = "YouTube"
    case netflix = "Netflix"
    case browser = "Web Video"
    case idle = "No Media"
}

/// Domain model representing the currently playing audio or video track across native apps and browsers.
nonisolated struct MediaTrack: Equatable, Sendable {
    let title: String
    let artist: String
    let album: String
    let artworkURL: URL?
    let isPlaying: Bool
    let platform: MediaPlatform
    let sourceAppName: String
    let bundleIdentifier: String?

    var isActiveMedia: Bool {
        platform != .idle
    }

    static let idle = MediaTrack(
        title: "Nothing Playing",
        artist: "Play Spotify, Music, YouTube, or Netflix",
        album: "",
        artworkURL: nil,
        isPlaying: false,
        platform: .idle,
        sourceAppName: "Media Idle",
        bundleIdentifier: nil
    )
}
