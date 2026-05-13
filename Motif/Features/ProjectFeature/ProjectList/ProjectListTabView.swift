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
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(project.title)
                                        .font(.system(size: 20))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .foregroundStyle(.gray)
                                    }
                                }
                                Text(project.createdAt.dateToString(formatter: Date.defaultFormatter))
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            }
                            HStack(spacing: 8) {
                                if let name = project.genre_name {
                                    tagItem(text: name, style: .selection )
                                }
                                if let bpm = project.bpm {
                                    tagItem(text: "\(bpm) BPM", iconName: "timer")
                                }
                                if let key = project.key {
                                    tagItem(text: key.description, iconName: "music.quarternote.3")
                                }
                            }
                        }
                    }
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(item: $store.scope(state: \.$projectEditSheetState, action: \.projectEditSheetAction), content: { store in
                ProjectEditSheetView(store: store)
                    .presentationBackground(.white)
            })
        }
    }
    
    @ViewBuilder
    func tagItem(text: String, iconName: String? = nil, style: some ShapeStyle = .secondary) -> some View {
        HStack(spacing: 8) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(style)
            }
            Text(text)
                .lineLimit(1)
                .font(.system(size: 16))
                .foregroundStyle(style)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style.opacity(0.1))
        .clipShape(Capsule())
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
