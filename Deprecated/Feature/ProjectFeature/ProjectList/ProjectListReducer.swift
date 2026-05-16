//
//  ProjectListReducer.swift
//  Motif
//
//  Created by 市東 on 2026/05/12.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SQLiteData

@Reducer
struct ProjectListReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var projectEditSheetState: ProjectEditSheetReducer.State?
        @FetchAll(
            Project.leftJoin(Genre.all) { $0.genre_id.is($1.id)}
                .order { project, _ in
                    project.createdAt.desc()
                }
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
        ) var projects: [ProjectWithGenre]
    }
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(internalAction)
        case delegate(delegateAction)
        case binding(BindingAction<State>)
        case projectEditSheetAction(PresentationAction<ProjectEditSheetReducer.Action>)
        enum ViewAction: Equatable {
            case addProjectButtonTapped
        }
        enum internalAction: Equatable {}
        enum delegateAction: Equatable {}
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .addProjectButtonTapped:
                    state.projectEditSheetState = ProjectEditSheetReducer.State()
                    return .none
                }
            case .binding:
                return .none
            case .projectEditSheetAction:
                return .none
            }
        }
        .ifLet(\.$projectEditSheetState, action: \.projectEditSheetAction) {
            ProjectEditSheetReducer()
        }
    }
}

