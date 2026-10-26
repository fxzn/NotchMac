//
//  MusicWidgetViewModel.swift
//  NotchMac
//

import Combine
import Foundation

/// ViewModel managing multi-platform media playback state and controls on the MainActor.
@MainActor
final class MusicWidgetViewModel: ObservableObject {
    @Published private(set) var currentTrack: MediaTrack = .idle

    private let spotifyService: any SpotifyServiceProtocol
    private var spotifyObserver: NSObjectProtocol?
    private var appleMusicObserver: NSObjectProtocol?

    init(spotifyService: any SpotifyServiceProtocol = SpotifyService()) {
        self.spotifyService = spotifyService
        observeMediaNotifications()
        refreshTrack()
    }

    /// Queries active media players in the background and updates the UI on the MainActor only if track state changed.
    func refreshTrack() {
        Task {
            let track = await spotifyService.fetchCurrentTrack()
            if track != currentTrack {
                currentTrack = track
            }
        }
    }

    func togglePlayPause() {
        Task {
            await spotifyService.playPause()
            let track = await spotifyService.fetchCurrentTrack()
            if track != currentTrack {
                currentTrack = track
            }
        }
    }

    func nextTrack() {
        Task {
            await spotifyService.nextTrack()
            let track = await spotifyService.fetchCurrentTrack()
            if track != currentTrack {
                currentTrack = track
            }
        }
    }

    func previousTrack() {
        Task {
            await spotifyService.previousTrack()
            let track = await spotifyService.fetchCurrentTrack()
            if track != currentTrack {
                currentTrack = track
            }
        }
    }

    /// Listens to Spotify and Apple Music distributed playback notifications for zero-CPU idle updates.
    private func observeMediaNotifications() {
        spotifyObserver = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshTrack()
            }
        }

        appleMusicObserver = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshTrack()
            }
        }
    }

    deinit {
        if let spotifyObserver {
            DistributedNotificationCenter.default().removeObserver(spotifyObserver)
        }
        if let appleMusicObserver {
            DistributedNotificationCenter.default().removeObserver(appleMusicObserver)
        }
    }
}
