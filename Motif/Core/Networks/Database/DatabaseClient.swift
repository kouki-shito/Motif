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
    var insertProject: @Sendable (_ project: Project) async throws -> Void
    var updateProject: @Sendable (_ updatedProject: UpdatedProject ) async throws -> Void
    var deleteProject: @Sendable (_ id: UUID) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static let liveValue = Self(
        insertProject: { project in
            @Dependency(\.defaultDatabase) var database
            guard project.title.isNotBlank() else {
                throw DatabaseError.InsertError.titleIsBlank
            }
            try database.write { db in
                try Project.insert { project }
                    .execute(db)
            }
        },
        updateProject: { project in
            @Dependency(\.defaultDatabase) var database
            guard project.title.isNotBlank() else { throw DatabaseError.UpdateError.titleIsBlank }
            try database.write { db in
                try Project.update {
                    $0.title = project.title
                    $0.description = project.description
                    $0.bpm = project.bpm
                    $0.key = project.key
                    $0.genre_id = project.genre_id
                }.where {
                    $0.id.is(project.id)
                }
                .execute(db)
            }
        },
        deleteProject: { id in
            @Dependency(\.defaultDatabase) var database
            try database.write { db in
                try Project.find(id)
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
