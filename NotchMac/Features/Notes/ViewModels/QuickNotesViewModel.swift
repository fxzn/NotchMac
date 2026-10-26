//
//  QuickNotesViewModel.swift
//  NotchMac
//

import Combine
import Foundation

/// ViewModel managing interactive date selection, week pagination, and per-day agenda notes inside the Notch.
@MainActor
final class QuickNotesViewModel: ObservableObject {
    private static let legacyStorageKey = "com.personal.NotchMac.quickNoteText"
    private static let notesByDateKey = "com.personal.NotchMac.notesByDate"

    @Published var selectedDate: Date = Date()
    @Published var weekOffset: Int = 0
    @Published private(set) var notesByDate: [String: String] = [:]

    var noteText: String {
        get {
            notesByDate[dateKey(for: selectedDate)] ?? ""
        }
        set {
            let key = dateKey(for: selectedDate)
            let trimmed = newValue
            if trimmed.isEmpty {
                notesByDate.removeValue(forKey: key)
            } else {
                notesByDate[key] = trimmed
            }
            saveNotes()
        }
    }

    init() {
        if let stored = UserDefaults.standard.dictionary(forKey: Self.notesByDateKey) as? [String: String] {
            self.notesByDate = stored
        } else if let legacyNote = UserDefaults.standard.string(forKey: Self.legacyStorageKey), !legacyNote.isEmpty {
            let todayKey = Self.formatKey(for: Date())
            self.notesByDate = [todayKey: legacyNote]
            saveNotes()
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    func shiftWeek(by delta: Int) {
        weekOffset += delta
        if let newSelected = Calendar.current.date(byAdding: .day, value: delta * 7, to: selectedDate) {
            selectedDate = newSelected
        }
    }

    func jumpToToday() {
        weekOffset = 0
        selectedDate = Date()
    }

    func hasNote(on date: Date) -> Bool {
        guard let text = notesByDate[dateKey(for: date)] else { return false }
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func clearNote() {
        noteText = ""
    }

    private func saveNotes() {
        UserDefaults.standard.set(notesByDate, forKey: Self.notesByDateKey)
    }

    private func dateKey(for date: Date) -> String {
        Self.formatKey(for: date)
    }

    private static func formatKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
