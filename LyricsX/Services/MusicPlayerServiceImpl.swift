//
//  MusicPlayerServiceImpl.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import MusicPlayer
import CXShim

// MARK: - Music Player Service Implementation

/// Implementation of `MusicPlayerServiceProtocol` that wraps the MusicPlayer package.
///
/// This class bridges the Combine-based MusicPlayer API with Swift Concurrency,
/// providing async/await access to the currently selected music player.
///
/// - Note: This implementation is thread-safe and `Sendable` compliant.
public final class MusicPlayerServiceImpl: MusicPlayerServiceProtocol, @unchecked Sendable {
    
    // MARK: - Private Properties
    
    /// Reference to the selected music player singleton.
    private let player: MusicPlayers.Selected
    
    // MARK: - Initialization
    
    /// Creates a new music player service instance.
    public init() {
        self.player = MusicPlayers.Selected.shared
    }
    
    /// Creates a new music player service instance with a custom player.
    /// - Parameter player: The music player to use.
    init(player: MusicPlayers.Selected) {
        self.player = player
    }
    
    // MARK: - MusicPlayerServiceProtocol Implementation
    
    public var currentTrack: MusicTrack? {
        get async {
            player.currentTrack
        }
    }
    
    public var playbackState: PlaybackState {
        get async {
            player.playbackState
        }
    }
    
    public var playerPosition: TimeInterval {
        get async {
            player.playbackTime
        }
    }
    
    public var playerName: MusicPlayerName? {
        get async {
            player.name
        }
    }
    
    public func observeTrackChanges() -> AsyncStream<MusicTrack?> {
        AsyncStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            // Emit current track immediately
            continuation.yield(self.player.currentTrack)
            
            // Subscribe to track changes using Combine
            let cancellable = self.player.currentTrackWillChange
                .receive(on: DispatchQueue.main.cx)
                .sink { track in
                    continuation.yield(track)
                }
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    
    public func observePlaybackState() -> AsyncStream<PlaybackState> {
        AsyncStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            // Emit current state immediately
            continuation.yield(self.player.playbackState)
            
            // Subscribe to playback state changes using Combine
            let cancellable = self.player.playbackStateWillChange
                .receive(on: DispatchQueue.main.cx)
                .sink { state in
                    continuation.yield(state)
                }
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    
    public func observePlayerPosition(interval: TimeInterval) -> AsyncStream<TimeInterval> {
        AsyncStream { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            
            // Use a timer to periodically emit the current position
            let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                let position = self.player.playbackTime
                continuation.yield(position)
            }
            
            // Add to run loop
            RunLoop.main.add(timer, forMode: .common)
            
            // Emit current position immediately
            continuation.yield(self.player.playbackTime)
            
            continuation.onTermination = { _ in
                timer.invalidate()
            }
        }
    }
    
    public func resume() async {
        player.resume()
    }
    
    public func pause() async {
        player.pause()
    }
    
    public func playPause() async {
        player.playPause()
    }
    
    public func skipToNext() async {
        player.skipToNextItem()
    }
    
    public func skipToPrevious() async {
        player.skipToPreviousItem()
    }
}
