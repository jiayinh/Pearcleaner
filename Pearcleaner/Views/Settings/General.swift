//
//  General.swift
//  PearBrew
//

import SwiftUI
import AlinFoundation

struct GeneralSettingsTab: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("settings.updater.loadOnStartup") private var loadUpdatesOnStartup: Bool = true
    @AppStorage("settings.brew.cachePassword") private var cachePassword: Bool = false
    @AppStorage("settings.brew.passwordCacheDuration") private var passwordCacheDuration: Double = 300

    var body: some View {
        VStack(spacing: 20) {
            PearGroupBox(header: {
                Text("PearBrew")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .font(.title2)
            }, content: {
                VStack(alignment: .leading, spacing: 12) {
                    Text("PearBrew focuses on Homebrew management and app updates.")
                        .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    Text("App-cleaner, privileged-helper, Finder extension, package, lipo, service, plugin, and orphan-file tools are intentionally outside this fork's scope.")
                        .foregroundStyle(ThemeColors.shared(for: colorScheme).secondaryText)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            })

            PearGroupBox(header: {
                Text("Updater")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .font(.title2)
            }, content: {
                Toggle("Load app updates on startup", isOn: $loadUpdatesOnStartup)
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
            })

            PearGroupBox(header: {
                Text("Homebrew")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .font(.title2)
            }, content: {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Cache Homebrew password for privileged brew operations", isOn: $cachePassword)
                        .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)

                    if cachePassword {
                        HStack {
                            Text("Cache duration")
                                .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                            Slider(value: $passwordCacheDuration, in: 60...1800, step: 60)
                            Text("\(Int(passwordCacheDuration / 60)) min")
                                .foregroundStyle(ThemeColors.shared(for: colorScheme).secondaryText)
                                .frame(width: 55, alignment: .trailing)
                        }
                    }
                }
            })
        }
    }
}
