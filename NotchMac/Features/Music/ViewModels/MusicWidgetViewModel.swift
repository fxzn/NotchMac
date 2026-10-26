//
//  MusicWidgetViewModel.swift
//  NotchMac
//

import Combine
import Foundation

/// ViewModel managing Spotify playback state and controls on the MainActor.
@MainActor
final class MusicWidgetViewModel: ObservableObject {
    @Published private(set) var currentTrack: MediaTrack = .idle
    @Published private(set) var isRefreshing: Bool = false

    private let spotifyService: any SpotifyServiceProtocol
    private var playbackObserver: NSObjectProtocol?

    init(spotifyService: any SpotifyServiceProtocol = SpotifyService()) {
        self.spotifyService = spotifyService
        observeSpotifyNotifications()
        refreshTrack()
    }

    /// Queries Spotify in the background and updates the UI on the MainActor.
    func refreshTrack() {
        Task {
            isRefreshing = true
            let track = await spotifyService.fetchCurrentTrack()
            currentTrack = track
            isRefreshing = false
        }
    }

    func togglePlayPause() {
        Task {
            await spotifyService.playPause()
            let track = await spotifyService.fetchCurrentTrack()
            currentTrack = track
        }
    }

    func nextTrack() {
        Task {
            await spotifyService.nextTrack()
            let track = await spotifyService.fetchCurrentTrack()
            currentTrack = track
        }
    }

    func previousTrack() {
        Task {
            await spotifyService.previousTrack()
            let track = await spotifyService.fetchCurrentTrack()
            currentTrack = track
        }
    }

    /// Listens to Spotify's distributed playback notification for zero-CPU idle updates.
    private func observeSpotifyNotifications() {
        playbackObserver = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshTrack()
            }
        }
    }

    deinit {
        if let playbackObserver {
            DistributedNotificationCenter.default().removeObserver(playbackObserver)
        }
    }
}
