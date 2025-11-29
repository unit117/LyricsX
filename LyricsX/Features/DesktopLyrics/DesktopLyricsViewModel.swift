//
//  DesktopLyricsViewModel.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftUI
import LyricsCore
import MusicPlayer

// MARK: - Desktop Lyrics ViewModel (macOS 14+)

/// ViewModel for the desktop lyrics overlay using the modern @Observable macro.
///
/// This ViewModel observes the music player and lyrics services to provide
/// real-time lyrics display with word-by-word progress animation.
///
/// - Important: Requires macOS 14.0+ for @Observable support.
@available(macOS 14.0, *)
@Observable
@MainActor
public final class ModernDesktopLyricsViewModel {
    
    // MARK: - Published Properties
    
    /// The current lyrics line being displayed.
    public var currentLine: String = ""
    
    /// The next lyrics line (for two-line display mode).
    public var nextLine: String = ""
    
    /// The progress of the current line (0.0 to 1.0).
    public var progress: Double = 0.0
    
    /// Whether the lyrics are currently visible.
    public var isVisible: Bool = true
    
    /// Whether playback is currently active.
    public var isPlaying: Bool = false
    
    /// The current line index in the lyrics.
    public var currentLineIndex: Int?
    
    /// Error message to display, if any.
    public var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// The lyrics service for fetching and managing lyrics.
    private let lyricsService: any LyricsServiceProtocol
    
    /// The music player service for tracking playback.
    private let playerService: any MusicPlayerServiceProtocol
    
    /// The currently loaded lyrics.
    private var lyrics: Lyrics?
    
    /// Task for observing player position.
    private var positionObservationTask: Task<Void, Never>?
    
    /// Task for observing track changes.
    private var trackObservationTask: Task<Void, Never>?
    
    /// Task for observing playback state.
    private var playbackObservationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    /// Creates a new ViewModel with the specified services.
    /// - Parameters:
    ///   - lyricsService: The lyrics service to use.
    ///   - playerService: The music player service to use.
    public init(
        lyricsService: any LyricsServiceProtocol,
        playerService: any MusicPlayerServiceProtocol
    ) {
        self.lyricsService = lyricsService
        self.playerService = playerService
    }
    
    /// Creates a new ViewModel using the default dependency container.
    public convenience init() {
        let container = DependencyContainer.shared
        self.init(
            lyricsService: container.lyricsService,
            playerService: container.playerService
        )
    }
    
    deinit {
        stopObserving()
    }
    
    // MARK: - Public Methods
    
    /// Starts observing player state and lyrics changes.
    ///
    /// This method sets up async streams to observe:
    /// - Track changes
    /// - Playback state changes
    /// - Player position updates
    public func startObserving() {
        stopObserving()
        
        // Observe track changes
        trackObservationTask = Task { [weak self] in
            guard let self = self else { return }
            for await track in self.playerService.observeTrackChanges() {
                await self.handleTrackChange(track)
            }
        }
        
        // Observe playback state
        playbackObservationTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in self.playerService.observePlaybackState() {
                await self.handlePlaybackStateChange(state)
            }
        }
        
