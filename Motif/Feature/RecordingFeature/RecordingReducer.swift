//
//  RecordingReducer.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SQLiteData

@Reducer
struct RecordingReducer {
    @ObservableState
    struct State: Equatable {}
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(internalAction)
        case delegate(delegateAction)
        case binding(BindingAction<State>)
        enum ViewAction: Equatable {
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
            }
        }
    }
}
