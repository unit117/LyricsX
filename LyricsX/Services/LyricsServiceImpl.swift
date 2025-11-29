//
//  LyricsServiceImpl.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import LyricsService
import MusicPlayer
import CXShim

// MARK: - Lyrics Service Implementation

/// Implementation of `LyricsServiceProtocol` that wraps the LyricsKit library.
///
/// This class provides an async/await interface over the Combine-based LyricsKit,
/// bridging the gap between modern Swift Concurrency and the existing backend.
///
/// - Note: This implementation is thread-safe and `Sendable` compliant.
public final class LyricsServiceImpl: LyricsServiceProtocol, @unchecked Sendable {
    
    // MARK: - Private Properties
    
    /// The underlying LyricsKit provider group.
    private let lyricsManager: LyricsProviders.Group
    
    /// Storage for current lyrics with thread-safe access.
    private let currentLyricsStorage: CurrentLyricsStorage
    
    /// Actor for thread-safe lyrics storage.
    private actor CurrentLyricsStorage {
        var lyrics: Lyrics?
        
        func set(_ newLyrics: Lyrics?) {
            lyrics = newLyrics
        }
        
        func get() -> Lyrics? {
            lyrics
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a new lyrics service instance.
    public init() {
        self.lyricsManager = LyricsProviders.Group()
        self.currentLyricsStorage = CurrentLyricsStorage()
    }
    
    // MARK: - LyricsServiceProtocol Implementation
    
    public func searchLyrics(
        title: String,
        artist: String,
        duration: TimeInterval?,
        limit: Int
    ) async throws -> [Lyrics] {
        guard !title.isEmpty || !artist.isEmpty else {
            throw LyricsXError.invalidInput(reason: "Title or artist must be provided")
        }
        
        let request = LyricsSearchRequest(
            searchTerm: .info(title: title, artist: artist),
            duration: duration ?? 0,
            limit: limit
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var results: [Lyrics] = []
            var hasCompleted = false
            
            var cancellable: AnyCancellable?
            cancellable = lyricsManager.lyricsPublisher(request: request)
                .timeout(.seconds(15), scheduler: DispatchQueue.global().cx)
                .sink(
                    receiveCompletion: { completion in
                        guard !hasCompleted else { return }
                        hasCompleted = true
                        
                        switch completion {
                        case .finished:
                            // Sort by quality (higher is better)
                            let sortedResults = results.sorted { $0.quality > $1.quality }
                            continuation.resume(returning: sortedResults)
                        case .failure:
                            if results.isEmpty {
                                continuation.resume(throwing: LyricsXError.lyricsNotFound)
                            } else {
                                let sortedResults = results.sorted { $0.quality > $1.quality }
                                continuation.resume(returning: sortedResults)
                            }
                        }
                    },
                    receiveValue: { lyrics in
                        guard !hasCompleted else { return }
                        results.append(lyrics)
                    }
                )
            
            continuation.onTermination = { _ in
                cancellable?.cancel()
            }
        }
    }
    
    public func fetchLyrics(for track: MusicTrack) async throws -> Lyrics? {
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        guard !title.isEmpty else {
            throw LyricsXError.invalidInput(reason: "Track title is required")
        }
        
        let results = try await searchLyrics(
            title: title,
            artist: artist,
            duration: track.duration,
            limit: 5
        )
        
        guard let bestMatch = results.first else {
            return nil
        }
        
        // Associate lyrics with the track
        var lyrics = bestMatch
        lyrics.metadata.title = title
        lyrics.metadata.artist = artist
        
        // Update current lyrics
        await currentLyricsStorage.set(lyrics)
        
        return lyrics
    }
    
    public func parseLRCX(_ content: String) throws -> Lyrics {
        guard !content.isEmpty else {
            throw LyricsXError.parsingError(reason: "Content is empty")
        }
        
        guard let lyrics = Lyrics(content) else {
            throw LyricsXError.parsingError(reason: "Invalid LRCX/LRC format")
        }
        
        return lyrics
    }
    
    public var currentLyrics: Lyrics? {
        get async {
            await currentLyricsStorage.get()
        }
    }
    
    public func observeLyricsChanges() -> AsyncStream<Lyrics?> {
        AsyncStream { continuation in
            // For now, we provide a basic implementation
            // In a full implementation, this would observe AppController.shared.$currentLyrics
            Task {
                let current = await currentLyricsStorage.get()
                continuation.yield(current)
            }
            
            continuation.onTermination = { _ in
                // Cleanup if needed
            }
        }
    }
    
    // MARK: - Internal Methods
    
    /// Updates the current lyrics.
    /// - Parameter lyrics: The new lyrics to set as current.
    func setCurrentLyrics(_ lyrics: Lyrics?) async {
        await currentLyricsStorage.set(lyrics)
    }
}
