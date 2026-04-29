import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    /// Default: ⌃⌥⌘I — open / close the iob-bar popover from anywhere.
    static let togglePopover = Self(
        "togglePopover",
        default: .init(.i, modifiers: [.control, .option, .command])
    )
}
