//
//  RecordingView.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import SwiftUI
import ComposableArchitecture
import SQLiteData

struct RecordingView: View {
    
    @Environment(\.dismiss) var dismiss
    @Bindable var store: StoreOf<RecordingReducer>
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.baseWhite)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("タイトルを記入...", text: $store.recordTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.textBlack)
                        tags()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
                    Spacer()
                    VStack(spacing: 64) {
                        RecordingWaveView(barHeights: store.barHeights)
                            .frame(height: 160)
                            .padding(.horizontal, 20)
                        VStack(spacing: 8) {
                            Text(store.currentTime.timeToString(formatter: .defaultFormatter))
                                .font(.system(size: 32))
                                .monospaced()
                                .monospacedDigit()
                                .foregroundStyle(store.recordingStatus == .idle ? .inactiveGray : .textBlack)
                        }
                    }
                    Spacer()
                    controls()
                        .padding(.horizontal, 34)
                        .padding(.bottom, 30)
                }
            }
            .navigationBarBackButtonHidden()
            .sheet(item: $store.scope(state: \.$editTagReducerState, action: \.editTagReducerAction), content: { store in
                EditTagSheetView(store: store)
                    .presentationBackground(.white)
            })
            .alert($store.scope(state: \.alert, action: \.alert))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.send(.view(.cancelButtonTapped))
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .fontWeight(.semibold)
                    }
                    .tint(.textBlack)
                }
            }
            .onAppear {
                store.send(.view(.viewAppear))
            }
            .onChange(of: store.isDismissed) { _, bool in
                guard bool else { return }
                dismiss()
            }
        }
        
    }
    
    @ViewBuilder
    private func tags() -> some View {
        HStack(spacing: 8) {
            ForEach(store.selectedTags, id: \.id) { tag in
                HStack(spacing: 4) {
                    Text(tag.name)
                        .foregroundStyle(.textBlack)
                    Button {
                        store.send(.view(.deleteTagButtonTapped(tag.id)))
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.subGray)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(.baseGray, in: Capsule())
            }
            Button {
                store.send(.view(.insertTagButtonTapped))
            } label: {
                Label("タグを追加", systemImage: "plus")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .frame(height: 32)
                    .tint(.primaryBlue)
                    .background(.baseGray, in: Capsule())
            }
        }
    }
    
    @ViewBuilder
    private func controls() -> some View {
        HStack(alignment: .center) {
            Spacer()
            Button {
                store.send(.view(.bookmarkButtonTapped))
            } label: {
                Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(store.isFavorite ? .dangerRed: .textBlack)
                    .padding(16)
            }
            .tint(.textBlack)
            .background(.baseGray)
            .clipShape(Circle())
            .disabled(store.recordingStatus == .idle)
            Spacer()
            
            Button {
                store.send(.view(.stopButtonTapped))
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 68, height: 68)
                
            }
            .tint(.white)
            .background(store.recordingStatus == .idle ? .baseGray : .dangerRed)
            .clipShape(Circle())
            .disabled(store.recordingStatus == .idle)
            
            Spacer()
            
            Button {
                store.send(.view(.pauseAndResumeButtonTapped))
            } label: {
                Image(systemName: store.recordingStatus == .pausing ?  "play.fill" : "pause.fill")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .padding(16)
            }
            .tint(.textBlack)
            .background(.baseGray)
            .clipShape(Circle())
            .disabled(store.recordingStatus == .idle)
            Spacer()
        }
    }
}

private struct RecordingTagChip: View {
    
    let title: String
    
    var body: some View {
        
    }
}

#Preview {
    let _ = prepareDependencies {
        let db = try! appDatabase()
        $0.defaultDatabase = db
    }
    RecordingView(store: Store(initialState: RecordingReducer.State(), reducer: {
        RecordingReducer()
    }))
}
