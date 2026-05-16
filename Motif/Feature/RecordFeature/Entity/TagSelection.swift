//
//  TagSelection.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import Foundation
import SQLiteData

nonisolated enum TagSelection: Equatable, Sendable, Hashable {
    case all
    case tag(Tag)
    
    var description: String {
        switch self {
        case .all:
            return "すべてのタグ"
        case .tag(let tag):
            return tag.name
        }
    }
}
