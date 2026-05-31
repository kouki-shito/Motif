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
        let recordID: UUID = UUID()
    }
    enum Action: BindableAction {
        case view(ViewAction)
        case `internal`(internalAction)
        case delegate(delegateAction)
        case binding(BindingAction<State>)
        enum ViewAction: Equatable {
            case viewAppear
            case stopButtonTapped
            case pauseAndResumeButtonTapped
            case cancelButtonTapped
        }
        enum internalAction: Equatable {
            case updateRecordingStatus(RecordingStatus)
            case updateRecordingSample(RecordingSample)
            case dismiss
        }
        enum delegateAction: Equatable {}
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
                        }
                    }
                case .stopButtonTapped:
                    return .run { [id = state.recordID, title = state.recordTitle] send in
                        do {
                            try await recorder.stop()
                            await send(.internal(.updateRecordingStatus(try recorder.getStatus())))
                            let duration = try await recorder.getDuration(id)
                            let record = Record(id: id, title: title, duration: duration, folder_id: nil)
                            try await db.insertRecord(record: record)
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
            }
        }
    }
}
