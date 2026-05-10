//
//  Project.swift
//  Motif
//
//  Created by 市東 on 2026/05/07.
//

import Foundation

struct Project: Equatable, Identifiable, Sendable, Hashable {
    let id: UUID
    let createdAt: Date
    var title: String
    var description: String
    var bpm: Int?
    var key: Key?
    var genre_id: UUID?
}
