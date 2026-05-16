//
//  Folder.swift
//  Motif
//
//  Created by 市東 on 2026/05/15.
//

import Foundation
import SQLiteData

@Table("folders")
nonisolated struct Folder: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
}
