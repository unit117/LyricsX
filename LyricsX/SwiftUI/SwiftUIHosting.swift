//
//  SwiftUIHosting.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import AppKit

// MARK: - SwiftUI Preferences Window Controller

/// A window controller that hosts the SwiftUI PreferencesView
@available(macOS 13.0, *)
public class SwiftUIPreferencesWindowController: NSWindowController {
    
    private static var shared: SwiftUIPreferencesWindowController?
    
    public static func showPreferences() {
        if shared == nil {
            shared = SwiftUIPreferencesWindowController()
        }
        shared?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private init() {
        let preferencesView = PreferencesView()
        let hostingView = NSHostingView(rootView: preferencesView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 450),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = NSLocalizedString("Preferences", comment: "Preferences window title")
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
    }
}

// MARK: - NSViewRepresentable for AppKit Views

/// Wraps an existing KaraokeLyricsView for use in SwiftUI (if needed in future)
@available(macOS 12.0, *)
public struct KaraokeLyricsViewRepresentable: NSViewRepresentable {
    public typealias NSViewType = KaraokeLyricsView
    
    var line1: String
    var line2: String
    var font: NSFont
    var textColor: NSColor
    var progressColor: NSColor
    var shadowColor: NSColor
    var backgroundColor: NSColor
    var isVertical: Bool
    
    public init(
        line1: String = "",
        line2: String = "",
        font: NSFont = .systemFont(ofSize: 24, weight: .semibold),
        textColor: NSColor = .white,
        progressColor: NSColor = NSColor(red: 0.2, green: 1.0, blue: 0.87, alpha: 1.0),
        shadowColor: NSColor = NSColor(red: 0.0, green: 1.0, blue: 0.83, alpha: 1.0),
        backgroundColor: NSColor = NSColor(white: 0, alpha: 0.6),
        isVertical: Bool = false
    ) {
        self.line1 = line1
        self.line2 = line2
        self.font = font
        self.textColor = textColor
        self.progressColor = progressColor
        self.shadowColor = shadowColor
        self.backgroundColor = backgroundColor
        self.isVertical = isVertical
    }
    
    public func makeNSView(context: Context) -> KaraokeLyricsView {
        let view = KaraokeLyricsView(frame: .zero)
        updateView(view)
        return view
    }
    
    public func updateNSView(_ nsView: KaraokeLyricsView, context: Context) {
        updateView(nsView)
    }
    
    private func updateView(_ view: KaraokeLyricsView) {
        view.font = font
        view.textColor = textColor
        view.progressColor = progressColor
        view.shadowColor = shadowColor
        view.backgroundColor = backgroundColor
        view.isVertical = isVertical
        view.displayLrc(line1, secondLine: line2)
    }
}

// MARK: - SwiftUI Window Helper

@available(macOS 12.0, *)
public struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Menu Actions Extension

extension NSApplication {
    
    /// Opens the SwiftUI preferences window
    @available(macOS 13.0, *)
    @objc func openSwiftUIPreferences(_ sender: Any?) {
        SwiftUIPreferencesWindowController.showPreferences()
    }
}

// MARK: - App Delegate Extension for SwiftUI Integration

extension AppDelegate {
    
    /// Opens the appropriate preferences window based on macOS version
    func openPreferences() {
        if #available(macOS 13.0, *) {
            // Use new SwiftUI preferences on macOS 13+
            SwiftUIPreferencesWindowController.showPreferences()
        } else {
            // Fall back to storyboard-based preferences
            openLegacyPreferences()
        }
    }
    
    /// Opens the legacy storyboard-based preferences window
    private func openLegacyPreferences() {
        guard let storyboard = NSStoryboard(name: "Preferences", bundle: nil) as NSStoryboard?,
              let windowController = storyboard.instantiateInitialController() as? NSWindowController else {
            // Log error and show alert if storyboard cannot be loaded
            NSLog("LyricsX: Failed to load Preferences storyboard")
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Error", comment: "Error alert title")
            alert.informativeText = NSLocalizedString("Could not open preferences window.", comment: "Preferences error message")
            alert.alertStyle = .warning
            alert.runModal()
            return
        }
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 13.0, *)
struct SwiftUIHosting_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
#endif
