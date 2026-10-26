//
//  MusicCardView.swift
//  NotchMac
//

import AppKit
import SwiftUI

/// Clean, cardless Apple-native media widget with micro platform tag, floating corner icon, and subtle progress line.
struct MusicCardView: View {
    @ObservedObject var viewModel: MusicWidgetViewModel

    private var platformAccent: Color {
        switch viewModel.currentTrack.platform {
        case .spotify:
            return NotchTheme.spotifyAccent
        case .appleMusic:
            return NotchTheme.appleMusicAccent
        case .youtube:
            return NotchTheme.youtubeAccent
        case .netflix:
            return NotchTheme.netflixAccent
        case .browser:
            return NotchTheme.browserAccent
        case .idle:
            return .white.opacity(0.35)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            artworkWithCornerBadge

            VStack(alignment: .leading, spacing: 3) {
                // Subtle platform source micro-indicator (unique to NotchMac, ultra-clean)
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.currentTrack.isPlaying ? platformAccent : .white.opacity(0.28))
                        .frame(width: 4.5, height: 4.5)

                    Text(viewModel.currentTrack.platform.rawValue)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                }

                Text(viewModel.currentTrack.title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(viewModel.currentTrack.artist)
                    .font(.system(size: 10.5, weight: .regular))
                    .foregroundStyle(.white.opacity(0.52))
                    .lineLimit(1)

                Spacer(minLength: 3)

                // Hairline progress bar + inline transport controls
                HStack(spacing: 12) {
                    Button(action: viewModel.previousTrack) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 10.5, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.60))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button(action: viewModel.togglePlayPause) {
                        Image(systemName: viewModel.currentTrack.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.95))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button(action: viewModel.nextTrack) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 10.5, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.60))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 2)

                    // Subtle audio activity bars (minimalist white/accent)
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { idx in
                            Capsule(style: .continuous)
                                .fill(viewModel.currentTrack.isPlaying ? platformAccent.opacity(0.85) : .white.opacity(0.18))
                                .frame(
                                    width: 2,
                                    height: viewModel.currentTrack.isPlaying ? CGFloat([6, 10, 7][idx]) : 3
                                )
                        }
                    }
                }
                .padding(.top, 1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var artworkWithCornerBadge: some View {
        ZStack(alignment: .bottomTrailing) {
            artworkImage
                .frame(width: 62, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 0.5)
                )

            platformCornerBadge
                .offset(x: 4, y: 4)
        }
    }

    @ViewBuilder
    private var platformCornerBadge: some View {
        switch viewModel.currentTrack.platform {
        case .spotify, .appleMusic, .browser:
            if let appIcon = resolvedNativeAppIcon() {
                Image(nsImage: appIcon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 19, height: 19)
                    .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)
            } else {
                ZStack {
                    Circle()
                        .fill(platformAccent)
                        .frame(width: 16, height: 16)
                    Image(systemName: "music.note")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

        case .youtube:
            ZStack {
                RoundedRectangle(cornerRadius: 4.5, style: .continuous)
                    .fill(NotchTheme.youtubeAccent)
                    .frame(width: 18, height: 14)
                Image(systemName: "play.fill")
                    .font(.system(size: 7.5, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)

        case .netflix:
            ZStack {
                Circle()
                    .fill(Color(white: 0.08))
                    .frame(width: 17, height: 17)
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                    )
                Text("N")
                    .font(.system(size: 10, weight: .black, design: .serif))
                    .foregroundStyle(NotchTheme.netflixAccent)
            }
            .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)

        case .idle:
            ZStack {
                Circle()
                    .fill(Color(white: 0.16))
                    .frame(width: 16, height: 16)
                Image(systemName: "waveform")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    private func resolvedNativeAppIcon() -> NSImage? {
        guard let bundleID = viewModel.currentTrack.bundleIdentifier,
              let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }

    @ViewBuilder
    private var artworkImage: some View {
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
        } else if let appIcon = resolvedNativeAppIcon() {
            ZStack {
                Color(white: 0.11)
                Image(nsImage: appIcon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 36, height: 36)
            }
        } else {
            placeholderArtwork
        }
    }

    private var placeholderArtwork: some View {
        ZStack {
            Color(white: 0.11)
            Image(systemName: "music.note")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.32))
        }
    }
}
