//
//  QuickNotesViewModel.swift
//  NotchMac
//

import Combine
import Foundation

/// ViewModel managing persistent quick scratchpad notes inside the Notch.
@MainActor
final class QuickNotesViewModel: ObservableObject {
    private static let storageKey = "com.personal.NotchMac.quickNoteText"

    @Published var noteText: String {
        didSet {
            UserDefaults.standard.set(noteText, forKey: Self.storageKey)
        }
    }

    init() {
        self.noteText = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
    }

    func clearNote() {
        noteText = ""
    }
}
