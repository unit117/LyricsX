//
//  DependencyContainer.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// MARK: - Dependency Container

/// A centralized dependency injection container for the LyricsX application.
///
/// This container provides lazy-initialized service instances that can be
/// replaced with mock implementations for testing purposes.
///
/// Usage:
/// ```swift
/// let container = DependencyContainer.shared
/// let lyricsService = container.lyricsService
///
/// // For testing, replace services with mocks:
/// let mockService = MockLyricsService()
/// container.register(lyricsService: mockService)
/// ```
@MainActor
public final class DependencyContainer: Sendable {
    
    // MARK: - Shared Instance
    
    /// The shared singleton instance of the dependency container.
    public static let shared = DependencyContainer()
    
    // MARK: - Service Storage
    
    /// Storage for the lyrics service instance.
    private var _lyricsService: (any LyricsServiceProtocol)?
    
    /// Storage for the music player service instance.
    private var _playerService: (any MusicPlayerServiceProtocol)?
    
    // MARK: - Services
    
    /// The lyrics service instance.
    ///
    /// Returns the registered service or creates a default implementation.
    public var lyricsService: any LyricsServiceProtocol {
        if let service = _lyricsService {
            return service
        }
        let service = LyricsServiceImpl()
        _lyricsService = service
        return service
    }
    
    /// The music player service instance.
    ///
    /// Returns the registered service or creates a default implementation.
    public var playerService: any MusicPlayerServiceProtocol {
        if let service = _playerService {
            return service
        }
        let service = MusicPlayerServiceImpl()
        _playerService = service
        return service
    }
    
    // MARK: - Initialization
    
    /// Creates a new dependency container instance.
    private init() {}
    
    // MARK: - Registration Methods
    
    /// Registers a custom lyrics service implementation.
    /// - Parameter service: The lyrics service to register.
    public func register(lyricsService: any LyricsServiceProtocol) {
        _lyricsService = lyricsService
    }
    
    /// Registers a custom music player service implementation.
    /// - Parameter service: The music player service to register.
    public func register(playerService: any MusicPlayerServiceProtocol) {
        _playerService = playerService
    }
    
    /// Resets all services to their default implementations.
    ///
    /// This is primarily useful for testing to ensure a clean state between tests.
    public func reset() {
        _lyricsService = nil
        _playerService = nil
    }
}

// MARK: - Testing Support

#if DEBUG
extension DependencyContainer {
    
    /// Creates a container with custom services for testing.
    /// - Parameters:
    ///   - lyricsService: Optional custom lyrics service.
    ///   - playerService: Optional custom player service.
    /// - Returns: A configured dependency container.
    @MainActor
    public static func forTesting(
        lyricsService: (any LyricsServiceProtocol)? = nil,
        playerService: (any MusicPlayerServiceProtocol)? = nil
    ) -> DependencyContainer {
        let container = DependencyContainer.shared
        container.reset()
        
        if let lyricsService = lyricsService {
            container.register(lyricsService: lyricsService)
        }
        
        if let playerService = playerService {
            container.register(playerService: playerService)
        }
        
        return container
    }
}
#endif
