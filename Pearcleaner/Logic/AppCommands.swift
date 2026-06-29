//
//  AppCommands.swift
//  PearBrew
//
//  Created by Alin Lupascu on 10/31/23.
//  Modified by jiayinh: Removed debug menu items; kept only Homebrew/Updater navigation and refresh commands.
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
                                                        Button {
                                                                                appState.currentPage = .homebrew
                                                        } label: {
                                                                                Text("Homebrew")
                                                        }
                                                        .keyboardShortcut("1", modifiers: .command)

                                                        Button {
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
                                    Button {
                                                        NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner")!)
                                    } label: {
                                                        Label("View Repository", systemImage: "paperplane")
                                    }

                                    Button {
                                                        NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner/releases")!)
                                    } label: {
                                                        Label("View Releases", systemImage: "paperplane")
                                    }

                                    Divider()

                                    Button {
                                                        NSWorkspace.shared.open(URL(string: "https://github.com/jiayinh/Pearcleaner/issues/new/choose")!)
                                    } label: {
                                                        Label("Submit New Issue", systemImage: "paperplane")
                                    }
                    }

        }
}
