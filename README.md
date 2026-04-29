# iob-bar

A tiny macOS menubar app that shows your current insulin on board (IOB).

That's it. No graphs, no blood-sugar tracking, no carb logging, no notifications,
no charts. Just the number, and a fast way to log a dose so you don't accidentally
double-dose.

> ⚠️ **Not a medical device.** This is a personal tool built to help one
> person remember whether they just took insulin. It is not approved by the
> FDA or any regulatory body, makes no medical claims, and is not a substitute
> for professional medical advice or your prescribed insulin regimen. The
> pharmacokinetic curve is a mathematical approximation — real insulin behavior
> varies by person, by injection site, by meal composition, by activity level,
> by stress, by ambient temperature, by everything. Treat the IOB number as a
> memory aid, not as truth. Use at your own risk.

## Who this is for

This app is built for **MDI (multiple daily injection) users on pens with
half-unit dosing** — e.g., Humalog Junior KwikPen. That assumption shapes
several design choices that might otherwise look like omissions:

- Quick-add buttons are in 0.5u increments (`+0.5` / `+1.0` / `+1.5` / `+2.0`)
- No carb counting, no bolus-wizard math
- No pump integration (if you're on a pump, [Loop](https://github.com/LoopKit/Loop)
  or another AID stack is what you actually want)
- No CGM / blood-glucose display (a separate companion app for that is on
  the [roadmap](ROADMAP.md))

If you're on full-unit pens, the math still works but the quick-add buttons
won't match your dosing granularity.

## What it does

A small text item lives in your menubar showing your current insulin on board:

```
2.5u
```

Click it (or hit `⌃⌥⌘I` from anywhere on macOS) to drop down a popover:

- The current IOB in big numerals
- Every dose still active in your system, with how much each one is currently
  contributing after pharmacokinetic decay
- Four big quick-add buttons (`+0.5u` / `+1.0u` / `+1.5u` / `+2.0u`), with
  keyboard shortcuts `1`–`4`
- A custom-amount-and-time entry for when you forgot to log earlier
- Optional AM/PM basal tracking (or once-per-day, or off entirely) that resets
  at midnight
- Hover over any active dose to reveal an × button that removes it from the
  IOB calculation

Doses older than the action-duration window (default 6 hours) are pruned
automatically — the popover only ever shows what's actually still doing
something.

## How the math works

The decay curve is the modern exponential model used by [LoopKit][loopkit],
parameterized by peak activity time and total action duration. Default
parameters target Humalog (75-min peak, 6-hour duration); to use another rapid-
acting insulin preset, edit [`Settings.swift`][settings-swift] (a settings UI
is on the [roadmap](ROADMAP.md)).

Total IOB at any moment is `sum(dose_i × fractionRemaining_i(elapsed_i))`,
where `fractionRemaining` is the biexponential pharmacokinetic curve. The
implementation is in [`InsulinModel.swift`][insulin-model], derived from
LoopKit's `ExponentialInsulinModel` under Apache 2.0; see [NOTICE](NOTICE).

## Build and run

### Requirements

- macOS Sonoma (14.0) or later
- Xcode 15 or later (free from the Mac App Store)
- A free Apple ID for local code signing — no paid Developer account is
  required for personal use

### Steps

```bash
git clone https://github.com/gpechenik/iob-bar.git
cd iob-bar
open iob-bar.xcodeproj
```

In Xcode:

1. Click the project root in the navigator → select the `iob-bar` target
2. In the **Signing & Capabilities** tab, set **Team** to your Apple ID
3. ⌘R to build and run

The first time you press `⌃⌥⌘I` while another app is focused, macOS will
prompt you to grant Accessibility / Input Monitoring permission so the global
hotkey can fire. Grant it via **System Settings → Privacy & Security**.

### Install for daily use

Once you've run the app once via ⌘R, you have a built `iob-bar.app` bundle
on disk that doesn't require Xcode to launch. To make it part of your
day-to-day environment:

1. **Find the bundle**: in Xcode's project navigator, expand the **Products**
   group at the bottom → right-click `iob-bar.app` → **Show in Finder**. Or
   navigate to `~/Library/Developer/Xcode/DerivedData/iob-bar-<hash>/Build/Products/Debug/iob-bar.app`.
