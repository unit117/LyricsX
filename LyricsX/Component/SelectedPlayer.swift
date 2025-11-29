//
//  SelectedPlayer.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import MusicPlayer
import GenericID
import CXShim

extension MusicPlayers {
    
    /// A music player agent that manages the currently selected player.
    ///
    /// This class observes user preferences to switch between different music players
    /// and provides periodic state updates for accurate playback tracking.
    final class Selected: Agent {
        
        // MARK: - Shared Instance
        
        static let shared = MusicPlayers.Selected()
        
        // MARK: - Properties
        
        /// Observation token for user defaults changes.
        private var defaultsObservation: DefaultsObservation?
        
        /// Cancellable for playback state observation (bridging with Combine).
        private var manualUpdateObservation: AnyCancellable?
        
        /// Task for periodic state updates (modern async approach).
        private var manualUpdateTask: Task<Void, Never>?
        
        /// The interval between manual state updates.
        var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        // MARK: - Initialization
        
        override init() {
            super.init()
            selectPlayer()
            scheduleManualUpdate()
            setupObservations()
        }
        
        deinit {
            manualUpdateTask?.cancel()
            scheduleCanceller?.cancel()
        }
        
        // MARK: - Setup
        
        private func setupObservations() {
            // Observe user defaults for player selection changes
            defaultsObservation = defaults.observe(keys: [.preferredPlayerIndex, .useSystemWideNowPlaying]) { [weak self] in
                self?.selectPlayer()
            }
            
            // Observe playback state to manage update scheduling
            manualUpdateObservation = playbackStateWillChange.sink { [weak self] state in
                if state.isPlaying {
                    self?.scheduleManualUpdate()
                } else {
                    self?.scheduleCanceller?.cancel()
                    self?.manualUpdateTask?.cancel()
                }
            }
        }
        
        // MARK: - Player Selection
        
        private func selectPlayer() {
            let idx = defaults[.preferredPlayerIndex]
            if idx == -1 {
                if defaults[.useSystemWideNowPlaying] {
                    designatedPlayer = MusicPlayers.SystemMedia()
                } else {
                    let players = MusicPlayerName.scriptableCases.compactMap(MusicPlayers.Scriptable.init)
                    designatedPlayer = MusicPlayers.NowPlaying(players: players)
                }
            } else {
                designatedPlayer = MusicPlayerName(index: idx).flatMap(MusicPlayers.Scriptable.init)
            }
        }
        
        // MARK: - Manual Update Scheduling
        
        /// Cancellable for scheduled updates (legacy Combine approach).
        private var scheduleCanceller: Cancellable?
        
        /// Schedules periodic manual updates to the player state.
        func scheduleManualUpdate() {
            scheduleCanceller?.cancel()
            manualUpdateTask?.cancel()
            
            guard manualUpdateInterval > 0 else { return }
            
            let q = DispatchQueue.global().cx
            let i: CXWrappers.DispatchQueue.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
            scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
                self.designatedPlayer?.updatePlayerState()
            }
        }
        
        // MARK: - Async API
        
        /// Creates an async stream for observing track changes.
        /// - Returns: An `AsyncStream` that emits the current track whenever it changes.
        func observeTrackChanges() -> AsyncStream<MusicTrack?> {
            AsyncStream { [weak self] continuation in
                guard let self = self else {
                    continuation.finish()
                    return
                }
                
                // Emit current track immediately
                continuation.yield(self.currentTrack)
                
                // Subscribe to track changes
                let cancellable = self.currentTrackWillChange
                    .sink { track in
                        continuation.yield(track)
                    }
                
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        
        /// Creates an async stream for observing playback state changes.
        /// - Returns: An `AsyncStream` that emits the playback state whenever it changes.
        func observePlaybackState() -> AsyncStream<PlaybackState> {
            AsyncStream { [weak self] continuation in
                guard let self = self else {
                    continuation.finish()
                    return
                }
                
                // Emit current state immediately
                continuation.yield(self.playbackState)
                
                // Subscribe to playback state changes
                let cancellable = self.playbackStateWillChange
                    .sink { state in
                        continuation.yield(state)
                    }
                
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
    }
}
