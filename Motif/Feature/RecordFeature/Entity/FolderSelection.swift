//
//  FolderSelection.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import Foundation
import SQLiteData

nonisolated enum FolderSelection: Equatable, Hashable {
    case all
    case folder(Folder)
    
    var description: String {
        switch self {
        case .all:
            return "すべてのメモ"
        case .folder(let folder):
            return folder.name
        }
    }
}
