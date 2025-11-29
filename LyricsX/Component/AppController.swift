//
//  AppController.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AppKit
import CXShim
import CXExtensions
import LyricsService
import MusicPlayer
import OpenCC
import Regex

class AppController: NSObject {
    
    static let shared = AppController()
    
    // MARK: - Properties
    
    /// The lyrics provider group for searching lyrics from multiple sources.
    let lyricsManager = LyricsProviders.Group()
    
    /// The lyrics service protocol implementation for async operations.
    private lazy var lyricsService: any LyricsServiceProtocol = {
        DependencyContainer.shared.lyricsService
    }()
    
    @Published var currentLyrics: Lyrics? {
        willSet {
            willChangeValue(forKey: "lyricsOffset")
            currentLineIndex = nil
        }
        didSet {
            didChangeValue(forKey: "lyricsOffset")
            scheduleCurrentLineCheck()
        }
    }
    
    @Published var currentLineIndex: Int?
    
    var searchRequest: LyricsSearchRequest?
    
    /// Legacy Combine cancellable for search operations
    var searchCanceller: Cancellable?
    
    private var cancelBag = Set<AnyCancellable>()
    
    /// Task for observing app termination
    private var appTerminationTask: Task<Void, Never>?
    
    @objc dynamic var lyricsOffset: Int {
        get {
            return currentLyrics?.offset ?? 0
        }
        set {
            currentLyrics?.offset = newValue
            currentLyrics?.metadata.needsPersist = true
            scheduleCurrentLineCheck()
        }
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupObservations()
        currentTrackChanged()
    }
    
    deinit {
        cancelAllTasks()
    }
    
    // MARK: - Setup
    
    private func setupObservations() {
        // Subscribe to track changes
        selectedPlayer.currentTrackWillChange
            .signal()
            .receive(on: DispatchQueue.lyricsDisplay.cx)
            .invoke(AppController.currentTrackChanged, weaklyOn: self)
            .store(in: &cancelBag)
        
        // Subscribe to playback state changes
        selectedPlayer.playbackStateWillChange
            .signal()
            .receive(on: DispatchQueue.lyricsDisplay.cx)
            .invoke(AppController.scheduleCurrentLineCheck, weaklyOn: self)
            .store(in: &cancelBag)
        
        // Setup app termination observation using async Task
        setupAppTerminationObservation()
    }
    
