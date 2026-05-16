//
//  UpdatedProject.swift
//  Motif
//
//  Created by 市東 on 2026/05/12.
//

import Foundation

struct UpdatedProject: Equatable, Identifiable, Sendable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var bpm: Int?
    var key: Key?
    var genre_id: Genre.ID?
}

