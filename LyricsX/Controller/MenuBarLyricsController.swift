//
//  MenuBarLyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import CXExtensions
import CXShim
import GenericID
import LyricsCore
import MusicPlayer
import OpenCC
import SwiftCF
import AccessibilityExt

class MenuBarLyricsController {
    
    static let shared = MenuBarLyricsController()
    
    let statusItem: NSStatusItem
    var lyricsItem: NSStatusItem?
    var buttonImage = #imageLiteral(resourceName: "status_bar_icon")
    var buttonlength: CGFloat = 30
    
    private var screenLyrics = "" {
        didSet {
            DispatchQueue.main.async {
                self.updateStatusItem()
            }
        }
    }
    
    // MARK: - Observation Storage
    
    /// Cancellable storage for Combine subscriptions (used for bridging with legacy @Published)
    private var cancelBag = Set<AnyCancellable>()
    
    /// Task for observing workspace notifications
    private var workspaceNotificationTask: Task<Void, Never>?
    
    /// Task for observing user defaults changes
    private var defaultsObservationTask: Task<Void, Never>?
    
    /// Observation token for defaults KVO (used until full async migration)
    private var defaultsObservation: DefaultsObservation?
    
    // MARK: - Initialization
    
    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupObservations()
    }
    
    deinit {
        cancelAllObservations()
    }
    
    // MARK: - Setup
    
    private func setupObservations() {
        // Subscribe to lyrics display changes using Combine (bridging with AppController's @Published)
        // This will be migrated when AppController moves to @Observable
        AppController.shared.$currentLyrics
            .combineLatest(AppController.shared.$currentLineIndex)
            .receive(on: DispatchQueue.lyricsDisplay.cx)
            .invoke(MenuBarLyricsController.handleLyricsDisplay, weaklyOn: self)
            .store(in: &cancelBag)
        
        // Observe workspace notifications using async Task
        setupWorkspaceNotificationObservation()
        
        // Observe defaults changes using KVO observation
        setupDefaultsObservation()
    }
    
    /// Sets up observation for workspace application activation notifications.
    private func setupWorkspaceNotificationObservation() {
        workspaceNotificationTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(
                named: NSWorkspace.didActivateApplicationNotification,
                object: nil
            )
            for await _ in notifications {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self?.updateStatusItem()
                }
            }
        }
    }
    
    /// Sets up observation for user defaults changes.
    private func setupDefaultsObservation() {
        // Use defaults observation for menu bar and combined lyrics settings
        defaultsObservation = defaults.observe(keys: [.menuBarLyricsEnabled, .combinedMenubarLyrics]) { [weak self] in
            DispatchQueue.main.async {
                self?.updateStatusItem()
            }
        }
        // Initial update
        updateStatusItem()
    }
    
    /// Cancels all active observations.
    private func cancelAllObservations() {
        workspaceNotificationTask?.cancel()
        workspaceNotificationTask = nil
        defaultsObservationTask?.cancel()
        defaultsObservationTask = nil
        defaultsObservation = nil
        cancelBag.removeAll()
    }
    
    // MARK: - Lyrics Display Handler
    
    private func handleLyricsDisplay(event: (lyrics: Lyrics?, index: Int?)) {
        guard !defaults[.disableLyricsWhenPaused] || selectedPlayer.playbackState.isPlaying,
            let lyrics = event.lyrics,
            let index = event.index else {
            screenLyrics = ""
            return
        }
        var newScreenLyrics = lyrics.lines[index].content
        if let converter = ChineseConverter.shared, lyrics.metadata.language?.hasPrefix("zh") == true {
            newScreenLyrics = converter.convert(newScreenLyrics)
        }
        if newScreenLyrics == screenLyrics {
            return
        }
        screenLyrics = newScreenLyrics
    }
    
    // MARK: - Status Item Updates
    
    @objc private func updateStatusItem() {
        guard defaults[.menuBarLyricsEnabled], !screenLyrics.isEmpty else {
            setImageStatusItem()
            lyricsItem = nil
            return
        }
        
        if defaults[.combinedMenubarLyrics] {
            updateCombinedStatusLyrics()
        } else {
            updateSeparateStatusLyrics()
        }
    }
    
    private func updateSeparateStatusLyrics() {
        setImageStatusItem()
        
        if lyricsItem == nil {
            lyricsItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            lyricsItem?.highlightMode = false
        }
        lyricsItem?.title = screenLyrics
    }
    
    private func updateCombinedStatusLyrics() {
        lyricsItem = nil
        
        setTextStatusItem(string: screenLyrics)
        if statusItem.isVisibe {
            return
        }
        
        // truncation
        var components = screenLyrics.components(options: [.byWords])
        while !components.isEmpty, !statusItem.isVisibe {
            components.removeLast()
            let proposed = components.joined() + "..."
            setTextStatusItem(string: proposed)
        }
    }
    
    private func setTextStatusItem(string: String) {
        statusItem.title = string
        statusItem.image = nil
        statusItem.length = NSStatusItem.variableLength
    }
    
    private func setImageStatusItem() {
        statusItem.title = ""
        statusItem.image = buttonImage
        statusItem.length = buttonlength
    }
}

// MARK: - Status Item Visibility

private extension NSStatusItem {
    
    var isVisibe: Bool {
        guard let buttonFrame = button?.frame,
            let frame = button?.window?.convertToScreen(buttonFrame) else {
                return false
        }
        
        let point = CGPoint(x: frame.midX, y: frame.midY)
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(point) }) else {
            return false
        }
        let carbonPoint = CGPoint(x: point.x, y: screen.frame.height - point.y - 1)
        
        guard let element = try? AXUIElement.systemWide().element(at: carbonPoint),
            let pid = try? element.pid() else {
            return false
        }
        
        return getpid() == pid
    }
}

private extension String {
    
    func components(options: String.EnumerationOptions) -> [String] {
        var components: [String] = []
        let range = Range(uncheckedBounds: (startIndex, endIndex))
        enumerateSubstrings(in: range, options: options) { _, _, range, _ in
            components.append(String(self[range]))
        }
        return components
    }
}
