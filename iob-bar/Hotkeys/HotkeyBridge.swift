import Foundation
import Combine
import KeyboardShortcuts

/// Owns the global hotkey registration and exposes a `@Published` Bool that
/// `MenuBarExtra` can bind to via `MenuBarExtraAccess`. Encapsulating this
/// in a class avoids the @State / closure-capture awkwardness that would
/// otherwise arise from registering a hotkey inside the App's init.
@MainActor
final class HotkeyBridge: ObservableObject {
    @Published var isPopoverPresented = false

    init() {
        KeyboardShortcuts.onKeyDown(for: .togglePopover) { [weak self] in
            Task { @MainActor in
                self?.isPopoverPresented.toggle()
            }
        }
    }
}
