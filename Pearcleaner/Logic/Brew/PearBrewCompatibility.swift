//
//  PearBrewCompatibility.swift
//  PearBrew
//
//  Small compatibility layer for the PearBrew fork. These shims keep the
//  retained Homebrew and updater workflows building without restoring the
//  removed app-cleaner/helper feature set from Pearcleaner.
//

import Foundation
import SwiftUI
import AppKit
import AlinFoundation

final class FolderSettingsManager: ObservableObject {
    static let shared = FolderSettingsManager()

    @Published var folderPaths: [String] {
        didSet {
            fileFolderPathsApps = folderPaths
            save()
        }
    }

    @Published var folderPathsZ: [String] {
        didSet { save() }
    }

    @Published var fileFolderPathsApps: [String]

    private let appFoldersKey = "pearbrew.folderPaths"
    private let extraFoldersKey = "pearbrew.folderPathsZ"

    private init() {
        let defaultAppFolders = ["/Applications", "\(NSHomeDirectory())/Applications"]
        let defaults = UserDefaults.standard
        let appFolders = defaults.stringArray(forKey: appFoldersKey) ?? defaultAppFolders
        self.folderPaths = appFolders
        self.folderPathsZ = defaults.stringArray(forKey: extraFoldersKey) ?? []
        self.fileFolderPathsApps = appFolders
    }

    func addPath(_ path: String) {
        guard !folderPaths.contains(path) else { return }
        folderPaths.append(path)
    }

    func removePath(_ path: String) {
        folderPaths.removeAll { $0 == path }
    }

    func addPathZ(_ path: String) {
        guard !folderPathsZ.contains(path) else { return }
        folderPathsZ.append(path)
    }

    func removePathZ(_ path: String) {
        folderPathsZ.removeAll { $0 == path }
    }

    private func save() {
        UserDefaults.standard.set(folderPaths, forKey: appFoldersKey)
        UserDefaults.standard.set(folderPathsZ, forKey: extraFoldersKey)
    }
}

final class Locations: ObservableObject {}

enum PathEnv: String, Codable, CaseIterable, Identifiable {
    case none
    var id: String { rawValue }
}

enum SearchSensitivityLevel: String, Codable, CaseIterable {
    case low
    case normal
    case high
}

struct FuzzyMatchResult {
    let weight: Int
}

protocol FuzzySearchable {
    var searchableString: String { get }
}

extension FuzzySearchable {
    func fuzzyMatch(query: String) -> FuzzyMatchResult {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return FuzzyMatchResult(weight: 1) }
        let normalizedTarget = searchableString.lowercased()
        return FuzzyMatchResult(weight: normalizedTarget.contains(normalizedQuery) ? 1 : 0)
    }
}

func createOptimalChunks<T>(from items: [T], minChunkSize: Int, maxChunkSize: Int) -> [[T]] {
    guard !items.isEmpty else { return [] }
    let chunkSize = max(minChunkSize, min(maxChunkSize, max(1, items.count / 4)))
    return stride(from: 0, to: items.count, by: chunkSize).map {
        Array(items[$0..<min($0 + chunkSize, items.count)])
    }
}

func handleLaunchMode() {}

func loadApps(folderPaths: [String]) {
    Task { await loadAppsAsync(folderPaths: folderPaths, useStreaming: false) }
}

func loadAppsAsync(folderPaths: [String], useStreaming: Bool = false) async {
    let apps = folderPaths.flatMap { folder -> [AppInfo] in
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: URL(fileURLWithPath: folder),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return urls.filter { $0.pathExtension == "app" }.compactMap { AppInfoFetcher.getAppInfo(atPath: $0) }
    }

    await MainActor.run {
        AppState.shared.sortedApps = apps.sorted { $0.appName < $1.appName }
    }
}

func invalidateCaskLookupCache() {}
func flushBundleCache(for url: URL) {}
func flushBundleCaches(for apps: [AppInfo]) {}

struct Pearcleaner {
    static func flushBundleCaches(for apps: [AppInfo]) {}
}

enum AppInfoUtils {
    static func fetchAppIcon(for url: URL, wrapped: Bool = false) -> NSImage? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}

enum AppInfoFetcher {
    static func getAppInfo(atPath url: URL) -> AppInfo? {
        guard let bundle = Bundle(url: url) else { return nil }
        let info = bundle.infoDictionary ?? [:]
        let bundleID = bundle.bundleIdentifier ?? url.deletingPathExtension().lastPathComponent
        let appName = (info["CFBundleDisplayName"] as? String)
            ?? (info["CFBundleName"] as? String)
            ?? url.deletingPathExtension().lastPathComponent
        let version = (info["CFBundleShortVersionString"] as? String)
            ?? (info["CFBundleVersion"] as? String)
            ?? ""
        let build = info["CFBundleVersion"] as? String
        let icon = AppInfoUtils.fetchAppIcon(for: url)

        return AppInfo(
            id: UUID(),
            path: url,
            bundleIdentifier: bundleID,
            appName: appName,
            appVersion: version,
            appBuildNumber: build,
            appIcon: icon,
            webApp: false,
            wrapped: false,
            system: url.path.hasPrefix("/System/"),
            arch: .empty,
            cask: nil,
            steam: false,
            hasSparkle: false,
            isAppStore: false,
            adamID: nil,
            autoUpdates: nil,
            bundleSize: totalSizeOnDisk(for: url),
            lipoSavings: nil,
            fileSize: [:],
            fileIcon: [:],
            creationDate: nil,
            contentChangeDate: nil,
            lastUsedDate: nil,
            dateAdded: nil,
            entitlements: nil,
            teamIdentifier: nil
        )
    }
}

