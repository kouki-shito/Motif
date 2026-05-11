//
//  Project.swift
//  Motif
//
//  Created by 市東 on 2026/05/07.
//

import Foundation
import SQLiteData

@Table("Projects")
struct Project: Equatable, Identifiable, Sendable, Hashable {
    let id: UUID
    let createdAt: Date
    var title: String
    var description: String
    var lyric: String
    var bpm: Int?
    var key: Key?
    var genre_id: Genre.ID?
}
