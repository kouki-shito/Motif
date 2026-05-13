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
        CREATE TABLE "projects" (
            "id"    TEXT NOT NULL,
            "createdAt"    TEXT NOT NULL,
            "title"    TEXT NOT NULL CHECK(TRIM("title") <> ''),
            "description"    TEXT NOT NULL DEFAULT '',
            "lyric"    TEXT NOT NULL DEFAULT "",
            "bpm"    INTEGER CHECK("bpm" > 0),
            "key"    INTEGER,
            "genre_id"    INTEGER,
            PRIMARY KEY("id"),
            FOREIGN KEY("genre_id") REFERENCES "genres"("id")
        )STRICT
        """
        ).execute(db)
        try #sql(
        """
        CREATE TABLE "genres" (
            "id"    INTEGER,
            "name"    TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
        ) STRICT
        """
        ).execute(db)
        try #sql(
        """
        INSERT INTO genres
            (name)
        VALUES
            ('Electro'),
            ('Jazz'),
            ('J-POP'),
            ('Rock'),
            ('Anime');
        """
        ).execute(db)
        
    }
    try migrator.migrate(database)
    return database
}
