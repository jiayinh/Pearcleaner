//
//  AppState.swift
//  PearBrew
//
//  Created by Alin Lupascu on 10/31/23.
//  Modified by jiayinh: Removed App Cleaner state; kept only Homebrew/Updater state.
//

import AlinFoundation
import Foundation
import SwiftUI

let home = FileManager.default.homeDirectoryForCurrentUser.path

class AppState: ObservableObject {
        // MARK: - Singleton Instance
        static let shared = AppState()

        @Published var currentPage: CurrentPage

        init() {
                    // Initialize currentPage from stored startup view preference
                    let storedStartupView = UserDefaults.standard.integer(forKey: "settings.interface.startupView")
                    let storedPage = CurrentPage(rawValue: storedStartupView) ?? .homebrew
                    self.currentPage = CurrentPage.availablePages.contains(storedPage) ? storedPage : .homebrew
        }

        // MARK: - Hidden Pages Management

        static func loadHiddenPages() -> Set<Int> {
                    guard let data = UserDefaults.standard.data(forKey: "settings.interface.hiddenPages"),
                          let decoded = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
                                          return []
                          }
                    return decoded
        }

        static func saveHiddenPages(_ pages: Set<Int>) {
                    if let encoded = try? JSONEncoder().encode(pages) {
                                    UserDefaults.standard.set(encoded, forKey: "settings.interface.hiddenPages")
                    }
        }
}
