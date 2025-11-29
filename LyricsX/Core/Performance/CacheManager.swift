//
//  CacheManager.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// MARK: - Cache Manager

/// A thread-safe actor-based cache manager for lyrics and related data.
///
/// This cache helps optimize performance by storing frequently accessed
/// lyrics to avoid redundant network requests and parsing operations.
///
/// Example usage:
/// ```swift
/// let cacheKey = CacheManager.lyricsKey(title: "Song", artist: "Artist")
/// if let cached = await CacheManager.shared.get(cacheKey, as: CachedLyrics.self) {
///     return cached.lyrics
/// }
/// ```
@available(macOS 12.0, *)
public actor CacheManager {
    
    // MARK: - Shared Instance
    
    /// The shared cache manager instance.
    public static let shared = CacheManager()
    
    // MARK: - Properties
    
    /// In-memory cache storage.
    private var cache: [String: CacheEntry] = [:]
    
    /// Maximum number of entries in the cache.
    private let maxEntries: Int
    
    /// Default time-to-live for cache entries (in seconds).
    private let defaultTTL: TimeInterval
    
    /// Total size of cached data in bytes.
    private var totalSize: Int = 0
    
    /// Maximum cache size in bytes (default: 50MB).
    private let maxSize: Int
    
    // MARK: - Initialization
    
    /// Creates a new cache manager with the specified configuration.
    ///
    /// - Parameters:
    ///   - maxEntries: Maximum number of cache entries (default: 500).
    ///   - defaultTTL: Default time-to-live in seconds (default: 1 hour).
    ///   - maxSize: Maximum cache size in bytes (default: 50MB).
    public init(
        maxEntries: Int = 500,
        defaultTTL: TimeInterval = 3600,
        maxSize: Int = 50 * 1024 * 1024
    ) {
        self.maxEntries = maxEntries
        self.defaultTTL = defaultTTL
        self.maxSize = maxSize
    }
    
    // MARK: - Cache Operations
    
    /// Stores a value in the cache.
    ///
    /// - Parameters:
    ///   - value: The value to cache (must be Codable).
    ///   - key: The cache key.
    ///   - ttl: Optional custom time-to-live. Uses default if nil.
    public func set<T: Codable & Sendable>(
        _ value: T,
        forKey key: String,
        ttl: TimeInterval? = nil
    ) {
        // Encode the value
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        
        let entry = CacheEntry(
            data: data,
            expiresAt: Date().addingTimeInterval(ttl ?? defaultTTL),
            accessCount: 0,
            lastAccessed: Date()
        )
        
        // Check if we need to evict entries
        if cache.count >= maxEntries {
            evictLRU()
        }
        
        // Check size limit
        if totalSize + data.count > maxSize {
            evictUntilSizeBelow(maxSize - data.count)
        }
        
        // Update total size
        if let existingEntry = cache[key] {
            totalSize -= existingEntry.data.count
        }
        totalSize += data.count
        
        cache[key] = entry
    }
    
    /// Retrieves a value from the cache.
    ///
    /// - Parameters:
    ///   - key: The cache key.
    ///   - type: The expected type of the cached value.
    /// - Returns: The cached value, or nil if not found or expired.
    public func get<T: Codable & Sendable>(_ key: String, as type: T.Type) -> T? {
        guard var entry = cache[key] else {
            return nil
        }
        
        // Check expiration
        if entry.expiresAt < Date() {
            cache.removeValue(forKey: key)
            totalSize -= entry.data.count
            return nil
        }
        
        // Update access statistics
        entry.accessCount += 1
        entry.lastAccessed = Date()
        cache[key] = entry
        
        // Decode and return
        return try? JSONDecoder().decode(type, from: entry.data)
    }
    
    /// Removes a value from the cache.
    ///
    /// - Parameter key: The cache key to remove.
    public func remove(_ key: String) {
        if let entry = cache.removeValue(forKey: key) {
            totalSize -= entry.data.count
        }
    }
    
    /// Removes all values from the cache.
    public func removeAll() {
        cache.removeAll()
        totalSize = 0
    }
    
    /// Removes expired entries from the cache.
    public func removeExpired() {
        let now = Date()
        let expiredKeys = cache.filter { $0.value.expiresAt < now }.map { $0.key }
        
        for key in expiredKeys {
            if let entry = cache.removeValue(forKey: key) {
                totalSize -= entry.data.count
            }
        }
    }
    
    /// Checks if a key exists in the cache and is not expired.
    ///
    /// - Parameter key: The cache key.
    /// - Returns: True if the key exists and is not expired.
    public func contains(_ key: String) -> Bool {
        guard let entry = cache[key] else {
            return false
        }
        return entry.expiresAt >= Date()
    }
    
    // MARK: - Cache Statistics
    
    /// Returns the current number of entries in the cache.
    public var count: Int {
        cache.count
    }
    
    /// Returns the current size of the cache in bytes.
    public var size: Int {
        totalSize
    }
    
    /// Returns cache statistics.
    public func getStatistics() -> CacheStatistics {
        let now = Date()
        let validEntries = cache.values.filter { $0.expiresAt >= now }
        
        return CacheStatistics(
            entryCount: cache.count,
            validEntryCount: validEntries.count,
            totalSize: totalSize,
            maxSize: maxSize,
            totalAccessCount: cache.values.reduce(0) { $0 + $1.accessCount }
        )
    }
    
    // MARK: - Private Methods
    
    /// Evicts the least recently used entry.
    private func evictLRU() {
        guard let oldestKey = cache.min(by: { $0.value.lastAccessed < $1.value.lastAccessed })?.key else {
            return
        }
        
        if let entry = cache.removeValue(forKey: oldestKey) {
            totalSize -= entry.data.count
        }
    }
    
    /// Evicts entries until the total size is below the target.
    private func evictUntilSizeBelow(_ targetSize: Int) {
        let sortedKeys = cache
            .sorted { $0.value.lastAccessed < $1.value.lastAccessed }
            .map { $0.key }
        
        for key in sortedKeys where totalSize > targetSize {
            if let entry = cache.removeValue(forKey: key) {
                totalSize -= entry.data.count
            }
        }
    }
}

