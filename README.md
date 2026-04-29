# iob-bar

A tiny macOS menubar app that shows your current insulin on board (IOB).

That's it. No graphs, no blood-sugar tracking, no carb logging. Just the number,
and a fast way to log a dose so you don't accidentally double-dose.

## Status

Pre-Xcode-setup scaffold. Source files are staged in [Sources/](Sources/) and
will be wired into an Xcode project once Xcode is installed.

## Design

- **Menubar text**: current IOB, e.g. `2.5u` (or `0.0u` when nothing is active).
- **Click or hotkey** (`⌃⌥⌘I` by default): opens a popover with the active doses,
  big buttons for common amounts (`+0.5` / `+1.0` / `+1.5` / `+2.0`), and a
  basal-tracking section.
- **Single-key shortcuts** in the popover: `1` / `2` / `3` / `4` log
  `+0.5` / `+1.0` / `+1.5` / `+2.0`u; `Enter` repeats the last dose; `Esc`
  closes; `m` / `e` mark AM / PM basal.
- **Decay**: exponential pharmacokinetic model derived from LoopKit. Defaults
  tuned for Humalog (75-min peak, 6-hour duration). Doses older than the
  duration of action are pruned automatically.
- **Basal tracking**: configurable — AM/PM, once-per-day, or off. Resets at
  midnight. Visible only in the popover, never in the menubar.
- **Storage**: JSON files in `~/Library/Application Support/iob-bar/`.
  Nothing leaves your machine. (HealthKit integration planned for a later
  iteration when iPhone support is added.)

## Build (once Xcode is installed)

This project will be developed as an Xcode-managed macOS app. The Swift
sources are pre-staged in [Sources/](Sources/) and are integrated into the
Xcode project via the steps documented below.

1. Install Xcode from the Mac App Store.
2. Open Xcode once, accept the license, install additional components.
3. From this directory: `open -a Xcode` and create a new project:
   `File → New → Project → macOS → App`. Name it `iob-bar`, choose any
   organization identifier you like (e.g. `com.yourname`), interface SwiftUI,
   language Swift. Save into `~/.code/` so the project lives at
   `~/.code/iob-bar/iob-bar.xcodeproj`.

   The bundle identifier (auto-derived as `<org-id>.iob-bar`) isn't referenced
   anywhere in this codebase — pick whatever you'll be happy with long-term.
   Note: macOS treats the bundle ID as the app's identity, so changing it
   later means re-granting any permissions (notably the Accessibility /
   Input Monitoring permission required by the global hotkey).
4. Add Swift Package dependencies via `File → Add Package Dependencies`:
   - [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) —
     `https://github.com/sindresorhus/KeyboardShortcuts` (global hotkey
     registration + future settings-rebind UI).
   - [MenuBarExtraAccess](https://github.com/orchetect/MenuBarExtraAccess) —
     `https://github.com/orchetect/MenuBarExtraAccess` (exposes a Bool
     binding for `MenuBarExtra`'s popover visibility, so the global hotkey
     can programmatically toggle the popover open).
5. Drag the contents of [Sources/](Sources/) into the project navigator,
   replacing the auto-generated `iob_barApp.swift` and `ContentView.swift`.
6. In the target's Info tab, set `LSUIElement` (Application is agent) to `YES`
   so the app runs as a menubar-only agent without a Dock icon.
7. ⌘R to build and run.

## License

[MIT](LICENSE). Portions derived from LoopKit (Apache 2.0); see [NOTICE](NOTICE).
