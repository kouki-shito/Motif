//
//  MotifApp.swift
//  Motif
//
//  Created by 市東 on 2026/05/06.
//

import SwiftUI
import SQLiteData
import ComposableArchitecture

@main
struct MotifApp: App {
    init() {
        prepareDependencies {
            let db = try! appDatabase()
            $0.defaultDatabase = db
        }
    }
    var body: some Scene {
        WindowGroup {
            RecordListView(store: Store(initialState: RecordListReducer.State(), reducer: {
                RecordListReducer()
            }))
        }
    }
}
