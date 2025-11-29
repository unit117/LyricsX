//
//  View+Accessibility.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

// MARK: - Accessibility Extensions for Lyrics Views

@available(macOS 12.0, *)
extension View {
    
    /// Applies accessibility modifiers for lyrics display views.
    ///
    /// This modifier configures the view for VoiceOver support, announcing
    /// the current lyrics line along with track information.
    ///
    /// - Parameters:
    ///   - currentLine: The currently displayed lyrics line.
    ///   - artist: The artist name of the current track.
    ///   - title: The title of the current track.
    /// - Returns: A view with accessibility modifiers applied.
    public func lyricsAccessibility(
        currentLine: String,
        artist: String,
        title: String
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                String(
                    format: NSLocalizedString(
                        "Now playing: %@ by %@",
                        comment: "Accessibility label for current track"
                    ),
                    title,
                    artist
                )
            )
            .accessibilityValue(currentLine)
            .accessibilityHint(
                NSLocalizedString(
                    "Current lyrics line",
                    comment: "Accessibility hint for lyrics display"
                )
            )
            .accessibilityAddTraits(.updatesFrequently)
    }
    
    /// Applies accessibility modifiers for desktop lyrics overlay.
    ///
    /// - Parameters:
    ///   - line1: The primary lyrics line.
    ///   - line2: The secondary lyrics line (translation or next line).
    ///   - isVisible: Whether the lyrics are currently visible.
    /// - Returns: A view with accessibility modifiers applied.
    public func desktopLyricsAccessibility(
        line1: String,
        line2: String,
        isVisible: Bool
    ) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                NSLocalizedString(
                    "Desktop Lyrics Overlay",
                    comment: "Accessibility label for desktop lyrics"
                )
            )
            .accessibilityValue(
                isVisible ? lyricsAccessibilityValue(line1: line1, line2: line2) :
                    NSLocalizedString("Hidden", comment: "Accessibility value when lyrics hidden")
            )
            .accessibilityAddTraits(.updatesFrequently)
            .accessibilityHint(
                NSLocalizedString(
                    "Double-tap to toggle visibility. Drag to reposition.",
                    comment: "Accessibility hint for desktop lyrics overlay"
                )
            )
    }
    
    /// Applies accessibility modifiers for search result items.
    ///
    /// - Parameters:
    ///   - title: The track title.
    ///   - artist: The artist name.
    ///   - source: The lyrics source provider.
    /// - Returns: A view with accessibility modifiers applied.
    public func searchResultAccessibility(
        title: String,
        artist: String,
        source: String
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                String(
                    format: NSLocalizedString(
                        "%@ by %@",
                        comment: "Accessibility label for search result"
                    ),
                    title,
                    artist
                )
            )
            .accessibilityValue(
                String(
                    format: NSLocalizedString(
                        "Source: %@",
                        comment: "Accessibility value for lyrics source"
                    ),
                    source
                )
            )
            .accessibilityHint(
                NSLocalizedString(
                    "Double-tap to select these lyrics",
                    comment: "Accessibility hint for search result"
                )
            )
            .accessibilityAddTraits(.isButton)
    }
    
    /// Applies accessibility modifiers for playback control buttons.
    ///
    /// - Parameters:
    ///   - action: The action description (e.g., "Play", "Pause", "Skip").
    ///   - isEnabled: Whether the control is currently enabled.
    /// - Returns: A view with accessibility modifiers applied.
    public func playbackControlAccessibility(
        action: String,
        isEnabled: Bool
    ) -> some View {
        self
            .accessibilityLabel(action)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(
                isEnabled ?
                    String(
                        format: NSLocalizedString(
                            "Double-tap to %@",
                            comment: "Accessibility hint for playback control"
                        ),
                        action.lowercased()
                    ) :
                    NSLocalizedString(
                        "Currently unavailable",
                        comment: "Accessibility hint when control is disabled"
                    )
            )
            .accessibilityRemoveTraits(isEnabled ? [] : .isButton)
    }
    
    /// Applies accessibility modifiers for toggle controls in preferences.
    ///
    /// - Parameters:
    ///   - label: The setting label.
    ///   - isOn: Whether the toggle is currently on.
    ///   - description: Additional description of the setting.
    /// - Returns: A view with accessibility modifiers applied.
    public func settingsToggleAccessibility(
        label: String,
        isOn: Bool,
        description: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue(
                isOn ?
                    NSLocalizedString("On", comment: "Toggle state on") :
                    NSLocalizedString("Off", comment: "Toggle state off")
            )
            .accessibilityHint(
                description ?? NSLocalizedString(
                    "Double-tap to toggle",
                    comment: "Default toggle hint"
                )
            )
    }
    
    /// Applies accessibility modifiers for slider controls.
    ///
    /// - Parameters:
    ///   - label: The slider label.
    ///   - value: The current value.
    ///   - unit: The unit of measurement.
    ///   - decimalPlaces: Number of decimal places to show (default: 0 for integers).
    /// - Returns: A view with accessibility modifiers applied.
    public func sliderAccessibility(
        label: String,
        value: Double,
        unit: String,
        decimalPlaces: Int = 0
    ) -> some View {
        let formattedValue: String
        if decimalPlaces > 0 {
            formattedValue = String(format: "%.\(decimalPlaces)f", value)
        } else {
            formattedValue = String(format: "%.0f", value)
        }
        
        return self
            .accessibilityLabel(label)
            .accessibilityValue("\(formattedValue) \(unit)")
            .accessibilityAdjustableAction { direction in
                // Note: Actual adjustment is handled by the slider itself
                // This is for VoiceOver gesture support
            }
    }
    
    // MARK: - Private Helpers
    
    private func lyricsAccessibilityValue(line1: String, line2: String) -> String {
        if line1.isEmpty && line2.isEmpty {
            return NSLocalizedString(
                "No lyrics displayed",
                comment: "Accessibility value when no lyrics"
            )
        } else if line2.isEmpty {
            return line1
        } else {
            return "\(line1). \(line2)"
        }
    }
}

