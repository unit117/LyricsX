//
//  LyricsXError.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// MARK: - LyricsX Error Types

/// Comprehensive error types for the LyricsX application.
///
/// This enum provides localized, user-friendly error messages with recovery suggestions.
///
/// Example usage:
/// ```swift
/// do {
///     let lyrics = try await service.fetchLyrics(for: track)
/// } catch let error as LyricsXError {
///     print(error.errorDescription ?? "Unknown error")
///     print(error.recoverySuggestion ?? "")
/// }
/// ```
public enum LyricsXError: LocalizedError, Equatable, Sendable {
    
    /// No lyrics were found for the requested track.
    case lyricsNotFound
    
    /// A network error occurred during the request.
    case networkError(message: String)
    
    /// Failed to parse lyrics content.
    case parsingError(reason: String)
    
    /// The music player is not available or not running.
    case playerNotAvailable
    
    /// The user has not authorized access to the music player.
    case unauthorized
    
    /// Invalid input was provided.
    case invalidInput(reason: String)
    
    /// The operation timed out.
    case timeout
    
    /// An unknown error occurred.
    case unknown(message: String)
    
    // MARK: - LocalizedError Implementation
    
    public var errorDescription: String? {
        switch self {
        case .lyricsNotFound:
            return NSLocalizedString(
                "Lyrics Not Found",
                comment: "Error message when no lyrics are found"
            )
            
        case .networkError(let message):
            return String(
                format: NSLocalizedString(
                    "Network Error: %@",
                    comment: "Error message for network errors"
                ),
                message
            )
            
        case .parsingError(let reason):
            return String(
                format: NSLocalizedString(
                    "Parsing Error: %@",
                    comment: "Error message for parsing errors"
                ),
                reason
            )
            
        case .playerNotAvailable:
            return NSLocalizedString(
                "Music Player Not Available",
                comment: "Error message when music player is not available"
            )
            
        case .unauthorized:
            return NSLocalizedString(
                "Authorization Required",
                comment: "Error message when authorization is needed"
            )
            
        case .invalidInput(let reason):
            return String(
                format: NSLocalizedString(
                    "Invalid Input: %@",
                    comment: "Error message for invalid input"
                ),
                reason
            )
            
        case .timeout:
            return NSLocalizedString(
                "Request Timed Out",
                comment: "Error message when request times out"
            )
            
        case .unknown(let message):
            return String(
                format: NSLocalizedString(
                    "An Error Occurred: %@",
                    comment: "Error message for unknown errors"
                ),
                message
            )
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .lyricsNotFound:
            return NSLocalizedString(
                "Try searching with different keywords or check if the song information is correct.",
                comment: "Recovery suggestion for lyrics not found"
            )
            
        case .networkError:
            return NSLocalizedString(
                "Check your internet connection and try again.",
                comment: "Recovery suggestion for network errors"
            )
            
        case .parsingError:
            return NSLocalizedString(
                "The lyrics file may be corrupted. Try downloading it again or use a different source.",
                comment: "Recovery suggestion for parsing errors"
            )
            
        case .playerNotAvailable:
            return NSLocalizedString(
                "Make sure a supported music player (Spotify, Apple Music, etc.) is running.",
                comment: "Recovery suggestion for player not available"
            )
            
        case .unauthorized:
            return NSLocalizedString(
                "Go to System Preferences > Security & Privacy > Privacy > Automation and grant LyricsX access to your music player.",
                comment: "Recovery suggestion for authorization errors"
            )
            
        case .invalidInput:
            return NSLocalizedString(
                "Please check your input and try again.",
                comment: "Recovery suggestion for invalid input"
            )
            
        case .timeout:
            return NSLocalizedString(
                "The server is taking too long to respond. Please try again later.",
                comment: "Recovery suggestion for timeout errors"
            )
            
        case .unknown:
            return NSLocalizedString(
                "Please try again. If the problem persists, restart the application.",
                comment: "Recovery suggestion for unknown errors"
            )
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .lyricsNotFound:
            return "The lyrics database did not return any results."
        case .networkError:
            return "Failed to establish a network connection."
        case .parsingError:
            return "The lyrics content could not be interpreted."
        case .playerNotAvailable:
            return "No supported music player could be detected."
        case .unauthorized:
            return "LyricsX does not have permission to access the music player."
        case .invalidInput:
            return "The provided input did not meet the requirements."
        case .timeout:
            return "The operation exceeded the maximum allowed time."
        case .unknown:
            return "An unexpected condition occurred."
        }
    }
}

// MARK: - Convenience Initializers

public extension LyricsXError {
    
    /// Creates an error from a generic Error.
    /// - Parameter error: The underlying error.
    /// - Returns: A `LyricsXError` wrapping the underlying error.
    static func from(_ error: Error) -> LyricsXError {
        if let lyricsXError = error as? LyricsXError {
            return lyricsXError
        }
        
        let nsError = error as NSError
        
        // Check for common error patterns
        if nsError.domain == NSURLErrorDomain {
            return .networkError(message: error.localizedDescription)
        }
        
        return .unknown(message: error.localizedDescription)
    }
}
