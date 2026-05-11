//
//  Genre.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import Foundation
import SQLiteData

@Table("Genres")
struct Genre: Equatable, Identifiable, Sendable, Hashable {
    let id: UUID
    let name: String
}
