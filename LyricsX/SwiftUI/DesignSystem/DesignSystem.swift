//
//  DesignSystem.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

// MARK: - Color Palette

/// LyricsX Design System color palette
public enum LyricsXColors {
    
    // MARK: Primary Colors
    
    /// Primary accent color (cyan/teal)
    public static let accent = Color(nsColor: NSColor(red: 0.2, green: 1.0, blue: 0.87, alpha: 1.0))
    
    /// Secondary accent color
    public static let secondaryAccent = Color(nsColor: NSColor(red: 0.0, green: 1.0, blue: 0.83, alpha: 1.0))
    
    // MARK: Text Colors
    
    /// Primary text color
    public static let textPrimary = Color.primary
    
    /// Secondary text color
    public static let textSecondary = Color.secondary
    
    /// Lyrics text color (default white)
    public static let lyricsText = Color.white
    
    /// Lyrics progress/highlight color
    public static let lyricsProgress = accent
    
    // MARK: Background Colors
    
    /// Primary background
    public static let backgroundPrimary = Color(nsColor: .windowBackgroundColor)
    
    /// Secondary background (for cards/sections)
    public static let backgroundSecondary = Color(nsColor: .controlBackgroundColor)
    
    /// Lyrics overlay background
    public static let lyricsBackground = Color.black.opacity(0.6)
    
    // MARK: Semantic Colors
    
    /// Success color
    public static let success = Color.green
    
    /// Warning color
    public static let warning = Color.orange
    
    /// Error color
    public static let error = Color.red
    
    /// Disabled state color
    public static let disabled = Color.gray.opacity(0.5)
}

// MARK: - Typography

/// LyricsX Design System typography
public enum LyricsXTypography {
    
    // MARK: Display Fonts (for lyrics)
    
    /// Large lyrics display font
    public static func lyricsLarge(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    /// Medium lyrics display font
    public static func lyricsMedium(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    /// Small lyrics display font
    public static func lyricsSmall(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    // MARK: UI Fonts
    
    /// Title font
    public static let title = Font.title2.weight(.semibold)
    
    /// Headline font
    public static let headline = Font.headline
    
    /// Body font
    public static let body = Font.body
    
    /// Caption font
    public static let caption = Font.caption
    
    /// Monospace font for technical content
    public static let monospace = Font.system(.body, design: .monospaced)
}

// MARK: - Spacing

/// LyricsX Design System spacing constants
public enum LyricsXSpacing {
    /// Extra small spacing (4pt)
    public static let xs: CGFloat = 4
    
    /// Small spacing (8pt)
    public static let sm: CGFloat = 8
    
    /// Medium spacing (12pt)
    public static let md: CGFloat = 12
    
    /// Large spacing (16pt)
    public static let lg: CGFloat = 16
    
    /// Extra large spacing (24pt)
    public static let xl: CGFloat = 24
    
    /// Double extra large spacing (32pt)
    public static let xxl: CGFloat = 32
}

// MARK: - Corner Radius

/// LyricsX Design System corner radius constants
public enum LyricsXRadius {
    /// Small radius (4pt)
    public static let small: CGFloat = 4
    
    /// Medium radius (8pt)
    public static let medium: CGFloat = 8
    
    /// Large radius (12pt)
    public static let large: CGFloat = 12
    
    /// Extra large radius (16pt)
    public static let extraLarge: CGFloat = 16
}

// MARK: - Animation

/// LyricsX Design System animation constants
public enum LyricsXAnimation {
    /// Quick animation (0.15s)
    public static let quick = Animation.easeOut(duration: 0.15)
    
    /// Standard animation (0.25s)
    public static let standard = Animation.easeInOut(duration: 0.25)
    
    /// Smooth animation (0.35s)
    public static let smooth = Animation.easeInOut(duration: 0.35)
    
    /// Spring animation
    public static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

// MARK: - View Extensions

extension View {
    /// Apply LyricsX card style
    public func lyricsXCard() -> some View {
        self
            .padding(LyricsXSpacing.lg)
            .background(LyricsXColors.backgroundSecondary)
            .cornerRadius(LyricsXRadius.large)
    }
    
    /// Apply LyricsX section style
    public func lyricsXSection() -> some View {
        self
            .padding(.vertical, LyricsXSpacing.sm)
    }
    
    /// Apply standard shadow
    public func lyricsXShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Button Styles

/// LyricsX Primary Button Style
public struct LyricsXPrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LyricsXTypography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, LyricsXSpacing.lg)
            .padding(.vertical, LyricsXSpacing.sm)
            .background(LyricsXColors.accent)
            .cornerRadius(LyricsXRadius.medium)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(LyricsXAnimation.quick, value: configuration.isPressed)
    }
}

/// LyricsX Secondary Button Style
public struct LyricsXSecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LyricsXTypography.headline)
            .foregroundColor(LyricsXColors.accent)
            .padding(.horizontal, LyricsXSpacing.lg)
            .padding(.vertical, LyricsXSpacing.sm)
            .background(LyricsXColors.backgroundSecondary)
            .cornerRadius(LyricsXRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: LyricsXRadius.medium)
                    .stroke(LyricsXColors.accent, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(LyricsXAnimation.quick, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == LyricsXPrimaryButtonStyle {
    public static var lyricsXPrimary: LyricsXPrimaryButtonStyle { LyricsXPrimaryButtonStyle() }
}

extension ButtonStyle where Self == LyricsXSecondaryButtonStyle {
    public static var lyricsXSecondary: LyricsXSecondaryButtonStyle { LyricsXSecondaryButtonStyle() }
}
