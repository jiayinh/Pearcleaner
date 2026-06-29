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
        let defaultAppFolders = [
            "/Applications",
            "\(NSHomeDirectory())/Applications"
        ]

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
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    succeeded = false
                    printOS("PearBrew could not remove \(url.path): \(error.localizedDescription)")
                }
            }
        }

        return succeeded
    }

    @discardableResult
    func restoreFiles(filePairs: [(from: URL, to: URL)]) -> Bool {
        var succeeded = true

        for pair in filePairs {
            do {
                if FileManager.default.fileExists(atPath: pair.to.path) {
                    try FileManager.default.removeItem(at: pair.to)
                }
                try FileManager.default.moveItem(at: pair.from, to: pair.to)
            } catch {
                succeeded = false
                printOS("PearBrew could not restore \(pair.to.path): \(error.localizedDescription)")
            }
        }

        return succeeded
    }
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

    func runCommand(_ command: String) async -> (Bool, String) {
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
    ) else {
        return 0
    }

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
