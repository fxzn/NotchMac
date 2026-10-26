//
//  NotchMacApp.swift
//  NotchMac
//
//  Created by Farhan Wundari on 26/10/26.
//

import SwiftUI

@main
struct NotchMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Use Settings scene instead of WindowGroup so no default standard macOS window is created on launch
        Settings {
            EmptyView()
        }
    }
}
