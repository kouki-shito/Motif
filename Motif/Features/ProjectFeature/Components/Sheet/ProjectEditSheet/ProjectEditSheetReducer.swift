//
//  ProjectEditSheetReducer.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SQLiteData

@Reducer
struct ProjectEditSheetReducer {
    @ObservableState
    struct State: Equatable {
        let update_id: UUID?
        var title: String
        var description: String
        var lyric: String
        var bpm: Int?
        var key: Key?
        var genreID: Genre.ID?
        var isDismiss: Bool = false
        var isConfirmButtonActive: Bool {
            title.isNotBlank()
        }
        let majorKeyCases: [Key] = Key.majorAllCases
        let minorKeyCases: [Key] = Key.minorAllCases
        @FetchAll var genres: [Genre]
        
        init(updateProject: Project? = nil) {
            if let project = updateProject {
                self.update_id = project.id
                self.title = project.title
                self.description = project.description
                self.lyric = project.lyric
                self.bpm = project.bpm
                self.key = project.key
                self.genreID = project.genre_id
            } else {
                self.update_id = nil
                self.title = ""
                self.description = ""
                self.lyric = ""
            }
        }
    }
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(internalAction)
        case delegate(delegateAction)
        case binding(BindingAction<State>)
        enum ViewAction: Equatable {
            case confirmButtonTapped
            case addGenreButtonTapped
        }
        enum internalAction: Equatable {
            case dismiss
        }
        enum delegateAction: Equatable {}
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .confirmButtonTapped:
                    @Dependency(\.databaseClient) var db: DatabaseClient
                    if let id = state.update_id {
                        let project = UpdatedProject(
                            id: id,
                            title: state.title,
                            description: state.description,
                            lyric: state.lyric,
                            bpm: state.bpm,
                            key: state.key,
                            genre_id: state.genreID
                        )
                        return .run { send in
                            do {
                                try await db.updateProject(project)
                                await send(.internal(.dismiss))
                            } catch(let err) {
                                print(err)
                            }
                        }
                    } else {
                        let project = Project(
                            title: state.title,
                            description: state.description,
                            lyric: state.lyric,
                            bpm: state.bpm,
                            key: state.key,
                            genre_id: state.genreID
                        )
                        return .run { send in
                            do {
                                try await db.insertProject(project)
                                await send(.internal(.dismiss))
                            } catch(let err) {
                                print(err)
                            }
                        }
                    }
                case .addGenreButtonTapped:
                    return .none
                }
            case .internal(let action):
                switch action {
                case .dismiss:
                    state.isDismiss = true
                    return .none
                }
            case .binding:
                return .none
            }
        }
    }
}