final class FileManagerUndo {
    static let shared = FileManagerUndo()
    let undoManager = UndoManager()

    private init() {}

    @discardableResult
    func deleteFiles(at urls: [URL], bundleName: String = "PearBrew", isCLI: Bool = false) -> Bool {
        var succeeded = true
        for url in urls {
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            do {
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            } catch {
                do { try FileManager.default.removeItem(at: url) }
                catch { succeeded = false }
            }
        }
        return succeeded
    }

    @discardableResult
    func restoreFiles(filePairs: [(from: URL, to: URL)]) -> Bool { false }
}

final class HelperToolManager: ObservableObject {
    static let shared = HelperToolManager()
    @Published var isHelperToolInstalled = false

    private init() {}

    func installHelperTool() async -> (Bool, String) {
        (false, "PearBrew does not include the privileged helper tool.")
    }

    func uninstallHelperTool() async -> (Bool, String) {
        (true, "PearBrew does not include the privileged helper tool.")
    }

    func runCommand(_ command: String, skipHelperCheck: Bool = false) async -> (Bool, String) {
        (false, "PearBrew does not include the privileged helper tool. Run manually if administrator access is required: \(command)")
    }

    func runBundleThinning(bundlePath: String) async -> (Bool, String, [String: UInt64]) {
        (false, "PearBrew does not include bundle thinning.", [:])
    }
}

struct FatArch {
    let cpuType: UInt32
    let cpuSubtype: UInt32
    let offset: UInt32
    let size: UInt32
    let align: UInt32
}

func totalSizeOnDisk(for path: URL) -> Int64 {
    let keys: Set<URLResourceKey> = [.isRegularFileKey, .fileAllocatedSizeKey, .totalFileAllocatedSizeKey]
    var total: Int64 = 0
    if let values = try? path.resourceValues(forKeys: keys), values.isRegularFile == true {
        return Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
    }
    guard let enumerator = FileManager.default.enumerator(
        at: path,
        includingPropertiesForKeys: Array(keys),
        options: [.skipsHiddenFiles],
        errorHandler: nil
    ) else { return 0 }
    for case let fileURL as URL in enumerator {
        guard let values = try? fileURL.resourceValues(forKeys: keys), values.isRegularFile == true else { continue }
        total += Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
    }
    return total
}

func totalSizeOnDisk(for paths: [URL]) -> Int64 {
    paths.reduce(0) { $0 + totalSizeOnDisk(for: $1) }
}

func thinAppBundle(at bundlePath: URL, dryRun: Bool = false) -> (Bool, [String: UInt64]?) {
    let size = UInt64(max(totalSizeOnDisk(for: bundlePath), 0))
    return (false, ["pre": size, "post": size])
}

final class DeeplinkManager {
    init(updater: Updater, fsm: FolderSettingsManager) {}
    func manage(url: URL, appState: AppState, locations: Locations) {}
}

struct SearchBarSidebar: View {
    @Binding var search: String
    var menu: Bool = false

    var body: some View {
        TextField("Search", text: $search)
            .textFieldStyle(.roundedBorder)
    }
}

struct Header: View {
    let title: String
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
            Text("\(count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct TCCPermission: Identifiable {
    enum Source: String { case user = "USER"; case system = "SYSTEM" }
    let id = UUID()
    var displayName: String
    var source: Source = .user
    var statusText: String = "Unknown"
    var statusColor: Color = .secondary
    var sourceColor: Color = .secondary
    var reasonText: String? = nil
    var lastModified: Date? = nil
}

struct TCCQueryResult {
    var allPermissions: [TCCPermission] = []
    var hasAnyPermissions: Bool { !allPermissions.isEmpty }
}

enum TCCQueryHelper {
    static func queryAllDatabases(bundleIdentifier: String) async -> TCCQueryResult {
        TCCQueryResult()
    }
}

struct PKGReceipt {
    let identifier: String
    func packageIdentifier() -> Any? { identifier }
}

struct PKGBOMInfo {
    let totalSize: Int64
}

enum PKGManager {
    static func getAllPackages() -> [PKGReceipt] { [] }
    static func getBOMInfo(for receipt: PKGReceipt) -> PKGBOMInfo? { nil }
}
