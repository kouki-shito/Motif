//
//  ProjectEditSheetView.swift
//  Motif
//
//  Created by 市東 on 2026/05/10.
//

import SwiftUI
import ComposableArchitecture

struct ProjectEditSheetView: View {
    
    @Bindable var store: StoreOf<ProjectEditSheetReducer>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("タイトル", text: $store.title)
                }
                Section("楽曲情報") {
                    Picker("ジャンル", selection: $store.selectingGenreID) {
                        Text("ジャンルを選択").tag(Genre.ID?(nil))
                        ForEach(store.genres, id: \.id) { genre in
                            Text(genre.name).tag(genre.id)
                        }
                        Button {
                            store.send(.view(.addGenreButtonTapped))
                        } label: {
                            Text("追加...")
                        }
                    }
                    Picker("キー", selection: $store.selectingKey) {
                        Text("キーを選択").tag(Key?(nil))
                        Section("長調") {
                            ForEach(store.majorKeyCases, id: \.self) { key in
                                Text(key.description).tag(key)
                            }
                        }
                        Section("短調") {
                            ForEach(store.minorKeyCases, id: \.self) { key in
                                Text(key.description).tag(key)
                            }
                        }
                    }
                    HStack {
                        Text("BPM")
                        Spacer()
                        TextField("120", value: $store.bpm, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("メモ") {
                    PlaceholderTextEditor(text: $store.descriptionText, placeholder: "詳細情報を記入...")
                        .frame(height: 160)
                }
                Section("歌詞") {
                    PlaceholderTextEditor(text: $store.lyricText, placeholder: "歌詞を記入...")
                        .frame(height: 160)
                }
            }
            .navigationTitle("プロジェクト設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        store.send(.view(.confirmButtonTapped))
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                    .tint(.green)
                    .buttonStyle(.glassProminent)
                    .disabled(!store.isConfirmButtonActive)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectEditSheetView(store: Store(initialState: ProjectEditSheetReducer.State(), reducer: {
            ProjectEditSheetReducer()
        }))
    }
}
