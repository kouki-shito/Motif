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
import Dependencies

@Reducer
struct RecordingReducer {
    @ObservableState
    struct State: Equatable {
        var recordTitle: String = "新規録音 \(Date().dateToString(formatter: .recordTitle))" {
            didSet {
                guard recordTitle.trimmingCharacters(in: .whitespaces) == "" else { return }
                recordTitle = "新規録音 \(Date().dateToString(formatter: .recordTitle))"
            }
        }
        var currentTime: TimeInterval = 0
        var recordingStatus: RecordingStatus = .idle
        var barHeights: [CGFloat] = [CGFloat](repeating: 5.0, count: 200)
        var didAppear: Bool = false
        var isDismissed: Bool = false
        var isFavorite = false
        let recordID: UUID = UUID()
        var selectedTagIDs: Set<Tag.ID> = []
        @FetchAll var selectedTags: [Tag]
        @Presents var editTagReducerState: EditTagReducer.State?
        
        init() {
            _selectedTags = FetchAll(Tag.where { selectedTagIDs.contains($0.id) })
        }
    }
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case editTagReducerAction(PresentationAction<EditTagReducer.Action>)
        enum ViewAction: Equatable {
            case viewAppear
            case stopButtonTapped
            case pauseAndResumeButtonTapped
            case cancelButtonTapped
            case insertTagButtonTapped
            case deleteTagButtonTapped(Tag.ID)
            case bookmarkButtonTapped
        }
        enum InternalAction: Equatable {
            case updateRecordingStatus(RecordingStatus)
            case updateRecordingSample(RecordingSample)
            case dismiss
        }
        enum DelegateAction: Equatable {}
    }
    
    @Dependency(\.recorderClient) private var recorder: RecorderClient
    @Dependency(\.databaseClient) private var db: DatabaseClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .view(let action):
                switch action {
                case .viewAppear:
                    guard !state.didAppear else { return .none }
                    state.didAppear = true
                    return .run { [id = state.recordID] send in
                        do {
                            let stream = try await recorder.start(id)
                            await send(.internal(.updateRecordingStatus(try recorder.getStatus())))
                            for try await sample in stream {
                                await send(.internal(.updateRecordingSample(sample)))
                            }
                        } catch {
                            //TODO: show allert + dismiss
                            print(error)
                            await send(.internal(.dismiss))
                        }
                    }
                case .stopButtonTapped:
                    return .run { [id = state.recordID, title = state.recordTitle, isFav = state.isFavorite, tagIDs = state.selectedTagIDs] send in
                        do {
                            try await recorder.stop()
                            await send(.internal(.updateRecordingStatus(try recorder.getStatus())))
                            let duration = try await recorder.getDuration(id)
                            let record = Record(id: id, title: title, duration: duration, isFavorite: isFav)
                            try await db.insertRecord(record: record)
                            try await db.insertRecordTag(recordID: id, tagIDs: tagIDs)
                        } catch {
                            //TODO: show allert + dismiss
                            print(error)
                        }
                        await send(.internal(.dismiss))
                    }
                case .pauseAndResumeButtonTapped:
                    return .run { send in
                        try await recorder.togglePauseAndResume()
                        await send(.internal(.updateRecordingStatus(try recorder.getStatus())))
                    }
                case .cancelButtonTapped:
                    return .run { send in
                        try await recorder.cancel()
                        await send(.internal(.updateRecordingStatus(try recorder.getStatus())))
                        await send(.internal(.dismiss))
                    }
                case .insertTagButtonTapped:
                    state.editTagReducerState = EditTagReducer.State(selectingTags: state.selectedTagIDs)
                    return .none
                case .deleteTagButtonTapped(let id):
                    state.selectedTagIDs.remove(id)
                    return .run { [tags = state.$selectedTags, ids = state.selectedTagIDs] send in
                        try await tags.load(Tag.where { ids.contains($0.id) })
                    }
                case .bookmarkButtonTapped:
                    state.isFavorite.toggle()
                    return .none
                }
            case .internal(let action):
                switch action {
                case .updateRecordingSample(let sample):
                    state.currentTime = sample.currentTime
                    state.barHeights.removeFirst()
                    state.barHeights.append(sample.volumeBarHeight)
                    return .none
                case .updateRecordingStatus(let status):
                    state.recordingStatus = status
                    return .none
                case .dismiss:
                    state.isDismissed = true
                    return .none
                }
            case .editTagReducerAction(let action):
                switch action {
                case .dismiss:
                    state.editTagReducerState = nil
                    return .none
                case .presented(let action):
                    switch action {
                    case .delegate(let action):
                        switch action {
                        case .selectingTagsConfirmed(let tagIDs):
                            state.selectedTagIDs = tagIDs
                            return .run { [tags = state.$selectedTags, ids = state.selectedTagIDs] send in
                                try await tags.load(Tag.where { ids.contains($0.id) })
                            }
                        }
                    default:
                        return .none
                    }
                }
            }
        }
        .ifLet(\.$editTagReducerState, action: \.editTagReducerAction) {
            EditTagReducer()
        }
    }
}
