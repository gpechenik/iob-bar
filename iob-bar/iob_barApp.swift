import SwiftUI
import MenuBarExtraAccess

@main
struct iob_barApp: App {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var doseStore = DoseStore()
    @StateObject private var basalStore = BasalStore()
    @StateObject private var ticker = Ticker()
    @StateObject private var hotkeyBridge = HotkeyBridge()

    var body: some Scene {
        MenuBarExtra(menuBarTitle, systemImage: nil) {
            PopoverView()
                .environmentObject(settingsStore)
                .environmentObject(doseStore)
                .environmentObject(basalStore)
                .environmentObject(ticker)
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $hotkeyBridge.isPopoverPresented)
    }

    private var menuBarTitle: String {
        _ = ticker.now  // tie title recomputation to the minute-tick
        let iob = IOBCalculator.currentIOB(
            doses: doseStore.doses,
            model: settingsStore.settings.insulinModel,
            now: ticker.now
        )
        return String(format: "%.1fu", iob)
    }
}
