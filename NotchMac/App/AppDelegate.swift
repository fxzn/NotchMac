//
//  AppDelegate.swift
//  NotchMac
//

import AppKit
import SwiftUI

/// Handles application lifecycle, single-instance enforcement, menu bar status item, and NotchWindowController bootstrap.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var notchWindowController: NotchWindowController?
    private var statusItem: NSStatusItem?

    private var navigationState: NotchNavigationState?
    private var musicViewModel: MusicWidgetViewModel?
    private var notesViewModel: QuickNotesViewModel?

    private var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent Xcode Canvas Previews from spawning real floating NotchPanels or extra Menu Bar icons
        guard !isRunningForPreviews else { return }

        // Ensure only a single instance of NotchMac is active at any time
        terminateExistingInstances()

        // Hide default dock icon and standard menu bar windows so NotchMac acts as a pure Notch companion
        NSApp.setActivationPolicy(.accessory)

        // Close any default SwiftUI windows if created
        for window in NSApp.windows where !(window is NotchPanel) {
            window.close()
        }

        let navState = NotchNavigationState()
        let musicVM = MusicWidgetViewModel()
        let notesVM = QuickNotesViewModel()

        self.navigationState = navState
        self.musicViewModel = musicVM
        self.notesViewModel = notesVM

        setupStatusItem()
        setupNotchWindow(
            navigationState: navState,
            musicViewModel: musicVM,
            notesViewModel: notesVM
        )
    }

    /// Terminates any lingering older NotchMac processes or preview host instances so windows never stack.
    private func terminateExistingInstances() {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        let bundleID = Bundle.main.bundleIdentifier ?? "com.personal.NotchMac"

        let runningInstances = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        for instance in runningInstances where instance.processIdentifier != currentPID {
            instance.forceTerminate()
        }
    }

    private func setupNotchWindow(
        navigationState: NotchNavigationState,
        musicViewModel: MusicWidgetViewModel,
        notesViewModel: QuickNotesViewModel
    ) {
        let controller = NotchWindowController(
            navigationState: navigationState,
            musicViewModel: musicViewModel,
            notesViewModel: notesViewModel
        )
        self.notchWindowController = controller
        controller.showNotchPanel()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "rectangle.topthird.inset.filled",
                accessibilityDescription: "NotchMac"
            )
        }

        let menu = NSMenu()
        let toggleItem = NSMenuItem(
            title: "Toggle Notch Expansion",
            action: #selector(toggleNotchExpansion),
            keyEquivalent: "n"
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit NotchMac",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        self.statusItem = item
    }

    @objc private func toggleNotchExpansion() {
        guard let navigationState else { return }
        navigationState.setExpanded(!navigationState.isExpanded)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
