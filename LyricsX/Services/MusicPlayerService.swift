//
//  MusicPlayerService.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import MusicPlayer

// MARK: - Music Player Service Protocol

/// Protocol that abstracts the MusicPlayer package functionality.
///
/// This protocol provides a clean async/await interface for interacting with
/// music players (Spotify, Apple Music, etc.) while maintaining compatibility
/// with the underlying Combine-based MusicPlayer package.
///
/// Example usage:
/// ```swift
/// let service = MusicPlayerServiceImpl()
/// let track = await service.currentTrack
///
/// for await newTrack in service.observeTrackChanges() {
///     print("Now playing: \(newTrack?.title ?? "Nothing")")
/// }
/// ```
public protocol MusicPlayerServiceProtocol: Sendable {
    
    /// The currently playing track, if any.
    var currentTrack: MusicTrack? { get async }
    
    /// The current playback state of the player.
    var playbackState: PlaybackState { get async }
    
    /// The current playback position in seconds.
    var playerPosition: TimeInterval { get async }
    
    /// The name of the currently active music player.
    var playerName: MusicPlayerName? { get async }
    
    /// Creates an async stream for observing track changes.
    /// - Returns: An `AsyncStream` that emits the current track whenever it changes.
    func observeTrackChanges() -> AsyncStream<MusicTrack?>
    
    /// Creates an async stream for observing playback state changes.
    /// - Returns: An `AsyncStream` that emits the playback state whenever it changes.
    func observePlaybackState() -> AsyncStream<PlaybackState>
    
    /// Creates an async stream for observing player position updates.
    /// - Parameter interval: The update interval in seconds (default: 0.1).
    /// - Returns: An `AsyncStream` that emits the player position at the specified interval.
    func observePlayerPosition(interval: TimeInterval) -> AsyncStream<TimeInterval>
    
    /// Resumes playback.
    func resume() async
    
    /// Pauses playback.
    func pause() async
    
    /// Toggles between play and pause.
    func playPause() async
    
    /// Skips to the next track.
    func skipToNext() async
    
    /// Skips to the previous track.
    func skipToPrevious() async
}

// MARK: - Default Parameter Values Extension

public extension MusicPlayerServiceProtocol {
    
    /// Observes player position with default interval.
    func observePlayerPosition() -> AsyncStream<TimeInterval> {
        observePlayerPosition(interval: 0.1)
    }
}
