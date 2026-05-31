//
//  LibraryReducer.swift
//  Motif
//
//  Created by 市東 on 2026/05/14.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SQLiteData

@Reducer
struct LibraryReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var recordingReducerState: RecordingReducer.State?
        var selectedTag: TagSelection = .all
        var selectedFolder: FolderSelection = .all
        var searchText: String = ""
        @FetchAll var folders: [Folder]
        @FetchAll var tags: [Tag]
        @FetchAll(
            Record
                .order { $0.createdAt.desc() }
                .group(by: \.id)
                .leftJoin(RecordJunctionTag.all) { $0.id.eq($1.record_id) }
                .leftJoin(Tag.all) { $1.tag_id.eq($2.id) }
                .select {
                    RecordWithTags.Columns(
                        record: $0,
                        tags: $2.jsonGroupArray()
                    )
                }
        )
        var recordWithTags: [RecordWithTags]
    }
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(internalAction)
        case delegate(delegateAction)
        case binding(BindingAction<State>)
        case recordingReducerAction(PresentationAction<RecordingReducer.Action>)
        enum ViewAction: Equatable {
            case recordButtonTapped
        }
        enum internalAction: Equatable {}
        enum delegateAction: Equatable {}
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .view(let action):
                switch action {
                case .recordButtonTapped:
                    state.recordingReducerState = RecordingReducer.State()
                    return .none
                }
            case .recordingReducerAction:
                return .none
            }
        }
        .ifLet(\.$recordingReducerState, action: \.recordingReducerAction) {
            RecordingReducer()
        }
    }
}
