//
//  Tag.swift
//  Motif
//
//  Created by 市東 on 2026/05/15.
//

import Foundation
import SQLiteData

@Table("tags")
nonisolated struct Tag: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
