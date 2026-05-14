//
//  ProjectDetailView.swift
//  Motif
//
//  Created by 市東 on 2026/05/13.
//

import SwiftUI
import ComposableArchitecture
import SQLiteData

struct ProjectDetailView: View {
    
    @Bindable var store: StoreOf<ProjectDetailReducer>
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    Section {
                        RecordingSection()
                    } header: {
                        VStack(alignment: .leading, spacing: 8) {
                            headerSection()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(width: .infinity, height: .infinity, alignment: .topLeading)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    @ViewBuilder
    func headerSection() -> some View {
        VStack(alignment: .leading) {
            Text(store.project?.title ?? "読み込みエラー")
                .font(.system(size: 32))
                .fontWeight(.bold)
            Text(store.project?.createdAt.dateToString(formatter: .defaultFormatter) ?? "読み込みエラー")
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                if let name = store.project?.genre_name {
                    TagItem(text: name, style: .selection)
                }
                if let bpm = store.project?.bpm {
                    TagItem(text: "\(bpm) BPM", iconName: "timer", style: .secondary)
                }
                if let key = store.project?.key {
                    TagItem(text: key.shortName, iconName: "music.quarternote.3", style: .secondary)
                }
            }
            //        if let description = store.project?.description, description.isNotBlank() {
            //            Text(description)
            //                .frame(maxWidth: .infinity, alignment: .leading)
            //                .foregroundStyle(.secondary)
            //        }
            Text("""
                連想されるイメージ
                - 青い空
                - 少年少女
                - 学校
                - 困難と成長
                - すれ違い
                - 恋愛
                - 戻ってこない
                - 挑戦
                - 少年少女が旅に出るお話
                - 爽やかなポップス
                """)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    func RecordingSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            //            Text("録音した音声")
            //                .font(.system(size: 20))
            //                .fontWeight(.semibold)
            if store.records.isEmpty {
                VStack(alignment: .center) {
                    ContentUnavailableView("ボイスメモがありません", systemImage: "microphone")
                }
            } else {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(store.records, id: \.id) { record in
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text(record.name)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                HStack {
                                    Text(record.createdAt.dateToString(formatter: .defaultFormatter))
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 16))
                                    Text("1:34")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            TagItem(text: "Aメロ", style: .cyan)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        let db = try! appDatabase()
        $0.defaultDatabase = db
    }
    NavigationStack {
        ProjectDetailView(store: Store(initialState: ProjectDetailReducer.State(project_id: UUID()), reducer: {
            ProjectDetailReducer()
        }))
    }
}
