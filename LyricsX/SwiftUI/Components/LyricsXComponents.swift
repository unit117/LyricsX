//
//  LyricsXComponents.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// A styled toggle component for LyricsX settings
public struct LyricsXToggle: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    public init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: LyricsXSpacing.xs) {
                Text(title)
                    .font(LyricsXTypography.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(LyricsXTypography.caption)
                        .foregroundColor(LyricsXColors.textSecondary)
                }
            }
        }
        .toggleStyle(.switch)
        .tint(LyricsXColors.accent)
    }
}

/// A section header component
public struct LyricsXSectionHeader: View {
    let title: String
    let icon: String?
    
    public init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    public var body: some View {
        HStack(spacing: LyricsXSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(LyricsXColors.accent)
            }
            
            Text(title)
                .font(LyricsXTypography.headline)
                .foregroundColor(LyricsXColors.textPrimary)
            
            Spacer()
        }
        .padding(.bottom, LyricsXSpacing.xs)
    }
}

/// A picker row component for settings
public struct LyricsXPickerRow<Selection: Hashable>: View {
    let title: String
    let options: [(String, Selection)]
    @Binding var selection: Selection
    
    public init(_ title: String, options: [(String, Selection)], selection: Binding<Selection>) {
        self.title = title
        self.options = options
        self._selection = selection
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(LyricsXTypography.body)
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.1) { option in
                    Text(option.0).tag(option.1)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 200)
        }
    }
}

/// A slider row component for settings
public struct LyricsXSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double?
    let valueFormatter: (Double) -> String
    
    public init(
        _ title: String,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double? = nil,
        formatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.valueFormatter = formatter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: LyricsXSpacing.sm) {
            HStack {
                Text(title)
                    .font(LyricsXTypography.body)
                
                Spacer()
                
                Text(valueFormatter(value))
                    .font(LyricsXTypography.body)
                    .foregroundColor(LyricsXColors.textSecondary)
                    .frame(minWidth: 40, alignment: .trailing)
            }
            
            if let step = step {
                Slider(value: $value, in: range, step: step)
                    .tint(LyricsXColors.accent)
            } else {
                Slider(value: $value, in: range)
                    .tint(LyricsXColors.accent)
            }
        }
    }
}

/// A color picker row component
public struct LyricsXColorPickerRow: View {
    let title: String
    @Binding var color: Color
    
    public init(_ title: String, color: Binding<Color>) {
        self.title = title
        self._color = color
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(LyricsXTypography.body)
            
            Spacer()
            
            ColorPicker("", selection: $color, supportsOpacity: true)
                .labelsHidden()
        }
    }
}

/// A button row component for actions
public struct LyricsXButtonRow: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(LyricsXColors.textSecondary)
            }
            .font(LyricsXTypography.body)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#if DEBUG
struct LyricsXComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: LyricsXSpacing.lg) {
            LyricsXSectionHeader("General", icon: "gear")
            
            LyricsXToggle(
                "Enable Desktop Lyrics",
                subtitle: "Show floating lyrics on your desktop",
                isOn: .constant(true)
            )
            
            LyricsXSliderRow(
                "Font Size",
                value: .constant(24),
                in: 12...48,
                step: 1
            )
            
            LyricsXColorPickerRow("Text Color", color: .constant(.white))
            
            LyricsXButtonRow("Choose Folder", icon: "folder") {}
        }
        .padding()
        .frame(width: 400)
    }
}
#endif
