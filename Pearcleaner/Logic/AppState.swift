//
//  AppState.swift
//  PearBrew
//
//  Created by Alin Lupascu on 10/31/23.
//  Modified by jiayinh: Removed App Cleaner state; kept only CurrentPage, Homebrew/Updater state.
//

import AlinFoundation
import Foundation
import SwiftUI

let home = FileManager.default.homeDirectoryForCurrentUser.path

// MARK: - CurrentPage

enum CurrentPage: Int, CaseIterable, Identifiable {
            case applications
            case development
            case fileSearch
            case homebrew
            case lipo
            case orphans
            case packages
            case plugins
            case services
            case updater

            var id: Int { rawValue }

            static var debugOnlyPages: [CurrentPage] { return [] }

            static var availablePages: [CurrentPage] {
                            let hiddenPages = AppState.loadHiddenPages()
                            let slimPages: [CurrentPage] = [.homebrew, .updater]
                            #if DEBUG
                            return slimPages.filter { !hiddenPages.contains($0.rawValue) }
                            #else
                            return slimPages
                                .filter { !debugOnlyPages.contains($0) }
                                .filter { !hiddenPages.contains($0.rawValue) }
                            #endif
            }

            var details: (title: String, icon: String) {
                            switch self {
                                            case .applications: return (String(localized: "Apps"), "macwindow")
                                            case .development:  return (String(localized: "Developer"), "hammer.circle")
                                            case .fileSearch:   return (String(localized: "File Search"), "magnifyingglass")
                                            case .homebrew:     return (String(localized: "Homebrew"), "mug")
                                            case .lipo:         return (String(localized: "Lipo"), "scissors")
                                            case .orphans:      return (String(localized: "Orphans"), "doc.text.magnifyingglass")
                                            case .packages:     return (String(localized: "Packages"), "shippingbox")
                                            case .plugins:      return (String(localized: "Plugins"), "puzzlepiece")
                                            case .services:     return (String(localized: "Services"), "gearshape.2")
                                            case .updater:      return (String(localized: "Updater"), "arrow.down.circle")
                            }
            }

            var title: String { details.title }
            var icon: String { details.icon }
}

// MARK: - AppState

class AppState: ObservableObject {
            static let shared = AppState()

            @Published var currentPage: CurrentPage

            init() {
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
