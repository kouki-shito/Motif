//
//  DatabaseClient.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import Foundation
import Dependencies
import DependenciesMacros
import SQLiteData

@DependencyClient
struct DatabaseClient: Sendable {
    var insertRecord: @Sendable (_ record: Record) async throws -> Void
    var updateRecordTitle: @Sendable (_ recordID: Record.ID, _ title: String) async throws -> Void
    var updateRecordFolder: @Sendable (_ recordID: Record.ID, _ folderID: Folder.ID) async throws -> Void
    var deleteRecord: @Sendable (_ recordID: Record.ID) async throws -> Void
    var insertNewTag: @Sendable (_ tag: Tag) async throws -> Void
    var updateTagName: @Sendable (_ tagID: Tag.ID, _ name: String) async throws -> Void
    var deleteTag: @Sendable (_ tagID: Tag.ID) async throws -> Void
    var insertRecordTag: @Sendable (_ recordID: Record.ID, _ tagIDs: Set<Tag.ID>) async throws -> Void
    var deleteRecordTag: @Sendable (_ recordID: Record.ID, _ tagID: Tag.ID) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return Self(
            insertRecord: { record in
                try database.write { db in
                    try Record.insert { record }
                        .execute(db)
                }
            }, updateRecordTitle: { id, title in
                try database.write { db in
                    try Record.update {
                        $0.title = title
                    }.where {
                        $0.id.is(id)
                    }.execute(db)
                }
            }, updateRecordFolder: { recordID, folderID in
                try database.write { db in
                    try Record.update {
                        $0.folder_id = #bind(folderID)
                    }.where {
                        $0.id.is(recordID)
                    }.execute(db)
                }
            }, deleteRecord: { id in
                try database.write { db in
                    try Record.find(id)
                        .delete()
                        .execute(db)
                }
            }, insertNewTag: { tag in
                try database.write { db in
                    try Tag.insert { tag }
                        .execute(db)
                }
            }, updateTagName: { id, name in
                try database.write { db in
                    try Tag.update {
                        $0.name = name
                    }.where {
                        $0.id.is(id)
                    }.execute(db)
                }
            }, deleteTag: { id in
                try database.write { db in
                    try Tag.find(id)
                        .delete()
                        .execute(db)
                }
            }, insertRecordTag: { recordID, tagIDs in
                try database.write { db in
                    try RecordJunctionTag.insert {
                        tagIDs.map {
                            RecordJunctionTag(record_id: recordID, tag_id: $0)
                        }
                    }.execute(db)
                }
            }, deleteRecordTag: { recordID, tagID in
                try database.write { db in
                    try RecordJunctionTag.where {
                        $0.record_id.is(recordID)
                        && $0.tag_id.is(tagID)
                    }.delete()
                    .execute(db)
                }
            }
        )
    }
}

extension DatabaseClient: TestDependencyKey {
    static let previewValue = Self()
    static let testValue = Self()
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
