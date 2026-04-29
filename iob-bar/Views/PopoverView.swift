import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var doseStore: DoseStore
    @EnvironmentObject var basalStore: BasalStore
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var ticker: Ticker

    @State private var showCustomEntry = false
    @State private var customAmount: Double = 1.0
    @State private var customDate: Date = Date()

    private var settings: AppSettings { settingsStore.settings }
    private var now: Date { ticker.now }

    private var iob: Double {
        IOBCalculator.currentIOB(doses: doseStore.doses, model: settings.insulinModel, now: now)
    }

    private var activeDoses: [Dose] {
        IOBCalculator.activeDoses(doseStore.doses, actionDuration: settings.insulinModel.actionDuration, now: now)
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            activeDosesSection
            Divider()
            quickAddSection
            customEntryToggle
            if showCustomEntry { customEntrySection }
            if settings.basalTracking != .off {
                Divider()
                basalSection
            }
            Divider()
            footer
        }
        .padding(14)
        .frame(width: 280)
        .onAppear {
            doseStore.prune(actionDuration: settings.insulinModel.actionDuration)
            basalStore.rolloverIfNewDay()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(String(format: "%.1f", iob))
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .monospacedDigit()
            Text("u on board")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    @ViewBuilder
    private var activeDosesSection: some View {
        if activeDoses.isEmpty {
            Text("No active doses")
                .foregroundStyle(.secondary)
                .font(.system(size: 12))
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(activeDoses) { dose in
                    DoseRowView(dose: dose, model: settings.insulinModel, now: now)
                }
            }
        }
    }

    private var quickAddSection: some View {
        HStack(spacing: 6) {
            ForEach(Array(settings.defaultDoseAmounts.prefix(4).enumerated()), id: \.offset) { index, amount in
                let shortcutChar = Character(String(index + 1))
                Button {
                    doseStore.add(amount: amount)
                } label: {
                    VStack(spacing: 0) {
                        Text("+\(amount.formatted())u")
                            .font(.system(size: 13, weight: .medium))
                        Text(String(index + 1))
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(KeyEquivalent(shortcutChar), modifiers: [])
            }
        }
    }

    private var customEntryToggle: some View {
        Button {
            showCustomEntry.toggle()
            if showCustomEntry { customDate = Date() }
        } label: {
            Label(showCustomEntry ? "Hide custom" : "Custom amount or time",
                  systemImage: "slider.horizontal.3")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private var customEntrySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Amount:").font(.system(size: 12))
                Stepper(value: $customAmount, in: 0.5...20, step: 0.5) {
                    EmptyView()
                }
                .labelsHidden()
                Text("\(customAmount, specifier: "%.1f")u")
                    .monospacedDigit()
                    .font(.system(size: 12))
            }
            DatePicker("Time:", selection: $customDate, displayedComponents: [.date, .hourAndMinute])
                .font(.system(size: 12))
            Button {
                doseStore.add(amount: customAmount, at: customDate)
                customDate = Date()
                showCustomEntry = false
            } label: {
                Text("Log dose").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: [.command])
        }
    }

    @ViewBuilder
    private var basalSection: some View {
        switch settings.basalTracking {
        case .amPm:
            HStack(spacing: 6) {
                basalButton(title: "AM",
                            timestamp: basalStore.morningTaken,
                            mark: { basalStore.markMorning() },
                            clear: { basalStore.clearMorning() },
                            shortcut: "m")
                basalButton(title: "PM",
                            timestamp: basalStore.eveningTaken,
                            mark: { basalStore.markEvening() },
                            clear: { basalStore.clearEvening() },
                            shortcut: "e")
            }
        case .oncePerDay:
            basalButton(title: "Daily basal",
                        timestamp: basalStore.dailyTaken,
                        mark: { basalStore.markDaily() },
                        clear: { basalStore.clearDaily() },
                        shortcut: "b")
        case .off:
            EmptyView()
        }
    }

    private func basalButton(title: String,
                             timestamp: Date?,
                             mark: @escaping () -> Void,
                             clear: @escaping () -> Void,
                             shortcut: KeyEquivalent) -> some View {
        Button {
            if timestamp != nil { clear() } else { mark() }
        } label: {
            HStack {
                Image(systemName: timestamp != nil ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(.system(size: 11, weight: .medium))
                    if let t = timestamp {
                        Text(t, style: .time)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("not yet")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .buttonStyle(.bordered)
        .keyboardShortcut(shortcut, modifiers: [])
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.system(size: 11))
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
}
