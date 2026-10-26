//
//  ContentView.swift
//  NotchMac
//
//  Created by Farhan Wundari on 26/10/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var navigationState: NotchNavigationState
    @ObservedObject var musicViewModel: MusicWidgetViewModel
    @ObservedObject var notesViewModel: QuickNotesViewModel

    init(
        navigationState: NotchNavigationState,
        musicViewModel: MusicWidgetViewModel,
        notesViewModel: QuickNotesViewModel
    ) {
        self.navigationState = navigationState
        self.musicViewModel = musicViewModel
        self.notesViewModel = notesViewModel
    }

    init() {
        self.navigationState = NotchNavigationState()
        self.musicViewModel = MusicWidgetViewModel()
        self.notesViewModel = QuickNotesViewModel()
    }

    private var currentWidth: CGFloat {
        navigationState.isExpanded
            ? NotchGeometry.expandedWidth
            : navigationState.geometry.notchWidth
    }

    private var currentHeight: CGFloat {
        navigationState.isExpanded
            ? NotchGeometry.expandedHeight
            : navigationState.geometry.notchHeight
    }

    private var currentCornerRadius: CGFloat {
        navigationState.isExpanded
            ? NotchTheme.expandedCornerRadius
            : NotchTheme.collapsedCornerRadius
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            notchContainer
                .frame(width: currentWidth, height: currentHeight, alignment: .top)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: currentCornerRadius,
                        bottomTrailingRadius: currentCornerRadius,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                    .fill(NotchTheme.notchBackground)
                )
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: currentCornerRadius,
                        bottomTrailingRadius: currentCornerRadius,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                    .strokeBorder(
                        navigationState.isExpanded ? NotchTheme.hairlineBorder : Color.clear,
                        lineWidth: NotchTheme.borderWidth
                    )
                )
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: currentCornerRadius,
                        bottomTrailingRadius: currentCornerRadius,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                )
                .shadow(
                    color: .black.opacity(navigationState.isExpanded ? 0.55 : 0),
                    radius: 18,
                    x: 0,
                    y: 10
                )
                .onHover { hovering in
                    withAnimation(NotchTheme.springAnimation) {
                        navigationState.isExpanded = hovering
                    }
                    if hovering {
                        musicViewModel.refreshTrack()
                    }
                }
                .notchSpringAnimation(value: navigationState.isExpanded)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var notchContainer: some View {
        if navigationState.isExpanded {
            expandedContent
                .transition(
                    .opacity.combined(with: .scale(scale: 0.92, anchor: .top))
                )
        } else {
            collapsedContent
                .transition(.opacity)
        }
    }

    /// Minimal indicator inside the collapsed notch footprint.
    private var collapsedContent: some View {
        HStack(spacing: 6) {
            if musicViewModel.currentTrack.isPlaying {
                Circle()
                    .fill(NotchTheme.spotifyAccent)
                    .frame(width: 6, height: 6)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Expanded Dynamic Island / NotchNook layout showing Spotify & Quick Notes below the physical camera cutout.
    private var expandedContent: some View {
        VStack(spacing: 10) {
            // Reserve top safe space for the physical camera housing + subtle status header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text("NotchMac")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                Text(musicViewModel.currentTrack.isSpotifyRunning ? "Spotify Connected" : "Idle")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .frame(height: max(navigationState.geometry.notchHeight, 28))
            .padding(.horizontal, 18)

            // Main Nook Widgets: Spotify Now Playing + Quick Notes
            HStack(spacing: 12) {
                MusicCardView(viewModel: musicViewModel)
                    .frame(width: 245)

                QuickNotesCardView(viewModel: notesViewModel)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 560, height: 250)
        .background(Color.gray.opacity(0.3))
}
