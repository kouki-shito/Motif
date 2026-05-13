//
//  Genre.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import Foundation
import SQLiteData

@Table("genres")
struct Genre: Equatable, Identifiable, Sendable, Hashable {
    let id: Int
    let name: String
}
