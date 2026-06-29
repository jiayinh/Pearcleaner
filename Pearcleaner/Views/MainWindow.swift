//
//  MainWindow.swift
//  PearBrew
//

import AlinFoundation
import SwiftUI

struct MainWindow: View {
    @ObservedObject private var consoleManager = GlobalConsoleManager.shared
    @StateObject private var brewManager = HomebrewManager()
    @StateObject private var updateManager = UpdateManager.shared
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: Updater
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("settings.interface.animationEnabled") private var animationEnabled: Bool = true
    @AppStorage("settings.updater.loadOnStartup") private var loadUpdatesOnStartup: Bool = true
    @AppStorage("settings.console.state") private var consoleStateData: Data = Data()
    @State private var showUpdateView = false
    @State private var showFeatureView = false
    @State private var glowRadius = 0.0

    var body: some View {
        Group {
            switch appState.currentPage {
            case .updater:
                withConsole {
                    AppsUpdaterView()
                        .environmentObject(brewManager)
                        .environmentObject(updateManager)
                }
            default:
                HomebrewView()
                    .environmentObject(brewManager)
            }
        }
        .background(backgroundView(color: ThemeColors.shared(for: colorScheme).primaryBG))
        .frame(minWidth: 900, minHeight: 650)
        .sheet(isPresented: $updater.sheet) {
            updater.getUpdateView()
        }
        .task {
            if let decoded = try? JSONDecoder().decode(ConsoleState.self, from: consoleStateData) {
                await MainActor.run {
                    consoleManager.showConsole = decoded.isOpen
                    consoleManager.consoleHeight = decoded.height
                }
            }
        }
        .onChange(of: consoleManager.showConsole) { newValue in
            saveConsoleState()
            if !newValue {
                Task { @MainActor in
                    consoleManager.trimOutput(toLines: 300)
                }
            }
        }
        .onChange(of: consoleManager.consoleHeight) { _ in
            saveConsoleState()
        }
        .toolbar {
            TahoeToolbarItem(placement: .navigation, isGroup: true) {
                pageSelector
                noticeArea
            }
        }
    }

    private var pageSelector: some View {
        Menu {
            ForEach(CurrentPage.availablePages, id: \.self) { page in
                Button {
                    withAnimation(.easeInOut(duration: animationEnabled ? 0.3 : 0)) {
                        appState.currentPage = page
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: page.icon)
                            .frame(width: 16)
                        if page == .updater && (loadUpdatesOnStartup || updateManager.totalUpdateCount > 0) {
                            Text(page.title)
                                .badge(updateManager.totalUpdateCount)
                        } else {
                            Text(page.title)
                        }
                    }
                    .foregroundStyle(ThemeColors.shared(for: colorScheme).primaryText)
                }
            }
        } label: {
            Image(systemName: appState.currentPage.icon)
        }
        .menuIndicator(.hidden)
    }

    @ViewBuilder
    private var noticeArea: some View {
        if updater.updateAvailable {
            noticeButton(image: "icloud.and.arrow.down.fill", color: .green, help: "Update Available") {
                showUpdateView.toggle()
            }
            .sheet(isPresented: $showUpdateView) {
                updater.getUpdateView()
            }
        } else if updater.announcementAvailable {
            noticeButton(image: "sparkles.2", color: .purple, help: "New Feature") {
                showFeatureView.toggle()
            }
            .sheet(isPresented: $showFeatureView) {
                updater.getAnnouncementView()
            }
        }
    }

    private func noticeButton(image: String, color: Color, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: image)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .shadow(color: Color(NSColor.windowBackgroundColor).opacity(1), radius: 1)
                .shadow(color: color.opacity(1), radius: glowRadius)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: glowRadius)
        }
        .buttonStyle(.plain)
        .help(help)
        .onAppear {
            glowRadius = 5.0
        }
    }

    @ViewBuilder
    private func withConsole<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
            if consoleManager.showConsole {
                GlobalConsoleView(
                    output: consoleManager.consoleOutput,
                    height: $consoleManager.consoleHeight,
                    onClear: {
                        Task { @MainActor in
                            consoleManager.clearOutput()
                        }
                    }
                )
                .frame(height: consoleManager.consoleHeight)
                .transition(.move(edge: .bottom))
            }
        }
    }

    private func saveConsoleState() {
        let state = ConsoleState(isOpen: consoleManager.showConsole, height: consoleManager.consoleHeight)
        if let encoded = try? JSONEncoder().encode(state) {
            consoleStateData = encoded
        }
    }
}
