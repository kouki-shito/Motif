//
//  RecordListReducer.swift
//  Motif
//
//  Created by 市東 on 2026/05/14.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import SQLiteData

@Reducer
struct RecordListReducer {
    @ObservableState
    struct State: Equatable {
        var selectedTag: TagSelection = .all
        var selectedFolder: FolderSelection = .all
        var searchText: String = ""
        @FetchAll var folders: [Folder]
        @FetchAll var tags: [Tag]
        @FetchAll(
            Record
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

//#sql(
//"""
//SELECT 
//\(Record.all),
//COALESCE(
//json_group_array(
//  json_object(
//    'id', \(Tag.id)
//    'name' \(Tag.name)
//  )  
//)            
//'[]'
//) AS \(Tag.self)
//FROM \(Record.self)
//LEFT JOIN \(RecordJunctionTag.self) ON \(Record.id) = \(RecordJunctionTag.record_id)
//LEFT JOIN \(Tag.self) ON \(RecordJunctionTag.tag_id) = \(Tag.id)
//GROUP BY \(Record.id)
//"""
//)
