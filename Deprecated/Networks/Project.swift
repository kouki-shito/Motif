//
//  Project.swift
//  Motif
//
//  Created by 市東 on 2026/05/07.
//

import Foundation
import SQLiteData

@Table("projects")
struct Project: Equatable, Identifiable, Sendable, Hashable {
    let id: UUID
    let createdAt: Date
    var title: String
    var description: String
    var bpm: Int?
    var key: Key?
    var genre_id: Genre.ID?
    
    init(id: UUID = UUID(), createdAt: Date = Date(), title: String, description: String, bpm: Int? = nil, key: Key? = nil, genre_id: Genre.ID? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.description = description
        self.bpm = bpm
        self.key = key
        self.genre_id = genre_id
    }
}
