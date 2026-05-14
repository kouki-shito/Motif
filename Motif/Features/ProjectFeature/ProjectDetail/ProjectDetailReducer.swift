//
//  ProjectDetailReducer.swift
//  Motif
//
//  Created by 市東 on 2026/05/13.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SQLiteData

@Reducer
struct ProjectDetailReducer {
    @ObservableState
    struct State: Equatable {
        let project_id: Project.ID
        @FetchOne var project: ProjectWithGenre?
//        @FetchAll var records: [Record]
        var records: [Record] = [
            Record(name: "new record", project_id: UUID()),
            Record(name: "new record", project_id: UUID()),
            Record(name: "new record", project_id: UUID()),
        ]
        
        init(project_id: Project.ID) {
            self.project_id = project_id
            self._project = FetchOne(
                Project
                    .where { $0.id.is(project_id) }
                    .leftJoin(Genre.all) { $0.genre_id.is($1.id)}
                    .select {
                        ProjectWithGenre.Columns(
                            id: $0.id,
                            createdAt: $0.createdAt,
                            title: $0.title,
                            description: $0.description,
                            bpm: $0.bpm,
                            key: $0.key,
                            genre_name: $1.name
                        )
                    }
            )
//            self._records = FetchAll(
//                Record.where { $0.project_id.is(project_id) }
//            )
        }
    }
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(internalAction)
        case delegate(delegateAction)
        case binding(BindingAction<State>)
        enum ViewAction: Equatable {}
        enum internalAction: Equatable {}
        enum delegateAction: Equatable {}
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            }
        }
    }
}

