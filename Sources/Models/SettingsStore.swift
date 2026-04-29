import Foundation
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings {
        didSet { save() }
    }

    init() {
        if let data = try? Data(contentsOf: AppPaths.settingsFile),
           let decoded = try? JSONDecoder.iso.decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
    }

    private func save() {
        guard let data = try? JSONEncoder.iso.encode(settings) else { return }
        try? data.write(to: AppPaths.settingsFile)
    }
}