// MARK: - Accessibility Rotor Support

@available(macOS 12.0, *)
extension View {
    
    /// Adds a custom accessibility rotor for lyrics navigation.
    ///
    /// This enables VoiceOver users to quickly navigate between lyrics lines.
    ///
    /// - Parameters:
    ///   - lines: The array of lyrics lines.
    ///   - currentIndex: The index of the currently displayed line.
    ///   - onSelect: Callback when a line is selected via rotor.
    /// - Returns: A view with the custom rotor added.
    public func lyricsRotor(
        lines: [String],
        currentIndex: Int,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        self.accessibilityRotor(
            NSLocalizedString("Lyrics Lines", comment: "Accessibility rotor name")
        ) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                AccessibilityRotorEntry(
                    "\(index + 1): \(line)",
                    id: index,
                    textRange: nil,
                    prepare: { onSelect(index) }
                )
            }
        }
    }
}

// MARK: - Accessibility Announcements

@available(macOS 12.0, *)
public enum LyricsAccessibility {
    
    /// Posts an accessibility announcement for a new lyrics line.
    ///
    /// - Parameter line: The lyrics line to announce.
    public static func announceLyricsLine(_ line: String) {
        guard !line.isEmpty else { return }
        
        #if os(macOS)
        NSAccessibility.post(
            element: NSApp.mainWindow as Any,
            notification: .announcementRequested,
            userInfo: [
                .announcement: line,
                .priority: NSAccessibilityPriorityLevel.high.rawValue
            ]
        )
        #endif
    }
    
    /// Posts an accessibility announcement for track change.
    ///
    /// - Parameters:
    ///   - title: The track title.
    ///   - artist: The artist name.
    public static func announceTrackChange(title: String, artist: String) {
        let announcement = String(
            format: NSLocalizedString(
                "Now playing: %@ by %@",
                comment: "Track change announcement"
            ),
            title,
            artist
        )
        
        #if os(macOS)
        NSAccessibility.post(
            element: NSApp.mainWindow as Any,
            notification: .announcementRequested,
            userInfo: [
                .announcement: announcement,
                .priority: NSAccessibilityPriorityLevel.medium.rawValue
            ]
        )
        #endif
    }
    
    /// Posts an accessibility announcement for lyrics status change.
    ///
    /// - Parameter status: The status message to announce.
    public static func announceStatus(_ status: String) {
        #if os(macOS)
        NSAccessibility.post(
            element: NSApp.mainWindow as Any,
            notification: .announcementRequested,
            userInfo: [
                .announcement: status,
                .priority: NSAccessibilityPriorityLevel.low.rawValue
            ]
        )
        #endif
    }
}
