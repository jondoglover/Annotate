import KeyboardShortcuts
import SwiftUI

@main
struct AnnotateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: UserDefaults.controlOptionDConfiguredKey) {
            KeyboardShortcuts.setShortcut(
                .init(.d, modifiers: [.control, .option]),
                for: .toggleOverlay
            )
            defaults.set(true, forKey: UserDefaults.controlOptionDConfiguredKey)
        }

        KeyboardShortcuts.onKeyDown(for: .toggleOverlay) {
            AppDelegate.shared?.toggleOverlay()
        }
        
        KeyboardShortcuts.onKeyDown(for: .toggleAlwaysOnMode) {
            AppDelegate.shared?.toggleAlwaysOnMode()
        }
    }

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
