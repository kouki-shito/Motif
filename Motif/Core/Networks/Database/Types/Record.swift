//
//  Record.swift
//  Motif
//
//  Created by 市東 on 2026/05/13.
//

import Foundation
import SQLiteData

@Table("records")
struct Record: Equatable, Identifiable, Sendable, Hashable {
    let id: UUID
    let createdAt: Date
    let name: String
    
    init(id: UUID = UUID(), createdAt: Date = Date(), name: String) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
    }
}
