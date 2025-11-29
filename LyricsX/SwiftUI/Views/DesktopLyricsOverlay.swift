//
//  DesktopLyricsOverlay.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

// MARK: - Desktop Lyrics Overlay View

/// A modern SwiftUI implementation of the desktop lyrics overlay
@available(macOS 12.0, *)
public struct DesktopLyricsOverlay: View {
    @ObservedObject var viewModel: DesktopLyricsViewModel
    
    @State private var isHovered = false
    @State private var dragOffset: CGSize = .zero
    
    public init(viewModel: DesktopLyricsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isVisible && !viewModel.line1.isEmpty {
                    lyricsContent
                        .position(
                            x: geometry.size.width * viewModel.xPositionFactor,
                            y: geometry.size.height * viewModel.yPositionFactor
                        )
                        .offset(dragOffset)
                        .opacity(shouldHide ? 0 : 1)
                        .animation(LyricsXAnimation.standard, value: shouldHide)
                        .gesture(dragGesture(in: geometry))
                        .onHover { hovering in
                            if viewModel.hideOnMouseOver {
                                isHovered = hovering
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
    
    private var shouldHide: Bool {
        isHovered && viewModel.hideOnMouseOver && !viewModel.isDraggable
    }
    
    @ViewBuilder
    private var lyricsContent: some View {
        Group {
            if viewModel.isVertical {
                HStack(spacing: viewModel.fontSize / 3) {
                    if !viewModel.line2.isEmpty {
                        LyricsTextView(
                            text: viewModel.line2,
                            progress: 0,
                            settings: viewModel
                        )
                    }
                    
                    LyricsTextView(
                        text: viewModel.line1,
                        progress: viewModel.progress,
                        settings: viewModel
                    )
                }
            } else {
                VStack(spacing: viewModel.fontSize / 3) {
                    LyricsTextView(
                        text: viewModel.line1,
                        progress: viewModel.progress,
                        settings: viewModel
                    )
                    
                    if !viewModel.line2.isEmpty {
                        LyricsTextView(
                            text: viewModel.line2,
                            progress: 0,
                            settings: viewModel
                        )
                    }
                }
            }
        }
        .padding(.horizontal, viewModel.fontSize)
        .padding(.vertical, viewModel.fontSize / 3)
        .background(viewModel.backgroundColor)
        .cornerRadius(viewModel.fontSize / 2)
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard viewModel.isDraggable else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard viewModel.isDraggable else { return }
                
                // Calculate new position factors
                let currentX = geometry.size.width * viewModel.xPositionFactor + value.translation.width
                let currentY = geometry.size.height * viewModel.yPositionFactor + value.translation.height
                
                var newXFactor = currentX / geometry.size.width
                var newYFactor = currentY / geometry.size.height
                
                // Snap to center if close
                if abs(newXFactor - 0.5) < 0.02 {
                    newXFactor = 0.5
                }
                if abs(newYFactor - 0.5) < 0.02 {
                    newYFactor = 0.5
                }
                
                // Clamp to valid range
                newXFactor = max(0.1, min(0.9, newXFactor))
                newYFactor = max(0.1, min(0.9, newYFactor))
                
                viewModel.xPositionFactor = newXFactor
                viewModel.yPositionFactor = newYFactor
                
                dragOffset = .zero
            }
    }
}

// MARK: - Lyrics Text View with Progress

@available(macOS 12.0, *)
struct LyricsTextView: View {
    let text: String
    let progress: Double
    let settings: DesktopLyricsViewModel
    
    var body: some View {
        ZStack {
            // Base text
            Text(text)
                .font(.system(size: settings.fontSize, weight: .semibold, design: .rounded))
                .foregroundColor(settings.textColor)
                .shadow(color: settings.shadowColor.opacity(0.8), radius: 3, x: 0, y: 0)
            
            // Progress overlay
            if progress > 0 {
                Text(text)
                    .font(.system(size: settings.fontSize, weight: .semibold, design: .rounded))
                    .foregroundColor(settings.progressColor)
                    .shadow(color: settings.shadowColor.opacity(0.8), radius: 3, x: 0, y: 0)
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: geometry.size.width * progress)
                        }
                    )
            }
        }
        .rotationEffect(settings.isVertical ? .degrees(-90) : .zero)
        .fixedSize()
    }
}

