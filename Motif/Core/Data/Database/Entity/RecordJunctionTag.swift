//
//  RecordJunctionTag.swift
//  Motif
//
//  Created by 市東 on 2026/05/15.
//

import Foundation
import SQLiteData

@Table("records_tags")
nonisolated struct RecordJunctionTag: Equatable, Hashable {
    let record_id: Record.ID
    let tag_id: Tag.ID
}
