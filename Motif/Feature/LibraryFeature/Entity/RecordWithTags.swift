//
//  RecordWithTags.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import Foundation
import SQLiteData

@Selection
nonisolated struct RecordWithTags: Equatable, Sendable, Hashable {
    let record: Record
    @Column(as: [Tag].JSONRepresentation.self)
    let tags: [Tag]
}
