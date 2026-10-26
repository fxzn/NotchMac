//
//  AppDelegate.swift
//  NotchMac
//

import AppKit
import SwiftUI

/// Handles application lifecycle, accessory activation policy, menu bar status item, and NotchWindowController bootstrap.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var notchWindowController: NotchWindowController?
    private var statusItem: NSStatusItem?

    private let navigationState = NotchNavigationState()
    private let musicViewModel = MusicWidgetViewModel()
    private let notesViewModel = QuickNotesViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide default dock icon and standard menu bar windows so NotchMac acts as a pure Notch companion
        NSApp.setActivationPolicy(.accessory)

        // Close any default SwiftUI windows if created
        for window in NSApp.windows where !(window is NotchPanel) {
            window.close()
        }

        setupStatusItem()
        setupNotchWindow()
    }

    private func setupNotchWindow() {
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
        navigationState.setExpanded(!navigationState.isExpanded)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
