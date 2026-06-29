//
//  About.swift
//  PearBrew
//

import SwiftUI
import AlinFoundation

struct AboutSettingsTab: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isResetting = false

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage)
                Text(Bundle.main.name)
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .font(.title)
                    .bold()
                HStack {
                    Text("Version \(Bundle.main.version)")
                    Text("(Build \(Bundle.main.buildVersion))")
                        .font(.footnote)
                }
                .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)

                Text("Unofficial non-commercial fork based on Pearcleaner")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).secondaryText)
                    .font(.footnote)
            }
            .padding(.vertical, 40)

            PearGroupBox(header: {
                Text("Project")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .font(.title)
            }, content: {
                VStack(alignment: .leading, spacing: 12) {
                    Text("PearBrew keeps Pearcleaner's Homebrew and app-updater workflows, while removing the app-cleaner and privileged-helper features from the user-facing app.")
                        .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)

                    Text("This fork is not affiliated with, endorsed by, or maintained by the original Pearcleaner author.")
                        .foregroundStyle(ThemeColors.shared(for: colorScheme).secondaryText)

                    HStack {
                        Button {
                            NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner")!)
                        } label: {
                            Label("Repository", systemImage: "link")
                        }

                        Button {
                            NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/Pearcleaner")!)
                        } label: {
                            Label("Upstream", systemImage: "arrow.up.right")
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            })

            PearGroupBox(header: {
                Text("License")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .font(.title)
            }, content: {
                Text("PearBrew is distributed under Pearcleaner's Apache 2.0 with Commons Clause terms. This fork is for free personal/community use and must not be sold or monetized.")
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            })

            SettingsControlButtonGroup(isResetting: $isResetting, resetAction: {
                resetUserDefaults()
            }, exportAction: {
                exportUserDefaults()
            }, importAction: {
                importUserDefaults()
            })
        }
    }

    private func resetUserDefaults() {
        isResetting = true
        DispatchQueue.global(qos: .background).async {
            let keys = UserDefaults.standard.dictionaryRepresentation().keys
                .filter { $0.hasPrefix("settings.") }
            for key in keys {
                UserDefaults.standard.removeObject(forKey: key)
            }
            DispatchQueue.main.async {
                isResetting = false
            }
        }
    }

    private func exportUserDefaults() {
        let defaults = UserDefaults.standard.dictionaryRepresentation()
        let settingsOnly = defaults.filter { $0.key.hasPrefix("settings.") }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: settingsOnly, options: [.prettyPrinted]) else { return }

        let savePanel = NSSavePanel()
        savePanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "PearBrewSettings.json"
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            try? jsonData.write(to: url)
        }
    }

    private func importUserDefaults() {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        openPanel.allowedContentTypes = [.json]
        openPanel.begin { response in
            guard response == .OK, let url = openPanel.url,
                  let data = try? Data(contentsOf: url),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

            for (key, value) in dict {
                UserDefaults.standard.setValue(value, forKey: key)
            }
        }
    }
}
