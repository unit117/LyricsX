//
//  LyricsWidgetView.swift
//  LyricsXWidget - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import WidgetKit

// MARK: - Lyrics Widget View

/// The main view for the lyrics widget.
@available(macOS 14.0, *)
struct LyricsWidgetView: View {
    
    @Environment(\.widgetFamily) var family
    
    let entry: LyricsEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget View

@available(macOS 14.0, *)
struct SmallWidgetView: View {
    
    let entry: LyricsEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Track info
            if !entry.trackTitle.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: entry.isPlaying ? "music.note" : "pause.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.trackTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
            
            // Current lyrics line
            Text(entry.currentLine)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        if entry.trackTitle.isEmpty {
            return entry.currentLine
        }
        return "\(entry.trackTitle) by \(entry.artist). \(entry.currentLine)"
    }
}

// MARK: - Medium Widget View

@available(macOS 14.0, *)
struct MediumWidgetView: View {
    
    let entry: LyricsEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Album art placeholder / Music icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                
                Image(systemName: entry.isPlaying ? "music.quarternote.3" : "pause.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, height: 80)
            
            // Right side: Track info and lyrics
            VStack(alignment: .leading, spacing: 6) {
                // Track info
                if !entry.trackTitle.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.trackTitle)
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        
                        Text(entry.artist)
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Lyrics
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.currentLine)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    
                    if !entry.nextLine.isEmpty {
                        Text(entry.nextLine)
                            .font(.system(.caption, design: .rounded))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        var label = ""
        if !entry.trackTitle.isEmpty {
            label += "\(entry.trackTitle) by \(entry.artist). "
        }
        label += entry.currentLine
        if !entry.nextLine.isEmpty {
            label += ". Next: \(entry.nextLine)"
        }
        return label
    }
}

// MARK: - Preview Provider

#if DEBUG
@available(macOS 14.0, *)
struct LyricsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallWidgetView(entry: LyricsEntry(
                date: Date(),
                currentLine: "Never gonna give you up",
                nextLine: "Never gonna let you down",
                trackTitle: "Never Gonna Give You Up",
                artist: "Rick Astley",
                isPlaying: true
            ))
            .previewDisplayName("Small Widget")
            .frame(width: 155, height: 155)
            
            MediumWidgetView(entry: LyricsEntry(
                date: Date(),
                currentLine: "Never gonna give you up",
                nextLine: "Never gonna let you down",
                trackTitle: "Never Gonna Give You Up",
                artist: "Rick Astley",
                isPlaying: true
            ))
            .previewDisplayName("Medium Widget")
            .frame(width: 329, height: 155)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
#endif
