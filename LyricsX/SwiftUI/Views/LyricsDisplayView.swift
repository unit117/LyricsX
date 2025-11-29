//
//  LyricsDisplayView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// A SwiftUI view for displaying lyrics with progress animation
/// This view is designed to work alongside the existing KaraokeLyricsView
@available(macOS 12.0, *)
public struct LyricsDisplayView: View {
    let line1: String
    let line2: String?
    let progress: Double // 0.0 to 1.0
    
    @State private var textColor: Color = .white
    @State private var progressColor: Color = LyricsXColors.accent
    @State private var shadowColor: Color = LyricsXColors.secondaryAccent
    @State private var backgroundColor: Color = .black.opacity(0.6)
    @State private var fontSize: CGFloat = 24
    @State private var isVertical: Bool = false
    
    public init(
        line1: String,
        line2: String? = nil,
        progress: Double = 0
    ) {
        self.line1 = line1
        self.line2 = line2
        self.progress = progress
    }
    
    public var body: some View {
        Group {
            if isVertical {
                HStack(spacing: fontSize / 3) {
                    if let line2 = line2, !line2.isEmpty {
                        LyricsLineView(
                            text: line2,
                            progress: 0,
                            textColor: textColor,
                            progressColor: progressColor,
                            shadowColor: shadowColor,
                            fontSize: fontSize,
                            isVertical: true
                        )
                    }
                    
                    LyricsLineView(
                        text: line1,
                        progress: progress,
                        textColor: textColor,
                        progressColor: progressColor,
                        shadowColor: shadowColor,
                        fontSize: fontSize,
                        isVertical: true
                    )
                }
            } else {
                VStack(spacing: fontSize / 3) {
                    LyricsLineView(
                        text: line1,
                        progress: progress,
                        textColor: textColor,
                        progressColor: progressColor,
                        shadowColor: shadowColor,
                        fontSize: fontSize,
                        isVertical: false
                    )
                    
                    if let line2 = line2, !line2.isEmpty {
                        LyricsLineView(
                            text: line2,
                            progress: 0,
                            textColor: textColor,
                            progressColor: progressColor,
                            shadowColor: shadowColor,
                            fontSize: fontSize,
                            isVertical: false
                        )
                    }
                }
            }
        }
        .padding(.horizontal, fontSize)
        .padding(.vertical, fontSize / 3)
        .background(backgroundColor)
        .cornerRadius(fontSize / 2)
    }
    
    // MARK: - Modifiers
    
    public func textColor(_ color: Color) -> LyricsDisplayView {
        var copy = self
        copy._textColor = State(initialValue: color)
        return copy
    }
    
    public func progressColor(_ color: Color) -> LyricsDisplayView {
        var copy = self
        copy._progressColor = State(initialValue: color)
        return copy
    }
    
    public func shadowColor(_ color: Color) -> LyricsDisplayView {
        var copy = self
        copy._shadowColor = State(initialValue: color)
        return copy
    }
    
    public func backgroundColor(_ color: Color) -> LyricsDisplayView {
        var copy = self
        copy._backgroundColor = State(initialValue: color)
        return copy
    }
    
    public func fontSize(_ size: CGFloat) -> LyricsDisplayView {
        var copy = self
        copy._fontSize = State(initialValue: size)
        return copy
    }
    
    public func vertical(_ isVertical: Bool) -> LyricsDisplayView {
        var copy = self
        copy._isVertical = State(initialValue: isVertical)
        return copy
    }
}

/// A single line of lyrics with progress fill
@available(macOS 12.0, *)
struct LyricsLineView: View {
    let text: String
    let progress: Double
    let textColor: Color
    let progressColor: Color
    let shadowColor: Color
    let fontSize: CGFloat
    let isVertical: Bool
    
