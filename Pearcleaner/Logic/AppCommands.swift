//
//  AppCommands.swift
//  Pearcleaner
//
//  Created by Alin Lupascu on 10/31/23.
//

import SwiftUI
import AlinFoundation

struct AppCommands: Commands {

    let appState: AppState
    let locations: Locations
    let fsm: FolderSettingsManager
    let updater: Updater
    @AppStorage("settings.interface.animationEnabled") private var animationEnabled: Bool = true
    @AppStorage("settings.general.selectedTab") private var selectedTab: CurrentTabView = .general
    @State private var windowController = WindowManager()
    @ObservedObject private var debugLogger = UpdaterDebugLogger.shared

    init(appState: AppState, locations: Locations, fsm: FolderSettingsManager, updater: Updater) {
        self.appState = appState
        self.locations = locations
        self.fsm = fsm
        self.updater = updater
    }

    var body: some Commands {
        
        // Pearcleaner Menu
        CommandGroup(replacing: .appInfo) {

            Button {
                openAppSettingsWindow(tab: .about, updater: updater)
            } label: {
                Label("About \(Bundle.main.name)", systemImage: "info.circle.fill")
            }

            Divider()

            Button {
                openAppSettingsWindow(updater: updater)
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
            .keyboardShortcut(",", modifiers: .command)

            Button {
                updater.checkForUpdates(sheet: true, force: true)
            } label: {
                Label("Check for Updates", systemImage: "tray.and.arrow.down.fill")
            }
            .keyboardShortcut("u", modifiers: .command)
        }


        // Window Menu
        CommandGroup(after: .sidebar) {

            Menu {
                Button
                {
                    appState.currentPage = .homebrew

                } label: {
                    Text("Homebrew")
                }
                .keyboardShortcut("1", modifiers: .command)

                Button
                {
                    appState.currentPage = .updater

                } label: {
                    Text("Updater")
                }
                .keyboardShortcut("2", modifiers: .command)

            } label: {
                Label("Navigate To", systemImage: "location.north.fill")
            }

        }


        // Tools Menu
        CommandMenu(Text("Tools", comment: "Tools Menu")) {

            Button {
                Task { @MainActor in
                    switch appState.currentPage {
                    case .homebrew:
                        NotificationCenter.default.post(name: NSNotification.Name("HomebrewViewShouldRefresh"), object: nil)
                    case .updater:
                        NotificationCenter.default.post(name: NSNotification.Name("UpdaterViewShouldRefresh"), object: nil)
                    default:
                        break
                    }
                }
            } label: {
                Label("Refresh", systemImage: "arrow.counterclockwise.circle")
            }
            .keyboardShortcut("r", modifiers: .command)

        }

        CommandGroup(after: .help) {
            // Debug options
            Button {
                withAnimation(Animation.easeInOut(duration: animationEnabled ? 0.35 : 0)) {
                    windowController.open(with: ConsoleView(), width: 600, height: 400)
                }
            } label: {
                Label("Debug Console", systemImage: "ladybug")
            }
            .keyboardShortcut("d", modifiers: .command)

            Button {
                // Export debug info to file
                exportDebugInfo(appState: appState)
            } label: {
                Label("Export Debug Info...", systemImage: "info.circle")
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])

            // Updater debug log export (only visible on Updater page)
            if appState.currentPage == .updater {
                Button {
                    exportUpdaterDebugInfo()
                } label: {
                    Label("Export Updater Debug Log...", systemImage: "arrow.triangle.2.circlepath.circle")
                }
                .keyboardShortcut("u", modifiers: [.command, .shift])
                .disabled(!debugLogger.hasLogs)
            }

            Divider()

            // GitHub Menu
            Button
            {
                NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner")!)
            } label: {
                Label("View Repository", systemImage: "paperplane")
            }


            Button
            {
                NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner/releases")!)
            } label: {
                Label("View Releases", systemImage: "paperplane")
            }


            Button
            {
                NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner/issues")!)
            } label: {
                Label("View Issues", systemImage: "paperplane")
            }


            Divider()


            Button
            {
                NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner/issues/new/choose")!)
            } label: {
                Label("Submit New Issue", systemImage: "paperplane")
            }
        }


    }
}