2. **Copy to /Applications/**: drag the `.app` into your Applications folder.
3. **Auto-launch on login** (optional): **System Settings → General → Login
   Items → click the +** under "Open at Login" → pick `iob-bar` from the
   Applications folder.

For a smaller, optimized Release-configuration build, use **Product → Archive
→ Distribute App → Copy App** in Xcode. For personal use the Debug build
works fine.

> **Code signing note**: apps signed with a free Apple ID work indefinitely
> on the Mac that signed them, but other Macs will see them as "unidentified
> developer" and Gatekeeper will challenge them on first launch. To distribute
> beyond your own machine cleanly, you need a paid Apple Developer ID
> (~$99/year).

### Storage

Doses, basal stamps, and settings live as plain JSON in:

```
~/Library/Containers/<bundle-id>/Data/Library/Application Support/iob-bar/
```

The App Sandbox transparently redirects the canonical Application Support
path to a per-app container, so this is where the data actually lives. The
`<bundle-id>` matches whatever you set during project creation (e.g.
`graham.gg.iob-bar`). Nothing leaves your machine.

#### Cross-machine sync via symlink (optional)

If you want the same dose history across multiple Macs, you can symlink
the storage directory to a synced location (iCloud Drive, Dropbox, syncthing,
etc.). On the first Mac:

```bash
# Quit iob-bar first.
BUNDLE_ID="graham.gg.iob-bar"  # change to yours
SYNC_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/iob-bar"

# Move existing data into the synced location:
mv "$HOME/Library/Containers/$BUNDLE_ID/Data/Library/Application Support/iob-bar" \
   "$SYNC_DIR"

# Replace the original location with a symlink:
ln -s "$SYNC_DIR" \
      "$HOME/Library/Containers/$BUNDLE_ID/Data/Library/Application Support/iob-bar"
```

On a second Mac, after building and running the app once (so the container
exists), only the second step is needed — point a fresh symlink at the same
`$SYNC_DIR`.

> macOS occasionally recreates container subdirectories during system updates
> or when sandbox grants change. If your symlink gets clobbered, recreate it.
> If that happens often enough to be annoying, that's the natural prompt to
> migrate to HealthKit-backed storage — see [ROADMAP.md](ROADMAP.md).

## Keyboard shortcuts

### Global

| Combo | Action |
|---|---|
| `⌃⌥⌘I` | Toggle the popover from anywhere |

### In the popover

| Key | Action |
|---|---|
| `1` | Log +0.5u |
| `2` | Log +1.0u |
| `3` | Log +1.5u |
| `4` | Log +2.0u |
| `m` | Toggle AM basal as logged (in AM/PM mode) |
| `e` | Toggle PM basal as logged (in AM/PM mode) |
| `b` | Toggle daily basal (in once-per-day mode) |
| `⌘↩` | Log the custom-entry dose (when expanded) |
| `Esc` | Close the popover |
| `⌘Q` | Quit the app |

## Design philosophy

The discipline is *just IOB, nothing else*. Other diabetes apps that exist
have all gone overboard — graphs, carb counting, BG correlation, predictions,
dashboards, notifications, push reminders, social features. This one resists
that pressure on purpose. If you want any of those features, fork it.

Why? Because in daily use, the question is almost always one of:
*"Did I just take insulin or did I imagine that?"* A tool that answers that
question in two clicks beats one that answers it in twelve clicks plus a
dashboard.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned future work, including iPhone/widget
port, settings UI, HealthKit integration, and a separate-but-related blood
glucose menubar app.

## Acknowledgments

- [**LoopKit**][loopkit] — the canonical open-source diabetes framework
  in the Apple ecosystem; source of the exponential pharmacokinetic model
  used here. Apache 2.0; attribution in [NOTICE](NOTICE).
- [**KeyboardShortcuts**][keyboardshortcuts] by Sindre Sorhus — global
  hotkey registration with built-in rebind UI machinery. MIT.
- [**MenuBarExtraAccess**][menubarextraaccess] by orchetect — programmatic
  control of `MenuBarExtra`'s popover visibility, used here to let the global
  hotkey toggle the popover. MIT.

## License

[MIT](LICENSE).

[loopkit]: https://github.com/LoopKit/LoopKit
[keyboardshortcuts]: https://github.com/sindresorhus/KeyboardShortcuts
[menubarextraaccess]: https://github.com/orchetect/MenuBarExtraAccess
[insulin-model]: iob-bar/Models/InsulinModel.swift
[settings-swift]: iob-bar/Models/Settings.swift