    var body: some View {
        ZStack {
            // Base text (unfilled)
            Text(text)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
                .shadow(color: shadowColor.opacity(0.8), radius: 3, x: 0, y: 0)
            
            // Progress overlay (filled portion)
            Text(text)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundColor(progressColor)
                .shadow(color: shadowColor.opacity(0.8), radius: 3, x: 0, y: 0)
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                            .frame(width: geometry.size.width * progress)
                    }
                )
        }
        .rotationEffect(isVertical ? .degrees(90) : .zero)
    }
}

/// A scrollable list of lyrics lines
@available(macOS 12.0, *)
public struct LyricsListView: View {
    let lines: [LyricsLine]
    let currentIndex: Int?
    let onLineSelected: ((Int) -> Void)?
    
    public init(
        lines: [LyricsLine],
        currentIndex: Int? = nil,
        onLineSelected: ((Int) -> Void)? = nil
    ) {
        self.lines = lines
        self.currentIndex = currentIndex
        self.onLineSelected = onLineSelected
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: LyricsXSpacing.md) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        LyricsListRow(
                            line: line,
                            isHighlighted: currentIndex == index
                        )
                        .id(index)
                        .onTapGesture {
                            onLineSelected?(index)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: currentIndex) { newIndex in
                if let index = newIndex {
                    withAnimation(LyricsXAnimation.smooth) {
                        proxy.scrollTo(index, anchor: .center)
                    }
                }
            }
        }
    }
}

/// A single row in the lyrics list
@available(macOS 12.0, *)
struct LyricsListRow: View {
    let line: LyricsLine
    let isHighlighted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: LyricsXSpacing.xs) {
            Text(line.content)
                .font(isHighlighted ? LyricsXTypography.lyricsMedium() : LyricsXTypography.lyricsSmall())
                .foregroundColor(isHighlighted ? LyricsXColors.accent : LyricsXColors.textPrimary)
            
            if let translation = line.translation {
                Text(translation)
                    .font(LyricsXTypography.caption)
                    .foregroundColor(LyricsXColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, LyricsXSpacing.sm)
        .padding(.horizontal, LyricsXSpacing.md)
        .background(isHighlighted ? LyricsXColors.accent.opacity(0.1) : Color.clear)
        .cornerRadius(LyricsXRadius.medium)
        .animation(LyricsXAnimation.standard, value: isHighlighted)
    }
}

/// Model for a lyrics line
public struct LyricsLine: Identifiable {
    public let id = UUID()
    public let content: String
    public let translation: String?
    public let timestamp: TimeInterval
    
    public init(content: String, translation: String? = nil, timestamp: TimeInterval = 0) {
        self.content = content
        self.translation = translation
        self.timestamp = timestamp
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct LyricsDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Horizontal lyrics
            LyricsDisplayView(
                line1: "Never gonna give you up",
                line2: "永远不会放弃你",
                progress: 0.6
            )
            
            // Vertical lyrics
            LyricsDisplayView(
                line1: "さくら",
                progress: 0.4
            )
            .vertical(true)
            .fontSize(32)
        }
        .padding(50)
        .background(Color.gray.opacity(0.3))
    }
}

@available(macOS 12.0, *)
struct LyricsListView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsListView(
            lines: [
                LyricsLine(content: "We're no strangers to love", timestamp: 0),
                LyricsLine(content: "You know the rules and so do I", translation: "你知道规则，我也知道", timestamp: 4),
                LyricsLine(content: "A full commitment's what I'm thinking of", timestamp: 8),
                LyricsLine(content: "You wouldn't get this from any other guy", timestamp: 12),
                LyricsLine(content: "I just wanna tell you how I'm feeling", timestamp: 16),
                LyricsLine(content: "Gotta make you understand", timestamp: 20),
                LyricsLine(content: "Never gonna give you up", translation: "永远不会放弃你", timestamp: 24),
                LyricsLine(content: "Never gonna let you down", timestamp: 28),
            ],
            currentIndex: 6
        )
        .frame(width: 400, height: 300)
    }
}
#endif