    /// Sets up observation for application termination to quit with player if enabled.
    private func setupAppTerminationObservation() {
        appTerminationTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(
                named: NSWorkspace.didTerminateApplicationNotification,
                object: nil
            )
            for await notification in notifications {
                guard !Task.isCancelled else { break }
                self?.handleAppTermination(notification)
            }
        }
    }
    
    private func handleAppTermination(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = app.bundleIdentifier else {
            return
        }
        
        if defaults[.launchAndQuitWithPlayer],
           (selectedPlayer.designatedPlayer as? MusicPlayers.Scriptable)?.playerBundleID == bundleID {
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    /// Cancels all active tasks.
    private func cancelAllTasks() {
        searchCanceller?.cancel()
        appTerminationTask?.cancel()
        appTerminationTask = nil
        cancelBag.removeAll()
    }
    
    // MARK: - Line Check Scheduling
    
    var currentLineCheckSchedule: Cancellable?
    func scheduleCurrentLineCheck() {
        currentLineCheckSchedule?.cancel()
        guard let lyrics = currentLyrics else {
            return
        }
        let playbackState = MusicPlayers.Selected.shared.playbackState
        let playbackTime = playbackState.time
        let (index, next) = lyrics[playbackTime + lyrics.adjustedTimeDelay]
        if currentLineIndex != index {
            currentLineIndex = index
        }
        if let next = next, playbackState.isPlaying {
            let dt = lyrics.lines[next].position - playbackTime - lyrics.adjustedTimeDelay
            let q = DispatchQueue.lyricsDisplay.cx
            currentLineCheckSchedule = q.schedule(after: q.now.advanced(by: .seconds(dt)), interval: .seconds(42), tolerance: .milliseconds(20)) { [unowned self] in
                self.scheduleCurrentLineCheck()
            }
        }
    }
    
    // MARK: - iTunes Integration
    
    func writeToiTunes(overwrite: Bool) {
        guard selectedPlayer.name == .appleMusic,
            let currentLyrics = currentLyrics,
            let sbTrack = selectedPlayer.currentTrack?.originalTrack,
            overwrite || (sbTrack.value(forKey: "lyrics") as! String?)?.isEmpty != false else {
            return
        }
        let content = currentLyrics.lines.map { line -> String in
            var content = line.content
            if let converter = ChineseConverter.shared {
                content = converter.convert(content)
            }
            if defaults[.writeiTunesWithTranslation] {
                // TODO: tagged translation
                let code = currentLyrics.metadata.translationLanguages.first
                if var translation = line.attachments[.translation(languageCode: code)] {
                    if let converter = ChineseConverter.shared {
                        translation = converter.convert(translation)
                    }
                    content += "\n" + translation
                }
            }
            return content
        }.joined(separator: "\n")
        // swiftlint:disable:next force_try
        let regex = Regex(#"\n{3,}"#)
        let replaced = content.replacingMatches(of: regex, with: "\n\n")
        sbTrack.setValue(replaced, forKey: "lyrics")
    }
    
    // MARK: - Track Change Handling
    
    func currentTrackChanged() {
        if currentLyrics?.metadata.needsPersist == true {
            currentLyrics?.persist()
        }
        currentLyrics = nil
        currentLineIndex = nil
        
        // Cancel any ongoing search operations
        searchCanceller?.cancel()
        
        guard let track = selectedPlayer.currentTrack else {
            return
        }
        // FIXME: deal with optional value
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        guard !defaults[.noSearchingTrackIds].contains(track.id) else {
            return
        }
        
        var candidateLyricsURL: [(URL, Bool, Bool)] = []  // (fileURL, isSecurityScoped, needsSearching)
        
        if defaults[.loadLyricsBesideTrack] {
            if let fileName = track.fileURL?.deletingPathExtension() {
                candidateLyricsURL += [
                    (fileName.appendingPathExtension("lrcx"), false, false),
                    (fileName.appendingPathExtension("lrc"), false, false)
                ]
            }
        }
        let (url, security) = defaults.lyricsSavingPath()
        let titleForReading = title.replacingOccurrences(of: "/", with: ":")
        let artistForReading = artist.replacingOccurrences(of: "/", with: ":")
        let fileName = url.appendingPathComponent("\(titleForReading) - \(artistForReading)")
        candidateLyricsURL += [
            (fileName.appendingPathExtension("lrcx"), security, false),
            (fileName.appendingPathExtension("lrc"), security, true)
        ]
        
        for (url, security, needsSearching) in candidateLyricsURL {
            if security {
                guard url.startAccessingSecurityScopedResource() else {
                    continue
                }
            }
            defer {
                if security {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if let lrcContents = try? String(contentsOf: url, encoding: String.Encoding.utf8),
                let lyrics = Lyrics(lrcContents) {
                lyrics.metadata.localURL = url
                lyrics.metadata.title = title
                lyrics.metadata.artist = artist
                lyrics.filtrate()
                lyrics.recognizeLanguage()
                currentLyrics = lyrics
                if needsSearching {
                    break
                } else {
                    return
                }
            }
        }
        
        #if IS_FOR_MAS
            guard defaults[.isInMASReview] == false else {
                return
            }
            checkForMASReview()
        #endif
        
        if let album = track.album, defaults[.noSearchingAlbumNames].contains(album) {
            return
        }
        
        let duration = track.duration ?? 0
        let req = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist), duration: duration, limit: 5)
        searchRequest = req
        searchCanceller = lyricsManager.lyricsPublisher(request: req)
            .timeout(.seconds(10), scheduler: DispatchQueue.lyricsDisplay.cx)
            .sink(receiveCompletion: { [unowned self] _ in
                if defaults[.writeToiTunesAutomatically] {
                    self.writeToiTunes(overwrite: true)
                }
            }, receiveValue: { [unowned self] lyrics in
                self.lyricsReceived(lyrics: lyrics)
            })
    }
    
    // MARK: - Async Lyrics Search (Modern API)
    
    /// Searches for lyrics asynchronously using the modern async/await API.
    /// - Parameters:
    ///   - title: The song title.
    ///   - artist: The artist name.
    ///   - duration: The track duration.
    /// - Returns: The best matching lyrics, or nil if none found.
    func searchLyricsAsync(title: String, artist: String, duration: TimeInterval) async -> Lyrics? {
        do {
            let results = try await lyricsService.searchLyrics(
                title: title,
                artist: artist,
                duration: duration,
                limit: 5
            )
            return results.first
        } catch {
            log("Async lyrics search failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        guard let req = searchRequest,
            lyrics.metadata.request == req,
            let track = selectedPlayer.currentTrack else {
            return
        }
        if defaults[.strictSearchEnabled] && !lyrics.isMatched() {
            return
        }
        if let current = currentLyrics, current.quality >= lyrics.quality {
            return
        }
        lyrics.associateWithTrack(track)
        lyrics.filtrate()
        lyrics.recognizeLanguage()
        lyrics.metadata.needsPersist = true
        currentLyrics = lyrics
    }
}

// MARK: - Lyrics Import

extension AppController {
    
    func importLyrics(_ lyricsString: String) throws {
        guard let lrc = Lyrics(lyricsString) else {
            throw LyricsXError.parsingError(reason: "Invalid lyric file format")
        }
        guard let track = selectedPlayer.currentTrack else {
            throw LyricsXError.playerNotAvailable
        }
        lrc.metadata.title = track.title
        lrc.metadata.artist = track.artist
        lrc.filtrate()
        lrc.recognizeLanguage()
        lrc.metadata.needsPersist = true
        currentLyrics = lrc
        if let index = defaults[.noSearchingTrackIds].firstIndex(of: track.id) {
            defaults[.noSearchingTrackIds].remove(at: index)
        }
        if let index = defaults[.noSearchingAlbumNames].firstIndex(of: track.album ?? "") {
            defaults[.noSearchingAlbumNames].remove(at: index)
        }
    }
    
    /// Imports lyrics asynchronously using the modern async/await API.
    /// - Parameter lyricsString: The lyrics content string to import.
    /// - Throws: `LyricsXError` if the import fails.
    func importLyricsAsync(_ lyricsString: String) async throws {
        let lyrics = try lyricsService.parseLRCX(lyricsString)
        
        guard let track = selectedPlayer.currentTrack else {
            throw LyricsXError.playerNotAvailable
        }
        
        var importedLyrics = lyrics
        importedLyrics.metadata.title = track.title
        importedLyrics.metadata.artist = track.artist
        importedLyrics.filtrate()
        importedLyrics.recognizeLanguage()
        importedLyrics.metadata.needsPersist = true
        
        await MainActor.run {
            self.currentLyrics = importedLyrics
            if let index = defaults[.noSearchingTrackIds].firstIndex(of: track.id) {
                defaults[.noSearchingTrackIds].remove(at: index)
            }
            if let index = defaults[.noSearchingAlbumNames].firstIndex(of: track.album ?? "") {
                defaults[.noSearchingAlbumNames].remove(at: index)
            }
        }
    }
}
