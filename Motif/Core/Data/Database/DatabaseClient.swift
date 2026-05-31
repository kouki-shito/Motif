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
}

extension DatabaseClient: DependencyKey {
    static let liveValue = Self(
        insertRecord: { record in
            @Dependency(\.defaultDatabase) var database
            try database.write { db in
                try Record.insert { record }
                    .execute(db)
            }
        }, updateRecordTitle: { id, title in
            @Dependency(\.defaultDatabase) var database
            try database.write { db in
                try Record.update {
                    $0.title = title
                }.where {
                    $0.id.is(id)
                }.execute(db)
            }
        }, updateRecordFolder: { recordID, folderID in
            @Dependency(\.defaultDatabase) var database
            try database.write { db in
                try Record.update {
                    $0.folder_id = #bind(folderID)
                }.where {
                    $0.id.is(recordID)
                }.execute(db)
            }
        }, deleteRecord: { id in
            @Dependency(\.defaultDatabase) var database
            try database.write { db in
                try Record.find(id)
                    .delete()
                    .execute(db)
            }
        }
    )
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
