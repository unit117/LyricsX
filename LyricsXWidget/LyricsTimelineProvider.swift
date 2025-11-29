//
//  LyricsTimelineProvider.swift
//  LyricsXWidget - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WidgetKit
import SwiftUI

// MARK: - Lyrics Timeline Provider

/// Provides timeline entries for the lyrics widget.
///
/// This provider reads shared data from the App Group to get
/// the current lyrics state from the main LyricsX app.
@available(macOS 14.0, *)
struct LyricsTimelineProvider: TimelineProvider {
    
    // MARK: - TimelineProvider Protocol
    
    /// Returns a placeholder entry for the widget gallery.
    func placeholder(in context: Context) -> LyricsEntry {
        .placeholder
    }
    
    /// Returns a snapshot entry for quick display.
    func getSnapshot(in context: Context, completion: @escaping (LyricsEntry) -> Void) {
        let entry = fetchCurrentEntry()
        completion(entry)
    }
    
    /// Returns a timeline of entries for the widget.
    func getTimeline(in context: Context, completion: @escaping (Timeline<LyricsEntry>) -> Void) {
        let currentEntry = fetchCurrentEntry()
        
        // Create timeline entries
        var entries: [LyricsEntry] = []
        
        // Add current entry
        entries.append(currentEntry)
        
        // Widget updates are driven by the main app via WidgetCenter.shared.reloadTimelines
        // We set a fallback refresh in 5 minutes in case the app doesn't trigger updates
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
    
    // MARK: - Data Fetching
    
    /// Fetches the current lyrics entry from shared App Group storage.
    private func fetchCurrentEntry() -> LyricsEntry {
        guard let defaults = UserDefaults(suiteName: WidgetConstants.appGroupIdentifier) else {
            return .noMusic
        }
        
        // Check if there's recent data
        if let lastUpdate = defaults.object(forKey: WidgetConstants.lastUpdateKey) as? Date {
            // If data is older than 30 seconds, consider it stale
            if Date().timeIntervalSince(lastUpdate) > 30 {
                let title = defaults.string(forKey: WidgetConstants.trackTitleKey) ?? ""
                let artist = defaults.string(forKey: WidgetConstants.artistKey) ?? ""
                
                if title.isEmpty {
                    return .noMusic
                }
                
                // Music might still be playing but lyrics aren't updating
                return .noLyrics(title: title, artist: artist)
            }
        }
        
        // Fetch current data
        let currentLine = defaults.string(forKey: WidgetConstants.currentLineKey) ?? ""
        let nextLine = defaults.string(forKey: WidgetConstants.nextLineKey) ?? ""
        let trackTitle = defaults.string(forKey: WidgetConstants.trackTitleKey) ?? ""
        let artist = defaults.string(forKey: WidgetConstants.artistKey) ?? ""
        let isPlaying = defaults.bool(forKey: WidgetConstants.isPlayingKey)
        
        // Return appropriate entry based on state
        if trackTitle.isEmpty && !isPlaying {
            return .noMusic
        }
        
        if currentLine.isEmpty && !trackTitle.isEmpty {
            return .noLyrics(title: trackTitle, artist: artist)
        }
        
        return LyricsEntry(
            date: Date(),
            currentLine: currentLine,
            nextLine: nextLine,
            trackTitle: trackTitle,
            artist: artist,
            isPlaying: isPlaying
        )
    }
}

// MARK: - Widget Data Writer

/// Helper class for the main app to write data to the shared App Group storage.
///
/// Use this from the main LyricsX app to update widget data.
///
/// Example usage:
/// ```swift
/// WidgetDataWriter.shared.updateLyrics(
///     currentLine: "Hello world",
///     nextLine: "Next line",
///     trackTitle: "Song",
///     artist: "Artist",
///     isPlaying: true
/// )
/// ```
@available(macOS 14.0, *)
public class WidgetDataWriter {
    
    /// Shared instance of the widget data writer.
    public static let shared = WidgetDataWriter()
    
    /// User defaults for the App Group.
    private let defaults: UserDefaults?
    
    private init() {
        defaults = UserDefaults(suiteName: WidgetConstants.appGroupIdentifier)
    }
    
    /// Updates the widget with current lyrics data.
    ///
    /// - Parameters:
    ///   - currentLine: The current lyrics line.
    ///   - nextLine: The next lyrics line.
    ///   - trackTitle: The track title.
    ///   - artist: The artist name.
    ///   - isPlaying: Whether music is currently playing.
    public func updateLyrics(
        currentLine: String,
        nextLine: String,
        trackTitle: String,
        artist: String,
        isPlaying: Bool
    ) {
        defaults?.set(currentLine, forKey: WidgetConstants.currentLineKey)
        defaults?.set(nextLine, forKey: WidgetConstants.nextLineKey)
        defaults?.set(trackTitle, forKey: WidgetConstants.trackTitleKey)
        defaults?.set(artist, forKey: WidgetConstants.artistKey)
        defaults?.set(isPlaying, forKey: WidgetConstants.isPlayingKey)
        defaults?.set(Date(), forKey: WidgetConstants.lastUpdateKey)
        
        // Request widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.widgetKind)
    }
    
    /// Clears all widget data (e.g., when stopping playback).
    public func clearData() {
        defaults?.removeObject(forKey: WidgetConstants.currentLineKey)
        defaults?.removeObject(forKey: WidgetConstants.nextLineKey)
        defaults?.removeObject(forKey: WidgetConstants.trackTitleKey)
        defaults?.removeObject(forKey: WidgetConstants.artistKey)
        defaults?.set(false, forKey: WidgetConstants.isPlayingKey)
        defaults?.set(Date(), forKey: WidgetConstants.lastUpdateKey)
        
        // Request widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.widgetKind)
    }
    
    /// Updates the playback state without changing lyrics.
    ///
    /// - Parameter isPlaying: Whether music is currently playing.
    public func updatePlaybackState(isPlaying: Bool) {
        defaults?.set(isPlaying, forKey: WidgetConstants.isPlayingKey)
        defaults?.set(Date(), forKey: WidgetConstants.lastUpdateKey)
        
        // Request widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.widgetKind)
    }
}
