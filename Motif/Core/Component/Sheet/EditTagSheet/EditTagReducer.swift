//
//  EditTagReducer.swift
//  Motif
//
//  Created by 市東 on 2026/06/01.
//

import Foundation
import ComposableArchitecture
import Dependencies
import DependenciesMacros
import SwiftUI
import SQLiteData

@Reducer
struct EditTagReducer {
    @ObservableState
    struct State: Equatable {
        var selectingTags: Set<Tag.ID>
        var isShowAddTagButton: Bool {
            !tags.contains(where: {$0.name == searchingText}) && searchingText.isNotBlank()
        }
        var searchingText: String = ""
        var isDismissed: Bool = false
        @FetchAll var tags: [Tag]
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        enum ViewAction: Equatable {
            case tagTapped(Tag.ID)
            case deleteTagButtonTapped(Tag)
            case addTagButtonTapped
            case confirmButtonTapped
            case cancelButtonTapped
        }
        enum InternalAction: Equatable {
            case dismiss
        }
        enum DelegateAction: Equatable {
            case selectingTagsConfirmed(Set<Tag.ID>)
        }
        enum Alert: Equatable {
            case confirmDeleteTagButtonTapped(Tag)
        }
    }
    
    @Dependency(\.databaseClient) private var database: DatabaseClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.searchingText):
                return .run { [tags = state.$tags, text = state.searchingText] send in
                    guard await text.isNotBlank() else {
                        try await tags.load(Tag.all)
                        return
                    }
                    try await tags.load(Tag.where { $0.name.like("%\(text)%") })
                }
            case .binding:
                    return .none
            case .view(let action):
                switch action {
                case .tagTapped(let id):
                    if state.selectingTags.contains(id) {
                        state.selectingTags.remove(id)
                    } else {
                        state.selectingTags.insert(id)
                    }
                    return .none
                case .deleteTagButtonTapped(let tag):
                    state.alert = AlertState(title: {
                        TextState("「\(tag.name)」を本当に削除しますか?")
                    }, actions: {
                        ButtonState(role: .cancel) {
                            TextState("キャンセル")
                        }
                        ButtonState(role: .destructive, action: .confirmDeleteTagButtonTapped(tag)) {
                            TextState("削除")
                        }
                    }, message: {
                        TextState("全てのメモから削除されます")
                    })
                    return .none
                case .addTagButtonTapped:
                    return .run {[name = state.searchingText] send in
                        try await database.insertNewTag(Tag(name: name))
                    }
                case .confirmButtonTapped:
                    return .run { [tagIDs = state.selectingTags] send in
                        await send(.delegate(.selectingTagsConfirmed(tagIDs)))
                        await send(.internal(.dismiss))
                    }
                case .cancelButtonTapped:
                    state.isDismissed = true
                    return .none
                }
            case .internal(let action):
                switch action {
                case .dismiss:
                    state.isDismissed = true
                    return .none
                }
            case .alert(let action):
                switch action {
                case .dismiss:
                    state.alert = nil
                    return .none
                case .presented(let action):
                    switch action {
                    case .confirmDeleteTagButtonTapped(let tag):
                        state.selectingTags.remove(tag.id)
                        return .run { send in
                            try await database.deleteTag(tagID: tag.id)
                        }
                    }
                }
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
