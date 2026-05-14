//
//  ProjectListTabView.swift
//  Motif
//
//  Created by 市東 on 2026/05/06.
//

import SwiftUI
import ComposableArchitecture
import SQLiteData

struct ProjectListTabView: View {
    
    @Bindable var store: StoreOf<ProjectListReducer>
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(store.projects, id: \.id) { project in
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.title)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                Text(project.createdAt.dateToString(formatter: .defaultFormatter))
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            }
                            HStack(spacing: 8) {
                                if let name = project.genre_name {
                                    TagItem(text: name, style: .selection)
                                }
                                if let bpm = project.bpm {
                                    TagItem(text: "\(bpm) BPM", iconName: "timer", style: .secondary)
                                }
                                if let key = project.key {
                                    TagItem(text: key.shortName, iconName: "music.quarternote.3", style: .secondary)
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                Button {
                    store.send(.view(.addProjectButtonTapped))
                } label: {
                    ZStack(alignment: .center) {
                        Circle()
                            .foregroundStyle(.orange)
                            .glassEffect()
                            .frame(width: 64, height: 64)
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 8)
            }
            .navigationTitle("ライブラリ")
            .sheet(item: $store.scope(state: \.$projectEditSheetState, action: \.projectEditSheetAction), content: { store in
                ProjectEditSheetView(store: store)
                    .presentationBackground(.white)
            })
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        let db = try! appDatabase()
        $0.defaultDatabase = db
    }
    NavigationStack {
        ProjectListTabView(store: Store(initialState: ProjectListReducer.State(), reducer: {
            ProjectListReducer()
        }))
    }
}
