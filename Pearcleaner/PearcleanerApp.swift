//
//  PearcleanerApp.swift
//  PearBrew
//
//  Created by Alin Lupascu on 10/31/23.
//

import SwiftUI
import AppKit
import AlinFoundation

@main
struct PearcleanerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //MARK: ObservedObjects
    @ObservedObject var appState = AppState.shared
    //MARK: StateObjects
    @StateObject var locations = Locations()
    @StateObject var fsm = FolderSettingsManager.shared
    @StateObject private var updater = Updater(owner: "jiayinh", repo: "Pearcleaner")

    init() {
        //MARK: GUI or CLI launch mode.
        handleLaunchMode()

        //MARK: Initialize password request handler for SUDO_ASKPASS IPC
        _ = PasswordRequestHandler.shared

        // The slim build is focused on Homebrew and app updates. The updater loads app data on demand.

    }

    var body: some Scene {

        WindowGroup {
            MainWindow()
                .environmentObject(appState)
                .environmentObject(locations)
                .environmentObject(fsm)
                .environmentObject(updater)

        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentMinSize)
        .commands {
            AppCommands(appState: appState, locations: locations, fsm: fsm, updater: updater)
        }
    }
}



// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false

        ensureApplicationSupportFolderExists()

        cleanupPearcleanerTempDirs()

    }

    func applicationWillTerminate(_ notification: Notification) {}

    func applicationShouldRestoreApplicationState(_ app: NSApplication) -> Bool {
        return false
    }

}