        // Observe player position
        positionObservationTask = Task { [weak self] in
            guard let self = self else { return }
            for await position in self.playerService.observePlayerPosition(interval: 0.05) {
                await self.handlePositionUpdate(position)
            }
        }
    }
    
    /// Stops all observation tasks.
    public func stopObserving() {
        positionObservationTask?.cancel()
        trackObservationTask?.cancel()
        playbackObservationTask?.cancel()
        
        positionObservationTask = nil
        trackObservationTask = nil
        playbackObservationTask = nil
    }
    
    /// Manually loads lyrics for a track.
    /// - Parameter track: The track to load lyrics for.
    public func loadLyrics(for track: MusicTrack) async {
        do {
            errorMessage = nil
            lyrics = try await lyricsService.fetchLyrics(for: track)
            
            if lyrics == nil {
                currentLine = ""
                nextLine = ""
            }
        } catch let error as LyricsXError {
            errorMessage = error.localizedDescription
            lyrics = nil
            currentLine = ""
            nextLine = ""
        } catch {
            errorMessage = LyricsXError.from(error).localizedDescription
            lyrics = nil
            currentLine = ""
            nextLine = ""
        }
    }
    
    /// Sets the lyrics directly (useful for imported lyrics).
    /// - Parameter lyrics: The lyrics to use.
    public func setLyrics(_ lyrics: Lyrics?) {
        self.lyrics = lyrics
        updateDisplay(at: 0)
    }
    
    // MARK: - Private Methods
    
    /// Handles track change events.
    private func handleTrackChange(_ track: MusicTrack?) async {
        guard let track = track else {
            lyrics = nil
            currentLine = ""
            nextLine = ""
            currentLineIndex = nil
            return
        }
        
        await loadLyrics(for: track)
    }
    
    /// Handles playback state change events.
    private func handlePlaybackStateChange(_ state: PlaybackState) async {
        isPlaying = state.isPlaying
        
        if !isPlaying {
            // Optionally hide lyrics when paused
            // This respects user preferences
        }
    }
    
    /// Handles position update events.
    private func handlePositionUpdate(_ position: TimeInterval) async {
        guard isPlaying else { return }
        updateDisplay(at: position)
    }
    
    /// Updates the display based on the current position.
    private func updateDisplay(at position: TimeInterval) {
        guard let lyrics = lyrics else {
            currentLine = ""
            nextLine = ""
            progress = 0
            return
        }
        
        // Get the time delay (offset)
        let adjustedPosition = position + lyrics.adjustedTimeDelay
        
        // Find current line index
        guard let index = lyrics.lineIndex(at: adjustedPosition) else {
            currentLine = ""
            nextLine = ""
            currentLineIndex = nil
            progress = 0
            return
        }
        
        currentLineIndex = index
        let line = lyrics[index]
        currentLine = line.content
        
        // Get next line
        if index + 1 < lyrics.count {
            let next = lyrics[index + 1]
            nextLine = next.content
        } else {
            nextLine = ""
        }
        
        // Calculate progress within the current line
        calculateProgress(for: line, at: adjustedPosition)
    }
    
    /// Calculates the word-by-word progress for the current line.
    private func calculateProgress(for line: LyricsLine, at position: TimeInterval) {
        // Check if we have timetags for word-by-word progress
        if let timetag = line.attachments.timetag {
            let lineProgress = position - line.position
            
            // Find the progress within the line based on timetags
            var lastIndex = 0
            for tag in timetag.tags {
                if tag.time > lineProgress {
                    break
                }
                lastIndex = tag.index
            }
            
            // Calculate progress as a percentage
            let textLength = line.content.count
            if textLength > 0 {
                progress = Double(lastIndex) / Double(textLength)
            } else {
                progress = 0
            }
        } else {
            // No timetags, use linear progress based on estimated line duration
            // Assume each line is about 3-5 seconds
            let estimatedDuration: TimeInterval = 4.0
            let lineProgress = position - line.position
            progress = min(1.0, max(0.0, lineProgress / estimatedDuration))
        }
    }
}

// MARK: - Legacy ViewModel (macOS 12+)

