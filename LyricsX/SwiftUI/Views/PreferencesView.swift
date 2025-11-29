//
//  PreferencesView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// Main preferences view with tabbed navigation
@available(macOS 13.0, *)
public struct PreferencesView: View {
    @State private var selectedTab: PreferenceTab = .general
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(PreferenceTab.general)
            
            DisplayPreferencesView()
                .tabItem {
                    Label("Display", systemImage: "paintbrush")
                }
                .tag(PreferenceTab.display)
            
            ShortcutsPreferencesView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(PreferenceTab.shortcuts)
            
            FilterPreferencesView()
                .tabItem {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
                .tag(PreferenceTab.filter)
            
            LabPreferencesView()
                .tabItem {
                    Label("Lab", systemImage: "flask")
                }
                .tag(PreferenceTab.lab)
        }
        .frame(width: 500, height: 400)
    }
    
    enum PreferenceTab: Hashable {
        case general
        case display
        case shortcuts
        case filter
        case lab
    }
}

// MARK: - General Preferences

@available(macOS 13.0, *)
struct GeneralPreferencesView: View {
    @AppStorage("PreferredPlayerIndex") private var preferredPlayerIndex = -1
    @AppStorage("LaunchAndQuitWithPlayer") private var launchAndQuitWithPlayer = false
    @AppStorage("LyricsSavingPathPopUpIndex") private var savingPathIndex = 0
    @AppStorage("LoadLyricsBesideTrack") private var loadLyricsBesideTrack = true
    
