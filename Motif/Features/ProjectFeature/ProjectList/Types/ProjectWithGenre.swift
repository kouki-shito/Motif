//
//  ProjectWithGenre.swift
//  Motif
//
//  Created by 市東 on 2026/05/12.
//

import Foundation
import SQLiteData

@Selection
struct ProjectWithGenre: Equatable {
    let id: UUID
    let createdAt: Date
    let title: String
    let description: String
    let bpm: Int?
    let key: Key?
    let genre_name: String?
}
