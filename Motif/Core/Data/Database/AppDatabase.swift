//
//  AppDatabase.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import OSLog
import SQLiteData

func appDatabase() throws -> any DatabaseWriter {
    let logger = Logger(subsystem: "MyApp", category: "Database")
    @Dependency(\.context) var context
    var configuration = Configuration()
    #if DEBUG
    configuration.prepareDatabase { db in
        db.trace(options: .profile) {
            if context == .preview {
                print("\($0.expandedDescription)")
            } else {
                logger.debug("\($0.expandedDescription)")
            }
        }
    }
    #endif
    let database = try defaultDatabase(configuration: configuration)
    logger.info("open '\(database.path)'")
    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create tables") { db in
        try #sql(
        """
        CREATE TABLE "records" (
            "id" TEXT NOT NULL,
            "createdAt" TEXT NOT NULL,
            "title" TEXT NOT NULL,
            "duration" REAL NOT NULL,
            "isFavorite" INTEGER NOT NULL DEFAULT 0,
            "folder_id" TEXT,
            PRIMARY KEY("id"),
            FOREIGN KEY("folder_id") REFERENCES "folders"("id") ON DELETE SET NULL
        )STRICT        
        """
        ).execute(db)
        try #sql(
        """
        CREATE TABLE "tags" (
            "id" TEXT NOT NULL,
            "name" TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id")
        )STRICT        
        """
        ).execute(db)
        try #sql(
        """
        CREATE TABLE "folders" (
            "id" TEXT NOT NULL,
            "name" TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id")
        )STRICT        
        """
        ).execute(db)
        try #sql(
        """
        CREATE TABLE "records_tags" (
            "record_id" TEXT NOT NULL,
            "tag_id" TEXT NOT NULL,
            PRIMARY KEY("record_id","tag_id"),
            FOREIGN KEY("record_id") REFERENCES "records"("id") ON DELETE CASCADE,
            FOREIGN KEY("tag_id") REFERENCES "tags"("id") ON DELETE CASCADE
        )STRICT        
        """
        ).execute(db)
        #if DEBUG
        try db.seed {
            let folder1_id = UUID()
            let folder2_id = UUID()
            let folder3_id = UUID()
            Folder(id: folder1_id, name: "生活")
            Folder(id: folder2_id, name: "授業")
            Folder(id: folder3_id, name: "音楽")
            
            let tag1_id = UUID()
            let tag2_id = UUID()
            Tag(id: tag1_id, name: "Aメロ")
            Tag(id: tag2_id, name: "Bメロ")
        }
        #endif
    }
    Task {
        let recover = DatabaseRecoveryManager(database: database)
        await recover.autoRecoveryRecords()
    }
    try migrator.migrate(database)
    return database
}
