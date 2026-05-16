//
//  Record.swift
//  Motif
//
//  Created by 市東 on 2026/05/13.
//

import Foundation
import SQLiteData

@Table("records")
nonisolated struct Record: Identifiable, Equatable, Hashable {
    let id: UUID
    let createdAt: Date
    let title: String
    let duration: TimeInterval
    let folder_id: Folder.ID?
    
    init(id: UUID = UUID(), createdAt: Date = Date(), title: String, duration: TimeInterval, folder_id: Folder.ID?) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.duration = duration
        self.folder_id = folder_id
    }
}