    var body: some View {
        Form {
            Section {
                LyricsXSectionHeader("Music Player", icon: "music.note")
                
                Picker("Preferred Player", selection: $preferredPlayerIndex) {
                    Text("Auto Detect").tag(-1)
                    Text("Apple Music").tag(0)
                    Text("Spotify").tag(1)
                    Text("Vox").tag(2)
                    Text("Audirvana").tag(3)
                    Text("Swinsian").tag(4)
                }
                .pickerStyle(.radioGroup)
                
                LyricsXToggle(
                    "Launch and quit with player",
                    subtitle: "Automatically start LyricsX when your music player opens",
                    isOn: $launchAndQuitWithPlayer
                )
                .disabled(preferredPlayerIndex < 0)
            }
            
            Divider()
                .padding(.vertical, LyricsXSpacing.sm)
            
            Section {
                LyricsXSectionHeader("Lyrics Storage", icon: "folder")
                
                Picker("Save lyrics to", selection: $savingPathIndex) {
                    Text("Default Location").tag(0)
                    Text("Music Folder").tag(1)
                    Text("Custom...").tag(2)
                }
                
                LyricsXToggle(
                    "Load lyrics from track folder",
                    subtitle: "Check for .lrc files next to the audio file",
                    isOn: $loadLyricsBesideTrack
                )
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Display Preferences

@available(macOS 13.0, *)
struct DisplayPreferencesView: View {
    @AppStorage("DesktopLyricsEnabled") private var desktopLyricsEnabled = true
    @AppStorage("MenuBarLyricsEnabled") private var menuBarLyricsEnabled = false
    @AppStorage("DesktopLyricsOneLineMode") private var oneLineMode = false
    @AppStorage("DesktopLyricsVerticalMode") private var verticalMode = false
    @AppStorage("DesktopLyricsDraggable") private var draggable = true
    @AppStorage("DesktopLyricsFontSize") private var fontSize = 24
    @AppStorage("HideLyricsWhenMousePassingBy") private var hideOnMouseOver = true
    
    @State private var textColor = Color.white
    @State private var progressColor = Color(red: 0.2, green: 1.0, blue: 0.87)
    @State private var backgroundColor = Color.black.opacity(0.6)
    
    var body: some View {
        Form {
            Section {
                LyricsXSectionHeader("Lyrics Display", icon: "text.bubble")
                
                LyricsXToggle(
                    "Desktop Lyrics",
                    subtitle: "Show floating lyrics overlay on your desktop",
                    isOn: $desktopLyricsEnabled
                )
                
                LyricsXToggle(
                    "Menu Bar Lyrics",
                    subtitle: "Display current lyrics in the menu bar",
                    isOn: $menuBarLyricsEnabled
                )
            }
            
            Divider()
                .padding(.vertical, LyricsXSpacing.sm)
            
            Section {
                LyricsXSectionHeader("Desktop Lyrics Style", icon: "paintbrush")
                
                LyricsXToggle("One Line Mode", isOn: $oneLineMode)
                LyricsXToggle("Vertical Mode", isOn: $verticalMode)
                LyricsXToggle("Draggable", isOn: $draggable)
                LyricsXToggle("Hide when mouse passes by", isOn: $hideOnMouseOver)
                
                LyricsXSliderRow(
                    "Font Size",
                    value: Binding(
                        get: { Double(fontSize) },
                        set: { fontSize = Int($0) }
                    ),
                    in: 12...48,
                    step: 1
                ) { "\(Int($0)) pt" }
            }
            
            Divider()
                .padding(.vertical, LyricsXSpacing.sm)
            
            Section {
                LyricsXSectionHeader("Colors", icon: "paintpalette")
                
                LyricsXColorPickerRow("Text Color", color: $textColor)
                LyricsXColorPickerRow("Progress Color", color: $progressColor)
                LyricsXColorPickerRow("Background Color", color: $backgroundColor)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Shortcuts Preferences

@available(macOS 13.0, *)
struct ShortcutsPreferencesView: View {
    var body: some View {
        Form {
            Section {
                LyricsXSectionHeader("Keyboard Shortcuts", icon: "keyboard")
                
                Text("Configure global keyboard shortcuts in System Preferences > Keyboard > Shortcuts")
                    .font(LyricsXTypography.caption)
                    .foregroundColor(LyricsXColors.textSecondary)
                
                VStack(alignment: .leading, spacing: LyricsXSpacing.md) {
                    ShortcutRow(title: "Toggle Desktop Lyrics", shortcut: "⌥⌘L")
                    ShortcutRow(title: "Toggle Menu Bar Lyrics", shortcut: "⌥⌘M")
                    ShortcutRow(title: "Show Lyrics Window", shortcut: "⌥⌘W")
                    ShortcutRow(title: "Increase Offset", shortcut: "⌥⌘→")
                    ShortcutRow(title: "Decrease Offset", shortcut: "⌥⌘←")
                    ShortcutRow(title: "Search Lyrics", shortcut: "⌥⌘S")
                    ShortcutRow(title: "Wrong Lyrics", shortcut: "⌥⌘X")
                }
                .padding(.top, LyricsXSpacing.sm)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct ShortcutRow: View {
    let title: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(LyricsXTypography.body)
            
            Spacer()
            
            Text(shortcut)
                .font(LyricsXTypography.monospace)
                .foregroundColor(LyricsXColors.textSecondary)
                .padding(.horizontal, LyricsXSpacing.sm)
                .padding(.vertical, LyricsXSpacing.xs)
                .background(LyricsXColors.backgroundSecondary)
                .cornerRadius(LyricsXRadius.small)
        }
    }
}

// MARK: - Filter Preferences

@available(macOS 13.0, *)
struct FilterPreferencesView: View {
    @AppStorage("LyricsFilterEnabled") private var filterEnabled = false
    @AppStorage("LyricsSmartFilterEnabled") private var smartFilterEnabled = false
    @State private var filterKeywords: [String] = []
    @State private var newKeyword = ""
    
    var body: some View {
        Form {
            Section {
                LyricsXSectionHeader("Lyrics Filter", icon: "line.3.horizontal.decrease.circle")
                
                LyricsXToggle(
                    "Enable Filter",
                    subtitle: "Filter out unwanted content from lyrics",
                    isOn: $filterEnabled
                )
                
                LyricsXToggle(
                    "Smart Filter",
                    subtitle: "Automatically detect and filter common unwanted content",
                    isOn: $smartFilterEnabled
                )
                .disabled(!filterEnabled)
            }
            
            if filterEnabled {
                Divider()
                    .padding(.vertical, LyricsXSpacing.sm)
                
                Section {
                    LyricsXSectionHeader("Filter Keywords", icon: "text.badge.minus")
                    
                    HStack {
                        TextField("Add keyword...", text: $newKeyword)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Add") {
                            if !newKeyword.isEmpty {
                                filterKeywords.append(newKeyword)
                                newKeyword = ""
                            }
                        }
                        .disabled(newKeyword.isEmpty)
                    }
                    
                    if !filterKeywords.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: LyricsXSpacing.xs) {
                                ForEach(filterKeywords, id: \.self) { keyword in
                                    HStack {
                                        Text(keyword)
                                            .font(LyricsXTypography.body)
                                        
                                        Spacer()
                                        
                                        Button {
                                            filterKeywords.removeAll { $0 == keyword }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(LyricsXColors.textSecondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, LyricsXSpacing.xs)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Lab Preferences

@available(macOS 13.0, *)
struct LabPreferencesView: View {
    @AppStorage("UseSystemWideNowPlaying") private var useSystemWideNowPlaying = false
    @AppStorage("WriteToiTunesAutomatically") private var autoWriteToiTunes = false
    @AppStorage("WriteiTunesWithTranslation") private var writeWithTranslation = false
    @AppStorage("GlobalLyricsOffset") private var globalOffset = 0
    
    var body: some View {
        Form {
            Section {
                LyricsXSectionHeader("Experimental Features", icon: "flask")
                
                Text("These features are experimental and may not work as expected.")
                    .font(LyricsXTypography.caption)
                    .foregroundColor(.orange)
                    .padding(.bottom, LyricsXSpacing.sm)
                
                LyricsXToggle(
                    "System-wide Now Playing",
                    subtitle: "Use macOS system now playing info instead of player APIs",
                    isOn: $useSystemWideNowPlaying
                )
            }
            
            Divider()
                .padding(.vertical, LyricsXSpacing.sm)
            
            Section {
                LyricsXSectionHeader("Apple Music Integration", icon: "music.note")
                
                LyricsXToggle(
                    "Auto-write to Apple Music",
                    subtitle: "Automatically save fetched lyrics to Apple Music library",
                    isOn: $autoWriteToiTunes
                )
                
                LyricsXToggle(
                    "Include translations",
                    subtitle: "Write translated lyrics along with original",
                    isOn: $writeWithTranslation
                )
                .disabled(!autoWriteToiTunes)
            }
            
            Divider()
                .padding(.vertical, LyricsXSpacing.sm)
            
            Section {
                LyricsXSectionHeader("Advanced", icon: "slider.horizontal.3")
                
                LyricsXSliderRow(
                    "Global Lyrics Offset",
                    value: Binding(
                        get: { Double(globalOffset) },
                        set: { globalOffset = Int($0) }
                    ),
                    in: -5000...5000,
                    step: 100
                ) { "\(Int($0)) ms" }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 13.0, *)
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
#endif