/// ViewModel for the desktop lyrics overlay using ObservableObject.
///
/// This ViewModel provides the same functionality as `ModernDesktopLyricsViewModel`
/// but uses `ObservableObject` for compatibility with macOS 12.0+.
@available(macOS 12.0, *)
public final class LegacyDesktopLyricsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var currentLine: String = ""
    @Published public var nextLine: String = ""
    @Published public var progress: Double = 0.0
    @Published public var isVisible: Bool = true
    @Published public var isPlaying: Bool = false
    @Published public var currentLineIndex: Int?
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let lyricsService: any LyricsServiceProtocol
    private let playerService: any MusicPlayerServiceProtocol
    private var lyrics: Lyrics?
    
    private var positionObservationTask: Task<Void, Never>?
    private var trackObservationTask: Task<Void, Never>?
    private var playbackObservationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    @MainActor
    public init(
        lyricsService: any LyricsServiceProtocol,
        playerService: any MusicPlayerServiceProtocol
    ) {
        self.lyricsService = lyricsService
        self.playerService = playerService
    }
    
    @MainActor
    public convenience init() {
        let container = DependencyContainer.shared
        self.init(
            lyricsService: container.lyricsService,
            playerService: container.playerService
        )
    }
    
    deinit {
        stopObserving()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    public func startObserving() {
        stopObserving()
        
        trackObservationTask = Task { [weak self] in
            guard let self = self else { return }
            for await track in self.playerService.observeTrackChanges() {
                await MainActor.run {
                    Task {
                        await self.handleTrackChange(track)
                    }
                }
            }
        }
        
        playbackObservationTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in self.playerService.observePlaybackState() {
                await MainActor.run {
                    self.isPlaying = state.isPlaying
                }
            }
        }
        
        positionObservationTask = Task { [weak self] in
            guard let self = self else { return }
            for await position in self.playerService.observePlayerPosition(interval: 0.05) {
                await MainActor.run {
                    self.updateDisplay(at: position)
                }
            }
        }
    }
    
    public func stopObserving() {
        positionObservationTask?.cancel()
        trackObservationTask?.cancel()
        playbackObservationTask?.cancel()
        
        positionObservationTask = nil
        trackObservationTask = nil
        playbackObservationTask = nil
    }
    
    @MainActor
    public func loadLyrics(for track: MusicTrack) async {
        do {
            errorMessage = nil
            lyrics = try await lyricsService.fetchLyrics(for: track)
            
            if lyrics == nil {
                currentLine = ""
                nextLine = ""
            }
        } catch let error as LyricsXError {
            errorMessage = error.localizedDescription
            lyrics = nil
            currentLine = ""
            nextLine = ""
        } catch {
            errorMessage = LyricsXError.from(error).localizedDescription
            lyrics = nil
            currentLine = ""
            nextLine = ""
        }
    }
    
    @MainActor
    public func setLyrics(_ lyrics: Lyrics?) {
        self.lyrics = lyrics
        updateDisplay(at: 0)
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func handleTrackChange(_ track: MusicTrack?) async {
        guard let track = track else {
            lyrics = nil
            currentLine = ""
            nextLine = ""
            currentLineIndex = nil
            return
        }
        
        await loadLyrics(for: track)
    }
    
    @MainActor
    private func updateDisplay(at position: TimeInterval) {
        guard isPlaying, let lyrics = lyrics else {
            if !isPlaying {
                return
            }
            currentLine = ""
            nextLine = ""
            progress = 0
            return
        }
        
        let adjustedPosition = position + lyrics.adjustedTimeDelay
        
        guard let index = lyrics.lineIndex(at: adjustedPosition) else {
            currentLine = ""
            nextLine = ""
            currentLineIndex = nil
            progress = 0
            return
        }
        
        currentLineIndex = index
        let line = lyrics[index]
        currentLine = line.content
        
        if index + 1 < lyrics.count {
            nextLine = lyrics[index + 1].content
        } else {
            nextLine = ""
        }
        
        calculateProgress(for: line, at: adjustedPosition)
    }
    
    @MainActor
    private func calculateProgress(for line: LyricsLine, at position: TimeInterval) {
        if let timetag = line.attachments.timetag {
            let lineProgress = position - line.position
            
            var lastIndex = 0
            for tag in timetag.tags {
                if tag.time > lineProgress {
                    break
                }
                lastIndex = tag.index
            }
            
            let textLength = line.content.count
            if textLength > 0 {
                progress = Double(lastIndex) / Double(textLength)
            } else {
                progress = 0
            }
        } else {
            let estimatedDuration: TimeInterval = 4.0
            let lineProgress = position - line.position
            progress = min(1.0, max(0.0, lineProgress / estimatedDuration))
        }
    }
}

// MARK: - Type Alias for Convenience

/// Type alias that selects the appropriate ViewModel based on macOS version.
///
/// - On macOS 14.0+: Uses `ModernDesktopLyricsViewModel` with @Observable
/// - On macOS 12.0-13.x: Uses `LegacyDesktopLyricsViewModel` with ObservableObject
@available(macOS 12.0, *)
public typealias DesktopLyricsViewModelType = LegacyDesktopLyricsViewModel
