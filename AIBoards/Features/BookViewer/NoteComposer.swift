import SwiftUI

/// A pin dropped on the document while taking a note.
struct PlacedPin: Identifiable {
    let id = UUID()
    var point: CGPoint
    var committed: Bool          // false = being composed, true = saved
    var initials: String = "KL"
    var tint: String = "#EEEFF5"
    var noteId: UUID? = nil      // links a saved pin to its note card
}

/// Drives the "new note" flow shared by the reader's document (pin placement)
/// and the Notes side panel (compose field + resulting note).
@MainActor
final class NoteComposer: ObservableObject {
    enum Mode { case off, placing, composing }

    @Published var mode: Mode = .off
    @Published var pins: [PlacedPin] = []
    @Published var draft = ""
    @Published var submitting = false
    @Published var addedNotes: [BoardNote] = []
    /// The saved note (and its pin) currently selected — gets the highlight + blue pin.
    @Published var focusedNoteId: UUID? = nil

    var isActive: Bool { mode != .off }

    func focus(_ id: UUID?) {
        withAnimation(.easeInOut(duration: 0.15)) { focusedNoteId = id }
    }
    func unfocus() {
        guard focusedNoteId != nil else { return }
        withAnimation(.easeInOut(duration: 0.15)) { focusedNoteId = nil }
    }

    init() {
        // Launch-argument hooks so each flow state can be screenshotted headlessly.
        let arg = ProcessInfo.processInfo.arguments
            .first { $0.hasPrefix("-note=") }?.replacingOccurrences(of: "-note=", with: "")
        switch arg {
        case "placing":
            mode = .placing
        case "composing":
            pins = [PlacedPin(point: CGPoint(x: 300, y: 320), committed: false)]
            draft = "Can we confirm the remediation timeline with the CIO before the vote?"
            mode = .composing
        case "added", "unfocused":
            let note = BoardNote(author: "Katherine L.", initials: "KL", tint: "#E9EDFD",
                                 timestamp: "Just now",
                                 body: "Can we confirm the remediation timeline with the CIO before the vote?")
            pins = [PlacedPin(point: CGPoint(x: 300, y: 320), committed: true, noteId: note.id)]
            addedNotes = [note]
            focusedNoteId = (arg == "added") ? note.id : nil
        default:
            break
        }
    }

    /// Tapped the "new note" button — arm placement (or cancel if already active).
    func toggle() {
        if mode == .off { mode = .placing } else { cancel() }
    }

    func cancel() {
        pins.removeAll { !$0.committed }
        draft = ""
        submitting = false
        mode = .off
    }

    /// Tapped the document while placing — drop the pin and open the compose field.
    func place(at point: CGPoint) {
        guard mode == .placing else { return }
        pins.removeAll { !$0.committed }
        pins.append(PlacedPin(point: point, committed: false))
        mode = .composing
    }

    /// Pressed send / Enter — show a brief loading state, then save the note.
    func submit() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !submitting else { return }
        submitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            let note = BoardNote(author: "Katherine L.", initials: "KL", tint: "#E9EDFD",
                                 timestamp: "Just now", body: text)
            withAnimation(.smooth(duration: 0.3)) {
                if let i = self.pins.firstIndex(where: { !$0.committed }) {
                    self.pins[i].committed = true
                    self.pins[i].noteId = note.id
                }
                self.addedNotes.insert(note, at: 0)
                self.focusedNoteId = note.id        // the just-added note starts focused
                self.draft = ""
                self.submitting = false
                self.mode = .off
            }
        }
    }
}
