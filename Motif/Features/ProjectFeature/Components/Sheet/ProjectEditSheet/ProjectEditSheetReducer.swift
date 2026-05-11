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
        var title: String = ""
        var descriptionText = ""
        var lyricText = ""
        var bpm: Int? = nil
        var selectingKey: Key? = nil
        var selectingGenreID: Genre.ID? = nil
        var isConfirmButtonActive: Bool = false
        let majorKeyCases: [Key] = Key.majorAllCases
        let minorKeyCases: [Key] = Key.minorAllCases
        var genres: [Genre] = [
            Genre(id: UUID(), name: "Pops"),
            Genre(id: UUID(), name: "Lofi"),
            Genre(id: UUID(), name: "Electoro"),
            Genre(id: UUID(), name: "Futurebass"),
        ]
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
        enum internalAction: Equatable {}
        enum delegateAction: Equatable {}
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(let action):
                switch action {
                case .confirmButtonTapped:
                    return .none
                case .addGenreButtonTapped:
                    return .none
                }
            case .binding(\.title):
                if state.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    state.isConfirmButtonActive = false
                } else {
                    state.isConfirmButtonActive = true
                }
                return .none
            case .binding:
                return .none
            }
        }
    }
}

