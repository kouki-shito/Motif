//
//  DatabaseRecoveryManager.swift
//  Motif
//
//  Created by 市東 on 2026/06/05.
//

import Foundation
import SQLiteData
import AVFoundation

struct DatabaseRecoveryManager: Sendable {
    
    @Table("temp_ids")
    struct Row {
        let id: UUID
        let createdAt: Date
        let url: URL
    }
    
    let database: DatabaseWriter
    func autoRecoveryRecords() async {
        do {
            let manager = FileManager.default
            guard let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let recordingDir = documentDir.appending(component: "Records", directoryHint: .isDirectory)
            let files = try manager.contentsOfDirectory(at: recordingDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let rows: [Row] = files.compactMap { url in
                guard url.pathExtension == "m4a" else { return nil }
                let uuidString = url.deletingPathExtension().lastPathComponent
                guard let uuid = UUID(uuidString: uuidString) else { return nil }
                let createdAt = (try? manager.attributesOfItem(atPath: url.path)[.creationDate] as? Date) ?? Date()
                return Row(id: uuid, createdAt: createdAt, url: url)
            }
            let notExistsRow: [Row] = try await database.write { db in
                try #sql(
                    """
                    CREATE TEMPORARY TABLE "temp_ids" (
                        "id" TEXT NOT NULL,
                        "createdAt" TEXT NOT NULL,
                        "url" TEXT NOT NULL,
                        PRIMARY KEY("id")
                    )STRICT  
                    """
                ).execute(db)
                try Row.insert { rows }.execute(db)
                return try #sql(
                    """
                    SELECT \(Row.columns)
                    FROM \(Row.self)
                    WHERE NOT EXISTS(
                        SELECT \(Record.id)
                        FROM \(Record.self)
                        WHERE \(Record.id) = \(Row.id)
                    )
                    """,
                    as: Row.self
                ).fetchAll(db)
            }
            var records: [Record] = []
            for row in notExistsRow {
                do {
                    let asset = AVURLAsset(url: row.url)
                    let duration = try await asset.load(.duration)
                    records.append(Record(id: row.id, createdAt: row.createdAt, title: row.createdAt.dateToString(formatter: .recordTitle), duration: duration.seconds))
                } catch {
                    print(error)
                }
            }
            try await database.write { [records] db in
                try Record.insert { records }
                    .execute(db)
            }
        } catch {
            print(error)
        }
    }
}
