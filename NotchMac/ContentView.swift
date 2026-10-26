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

    @State private var hoverCollapseTask: Task<Void, Never>?

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

    private var topEarRadius: CGFloat {
        navigationState.isExpanded
            ? NotchGeometry.expandedTopEarRadius
            : NotchGeometry.collapsedTopEarRadius
    }

    private var bottomCornerRadius: CGFloat {
        navigationState.isExpanded
            ? NotchTheme.expandedCornerRadius
            : NotchTheme.collapsedCornerRadius
    }

    private var currentBodyWidth: CGFloat {
        navigationState.isExpanded
            ? NotchGeometry.expandedWidth
            : navigationState.geometry.notchWidth
    }

    private var currentTotalWidth: CGFloat {
        currentBodyWidth + (topEarRadius * 2)
    }

    private var currentHeight: CGFloat {
        navigationState.isExpanded
            ? NotchGeometry.expandedHeight
            : navigationState.geometry.notchHeight
    }

    private var notchShape: NotchShape {
        NotchShape(
            topCornerRadius: topEarRadius,
            bottomCornerRadius: bottomCornerRadius
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            ZStack(alignment: .top) {
                // Collapsed indicator layer
                collapsedContent
                    .frame(
                        width: navigationState.geometry.notchWidth,
                        height: navigationState.geometry.notchHeight
                    )
                    .opacity(navigationState.isExpanded ? 0 : 1)
                    .scaleEffect(navigationState.isExpanded ? 0.85 : 1.0, anchor: .top)

                // Expanded pure-black seamless layer (fixed 456x136 layout frame for 120fps spring)
                expandedContent
                    .frame(
                        width: NotchGeometry.expandedWidth,
                        height: NotchGeometry.expandedHeight,
                        alignment: .top
                    )
                    .scaleEffect(
                        x: navigationState.isExpanded ? 1.0 : 0.56,
                        y: navigationState.isExpanded ? 1.0 : 0.34,
                        anchor: .top
                    )
                    .opacity(navigationState.isExpanded ? 1.0 : 0.0)
                    .blur(radius: navigationState.isExpanded ? 0 : 6)
                    .allowsHitTesting(navigationState.isExpanded)
            }
            .frame(width: currentTotalWidth, height: currentHeight, alignment: .top)
            .background(
                notchShape
                    .fill(NotchTheme.notchBackground)
            )
            .overlay(
                notchShape
                    .stroke(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(navigationState.isExpanded ? 0.10 : 0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: NotchTheme.borderWidth
                    )
            )
            .clipShape(notchShape)
            .shadow(
                color: .black.opacity(navigationState.isExpanded ? 0.45 : 0),
                radius: 14,
                x: 0,
                y: 6
            )
            .contentShape(notchShape)
            .onHover { hovering in
                handleHover(hovering)
            }
            .notchSpringAnimation(value: navigationState.isExpanded)
            .notchSpringAnimation(value: navigationState.activeTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func handleHover(_ hovering: Bool) {
        hoverCollapseTask?.cancel()
        if hovering {
            navigationState.setExpanded(true)
            musicViewModel.refreshTrack()
        } else {
            hoverCollapseTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(70))
                guard !Task.isCancelled else { return }
                navigationState.setExpanded(false)
            }
        }
    }

    /// Minimal indicator inside the collapsed notch footprint.
    private var collapsedContent: some View {
        HStack(spacing: 6) {
            if musicViewModel.currentTrack.isPlaying {
                Circle()
                    .fill(NotchTheme.spotifyAccent)
                    .frame(width: 5, height: 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
    }

    /// Clean, pure-black cardless layout with a subtle hairline divider and NotchMac's own identity ("Live" / "Stash").
    private var expandedContent: some View {
        VStack(spacing: 6) {
            // Top bar: Minimal dot-accented tabs on left, camera cutout in center, Pin toggle on right
            HStack(spacing: 6) {
                HStack(spacing: 12) {
                    ForEach(NotchTab.allCases) { tab in
                        Button {
                            navigationState.activeTab = tab
                        } label: {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(
                                        navigationState.activeTab == tab
                                            ? Color.white
                                            : Color.white.opacity(0.22)
                                    )
                                    .frame(width: 4.5, height: 4.5)

                                Text(tab.rawValue)
                                    .font(.system(size: 10.5, weight: navigationState.activeTab == tab ? .semibold : .medium))
                                    .foregroundStyle(
                                        navigationState.activeTab == tab
                                            ? .white
                                            : .white.opacity(0.42)
                                    )
                            }
                            .padding(.vertical, 3)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                Button(action: navigationState.togglePin) {
                    Image(systemName: navigationState.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(navigationState.isPinned ? NotchTheme.calendarAccent : .white.opacity(0.38))
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(navigationState.isPinned ? "Unpin Notch" : "Pin Notch Open")
            }
            .frame(height: 22)
            .padding(.horizontal, 18)
            .padding(.top, 5)

            // Main body directly on the pure black notch canvas (no card wrappers, separated by a subtle hairline)
            Group {
                switch navigationState.activeTab {
                case .nook:
                    liveWorkspaceView
                case .tray:
                    stashWorkspaceView
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)
        }
    }

    private var liveWorkspaceView: some View {
        HStack(alignment: .center, spacing: 14) {
            MusicCardView(viewModel: musicViewModel)
                .frame(width: 194)

            // Ultra-subtle hairline vertical divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 0.5, height: 58)

            QuickNotesCardView(viewModel: notesViewModel)
        }
    }

    private var stashWorkspaceView: some View {
        HStack(spacing: 10) {
            Image(systemName: "tray.and.arrow.down")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.42))

            Text("Drop files or links into Stash")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.42))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .frame(width: 520, height: 200)
        .background(Color.gray.opacity(0.3))
}
