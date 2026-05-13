//
//  String+Extension.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import Foundation

extension String {
    func isNotBlank() -> Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
