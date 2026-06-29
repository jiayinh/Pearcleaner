//
//  Logic.swift
//  PearBrew
//
//  Created by Alin Lupascu on 10/31/23.
//  Modified by jiayinh: Removed App Cleaner logic; kept only sortKey extension used by HomebrewManager.
//

import Foundation

// MARK: - String Sorting Extension

extension String {
        /// Returns a normalized sort key that handles Chinese characters via pinyin transformation.
        /// Only applies expensive transformation when CJK characters are detected.
        var sortKey: String {
                    let containsCJK = self.unicodeScalars.contains { scalar in
                                                                                (0x4E00...0x9FFF).contains(scalar.value) ||  // CJK Unified Ideographs
                                                                                (0x3400...0x4DBF).contains(scalar.value) ||  // CJK Extension A
                                                                                (0x20000...0x2A6DF).contains(scalar.value)   // CJK Extension B
                                                                   }

                    if containsCJK {
                                    let latin = self.applyingTransform(.toLatin, reverse: false) ?? self
                                    let noTone = latin.applyingTransform(.stripDiacritics, reverse: false) ?? latin
                                    return noTone.lowercased()
                    } else {
                                    return self.lowercased()
                    }
        }
}
