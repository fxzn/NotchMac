//
//  MusicCardView.swift
//  NotchMac
//

import SwiftUI

/// Displays the Spotify Now Playing widget card inside the expanded Notch.
struct MusicCardView: View {
    @ObservedObject var viewModel: MusicWidgetViewModel

    var body: some View {
        GlassCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Artwork + Track Info
                HStack(spacing: 12) {
                    artworkView

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(viewModel.currentTrack.isPlaying ? NotchTheme.spotifyAccent : Color.white.opacity(0.3))
                                .frame(width: 6, height: 6)

                            Text(viewModel.currentTrack.isPlaying ? "SPOTIFY • PLAYING" : "SPOTIFY")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.55))
                                .tracking(0.6)
                        }

                        Text(viewModel.currentTrack.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(viewModel.currentTrack.artist)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.white.opacity(0.65))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }

                Spacer(minLength: 0)

                // Playback Controls
                HStack(spacing: 18) {
                    Button(action: viewModel.previousTrack) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)

                    Button(action: viewModel.togglePlayPause) {
                        Image(systemName: viewModel.currentTrack.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    Button(action: viewModel.nextTrack) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: viewModel.refreshTrack) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .buttonStyle(.plain)
                    .help("Refresh Spotify status")
                }
            }
        }
    }

    @ViewBuilder
    private var artworkView: some View {
        if let url = viewModel.currentTrack.artworkURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    placeholderArtwork
                }
            }
            .frame(width: 46, height: 46)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            placeholderArtwork
        }
    }

    private var placeholderArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            NotchTheme.spotifyAccent.opacity(0.35),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: viewModel.currentTrack.isPlaying ? "waveform" : "music.note")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(viewModel.currentTrack.isPlaying ? NotchTheme.spotifyAccent : .white.opacity(0.7))
        }
        .frame(width: 46, height: 46)
    }
}