// MARK: - Desktop Lyrics View Model

@available(macOS 12.0, *)
public class DesktopLyricsViewModel: ObservableObject {
    // Content
    @Published public var line1: String = ""
    @Published public var line2: String = ""
    @Published public var progress: Double = 0
    
    // Visibility
    @Published public var isVisible: Bool = true
    
    // Position
    @Published public var xPositionFactor: CGFloat = 0.5
    @Published public var yPositionFactor: CGFloat = 0.9
    
    // Style
    @Published public var fontSize: CGFloat = 24
    @Published public var textColor: Color = .white
    @Published public var progressColor: Color = Color(red: 0.2, green: 1.0, blue: 0.87)
    @Published public var shadowColor: Color = Color(red: 0.0, green: 1.0, blue: 0.83)
    @Published public var backgroundColor: Color = Color.black.opacity(0.6)
    
    // Behavior
    @Published public var isVertical: Bool = false
    @Published public var hideOnMouseOver: Bool = true
    @Published public var isDraggable: Bool = true
    
    public init() {
        loadFromUserDefaults()
    }
    
    /// Load settings from UserDefaults
    public func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        isVisible = defaults.bool(forKey: "DesktopLyricsEnabled")
        
        // Use object(forKey:) to distinguish between 0 and unset values
        if let xFactor = defaults.object(forKey: "DesktopLyricsXPositionFactor") as? Double {
            xPositionFactor = CGFloat(xFactor)
        }
        if let yFactor = defaults.object(forKey: "DesktopLyricsYPositionFactor") as? Double {
            yPositionFactor = CGFloat(yFactor)
        }
        if let size = defaults.object(forKey: "DesktopLyricsFontSize") as? Int, size > 0 {
            fontSize = CGFloat(size)
        }
        
        isVertical = defaults.bool(forKey: "DesktopLyricsVerticalMode")
        hideOnMouseOver = defaults.bool(forKey: "HideLyricsWhenMousePassingBy")
        isDraggable = defaults.bool(forKey: "DesktopLyricsDraggable")
    }
    
    /// Save position to UserDefaults
    public func savePosition() {
        let defaults = UserDefaults.standard
        defaults.set(Double(xPositionFactor), forKey: "DesktopLyricsXPositionFactor")
        defaults.set(Double(yPositionFactor), forKey: "DesktopLyricsYPositionFactor")
    }
    
    /// Update the displayed lyrics
    public func updateLyrics(line1: String, line2: String = "", progress: Double = 0) {
        self.line1 = line1
        self.line2 = line2
        self.progress = progress
    }
}

// MARK: - SwiftUI Desktop Lyrics Window Controller

@available(macOS 12.0, *)
public class SwiftUIDesktopLyricsController {
    
    public static let shared = SwiftUIDesktopLyricsController()
    
    private var window: NSWindow?
    public let viewModel = DesktopLyricsViewModel()
    
    private init() {}
    
    /// Show the desktop lyrics overlay window
    public func show() {
        if window == nil {
            setupWindow()
        }
        window?.orderFront(nil)
    }
    
    /// Hide the desktop lyrics overlay window
    public func hide() {
        window?.orderOut(nil)
    }
    
    /// Update the lyrics display
    public func updateLyrics(line1: String, line2: String = "", progress: Double = 0) {
        viewModel.updateLyrics(line1: line1, line2: line2, progress: progress)
    }
    
    private func setupWindow() {
        let contentView = DesktopLyricsOverlay(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = false
        window.contentView = hostingView
        
        // Make the window span the entire screen
        if let screen = NSScreen.main {
            window.setFrame(screen.frame, display: true)
        }
        
        self.window = window
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 12.0, *)
struct DesktopLyricsOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DesktopLyricsViewModel()
        viewModel.line1 = "Never gonna give you up"
        viewModel.line2 = "永远不会放弃你"
        viewModel.progress = 0.6
        viewModel.isVisible = true
        
        return DesktopLyricsOverlay(viewModel: viewModel)
            .frame(width: 800, height: 600)
            .background(Color.gray.opacity(0.3))
    }
}
#endif
