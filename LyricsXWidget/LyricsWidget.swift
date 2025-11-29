//
//  LyricsWidget.swift
//  LyricsXWidget - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WidgetKit
import SwiftUI

// MARK: - Lyrics Widget

/// A macOS widget that displays current song lyrics.
///
/// This widget provides a quick preview of the currently playing song's lyrics,
/// available in small and medium sizes.
@available(macOS 14.0, *)
@main
struct LyricsWidget: Widget {
    
    /// The widget identifier.
    let kind: String = "com.ddddxxx.LyricsX.Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LyricsTimelineProvider()) { entry in
            LyricsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(
            NSLocalizedString(
                "widget.title",
                value: "Lyrics Preview",
                comment: "Widget display name"
            )
        )
        .description(
            NSLocalizedString(
                "widget.description",
                value: "Shows current song lyrics",
                comment: "Widget description"
            )
        )
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Entry

/// The timeline entry for the lyrics widget.
struct LyricsEntry: TimelineEntry {
    
    /// The date for this entry.
    let date: Date
    
    /// The current lyrics line.
    let currentLine: String
    
    /// The next lyrics line.
    let nextLine: String
    
    /// The track title.
    let trackTitle: String
    
    /// The artist name.
    let artist: String
    
    /// Whether music is currently playing.
    let isPlaying: Bool
    
    /// Creates a placeholder entry.
    static var placeholder: LyricsEntry {
        LyricsEntry(
            date: Date(),
            currentLine: "♪ Lyrics will appear here",
            nextLine: "Start playing music to see lyrics",
            trackTitle: "Song Title",
            artist: "Artist Name",
            isPlaying: false
        )
    }
    
    /// Creates an entry for when no music is playing.
    static var noMusic: LyricsEntry {
        LyricsEntry(
            date: Date(),
            currentLine: NSLocalizedString(
                "widget.noMusic",
                value: "No music playing",
                comment: "Widget placeholder when no music is playing"
            ),
            nextLine: "",
            trackTitle: "",
            artist: "",
            isPlaying: false
        )
    }
    
    /// Creates an entry for when lyrics are not available.
    static func noLyrics(title: String, artist: String) -> LyricsEntry {
        LyricsEntry(
            date: Date(),
            currentLine: NSLocalizedString(
                "widget.noLyrics",
                value: "No lyrics available",
                comment: "Widget placeholder when no lyrics available"
            ),
            nextLine: "",
            trackTitle: title,
            artist: artist,
            isPlaying: true
        )
    }
}

// MARK: - App Group Constants

/// Constants for App Group data sharing.
enum WidgetConstants {
    
    /// The App Group identifier for sharing data between the app and widget.
    static let appGroupIdentifier = "group.com.ddddxxx.LyricsX"
    
    /// User defaults key for current lyrics line.
    static let currentLineKey = "widget.currentLine"
    
    /// User defaults key for next lyrics line.
    static let nextLineKey = "widget.nextLine"
    
    /// User defaults key for track title.
    static let trackTitleKey = "widget.trackTitle"
    
    /// User defaults key for artist name.
    static let artistKey = "widget.artist"
    
    /// User defaults key for playback state.
    static let isPlayingKey = "widget.isPlaying"
    
    /// User defaults key for last update timestamp.
    static let lastUpdateKey = "widget.lastUpdate"
}

// MARK: - Widget Previews

#if DEBUG
@available(macOS 14.0, *)
struct LyricsWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LyricsWidgetView(entry: LyricsEntry(
                date: Date(),
                currentLine: "Never gonna give you up",
                nextLine: "Never gonna let you down",
                trackTitle: "Never Gonna Give You Up",
                artist: "Rick Astley",
                isPlaying: true
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small - Playing")
            
            LyricsWidgetView(entry: LyricsEntry(
                date: Date(),
                currentLine: "Never gonna give you up",
                nextLine: "Never gonna let you down",
                trackTitle: "Never Gonna Give You Up",
                artist: "Rick Astley",
                isPlaying: true
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium - Playing")
            
            LyricsWidgetView(entry: .noMusic)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small - No Music")
            
            LyricsWidgetView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium - Placeholder")
        }
    }
}
#endif
