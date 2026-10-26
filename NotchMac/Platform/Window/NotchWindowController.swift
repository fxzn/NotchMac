//
//  NotchWindowController.swift
//  NotchMac
//

import AppKit
import SwiftUI

/// Coordinates the floating NotchPanel lifecycle, static bounding box positioning, and display configuration changes.
@MainActor
final class NotchWindowController: NSWindowController {
    private let navigationState: NotchNavigationState
    private let musicViewModel: MusicWidgetViewModel
    private let notesViewModel: QuickNotesViewModel
    private var screenObserver: NSObjectProtocol?

    init(
        navigationState: NotchNavigationState,
        musicViewModel: MusicWidgetViewModel,
        notesViewModel: QuickNotesViewModel
    ) {
        self.navigationState = navigationState
        self.musicViewModel = musicViewModel
        self.notesViewModel = notesViewModel

        let geometry = NotchGeometry.current()
        navigationState.geometry = geometry

        let panel = NotchPanel(contentRect: geometry.panelFrame)
        super.init(window: panel)

        let rootView = ContentView(
            navigationState: navigationState,
            musicViewModel: musicViewModel,
            notesViewModel: notesViewModel
        )

        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(origin: .zero, size: geometry.panelFrame.size)
        hostingView.autoresizingMask = [.width, .height]
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        panel.contentView = hostingView
        observeScreenChanges()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shows the floating notch panel at the top-center of the target screen without stealing focus.
    func showNotchPanel() {
        repositionPanel()
        window?.orderFrontRegardless()
    }

    /// Updates the panel's static bounding box when screen geometry or resolution changes.
    func repositionPanel() {
        guard let panel = window else { return }
        let geometry = NotchGeometry.current()
        navigationState.geometry = geometry
        panel.setFrame(geometry.panelFrame, display: true)
    }

    private func observeScreenChanges() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.repositionPanel()
            }
        }
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }
}
