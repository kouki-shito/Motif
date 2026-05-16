//
//  RecordListView.swift
//  Motif
//
//  Created by 市東 on 2026/05/14.
//

import SwiftUI
import ComposableArchitecture
import SQLiteData

struct RecordListView: View {
    
    @Bindable var store: StoreOf<RecordListReducer>

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    header()
                    tagFilter()
                    recordList()
                }
                .padding(.horizontal, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.fixed, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        
                    } label: {
                        Circle()
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack {
            Menu {
                Picker("folder", selection: $store.selectedFolder) {
                    Text("すべてのメモ").tag(FolderSelection.all)
                    ForEach(store.folders, id: \.id) { folder in
                        Text(folder.name).tag(FolderSelection.folder(folder))
                    }
                }
                Button {
                    
                } label: {
                    Text("フォルダを追加...")
                }
            } label: {
                HStack {
                    Text(store.selectedFolder.description)
                        .lineLimit(1)
                        .font(.title2)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.down")
                }
                .frame(maxWidth: 240, alignment: .leading)
            }
            .tint(.primary)
            .compositingGroup() 
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .frame(width: 20, height: 28)
                    .contentShape(Circle())
                    .tint(.primary)
            }
            .buttonStyle(.glass)
            
        }
        .padding(.trailing, 8)
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    func tagFilter() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    store.selectedTag = .all
                } label: {
                    Text(TagSelection.all.description)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(store.selectedTag == .all ? .white : .primary)
                        .padding(.horizontal, 14)
                        .frame(height: 30)
                        .background(
                            Capsule()
                                .fill(store.selectedTag == .all ? Color.recordAccent : Color(.white))
                        )
                }
                ForEach(store.tags, id: \.self) { tag in
                    Button {
                        store.selectedTag = .tag(tag)
                    } label: {
                        Text(tag.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(store.selectedTag == .tag(tag) ? .white : .primary)
                            .padding(.horizontal, 14)
                            .frame(height: 30)
                            .background(
                                Capsule()
                                    .fill(store.selectedTag == .tag(tag) ? Color.recordAccent : Color(.white))
                            )
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    func recordList() -> some View {
        List {
            ForEach(store.recordWithTags, id: \.record.id) { recordWithTags in
                recordRow(recordWithTags: recordWithTags)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listRowSpacing(8)
        .listStyle(.plain)
        .buttonStyle(.plain)
        .searchable(text: $store.searchText, placement: .toolbar)
    }
    
    @ViewBuilder
    func recordRow(recordWithTags: RecordWithTags) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ForEach(recordWithTags.tags, id: \.id) { tag in
                        Text(tag.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .frame(height: 20)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
                Text(recordWithTags.record.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(recordWithTags.record.createdAt.dateToString(formatter: .defaultFormatter))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .center, spacing: 8) {
                Button {
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                }
                .tint(Color.recordAccent)
                Text(recordWithTags.record.duration.timeToString(formatter: .defaultFormatter))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private extension Color {
    static let recordAccent = Color(red: 0.43, green: 0.30, blue: 0.89)
}

#Preview {
    let _ = prepareDependencies {
        let db = try! appDatabase()
        $0.defaultDatabase = db
    }
    NavigationStack {
        RecordListView(store: Store(initialState: RecordListReducer.State(), reducer: {
            RecordListReducer()
        }))
    }
}
