//
//  LyricsService.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import MusicPlayer

// MARK: - Lyrics Service Protocol

/// Protocol that abstracts LyricsKit functionality for lyrics searching, fetching, and parsing.
///
/// This protocol provides a clean async/await interface over the underlying LyricsKit
/// Combine-based implementation, enabling modern Swift Concurrency patterns.
///
/// Example usage:
/// ```swift
/// let service = LyricsServiceImpl()
/// let lyrics = try await service.searchLyrics(title: "Song", artist: "Artist")
/// ```
public protocol LyricsServiceProtocol: Sendable {
    
    /// Searches for lyrics matching the given title and artist.
    /// - Parameters:
    ///   - title: The song title to search for.
    ///   - artist: The artist name to search for.
    ///   - duration: Optional track duration for better matching accuracy.
    ///   - limit: Maximum number of results to return (default: 5).
    /// - Returns: An array of matching lyrics, sorted by quality.
    /// - Throws: `LyricsXError` if the search fails.
    func searchLyrics(
        title: String,
        artist: String,
        duration: TimeInterval?,
        limit: Int
    ) async throws -> [Lyrics]
    
    /// Fetches the best matching lyrics for a music track.
    /// - Parameter track: The music track to fetch lyrics for.
    /// - Returns: The best matching lyrics, or nil if none found.
    /// - Throws: `LyricsXError` if the fetch fails.
    func fetchLyrics(for track: MusicTrack) async throws -> Lyrics?
    
    /// Parses an LRCX/LRC formatted string into a Lyrics object.
    /// - Parameter content: The LRCX or LRC formatted string content.
    /// - Returns: The parsed Lyrics object.
    /// - Throws: `LyricsXError.parsingError` if the content is invalid.
    func parseLRCX(_ content: String) throws -> Lyrics
    
    /// The currently active lyrics, if any.
    var currentLyrics: Lyrics? { get async }
    
    /// Creates an async stream for observing lyrics changes.
    /// - Returns: An `AsyncStream` that emits the current lyrics whenever they change.
    func observeLyricsChanges() -> AsyncStream<Lyrics?>
}

// MARK: - Default Parameter Values Extension

public extension LyricsServiceProtocol {
    
    /// Searches for lyrics with default parameters.
    /// - Parameters:
    ///   - title: The song title to search for.
    ///   - artist: The artist name to search for.
    /// - Returns: An array of matching lyrics.
    func searchLyrics(title: String, artist: String) async throws -> [Lyrics] {
        try await searchLyrics(title: title, artist: artist, duration: nil, limit: 5)
    }
}
