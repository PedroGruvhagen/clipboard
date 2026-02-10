import SwiftUI
import AppKit
import MenuBarExtraAccess

/// Shared state for menu bar visibility
class MenuBarState: ObservableObject {
    static let shared = MenuBarState()
    @Published var isPresented = false
}

@main
struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var historyStore = HistoryStore.shared
    @StateObject private var clipboardWatcher = ClipboardWatcher.shared
    @StateObject private var menuBarState = MenuBarState.shared

    var body: some Scene {
        MenuBarExtra(isInserted: .constant(true)) {
            MenuBarView()
                .environmentObject(historyStore)
                .environmentObject(clipboardWatcher)
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $menuBarState.isPresented)

        Settings {
            PreferencesView()
                .environmentObject(historyStore)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var showHistoryObserver: NSObjectProtocol?
    private var openSettingsObserver: NSObjectProtocol?
    private var preferencesWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start clipboard monitoring
        ClipboardWatcher.shared.startMonitoring()

        // Register global hotkey
        HotKeyService.shared.registerDefaultHotkey()

        // Listen for show clipboard history notification
        showHistoryObserver = NotificationCenter.default.addObserver(
            forName: .showClipboardHistory,
            object: nil,
            queue: .main
        ) { _ in
            MenuBarState.shared.isPresented.toggle()
        }

        // Listen for open settings notification (robust approach for macOS 26+)
        openSettingsObserver = NotificationCenter.default.addObserver(
            forName: .openSettings,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.openPreferencesWindow()
        }

        // Check accessibility permission (required for paste simulation)
        // Prompt user if not granted - this is needed for CGEvent to work
        if !HotKeyService.shared.checkAccessibilityPermission() {
            // Delay prompt slightly so app fully launches first
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                HotKeyService.shared.requestAccessibilityPermission()
            }
        }

        // Hide dock icon (configured via LSUIElement, but ensure it)
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Stop monitoring
        ClipboardWatcher.shared.stopMonitoring()

        // Remove observers
        if let observer = showHistoryObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = openSettingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// Opens the preferences window using a direct NSWindow approach.
    /// This bypasses SwiftUI's broken openSettings/showSettingsWindow: on macOS 26 Tahoe.
    func openPreferencesWindow() {
        // Check if our window already exists and bring it to front
        if let window = preferencesWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Also check for any existing SwiftUI Settings window (from Cmd+,)
        for window in NSApp.windows where window.isVisible {
            if window.title == "Settings" || window.title == "Preferences" {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }
        }

        // Create a new preferences window using NSHostingController
        let view = PreferencesView()
            .environmentObject(HistoryStore.shared)

        let controller = NSHostingController(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Demoskop Clipboard Settings"
        window.contentViewController = controller
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)

        preferencesWindow = window
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openSettings = Notification.Name("openSettings")
}