// MARK: - Cache Entry

/// Internal structure representing a cache entry.
private struct CacheEntry {
    let data: Data
    let expiresAt: Date
    var accessCount: Int
    var lastAccessed: Date
}

// MARK: - Cache Statistics

/// Statistics about the cache state.
public struct CacheStatistics: Sendable {
    /// Total number of entries in the cache.
    public let entryCount: Int
    
    /// Number of non-expired entries.
    public let validEntryCount: Int
    
    /// Total size of cached data in bytes.
    public let totalSize: Int
    
    /// Maximum allowed cache size in bytes.
    public let maxSize: Int
    
    /// Total number of cache accesses.
    public let totalAccessCount: Int
    
    /// Cache utilization as a percentage.
    public var utilization: Double {
        guard maxSize > 0 else { return 0 }
        return Double(totalSize) / Double(maxSize) * 100
    }
}

// MARK: - Cache Key Helpers

@available(macOS 12.0, *)
extension CacheManager {
    
    /// Generates a cache key for lyrics.
    ///
    /// - Parameters:
    ///   - title: The track title.
    ///   - artist: The artist name.
    /// - Returns: A unique cache key.
    public static func lyricsKey(title: String, artist: String) -> String {
        let normalizedTitle = title.lowercased().trimmingCharacters(in: .whitespaces)
        let normalizedArtist = artist.lowercased().trimmingCharacters(in: .whitespaces)
        // Use the full normalized string as key to avoid hash collisions
        return "lyrics:\(normalizedArtist):\(normalizedTitle)"
    }
    
    /// Generates a cache key for search results.
    ///
    /// - Parameters:
    ///   - query: The search query.
    ///   - source: The lyrics source.
    /// - Returns: A unique cache key.
    public static func searchKey(query: String, source: String? = nil) -> String {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        if let source = source {
            return "search:\(source):\(normalizedQuery)"
        }
        return "search:\(normalizedQuery)"
    }
}

// MARK: - Cached Lyrics Model

/// A model for caching lyrics with metadata.
public struct CachedLyrics: Codable, Sendable {
    /// The raw lyrics content.
    public let content: String
    
    /// The track title.
    public let title: String
    
    /// The artist name.
    public let artist: String
    
    /// The lyrics source.
    public let source: String
    
    /// When the lyrics were cached.
    public let cachedAt: Date
    
    /// Creates a new cached lyrics entry.
    public init(
        content: String,
        title: String,
        artist: String,
        source: String
    ) {
        self.content = content
        self.title = title
        self.artist = artist
        self.source = source
        self.cachedAt = Date()
    }
}
