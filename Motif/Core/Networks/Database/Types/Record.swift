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
    let project_id: Project.ID
    
    init(id: UUID = UUID(), createdAt: Date = Date(), name: String, project_id: Project.ID) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.project_id = project_id
    }
}
